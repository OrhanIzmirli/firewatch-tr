import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/utils/loading_race.dart';
import '../../l10n/app_localizations.dart';
import '../../models/fire_point.dart';
import '../../services/fire_api_service.dart';
import '../../services/fire_mapper.dart';
import '../../services/offline_cache_service.dart';
import '../../shared/coach_mark_keys.dart';
import '../../shared/widgets/coach_mark_overlay.dart';
import '../../shared/widgets/glass_panel.dart';
import '../../shared/widgets/info_icon_button.dart';
import '../../shared/widgets/offline_banner.dart';
import '../../shared/widgets/report_fire_panel.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/slow_loading_banner.dart';
import '../../shared/widgets/status_chip.dart';
import '../../shared/widgets/trust_info_card.dart';

class MapScreen extends StatefulWidget {
  final double? focusLat;
  final double? focusLng;

  /// When true, only fires with 'high' or 'nominal' confidence are shown
  /// on the map — used when arriving from the Home screen's "Active Fire
  /// Points" overview card, which counts the same subset.
  final bool initialConfidenceFilter;

  const MapScreen({
    super.key,
    this.focusLat,
    this.focusLng,
    this.initialConfidenceFilter = false,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _cacheKey = 'map_fires';

  bool _isReportOpen = false;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isOffline = false;
  bool _isSlowLoading = false;
  bool _isLegendOpen = false;
  DateTime? _cachedAt;
  late bool _confidenceFilterActive = widget.initialConfidenceFilter;
  double _currentZoom = 5.6;

  List<FirePoint> _firePoints = [];
  List<FirePoint> _nearbyFirePoints = [];
  FirePoint? _selectedPoint;

  final MapController _mapController = MapController();
  final FireApiService _fireApiService = FireApiService();

  Position? _userPosition;

  @override
  void initState() {
    super.initState();
    if (widget.focusLat != null) _currentZoom = 13;
    _bootstrapMapData().then((_) => _maybeShowMapCoachMarks());
    if (widget.focusLat != null && widget.focusLng != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted)
            _mapController.move(LatLng(widget.focusLat!, widget.focusLng!), 13);
        });
      });
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _bootstrapMapData() async {
    await _loadUserLocation();
    await _loadFirePoints();
  }

  void _maybeShowMapCoachMarks() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      await maybeShowScreenCoachMarks(
        context,
        prefsKey: 'hasSeenMapTour',
        steps: [
          CoachMarkStep(
            targetKey: CoachMarkKeys.mapArea,
            title: l10n.coachMarkMapMarkersTitle,
            description: l10n.coachMarkMapMarkersDesc,
          ),
          CoachMarkStep(
            targetKey: CoachMarkKeys.mapArea,
            title: l10n.coachMarkMapClustersTitle,
            description: l10n.coachMarkMapClustersDesc,
          ),
          CoachMarkStep(
            targetKey: CoachMarkKeys.mapReportFab,
            title: l10n.coachMarkMapReportTitle,
            description: l10n.coachMarkMapReportDesc,
          ),
          CoachMarkStep(
            targetKey: CoachMarkKeys.mapNearbyFiresSection,
            title: l10n.coachMarkMapNearbyTitle,
            description: l10n.coachMarkMapNearbyDesc,
          ),
        ],
      );
    });
  }

  Future<void> _loadUserLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied)
        permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever)
        return;
      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() => _userPosition = position);
    } catch (_) {}
  }

  Future<void> _loadFirePoints() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isSlowLoading = false;
    });
    try {
      final firePoints = await raceWithCacheFallback(
        fetch: retryOnce(() => _fireApiService.fetchTurkeyFiresWithCities()),
        timeout: const Duration(seconds: 12),
        cacheKey: _cacheKey,
        onSlowFallback: (cached) {
          if (!mounted) return;
          final (data, savedAt) = cached;
          final points = (data as List)
              .map((e) => FirePoint.fromJson(e as Map<String, dynamic>))
              .toList();
          setState(() {
            _firePoints = points;
            _nearbyFirePoints = _buildNearbyList(points);
            _cachedAt = savedAt;
            _isSlowLoading = true;
            _isLoading = false;
          });
        },
      );
      final allPoints = _attachDistances(firePoints);
      final nearby = _buildNearbyList(allPoints);
      await OfflineCacheService.instance.save(
        _cacheKey,
        allPoints.map((p) => p.toJson()).toList(),
      );

      if (!mounted) return;
      setState(() {
        _firePoints = allPoints;
        _nearbyFirePoints = nearby;
        _isLoading = false;
        _isOffline = false;
        _isSlowLoading = false;
      });
    } catch (_) {
      final cached = await OfflineCacheService.instance.load(_cacheKey);
      if (!mounted) return;
      if (cached != null) {
        final (data, savedAt) = cached;
        final points = (data as List)
            .map((e) => FirePoint.fromJson(e as Map<String, dynamic>))
            .toList();
        setState(() {
          _firePoints = points;
          _nearbyFirePoints = _buildNearbyList(points);
          _cachedAt = savedAt;
          // Fresh cache (<30min) is shown silently; only stale cache
          // paired with a real fetch failure warrants the banner.
          _isOffline = !isCacheFresh(savedAt);
          _isSlowLoading = false;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = AppLocalizations.of(context)!.mapFetchError;
          _isSlowLoading = false;
          _isLoading = false;
        });
      }
    }
  }

  List<FirePoint> _attachDistances(List<FirePoint> points) {
    if (_userPosition == null) return points;
    return points.map((point) {
      final distanceMeters = Geolocator.distanceBetween(
        _userPosition!.latitude,
        _userPosition!.longitude,
        point.latitude,
        point.longitude,
      );
      return point.copyWith(distanceKm: distanceMeters / 1000);
    }).toList();
  }

  List<FirePoint> _buildNearbyList(List<FirePoint> points) {
    final sortable = [...points];
    sortable.sort(
      (a, b) => (a.distanceKm ?? 999999).compareTo(b.distanceKm ?? 999999),
    );
    return sortable.take(5).toList();
  }

  String _timeAgo(BuildContext context, String acqDate, String acqTime) {
    final l10n = AppLocalizations.of(context)!;
    try {
      final timeStr = acqTime.padLeft(4, '0');
      final hour = int.parse(timeStr.substring(0, 2));
      final minute = int.parse(timeStr.substring(2, 4));
      final dateParts = acqDate.split('-');
      if (dateParts.length != 3) return acqDate;
      final dt = DateTime.utc(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
        hour,
        minute,
      );
      final diff = DateTime.now().toUtc().difference(dt);
      if (diff.inMinutes < 60) return l10n.timeAgoMinutes(diff.inMinutes);
      if (diff.inHours < 24) return l10n.timeAgoHours(diff.inHours);
      return l10n.timeAgoDays(diff.inDays);
    } catch (_) {
      return '$acqDate $acqTime';
    }
  }

  void _openReportPanel() {
    setState(() => _isReportOpen = true);
    showReportFirePanel(context).then((_) {
      if (mounted) setState(() => _isReportOpen = false);
    });
  }

  /// Marker color by NASA confidence tier only — high: danger (red),
  /// nominal: warning (orange), low: primary — independent of
  /// FirePoint.detectionColor (which still drives the bottom sheet/cards
  /// elsewhere and is deliberately left alone).
  Color _markerColor(FirePoint point) {
    switch (point.riskTier) {
      case 'high':
        return AppColors.danger;
      case 'medium':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  /// Base marker size by confidence tier (at the reference zoom level) —
  /// high-confidence detections read as the largest/most urgent,
  /// low-confidence detections shrink so the map isn't visually dominated
  /// by noise-tier points.
  double _baseMarkerSize(FirePoint point) {
    switch (point.riskTier) {
      case 'high':
        return 28;
      case 'medium':
        return 20;
      default:
        return 16;
    }
  }

  /// Scales marker size with the current zoom level so markers stay
  /// proportionate to the map instead of a fixed screen size regardless of
  /// how far in/out the user is — clamped to keep tiny/huge zooms sane.
  double _markerSize(FirePoint point) {
    final zoomScale = (_currentZoom / 6.0).clamp(0.55, 2.4);
    return _baseMarkerSize(point) * zoomScale;
  }

  /// Every tier renders as the same fire-department icon, just a different
  /// color/size — only the high-confidence tier pulses, so the animation
  /// itself signals urgency.
  Widget _buildMarkerIcon(FirePoint point) {
    final size = _markerSize(point);
    final color = _markerColor(point);
    final icon = Icon(Icons.local_fire_department_rounded, color: color, size: size);
    if (point.riskTier == 'high') {
      return icon.animate(onPlay: (c) => c.repeat(reverse: true)).scale(
            begin: const Offset(0.94, 0.94),
            end: const Offset(1.06, 1.06),
            duration: 1400.ms,
            curve: Curves.easeInOut,
          );
    }
    return icon;
  }

  bool _isLowConfidence(FirePoint p) {
    final c = p.confidence.toLowerCase();
    return !(c.contains('high') ||
        c == 'h' ||
        c.contains('nominal') ||
        c == 'n');
  }

  List<FirePoint> get _visibleFirePoints => _confidenceFilterActive
      ? _firePoints.where((p) => !_isLowConfidence(p)).toList()
      : _firePoints;

  void _focusOnFire(FirePoint point) {
    _mapController.move(LatLng(point.latitude, point.longitude), 10);
    _openFireBottomSheet(point);
  }

  void _centerOnUser() {
    if (_userPosition == null) return;
    _mapController.move(
      LatLng(_userPosition!.latitude, _userPosition!.longitude),
      8,
    );
  }

  void _openFireBottomSheet(FirePoint point) {
    setState(() => _selectedPoint = point);
    final timeAgo = _timeAgo(
      context,
      point.acquisitionDate,
      point.acquisitionTime,
    );
    final bright = double.tryParse(point.brightness) ?? 0;
    final tempC = bright > 200
        ? (bright - 273.15).toStringAsFixed(1)
        : bright.toStringAsFixed(1);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        final l10n = AppLocalizations.of(context)!;
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final titleColor =
            theme.textTheme.titleLarge?.color ??
            (isDark ? AppColors.white : const Color(0xFF0F172A));
        final secondaryTextColor = isDark
            ? AppColors.white.withValues(alpha: 0.72)
            : Colors.black.withValues(alpha: 0.62);

        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: GlassPanel(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: point.detectionColor.withValues(
                      alpha: isDark ? 0.18 : 0.12,
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
                    border: Border.all(
                      color: point.detectionColor.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.satellite_alt_rounded,
                        color: point.detectionColor,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          point.detectionTitle(l10n),
                          style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: point.detectionColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    StatusChip(
                      label:
                          '${fireStatusEmoji(point.smartStatus)} ${fireStatusLabel(l10n, point.smartStatus)}',
                      color: fireStatusColor(point.smartStatus),
                    ),
                    InfoIconButton(
                      title: l10n.tooltipConfidenceTitle,
                      bodyLines: [
                        l10n.smartConfidenceHigh,
                        l10n.smartConfidenceMedium,
                        l10n.smartConfidenceLow,
                      ],
                    ),
                    StatusChip(label: timeAgo, icon: Icons.access_time_rounded),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  point.cityName != null
                      ? '${point.cityName} (${point.nearestRegion ?? point.regionDisplayName(l10n)})'
                      : point.regionDisplayName(l10n),
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  point.riskReasonText(l10n),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.45,
                    color: secondaryTextColor,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _DetailRow(
                  icon: Icons.thermostat_rounded,
                  label: l10n.commonTemperature,
                  value: '$tempC°C (${bright.toStringAsFixed(0)}K)',
                  color: secondaryTextColor,
                  info: InfoIconButton(
                    title: l10n.tooltipTempTitle,
                    bodyLines: [l10n.tooltipTempBody],
                  ),
                ),
                const SizedBox(height: 8),
                _DetailRow(
                  icon: Icons.satellite_alt_rounded,
                  label: l10n.commonSatellite,
                  value: point.mergedSatelliteLabel,
                  color: point.isMerged
                      ? AppColors.success
                      : secondaryTextColor,
                  info: InfoIconButton(
                    title: l10n.tooltipSatelliteTitle,
                    bodyLines: point.isMerged
                        ? [
                            l10n.tooltipSatelliteViirsBody,
                            l10n.tooltipSatelliteModisBody,
                            l10n.tooltipSatelliteMergedBody,
                          ]
                        : [
                            l10n.tooltipSatelliteViirsBody,
                            l10n.tooltipSatelliteModisBody,
                          ],
                  ),
                ),
                const SizedBox(height: 8),
                _DetailRow(
                  icon: Icons.calendar_today_rounded,
                  label: l10n.commonDetection,
                  value: '${point.formattedDate} ${point.formattedTime}',
                  color: secondaryTextColor,
                ),
                if (point.distanceKm != null) ...[
                  const SizedBox(height: 8),
                  _DetailRow(
                    icon: Icons.near_me_rounded,
                    label: l10n.commonDistance,
                    value: '${point.distanceKm!.toStringAsFixed(1)} km',
                    color: secondaryTextColor,
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                GlassPanel(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    point.recommendedActionText(l10n),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      height: 1.45,
                      color: titleColor,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _mapController.move(
                            LatLng(point.latitude, point.longitude),
                            13,
                          );
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
                          context.push(
                            '/fire-detail',
                            extra: convertPointToFireEvent(point, l10n),
                          );
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final titleColor =
        theme.textTheme.titleLarge?.color ??
        (isDark ? AppColors.white : const Color(0xFF0F172A));
    final secondaryTextColor = isDark
        ? AppColors.white.withValues(alpha: 0.74)
        : Colors.black.withValues(alpha: 0.64);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.mapTitle,
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _loadFirePoints,
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isOffline && _cachedAt != null)
                    OfflineBanner(lastUpdated: _cachedAt!),
                  if (_isSlowLoading) const SlowLoadingBanner(),
                  GlassPanel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StatusChip(
                              label: l10n.mapLiveMap,
                              icon: Icons.map_rounded,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              l10n.mapHeaderTitle,
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: titleColor,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              l10n.mapHeaderSubtitle,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                height: 1.45,
                                color: secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 450.ms)
                      .scale(
                        begin: const Offset(0.97, 0.97),
                        end: const Offset(1, 1),
                        curve: Curves.easeOutCubic,
                      )
                      .slideY(begin: 0.06, end: 0),

                  if (_confidenceFilterActive) ...[
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.pillRadius,
                        ),
                        border: Border.all(
                          color: AppColors.danger.withValues(alpha: 0.28),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.filter_alt_rounded,
                            size: 16,
                            color: AppColors.danger,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              l10n.mapConfidenceFilterActive,
                              style: GoogleFonts.inter(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.danger,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () =>
                                setState(() => _confidenceFilterActive = false),
                            behavior: HitTestBehavior.opaque,
                            child: SizedBox(
                              height: 48,
                              child: Center(
                                child: Text(
                                  l10n.mapConfidenceFilterClear,
                                  style: GoogleFonts.inter(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.danger,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.md),
                  TrustInfoCardGroup(
                    meaning: l10n.trustMapMeaning,
                    source: l10n.trustMapSource,
                    interpret: l10n.trustMapInterpret,
                    action: l10n.trustMapAction,
                  ),

                  const SizedBox(height: AppSpacing.md),
                  TrustInfoCard(
                    title: l10n.detectionAboutTitle,
                    icon: Icons.info_outline,
                    text: l10n.thermalAnomalyDisclaimer,
                  ),

                  const SizedBox(height: AppSpacing.xxl),
                  SectionHeader(
                    title: l10n.mapArea,
                    subtitle: l10n.mapAreaSubtitle,
                    icon: Icons.public_rounded,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  GlassPanel(
                        key: CoachMarkKeys.mapArea,
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: SizedBox(
                          height: 380,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.largeCardRadius,
                            ),
                            child: Stack(
                              children: [
                                FlutterMap(
                                  mapController: _mapController,
                                  options: MapOptions(
                                    initialCenter: widget.focusLat != null
                                        ? LatLng(
                                            widget.focusLat!,
                                            widget.focusLng!,
                                          )
                                        : const LatLng(39.0, 35.0),
                                    initialZoom: widget.focusLat != null
                                        ? 13
                                        : 5.6,
                                    minZoom: 4,
                                    maxZoom: 16,
                                    onTap: (_, __) =>
                                        setState(() => _selectedPoint = null),
                                    onPositionChanged: (camera, hasGesture) {
                                      if ((camera.zoom - _currentZoom).abs() >
                                          0.2) {
                                        setState(
                                          () => _currentZoom = camera.zoom,
                                        );
                                      }
                                    },
                                  ),
                                  children: [
                                    TileLayer(
                                      urlTemplate:
                                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                      userAgentPackageName:
                                          'com.firewatchtr.app',
                                    ),
                                    MarkerLayer(
                                      markers: _userPosition != null
                                          ? [
                                              Marker(
                                                point: LatLng(
                                                  _userPosition!.latitude,
                                                  _userPosition!.longitude,
                                                ),
                                                width: 54,
                                                height: 54,
                                                child: const Icon(
                                                  Icons.my_location_rounded,
                                                  size: 34,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                            ]
                                          : [],
                                    ),
                                    if (widget.focusLat != null &&
                                        widget.focusLng != null)
                                      MarkerLayer(
                                        markers: [
                                          Marker(
                                            point: LatLng(
                                              widget.focusLat!,
                                              widget.focusLng!,
                                            ),
                                            width: 60,
                                            height: 60,
                                            child: const Icon(
                                              Icons
                                                  .local_fire_department_rounded,
                                              color: AppColors.danger,
                                              size: 44,
                                            ),
                                          ),
                                        ],
                                      ),
                                    MarkerClusterLayerWidget(
                                      options: MarkerClusterLayerOptions(
                                        maxClusterRadius: 45,
                                        size: const Size(40, 40),
                                        alignment: Alignment.center,
                                        markers: _visibleFirePoints.map((
                                          point,
                                        ) {
                                          return Marker(
                                            point: LatLng(
                                              point.latitude,
                                              point.longitude,
                                            ),
                                            width: 48,
                                            height: 48,
                                            child: GestureDetector(
                                              onTap: () =>
                                                  _openFireBottomSheet(point),
                                              child: Center(
                                                child: _buildMarkerIcon(point),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        builder: (context, markers) =>
                                            Container(
                                              decoration: const BoxDecoration(
                                                color: AppColors.primary,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  markers.length.toString(),
                                                  style: GoogleFonts.inter(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (_isLoading)
                                  Positioned.fill(
                                    child: Container(
                                      color: Colors.black.withValues(
                                        alpha: 0.12,
                                      ),
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                  ),
                                if (_errorMessage != null)
                                  Positioned(
                                    left: 12,
                                    right: 12,
                                    top: 12,
                                    child: GlassPanel(
                                      padding: const EdgeInsets.all(
                                        AppSpacing.lg,
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.info_outline_rounded,
                                            color: AppColors.warning,
                                          ),
                                          const SizedBox(width: AppSpacing.md),
                                          Expanded(
                                            child: Text(
                                              _errorMessage!,
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                height: 1.45,
                                                color: titleColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                Positioned(
                                  right: 12,
                                  bottom: 12,
                                  child:
                                      Column(
                                            children: [
                                              GlassPanel(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 14,
                                                      vertical: 12,
                                                    ),
                                                radius: 16,
                                                child: InkWell(
                                                  onTap: _loadFirePoints,
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      const Icon(
                                                        Icons.refresh_rounded,
                                                        size: 18,
                                                        color:
                                                            AppColors.primary,
                                                      ),
                                                      const SizedBox(
                                                        width: AppSpacing.sm,
                                                      ),
                                                      Text(
                                                        l10n.commonRefresh,
                                                        style:
                                                            GoogleFonts.inter(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              color: titleColor,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: AppSpacing.sm,
                                              ),
                                              if (_userPosition != null)
                                                GlassPanel(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 14,
                                                        vertical: 12,
                                                      ),
                                                  radius: 16,
                                                  child: InkWell(
                                                    onTap: _centerOnUser,
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        const Icon(
                                                          Icons.near_me_rounded,
                                                          size: 18,
                                                          color:
                                                              AppColors.primary,
                                                        ),
                                                        const SizedBox(
                                                          width: AppSpacing.sm,
                                                        ),
                                                        Text(
                                                          l10n.mapGoToMe,
                                                          style:
                                                              GoogleFonts.inter(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color:
                                                                    titleColor,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          )
                                          .animate(delay: 240.ms)
                                          .fadeIn(duration: 280.ms)
                                          .slideY(begin: 0.2, end: 0),
                                ),
                                Positioned(
                                  left: 12,
                                  bottom: 12,
                                  child: GlassPanel(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    radius: 16,
                                    child: InkWell(
                                      onTap: () => setState(
                                        () => _isLegendOpen = !_isLegendOpen,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.info_outline_rounded,
                                            size: 18,
                                            color: AppColors.primary,
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          Text(
                                            l10n.mapLegendTitle,
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: titleColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                if (_isLegendOpen)
                                  Positioned(
                                    left: 12,
                                    right: 12,
                                    bottom: 66,
                                    child:
                                        GlassPanel(
                                              padding: const EdgeInsets.all(
                                                AppSpacing.lg,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    l10n.legendProbableFire,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: titleColor,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    l10n.legendHighThermal,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: titleColor,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    l10n.legendThermalDetection,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: titleColor,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    l10n.legendLowConfidence,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: titleColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                            .animate()
                                            .fadeIn(duration: 180.ms)
                                            .slideY(begin: 0.08, end: 0),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 420.ms, delay: 120.ms)
                      .scale(
                        begin: const Offset(0.98, 0.98),
                        end: const Offset(1, 1),
                      )
                      .slideY(begin: 0.05, end: 0),

                  const SizedBox(height: AppSpacing.sm),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                    ),
                    child: Text(
                      l10n.mapMarkerDisclaimer,
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        height: 1.4,
                        color: secondaryTextColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  if (_nearbyFirePoints.isNotEmpty) ...[
                    SectionHeader(
                      key: CoachMarkKeys.mapNearbyFiresSection,
                      title: l10n.mapNearbyFires,
                      subtitle: l10n.mapNearbyFiresSubtitle,
                      icon: Icons.near_me_rounded,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ..._nearbyFirePoints.asMap().entries.map((entry) {
                      final index = entry.key;
                      final point = entry.value;
                      final timeAgo = _timeAgo(
                        context,
                        point.acquisitionDate,
                        point.acquisitionTime,
                      );
                      final bright = double.tryParse(point.brightness) ?? 0;
                      final tempC = bright > 200
                          ? (bright - 273.15).toStringAsFixed(1)
                          : bright.toStringAsFixed(1);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                        child:
                            GlassPanel(
                                  padding: const EdgeInsets.all(AppSpacing.lg),
                                  child: InkWell(
                                    onTap: () => _focusOnFire(point),
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.largeCardRadius,
                                    ),
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        minHeight: 80,
                                      ),
                                      child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 44,
                                              height: 44,
                                              decoration: BoxDecoration(
                                                color: _markerColor(
                                                  point,
                                                ).withValues(alpha: 0.12),
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                              ),
                                              child: Icon(
                                                Icons
                                                    .local_fire_department_rounded,
                                                color: _markerColor(point),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: AppSpacing.md,
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // ── Şehir + Bölge ──────────────────────
                                                  Text(
                                                    point.cityName != null
                                                        ? '${point.cityName} — ${point.nearestRegion ?? point.regionDisplayName(l10n)}'
                                                        : point
                                                              .regionDisplayName(
                                                                l10n,
                                                              ),
                                                    style: GoogleFonts.inter(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: titleColor,
                                                    ),
                                                  ),
                                                  Text(
                                                    point.distanceKm != null
                                                        ? l10n.notificationsDistanceAndTime(
                                                            point.distanceKm!
                                                                .toStringAsFixed(
                                                                  1,
                                                                ),
                                                            timeAgo,
                                                          )
                                                        : timeAgo,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 13,
                                                      color: secondaryTextColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Wrap(
                                              spacing: AppSpacing.xs,
                                              runSpacing: AppSpacing.xs,
                                              alignment: WrapAlignment.end,
                                              children: [
                                                StatusChip(
                                                  label: point.riskLevelLabel(
                                                    l10n,
                                                  ),
                                                  icon: Icons
                                                      .warning_amber_rounded,
                                                  color: AppColors.forRiskTier(
                                                    point.riskTier,
                                                  ),
                                                ),
                                                StatusChip(
                                                  label:
                                                      '${fireStatusEmoji(point.smartStatus)} ${fireStatusLabel(l10n, point.smartStatus)}',
                                                  color: fireStatusColor(
                                                    point.smartStatus,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: AppSpacing.md),
                                        Container(
                                          padding: const EdgeInsets.all(
                                            AppSpacing.md,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _markerColor(
                                              point,
                                            ).withValues(alpha: 0.06),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                point.riskReasonText(l10n),
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  height: 1.4,
                                                  color: secondaryTextColor,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.thermostat_rounded,
                                                    size: 14,
                                                    color: secondaryTextColor,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '$tempC°C',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 12,
                                                      color: secondaryTextColor,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Icon(
                                                    Icons.satellite_alt_rounded,
                                                    size: 14,
                                                    color: point.isMerged
                                                        ? AppColors.success
                                                        : secondaryTextColor,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Flexible(
                                                    child: Text(
                                                      point
                                                          .mergedSatelliteLabel,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: GoogleFonts.inter(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            point.isMerged
                                                            ? FontWeight.w700
                                                            : FontWeight.normal,
                                                        color: point.isMerged
                                                            ? AppColors.success
                                                            : secondaryTextColor,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Icon(
                                                    Icons.location_on_rounded,
                                                    size: 14,
                                                    color: secondaryTextColor,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      point.locationLabelText(
                                                        l10n,
                                                      ),
                                                      style: GoogleFonts.inter(
                                                        fontSize: 12,
                                                        color:
                                                            secondaryTextColor,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    ),
                                  ),
                                )
                                .animate()
                                .fadeIn(
                                  duration: 300.ms,
                                  delay: (180 + (index * 70)).ms,
                                )
                                .slideX(begin: 0.03, end: 0)
                                .scale(
                                  begin: const Offset(0.98, 0.98),
                                  end: const Offset(1, 1),
                                ),
                      );
                    }),
                    const SizedBox(height: AppSpacing.xxl),
                  ],

                  const SizedBox(height: 110),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 220),
        offset: _isReportOpen ? const Offset(0, 2) : Offset.zero,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: _isReportOpen ? 0 : 1,
          child: IgnorePointer(
            ignoring: _isReportOpen,
            child: FloatingActionButton.extended(
              key: CoachMarkKeys.mapReportFab,
              onPressed: _openReportPanel,
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              elevation: 10,
              icon: const Icon(Icons.edit_location_alt_rounded),
              label: Text(
                l10n.mapReport,
                style: GoogleFonts.inter(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Widget? info;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.info,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: AppSpacing.sm),
        Text('$label: ', style: GoogleFonts.inter(fontSize: 13, color: color)),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
        ?info,
      ],
    );
  }
}
