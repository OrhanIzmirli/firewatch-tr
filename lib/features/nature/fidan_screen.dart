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
import 'fidan_account.dart';
import 'nature_content.dart';
import 'nature_facts.dart';
import 'nature_progress.dart';
import 'tree.dart';

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
                  child: TreeView(stage: treeStage(p), season: seasonOf(_today), mood: thirsty ? Mood.thirsty : Mood.calm, apples: applesOf(p).length, size: 78),
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
                      _SourceText(fact.sourceName, fact.sourceUrl),
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
                  TreeView(stage: treeStage(p), season: seasonOf(widget.today), mood: Mood.happy, apples: applesOf(p).length, size: 200),
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

class FidanRewardScreen extends StatefulWidget {
  final int xp;
  final bool newApple;
  final int? grewTo;
  final String message;
  final DateTime today;
  const FidanRewardScreen({super.key, required this.xp, required this.newApple, required this.grewTo, required this.message, required this.today});

  @override
  State<FidanRewardScreen> createState() => _FidanRewardScreenState();
}

class _FidanRewardScreenState extends State<FidanRewardScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200));

  @override
  void initState() {
    super.initState();
    HapticFeedback.lightImpact();
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = NatureStore.instance.progress;
    return FidanTheme(
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _c,
                builder: (_, _) => CustomPaint(painter: ConfettiPainter(_c.value)),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 24),
                            TreeView(
                              stage: treeStage(p),
                              mood: Mood.happy,
                              season: seasonOf(widget.today),
                              apples: applesOf(p).length,
                              size: 280,
                            ).animate().scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 600.ms, curve: Curves.elasticOut),
                            const SizedBox(height: 8),
                            Text(
                              l10n.fidanXpGain(widget.xp),
                              key: const Key('fidanXpGain'),
                              textAlign: TextAlign.center,
                              style: _t(52, weight: FontWeight.w900, color: leaf),
                            ),
                            if (widget.newApple)
                              Text(
                                l10n.fidanNewApple,
                                key: const Key('fidanNewApple'),
                                textAlign: TextAlign.center,
                                style: _t(25, weight: FontWeight.w900),
                              ),
                            if (widget.grewTo != null)
                              Text(
                                l10n.fidanGrew(stageName(l10n, widget.grewTo!)),
                                textAlign: TextAlign.center,
                                style: _t(21, weight: FontWeight.w900, color: leafDark),
                              ),
                            const SizedBox(height: 8),
                            Text(
                              widget.message,
                              textAlign: TextAlign.center,
                              style: _t(18, color: inkSoft),
                            ),
                          ],
                        ),
                      ),
                    ),
                    BigGreenButton(l10n.fidanContinue, key: const Key('fidanRewardContinue'), onTap: () => Navigator.of(context).pop()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LessonPathScreen extends StatefulWidget {
  final DateTime? today;
  const LessonPathScreen({super.key, this.today});

  @override
  State<LessonPathScreen> createState() => _LessonPathScreenState();
}

class _LessonPathScreenState extends State<LessonPathScreen> {
  final _store = NatureStore.instance;

  @override
  void initState() {
    super.initState();
    _store.addListener(_changed);
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
    final today = widget.today ?? DateTime.now();
    final next = natureLessons.indexWhere((l) => !p.lessons.contains(l.id));
    const xs = [0.28, 0.72, 0.30, 0.70, 0.34];
    const top = 72.0;
    const gap = 150.0;
    final count = natureLessons.length + 1;
    return FidanTheme(
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, box) {
              final w = box.maxWidth;
              final pts = [for (var i = 0; i < count; i++) Offset(xs[i % xs.length] * w, top + 60 + i * gap)];
              final doneUntil = next == -1 ? natureLessons.length : next;
              return SingleChildScrollView(
                child: SizedBox(
                  width: w,
                  height: top + 60 + (count - 1) * gap + 100,
                  child: Stack(
                    children: [
                      Positioned.fill(child: CustomPaint(painter: _RoadPainter(pts, doneUntil))),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(6, 6, 14, 0),
                        child: Row(
                          children: [
                            IconButton(
                              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.arrow_back_rounded, color: ink),
                            ),
                            Expanded(
                              child: Text(l10n.fidanPath, style: _t(22, weight: FontWeight.w900)),
                            ),
                            if (!p.hideStreak) _Pill('🔥 ${currentStreak(p.days, today)}'),
                            const SizedBox(width: 6),
                            _Pill('⭐ ${xpOf(p)}'),
                          ],
                        ),
                      ),
                      for (var i = 0; i < count; i++) ...[
                        Positioned(
                          left: pts[i].dx - 42,
                          top: pts[i].dy - 42,
                          child: _Stop(
                            state: i < natureLessons.length && p.lessons.contains(natureLessons[i].id) ? 2 : (i == next ? 1 : 0),
                            lessonKey: i < natureLessons.length ? Key('natureLesson-${natureLessons[i].id}') : null,
                            label: i < natureLessons.length ? natureLessons[i].title.of(lang) : l10n.fidanMoreLessons,
                            onTap: i < natureLessons.length && (i <= next || next == -1)
                                ? () => Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => NatureLessonScreen(lesson: natureLessons[i], today: today),
                                    ),
                                  )
                                : () {
                                    ScaffoldMessenger.of(context)
                                      ..hideCurrentSnackBar()
                                      ..showSnackBar(SnackBar(content: Text(i < natureLessons.length ? l10n.fidanLocked : l10n.fidanMoreLessons)));
                                  },
                          ),
                        ),
                        Positioned(
                          left: xs[i % xs.length] < 0.5 ? pts[i].dx + 50 : 14,
                          right: xs[i % xs.length] < 0.5 ? 10 : w - pts[i].dx + 50,
                          top: pts[i].dy - 30,
                          child: Text(
                            i < natureLessons.length ? natureLessons[i].title.of(lang) : l10n.fidanMoreLessons,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: _t(16.5, weight: FontWeight.w800, color: i == next || (i < natureLessons.length && p.lessons.contains(natureLessons[i].id)) ? ink : const Color(0xFF62785A)),
                          ),
                        ),
                        if (i < natureLessons.length && p.lessons.contains(natureLessons[i].id))
                          Positioned(
                            left: pts[i].dx + 20,
                            top: pts[i].dy - 54,
                            child: const Text('🍎', style: TextStyle(fontSize: 24)),
                          ),
                      ],
                      if (next >= 0)
                        Positioned(
                          left: (pts[next].dx - 130).clamp(0.0, w - 84),
                          top: pts[next].dy + 44,
                          child: TreeView(stage: treeStage(p), season: seasonOf(today), mood: Mood.happy, size: 84),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RoadPainter extends CustomPainter {
  final List<Offset> pts;
  final int doneUntil;
  _RoadPainter(this.pts, this.doneUntil);

  Path _through(List<Offset> p) {
    final path = Path()..moveTo(p.first.dx, p.first.dy);
    for (var i = 1; i < p.length; i++) {
      final a = p[i - 1], b = p[i];
      final mid = (a.dy + b.dy) / 2;
      path.cubicTo(a.dx, mid, b.dx, mid, b.dx, b.dy);
    }
    return path;
  }

  @override
  void paint(Canvas c, Size s) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;
    c.drawPath(_through(pts), p..color = const Color(0xFFDCEBCB));
    if (doneUntil > 0) c.drawPath(_through(pts.sublist(0, doneUntil + 1)), p..color = const Color(0xFF8FD35F));
  }

  @override
  bool shouldRepaint(_RoadPainter o) => o.doneUntil != doneUntil || o.pts != pts;
}

class _Stop extends StatelessWidget {
  /// 2 done, 1 next, 0 locked.
  final int state;
  final Key? lessonKey;
  final String label;
  final VoidCallback onTap;
  const _Stop({required this.state, this.lessonKey, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      2 => leaf,
      1 => const Color(0xFFFFB627),
      _ => const Color(0xFFD3DEC8),
    };
    final stop = Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        key: lessonKey,
        onTap: onTap,
        child: Container(
          width: 84,
          height: 84,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 5),
            boxShadow: state == 1 ? const [BoxShadow(color: Color(0xCCFFC94D), blurRadius: 30, spreadRadius: 10)] : null,
          ),
          child: Icon(
            switch (state) {
              2 => Icons.check_rounded,
              1 => Icons.play_arrow_rounded,
              _ => Icons.lock_rounded,
            },
            color: Colors.white,
            size: 42,
          ),
        ),
      ),
    );
    return state == 1 ? stop.animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(begin: 1, end: 1.05, duration: 900.ms, curve: Curves.easeInOut) : stop;
  }
}

class NatureLessonScreen extends StatefulWidget {
  final NatureLesson lesson;
  final DateTime? today;
  const NatureLessonScreen({super.key, required this.lesson, this.today});

  @override
  State<NatureLessonScreen> createState() => _NatureLessonScreenState();
}

class _NatureLessonScreenState extends State<NatureLessonScreen> {
  final _pages = PageController();
  int _step = 0;
  int? _chosen;

  int get _cards => widget.lesson.cards.length;
  int get _total => _cards + widget.lesson.quiz.length;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_step + 1 >= _total) {
      final store = NatureStore.instance;
      final l10n = AppLocalizations.of(context)!;
      final navigator = Navigator.of(context);
      final before = store.progress;
      await store.finishLesson(widget.lesson.id);
      final after = store.progress;
      if (identical(before.lessons, after.lessons) || before.lessons.length == after.lessons.length) {
        navigator.pop();
        return;
      }
      navigator.pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => FidanRewardScreen(
            xp: xpOf(after) - xpOf(before),
            newApple: applesOf(after).length > applesOf(before).length,
            grewTo: treeStage(after) > treeStage(before) ? treeStage(after) : null,
            message: l10n.fidanRewardLesson,
            today: widget.today ?? DateTime.now(),
          ),
        ),
      );
      return;
    }
    setState(() => _chosen = null);
    await _pages.nextPage(duration: const Duration(milliseconds: 260), curve: Curves.easeOut);
  }

  Widget _card(LessonCard c, String lang) => SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: Column(
      children: [
        const SizedBox(height: 28),
        Container(
          width: 190,
          height: 190,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: Color(0xFFD8F1FF), shape: BoxShape.circle),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: FittedBox(child: Text(c.emoji, style: const TextStyle(fontSize: 70))),
          ),
        ),
        const SizedBox(height: 22),
        Text(
          c.title.of(lang),
          textAlign: TextAlign.center,
          style: _t(27, weight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        Text(
          c.body.of(lang),
          textAlign: TextAlign.center,
          style: _t(19, color: inkSoft, height: 1.3),
        ),
        const SizedBox(height: 6),
        for (final s in c.sources) _SourceText(s.name, s.url),
      ],
    ),
  );

  Widget _quiz(QuizQuestion q, String lang, AppLocalizations l10n) => SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Text(q.question.of(lang), style: _t(23, weight: FontWeight.w900)),
        const SizedBox(height: 14),
        for (final (i, o) in q.options.indexed) _option(q, i, o.of(lang)),
        if (_chosen != null) ...[
          const SizedBox(height: 12),
          Text(
            '${_chosen == q.correct ? l10n.fidanCorrect : l10n.fidanWrong} ${q.feedback.of(lang)}',
            key: const Key('natureFeedback'),
            textAlign: TextAlign.center,
            style: _t(16.5, weight: FontWeight.w800, color: leafDark),
          ),
          Center(child: _SourceText(q.source.name, q.source.url)),
        ],
      ],
    ),
  );

  Widget _option(QuizQuestion q, int i, String text) {
    final answered = _chosen != null;
    final right = answered && i == q.correct;
    final wrong = answered && i == _chosen && i != q.correct;
    final color = right ? const Color(0xFFDDF4C6) : (wrong ? const Color(0xFFFFE0DB) : Colors.white);
    final border = right ? leaf : (wrong ? const Color(0xFFE5392F) : const Color(0xFFDDE8D2));
    Widget box = Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: Key('natureOption-$i'),
          borderRadius: BorderRadius.circular(18),
          onTap: answered
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  setState(() => _chosen = i);
                },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: border, width: 2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: _t(17, weight: FontWeight.w700, color: right ? leafDark : inkSoft),
                  ),
                ),
                if (right) const Icon(Icons.check_circle_rounded, color: leaf, size: 26),
                if (wrong) const Icon(Icons.cancel_rounded, color: Color(0xFFE5392F), size: 26),
              ],
            ),
          ),
        ),
      ),
    );
    if (wrong) box = box.animate().shake(duration: 400.ms, hz: 6);
    if (right) box = box.animate().scaleXY(begin: 0.96, end: 1, duration: 260.ms, curve: Curves.easeOutBack);
    return box;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final inQuiz = _step >= _cards;
    return FidanTheme(
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded, color: inkSoft, size: 28),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(value: (_step + 1) / _total, minHeight: 12, color: leaf, backgroundColor: const Color(0xFFD5EBBD)),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pages,
                    physics: inQuiz ? const NeverScrollableScrollPhysics() : const PageScrollPhysics(),
                    itemCount: _cards + (inQuiz ? widget.lesson.quiz.length : 1),
                    onPageChanged: (i) => setState(() => _step = i),
                    itemBuilder: (_, i) => i < _cards ? _card(widget.lesson.cards[i], lang) : _quiz(widget.lesson.quiz[i - _cards], lang, l10n),
                  ),
                ),
                const SizedBox(height: 10),
                BigGreenButton(_step + 1 >= _total ? l10n.natureFinish : l10n.fidanContinue, key: const Key('natureNext'), onTap: !inQuiz || _chosen != null ? _next : null),
              ],
            ),
          ),
        ),
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
