import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/config/api_config.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/loading_race.dart';
import '../../core/utils/risk_display.dart';
import '../../l10n/app_localizations.dart';
import '../../services/fire_api_service.dart';
import '../../services/offline_cache_service.dart';
import '../../shared/coach_mark_keys.dart';
import '../../shared/widgets/coach_mark_overlay.dart';
import '../../shared/widgets/glass_panel.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/skeleton_loader.dart';
import '../../shared/widgets/slow_loading_banner.dart';
import '../../shared/widgets/smart_overview_card.dart';
import '../../shared/widgets/status_chip.dart';
import '../../shared/widgets/trust_info_card.dart';

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
  final FireApiService _fireApiService = FireApiService();
  List<Map<String, dynamic>> _regions = [];
  bool _loading = true;
  bool _isSlowLoading = false;

  bool _showMyLocation = false;
  bool _myLocationLoading = false;
  String? _myLocationError;
  String? _myCity;
  String? _myRegionRaw;
  double? _myDistanceKm;

  // Awaited by _loadMyLocation() so a "My Location" tap that lands before
  // the Turkey-wide region fetch finishes doesn't wrongly conclude
  // 'region_not_found' against a still-empty _regions list.
  late Future<void> _riskDataLoadFuture;

  // Same bounding box / mock-fix detection home_screen.dart uses, so both
  // screens classify a given GPS fix identically instead of risk_screen
  // relying solely on the backend's own outsideTurkey classification.
  static const double _emulatorTestLat = 38.42;
  static const double _emulatorTestLng = 27.14;

  static bool _isInsideTurkeyBbox(double lat, double lng) =>
      lat >= 35.8 && lat <= 42.2 && lng >= 25.6 && lng <= 44.8;

  @override
  void initState() {
    super.initState();
    _riskDataLoadFuture = _loadRiskData().then((_) {
      _maybeShowRiskCoachMarks();
      _maybeShowHighlightedRegion();
    });
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
          final (data, _) = cached;
          setState(() {
            _regions = (data as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
            _isSlowLoading = true;
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
        });
        }
      }
    } catch (e) {
      final cached = await OfflineCacheService.instance.load(_cacheKey);
      if (mounted) {
        setState(() {
          if (cached != null) {
            final (data, _) = cached;
            _regions = (data as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
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
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _myLocationLoading = false;
          _myLocationError = 'permission_denied';
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 10),
        ),
      );
      if (!mounted) return;

      final isEmulatorTestLocation =
          (position.latitude - _emulatorTestLat).abs() < 0.01 &&
          (position.longitude - _emulatorTestLng).abs() < 0.01;

      NearestCityResult cityInfo;
      if (!isEmulatorTestLocation && !_isInsideTurkeyBbox(position.latitude, position.longitude)) {
        cityInfo = const NearestCityResult(outsideTurkey: true);
      } else {
        cityInfo = await _fireApiService.getNearestCity(position.latitude, position.longitude);
      }

      if (!mounted) return;
      if (cityInfo.outsideTurkey) {
        setState(() {
          _myCity = null;
          _myRegionRaw = null;
          _myDistanceKm = null;
          _myLocationLoading = false;
          _myLocationError = 'outside_turkey';
        });
        return;
      }

      // Wait for the Turkey-wide region fetch if it hasn't finished yet —
      // otherwise _regions is still empty and every region legitimately
      // "doesn't match", permanently sticking on 'region_not_found' even
      // after _regions populates (nothing re-runs this check afterwards).
      if (_regions.isEmpty) {
        await _riskDataLoadFuture;
        if (!mounted) return;
      }

      final regionRaw = cityInfo.region;
      final matches = _regions.any((r) => r['region'] == regionRaw);
      setState(() {
        _myCity = cityInfo.city;
        _myRegionRaw = regionRaw;
        _myDistanceKm = cityInfo.distanceKm;
        _myLocationLoading = false;
        _myLocationError = matches ? null : 'region_not_found';
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
    setState(() => _showMyLocation = true);
    if (_myCity == null && !_myLocationLoading) {
      _loadMyLocation();
    }
  }

  Map<String, dynamic>? get _myRegionData {
    if (_myRegionRaw == null) return null;
    for (final r in _regions) {
      if (r['region'] == _myRegionRaw) return r;
    }
    return null;
  }

  String _riskNote(AppLocalizations l10n, Map<String, dynamic> region) {
    final temp = double.tryParse(region['temperature'].toString()) ?? 0;
    final hum = double.tryParse(region['humidity'].toString()) ?? 0;
    final wind = double.tryParse(region['wind_speed'].toString()) ?? 0;

    final parts = <String>[];
    if (temp >= 35) {
      parts.add(l10n.riskNoteHighTemp(temp.toInt()));
    } else if (temp >= 25) {
      parts.add(l10n.riskNoteMildTemp(temp.toInt()));
    } else {
      parts.add(l10n.riskNoteCoolTemp(temp.toInt()));
    }

    if (hum <= 30) {
      parts.add(l10n.riskNoteLowHumidity(hum.toInt()));
    } else if (hum <= 50) {
      parts.add(l10n.riskNoteMediumHumidity(hum.toInt()));
    } else {
      parts.add(l10n.riskNoteHighHumidity(hum.toInt()));
    }

    if (wind >= 30) {
      parts.add(l10n.riskNoteStrongWind(wind.toInt()));
    } else if (wind >= 15) {
      parts.add(l10n.riskNoteMediumWind(wind.toInt()));
    }

    return parts.join(' • ');
  }

  void _showRiskInfoSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final isDark = theme.brightness == Brightness.dark;
        final titleColor = theme.textTheme.titleLarge?.color ?? (isDark ? AppColors.white : const Color(0xFF0F172A));
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
    final level = region['risk_level'] as String;
    final color = colorForApiRiskLevel(level);
    final temp = double.tryParse(region['temperature'].toString()) ?? 0;
    final hum = double.tryParse(region['humidity'].toString()) ?? 0;
    final wind = double.tryParse(region['wind_speed'].toString()) ?? 0;
    final dryness = double.tryParse(region['dryness_index'].toString()) ?? 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final isDark = theme.brightness == Brightness.dark;
        final titleColor = theme.textTheme.titleLarge?.color ?? (isDark ? AppColors.white : const Color(0xFF0F172A));
        final secondaryTextColor = isDark ? AppColors.white.withValues(alpha: 0.72) : Colors.black.withValues(alpha: 0.62);

        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: GlassPanel(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(displayRegionName(l10n, region['region']),
                          style: GoogleFonts.ibmPlexSans(fontSize: 22, fontWeight: FontWeight.w800, color: titleColor)),
                    ),
                    StatusChip(label: riskLevelLabel(l10n, level), icon: Icons.warning_amber_rounded, color: color),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(l10n.riskScoreOutOf100(score),
                    style: GoogleFonts.ibmPlexSans(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
                const SizedBox(height: AppSpacing.sm),
                Text(_riskNote(l10n, region),
                    style: GoogleFonts.ibmPlexSans(fontSize: 13, height: 1.45, color: secondaryTextColor)),
                const SizedBox(height: AppSpacing.lg),
                _DetailMetricRow(icon: Icons.thermostat_rounded, label: l10n.commonTemperature, value: '${temp.toInt()}°C', color: secondaryTextColor),
                const SizedBox(height: 8),
                _DetailMetricRow(icon: Icons.water_drop_outlined, label: l10n.riskHumidity, value: '%${hum.toInt()}', color: secondaryTextColor),
                const SizedBox(height: 8),
                _DetailMetricRow(icon: Icons.air_rounded, label: l10n.commonWind, value: '${wind.toInt()} km/h', color: secondaryTextColor),
                const SizedBox(height: 8),
                _DetailMetricRow(icon: Icons.grain_rounded, label: l10n.riskDrynessIndex, value: '${dryness.toInt()}', color: secondaryTextColor),
              ],
            ),
          ),
        );
      },
    );
  }

  Map<String, dynamic>? get _highestRisk {
    if (_regions.isEmpty) return null;
    return _regions.reduce((a, b) =>
        (a['general_risk_score'] as int) > (b['general_risk_score'] as int) ? a : b);
  }

  Map<String, dynamic>? get _lowestRisk {
    if (_regions.isEmpty) return null;
    return _regions.reduce((a, b) =>
        (a['general_risk_score'] as int) < (b['general_risk_score'] as int) ? a : b);
  }

  double get _avgRisk {
    if (_regions.isEmpty) return 0;
    final total = _regions.fold<double>(0, (sum, r) => sum + (r['general_risk_score'] as int));
    return total / _regions.length;
  }

  /// Average of the previous calculator run's score across regions that
  /// have a prior data point, vs the current average — a simple two-point
  /// trend (the backend only exposes one prior snapshot per region, not a
  /// full history).
  double? get _avgPreviousRisk {
    final withPrevious = _regions.where((r) => r['previous_risk_score'] != null).toList();
    if (withPrevious.isEmpty) return null;
    final total = withPrevious.fold<double>(0, (sum, r) => sum + (r['previous_risk_score'] as int));
    return total / withPrevious.length;
  }

  double get _avgTemp {
    if (_regions.isEmpty) return 0;
    final total = _regions.fold<double>(0, (sum, r) => sum + (double.tryParse(r['temperature'].toString()) ?? 0));
    return total / _regions.length;
  }

  double get _avgHumidity {
    if (_regions.isEmpty) return 0;
    final total = _regions.fold<double>(0, (sum, r) => sum + (double.tryParse(r['humidity'].toString()) ?? 0));
    return total / _regions.length;
  }

  double get _avgWind {
    if (_regions.isEmpty) return 0;
    final total = _regions.fold<double>(0, (sum, r) => sum + (double.tryParse(r['wind_speed'].toString()) ?? 0));
    return total / _regions.length;
  }

  double get _avgDryness {
    if (_regions.isEmpty) return 0;
    final total = _regions.fold<double>(0, (sum, r) => sum + (double.tryParse(r['dryness_index'].toString()) ?? 0));
    return total / _regions.length;
  }

  double get _avgVegetation {
    if (_regions.isEmpty) return 0;
    final total = _regions.fold<double>(0, (sum, r) => sum + (double.tryParse(r['vegetation_density'].toString()) ?? 0));
    return total / _regions.length;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final titleColor = theme.textTheme.titleLarge?.color ??
        (isDark ? AppColors.white : const Color(0xFF0F172A));
    final secondaryTextColor = isDark
        ? AppColors.white.withValues(alpha: 0.74)
        : Colors.black.withValues(alpha: 0.66);
    final mutedTextColor = isDark
        ? AppColors.white.withValues(alpha: 0.58)
        : Colors.black.withValues(alpha: 0.5);

    final topRegion = _highestRisk;
    final avgRiskScore = _avgRisk.toInt();
    final overallLevel = avgRiskScore >= 75 ? l10n.commonCritical :
                         avgRiskScore >= 50 ? l10n.commonHigh :
                         avgRiskScore >= 25 ? l10n.commonMedium : l10n.commonLow;
    final overallLevelColor = avgRiskScore >= 75
        ? AppColors.danger
        : avgRiskScore >= 50
            ? AppColors.danger
            : avgRiskScore >= 25
                ? AppColors.warning
                : AppColors.success;

    DateTime? lastCalculated;
    for (final region in _regions) {
      final parsed = DateTime.tryParse(region['date']?.toString() ?? '');
      if (parsed != null && (lastCalculated == null || parsed.isAfter(lastCalculated))) {
        lastCalculated = parsed;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.riskTitle, style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700)),
        actions: [
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
              if (_showMyLocation) _loadMyLocation();
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
                  if (_isSlowLoading) const SlowLoadingBanner(),
                  GlassPanel(
                    key: CoachMarkKeys.riskScoreCard,
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StatusChip(label: l10n.riskLiveView, icon: Icons.auto_graph_rounded),
                        const SizedBox(height: AppSpacing.lg),
                        Text(l10n.riskSummaryTitle,
                            style: GoogleFonts.ibmPlexSans(fontSize: 30, fontWeight: FontWeight.w800, color: titleColor)),
                        if (lastCalculated != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.update_rounded, size: 14, color: mutedTextColor),
                              const SizedBox(width: 4),
                              Text(
                                l10n.fireDetailLastUpdate('${lastCalculated.day.toString().padLeft(2, '0')}.${lastCalculated.month.toString().padLeft(2, '0')}.${lastCalculated.year} ${lastCalculated.hour.toString().padLeft(2, '0')}:${lastCalculated.minute.toString().padLeft(2, '0')}'),
                                style: GoogleFonts.ibmPlexSans(fontSize: 12, color: mutedTextColor),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: AppSpacing.sm),
                        Text(l10n.riskSummarySubtitle,
                            style: GoogleFonts.ibmPlexSans(fontSize: 15, height: 1.45, color: secondaryTextColor)),
                        const SizedBox(height: AppSpacing.lg),
                        Row(
                          children: [
                            StatusChip(label: overallLevel, icon: Icons.warning_amber_rounded, color: overallLevelColor),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                topRegion != null
                                    ? l10n.riskHighestRisk(displayRegionName(l10n, topRegion['region']), topRegion['general_risk_score'])
                                    : l10n.riskDataLoading,
                                style: GoogleFonts.ibmPlexSans(fontSize: 14, color: secondaryTextColor),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 450.ms).scale(
                        begin: const Offset(0.97, 0.97),
                        end: const Offset(1, 1),
                        curve: Curves.easeOutCubic,
                      ).slideY(begin: 0.06, end: 0),

                  const SizedBox(height: AppSpacing.md),
                  TrustInfoCardGroup(
                    meaning: l10n.trustRiskMeaning,
                    source: l10n.trustRiskSource,
                    interpret: l10n.trustRiskInterpret,
                    action: l10n.trustRiskAction,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // ── Turkey Overview / My Location toggle ──────────
                  Row(
                    children: [
                      Expanded(
                        child: _TabToggleButton(
                          label: l10n.riskTabTurkeyOverview,
                          selected: !_showMyLocation,
                          onTap: () => setState(() => _showMyLocation = false),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _TabToggleButton(
                          key: CoachMarkKeys.riskMyLocationTab,
                          label: l10n.riskTabMyLocation,
                          selected: _showMyLocation,
                          onTap: _selectMyLocationTab,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  if (_showMyLocation)
                    _MyLocationSection(
                      loading: _myLocationLoading,
                      error: _myLocationError,
                      city: _myCity,
                      regionData: _myRegionData,
                      regions: _regions,
                      avgRiskScore: avgRiskScore,
                      avgTemp: _avgTemp,
                      avgHumidity: _avgHumidity,
                      avgWind: _avgWind,
                      avgDryness: _avgDryness,
                      avgVegetation: _avgVegetation,
                      distanceKm: _myDistanceKm,
                      onRetry: _loadMyLocation,
                      onTapRegion: () {
                        final data = _myRegionData;
                        if (data != null) _showRegionDetail(context, data);
                      },
                    )
                  else ...[
                  SectionHeader(
                    title: l10n.riskKeyIndicators,
                    subtitle: l10n.riskTurkeyAverage,
                    icon: const Icon(Icons.dashboard_rounded),
                  ).animate(delay: 80.ms).fadeIn(duration: 280.ms).slideX(begin: -0.03, end: 0),

                  const SizedBox(height: AppSpacing.md),

                  Builder(builder: (context) {
                    final highest = _highestRisk;
                    final lowest = _lowestRisk;
                    final prevAvg = _avgPreviousRisk;
                    final trendDelta = prevAvg == null ? null : (avgRiskScore - prevAvg);
                    final trendColor = trendDelta == null
                        ? AppColors.primary
                        : trendDelta > 1
                            ? AppColors.danger
                            : trendDelta < -1
                                ? AppColors.success
                                : AppColors.warning;
                    final trendLabel = trendDelta == null
                        ? l10n.riskOverviewTrendNoData
                        : trendDelta > 1
                            ? l10n.riskOverviewTrendWorsening
                            : trendDelta < -1
                                ? l10n.riskOverviewTrendImproving
                                : l10n.riskOverviewTrendStable;
                    final trendIcon = trendDelta == null
                        ? Icons.show_chart_rounded
                        : trendDelta > 1
                            ? Icons.trending_up_rounded
                            : trendDelta < -1
                                ? Icons.trending_down_rounded
                                : Icons.trending_flat_rounded;

                    return GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                      childAspectRatio: 0.86,
                      children: [
                        SmartOverviewCard(
                          title: l10n.riskOverviewHighestTitle,
                          value: highest == null
                              ? l10n.riskDataLoading
                              : l10n.homeOverviewHighestRiskValue(
                                  displayRegionName(l10n, highest['region'] as String),
                                  highest['general_risk_score'] as int),
                          subtitle: l10n.riskOverviewHighestSubtitle,
                          icon: Icons.warning_amber_rounded,
                          color: highest == null ? AppColors.primary : colorForApiRiskLevel(highest['risk_level'] as String),
                          delay: 140.ms,
                          onTap: highest == null ? null : () => _showRegionDetail(context, highest),
                        ),
                        SmartOverviewCard(
                          title: l10n.riskOverviewLowestTitle,
                          value: lowest == null
                              ? l10n.riskDataLoading
                              : l10n.homeOverviewHighestRiskValue(
                                  displayRegionName(l10n, lowest['region'] as String),
                                  lowest['general_risk_score'] as int),
                          subtitle: l10n.riskOverviewLowestSubtitle,
                          icon: Icons.eco_outlined,
                          color: lowest == null ? AppColors.primary : colorForApiRiskLevel(lowest['risk_level'] as String),
                          delay: 220.ms,
                          onTap: lowest == null ? null : () => _showRegionDetail(context, lowest),
                        ),
                        SmartOverviewCard(
                          title: l10n.riskOverviewAvgTitle,
                          value: '$avgRiskScore',
                          subtitle: l10n.riskOverviewAvgSubtitle,
                          icon: Icons.local_fire_department_rounded,
                          color: avgRiskScore >= 50 ? AppColors.danger : AppColors.warning,
                          delay: 300.ms,
                        ),
                        SmartOverviewCard(
                          title: l10n.riskOverviewTrendTitle,
                          value: trendLabel,
                          subtitle: trendDelta == null
                              ? l10n.riskOverviewTrendNoDataSubtitle
                              : l10n.riskOverviewTrendSubtitle(trendDelta.abs().toStringAsFixed(0)),
                          icon: trendIcon,
                          color: trendColor,
                          delay: 380.ms,
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: AppSpacing.xxxl),

                  if (_regions.isNotEmpty) ...[
                    SectionHeader(
                      title: l10n.riskRegionalDistribution,
                      subtitle: l10n.riskRegionalDistributionSubtitle,
                      icon: const Icon(Icons.show_chart_rounded),
                    ).animate(delay: 140.ms).fadeIn(duration: 280.ms).slideX(begin: -0.03, end: 0),

                    const SizedBox(height: AppSpacing.md),

                    RepaintBoundary(
                      child: GlassPanel(
                      key: CoachMarkKeys.riskChart,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(l10n.riskScore,
                                    style: GoogleFonts.ibmPlexSans(fontSize: 16, fontWeight: FontWeight.w700, color: titleColor)),
                              ),
                              Text(l10n.riskChartTapHint,
                                  style: GoogleFonts.ibmPlexSans(fontSize: 11, color: mutedTextColor)),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Table(
                            columnWidths: const {0: IntrinsicColumnWidth(), 1: FlexColumnWidth()},
                            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                            children: _regions.asMap().entries.map((e) {
                              final region = e.value;
                              final score = region['general_risk_score'] as int;
                              final isMine = _myRegionRaw != null && region['region'] == _myRegionRaw;
                              final barColor = riskScoreColor(score);
                              return TableRow(
                                decoration: isMine
                                    ? BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(10),
                                      )
                                    : null,
                                children: [
                                  InkWell(
                                    onTap: () => _showRegionDetail(context, region),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                                      child: Text(
                                        displayRegionName(l10n, region['region']),
                                        style: GoogleFonts.ibmPlexSans(
                                          fontSize: 13,
                                          fontWeight: isMine ? FontWeight.w800 : FontWeight.w600,
                                          color: isMine
                                              ? (isDark ? AppColors.white : Colors.black87)
                                              : mutedTextColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => _showRegionDetail(context, region),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: SizedBox(
                                              height: 18,
                                              child: Stack(
                                                children: [
                                                  Positioned.fill(
                                                    child: DecoratedBox(
                                                      decoration: BoxDecoration(
                                                        color: isDark
                                                            ? AppColors.white.withValues(alpha: 0.06)
                                                            : Colors.black.withValues(alpha: 0.05),
                                                        borderRadius: BorderRadius.circular(6),
                                                      ),
                                                    ),
                                                  ),
                                                  FractionallySizedBox(
                                                    widthFactor: score.clamp(0, 100) / 100,
                                                    heightFactor: 1,
                                                    alignment: Alignment.centerLeft,
                                                    child: DecoratedBox(
                                                      decoration: BoxDecoration(
                                                        color: barColor,
                                                        borderRadius: BorderRadius.circular(6),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ).animate(delay: (220 + e.key * 40).ms).fadeIn(duration: 320.ms).scaleX(
                                                  begin: 0,
                                                  end: 1,
                                                  alignment: Alignment.centerLeft,
                                                ),
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          SizedBox(
                                            width: 28,
                                            child: Text(
                                              '$score',
                                              textAlign: TextAlign.right,
                                              style: AppTheme.mono(
                                                size: 13,
                                                weight: FontWeight.w700,
                                                color: barColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                      ),
                    ).animate(delay: 180.ms).fadeIn(duration: 380.ms).scale(
                          begin: const Offset(0.98, 0.98),
                          end: const Offset(1, 1),
                        ),

                    const SizedBox(height: AppSpacing.xxxl),
                  ],

                  SectionHeader(
                    title: l10n.riskRegionDetails,
                    subtitle: l10n.riskRegionDetailsSubtitle,
                    icon: const Icon(Icons.public_rounded),
                  ).animate(delay: 200.ms).fadeIn(duration: 280.ms).slideX(begin: -0.03, end: 0),

                  const SizedBox(height: AppSpacing.md),

                  ..._regions.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final region = entry.value;
                    final score = region['general_risk_score'] as int;
                    final level = region['risk_level'] as String;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius),
                        onTap: () => _showRegionDetail(context, region),
                        child: _RegionRiskCard(
                          region: displayRegionName(l10n, region['region']),
                          risk: riskLevelLabel(l10n, level),
                          rawLevel: level,
                          score: score,
                          note: _riskNote(l10n, region),
                          delay: Duration(milliseconds: 240 + (idx * 70)),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: AppSpacing.xxxl),

                  SectionHeader(
                    title: l10n.riskEnvironmentalFactors,
                    subtitle: l10n.riskTurkeyAverage,
                    icon: const Icon(Icons.eco_outlined),
                  ).animate(delay: 240.ms).fadeIn(duration: 280.ms).slideX(begin: -0.03, end: 0),

                  const SizedBox(height: AppSpacing.md),

                  _ProgressFactorCard(
                    title: l10n.riskDrynessIndex,
                    value: _avgDryness / 100,
                    label: _avgDryness >= 70 ? l10n.riskDrynessVeryHigh : _avgDryness >= 50 ? l10n.commonHigh : l10n.commonMedium,
                    color: AppColors.danger,
                    delay: const Duration(milliseconds: 280),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _ProgressFactorCard(
                    title: l10n.riskWindPressure,
                    value: (_avgWind / 80).clamp(0, 1),
                    label: _avgWind >= 50 ? l10n.commonHigh : _avgWind >= 25 ? l10n.commonMedium : l10n.commonLow,
                    color: AppColors.warning,
                    delay: const Duration(milliseconds: 350),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _ProgressFactorCard(
                    title: l10n.riskVegetationDensity,
                    value: _avgVegetation / 100,
                    label: _avgVegetation >= 60 ? l10n.riskVegetationMediumHigh : l10n.commonMedium,
                    color: AppColors.primary,
                    delay: const Duration(milliseconds: 420),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _ProgressFactorCard(
                    title: l10n.riskHumidityLevel,
                    value: (_avgHumidity / 100).clamp(0, 1),
                    label: _avgHumidity >= 60 ? l10n.commonHigh : _avgHumidity >= 40 ? l10n.commonMedium : l10n.commonLow,
                    color: AppColors.success,
                    delay: const Duration(milliseconds: 490),
                  ),
                  ],

                  const SizedBox(height: 100),
                ],
              ),
            ),
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

class _MyLocationSection extends StatelessWidget {
  final bool loading;
  final String? error;
  final String? city;
  final Map<String, dynamic>? regionData;
  final List<Map<String, dynamic>> regions;
  final int avgRiskScore;
  final double avgTemp;
  final double avgHumidity;
  final double avgWind;
  final double avgDryness;
  final double avgVegetation;
  final double? distanceKm;
  final VoidCallback onRetry;
  final VoidCallback onTapRegion;

  const _MyLocationSection({
    required this.loading,
    required this.error,
    required this.city,
    required this.regionData,
    required this.regions,
    required this.avgRiskScore,
    required this.avgTemp,
    required this.avgHumidity,
    required this.avgWind,
    required this.avgDryness,
    required this.avgVegetation,
    required this.distanceKm,
    required this.onRetry,
    required this.onTapRegion,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final titleColor = theme.textTheme.titleLarge?.color ?? (isDark ? AppColors.white : const Color(0xFF0F172A));
    final secondaryTextColor = isDark ? AppColors.white.withValues(alpha: 0.74) : Colors.black.withValues(alpha: 0.66);

    if (loading) {
      return GlassPanel(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: AppSpacing.md),
            Text(l10n.riskMyLocationGettingLocation,
                style: GoogleFonts.ibmPlexSans(fontSize: 14, color: secondaryTextColor)),
          ],
        ),
      );
    }

    if (error != null) {
      final message = switch (error) {
        'service_off' => l10n.riskMyLocationServiceOff,
        'permission_denied' => l10n.riskMyLocationPermissionDenied,
        'region_not_found' => l10n.riskMyLocationRegionNotFound,
        'outside_turkey' => l10n.riskOutsideTurkeyBanner,
        _ => l10n.riskMyLocationError,
      };
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
              icon: const Icon(Icons.my_location_rounded),
              label: Text(l10n.riskMyLocationEnableButton),
            ),
          ],
        ),
      );
    }

    final data = regionData;
    if (data == null) {
      return GlassPanel(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Text(l10n.riskDataLoading, style: GoogleFonts.ibmPlexSans(fontSize: 14, color: secondaryTextColor)),
      );
    }

    final score = data['general_risk_score'] as int;
    final level = data['risk_level'] as String;
    final color = colorForApiRiskLevel(level);
    final temp = double.tryParse(data['temperature'].toString()) ?? 0;
    final hum = double.tryParse(data['humidity'].toString()) ?? 0;
    final wind = double.tryParse(data['wind_speed'].toString()) ?? 0;
    final dryness = double.tryParse(data['dryness_index'].toString()) ?? 0;
    final vegetation = double.tryParse(data['vegetation_density'].toString()) ?? 0;

    final sorted = [...regions]..sort((a, b) => (b['general_risk_score'] as int).compareTo(a['general_risk_score'] as int));
    final rank = sorted.indexWhere((r) => r['region'] == data['region']) + 1;
    final diff = score - avgRiskScore;
    final diffStr = diff > 0 ? '+$diff' : '$diff';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius),
          onTap: onTapRegion,
          child: GlassPanel(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.riskMyLocationYourRegion(city ?? '', displayRegionName(l10n, data['region'])),
                        style: GoogleFonts.ibmPlexSans(fontSize: 20, fontWeight: FontWeight.w800, color: titleColor),
                      ),
                    ),
                    StatusChip(label: riskLevelLabel(l10n, level), icon: Icons.warning_amber_rounded, color: color),
                  ],
                ),
                if (distanceKm != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.satellite_alt_rounded, size: 13, color: secondaryTextColor),
                      const SizedBox(width: 4),
                      Text(
                        l10n.riskMyLocationPostgisDistance(distanceKm!.toStringAsFixed(1)),
                        style: GoogleFonts.ibmPlexSans(fontSize: 12, color: secondaryTextColor),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                Text(l10n.riskScoreOutOf100(score),
                    style: GoogleFonts.ibmPlexSans(fontSize: 15, fontWeight: FontWeight.w700, color: color)),
                const SizedBox(height: 4),
                Text(l10n.riskMyLocationRankLabel(rank),
                    style: GoogleFonts.ibmPlexSans(fontSize: 13, color: secondaryTextColor)),
                const SizedBox(height: 4),
                Text(l10n.riskMyLocationVsAverage(diffStr),
                    style: GoogleFonts.ibmPlexSans(fontSize: 13, color: secondaryTextColor)),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 380.ms).scale(begin: const Offset(0.98, 0.98), end: const Offset(1, 1)),

        const SizedBox(height: AppSpacing.xxl),

        SectionHeader(
          title: l10n.riskMyLocationMetricsTitle,
          subtitle: city ?? '',
          icon: const Icon(Icons.dashboard_rounded),
        ),
        const SizedBox(height: AppSpacing.md),

        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.15,
          children: [
            _RiskMetricCard(
              title: l10n.riskGeneralRisk,
              value: '$score',
              subtitle: l10n.riskOutOf100,
              icon: Icons.local_fire_department_rounded,
              accent: color,
              delay: const Duration(milliseconds: 100),
            ),
            _RiskMetricCard(
              title: l10n.commonWind,
              value: '${wind.toInt()} km/h',
              subtitle: wind >= 30 ? l10n.riskWindIncreasesSpread : l10n.riskWindNormal,
              icon: Icons.air_rounded,
              accent: AppColors.warning,
              delay: const Duration(milliseconds: 160),
            ),
            _RiskMetricCard(
              title: l10n.riskHumidity,
              value: '%${hum.toInt()}',
              subtitle: hum <= 30 ? l10n.riskHumidityLow : hum <= 50 ? l10n.riskHumidityMedium : l10n.riskHumidityHigh,
              icon: Icons.water_drop_outlined,
              accent: AppColors.primary,
              delay: const Duration(milliseconds: 220),
            ),
            _RiskMetricCard(
              title: l10n.commonTemperature,
              value: '${temp.toInt()}°C',
              subtitle: temp >= 35 ? l10n.riskTempCritical : temp >= 25 ? l10n.commonHigh : l10n.riskTempNormal,
              icon: Icons.thermostat_rounded,
              accent: temp >= 35 ? AppColors.danger : AppColors.warning,
              delay: const Duration(milliseconds: 280),
            ),
            _RiskMetricCard(
              title: l10n.riskDrynessIndex,
              value: '${dryness.toInt()}',
              subtitle: dryness >= 70 ? l10n.riskDrynessVeryHigh : dryness >= 50 ? l10n.commonHigh : l10n.commonMedium,
              icon: Icons.grain_rounded,
              accent: AppColors.danger,
              delay: const Duration(milliseconds: 340),
            ),
            _RiskMetricCard(
              title: l10n.riskVegetationDensity,
              value: '${vegetation.toInt()}',
              subtitle: vegetation >= 60 ? l10n.riskVegetationMediumHigh : l10n.commonMedium,
              icon: Icons.eco_outlined,
              accent: AppColors.primary,
              delay: const Duration(milliseconds: 400),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.xxl),

        SectionHeader(
          title: l10n.riskComparisonTitle,
          subtitle: l10n.riskTurkeyAverage,
          icon: const Icon(Icons.compare_arrows_rounded),
        ),
        const SizedBox(height: AppSpacing.md),

        GlassPanel(
          child: Column(
            children: [
              _ComparisonRow(
                icon: Icons.local_fire_department_rounded,
                label: l10n.riskGeneralRisk,
                regionValue: score.toDouble(),
                avgValue: avgRiskScore.toDouble(),
                unit: '',
                invertedRisk: false,
              ),
              const Divider(height: AppSpacing.xl),
              _ComparisonRow(
                icon: Icons.thermostat_rounded,
                label: l10n.commonTemperature,
                regionValue: temp,
                avgValue: avgTemp,
                unit: '°C',
                invertedRisk: false,
              ),
              const Divider(height: AppSpacing.xl),
              _ComparisonRow(
                icon: Icons.water_drop_outlined,
                label: l10n.riskHumidity,
                regionValue: hum,
                avgValue: avgHumidity,
                unit: '%',
                invertedRisk: true,
              ),
              const Divider(height: AppSpacing.xl),
              _ComparisonRow(
                icon: Icons.air_rounded,
                label: l10n.commonWind,
                regionValue: wind,
                avgValue: avgWind,
                unit: 'km/h',
                invertedRisk: false,
              ),
              const Divider(height: AppSpacing.xl),
              _ComparisonRow(
                icon: Icons.grain_rounded,
                label: l10n.riskDrynessIndex,
                regionValue: dryness,
                avgValue: avgDryness,
                unit: '',
                invertedRisk: false,
              ),
              const Divider(height: AppSpacing.xl),
              _ComparisonRow(
                icon: Icons.eco_outlined,
                label: l10n.riskVegetationDensity,
                regionValue: vegetation,
                avgValue: avgVegetation,
                unit: '',
                invertedRisk: false,
              ),
            ],
          ),
        ).animate(delay: 120.ms).fadeIn(duration: 320.ms).slideY(begin: 0.06, end: 0),
      ],
    );
  }

}

class _ComparisonRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double regionValue;
  final double avgValue;
  final String unit;
  /// True when a lower value means higher risk (e.g. humidity).
  final bool invertedRisk;

  const _ComparisonRow({
    required this.icon,
    required this.label,
    required this.regionValue,
    required this.avgValue,
    required this.unit,
    required this.invertedRisk,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = Theme.of(context).textTheme.titleMedium?.color ??
        (isDark ? AppColors.white : const Color(0xFF0F172A));
    final mutedColor = isDark ? AppColors.white.withValues(alpha: 0.58) : Colors.black.withValues(alpha: 0.5);

    final diff = regionValue - avgValue;
    final isSimilar = diff.abs() < 0.5;
    final isHigherRisk = invertedRisk ? diff < 0 : diff > 0;
    final arrowIcon = isSimilar
        ? Icons.remove_rounded
        : diff > 0
            ? Icons.arrow_upward_rounded
            : Icons.arrow_downward_rounded;
    final riskLabel = isSimilar
        ? l10n.riskComparisonSimilar
        : isHigherRisk
            ? l10n.riskComparisonHigherRisk
            : l10n.riskComparisonLowerRisk;
    final riskColor = isSimilar ? mutedColor : (isHigherRisk ? AppColors.danger : AppColors.success);

    String fmt(double v) => unit == '%' ? '%${v.toInt()}' : '${v.toInt()}$unit';

    return Row(
      children: [
        Icon(icon, size: 18, color: mutedColor),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          flex: 2,
          child: Text(label, style: GoogleFonts.ibmPlexSans(fontSize: 13, fontWeight: FontWeight.w700, color: titleColor)),
        ),
        Expanded(
          flex: 3,
          child: Text(
            '${fmt(regionValue)} vs ${fmt(avgValue)}',
            textAlign: TextAlign.right,
            style: AppTheme.mono(size: 12, color: mutedColor),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Icon(arrowIcon, size: 16, color: riskColor),
        const SizedBox(width: 2),
        Text(riskLabel, style: GoogleFonts.ibmPlexSans(fontSize: 11, fontWeight: FontWeight.w700, color: riskColor)),
      ],
    );
  }
}

class _DetailMetricRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DetailMetricRow({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: AppSpacing.sm),
        Text('$label: ', style: GoogleFonts.ibmPlexSans(fontSize: 13, color: color)),
        // Weather readouts are mono with tabular figures so the digits hold
        // their width between refreshes.
        Expanded(child: Text(value, style: AppTheme.mono(size: 13, weight: FontWeight.w600, color: color))),
      ],
    );
  }
}

class _RiskMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final Duration delay;

  const _RiskMetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accent,
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final valueColor = Theme.of(context).textTheme.titleLarge?.color ??
        (isDark ? AppColors.white : const Color(0xFF0F172A));
    final titleColor = Theme.of(context).textTheme.titleMedium?.color ??
        (isDark ? AppColors.white : const Color(0xFF0F172A));
    final subtitleColor = isDark
        ? AppColors.white.withValues(alpha: 0.58)
        : Colors.black.withValues(alpha: 0.5);

    return GlassPanel(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const Spacer(),
          Text(value,
              style: AppTheme.mono(size: 24, weight: FontWeight.w700, color: valueColor)),
          const SizedBox(height: AppSpacing.xs),
          Text(title,
              style: GoogleFonts.ibmPlexSans(fontSize: 14, fontWeight: FontWeight.w700, color: titleColor)),
          const SizedBox(height: 2),
          Text(subtitle,
              style: GoogleFonts.ibmPlexSans(fontSize: 12, color: subtitleColor)),
        ],
      ),
    ).animate(delay: delay).fadeIn(duration: 300.ms).slideY(begin: 0.12, end: 0).scale(
          begin: const Offset(0.97, 0.97),
          end: const Offset(1, 1),
        );
  }
}

class _RegionRiskCard extends StatelessWidget {
  final String region;
  final String risk;
  final String rawLevel;
  final int score;
  final String note;
  final Duration delay;

  const _RegionRiskCard({
    required this.region,
    required this.risk,
    required this.rawLevel,
    required this.score,
    required this.note,
    this.delay = Duration.zero,
  });

  Color get accent => colorForApiRiskLevel(rawLevel);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = Theme.of(context).textTheme.titleMedium?.color ??
        (isDark ? AppColors.white : const Color(0xFF0F172A));
    final noteColor = isDark
        ? AppColors.white.withValues(alpha: 0.58)
        : Colors.black.withValues(alpha: 0.5);

    return GlassPanel(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(region,
                    style: GoogleFonts.ibmPlexSans(fontSize: 16, fontWeight: FontWeight.w800, color: titleColor)),
              ),
              const SizedBox(width: AppSpacing.sm),
              StatusChip(label: risk, icon: Icons.warning_amber_rounded, color: accent),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 10,
              backgroundColor: isDark
                  ? AppColors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(l10n.riskScoreOutOf100(score),
              style: GoogleFonts.ibmPlexSans(fontSize: 13, fontWeight: FontWeight.w700, color: accent)),
          const SizedBox(height: 4),
          Text(note,
              style: GoogleFonts.ibmPlexSans(fontSize: 12, height: 1.35, color: noteColor)),
        ],
      ),
    ).animate(delay: delay).fadeIn(duration: 280.ms).slideX(begin: 0.03, end: 0).scale(
          begin: const Offset(0.98, 0.98),
          end: const Offset(1, 1),
        );
  }
}

class _ProgressFactorCard extends StatelessWidget {
  final String title;
  final double value;
  final String label;
  final Color color;
  final Duration delay;

  const _ProgressFactorCard({
    required this.title,
    required this.value,
    required this.label,
    required this.color,
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = Theme.of(context).textTheme.titleMedium?.color ??
        (isDark ? AppColors.white : const Color(0xFF0F172A));
    final labelColor = isDark
        ? AppColors.white.withValues(alpha: 0.62)
        : Colors.black.withValues(alpha: 0.56);

    return GlassPanel(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title,
                    style: GoogleFonts.ibmPlexSans(fontSize: 15, fontWeight: FontWeight.w800, color: titleColor)),
              ),
              Text('${(value * 100).toInt()}%',
                  style: AppTheme.mono(size: 14, weight: FontWeight.w700, color: color)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 10,
              backgroundColor: isDark
                  ? AppColors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(label, style: GoogleFonts.ibmPlexSans(fontSize: 13, color: labelColor)),
        ],
      ),
    ).animate(delay: delay).fadeIn(duration: 280.ms).slideY(begin: 0.12, end: 0).scale(
          begin: const Offset(0.98, 0.98),
          end: const Offset(1, 1),
        );
  }
}
