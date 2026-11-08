import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/risk_display.dart';
import '../../l10n/app_localizations.dart';
import '../../services/risk_data_cache.dart';
import '../../shared/widgets/app_sheet.dart';
import '../../shared/widgets/detection_safety_notice.dart';
import '../../shared/widgets/glass_panel.dart';
import '../map/widgets/region_risk_layer.dart';
import 'fact_widgets.dart';
import 'fidan_account.dart';
import 'nature_content.dart';
import 'nature_facts.dart';
import 'nature_progress.dart';
import 'tree.dart';

part 'fidan_lessons.dart';

/// White text on this reaches 3:1, the minimum for large button labels.
const leaf = Color(0xFF3F9A1F);
const leafDark = Color(0xFF2F6B1A);
const cream = Color(0xFFF3FBE8);
const ink = Color(0xFF24401A);
const inkSoft = Color(0xFF55704A);
const _lightGreen = Color(0xFFDFF3C9);

TextStyle _t(double size, {FontWeight weight = FontWeight.w500, Color color = ink, double? height, TextDecoration? deco}) =>
    GoogleFonts.ibmPlexSans(fontSize: size, fontWeight: weight, color: color, height: height, decoration: deco, decorationColor: color);

/// The one light, green corner of the app.
class FidanTheme extends StatelessWidget {
  final Widget child;
  const FidanTheme({super.key, required this.child});

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle.dark,
    child: Theme(
      data: AppTheme.lightTheme.copyWith(scaffoldBackgroundColor: cream),
      child: child,
    ),
  );
}

Future<void> _open(String url) => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

class _SourceText extends StatelessWidget {
  final String name;
  final String url;
  const _SourceText(this.name, this.url);

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => _open(url),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Text(
        AppLocalizations.of(context)!.natureSource(name),
        style: _t(13, color: leafDark, deco: TextDecoration.underline),
      ),
    ),
  );
}

class BigGreenButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final Color color;
  const BigGreenButton(this.text, {super.key, this.onTap, this.color = leaf});

  @override
  Widget build(BuildContext context) => Material(
    color: onTap == null ? color.withValues(alpha: 0.4) : color,
    borderRadius: BorderRadius.circular(20),
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 58),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: _t(19, weight: FontWeight.w800, color: Colors.white),
            ),
          ),
        ),
      ),
    ),
  );
}

class _Pill extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  const _Pill(this.text, {this.onTap, super.key});

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        child: Text(text, style: _t(14.5, weight: FontWeight.w800)),
      ),
    ),
  );
}

class _WeekRing extends StatelessWidget {
  final int done;
  const _WeekRing(this.done);

  @override
  Widget build(BuildContext context) {
    final shown = done.clamp(0, weeklyGoalDays);
    return Tooltip(
      message: AppLocalizations.of(context)!.fidanWeekGoal(shown, weeklyGoalDays),
      child: SizedBox.square(
        dimension: 48,
        child: CustomPaint(
          painter: RingPainter(shown / weeklyGoalDays, leaf, const Color(0xFFD5EBBD)),
          child: Center(
            child: FittedBox(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text('$shown/$weeklyGoalDays', style: _t(12.5, weight: FontWeight.w800)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String stageName(AppLocalizations l10n, int stage) => switch (stage) {
  0 => l10n.fidanStage0,
  1 => l10n.fidanStage1,
  2 => l10n.fidanStage2,
  3 => l10n.fidanStage3,
  4 => l10n.fidanStage4,
  _ => l10n.fidanStage5,
};

String appleLabel(AppLocalizations l10n, Apple apple, String lang) {
  if (apple.section != null) {
    final section = natureSections.firstWhere((x) => x.id == apple.section);
    return l10n.fidanAppleSection(section.title.of(lang));
  }
  if (apple.lesson != null) {
    final lesson = natureLessons.firstWhere((l) => l.id == apple.lesson);
    return l10n.fidanAppleLesson(lesson.title.of(lang));
  }
  return l10n.fidanAppleWeek(apple.week!);
}

/// At most one a day, off until asked for, and not an alert: it never goes
/// into the alerts inbox and has its own channel that can be turned off.
class NatureReminder {
  static const _firstId = 7301;
  static const _ids = 8;
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ?? true;
  }

  /// Replaces whatever is queued with what [p] calls for now.
  static Future<void> sync(NatureProgress p, AppLocalizations l10n, {DateTime? now}) async {
    try {
      for (var i = 0; i < _ids; i++) {
        await _plugin.cancel(_firstId + i);
      }
      if (!p.reminder) return;
      final at = now ?? DateTime.now();
      final details = NotificationDetails(
        android: AndroidNotificationDetails('firewatch_nature_notes', l10n.fidanReminderChannel, importance: Importance.low, priority: Priority.low),
      );
      final times = reminderTimes(at, hour: p.reminderHour, minute: p.reminderMinute, doneToday: p.days.containsKey(dayKey(at)));
      for (final (i, t) in times.indexed) {
        await _plugin.zonedSchedule(
          _firstId + i,
          null,
          l10n.natureReminderText,
          tz.TZDateTime.from(t.toUtc(), tz.UTC),
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Nature reminder: $e');
    }
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

void openLessonPath(BuildContext context, {DateTime? today}) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => LessonPathScreen(today: today)));

/// The Fidan card on the home screen.
class FidanHomeCard extends StatefulWidget {
  final DateTime? today;
  const FidanHomeCard({super.key, this.today});

  @override
  State<FidanHomeCard> createState() => _FidanHomeCardState();
}

class _FidanHomeCardState extends State<FidanHomeCard> {
  final _store = NatureStore.instance;
  DateTime get _today => widget.today ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    _store.addListener(_changed);
    _store.load().then((_) => FidanAccount.instance.start());
  }

  @override
  void dispose() {
    _store.removeListener(_changed);
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final p = _store.progress;
    final key = dayKey(_today);
    final task = taskFor(_today, swapped: p.swappedOn == key);
    final done = p.days[key] == true;
    final muted = Theme.of(context).textTheme.bodySmall?.color;
    final strong = GoogleFonts.ibmPlexSans(fontSize: 13.5, fontWeight: FontWeight.w700, color: muted);
    final thirsty = isThirsty(p, _today);
    return InkWell(
      key: const Key('fidanHomeCard'),
      borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius),
      onTap: () => context.push('/fidan'),
      child: GlassPanel(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${l10n.navNature} · ${l10n.fidanName}',
                    style: GoogleFonts.ibmPlexSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.success),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, size: 20, color: muted),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.all(4),
                  child: TreeView(stage: treeStage(p), season: seasonOf(_today), mood: thirsty ? Mood.thirsty : Mood.calm, apples: applesOf(p).length, flowers: sectionsDone(p).length, size: 78),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(thirsty ? l10n.fidanThirsty : (done ? l10n.fidanTaskDone : task.title.of(lang)), style: GoogleFonts.ibmPlexSans(fontSize: 16, height: 1.25, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 12,
                        children: [
                          if (!p.hideStreak) Text('🔥 ${currentStreak(p.days, _today)}', style: strong),
                          Text('⭐ ${l10n.fidanXpTotal(xpOf(p))}', style: strong),
                          Text('🍎 ${applesOf(p).length}', style: strong),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(
              key: const Key('fidanLessons'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.success,
                side: BorderSide(color: AppColors.success.withValues(alpha: 0.5)),
              ),
              onPressed: () => openLessonPath(context, today: widget.today),
              child: Text(l10n.fidanContinueLessons),
            ),
          ],
        ),
      ),
    );
  }
}

class FidanScreen extends StatefulWidget {
  /// Fixed in tests.
  final DateTime? today;
  const FidanScreen({super.key, this.today});

  @override
  State<FidanScreen> createState() => _FidanScreenState();
}

class _FidanScreenState extends State<FidanScreen> {
  final _store = NatureStore.instance;
  List<NatureProvince> _provinces = const [];
  NatureFact? _fact;
  Apple? _bubble;

  DateTime get _today => widget.today ?? DateTime.now();

  static const double _treeSize = 236;

  @override
  void initState() {
    super.initState();
    _store.addListener(_changed);
    _store.load().then((_) {
      if (mounted && _store.progress.reminder) _syncReminder();
      FidanAccount.instance.start();
    });
    RiskDataCache.instance.warmUp().then((_) => _changed());
    loadNatureProvinces().then((p) {
      if (mounted) setState(() => _provinces = p);
    });
    NatureFacts.instance
        .today(_today)
        .then((f) {
          if (mounted) setState(() => _fact = f);
        })
        .catchError((Object _) {});
  }

  @override
  void dispose() {
    _store.removeListener(_changed);
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  Future<void> _syncReminder() => NatureReminder.sync(_store.progress, AppLocalizations.of(context)!);

  Future<void> _done() async {
    final l10n = AppLocalizations.of(context)!;
    final before = _store.progress;
    await _store.mark(_today, true);
    if (!mounted) return;
    if (_store.progress.reminder) await _syncReminder();
    if (!mounted) return;
    final after = _store.progress;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FidanRewardScreen(
          xp: xpOf(after) - xpOf(before),
          newApple: applesOf(after).length > applesOf(before).length,
          grewTo: treeStage(after) > treeStage(before) ? treeStage(after) : null,
          message: l10n.fidanRewardTask,
          today: _today,
        ),
      ),
    );
  }

  NatureProvince? get _province {
    for (final p in _provinces) {
      if (p.plate == _store.progress.plate) return p;
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

  Widget? _taskAction(AppLocalizations l10n, NatureTask task, String lang) {
    Widget button(String label, IconData icon, VoidCallback onTap) => TextButton.icon(
      key: const Key('natureTaskAction'),
      style: TextButton.styleFrom(foregroundColor: leafDark, padding: EdgeInsets.zero),
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
    switch (task.kind) {
      case NatureTaskKind.shareRisk:
        final risk = _regionRisk;
        if (risk == null) return button(l10n.naturePickProvince, Icons.place_outlined, _pickProvince);
        final score = (risk['general_risk_score'] as num).toInt();
        return button(
          l10n.natureShare,
          Icons.share_rounded,
          () => _shareText(l10n.natureShareRisk(displayRegionName(l10n, '${risk['region']}'), riskLevelLabel(l10n, riskLevelForScore(score)), score)),
        );
      case NatureTaskKind.shareFact:
        final f = _fact;
        if (f == null) return null;
        return button(l10n.natureShare, Icons.share_rounded, () => _shareText('${f.of(lang)}\n${l10n.natureSource(f.sourceName)}: ${f.sourceUrl}'));
      case NatureTaskKind.burnedArea:
        return button(l10n.homeSeeOnMap, Icons.map_outlined, () => context.go('/map'));
      case NatureTaskKind.citizenScience:
        return button(l10n.natureOpenInat, Icons.open_in_new_rounded, () async {
          await _open(inaturalist.url);
          await _store.addObservation();
        });
      case NatureTaskKind.doLesson:
      case NatureTaskKind.prevention:
        return null;
    }
  }

  Widget _treePanel(AppLocalizations l10n, String lang, NatureProgress p) {
    final stage = treeStage(p);
    final apples = applesOf(p);
    final spots = stage >= 3 ? appleSpots(stage).take(apples.length).toList() : const <Offset>[];
    final thirsty = isThirsty(p, _today);
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          height: 256,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: seasonOf(_today) == Season.winter ? const [Color(0xFFDCEBF7), Color(0xFFF0F6FB)] : const [Color(0xFFD8F1FF), Color(0xFFEAF8DA)],
            ),
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: GestureDetector(
            key: const Key('fidanTree'),
            onTapUp: (d) {
              final at = d.localPosition * (200 / _treeSize);
              Apple? hit;
              for (final (i, s) in spots.indexed) {
                if ((s - at).distance <= 20) hit = apples[i];
              }
              setState(() => _bubble = hit);
            },
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              switchInCurve: Curves.elasticOut,
              transitionBuilder: (child, a) => ScaleTransition(scale: a, child: child),
              child: TreeView(
                key: ValueKey(stage),
                stage: stage,
                season: seasonOf(_today),
                mood: thirsty ? Mood.thirsty : (p.days[dayKey(_today)] == true ? Mood.happy : Mood.calm),
                apples: apples.length,
                size: _treeSize,
              ),
            ),
          ),
        ),
        if (_bubble != null)
          Positioned(
            right: 10,
            top: 16,
            child: Container(
              key: const Key('fidanAppleBubble'),
              constraints: const BoxConstraints(maxWidth: 150),
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
              child: Text(appleLabel(l10n, _bubble!, lang), style: _t(12.5, weight: FontWeight.w600)),
            ),
          ),
        if (thirsty) const Positioned(left: 18, top: 22, child: Text('💧', style: TextStyle(fontSize: 30))),
      ],
    );
  }

  Widget _taskCard(AppLocalizations l10n, String lang, NatureProgress p) {
    final key = dayKey(_today);
    final swapped = p.swappedOn == key;
    final task = taskFor(_today, swapped: swapped);
    final answered = p.days.containsKey(key);
    final action = _taskAction(l10n, task, lang);
    return Container(
      key: const Key('natureTask'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: answered
          ? Text(
              l10n.fidanTaskDone,
              key: const Key('natureTaskSaved'),
              style: _t(19, weight: FontWeight.w900),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(task.title.of(lang), style: _t(23, weight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text(task.text.of(lang), style: _t(16, color: inkSoft, height: 1.3)),
                if (task.source != null) Align(alignment: Alignment.centerLeft, child: _SourceText(task.source!.name, task.source!.url)),
                if (task.kind == NatureTaskKind.burnedArea && _province != null)
                  Text(l10n.natureProvinceStat(_province!.name, _province!.latestYear, _province!.latestHa.round(), _province!.latestFires), style: _t(14, color: inkSoft)),
                if (action != null) Align(alignment: Alignment.centerLeft, child: action),
                const SizedBox(height: 10),
                BigGreenButton(l10n.fidanDone, key: const Key('natureYes'), onTap: _done),
                if (!swapped)
                  Center(
                    child: TextButton(
                      key: const Key('natureSwap'),
                      style: TextButton.styleFrom(foregroundColor: leafDark),
                      onPressed: () => _store.save(p.copyWith(swappedOn: key)),
                      child: Text(
                        l10n.natureAnotherTask,
                        style: _t(16, weight: FontWeight.w700, color: leafDark),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  void _showApples(AppLocalizations l10n, String lang, List<Apple> apples) => showAppSheet<void>(
    context,
    builder: (_) => Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (apples.isEmpty) Text(l10n.fidanNoApples),
          for (final a in apples) Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Text(appleLabel(l10n, a, lang))),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final p = _store.progress;
    final stage = treeStage(p);
    final apples = applesOf(p);
    final thirsty = isThirsty(p, _today);
    final fact = _fact;
    return FidanTheme(
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                    onPressed: () => context.canPop() ? context.pop() : context.go('/app'),
                    icon: const Icon(Icons.arrow_back_rounded, color: ink),
                  ),
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (!p.hideStreak) _Pill('🔥 ${l10n.natureStreak(currentStreak(p.days, _today))}', key: const Key('natureStreak')),
                        _Pill('⭐ ${l10n.fidanXpTotal(xpOf(p))}'),
                        _Pill('🍎 ${apples.length}', key: const Key('fidanApples'), onTap: () => _showApples(l10n, lang, apples)),
                      ],
                    ),
                  ),
                  _WeekRing(daysThisWeek(p.days, _today)),
                  IconButton(
                    key: const Key('natureSettings'),
                    tooltip: l10n.navSettings,
                    icon: const Icon(Icons.tune_rounded, color: ink),
                    onPressed: () => showAppSheet<void>(context, builder: (_) => const _FidanSettings()),
                  ),
                ],
              ),
              _treePanel(l10n, lang, p),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  '${l10n.fidanName} · ${stageName(l10n, stage)}',
                  style: _t(16, weight: FontWeight.w800, color: leafDark),
                ),
              ),
              if (thirsty) ...[
                const SizedBox(height: 6),
                Text(
                  l10n.fidanThirsty,
                  key: const Key('fidanThirsty'),
                  textAlign: TextAlign.center,
                  style: _t(22, weight: FontWeight.w900),
                ),
                Text(
                  l10n.fidanThirstyBody,
                  textAlign: TextAlign.center,
                  style: _t(16, color: inkSoft),
                ),
              ],
              if (stage == 5) ...[
                const SizedBox(height: 8),
                Container(
                  key: const Key('fidanFullGrown'),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: const Color(0xFFFFF1C9), borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    l10n.fidanFullGrown,
                    textAlign: TextAlign.center,
                    style: _t(17, weight: FontWeight.w800),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              _taskCard(l10n, lang, p),
              const SizedBox(height: 12),
              BigGreenButton(l10n.fidanContinueLessons, onTap: () => openLessonPath(context, today: widget.today)),
              if (fact != null) ...[
                const SizedBox(height: 12),
                Container(
                  key: const Key('natureFact'),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: _lightGreen, borderRadius: BorderRadius.circular(22)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.fidanDidYouKnow, style: _t(16, weight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Text(fact.of(lang), style: _t(16, height: 1.3)),
                      Row(children: [
                        Expanded(child: _SourceText(fact.sourceName, fact.sourceUrl)),
                        IconButton(key: const Key('fidanFactShare'), tooltip: l10n.natureShare, onPressed: () => shareFact(context, fact), icon: const Icon(Icons.ios_share_rounded, color: leafDark, size: 20)),
                      ]),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 8),
              TextButton.icon(
                key: const Key('fidanShare'),
                style: TextButton.styleFrom(foregroundColor: leafDark),
                onPressed: () => showAppSheet<void>(context, builder: (_) => _ShareSheet(today: _today)),
                icon: const Icon(Icons.ios_share_rounded),
                label: Text(l10n.fidanShare),
              ),
              const SizedBox(height: 4),
              const DetectionSafetyNotice(prominent: false),
              Text(l10n.natureOnDevice, style: _t(12, color: inkSoft, height: 1.4)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShareSheet extends StatefulWidget {
  final DateTime today;
  const _ShareSheet({required this.today});

  @override
  State<_ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<_ShareSheet> {
  final _key = GlobalKey();

  Future<void> _share(String text) async {
    final boundary = _key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('${(await getTemporaryDirectory()).path}/agacim.png');
    await file.writeAsBytes(bytes!.buffer.asUint8List());
    await Share.shareXFiles([XFile(file.path, mimeType: 'image/png')], text: text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = NatureStore.instance.progress;
    final caption = l10n.fidanShareCard(activeDays(p));
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RepaintBoundary(
            key: _key,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: cream, borderRadius: BorderRadius.circular(24)),
              child: Column(
                children: [
                  TreeView(stage: treeStage(p), season: seasonOf(widget.today), mood: Mood.happy, apples: applesOf(p).length, flowers: sectionsDone(p).length, size: 200),
                  Text(
                    caption,
                    textAlign: TextAlign.center,
                    style: _t(22, weight: FontWeight.w900),
                  ),
                  Text('FireWatch TR', style: _t(13, color: inkSoft)),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          BigGreenButton(l10n.natureShare, onTap: () => _share(caption)),
        ],
      ),
    );
  }
}

class _FidanSettings extends StatefulWidget {
  const _FidanSettings();

  @override
  State<_FidanSettings> createState() => _FidanSettingsState();
}

class _FidanSettingsState extends State<_FidanSettings> {
  final _store = NatureStore.instance;
  final _account = FidanAccount.instance;
  List<NatureProvince> _provinces = const [];

  @override
  void initState() {
    super.initState();
    _account.addListener(_changed);
    loadNatureProvinces().then((p) {
      if (mounted) setState(() => _provinces = p);
    });
  }

  @override
  void dispose() {
    _account.removeListener(_changed);
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
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

  Future<bool> _confirm(AppLocalizations l10n, String title, String body, Key key) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: DialogTitleWithClose(title: Text(title)),
        content: Text(body),
        actions: [
          TextButton(onPressed: () => Navigator.of(c).pop(false), child: Text(l10n.commonCancel)),
          FilledButton(key: key, onPressed: () => Navigator.of(c).pop(true), child: Text(l10n.natureDeleteConfirm)),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _deleteLocal(AppLocalizations l10n) async {
    if (!await _confirm(l10n, l10n.natureDeleteTitle, l10n.natureDeleteBody, const Key('natureDeleteConfirm'))) return;
    await _store.deleteAll();
    await NatureReminder.sync(_store.progress, l10n);
    if (mounted) setState(() {});
  }

  Future<void> _deleteAccount(AppLocalizations l10n) async {
    if (!await _confirm(l10n, l10n.fidanDeleteAccount, l10n.fidanDeleteAccountBody, const Key('fidanDeleteAccountConfirm'))) return;
    final result = await _account.deleteAccount();
    if (!mounted) return;
    if (result == FidanAuthResult.ok) await NatureReminder.sync(_store.progress, l10n);
    if (!mounted || result == FidanAuthResult.cancelled) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result == FidanAuthResult.ok ? l10n.fidanDeleted : l10n.fidanSignInFailed)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = _store.progress;
    final user = _account.user;
    String? provinceName;
    for (final x in _provinces) {
      if (x.plate == p.plate) provinceName = x.name;
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(contentPadding: EdgeInsets.zero, title: Text(l10n.natureProvince), subtitle: Text(provinceName ?? l10n.naturePickProvince), onTap: _pick),
          SwitchListTile(
            key: const Key('natureReminder'),
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.natureReminder),
            subtitle: Text(l10n.natureReminderDesc),
            value: p.reminder,
            onChanged: (on) async {
              final allowed = !on || await NatureReminder.requestPermission();
              await _store.save(p.copyWith(reminder: on && allowed));
              await NatureReminder.sync(_store.progress, l10n);
              if (mounted) setState(() {});
            },
          ),
          ListTile(
            key: const Key('natureReminderTime'),
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.natureReminderTime),
            trailing: Text('${p.reminderHour.toString().padLeft(2, '0')}:${p.reminderMinute.toString().padLeft(2, '0')}'),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(hour: p.reminderHour, minute: p.reminderMinute),
              );
              if (picked == null) return;
              await _store.save(_store.progress.copyWith(reminderHour: picked.hour, reminderMinute: picked.minute));
              await NatureReminder.sync(_store.progress, l10n);
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
          const Divider(),
          Text(l10n.fidanAccount, style: GoogleFonts.ibmPlexSans(fontSize: 15, fontWeight: FontWeight.w800)),
          if (user == null)
            ListTile(
              key: const Key('fidanSignIn'),
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.account_circle_outlined),
              title: Text(l10n.fidanContinueGoogle),
              subtitle: Text(l10n.fidanAccountNone),
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const FidanSignInScreen())),
            )
          else ...[
            ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.account_circle_rounded), title: Text(l10n.fidanSignedIn), subtitle: Text(user.email ?? '')),
            TextButton(onPressed: _account.signOut, child: Text(l10n.fidanSignOut)),
            TextButton(key: const Key('fidanDeleteAccount'), onPressed: () => _deleteAccount(l10n), child: Text(l10n.fidanDeleteAccount)),
          ],
          const Divider(),
          TextButton(key: const Key('natureDelete'), onPressed: () => _deleteLocal(l10n), child: Text(l10n.natureDeleteTitle)),
        ],
      ),
    );
  }
}

/// Optional, in the app's usual colours.
class FidanSignInScreen extends StatefulWidget {
  const FidanSignInScreen({super.key});

  @override
  State<FidanSignInScreen> createState() => _FidanSignInScreenState();
}

class _FidanSignInScreenState extends State<FidanSignInScreen> {
  bool _busy = false;

  Future<void> _signIn(AppLocalizations l10n) async {
    setState(() => _busy = true);
    final result = await FidanAccount.instance.signIn();
    if (!mounted) return;
    setState(() => _busy = false);
    if (result == FidanAuthResult.ok) {
      Navigator.of(context).pop();
    } else if (result == FidanAuthResult.unavailable) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.fidanSignInFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final muted = Theme.of(context).textTheme.bodySmall?.color;
    Widget line(String e, String t) => Padding(
      padding: const EdgeInsets.only(top: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(e, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 9),
          Expanded(
            child: Text(t, style: GoogleFonts.ibmPlexSans(fontSize: 15, height: 1.3, color: muted)),
          ),
        ],
      ),
    );
    final p = NatureStore.instance.progress;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.fidanContinueGoogle, style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: TreeView(stage: treeStage(p), season: seasonOf(DateTime.now()), mood: Mood.happy, size: 140),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.fidanSignInTitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.ibmPlexSans(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.fidanSignInBody,
            textAlign: TextAlign.center,
            style: GoogleFonts.ibmPlexSans(fontSize: 16, height: 1.3, color: muted),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            key: const Key('fidanGoogleButton'),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
            onPressed: _busy ? null : () => _signIn(l10n),
            icon: const Icon(Icons.account_circle_rounded),
            label: Text(l10n.fidanContinueGoogle),
          ),
          const SizedBox(height: 10),
          line('🌳', l10n.fidanSavedList),
          line('📍', l10n.fidanNeverSaved),
          line('🗑️', l10n.fidanCanDelete),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
            child: Text(
              l10n.fidanUnder13,
              key: const Key('fidanUnder13'),
              textAlign: TextAlign.center,
              style: GoogleFonts.ibmPlexSans(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.fidanSkip)),
          ),
        ],
      ),
    );
  }
}
