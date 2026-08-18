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
import '../../core/theme/app_theme.dart';
import '../../core/utils/loading_race.dart';
import '../../core/utils/news_content_analysis.dart';
import '../../core/utils/risk_display.dart';
import '../../l10n/app_localizations.dart';
import '../../models/fire_incident.dart';
import '../../models/fire_point.dart';
import '../../models/incident_summary.dart';
import '../../models/news_item.dart';
import '../../services/fire_api_service.dart';
import '../../services/fire_mapper.dart';
import '../../services/news_service.dart';
import '../../services/render_api_service.dart';
import '../../services/news_translation_service.dart';
import '../../services/offline_cache_service.dart';
import '../../services/watchlist_provider.dart';
import '../../shared/coach_mark_keys.dart';
import '../../shared/widgets/glass_panel.dart';
import '../../shared/widgets/info_icon_button.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/skeleton_loader.dart';
import '../../shared/widgets/slow_loading_banner.dart';
import '../../shared/widgets/smart_overview_card.dart';
import '../../shared/widgets/state_views.dart';
import '../../shared/widgets/status_chip.dart';
import '../../shared/widgets/trust_info_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const _newsCacheKey = 'home_news';
  static const _firesCacheKey = 'home_fires';
  static const _riskCacheKey = 'home_risk';

  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
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
  List<Map<String, dynamic>> _regions = [];
  Position? _userPosition;
  String? _myCity;
  double? _myDistanceKm;
  _LocationStatus _locationStatus = _LocationStatus.pending;
  // Canonical (non-localized) quick filter: 'high' | 'medium' | 'ege' | 'akdeniz' | 'marmara' | 'karadeniz'
  String? _quickFilter;
  bool _newsLoading = true;
  bool _fireLoading = true;
  bool _riskLoading = true;
  bool _newsSlowLoading = false;
  bool _firesSlowLoading = false;

  final RenderApiService _renderApi = RenderApiService();
  IncidentSummary? _incidentSummary;
  bool _incidentSummaryLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadUserPosition();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadNews(),
      _loadFires(),
      _loadRiskSummary(),
      _loadIncidentSummary(),
    ]);
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

  /// Turns a duration in hours into something a person reads at a glance.
  /// Deliberately coarse — the satellite fixes the resolution at a few passes
  /// a day, so minutes would be false precision.
  String _formatDuration(AppLocalizations l10n, double hours) {
    final total = hours.round();
    if (total < 24) return l10n.durationHoursShort(total);
    return l10n.durationDaysHours(total ~/ 24, total % 24);
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
          childAspectRatio: 0.86,
          children: [
            SmartOverviewCard(
              title: l10n.homeLast24hActiveTitle,
              value: summary.activeCount.toString(),
              // Two layers on purpose. The raw count grows through the fire
              // season and reads as a fire count, but most of it is single
              // fresh pixels that have not had a second overpass yet. The
              // map still shows all of them — asymmetric caution holds
              // there — but a headline number is a different claim.
              subtitle: l10n.homeLast24hActiveSubtitleLayered(
                summary.activeSignificantCount,
                summary.recentDetectionHours,
              ),
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
              subtitle: l10n.homeLast24hEndedSubtitle,
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
            value: [
              if (strongestCity != null && strongestCity.isNotEmpty)
                strongestCity,
              l10n.homeLast24hStrongestPower(
                summary.strongestActiveMaxFrpMw!.round(),
              ),
            ].join(' · '),
            // Duration goes in the subtitle as a floor, never as a headline.
            subtitle: summary.strongestActiveDurationHoursAtLeast == null
                ? l10n.homeLast24hStrongestSubtitle
                : l10n.homeLast24hStrongestSubtitleWithDuration(
                    _formatDuration(
                      l10n,
                      summary.strongestActiveDurationHoursAtLeast!,
                    ),
                  ),
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

  // Stock Android emulator AVDs used for local testing report a fixed mock
  // GPS fix (İzmir) rather than a real location. Flagging it explicitly
  // stops testers from mistaking "the emulator's hardcoded fix" for "the
  // real-device city lookup is broken".
  static const double _emulatorTestLat = 38.42;
  static const double _emulatorTestLng = 27.14;

  // Same bounding box used to decide whether a resolved location should
  // attempt a Turkish city lookup at all.
  static bool _isInsideTurkeyBbox(double lat, double lng) =>
      lat >= 35.8 && lat <= 42.2 && lng >= 25.6 && lng <= 44.8;

  /// Best-effort location fetch for the "Nearby Fire Alert" overview card —
  /// silently falls back to the region-wide count on failure, but still
  /// records _locationStatus so the header can show why (unavailable vs.
  /// outside Turkey vs. emulator test fix) instead of just hiding the row.
  Future<void> _loadUserPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() => _locationStatus = _LocationStatus.unavailable);
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        if (mounted) setState(() => _locationStatus = _LocationStatus.unavailable);
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low, timeLimit: Duration(seconds: 8)),
      );
      if (!mounted) return;
      debugPrint('[Location] Fresh GPS fix: lat=${position.latitude}, lng=${position.longitude}');
      setState(() => _userPosition = position);

      final isEmulatorTestLocation =
          (position.latitude - _emulatorTestLat).abs() < 0.01 &&
          (position.longitude - _emulatorTestLng).abs() < 0.01;
      if (isEmulatorTestLocation) {
        debugPrint('[Location] Matches known emulator test fix (İzmir) — not a real device location.');
        setState(() {
          _locationStatus = _LocationStatus.emulatorTest;
          _myCity = null;
          _myDistanceKm = null;
        });
        return;
      }

      if (!_isInsideTurkeyBbox(position.latitude, position.longitude)) {
        setState(() {
          _locationStatus = _LocationStatus.outsideTurkey;
          _myCity = null;
          _myDistanceKm = null;
        });
        return;
      }

      final cityInfo = await _fireApiService.getNearestCity(position.latitude, position.longitude);
      if (!mounted) return;
      setState(() {
        if (cityInfo.outsideTurkey) {
          _locationStatus = _LocationStatus.outsideTurkey;
          _myCity = null;
          _myDistanceKm = null;
        } else {
          _locationStatus = _LocationStatus.resolved;
          _myCity = cityInfo.city;
          _myDistanceKm = cityInfo.distanceKm;
        }
      });
    } catch (_) {
      // No location — nearby-fire card falls back to the Turkey-wide count.
      if (mounted) setState(() => _locationStatus = _LocationStatus.unavailable);
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
    if (mounted) setState(() { _newsLoading = true; _newsSlowLoading = false; });
    try {
      final news = await raceWithCacheFallback(
        fetch: retryOnce(() => _newsService.fetchNewsFromRender(limit: 3)),
        timeout: const Duration(seconds: 12),
        cacheKey: _newsCacheKey,
        onSlowFallback: (cached) {
          if (!mounted) return;
          final (data, _) = cached;
          setState(() {
            _topNews = (data as List).map((e) => NewsItem.fromJson(e as Map<String, dynamic>)).toList();
            _newsSlowLoading = true;
            _newsLoading = false;
          });
        },
      );
      await OfflineCacheService.instance.save(_newsCacheKey, news.map((n) => n.toJson()).toList());
      if (mounted) setState(() { _topNews = news; _newsLoading = false; _newsSlowLoading = false; });
    } catch (e, stack) {
      if (kDebugMode) debugPrint('ERROR _loadNews: $e\n$stack');
      final cached = await OfflineCacheService.instance.load(_newsCacheKey);
      if (mounted) {
        setState(() {
          if (cached != null) {
            final (data, _) = cached;
            _topNews = (data as List).map((e) => NewsItem.fromJson(e as Map<String, dynamic>)).toList();
          }
          _newsSlowLoading = false;
          _newsLoading = false;
        });
      }
    }
  }

  Future<void> _loadFires() async {
    if (mounted) setState(() { _fireLoading = true; _firesSlowLoading = false; });
    try {
      final allPoints = await raceWithCacheFallback(
        fetch: retryOnce(() => _fireApiService.fetchTurkeyFiresWithCities()),
        timeout: const Duration(seconds: 12),
        cacheKey: _firesCacheKey,
        onSlowFallback: (cached) {
          if (!mounted) return;
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

  bool _matchesQuickFilter(FirePoint p) {
    final filter = _quickFilter;
    if (filter == null) return true;
    if (filter == 'high' || filter == 'medium') return p.riskTier == filter;
    // Region filters: match the canonical bbox key, or the raw backend
    // city/region text (proper nouns, same in every locale).
    if (p.regionKey == filter) return true;
    final nr = p.nearestRegion?.toLowerCase();
    if (nr != null && nr.contains(filter)) return true;
    final cn = p.cityName?.toLowerCase();
    if (cn != null && cn.contains(filter)) return true;
    return false;
  }

  void _showFirePreview(BuildContext context, FirePoint point) {
    final l10n = AppLocalizations.of(context)!;
    final bright = double.tryParse(point.brightness) ?? 0;
    final tempC = bright > 200 ? (bright - 273.15).toStringAsFixed(0) : bright.toStringAsFixed(0);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final titleColor = theme.textTheme.titleLarge?.color ??
        (isDark ? AppColors.white : const Color(0xFF0F172A));
    final secondaryTextColor = isDark
        ? AppColors.white.withValues(alpha: 0.74)
        : Colors.black.withValues(alpha: 0.66);

    String alanTahmini;
    if (bright >= 370) {
      alanTahmini = l10n.homeAreaOver100Ha;
    } else if (bright >= 330) {
      alanTahmini = l10n.homeArea10to100Ha;
    } else if (bright >= 300) {
      alanTahmini = l10n.homeAreaUnder10Ha;
    } else {
      alanTahmini = l10n.homeAreaInsufficientRes;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
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
                    label: fireStatusLabel(l10n, point.smartStatus),
                    showDot: true,
                    color: fireStatusColor(point.smartStatus),
                  ),
                  InfoIconButton(
                    title: l10n.tooltipConfidenceTitle,
                    bodyLines: [l10n.smartConfidenceHigh, l10n.smartConfidenceMedium, l10n.smartConfidenceLow],
                  ),
                  StatusChip(label: '${point.formattedDate} ${point.formattedTime}', icon: Icons.access_time_rounded),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.homeFireRegionTitle(point.regionDisplayName(l10n)),
                style: GoogleFonts.ibmPlexSans(fontSize: 22, fontWeight: FontWeight.w800, color: titleColor),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                point.riskReasonText(l10n),
                style: GoogleFonts.ibmPlexSans(fontSize: 14, height: 1.45, color: secondaryTextColor),
              ),
              const SizedBox(height: AppSpacing.lg),
              _PreviewRow(
                icon: Icons.thermostat_rounded,
                label: l10n.commonTemperature,
                value: '$tempC°C (${bright.toStringAsFixed(0)}K)',
                info: InfoIconButton(title: l10n.tooltipTempTitle, bodyLines: [l10n.tooltipTempBody]),
              ),
              const SizedBox(height: 8),
              _PreviewRow(icon: Icons.area_chart_rounded, label: l10n.homeEstimatedArea, value: alanTahmini),
              const SizedBox(height: 8),
              _PreviewRow(
                icon: Icons.satellite_alt_rounded,
                label: l10n.commonSatellite,
                value: point.mergedSatelliteLabel,
                valueColor: point.isMerged ? AppColors.success : null,
                info: InfoIconButton(
                  title: l10n.tooltipSatelliteTitle,
                  bodyLines: point.isMerged
                      ? [l10n.tooltipSatelliteViirsBody, l10n.tooltipSatelliteModisBody, l10n.tooltipSatelliteMergedBody]
                      : [l10n.tooltipSatelliteViirsBody, l10n.tooltipSatelliteModisBody],
                ),
              ),
              const SizedBox(height: 8),
              _PreviewRow(icon: Icons.location_on_rounded, label: l10n.commonCoordinate, value: point.locationLabelText(l10n)),
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
                      label: Text(l10n.commonDetail),
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
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryTextColor = theme.textTheme.titleLarge?.color ??
        (isDark ? AppColors.white : const Color(0xFF0F172A));
    final secondaryTextColor = isDark
        ? AppColors.white.withValues(alpha: 0.75)
        : Colors.black.withValues(alpha: 0.68);
    final tertiaryTextColor = isDark
        ? AppColors.white.withValues(alpha: 0.62)
        : Colors.black.withValues(alpha: 0.5);

    final savedIds = ref.watch(watchlistProvider);
    final query = _searchController.text.trim().toLowerCase();

    // ── Overview card 1: active (non-low-confidence) fire points ──
    // Uses FirePoint.riskTier (not a local confidence parse) so it handles
    // both VIIRS text confidence ("high"/"nominal") and MODIS numeric
    // confidence (e.g. "79") the same way markers/badges do elsewhere.
    final activeFireCount = _firePoints.where((p) => p.riskTier != 'low').length;
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
        : colorForApiRiskLevel(highestRiskRegion['risk_level'] as String);

    // ── Overview card 3: fires within 100km, falling back to the
    // nationwide count when location isn't available ──
    final position = _userPosition;
    final nearbyCount = position == null
        ? null
        : _firePoints.where((p) {
            final distanceMeters = Geolocator.distanceBetween(
              position.latitude, position.longitude, p.latitude, p.longitude);
            return distanceMeters <= 100000;
          }).length;
    final nearbyDisplayCount = nearbyCount ?? _firePoints.length;
    final nearbyColor = nearbyDisplayCount > 0 ? AppColors.danger : AppColors.success;

    // ── Overview card 4: news freshness ──
    String newsTimeAgo = l10n.homeOverviewNewsNone;
    if (_topNews.isNotEmpty) {
      final published = DateTime.tryParse(_topNews.first.publishedAt);
      if (published != null) {
        final diff = DateTime.now().toUtc().difference(published.toUtc());
        if (diff.inMinutes < 1) {
          newsTimeAgo = l10n.timeAgoJustNow;
        } else if (diff.inMinutes < 60) {
          newsTimeAgo = l10n.timeAgoMinutes(diff.inMinutes);
        } else if (diff.inHours < 24) {
          newsTimeAgo = l10n.timeAgoHours(diff.inHours);
        } else {
          newsTimeAgo = l10n.timeAgoDays(diff.inDays);
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName, style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _loadData),
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
            if (_firesSlowLoading) const SlowLoadingBanner(),
            // ── Header ──────────────────────────────────────
            GlassPanel(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatusChip(label: l10n.homeLiveSummary, icon: Icons.bolt_rounded),
                  const SizedBox(height: AppSpacing.lg),
                  Text(l10n.homeHeaderTitle,
                      style: GoogleFonts.ibmPlexSans(fontSize: 30, fontWeight: FontWeight.w800, color: primaryTextColor)),
                  const SizedBox(height: AppSpacing.sm),
                  Text(l10n.homeHeaderSubtitle,
                      style: GoogleFonts.ibmPlexSans(fontSize: 16, height: 1.45, color: secondaryTextColor)),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 18, color: tertiaryTextColor),
                      const SizedBox(width: AppSpacing.sm),
                      Text(l10n.homeNasaLiveData,
                          style: GoogleFonts.ibmPlexSans(fontSize: 14, color: tertiaryTextColor)),
                    ],
                  ),
                  if (_locationStatus != _LocationStatus.pending) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Icon(
                          switch (_locationStatus) {
                            _LocationStatus.outsideTurkey => Icons.public_off_rounded,
                            _LocationStatus.unavailable => Icons.location_off_rounded,
                            _LocationStatus.emulatorTest => Icons.phone_android_rounded,
                            _LocationStatus.resolved || _LocationStatus.pending => Icons.location_on_rounded,
                          },
                          size: 18,
                          color: tertiaryTextColor,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            switch (_locationStatus) {
                              _LocationStatus.outsideTurkey => l10n.homeOutsideTurkeyLocation,
                              _LocationStatus.unavailable => l10n.homeLocationUnavailable,
                              _LocationStatus.emulatorTest => l10n.homeLocationEmulatorTest,
                              _LocationStatus.resolved || _LocationStatus.pending => _myCity ?? '',
                            },
                            style: GoogleFonts.ibmPlexSans(fontSize: 14, fontWeight: FontWeight.w700, color: primaryTextColor),
                          ),
                        ),
                      ],
                    ),
                    if (_locationStatus == _LocationStatus.resolved && _myDistanceKm != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 26, top: 2),
                        child: Text(
                          l10n.riskMyLocationPostgisDistance(_myDistanceKm!.toStringAsFixed(1)),
                          style: GoogleFonts.ibmPlexSans(fontSize: 12, color: tertiaryTextColor),
                        ),
                      ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          key: CoachMarkKeys.riskButton,
                          onPressed: () => context.push('/risk'),
                          icon: const Icon(Icons.auto_graph_rounded),
                          label: Text(l10n.homeRiskAnalysis),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: OutlinedButton.icon(
                          key: CoachMarkKeys.savedButton,
                          onPressed: () => context.push('/watchlist'),
                          icon: const Icon(Icons.bookmark_rounded),
                          label: Text(l10n.homeSaved(savedIds.length)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.push('/safety-guide'),
                          icon: const Icon(Icons.shield_outlined),
                          label: Text(l10n.homeSafety),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.push('/emergency'),
                          icon: const Icon(Icons.emergency_rounded),
                          label: Text(l10n.commonEmergency),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms).scale(
                  begin: const Offset(0.96, 0.96),
                  end: const Offset(1, 1),
                  curve: Curves.easeOutCubic,
                ).slideY(begin: 0.08, end: 0),

            const SizedBox(height: AppSpacing.md),
            TrustInfoCardGroup(
              meaning: l10n.trustHomeMeaning,
              source: l10n.trustHomeSource,
              interpret: l10n.trustHomeInterpret,
              action: l10n.trustHomeAction,
            ),

            const SizedBox(height: AppSpacing.xxl),

            // ── Genel Bakış ──────────────────────────────────
            SectionHeader(
              title: l10n.homeOverview,
              subtitle: _fireLoading ? l10n.homeOverviewSubtitle : l10n.homeOverviewUniqueCount(_firePoints.length),
              icon: const Icon(Icons.dashboard_customize_rounded),
            ),
            const SizedBox(height: AppSpacing.md),

            if (_fireLoading || _riskLoading || _newsLoading)
              const SkeletonMetricGrid(count: 4)
            else
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: 0.86,
                children: [
                  SmartOverviewCard(
                    title: l10n.homeOverviewActiveFiresTitle,
                    value: activeFireCount.toString(),
                    subtitle: l10n.homeOverviewActiveFiresSubtitle,
                    icon: Icons.local_fire_department_rounded,
                    color: activeFireColor,
                    delay: 0.ms,
                    onTap: () => context.go('/map', extra: {'confidenceFilter': true}),
                  ),
                  SmartOverviewCard(
                    title: l10n.homeOverviewHighestRiskTitle,
                    value: highestRiskRegion == null
                        ? l10n.riskDataLoading
                        : l10n.homeOverviewHighestRiskValue(
                            displayRegionName(l10n, highestRiskRegion['region'] as String),
                            highestRiskRegion['general_risk_score'] as int,
                          ),
                    subtitle: l10n.homeOverviewHighestRiskSubtitle,
                    icon: Icons.warning_amber_rounded,
                    color: highestRiskColor,
                    delay: 60.ms,
                    onTap: highestRiskRegion == null
                        ? null
                        : () => context.push('/risk', extra: highestRiskRegion!['region'] as String),
                  ),
                  SmartOverviewCard(
                    title: l10n.homeOverviewNearbyTitle,
                    value: nearbyCount != null
                        ? l10n.homeOverviewNearbyValueWithLocation(nearbyCount)
                        : l10n.homeOverviewNearbyValueNationwide(nearbyDisplayCount),
                    subtitle: nearbyCount != null
                        ? l10n.homeOverviewNearbySubtitleLocated
                        : l10n.homeOverviewNearbySubtitleFallback,
                    icon: Icons.location_on_rounded,
                    color: nearbyColor,
                    delay: 120.ms,
                    onTap: position == null
                        ? () => context.go('/map')
                        : () => context.go('/map', extra: {'lat': position.latitude, 'lng': position.longitude}),
                  ),
                  SmartOverviewCard(
                    title: l10n.homeOverviewNewsTitle,
                    value: l10n.homeOverviewNewsValue(_topNews.length),
                    subtitle: l10n.homeOverviewNewsSubtitleUpdated(newsTimeAgo),
                    icon: Icons.newspaper_rounded,
                    color: AppColors.primary,
                    delay: 180.ms,
                    onTap: () => context.go('/app?tab=news'),
                  ),
                ],
              ),

            // ── Son 24 Saat ──────────────────────────────────
            if (_incidentSummaryLoading || _incidentSummary != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              SectionHeader(
                title: l10n.homeLast24hTitle,
                subtitle: l10n.homeLast24hSubtitle,
                icon: const Icon(Icons.history_rounded),
              ),
              const SizedBox(height: AppSpacing.md),
              if (_incidentSummaryLoading)
                const SkeletonMetricGrid(count: 2)
              else
                _buildLast24hSection(l10n, _incidentSummary!),
            ],

            const SizedBox(height: AppSpacing.xxxl),

            // ── Son Haberler ─────────────────────────────────
            SectionHeader(
              title: l10n.homeLatestNews,
              subtitle: l10n.homeLatestNewsSubtitle,
              icon: const Icon(Icons.newspaper_rounded),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt_rounded, size: 16, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Text(l10n.homeBreakingCount(_topNews.where((e) => e.isBreaking).length),
                        style: GoogleFonts.ibmPlexSans(color: AppColors.primary, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            if (_newsSlowLoading) const SlowLoadingBanner(),
            if (_newsLoading)
              const SkeletonListLoader(count: 2)
            else if (_topNews.isEmpty)
              EmptyStateView(
                icon: Icons.newspaper_outlined,
                title: l10n.emptyStateGenericTitle,
                subtitle: l10n.emptyStateGenericSubtitle,
              )
            else
              ..._topNews.asMap().entries.map((entry) {
                final index = entry.key;
                final NewsItem item = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _HomeNewsPreviewCard(
                    item: item,
                    onTap: () => context.push('/news-detail', extra: item),
                  ).animate()
                      .fadeIn(duration: 300.ms, delay: (100 + (index * 70)).ms)
                      .slideX(begin: 0.03, end: 0)
                      .scale(begin: const Offset(0.98, 0.98), end: const Offset(1, 1)),
                );
              }),

            const SizedBox(height: AppSpacing.xxxl),

            // ── Aktif Termal Noktalar ─────────────────────────
            SectionHeader(
              title: l10n.homeActiveThermalPoints,
              subtitle: l10n.homeActiveThermalSubtitle,
              icon: const FaIcon(FontAwesomeIcons.fireFlameCurved),
              trailing: SizedBox(
                height: 48,
                child: InkWell(
                  onTap: () => context.go('/map'),
                  borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.map_rounded, size: 16, color: AppColors.primary),
                          const SizedBox(width: AppSpacing.sm),
                          Text(l10n.homeMap, style: GoogleFonts.ibmPlexSans(color: AppColors.primary, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Filtre chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(label: l10n.commonAll, selected: _quickFilter == null && query.isEmpty, onTap: () { _searchDebounce?.cancel(); _searchController.clear(); setState(() => _quickFilter = null); }),
                  const SizedBox(width: 8),
                  _FilterChip(label: l10n.homeFilterHighRisk, selected: _quickFilter == 'high', onTap: () { setState(() => _quickFilter = _quickFilter == 'high' ? null : 'high'); }),
                  const SizedBox(width: 8),
                  _FilterChip(label: l10n.homeFilterMediumRisk, selected: _quickFilter == 'medium', onTap: () { setState(() => _quickFilter = _quickFilter == 'medium' ? null : 'medium'); }),
                  const SizedBox(width: 8),
                  _FilterChip(label: l10n.regionEge, selected: _quickFilter == 'ege', onTap: () { setState(() => _quickFilter = _quickFilter == 'ege' ? null : 'ege'); }),
                  const SizedBox(width: 8),
                  _FilterChip(label: l10n.regionAkdeniz, selected: _quickFilter == 'akdeniz', onTap: () { setState(() => _quickFilter = _quickFilter == 'akdeniz' ? null : 'akdeniz'); }),
                  const SizedBox(width: 8),
                  _FilterChip(label: l10n.regionMarmara, selected: _quickFilter == 'marmara', onTap: () { setState(() => _quickFilter = _quickFilter == 'marmara' ? null : 'marmara'); }),
                  const SizedBox(width: 8),
                  _FilterChip(label: l10n.regionKaradeniz, selected: _quickFilter == 'karadeniz', onTap: () { setState(() => _quickFilter = _quickFilter == 'karadeniz' ? null : 'karadeniz'); }),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            GlassPanel(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => _onSearchChanged(),
                decoration: InputDecoration(
                  hintText: l10n.homeSearchHint,
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: query.isNotEmpty
                      ? IconButton(onPressed: () { _searchDebounce?.cancel(); _searchController.clear(); setState(() {}); }, icon: const Icon(Icons.close_rounded))
                      : null,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            if (_fireLoading)
              const SkeletonListLoader(count: 3)
            else if (_firePoints.isEmpty)
              EmptyStateView(
                icon: Icons.local_fire_department_outlined,
                title: l10n.homeNoActiveFires,
              )
            else
              ..._firePoints
                  .where((p) => _matchesQuickFilter(p) && (query.isEmpty ||
                      p.regionDisplayName(l10n).toLowerCase().contains(query) ||
                      (p.cityName?.toLowerCase().contains(query) ?? false) ||
                      (p.nearestRegion?.toLowerCase().contains(query) ?? false) ||
                      p.riskLevelLabel(l10n).toLowerCase().contains(query) ||
                      p.acquisitionDate.contains(query)))
                  .take(10)
                  .toList()
                  .asMap()
                  .entries
                  .map((entry) {
                final index = entry.key;
                final FirePoint point = entry.value;
                final bright = double.tryParse(point.brightness) ?? 0;
                final tempC = bright > 200 ? (bright - 273.15).toStringAsFixed(0) : bright.toStringAsFixed(0);

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: GlassPanel(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: InkWell(
                      onTap: () => _showFirePreview(context, point),
                      borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  point.regionDisplayName(l10n),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.ibmPlexSans(fontSize: 16, fontWeight: FontWeight.w800, color: primaryTextColor),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Flexible(
                                child: Wrap(
                                  spacing: AppSpacing.xs,
                                  runSpacing: AppSpacing.xs,
                                  alignment: WrapAlignment.end,
                                  children: [
                                    StatusChip(label: point.detectionTitle(l10n), icon: Icons.satellite_alt_rounded, color: point.detectionColor),
                                    StatusChip(
                                      label: fireStatusLabel(l10n, point.smartStatus),
                                      showDot: true,
                                      color: fireStatusColor(point.smartStatus),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            '${point.formattedDate} • ${point.formattedTime} UTC',
                            style: AppTheme.mono(size: 12, color: tertiaryTextColor),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            point.riskReasonText(l10n),
                            style: GoogleFonts.ibmPlexSans(fontSize: 13, height: 1.4, color: secondaryTextColor),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            children: [
                              Icon(Icons.thermostat_rounded, size: 13, color: tertiaryTextColor),
                              const SizedBox(width: 4),
                              Text('$tempC°C', style: AppTheme.mono(size: 12, color: tertiaryTextColor)),
                              const SizedBox(width: 12),
                              Icon(Icons.satellite_alt_rounded, size: 13, color: point.isMerged ? AppColors.success : tertiaryTextColor),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(point.mergedSatelliteLabel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.ibmPlexSans(
                                        fontSize: 12,
                                        fontWeight: point.isMerged ? FontWeight.w700 : FontWeight.normal,
                                        color: point.isMerged ? AppColors.success : tertiaryTextColor)),
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.primary),
                              Text(l10n.commonDetail, style: GoogleFonts.ibmPlexSans(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ).animate()
                      .fadeIn(duration: 320.ms, delay: (120 + (index * 70)).ms)
                      .slideX(begin: 0.03, end: 0)
                      .scale(begin: const Offset(0.98, 0.98), end: const Offset(1, 1), duration: 280.ms),
                );
              }),

            const SizedBox(height: 110),
          ],
        ),
        ),
      ),
    );
  }
}

/// Classifies the device's resolved GPS fix for display: still figuring it
/// out, no fix could be obtained at all, a fix outside Turkey, the fixed
/// mock-location Android emulators report, or a genuine resolved Turkish
/// city.
enum _LocationStatus { pending, unavailable, outsideTurkey, emulatorTest, resolved }

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 48,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(label,
                style: GoogleFonts.ibmPlexSans(fontSize: 13, fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppColors.primary)),
          ),
        ),
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? info;
  final Color? valueColor;

  const _PreviewRow({required this.icon, required this.label, required this.value, this.info, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark
        ? AppColors.white.withValues(alpha: 0.65)
        : Colors.black.withValues(alpha: 0.55);

    return Row(
      children: [
        Icon(icon, size: 16, color: valueColor ?? color),
        const SizedBox(width: 6),
        Text('$label: ', style: GoogleFonts.ibmPlexSans(fontSize: 13, color: color)),
        Expanded(
          // Readout values are mono with tabular figures so refreshing
          // digits (temperature, coordinates) never jitter.
          child: Text(value,
              style: AppTheme.mono(size: 13, weight: FontWeight.w600, color: valueColor ?? color),
              overflow: TextOverflow.ellipsis),
        ),
        ?info,
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
        (isDark ? AppColors.white : const Color(0xFF0F172A));
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
                    borderRadius: BorderRadius.circular(16),
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
                          if (item.isBreaking) StatusChip(label: l10n.newsBreakingBadge, icon: Icons.bolt_rounded),
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
