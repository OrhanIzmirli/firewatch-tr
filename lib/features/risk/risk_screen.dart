import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/config/api_config.dart';
import '../../core/config/feature_flags.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/utils/loading_race.dart';
import '../../core/utils/risk_display.dart';
import '../../l10n/app_localizations.dart';
import '../../services/offline_cache_service.dart';
import '../../shared/coach_mark_keys.dart';
import '../../shared/widgets/coach_mark_overlay.dart';
import '../../shared/widgets/glass_panel.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/skeleton_loader.dart';
import '../../shared/widgets/slow_loading_banner.dart';
import '../../shared/widgets/status_chip.dart';
import '../../shared/widgets/trust_info_card.dart';
import 'widgets/risk_components_list.dart';
import 'widgets/risk_region_list.dart';
import 'widgets/turkey_risk_heatmap.dart';
import '../../services/location_disclosure.dart';
import '../../services/device_position.dart';
import 'package:intl/intl.dart';

import '../../models/tracked_place.dart';
import '../../services/fwi_point_service.dart';
import '../../services/point_risk_service.dart';
import '../../shared/widgets/color_dot.dart';
import 'widgets/tracked_places_section.dart';
import '../../shared/widgets/app_sheet.dart';
import '../../shared/widgets/related_news_section.dart';
import '../../shared/widgets/alerts_bell.dart';

enum _RiskTab { overview, myLocation, places }

class RiskScreen extends StatefulWidget {
  /// Raw region key (e.g. "Ege") to auto-open the detail sheet for once
  /// data has loaded — used when arriving from Home's "Highest Risk
  /// Region" overview card.
  final String? highlightRegion;

  const RiskScreen({super.key, this.highlightRegion});

  @override
  State<RiskScreen> createState() => _RiskScreenState();
}

class _RiskScreenState extends State<RiskScreen> {
  static const _cacheKey = 'risk_summary';

  final Dio _dio = Dio(
    BaseOptions(
      // Generous enough to survive a Render free-tier cold start (can take
      // 10-30s to wake) without throwing a false "offline" failure.
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );
  List<Map<String, dynamic>> _regions = [];
  bool _loading = true;
  bool _isSlowLoading = false;

  /// True while the screen shows the saved copy because the server could
  /// not be reached; [_cachedAt] is when that copy was saved.
  bool _showingCached = false;
  DateTime? _cachedAt;

  _RiskTab _tab = _RiskTab.overview;
  bool _myLocationLoading = false;
  String? _myLocationError;
  String? _myCity;
  String? _myRegionRaw;

  /// The risk score at the user's position, from the server.
  Map<String, dynamic>? _myPoint;

  /// The place open on the Yerlerim tab; null shows the list.
  TrackedPlace? _selectedPlace;
  bool _placeLoading = false;
  String? _placeError;
  Map<String, dynamic>? _placePoint;

  // Awaited by _loadMyLocation() so a "My Location" tap that lands before
  // the Turkey-wide region fetch finishes doesn't wrongly conclude
  // 'region_not_found' against a still-empty _regions list.

  @override
  void initState() {
    super.initState();
    _loadRiskData().then((_) {
      _maybeShowRiskCoachMarks();
      _maybeShowHighlightedRegion();
    });
    _maybeLocateSilently();
  }

  /// When location permission was already granted, find the user's region
  /// in the background so it is highlighted in the chart and the "My
  /// location" tab opens ready. Never asks for permission and never switches
  /// tabs — the Türkiye heat map stays the first view.
  Future<void> _maybeLocateSilently() async {
    if (widget.highlightRegion != null) return;
    try {
      final permission = await Geolocator.checkPermission();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        return;
      }
      if (!mounted || _myPoint != null || _myLocationLoading) return;
      await _loadMyLocation();
    } catch (_) {
      // The Türkiye view works without location.
    }
  }

  String _formatDateTime(DateTime date) {
    final d = date.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}.${two(d.month)}.${d.year} ${two(d.hour)}:${two(d.minute)}';
  }

  void _maybeShowHighlightedRegion() {
    final target = widget.highlightRegion;
    if (target == null || !mounted) return;
    Map<String, dynamic>? region;
    for (final r in _regions) {
      if (r['region'] == target) { region = r; break; }
    }
    if (region == null) return;
    final found = region;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _showRegionDetail(context, found);
    });
  }

  void _maybeShowRiskCoachMarks() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      await maybeShowScreenCoachMarks(
        context,
        prefsKey: 'hasSeenRiskTour',
        steps: [
          CoachMarkStep(
            targetKey: CoachMarkKeys.riskScoreCard,
            title: l10n.coachMarkRiskScoreTitle,
            description: l10n.coachMarkRiskScoreDesc,
          ),
          CoachMarkStep(
            targetKey: CoachMarkKeys.riskChart,
            title: l10n.coachMarkRiskChartTitle,
            description: l10n.coachMarkRiskChartDesc,
          ),
          CoachMarkStep(
            targetKey: CoachMarkKeys.riskMyLocationTab,
            title: l10n.coachMarkRiskMyLocationTabTitle,
            description: l10n.coachMarkRiskMyLocationTabDesc,
          ),
          CoachMarkStep(
            targetKey: CoachMarkKeys.riskInfoButton,
            title: l10n.coachMarkRiskInfoTitle,
            description: l10n.coachMarkRiskInfoDesc,
          ),
        ],
      );
    });
  }

  Future<void> _loadRiskData() async {
    if (mounted) {
      setState(() { _loading = true; _isSlowLoading = false; });
    }
    try {
      final response = await raceWithCacheFallback(
        fetch: retryOnce(() => _dio.get('${ApiConfig.apiBaseUrl}/risk/summary')),
        timeout: const Duration(seconds: 12),
        cacheKey: _cacheKey,
        onSlowFallback: (cached) {
          if (!mounted) return;
          final (data, savedAt) = cached;
          setState(() {
            _regions = (data as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
            _isSlowLoading = true;
            _showingCached = true;
            _cachedAt = savedAt;
            _loading = false;
          });
        },
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        final regions = data.map((e) => Map<String, dynamic>.from(e)).toList();
        await OfflineCacheService.instance.save(_cacheKey, regions);
        if (mounted) {
          setState(() {
          _regions = regions;
          _loading = false;
          _isSlowLoading = false;
          _showingCached = false;
          _cachedAt = null;
        });
        }
      }
    } catch (e) {
      final cached = await OfflineCacheService.instance.load(_cacheKey);
      if (mounted) {
        setState(() {
          if (cached != null) {
            final (data, savedAt) = cached;
            _regions = (data as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
            _showingCached = true;
            _cachedAt = savedAt;
          }
          _isSlowLoading = false;
          _loading = false;
        });
      }
    }
  }

  Future<void> _loadMyLocation() async {
    setState(() {
      _myLocationLoading = true;
      _myLocationError = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() {
          _myLocationLoading = false;
          _myLocationError = 'service_off';
        });
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        permission = await LocationDisclosure.requestPermission(context);
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _myLocationLoading = false;
          _myLocationError = 'permission_denied';
        });
        return;
      }

      final position = await DevicePosition.current(accuracy: LocationAccuracy.low, timeLimit: const Duration(seconds: 10));
      if (!mounted) return;

      final point = await PointRiskService.instance.fetch(lat: position.latitude, lng: position.longitude);
      if (!mounted) return;
      setState(() {
        _myPoint = point;
        _myCity = point['city'] as String?;
        _myRegionRaw = point['region'] as String?;
        _myLocationLoading = false;
        _myLocationError = null;
      });
    } on PointRiskException catch (e) {
      if (!mounted) return;
      setState(() {
        _myPoint = null;
        _myCity = null;
        _myRegionRaw = null;
        _myLocationLoading = false;
        _myLocationError = e.error == PointRiskError.outsideTurkey ? 'outside_turkey' : 'risk_unavailable';
      });
    } catch (e, stack) {
      if (kDebugMode) debugPrint('ERROR _loadMyLocation: $e\n$stack');
      if (!mounted) return;
      setState(() {
        _myLocationLoading = false;
        _myLocationError = 'generic';
      });
    }
  }

  void _selectMyLocationTab() {
    setState(() => _tab = _RiskTab.myLocation);
    if (_myPoint == null && !_myLocationLoading) {
      _loadMyLocation();
    }
  }

  Future<void> _openPlace(TrackedPlace place) async {
    setState(() {
      _selectedPlace = place;
      _placeLoading = true;
      _placeError = null;
      _placePoint = null;
    });
    try {
      final point = await PointRiskService.instance.fetch(lat: place.latitude, lng: place.longitude);
      if (!mounted || _selectedPlace?.id != place.id) return;
      setState(() {
        _placePoint = point;
        _placeLoading = false;
      });
    } on PointRiskException catch (e) {
      if (!mounted || _selectedPlace?.id != place.id) return;
      setState(() {
        _placeLoading = false;
        _placeError = e.error == PointRiskError.outsideTurkey ? 'outside_turkey' : 'risk_unavailable';
      });
    }
  }

  void _showRiskInfoSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showAppSheet(
      context,
      flatGlass: true,
      scrollable: false,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final isDark = theme.brightness == Brightness.dark;
        final titleColor = theme.textTheme.titleLarge?.color ?? (isDark ? AppColors.white : AppColors.lightText);
        final secondaryTextColor = isDark ? AppColors.white.withValues(alpha: 0.74) : Colors.black.withValues(alpha: 0.66);
        final mutedTextColor = isDark ? AppColors.white.withValues(alpha: 0.58) : Colors.black.withValues(alpha: 0.5);

        Widget formulaLine(IconData icon, String text) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 16, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(text, style: GoogleFonts.ibmPlexSans(fontSize: 13, color: secondaryTextColor))),
                ],
              ),
            );

        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: GlassPanel(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.riskInfoTitle,
                      style: GoogleFonts.ibmPlexSans(fontSize: 20, fontWeight: FontWeight.w800, color: titleColor)),
                  const SizedBox(height: AppSpacing.lg),
                  Text(l10n.riskInfoFormulaTitle,
                      style: GoogleFonts.ibmPlexSans(fontSize: 14, fontWeight: FontWeight.w700, color: titleColor)),
                  const SizedBox(height: AppSpacing.sm),
                  formulaLine(Icons.thermostat_rounded, l10n.riskInfoFormulaTemp),
                  formulaLine(Icons.water_drop_outlined, l10n.riskInfoFormulaHumidity),
                  formulaLine(Icons.air_rounded, l10n.riskInfoFormulaWind),
                  formulaLine(Icons.local_fire_department_rounded, l10n.riskInfoFormulaFireCount),
                  formulaLine(Icons.wb_sunny_outlined, l10n.riskInfoFormulaHeatBonus),
                  const SizedBox(height: AppSpacing.lg),
                  Text(l10n.riskInfoSourcesTitle,
                      style: GoogleFonts.ibmPlexSans(fontSize: 14, fontWeight: FontWeight.w700, color: titleColor)),
                  const SizedBox(height: 6),
                  Text(l10n.riskInfoSourcesBody,
                      style: GoogleFonts.ibmPlexSans(fontSize: 13, height: 1.45, color: secondaryTextColor)),
                  const SizedBox(height: AppSpacing.lg),
                  Text(l10n.riskInfoUpdateFrequencyTitle,
                      style: GoogleFonts.ibmPlexSans(fontSize: 14, fontWeight: FontWeight.w700, color: titleColor)),
                  const SizedBox(height: 6),
                  Text(l10n.riskInfoUpdateFrequencyBody,
                      style: GoogleFonts.ibmPlexSans(fontSize: 13, height: 1.45, color: mutedTextColor)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showRegionDetail(BuildContext context, Map<String, dynamic> region) {
    final l10n = AppLocalizations.of(context)!;
    final score = region['general_risk_score'] as int;
    final previous = region['previous_risk_score'];

    showAppSheet(
      context,
      flatGlass: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final isDark = theme.brightness == Brightness.dark;
        final titleColor = theme.textTheme.titleLarge?.color ?? (isDark ? AppColors.white : AppColors.lightText);
        final secondaryTextColor = isDark ? AppColors.white.withValues(alpha: 0.72) : Colors.black.withValues(alpha: 0.62);
        final smallStyle = GoogleFonts.ibmPlexSans(fontSize: 12, color: secondaryTextColor);

        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: GlassPanel(
            key: const Key('riskRegionSheet'),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ColorDot(color: riskScoreColor(score), size: 14),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(riskPlaceLevel(l10n, displayRegionName(l10n, region['region']), score),
                          style: GoogleFonts.ibmPlexSans(fontSize: 22, fontWeight: FontWeight.w800, color: titleColor)),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(l10n.riskScoreOutOf100(score),
                    style: GoogleFonts.ibmPlexSans(fontSize: 14, fontWeight: FontWeight.w700, color: titleColor)),
                Text(l10n.riskScoreNotProbability,
                    style: GoogleFonts.ibmPlexSans(fontSize: 11.5, color: secondaryTextColor)),
                const SizedBox(height: AppSpacing.md),
                Text(riskAdvice(l10n, score),
                    style: GoogleFonts.ibmPlexSans(fontSize: 14, height: 1.4, fontWeight: FontWeight.w700, color: titleColor)),
                const SizedBox(height: AppSpacing.lg),
                RiskComponentsList(row: region),
                const SizedBox(height: AppSpacing.md),
                if (previous != null && previous != score)
                  Text(l10n.riskPreviousScore('$previous'), style: smallStyle),
                if (DateTime.tryParse((region['created_at'] ?? region['date'])?.toString() ?? '') case final calculated?)
                  Text(l10n.riskCalculatedAt(_formatDateTime(calculated)), style: smallStyle),
                if (isRiskRowStale(region))
                  Text(l10n.riskDataStale, style: smallStyle.copyWith(fontWeight: FontWeight.w700, color: AppColors.warning)),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Region key → score for the heat map. Rows with a missing or
  /// unparseable score are left out rather than drawn as zero.
  Map<String, double> get _heatmapScores {
    final scores = <String, double>{};
    for (final r in _regions) {
      final key = r['region']?.toString();
      final raw = r['general_risk_score'];
      final score = raw is num ? raw.toDouble() : double.tryParse('$raw');
      if (key != null && score != null) scores[key] = score;
    }
    return scores;
  }

  Map<String, dynamic>? get _highestRisk {
    if (_regions.isEmpty) return null;
    return _regions.reduce((a, b) =>
        (a['general_risk_score'] as int) > (b['general_risk_score'] as int) ? a : b);
  }

  double get _avgRisk {
    if (_regions.isEmpty) return 0;
    final total = _regions.fold<double>(0, (sum, r) => sum + (r['general_risk_score'] as int));
    return total / _regions.length;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final titleColor = theme.textTheme.titleLarge?.color ??
        (isDark ? AppColors.white : AppColors.lightText);
    final secondaryTextColor = isDark
        ? AppColors.white.withValues(alpha: 0.74)
        : Colors.black.withValues(alpha: 0.66);
    final mutedTextColor = isDark
        ? AppColors.white.withValues(alpha: 0.58)
        : Colors.black.withValues(alpha: 0.5);

    final topRegion = _highestRisk;
    // Rounded like the map's pill, so the same average never reads as two
    // different numbers.
    final avgRiskScore = _avgRisk.round();
    final trendDelta = riskTrendDelta(_regions);

    final anyRegionStale = _regions.any(isRiskRowStale);
    DateTime? lastCalculated;
    for (final region in _regions) {
      final parsed = DateTime.tryParse((region['created_at'] ?? region['date'])?.toString() ?? '');
      if (parsed != null && (lastCalculated == null || parsed.isAfter(lastCalculated))) {
        lastCalculated = parsed;
      }
    }
    final rankedRegions = [..._regions]
      ..sort((a, b) => (b['general_risk_score'] as int)
          .compareTo(a['general_risk_score'] as int));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.riskTitle, style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700)),
        actions: [
          const AlertsBell(),
          IconButton(
            key: CoachMarkKeys.riskInfoButton,
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: l10n.riskInfoButtonTooltip,
            onPressed: () => _showRiskInfoSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() => _loading = true);
              _loadRiskData();
              if (_tab == _RiskTab.myLocation) _loadMyLocation();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadRiskData,
        color: AppColors.primary,
        child: _loading
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: const [SkeletonMetricGrid(count: 4), SizedBox(height: AppSpacing.xl), SkeletonListLoader(count: 3)],
            )
          : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TurkeyRiskHeatmap(regionScores: _heatmapScores)
                      .animate()
                      .fadeIn(duration: 400.ms),
                  if (_regions.isEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Icon(Icons.cloud_off_rounded, size: 14, color: mutedTextColor),
                        const SizedBox(width: 6),
                        Text(
                          l10n.riskHeatUnavailable,
                          style: GoogleFonts.ibmPlexSans(fontSize: 12, color: mutedTextColor),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  if (_isSlowLoading) const SlowLoadingBanner(),
                  GlassPanel(
                    key: CoachMarkKeys.riskScoreCard,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StatusChip(
                          key: const Key('riskViewChip'),
                          label: _showingCached
                              ? l10n.riskSavedView
                              : anyRegionStale
                                  ? l10n.riskLastKnownView
                                  : l10n.riskLiveView,
                          icon: _showingCached
                              ? Icons.cloud_off_rounded
                              : anyRegionStale
                                  ? Icons.history_rounded
                                  : Icons.auto_graph_rounded,
                          color: _showingCached || anyRegionStale ? AppColors.warning : null,
                        ),
                        if (_showingCached) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            _cachedAt == null
                                ? l10n.riskServerUnreachable
                                : l10n.riskServerUnreachableSavedAt(_formatDateTime(_cachedAt!)),
                            style: GoogleFonts.ibmPlexSans(fontSize: 12, color: AppColors.warning),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.md),
                        Text(l10n.riskSummaryTitle,
                            style: GoogleFonts.ibmPlexSans(fontSize: 20, fontWeight: FontWeight.w800, color: titleColor)),
                        if (lastCalculated != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.update_rounded, size: 14, color: mutedTextColor),
                              const SizedBox(width: 4),
                              Text(
                                l10n.fireDetailLastUpdate(_formatDateTime(lastCalculated)),
                                style: GoogleFonts.ibmPlexSans(fontSize: 12, color: mutedTextColor),
                              ),
                            ],
                          ),
                          if (anyRegionStale)
                            Text(
                              l10n.riskDataStale,
                              key: const Key('riskDataStale'),
                              style: GoogleFonts.ibmPlexSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.warning),
                            ),
                        ],
                        const SizedBox(height: AppSpacing.md),
                        if (topRegion != null)
                          // The chip names its region: the national average
                          // on the map can be a different level.
                          Wrap(
                            key: const Key('riskSummaryTopRegion'),
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.xs,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              StatusChip(
                                label: riskPlaceLevel(
                                  l10n,
                                  displayRegionName(l10n, topRegion['region'] as String),
                                  topRegion['general_risk_score'] as num,
                                ),
                                icon: Icons.warning_amber_rounded,
                                color: riskScoreColor(topRegion['general_risk_score'] as num),
                              ),
                              Text(
                                l10n.riskHighestScoreLine(topRegion['general_risk_score'] as int),
                                style: GoogleFonts.ibmPlexSans(fontSize: 14, color: secondaryTextColor),
                              ),
                            ],
                          )
                        else
                          Text(l10n.riskDataLoading,
                              style: GoogleFonts.ibmPlexSans(fontSize: 14, color: secondaryTextColor)),
                        const SizedBox(height: AppSpacing.sm),
                        Text(l10n.riskScoresAreIndices,
                            style: GoogleFonts.ibmPlexSans(fontSize: 12, height: 1.4, color: mutedTextColor)),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms),


                  const SizedBox(height: AppSpacing.xl),

                  // ── Turkey / My Location / My Places ──────────────
                  Row(
                    children: [
                      Expanded(
                        child: _TabToggleButton(
                          label: l10n.riskTabTurkeyOverview,
                          selected: _tab == _RiskTab.overview,
                          onTap: () => setState(() => _tab = _RiskTab.overview),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _TabToggleButton(
                          key: CoachMarkKeys.riskMyLocationTab,
                          label: l10n.riskTabMyLocation,
                          selected: _tab == _RiskTab.myLocation,
                          onTap: _selectMyLocationTab,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _TabToggleButton(
                          key: const Key('riskPlacesTab'),
                          label: l10n.riskTabPlaces,
                          selected: _tab == _RiskTab.places,
                          onTap: () => setState(() => _tab = _RiskTab.places),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  if (_tab == _RiskTab.myLocation) ...[
                    _PointRiskSection(
                      loading: _myLocationLoading,
                      error: _myLocationError,
                      heading: _myPoint == null
                          ? ''
                          : (_myCity != null && _myRegionRaw != null
                              ? l10n.riskMyLocationYourRegion(_myCity!, displayRegionName(l10n, _myRegionRaw!))
                              : l10n.riskTabMyLocation),
                      data: _myPoint,
                      avgRiskScore: avgRiskScore,
                      needsLocation: true,
                      onRetry: _loadMyLocation,
                    ),
                  ]
                  else if (_tab == _RiskTab.places) ...[
                    if (_selectedPlace case final place?) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          key: const Key('riskPlaceBack'),
                          onPressed: () => setState(() => _selectedPlace = null),
                          icon: const Icon(Icons.arrow_back_rounded, size: 18),
                          label: Text(l10n.riskPointBack),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _PointRiskSection(
                        loading: _placeLoading,
                        error: _placeError,
                        heading: place.name,
                        data: _placePoint,
                        avgRiskScore: avgRiskScore,
                        needsLocation: false,
                        onRetry: () => _openPlace(place),
                      ),
                    ] else
                      TrackedPlacesSection(onPlaceTap: _openPlace),
                  ]
                  else ...[
                  if (trendDelta != null) ...[
                    _TrendNote(delta: trendDelta, averageScore: avgRiskScore),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  if (_regions.isNotEmpty) ...[
                    SectionHeader(
                      title: l10n.riskRegionsTitle,
                      subtitle: l10n.riskChartTapHint,
                      icon: const Icon(Icons.public_rounded),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    RiskRegionList(
                      key: CoachMarkKeys.riskChart,
                      regions: rankedRegions,
                      myRegion: _myRegionRaw,
                      onRegionTap: (region) => _showRegionDetail(context, region),
                    ).animate().fadeIn(duration: 300.ms),
                    const SizedBox(height: AppSpacing.xl),
                  ],

                  // Each card is shown only where its screen has real data
                  // (FeatureFlags); debug builds show all three.
                  for (final card in [
                    if (FeatureFlags.restoration)
                      _RiskLinkCard(
                        icon: Icons.forest_rounded,
                        title: l10n.riskRestorationCardTitle,
                        subtitle: l10n.riskRestorationCardSubtitle,
                        onTap: () => context.push('/restoration'),
                      ),
                    if (FeatureFlags.fireHistory)
                      _RiskLinkCard(
                        icon: Icons.history_rounded,
                        title: l10n.riskHistoryCardTitle,
                        subtitle: l10n.riskHistoryCardSubtitle,
                        onTap: () => context.push('/history'),
                      ),
                    if (FeatureFlags.districtRiskMap)
                      _RiskLinkCard(
                        icon: Icons.map_outlined,
                        title: l10n.riskDistrictMapCardTitle,
                        subtitle: l10n.riskDistrictMapCardSubtitle,
                        onTap: () => context.push('/risk-map'),
                      ),
                  ]) ...[card, const SizedBox(height: AppSpacing.md)],

                  RelatedNewsSection(
                    city: null,
                    from: DateTime.now().subtract(const Duration(days: 7)),
                    to: DateTime.now(),
                  ),
                  ],

                  const SizedBox(height: AppSpacing.lg),
                  // The explanations stay folded so the screen stays short.
                  TrustInfoCard(
                    key: const Key('riskMeaningCard'),
                    title: l10n.trustAspectMeaningTitle,
                    icon: Icons.info_outline_rounded,
                    text: [
                      l10n.trustRiskMeaning,
                      l10n.riskSummarySubtitle,
                      l10n.trustRiskSource,
                      l10n.trustRiskInterpret,
                      l10n.trustRiskAction,
                    ].join('\n\n'),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
      ),
    );
  }
}

/// Shown only when the national average really moved since the last run.
class _TrendNote extends StatelessWidget {
  final double delta;
  final int averageScore;

  const _TrendNote({required this.delta, required this.averageScore});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final label = delta > 0 ? l10n.riskOverviewTrendWorsening : l10n.riskOverviewTrendImproving;
    return GlassPanel(
      key: const Key('riskTrendCard'),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Icon(
            delta > 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            color: riskScoreColor(averageScore),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${l10n.riskOverviewTrendTitle}: $label',
                    style: GoogleFonts.ibmPlexSans(fontSize: 14, fontWeight: FontWeight.w700, color: theme.textTheme.titleMedium?.color)),
                Text(l10n.riskOverviewTrendSubtitle(delta.abs().toStringAsFixed(0)),
                    style: GoogleFonts.ibmPlexSans(fontSize: 12, color: theme.textTheme.bodySmall?.color)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabToggleButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabToggleButton({super.key, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.primary.withValues(alpha: isDark ? 0.1 : 0.08),
          borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
        ),
        child: Text(label,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppColors.primary,
            )),
      ),
    );
  }
}

/// The same analysis for "Konumum" and for a saved place: level, score,
/// advice and what the score is made of, with the Copernicus index separate
/// at the bottom.
class _PointRiskSection extends StatelessWidget {
  final bool loading;
  final String? error;
  final String heading;
  final Map<String, dynamic>? data;
  final int avgRiskScore;

  /// Loading and failure messages talk about the device's location.
  final bool needsLocation;
  final VoidCallback onRetry;

  const _PointRiskSection({
    required this.loading,
    required this.error,
    required this.heading,
    required this.data,
    required this.avgRiskScore,
    required this.needsLocation,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final titleColor = theme.textTheme.titleLarge?.color ?? (isDark ? AppColors.white : AppColors.lightText);
    final secondaryTextColor = isDark ? AppColors.white.withValues(alpha: 0.74) : Colors.black.withValues(alpha: 0.66);

    if (loading) {
      return GlassPanel(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: AppSpacing.md),
            Text(needsLocation ? l10n.riskMyLocationGettingLocation : l10n.riskDataLoading,
                style: GoogleFonts.ibmPlexSans(fontSize: 14, color: secondaryTextColor)),
          ],
        ),
      );
    }

    if (error != null) {
      final message = switch (error) {
        'service_off' => l10n.riskMyLocationServiceOff,
        'permission_denied' => l10n.riskMyLocationPermissionDenied,
        'outside_turkey' => l10n.riskOutsideTurkeyBanner,
        'risk_unavailable' => l10n.riskPointUnavailable,
        _ => l10n.riskMyLocationError,
      };
      final locationProblem = error != 'risk_unavailable' && error != 'outside_turkey';
      return GlassPanel(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Icon(
              error == 'outside_turkey' ? Icons.public_off_rounded : Icons.location_off_rounded,
              color: secondaryTextColor,
              size: 32,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(message, textAlign: TextAlign.center,
                style: GoogleFonts.ibmPlexSans(fontSize: 14, color: secondaryTextColor)),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: onRetry,
              icon: Icon(locationProblem ? Icons.my_location_rounded : Icons.refresh_rounded),
              label: Text(locationProblem ? l10n.riskMyLocationEnableButton : l10n.commonRetry),
            ),
          ],
        ),
      );
    }

    final data = this.data;
    if (data == null) {
      return GlassPanel(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Text(l10n.riskDataLoading, style: GoogleFonts.ibmPlexSans(fontSize: 14, color: secondaryTextColor)),
      );
    }

    final score = (data['general_risk_score'] as num).toInt();
    final level = riskLevelForScore(score);
    final color = colorForApiRiskLevel(level);
    final diff = score - avgRiskScore;
    final diffStr = diff > 0 ? '+$diff' : '$diff';
    final city = data['city'] as String?;
    final levelOwner = needsLocation ? city ?? heading : heading;
    final radius = (data['nearby_radius_km'] as num?)?.toInt() ?? 50;
    final nearby = (data['nearby_fire_count'] as num?)?.toInt();
    final nearbyText = nearby == null
        ? l10n.riskPointNearbyUnknown
        : nearby == 0
            ? l10n.riskPointNearbyNone(radius)
            : l10n.riskPointNearby(radius, nearby);
    final calculated = DateTime.tryParse('${data['date']}')?.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    final sectionTitle = GoogleFonts.ibmPlexSans(fontSize: 14, fontWeight: FontWeight.w700, color: titleColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: GlassPanel(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        heading,
                        style: GoogleFonts.ibmPlexSans(fontSize: 20, fontWeight: FontWeight.w800, color: titleColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    ColorDot(color: color, size: 12),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        riskPlaceLevel(l10n, levelOwner, score),
                        style: GoogleFonts.ibmPlexSans(fontSize: 15, fontWeight: FontWeight.w700, color: titleColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(l10n.riskScoreOutOf100(score),
                    style: GoogleFonts.ibmPlexSans(fontSize: 14, fontWeight: FontWeight.w700, color: titleColor)),
                const SizedBox(height: 2),
                Text(l10n.riskMyLocationVsAverage(diffStr),
                    style: GoogleFonts.ibmPlexSans(fontSize: 13, color: secondaryTextColor)),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 380.ms).scale(begin: const Offset(0.98, 0.98), end: const Offset(1, 1)),

        const SizedBox(height: AppSpacing.md),

        GlassPanel(
          key: const Key('pointRiskDetails'),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.riskPointAdviceTitle, style: sectionTitle),
              const SizedBox(height: 4),
              Text(riskAdvice(l10n, score),
                  style: GoogleFonts.ibmPlexSans(fontSize: 14, height: 1.4, fontWeight: FontWeight.w700, color: color)),
              const SizedBox(height: AppSpacing.md),
              Text(l10n.riskScoreNotProbability,
                  style: GoogleFonts.ibmPlexSans(fontSize: 11.5, height: 1.4, color: secondaryTextColor)),
              if (calculated != null)
                Text(l10n.riskPointCalculatedAt('${two(calculated.hour)}:${two(calculated.minute)}'),
                    style: GoogleFonts.ibmPlexSans(fontSize: 11.5, height: 1.4, color: secondaryTextColor)),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        GlassPanel(
          key: const Key('pointRiskComponents'),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: RiskComponentsList(row: data, detectionsNote: nearbyText),
        ),

        RelatedNewsSection(
          city: city,
          from: DateTime.now().subtract(const Duration(days: 7)),
          to: DateTime.now(),
        ),
        const SizedBox(height: AppSpacing.xxl),
        _CopernicusIndexCard(
          lat: (data['latitude'] as num).toDouble(),
          lng: (data['longitude'] as num).toDouble(),
        ),
      ],
    );
  }

}

/// Copernicus's own fire danger class at the (already rounded) point. A
/// second opinion, labelled as such: it is not the FireWatch score and
/// nothing is calculated from it. Absent when the service has no answer.
class _CopernicusIndexCard extends StatefulWidget {
  final double lat;
  final double lng;
  const _CopernicusIndexCard({required this.lat, required this.lng});

  @override
  State<_CopernicusIndexCard> createState() => _CopernicusIndexCardState();
}

class _CopernicusIndexCardState extends State<_CopernicusIndexCard> {
  static const _colors = [
    AppColors.fwiVeryLow,
    AppColors.fwiLow,
    AppColors.fwiModerate,
    AppColors.fwiHigh,
    AppColors.fwiVeryHigh,
    AppColors.fwiExtreme,
  ];

  late Future<FwiPointSample?> _sample = _load();

  Future<FwiPointSample?> _load() => FwiPointService.instance.sample(
        lat: widget.lat,
        lng: widget.lng,
        date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      );

  @override
  void didUpdateWidget(_CopernicusIndexCard old) {
    super.didUpdateWidget(old);
    if (old.lat != widget.lat || old.lng != widget.lng) _sample = _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final labels = [
      l10n.riskClassVeryLow,
      l10n.riskClassLow,
      l10n.riskClassModerate,
      l10n.riskClassHigh,
      l10n.riskClassVeryHigh,
      l10n.riskClassExtreme,
    ];
    final muted = Theme.of(context).textTheme.bodySmall?.color;
    return FutureBuilder<FwiPointSample?>(
      future: _sample,
      builder: (context, snapshot) {
        final index = snapshot.data?.classIndex;
        if (index == null) return const SizedBox.shrink();
        return GlassPanel(
          key: const Key('copernicusIndex'),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.riskCopernicusTitle, style: GoogleFonts.ibmPlexSans(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Row(
                children: [
                  ColorDot(color: _colors[index], size: 10),
                  const SizedBox(width: 6),
                  Text(labels[index], style: GoogleFonts.ibmPlexSans(fontSize: 13.5, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 6),
              Text(l10n.riskCopernicusNote, style: GoogleFonts.ibmPlexSans(fontSize: 12, height: 1.4, color: muted)),
              const SizedBox(height: 4),
              Text(l10n.riskCopernicusAttribution, style: GoogleFonts.ibmPlexSans(fontSize: 10.5, color: muted)),
            ],
          ),
        );
      },
    );
  }
}

/// A tappable card that leads off the risk screen to a related screen.
class _RiskLinkCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RiskLinkCard({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius),
      child: GlassPanel(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.ibmPlexSans(fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: GoogleFonts.ibmPlexSans(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
