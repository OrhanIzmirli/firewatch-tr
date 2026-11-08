import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/utils/auto_refresh.dart';
import '../../core/utils/news_content_analysis.dart';
import '../../core/utils/risk_display.dart';
import '../../l10n/app_localizations.dart';
import '../../models/detection_status.dart';
import '../../models/fire_incident.dart';
import '../../models/news_item.dart';
import '../../models/tracked_place.dart';
import '../../services/device_position.dart';
import '../../services/location_disclosure.dart';
import '../../services/news_service.dart';
import '../../services/news_translation_service.dart';
import '../../services/point_risk_service.dart';
import '../../services/render_api_service.dart';
import '../../shared/coach_mark_keys.dart';
import '../../shared/widgets/detection_status_card.dart';
import '../../shared/widgets/glass_panel.dart';
import '../../shared/widgets/report_fire_panel.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/skeleton_loader.dart';
import '../../shared/widgets/status_chip.dart';
import '../risk/widgets/tracked_places_section.dart';

enum _Location { pending, unavailable, outsideTurkey, unknownRisk, ready }

/// One screen, four answers, in this order: what about where I am, my
/// places, the country in one line, the news.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const nearbyRadiusMeters = 25000.0;
  static const newsFreshFor = Duration(hours: 72);

  final NewsService _newsService = NewsService();
  final RenderApiService _api = RenderApiService();

  _Location _location = _Location.pending;
  Position? _position;
  Map<String, dynamic>? _point;
  List<FireIncident> _incidents = const [];
  DetectionStatus? _status;
  List<NewsItem> _news = const [];

  late final AutoRefresher _autoRefresher = AutoRefresher(onRefresh: _loadData);

  @override
  void initState() {
    super.initState();
    _loadData();
    _autoRefresher.start();
  }

  @override
  void dispose() {
    _autoRefresher.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadLocation(), _loadIncidents(), _loadStatus(), _loadNews()]);
    _autoRefresher.markRefreshed();
  }

  Future<void> _loadIncidents() async {
    final incidents = await _api.fetchIncidents(days: 2, limit: 300);
    if (mounted) setState(() => _incidents = incidents);
  }

  Future<void> _loadStatus() async {
    final status = await _api.fetchDetectionStatus();
    if (mounted) setState(() => _status = status);
  }

  Future<void> _loadNews() async {
    try {
      final news = await _newsService.fetchNewsFromRender(limit: 5);
      if (mounted) setState(() => _news = news.where((n) => n.publishedWithin(newsFreshFor)).take(3).toList());
    } catch (_) {
      // No news section is the right answer when the feed cannot be read.
    }
  }

  Future<void> _loadLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        if (mounted) setState(() => _location = _Location.unavailable);
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied && mounted) {
        permission = await LocationDisclosure.requestPermission(context);
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        if (mounted) setState(() => _location = _Location.unavailable);
        return;
      }
      final position = await DevicePosition.current(accuracy: LocationAccuracy.low, timeLimit: const Duration(seconds: 10));
      if (!mounted) return;
      setState(() => _position = position);
      final point = await PointRiskService.instance.fetch(lat: position.latitude, lng: position.longitude);
      if (mounted) {
        setState(() {
          _point = point;
          _location = _Location.ready;
        });
      }
    } on PointRiskException catch (e) {
      if (mounted) setState(() => _location = e.error == PointRiskError.outsideTurkey ? _Location.outsideTurkey : _Location.unknownRisk);
    } catch (_) {
      if (mounted) setState(() => _location = _Location.unavailable);
    }
  }

  bool _isRecentStrong(FireIncident i) =>
      !i.isKeptOffEvents && i.hoursSinceLastDetection <= 24 && (i.belongsOnEventsLayer || i.isStrongUnverified);

  int get _nearbyCount {
    final position = _position;
    if (position == null) return 0;
    return _incidents
        .where((i) =>
            _isRecentStrong(i) &&
            Geolocator.distanceBetween(position.latitude, position.longitude, i.latitude, i.longitude) <= nearbyRadiusMeters)
        .length;
  }

  /// Fires-side detections in the last 24 hours inside a place's radius.
  int _detectionsNear(TrackedPlace place) => _incidents
      .where((i) => !i.isKeptOffEvents && i.hoursSinceLastDetection <= 24 && place.isWithinRadius(i.latitude, i.longitude))
      .length;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final status = _status;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName, style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(tooltip: l10n.navSettings, icon: const Icon(Icons.settings_outlined), onPressed: () => context.push('/settings')),
          IconButton(tooltip: l10n.commonRefresh, icon: const Icon(Icons.refresh_rounded), onPressed: _loadData),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TodayCard(
                key: CoachMarkKeys.riskButton,
                location: _location,
                point: _point,
                nearbyCount: _nearbyCount,
                onEnableLocation: _loadLocation,
                onOpenRisk: () => context.go('/app?tab=risk'),
              ),
              const SizedBox(height: AppSpacing.xl),
              TrackedPlacesSection(detectionCount: _detectionsNear),
              const SizedBox(height: AppSpacing.xl),
              if (status != null) ...[
                if (status.kind == DetectionStatusKind.strong)
                  _TurkeyLine(status: status, onOpenMap: () => context.go('/map'))
                else
                  DetectionStatusCard(
                    status: status,
                    onRetry: _loadStatus,
                    onReport: () => showReportFirePanel(context, initialType: ReportType.missingFire),
                    onShowLast7Days: status.kind == DetectionStatusKind.unavailable
                        ? null
                        : () => context.go('/map', extra: const {'incidentFilter': 'all'}),
                  ),
                const SizedBox(height: AppSpacing.xl),
              ],
              if (_news.isNotEmpty) ...[
                SectionHeader(
                  title: l10n.homeNewsTitle,
                  icon: const Icon(Icons.newspaper_outlined),
                  trailing: StatusChip(label: l10n.newsNewBadge),
                ),
                const SizedBox(height: AppSpacing.md),
                for (final item in _news)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _HomeNewsPreviewCard(item: item, onTap: () => context.push('/news-detail', extra: item)),
                  ),
              ],
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  TextButton.icon(
                    onPressed: () => context.push('/safety-guide'),
                    icon: const Icon(Icons.health_and_safety_outlined, size: 18),
                    label: Text(l10n.homeSafety),
                  ),
                  TextButton.icon(
                    key: CoachMarkKeys.savedButton,
                    onPressed: () => context.push('/watchlist'),
                    icon: const Icon(Icons.bookmark_outline_rounded, size: 18),
                    label: Text(l10n.watchlistTitle),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  final _Location location;
  final Map<String, dynamic>? point;
  final int nearbyCount;
  final VoidCallback onEnableLocation;
  final VoidCallback onOpenRisk;

  const _TodayCard({
    super.key,
    required this.location,
    required this.point,
    required this.nearbyCount,
    required this.onEnableLocation,
    required this.onOpenRisk,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.color;
    final point = this.point;
    final body = GoogleFonts.ibmPlexSans(fontSize: 14, height: 1.45, color: muted);

    final Widget content;
    if (location == _Location.ready && point != null) {
      final score = (point['general_risk_score'] as num).toInt();
      final level = riskLevelForScore(score);
      final color = colorForApiRiskLevel(level);
      final city = point['city'] as String?;
      final wind = num.tryParse('${point['wind_speed']}')?.round();
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(city ?? l10n.homeTodayTitle,
                    style: GoogleFonts.ibmPlexSans(fontSize: 22, fontWeight: FontWeight.w800)),
              ),
              StatusChip(label: riskLevelLabel(l10n, level), color: color, showDot: true),
            ],
          ),
          const SizedBox(height: 4),
          Text(l10n.riskScoreOutOf100(score), style: GoogleFonts.ibmPlexSans(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: AppSpacing.sm),
          Text(nearbyCount > 0 ? l10n.homeNearbySome(nearbyCount) : l10n.homeNearbyNone, key: const Key('homeNearby'), style: body),
          if (wind != null) Text(l10n.homeWind('$wind'), style: body),
        ],
      );
    } else if (location == _Location.pending) {
      content = const Center(child: Padding(padding: EdgeInsets.all(AppSpacing.md), child: CircularProgressIndicator()));
    } else {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            switch (location) {
              _Location.outsideTurkey => l10n.homeLocationOutside,
              _Location.unknownRisk => l10n.homeRiskUnavailable,
              _ => l10n.homeLocationNeeded,
            },
            style: body,
          ),
          if (location == _Location.unavailable)
            TextButton.icon(
              onPressed: onEnableLocation,
              icon: const Icon(Icons.my_location_rounded, size: 18),
              label: Text(l10n.homeLocationEnable),
            ),
        ],
      );
    }

    return InkWell(
      key: const Key('homeTodayCard'),
      borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius),
      onTap: location == _Location.ready ? onOpenRisk : null,
      child: GlassPanel(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.homeTodayTitle, style: GoogleFonts.ibmPlexSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
              const SizedBox(height: AppSpacing.sm),
              content,
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 260.ms);
  }
}

class _TurkeyLine extends StatelessWidget {
  final DetectionStatus status;
  final VoidCallback onOpenMap;

  const _TurkeyLine({required this.status, required this.onOpenMap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      key: const Key('homeTurkeyLine'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.homeTurkeyLine(status.strongCount, status.otherCount), style: GoogleFonts.ibmPlexSans(fontSize: 14, height: 1.45, fontWeight: FontWeight.w600)),
        Row(
          children: [
            Expanded(child: DetectionFreshnessLine(status: status)),
            TextButton(onPressed: onOpenMap, child: Text(l10n.homeSeeOnMap)),
          ],
        ),
      ],
    );
  }
}

class _HomeNewsPreviewCard extends StatefulWidget {
  final NewsItem item;
  final VoidCallback onTap;

  const _HomeNewsPreviewCard({required this.item, required this.onTap});

  @override
  State<_HomeNewsPreviewCard> createState() => _HomeNewsPreviewCardState();
}

class _HomeNewsPreviewCardState extends State<_HomeNewsPreviewCard> {
  bool _translating = false;
  String? _translatedTitle;
  String? _translatedSummary;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maybeAutoTranslate();
  }

  @override
  void didUpdateWidget(covariant _HomeNewsPreviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _translatedTitle = null;
      _translatedSummary = null;
      _maybeAutoTranslate();
    }
  }

  // Mirrors NewsCard's auto-translate logic (features/news/widgets/news_card.dart)
  // so home screen previews get the same English-mode translation instead of
  // showing raw Turkish text.
  Future<void> _maybeAutoTranslate() async {
    if (Localizations.localeOf(context).languageCode != 'en') return;
    if (_translatedTitle != null || _translating) return;

    final service = NewsTranslationService.instance;
    final cachedTitle = await service.getCached(widget.item.id, 'title');
    final cachedSummary = await service.getCached(widget.item.id, 'summary');
    if (cachedTitle != null) {
      if (!mounted) return;
      setState(() {
        _translatedTitle = cachedTitle;
        _translatedSummary = cachedSummary;
      });
      return;
    }

    if (!mounted) return;
    setState(() => _translating = true);
    try {
      final title = await service.translate(
        articleId: widget.item.id,
        field: 'title',
        text: widget.item.title,
      );
      final summary = await service.translate(
        articleId: widget.item.id,
        field: 'summary',
        text: widget.item.summary,
      );
      if (!mounted) return;
      setState(() {
        _translatedTitle = title;
        _translatedSummary = summary;
      });
    } catch (_) {
      // Falls back to showing the original Turkish text below.
    } finally {
      if (mounted) setState(() => _translating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final onTap = widget.onTap;
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = Theme.of(context).textTheme.titleMedium?.color ??
        (isDark ? AppColors.white : AppColors.lightText);
    final summaryColor = isDark
        ? AppColors.white.withValues(alpha: 0.7)
        : Colors.black.withValues(alpha: 0.64);
    final metaColor = isDark
        ? AppColors.white.withValues(alpha: 0.52)
        : Colors.black.withValues(alpha: 0.46);
    final arrowColor = isDark
        ? AppColors.white.withValues(alpha: 0.42)
        : Colors.black.withValues(alpha: 0.3);

    final fullText = '${item.title} ${item.summary}';
    final category = classifyNewsCategory(fullText);
    final riskLevel = classifyNewsRiskLevel(fullText);
    final timeAgo = formatNewsTimeAgo(l10n, item.publishedAt);
    final wordCount = newsWordCount(item);
    final displayTitle = _translatedTitle ?? item.title;
    final displaySummary = _translatedSummary ?? item.summary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius),
        child: Ink(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius)),
          child: GlassPanel(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius),
                  ),
                  child: Icon(newsCategoryIcon(category), color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8, runSpacing: 8,
                        children: [
                          StatusChip(label: newsCategoryLabel(l10n, category), icon: newsCategoryIcon(category)),
                          StatusChip(
                            label: newsRiskLevelLabel(l10n, riskLevel),
                            showDot: true,
                            color: newsRiskLevelColor(riskLevel),
                          ),
                          if (item.isBreakingNow()) StatusChip(label: l10n.newsBreakingBadge, icon: Icons.bolt_rounded),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (_translating)
                        const ShimmerWrap(
                          child: SkeletonBox(width: double.infinity, height: 15),
                        )
                      else
                        Text(displayTitle,
                            style: GoogleFonts.ibmPlexSans(fontSize: 15, fontWeight: FontWeight.w800, height: 1.2, color: titleColor)),
                      const SizedBox(height: AppSpacing.sm),
                      if (_translating)
                        const ShimmerWrap(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SkeletonBox(width: double.infinity, height: 12),
                              SizedBox(height: 6),
                              SkeletonBox(width: double.infinity, height: 12),
                            ],
                          ),
                        )
                      else
                        Text(displaySummary, maxLines: 2, overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.ibmPlexSans(fontSize: 13, height: 1.45, color: summaryColor)),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(child: Text('${item.source} • $timeAgo',
                              style: GoogleFonts.ibmPlexSans(fontSize: 12, color: metaColor))),
                          if (wordCount != null) ...[
                            const SizedBox(width: AppSpacing.sm),
                            Text(l10n.newsWordCount(wordCount),
                                style: GoogleFonts.ibmPlexSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(Icons.arrow_forward_ios_rounded, size: 15, color: arrowColor)
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .moveX(begin: 0, end: 3, duration: 900.ms, curve: Curves.easeInOut),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
