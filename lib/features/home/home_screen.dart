import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/config/api_config.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/utils/auto_refresh.dart';
import '../../core/utils/loading_race.dart';
import '../../core/utils/risk_display.dart';
import '../../l10n/app_localizations.dart';
import '../../models/fire_incident.dart';
import '../../models/fire_point.dart';
import '../../models/incident_summary.dart';
import '../../models/persistent_heat_source.dart';
import '../../models/news_item.dart';
import '../../models/tracked_place.dart';
import '../../services/fire_api_service.dart';
import '../risk/widgets/tracked_places_section.dart';
import '../../services/fire_mapper.dart';
import '../../services/news_service.dart';
import '../../services/render_api_service.dart';
import '../../services/offline_cache_service.dart';
import '../../services/watchlist_provider.dart';
import '../../shared/coach_mark_keys.dart';
import '../../shared/widgets/glass_panel.dart';
import '../../shared/widgets/detection_status_card.dart';
import '../../models/detection_status.dart';
import '../../shared/widgets/report_fire_panel.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/skeleton_loader.dart';
import '../../shared/widgets/slow_loading_banner.dart';
import '../../shared/widgets/smart_overview_card.dart';
import '../../shared/widgets/status_chip.dart';
import '../../shared/widgets/trust_info_card.dart';
import '../../services/location_disclosure.dart';
import '../../services/device_position.dart';
import '../../core/utils/detection_summary.dart';
import '../../services/point_risk_service.dart';
import '../../shared/widgets/detection_safety_notice.dart';
import '../../shared/widgets/app_sheet.dart';
import '../../shared/widgets/alerts_bell.dart';
import '../nature/fidan_screen.dart';
import '../news/widgets/news_visual.dart';

/// Short cards stay readable under large text.
double _cardRatio(BuildContext context) => MediaQuery.textScalerOf(context).scale(10) > 11.5 ? 0.86 : 1.05;

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

enum _Location { pending, unavailable, outsideTurkey, unknownRisk, ready }

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const _newsCacheKey = 'home_news';
  static const _firesCacheKey = 'home_fires';
  static const _riskCacheKey = 'home_risk';

  final NewsService _newsService = NewsService();
  final FireApiService _fireApiService = FireApiService();
  final Dio _dio = Dio(
    BaseOptions(
      // Generous enough to survive a Render free-tier cold start (can take
      // 10-30s to wake) without throwing a false "offline" failure.
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  List<NewsItem> _topNews = [];
  List<FirePoint> _firePoints = [];
  DetectionStatus? _detectionStatus;
  final RenderApiService _statusApi = RenderApiService();

  _Location _todayLocation = _Location.pending;
  Map<String, dynamic>? _point;
  List<FireIncident> _incidents = const [];

  static const _nearbyStrongRadiusMeters = 25000.0;

  /// Fire-side detections in the last 24 hours inside a place's radius.
  int _detectionsNear(TrackedPlace place) => _incidents
      .where((i) => !i.isKeptOffEvents && i.hoursSinceLastDetection <= 24 && place.isWithinRadius(i.latitude, i.longitude))
      .length;

  int get _nearbyStrongCount {
    final position = _userPosition;
    if (position == null) return 0;
    return _incidents
        .where((i) =>
            !i.isKeptOffEvents &&
            i.hoursSinceLastDetection <= 24 &&
            (i.belongsOnEventsLayer || i.isStrongUnverified) &&
            Geolocator.distanceBetween(position.latitude, position.longitude, i.latitude, i.longitude) <= _nearbyStrongRadiusMeters)
        .length;
  }

  /// 'agriculture' or 'built' when a classified incident sits on this point.
  String? _farmOrBuiltNear(FirePoint point) {
    for (final i in _incidents) {
      if (i.landCover != 'agriculture' && i.landCover != 'built') continue;
      if (i.newsVerification != null) continue;
      if (Geolocator.distanceBetween(i.latitude, i.longitude, point.latitude, point.longitude) <= 1500) return i.landCover;
    }
    return null;
  }

  Future<void> _loadIncidents() async {
    final incidents = await _renderApi.fetchIncidents(days: 2, limit: 300);
    if (mounted) setState(() => _incidents = incidents);
  }

  Future<void> _loadToday() async {
    final position = _userPosition;
    if (position == null) {
      if (mounted) setState(() => _todayLocation = _Location.unavailable);
      return;
    }
    try {
      final point = await PointRiskService.instance.fetch(lat: position.latitude, lng: position.longitude);
      if (mounted) {
        setState(() {
          _point = point;
          _todayLocation = _Location.ready;
        });
      }
    } on PointRiskException catch (e) {
      if (mounted) setState(() => _todayLocation = e.error == PointRiskError.outsideTurkey ? _Location.outsideTurkey : _Location.unknownRisk);
    }
  }

  Future<void> _refreshLocation() async {
    await _loadUserPosition();
    await _loadToday();
  }

  List<Map<String, dynamic>> _regions = [];
  Position? _userPosition;
  bool _fireLoading = true;
  bool _riskLoading = true;
  bool _firesSlowLoading = false;

  final RenderApiService _renderApi = RenderApiService();
  IncidentSummary? _incidentSummary;
  bool _incidentSummaryLoading = true;

  /// Settings › data refresh interval: a silent reload of the fire feed
  /// and the 24-hour summary, no spinner.
  late final AutoRefresher _autoRefresher = AutoRefresher(
    onRefresh: () => Future.wait([
      _loadFires(force: true, silent: true),
      _loadIncidentSummary(),
    ]),
  );

  @override
  void initState() {
    super.initState();
    _loadData();
    _refreshLocation();
    _autoRefresher.start();
  }

  /// [force] skips the two-minute feed memo (pull-to-refresh).
  Future<void> _loadData({bool force = false}) async {
    await Future.wait([
      _loadNews(),
      _loadFires(force: force),
      _loadRiskSummary(),
      _loadIncidentSummary(),
      _loadIncidents(),
    ]);
    _autoRefresher.markRefreshed();
  }

  /// Best-effort. A null summary hides the section rather than showing zeros,
  /// because "0 active fires" and "we could not reach the server" are very
  /// different statements to put in front of someone checking for a fire.
  Future<void> _loadIncidentSummary() async {
    final summary = await _renderApi.fetchIncidentSummary();
    if (!mounted) return;
    setState(() {
      _incidentSummary = summary;
      _incidentSummaryLoading = false;
    });
  }

  /// The last 24 hours in three cards.
  ///
  /// The middle card is the delicate one: it counts events the satellite
  /// stopped seeing, and its title and subtitle both have to keep saying that
  /// rather than the shorter, wronger thing. There is no data anywhere in
  /// this app that says a fire was put out.
  Widget _buildLast24hSection(AppLocalizations l10n, IncidentSummary summary) {
    // The client-side fallback has no province to work with. Printing
    // "Province unknown · 50 MW" spends the card's one line on the thing we
    // do not know; the power alone is the part that carries meaning.
    final strongestCity = summary.strongestActiveCityName;

    return Column(
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: _cardRatio(context),
          children: [
            SmartOverviewCard(
              title: l10n.homeLast24hActiveTitle,
              // As in 1.0.6: the headline is the multi-pass count, the
              // number the events layer actually draws. Single fresh pixels
              // are counted in the subtitle and live on the Points layer.
              value: summary.activeSignificantCount.toString(),
              subtitle: l10n.homeGridLast24h,
              icon: Icons.local_fire_department_rounded,
              color: AppColors.danger,
              delay: 0.ms,
              onTap: () => context.go(
                '/map',
                extra: {'incidentFilter': IncidentFilter.active.storageValue},
              ),
            ),
            SmartOverviewCard(
              title: l10n.homeLast24hEndedTitle,
              value: summary.detectionEndedLast24h.toString(),
              subtitle: l10n.homeGridLast24h,
              icon: Icons.satellite_alt_rounded,
              color: AppColors.primary,
              delay: 60.ms,
              onTap: () => context.go(
                '/map',
                extra: {'incidentFilter': IncidentFilter.ended.storageValue},
              ),
            ),
          ],
        ),
        if (summary.hasStrongestActive) ...[
          const SizedBox(height: AppSpacing.md),
          SmartOverviewCard(
            title: l10n.homeLast24hStrongestTitle,
            value: strongestCity != null && strongestCity.isNotEmpty
                ? strongestCity
                : l10n.detectionThermalDetection,
            // Duration goes in the subtitle as a floor, never as a headline.
            subtitle: l10n.homeGridLast24h,
            icon: Icons.whatshot_rounded,
            color: AppColors.danger,
            delay: 120.ms,
            onTap: () => context.go(
              '/map',
              extra: {'incidentFilter': IncidentFilter.active.storageValue},
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _loadUserPosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied && mounted) {
        permission = await LocationDisclosure.requestPermission(context);
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return;
      final position = await DevicePosition.current(accuracy: LocationAccuracy.low, timeLimit: const Duration(seconds: 8));
      if (mounted) setState(() => _userPosition = position);
    } catch (_) {
      // The card then offers to enable location.
    }
  }

  Future<void> _loadRiskSummary() async {
    if (mounted) setState(() => _riskLoading = true);
    try {
      final response = await raceWithCacheFallback(
        fetch: retryOnce(() => _dio.get('${ApiConfig.apiBaseUrl}/risk/summary')),
        timeout: const Duration(seconds: 12),
        cacheKey: _riskCacheKey,
        onSlowFallback: (cached) {
          if (!mounted) return;
          final (data, _) = cached;
          setState(() {
            _regions = (data as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
            _riskLoading = false;
          });
        },
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        final regions = data.map((e) => Map<String, dynamic>.from(e)).toList();
        await OfflineCacheService.instance.save(_riskCacheKey, regions);
        if (mounted) setState(() { _regions = regions; _riskLoading = false; });
      }
    } catch (_) {
      final cached = await OfflineCacheService.instance.load(_riskCacheKey);
      if (mounted) {
        setState(() {
          if (cached != null) {
            final (data, _) = cached;
            _regions = (data as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
          }
          _riskLoading = false;
        });
      }
    }
  }

  Future<void> _loadNews() async {
    try {
      final news = await raceWithCacheFallback(
        fetch: retryOnce(() => _newsService.fetchNewsFromRender(limit: 3)),
        timeout: const Duration(seconds: 12),
        cacheKey: _newsCacheKey,
        onSlowFallback: (cached) {
          if (!mounted) return;
          final (data, _) = cached;
          setState(() => _topNews = (data as List).map((e) => NewsItem.fromJson(e as Map<String, dynamic>)).toList());
        },
      );
      await OfflineCacheService.instance.save(_newsCacheKey, news.map((n) => n.toJson()).toList());
      if (mounted) setState(() => _topNews = news);
    } catch (e, stack) {
      if (kDebugMode) debugPrint('ERROR _loadNews: $e\n$stack');
      final cached = await OfflineCacheService.instance.load(_newsCacheKey);
      if (mounted && cached != null) {
        final (data, _) = cached;
        setState(() => _topNews = (data as List).map((e) => NewsItem.fromJson(e as Map<String, dynamic>)).toList());
      }
    }
  }

  Future<void> _loadDetectionStatus() async {
    final status = await _statusApi.fetchDetectionStatus();
    if (mounted) setState(() => _detectionStatus = status);
  }

  Future<void> _loadFires({bool force = false, bool silent = false}) async {
    if (mounted && !silent) setState(() { _fireLoading = true; _firesSlowLoading = false; });
    _loadDetectionStatus();
    try {
      final allPoints = await raceWithCacheFallback(
        fetch: retryOnce(
          () => _fireApiService.fetchTurkeyFiresWithCities(force: force),
        ),
        timeout: const Duration(seconds: 12),
        cacheKey: _firesCacheKey,
        onSlowFallback: (cached) {
          // A silent refresh never swaps fresh data for the offline copy.
          if (silent || !mounted) return;
          final (data, _) = cached;
          setState(() {
            _firePoints = (data as List).map((e) => FirePoint.fromJson(e as Map<String, dynamic>)).toList();
            _firesSlowLoading = true;
            _fireLoading = false;
          });
        },
      );
      await OfflineCacheService.instance.save(_firesCacheKey, allPoints.map((p) => p.toJson()).toList());
      if (mounted) {
        setState(() {
        _firePoints = allPoints;
        _fireLoading = false;
        _firesSlowLoading = false;
      });
      }
    } catch (e, stack) {
      if (kDebugMode) debugPrint('ERROR _loadFires: $e\n$stack');
      // Silent refresh failed: keep what is on screen.
      if (silent) return;
      final cached = await OfflineCacheService.instance.load(_firesCacheKey);
      if (mounted) {
        setState(() {
          if (cached != null) {
            final (data, _) = cached;
            _firePoints = (data as List).map((e) => FirePoint.fromJson(e as Map<String, dynamic>)).toList();
          }
          _firesSlowLoading = false;
          _fireLoading = false;
        });
      }
    }
  }

  /// A raw detection within 2 km of a fixed heat source the backend has
  /// labelled (steelworks, refinery, flare). Drawn grey and named as such,
  /// never as a fire — and never hidden.
  bool _isFixedSourcePoint(FirePoint p) =>
      p.nearPersistentSource ||
      PersistentHeatSource.coversPoint(
        _incidentSummary?.persistentHeatSources ?? const [],
        p.latitude,
        p.longitude,
      );

  void _showFirePreview(BuildContext context, FirePoint point) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final titleColor = theme.textTheme.titleLarge?.color ??
        (isDark ? AppColors.white : AppColors.lightText);
    final secondaryTextColor = isDark
        ? AppColors.white.withValues(alpha: 0.74)
        : Colors.black.withValues(alpha: 0.66);

    final cover = _farmOrBuiltNear(point);

    showAppSheet(
      context,
      flatGlass: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: GlassPanel(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  StatusChip(label: point.detectionTitle(l10n), icon: Icons.satellite_alt_rounded, color: point.detectionColor),
                  StatusChip(
                    label: fireStatusLabel(l10n, point.smartStatus, seenAt: point.detectionDateTimeUtc),
                    showDot: true,
                    color: fireStatusColor(point.smartStatus),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.homeFireRegionTitle(point.regionDisplayName(l10n)),
                style: GoogleFonts.ibmPlexSans(fontSize: 22, fontWeight: FontWeight.w800, color: titleColor),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                detectionSummaryText(
                  l10n,
                  city: point.cityName,
                  strong: point.riskTier == 'high',
                  newsVerified: false,
                  landCover: null,
                  age: DateTime.now().toUtc().difference(point.detectionDateTimeUtc ?? DateTime.now().toUtc()),
                ),
                style: GoogleFonts.ibmPlexSans(fontSize: 14, height: 1.45, color: secondaryTextColor),
              ),
              if (cover != null) ...[
                const SizedBox(height: 6),
                Text(
                  cover == 'agriculture' ? l10n.mapPointFarmland : l10n.mapPointBuilt,
                  style: GoogleFonts.ibmPlexSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.warning),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              DetectionSafetyNotice(
                prominent: point.riskTier == 'high' &&
                    cover == null &&
                    (point.smartStatus == FireStatus.active || point.smartStatus == FireStatus.likelyActive),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        context.go('/map', extra: {'lat': point.latitude, 'lng': point.longitude});
                      },
                      icon: const Icon(Icons.map_rounded),
                      label: Text(l10n.commonViewOnMap),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        context.push('/fire-detail', extra: convertPointToFireEvent(point, l10n));
                      },
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: Text(l10n.commonAllTechnical),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _autoRefresher.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryTextColor = theme.textTheme.titleLarge?.color ??
        (isDark ? AppColors.white : AppColors.lightText);

    final savedIds = ref.watch(watchlistProvider);

    // ── Overview card 1: active (non-low-confidence) fire points ──
    // Uses FirePoint.riskTier (not a local confidence parse) so it handles
    // both VIIRS text confidence ("high"/"nominal") and MODIS numeric
    // confidence (e.g. "79") the same way markers/badges do elsewhere.
    // NASA's feed reaches back about two days; the cards say "last 24 hours".
    final now = DateTime.now().toUtc();
    final recentPoints = _firePoints.where((p) {
      final seen = p.detectionDateTimeUtc;
      return seen != null && now.difference(seen) <= const Duration(hours: 24);
    }).toList()
      ..sort((a, b) => b.detectionDateTimeUtc!.compareTo(a.detectionDateTimeUtc!));
    final activeFireCount = recentPoints.where((p) => p.riskTier != 'low').length;
    final activeFireColor = activeFireCount > 10
        ? AppColors.danger
        : activeFireCount > 5
            ? AppColors.warning
            : AppColors.success;

    // ── Overview card 2: highest-risk region from /api/risk/summary ──
    Map<String, dynamic>? highestRiskRegion;
    for (final r in _regions) {
      final score = r['general_risk_score'] as int? ?? 0;
      final bestSoFar = highestRiskRegion?['general_risk_score'] as int? ?? -1;
      if (score > bestSoFar) highestRiskRegion = r;
    }
    final highestRiskColor = highestRiskRegion == null
        ? AppColors.success
        : riskScoreColor(highestRiskRegion['general_risk_score'] as num);

    // ── Overview card 3: fires within 100km, falling back to the
    // nationwide count when location isn't available ──
    final position = _userPosition;
    final nearbyCount = position == null
        ? null
        : recentPoints.where((p) {
            final distanceMeters = Geolocator.distanceBetween(
              position.latitude, position.longitude, p.latitude, p.longitude);
            return distanceMeters <= 100000;
          }).length;
    final nearbyColor = (nearbyCount ?? 0) > 0 ? AppColors.danger : AppColors.success;

    // ── Overview card 4: news freshness ──
    // "New" is the last 72 hours; an old item is never counted as new.
    final freshNews = _topNews.where((n) => n.publishedWithin(const Duration(hours: 72))).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName, style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700)),
        actions: [
          const AlertsBell(),
          IconButton(tooltip: l10n.navSettings, icon: const Icon(Icons.settings_outlined), onPressed: () => context.push('/settings')),
          IconButton(tooltip: l10n.commonRefresh, icon: const Icon(Icons.refresh_rounded), onPressed: _loadData),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadData(force: true),
        color: AppColors.primary,
        child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TodayCard(
              location: _todayLocation,
              point: _point,
              nearbyCount: _nearbyStrongCount,
              onEnableLocation: _refreshLocation,
              onOpenRisk: () => context.go('/app?tab=risk'),
              onOpenMap: () => context.go('/map'),
              onReport: () => showReportFirePanel(context, initialType: ReportType.missingFire),
            ),
            const SizedBox(height: AppSpacing.md),
            const FidanHomeCard(),
            const SizedBox(height: AppSpacing.md),
            TrackedPlacesSection(detectionCount: _detectionsNear),
            const SizedBox(height: AppSpacing.lg),
            if (_firesSlowLoading) const SlowLoadingBanner(),

            // Shortcuts
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    key: CoachMarkKeys.riskButton,
                    onPressed: () => context.push('/risk'),
                    icon: const Icon(Icons.auto_graph_rounded),
                    label: Text(l10n.homeRiskAnalysis),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    key: CoachMarkKeys.savedButton,
                    onPressed: () => context.push('/watchlist'),
                    icon: const Icon(Icons.bookmark_rounded),
                    label: Text(l10n.homeSaved(savedIds.length), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/safety-guide'),
                    icon: const Icon(Icons.shield_outlined),
                    label: Text(l10n.homeSafety),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/emergency'),
                    icon: const Icon(Icons.emergency_rounded),
                    label: Text(l10n.commonEmergency),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Overview: one number, one short line.
            SectionHeader(title: l10n.homeOverview, icon: const Icon(Icons.dashboard_customize_rounded)),
            const SizedBox(height: AppSpacing.md),
            if (_fireLoading || _riskLoading)
              const SkeletonMetricGrid(count: 4)
            else
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: _cardRatio(context),
                children: [
                  SmartOverviewCard(
                    title: l10n.homeOverviewActiveFiresTitle,
                    value: activeFireCount.toString(),
                    subtitle: l10n.homeGridLast24h,
                    icon: Icons.local_fire_department_rounded,
                    color: activeFireColor,
                    delay: 0.ms,
                    onTap: () => context.go('/map', extra: {'confidenceFilter': true}),
                  ),
                  SmartOverviewCard(
                    title: l10n.homeOverviewHighestRiskTitle,
                    value: highestRiskRegion == null
                        ? l10n.riskDataLoading
                        : riskLevelLabel(l10n, riskLevelForScore(highestRiskRegion['general_risk_score'] as num)),
                    subtitle: highestRiskRegion == null
                        ? l10n.homeOverviewHighestRiskSubtitle
                        : '${displayRegionName(l10n, highestRiskRegion['region'] as String)} · ${highestRiskRegion['general_risk_score']}/100',
                    icon: Icons.warning_amber_rounded,
                    color: highestRiskColor,
                    delay: 60.ms,
                    onTap: highestRiskRegion == null
                        ? null
                        : () => context.push('/risk', extra: highestRiskRegion!['region'] as String),
                  ),
                  SmartOverviewCard(
                    title: l10n.homeOverviewNearbyTitle,
                    value: nearbyCount?.toString() ?? '—',
                    subtitle: nearbyCount != null ? l10n.homeGridNear : l10n.homeGridLocationOff,
                    icon: Icons.location_on_rounded,
                    color: nearbyColor,
                    delay: 120.ms,
                    onTap: position == null
                        ? () => context.go('/map')
                        : () => context.go('/map', extra: {'lat': position.latitude, 'lng': position.longitude}),
                  ),
                  SmartOverviewCard(
                    title: l10n.homeOverviewNewsTitle,
                    value: freshNews.isEmpty ? l10n.homeOverviewNewsNoFresh : freshNews.length.toString(),
                    subtitle: l10n.homeGridNews,
                    icon: Icons.newspaper_rounded,
                    color: AppColors.primary,
                    delay: 180.ms,
                    onTap: () => context.go('/app?tab=news'),
                  ),
                ],
              ),

            if (_incidentSummaryLoading || _incidentSummary != null) ...[
              const SizedBox(height: AppSpacing.xl),
              SectionHeader(title: l10n.homeLast24hTitle, icon: const Icon(Icons.history_rounded)),
              const SizedBox(height: AppSpacing.md),
              if (_incidentSummaryLoading)
                const SkeletonMetricGrid(count: 2)
              else
                _buildLast24hSection(l10n, _incidentSummary!),
            ],

            if (freshNews.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
              SectionHeader(title: l10n.homeLatestNews, icon: const Icon(Icons.newspaper_rounded)),
              for (final item in freshNews.take(3)) ...[
                NewsListRow(item: item),
                const Divider(height: 1, thickness: 0.6),
              ],
            ],

            const SizedBox(height: AppSpacing.xl),
            SectionHeader(
              title: l10n.homeActiveThermalPoints,
              icon: const FaIcon(FontAwesomeIcons.fireFlameCurved),
              trailing: TextButton(onPressed: () => context.go('/map'), child: Text(l10n.homeSeeOnMap)),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (_fireLoading)
              const SkeletonListLoader(count: 3)
            else
              for (final point in recentPoints.take(5)) ...[
                InkWell(
                  onTap: () => _showFirePreview(context, point),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                point.regionDisplayName(l10n),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.ibmPlexSans(fontSize: 16, fontWeight: FontWeight.w700, color: primaryTextColor),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _isFixedSourcePoint(point)
                                    ? l10n.homeFixedHeatSourceChip
                                    : fireStatusLabel(l10n, point.smartStatus, seenAt: point.detectionDateTimeUtc),
                                style: GoogleFonts.ibmPlexSans(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: _isFixedSourcePoint(point) ? AppColors.textFaint : fireStatusColor(point.smartStatus),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, size: 20),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1, thickness: 0.6),
              ],

            const SizedBox(height: AppSpacing.lg),
            if (_detectionStatus case final status?) ...[
              if (status.kind == DetectionStatusKind.strong)
                _TurkeyLine(status: status, onOpenMap: () => context.go('/map'))
              else
                DetectionStatusCard(
                  status: status,
                  onRetry: _loadDetectionStatus,
                  onReport: () => showReportFirePanel(context, initialType: ReportType.missingFire),
                  onShowLast7Days: status.kind == DetectionStatusKind.unavailable
                      ? null
                      : () => context.go('/map', extra: const {'incidentFilter': 'all'}),
                ),
            ],
            PageAboutLink(
              meaning: l10n.trustHomeMeaning,
              source: l10n.trustHomeSource,
              interpret: l10n.trustHomeInterpret,
              action: l10n.trustHomeAction,
            ),
            const SizedBox(height: 110),
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
  final VoidCallback onOpenMap;
  final VoidCallback onReport;

  const _TodayCard({
    required this.location,
    required this.point,
    required this.nearbyCount,
    required this.onEnableLocation,
    required this.onOpenRisk,
    required this.onOpenMap,
    required this.onReport,
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
          if (nearbyCount > 0 || score >= riskHighFrom) ...[
            const SizedBox(height: AppSpacing.md),
            DetectionSafetyNotice(key: const Key('homeSafetyExpanded'), prominent: nearbyCount > 0),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: onOpenMap, child: Text(l10n.homeSeeOnMap))),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: OutlinedButton(onPressed: onReport, child: Text(l10n.detectionReportButton))),
              ],
            ),
          ],
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
