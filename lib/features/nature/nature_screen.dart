import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/utils/risk_display.dart';
import '../../l10n/app_localizations.dart';
import '../../services/risk_data_cache.dart';
import '../../shared/widgets/app_sheet.dart';
import '../../shared/widgets/detection_safety_notice.dart';
import '../../shared/widgets/glass_panel.dart';
import '../../shared/widgets/section_header.dart';
import '../map/widgets/region_risk_layer.dart';
import 'nature_content.dart';
import 'nature_progress.dart';

/// The only green in the app, and only as an accent.
const Color natureGreen = AppColors.success;

Future<void> openSource(NatureSource s) => launchUrl(Uri.parse(s.url), mode: LaunchMode.externalApplication);

class SourceLink extends StatelessWidget {
  final NatureSource source;
  const SourceLink(this.source, {super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: () => openSource(source),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Flexible(
            child: Text(l10n.natureSource(source.name),
                style: GoogleFonts.ibmPlexSans(fontSize: 12, fontWeight: FontWeight.w600, color: natureGreen)),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.open_in_new_rounded, size: 13, color: natureGreen),
        ]),
      ),
    );
  }
}

class NatureProvince {
  final String plate;
  final String name;
  final int latestYear;
  final double latestHa;
  final int latestFires;
  const NatureProvince(this.plate, this.name, this.latestYear, this.latestHa, this.latestFires);
}

Future<List<NatureProvince>> loadNatureProvinces({AssetBundle? bundle}) async {
  final raw = await (bundle ?? rootBundle).loadString('assets/data/il_yil_veri.json');
  final iller = (jsonDecode(raw) as Map<String, dynamic>)['iller'] as Map<String, dynamic>;
  final out = <NatureProvince>[];
  iller.forEach((plate, v) {
    final years = (v['yillar'] as Map<String, dynamic>).keys.map(int.parse).toList()..sort();
    final last = years.last;
    final row = v['yillar']['$last'] as Map<String, dynamic>;
    out.add(NatureProvince(plate, '${v['il']}', last, (row['ogm_yanan_alan_ha'] as num?)?.toDouble() ?? 0, (row['ogm_yangin_sayisi'] as num?)?.toInt() ?? 0));
  });
  out.sort((a, b) => a.name.compareTo(b.name));
  return out;
}

/// At most one a day, off until asked for, and not an alert: it never goes
/// into the alerts inbox and has its own channel that can be turned off.
class NatureReminder {
  static const _id = 7301;
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<bool> enable(String title) async {
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission() ?? true;
    if (!granted) return false;
    await _plugin.periodicallyShow(
      _id,
      null,
      title,
      RepeatInterval.daily,
      const NotificationDetails(android: AndroidNotificationDetails('firewatch_nature', 'Doğa', importance: Importance.low, priority: Priority.low)),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
    return true;
  }

  static Future<void> disable() => _plugin.cancel(_id);
}

class NatureScreen extends StatefulWidget {
  /// Fixed in tests.
  final DateTime? today;
  const NatureScreen({super.key, this.today});

  @override
  State<NatureScreen> createState() => _NatureScreenState();
}

class _NatureScreenState extends State<NatureScreen> {
  List<NatureProvince> _provinces = const [];
  final _store = NatureStore.instance;

  DateTime get _today => widget.today ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    _store.addListener(_changed);
    _store.load();
    RiskDataCache.instance.warmUp().then((_) => _changed());
    loadNatureProvinces().then((p) {
      if (mounted) setState(() => _provinces = p);
    });
  }

  @override
  void dispose() {
    _store.removeListener(_changed);
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  NatureProvince? get _province {
    final plate = _store.progress.plate;
    for (final p in _provinces) {
      if (p.plate == plate) return p;
    }
    return null;
  }

  Map<String, dynamic>? get _regionRisk {
    final region = provinceRegion[_store.progress.plate];
    if (region == null) return null;
    for (final r in RiskDataCache.instance.regions) {
      if (foldRegionName('${r['region']}') == region) return r;
    }
    return null;
  }

  Future<void> _pickProvince() async {
    final picked = await showAppSheet<String>(
      context,
      scrollable: false,
      builder: (c) => ListView(
        shrinkWrap: true,
        children: [for (final p in _provinces) ListTile(title: Text(p.name), onTap: () => Navigator.of(c).pop(p.plate))],
      ),
    );
    if (picked != null) await _store.save(_store.progress.copyWith(plate: picked));
  }

  Future<void> _shareText(String text) async {
    await Share.share(text);
    await _store.addShare();
  }

  String _riskShareText(AppLocalizations l10n, Map<String, dynamic> risk) {
    final score = (risk['general_risk_score'] as num).toInt();
    return l10n.natureShareRisk(displayRegionName(l10n, '${risk['region']}'), riskLevelLabel(l10n, riskLevelForScore(score)), score);
  }

  Widget? _taskAction(AppLocalizations l10n, NatureTask task, String lang) {
    Widget button(String label, IconData icon, VoidCallback onTap) => TextButton.icon(
          key: const Key('natureTaskAction'),
          style: TextButton.styleFrom(foregroundColor: natureGreen, padding: EdgeInsets.zero),
          onPressed: onTap,
          icon: Icon(icon, size: 18),
          label: Text(label),
        );
    switch (task.kind) {
      case NatureTaskKind.shareRisk:
        final risk = _regionRisk;
        if (risk == null) return button(l10n.naturePickProvince, Icons.place_outlined, _pickProvince);
        return button(l10n.natureShare, Icons.share_rounded, () => _shareText(_riskShareText(l10n, risk)));
      case NatureTaskKind.shareFact:
        final f = factFor(_today);
        return button(l10n.natureShare, Icons.share_rounded, () => _shareText('${f.text.of(lang)}\n${l10n.natureSource(f.source.name)}: ${f.source.url}'));
      case NatureTaskKind.burnedArea:
        return button(l10n.homeSeeOnMap, Icons.map_outlined, () => context.go('/app?tab=map'));
      case NatureTaskKind.citizenScience:
        return button(l10n.natureOpenInat, Icons.open_in_new_rounded, () async {
          await openSource(inaturalist);
          await _store.addObservation();
        });
      case NatureTaskKind.doLesson:
        return null;
      case NatureTaskKind.prevention:
        return null;
    }
  }

  Widget _taskCard(AppLocalizations l10n, String lang, TextStyle h, TextStyle body) {
    final key = dayKey(_today);
    final p = _store.progress;
    final answered = p.days.containsKey(key);
    final swapped = p.swappedOn == key;
    final task = taskFor(_today, swapped: swapped);
    final action = _taskAction(l10n, task, lang);
    return GlassPanel(
      key: const Key('natureTask'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: SizedBox(
        width: double.infinity,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l10n.natureTodayTask, style: GoogleFonts.ibmPlexSans(fontSize: 13, fontWeight: FontWeight.w700, color: natureGreen)),
          const SizedBox(height: 6),
          if (answered)
            Text(l10n.natureTaskSaved, key: const Key('natureTaskSaved'), style: h)
          else ...[
            Text(task.text.of(lang), style: h),
            if (task.source != null) SourceLink(task.source!),
            if (task.kind == NatureTaskKind.burnedArea && _province != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(l10n.natureProvinceStat(_province!.name, _province!.latestYear, _province!.latestHa.round(), _province!.latestFires), style: body),
              ),
            ?action,
            const SizedBox(height: AppSpacing.sm),
            Row(children: [
              Expanded(
                child: FilledButton(
                  key: const Key('natureYes'),
                  style: FilledButton.styleFrom(backgroundColor: natureGreen, foregroundColor: AppColors.white),
                  onPressed: () => _store.mark(_today, true),
                  child: Text(l10n.natureYes),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton(
                  key: const Key('natureNo'),
                  onPressed: () => _store.mark(_today, false),
                  child: Text(l10n.natureNo),
                ),
              ),
            ]),
            if (!swapped)
              Center(
                child: TextButton(
                  key: const Key('natureSwap'),
                  onPressed: () => _store.save(p.copyWith(swappedOn: key)),
                  child: Text(l10n.natureAnotherTask),
                ),
              ),
          ],
        ]),
      ),
    );
  }

  Widget _progressCard(AppLocalizations l10n, TextStyle body) {
    final p = _store.progress;
    final dots = weekDots(p.days, _today);
    final goal = goalFor(_today);
    final (String goalText, int done, int target) = switch (goal) {
      WeeklyGoal.days => (l10n.natureGoalDays, daysThisWeek(p.days, _today), 4),
      WeeklyGoal.lesson => (l10n.natureGoalLesson, p.lessons.isEmpty ? 0 : 1, 1),
      WeeklyGoal.shares => (l10n.natureGoalShares, p.shares.clamp(0, 2), 2),
    };
    return GlassPanel(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: SizedBox(
        width: double.infinity,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            for (final d in dots)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Icon(d ? Icons.circle : Icons.circle_outlined, size: 13, color: d ? natureGreen : Theme.of(context).textTheme.bodySmall?.color),
              ),
            const Spacer(),
            if (!p.hideStreak) Text(l10n.natureStreak(currentStreak(p.days, _today)), key: const Key('natureStreak'), style: GoogleFonts.ibmPlexSans(fontSize: 14, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: AppSpacing.sm),
          Text(l10n.natureWeeklyChallenge, style: GoogleFonts.ibmPlexSans(fontSize: 13, fontWeight: FontWeight.w700, color: natureGreen)),
          Text('$goalText ($done/$target)', style: body),
        ]),
      ),
    );
  }

  String _badgeName(AppLocalizations l10n, NatureBadge b) => switch (b) {
        NatureBadge.firstStep => l10n.natureBadgeFirst,
        NatureBadge.sevenDays => l10n.natureBadgeSeven,
        NatureBadge.thirtyDays => l10n.natureBadgeThirty,
        NatureBadge.fourSeasons => l10n.natureBadgeSeasons,
        NatureBadge.curious => l10n.natureBadgeCurious,
        NatureBadge.knowledgeable => l10n.natureBadgeAllLessons,
        NatureBadge.sharer => l10n.natureBadgeSharer,
        NatureBadge.observer => l10n.natureBadgeObserver,
      };

  Future<void> _openSettings() => showAppSheet<void>(
        context,
        builder: (_) => const _NatureSettings(),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final muted = Theme.of(context).textTheme.bodySmall?.color;
    final h = GoogleFonts.ibmPlexSans(fontSize: 17, height: 1.35, fontWeight: FontWeight.w700);
    final body = GoogleFonts.ibmPlexSans(fontSize: 14, height: 1.45, color: muted);
    final fact = factFor(_today);
    final earned = earnedBadges(_store.progress);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navNature, style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700)),
        actions: [IconButton(key: const Key('natureSettings'), tooltip: l10n.navSettings, icon: const Icon(Icons.tune_rounded), onPressed: _openSettings)],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const DetectionSafetyNotice(prominent: false),
          const SizedBox(height: AppSpacing.sm),
          _taskCard(l10n, lang, h, body),
          const SizedBox(height: AppSpacing.md),
          _progressCard(l10n, body),
          const SizedBox(height: AppSpacing.md),
          GlassPanel(
            key: const Key('natureFact'),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: SizedBox(
              width: double.infinity,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l10n.natureFactTitle, style: GoogleFonts.ibmPlexSans(fontSize: 13, fontWeight: FontWeight.w700, color: natureGreen)),
                const SizedBox(height: 6),
                Text(fact.text.of(lang), style: GoogleFonts.ibmPlexSans(fontSize: 15, height: 1.45, fontWeight: FontWeight.w600)),
                SourceLink(fact.source),
              ]),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(title: l10n.natureLessons, icon: const Icon(Icons.menu_book_rounded)),
          const SizedBox(height: AppSpacing.md),
          for (final lesson in natureLessons)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: InkWell(
                key: Key('natureLesson-${lesson.id}'),
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => NatureLessonScreen(lesson: lesson))),
                child: GlassPanel(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(children: [
                    Icon(_store.progress.lessons.contains(lesson.id) ? Icons.check_circle_rounded : Icons.circle_outlined, color: natureGreen, size: 20),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: Text(lesson.title.of(lang), style: GoogleFonts.ibmPlexSans(fontSize: 15, fontWeight: FontWeight.w700))),
                    Text(l10n.natureLessonLength(lesson.cards.length), style: GoogleFonts.ibmPlexSans(fontSize: 12.5, color: muted)),
                  ]),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          SectionHeader(title: l10n.natureBadges, icon: const Icon(Icons.emoji_events_outlined)),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final b in NatureBadge.values)
                Chip(
                  avatar: Icon(earned.contains(b) ? Icons.eco : Icons.lock_outline_rounded, size: 16, color: earned.contains(b) ? natureGreen : muted),
                  label: Text(_badgeName(l10n, b), style: GoogleFonts.ibmPlexSans(fontSize: 12.5)),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(l10n.natureOnDevice, style: GoogleFonts.ibmPlexSans(fontSize: 12, height: 1.4, color: muted)),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _NatureSettings extends StatefulWidget {
  const _NatureSettings();

  @override
  State<_NatureSettings> createState() => _NatureSettingsState();
}

class _NatureSettingsState extends State<_NatureSettings> {
  final _store = NatureStore.instance;
  List<NatureProvince> _provinces = const [];

  @override
  void initState() {
    super.initState();
    loadNatureProvinces().then((p) {
      if (mounted) setState(() => _provinces = p);
    });
  }

  Future<void> _pick() async {
    final picked = await showAppSheet<String>(
      context,
      scrollable: false,
      builder: (c) => ListView(
        shrinkWrap: true,
        children: [for (final p in _provinces) ListTile(title: Text(p.name), onTap: () => Navigator.of(c).pop(p.plate))],
      ),
    );
    if (picked != null) {
      await _store.save(_store.progress.copyWith(plate: picked));
      if (mounted) setState(() {});
    }
  }

  Future<void> _delete(AppLocalizations l10n) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: DialogTitleWithClose(title: Text(l10n.natureDeleteTitle)),
        content: Text(l10n.natureDeleteBody),
        actions: [
          TextButton(onPressed: () => Navigator.of(c).pop(false), child: Text(l10n.commonCancel)),
          FilledButton(key: const Key('natureDeleteConfirm'), onPressed: () => Navigator.of(c).pop(true), child: Text(l10n.natureDeleteConfirm)),
        ],
      ),
    );
    if (ok != true) return;
    await NatureReminder.disable();
    await _store.deleteAll();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = _store.progress;
    String? provinceName;
    for (final x in _provinces) {
      if (x.plate == p.plate) provinceName = x.name;
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(contentPadding: EdgeInsets.zero, title: Text(l10n.natureProvince), subtitle: Text(provinceName ?? l10n.naturePickProvince), onTap: _pick),
        SwitchListTile(
          key: const Key('natureReminder'),
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.natureReminder),
          subtitle: Text(l10n.natureReminderDesc),
          value: p.reminder,
          onChanged: (on) async {
            if (on) {
              final ok = await NatureReminder.enable(l10n.natureReminderText);
              await _store.save(p.copyWith(reminder: ok));
            } else {
              await NatureReminder.disable();
              await _store.save(p.copyWith(reminder: false));
            }
            if (mounted) setState(() {});
          },
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.natureShowStreak),
          value: !p.hideStreak,
          onChanged: (on) async {
            await _store.save(p.copyWith(hideStreak: !on));
            if (mounted) setState(() {});
          },
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(key: const Key('natureDelete'), onPressed: () => _delete(l10n), child: Text(l10n.natureDeleteTitle)),
        ),
      ]),
    );
  }
}

class NatureLessonScreen extends StatefulWidget {
  final NatureLesson lesson;
  const NatureLessonScreen({super.key, required this.lesson});

  @override
  State<NatureLessonScreen> createState() => _NatureLessonScreenState();
}

class _NatureLessonScreenState extends State<NatureLessonScreen> {
  int _step = 0;
  int? _chosen;

  int get _cards => widget.lesson.cards.length;
  int get _total => _cards + widget.lesson.quiz.length;

  void _next() {
    if (_step + 1 >= _total) {
      NatureStore.instance.finishLesson(widget.lesson.id);
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _step++;
      _chosen = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final h = GoogleFonts.ibmPlexSans(fontSize: 21, height: 1.3, fontWeight: FontWeight.w800);
    final body = GoogleFonts.ibmPlexSans(fontSize: 16, height: 1.5);
    final isQuiz = _step >= _cards;
    final Widget content;
    var canContinue = true;
    if (!isQuiz) {
      final c = widget.lesson.cards[_step];
      content = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(c.title.of(lang), style: h),
        const SizedBox(height: AppSpacing.md),
        Text(c.body.of(lang), style: body),
        const SizedBox(height: AppSpacing.md),
        for (final s in c.sources) SourceLink(s),
      ]);
    } else {
      final q = widget.lesson.quiz[_step - _cards];
      canContinue = _chosen != null;
      content = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(q.question.of(lang), style: h),
        const SizedBox(height: AppSpacing.md),
        for (final (i, o) in q.options.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                key: Key('natureOption-$i'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _chosen == null ? null : (i == q.correct ? natureGreen : null),
                  side: _chosen != null && i == q.correct ? const BorderSide(color: natureGreen, width: 2) : null,
                ),
                onPressed: () => setState(() => _chosen = i),
                child: Text(o.of(lang), textAlign: TextAlign.center),
              ),
            ),
          ),
        if (_chosen != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(q.feedback.of(lang), key: const Key('natureFeedback'), style: body),
          SourceLink(q.source),
        ],
      ]);
    }
    return Scaffold(
      appBar: AppBar(title: Text(widget.lesson.title.of(lang), style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            LinearProgressIndicator(value: (_step + 1) / _total, color: natureGreen, minHeight: 4),
            const SizedBox(height: AppSpacing.lg),
            Expanded(child: SingleChildScrollView(child: content)),
            FilledButton(
              key: const Key('natureNext'),
              style: FilledButton.styleFrom(backgroundColor: natureGreen, foregroundColor: AppColors.white),
              onPressed: canContinue ? _next : null,
              child: Text(_step + 1 >= _total ? l10n.natureFinish : l10n.coachMarksNext),
            ),
          ]),
        ),
      ),
    );
  }
}
