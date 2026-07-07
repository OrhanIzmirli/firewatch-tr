import 'dart:ui';
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
import '../../shared/widgets/status_chip.dart';
import '../../shared/widgets/trust_info_card.dart';

class MapScreen extends StatefulWidget {
  final double? focusLat;
  final double? focusLng;

  const MapScreen({super.key, this.focusLat, this.focusLng});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _cacheKey = 'map_fires';

  bool _isReportOpen = false;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isOffline = false;
  DateTime? _cachedAt;

  List<FirePoint> _firePoints = [];
  List<FirePoint> _nearbyFirePoints = [];
  FirePoint? _selectedPoint;

  final MapController _mapController = MapController();
  final FireApiService _fireApiService = FireApiService();

  Position? _userPosition;

  @override
  void initState() {
    super.initState();
    _bootstrapMapData().then((_) => _maybeShowMapCoachMarks());
    if (widget.focusLat != null && widget.focusLng != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _mapController.move(LatLng(widget.focusLat!, widget.focusLng!), 13);
        });
      });
    }
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
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return;
      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() => _userPosition = position);
    } catch (_) {}
  }

  Future<void> _loadFirePoints() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final firePoints = await _fireApiService.fetchTurkeyFiresWithCities();
      final allPoints = _attachDistances(firePoints);
      final nearby = _buildNearbyList(allPoints);
      await OfflineCacheService.instance.save(_cacheKey, allPoints.map((p) => p.toJson()).toList());

      if (!mounted) return;
      setState(() {
        _firePoints = allPoints;
        _nearbyFirePoints = nearby;
        _isLoading = false;
        _isOffline = false;
      });
    } catch (_) {
      final cached = await OfflineCacheService.instance.load(_cacheKey);
      if (!mounted) return;
      if (cached != null) {
        final (data, savedAt) = cached;
        final points = (data as List).map((e) => FirePoint.fromJson(e as Map<String, dynamic>)).toList();
        setState(() {
          _firePoints = points;
          _nearbyFirePoints = _buildNearbyList(points);
          _cachedAt = savedAt;
          _isOffline = true;
          _isLoading = false;
        });
      } else {
        setState(() { _errorMessage = AppLocalizations.of(context)!.mapFetchError; _isLoading = false; });
      }
    }
  }

  List<FirePoint> _attachDistances(List<FirePoint> points) {
    if (_userPosition == null) return points;
    return points.map((point) {
      final distanceMeters = Geolocator.distanceBetween(
        _userPosition!.latitude, _userPosition!.longitude,
        point.latitude, point.longitude,
      );
      return point.copyWith(distanceKm: distanceMeters / 1000);
    }).toList();
  }

  List<FirePoint> _buildNearbyList(List<FirePoint> points) {
    final sortable = [...points];
    sortable.sort((a, b) => (a.distanceKm ?? 999999).compareTo(b.distanceKm ?? 999999));
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
      final dt = DateTime.utc(int.parse(dateParts[0]), int.parse(dateParts[1]), int.parse(dateParts[2]), hour, minute);
      final diff = DateTime.now().toUtc().difference(dt);
      if (diff.inMinutes < 60) return l10n.timeAgoMinutes(diff.inMinutes);
      if (diff.inHours < 24) return l10n.timeAgoHours(diff.inHours);
      return l10n.timeAgoDays(diff.inDays);
    } catch (_) {
      return '$acqDate $acqTime';
    }
  }

  void _openReportPanel() => setState(() => _isReportOpen = true);
  void _closeReportPanel() => setState(() => _isReportOpen = false);

  Color _markerColor(String confidence) {
    final c = confidence.toLowerCase();
    if (c.contains('high') || c == 'h') return AppColors.danger;
    if (c.contains('nominal') || c == 'n') return AppColors.warning;
    return AppColors.primary;
  }

  void _focusOnFire(FirePoint point) {
    _mapController.move(LatLng(point.latitude, point.longitude), 10);
    _openFireBottomSheet(point);
  }

  void _centerOnUser() {
    if (_userPosition == null) return;
    _mapController.move(LatLng(_userPosition!.latitude, _userPosition!.longitude), 8);
  }

  void _openFireBottomSheet(FirePoint point) {
    setState(() => _selectedPoint = point);
    final timeAgo = _timeAgo(context, point.acquisitionDate, point.acquisitionTime);
    final bright = double.tryParse(point.brightness) ?? 0;
    final tempC = bright > 200 ? (bright - 273.15).toStringAsFixed(1) : bright.toStringAsFixed(1);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        final l10n = AppLocalizations.of(context)!;
        final theme = Theme.of(context);
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
                    StatusChip(label: point.riskLevelLabel(l10n), icon: Icons.local_fire_department_rounded, color: AppColors.forRiskTier(point.riskTier)),
                    InfoIconButton(
                      title: l10n.tooltipConfidenceTitle,
                      bodyLines: [l10n.smartConfidenceHigh, l10n.smartConfidenceMedium, l10n.smartConfidenceLow],
                    ),
                    const SizedBox(width: 4),
                    StatusChip(label: timeAgo, icon: Icons.access_time_rounded),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  point.cityName != null
                      ? '${point.cityName} (${point.nearestRegion ?? point.regionDisplayName(l10n)})'
                      : point.regionDisplayName(l10n),
                  style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: titleColor),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(point.riskReasonText(l10n), style: GoogleFonts.inter(fontSize: 14, height: 1.45, color: secondaryTextColor)),
                const SizedBox(height: AppSpacing.lg),
                _DetailRow(
                  icon: Icons.thermostat_rounded,
                  label: l10n.commonTemperature,
                  value: '$tempC°C (${bright.toStringAsFixed(0)}K)',
                  color: secondaryTextColor,
                  info: InfoIconButton(title: l10n.tooltipTempTitle, bodyLines: [l10n.tooltipTempBody]),
                ),
                const SizedBox(height: 8),
                _DetailRow(
                  icon: Icons.satellite_alt_rounded,
                  label: l10n.commonSatellite,
                  value: point.satellite,
                  color: secondaryTextColor,
                  info: InfoIconButton(
                    title: l10n.tooltipSatelliteTitle,
                    bodyLines: [l10n.tooltipSatelliteViirsBody, l10n.tooltipSatelliteModisBody],
                  ),
                ),
                const SizedBox(height: 8),
                _DetailRow(icon: Icons.calendar_today_rounded, label: l10n.commonDetection, value: '${point.formattedDate} ${point.formattedTime}', color: secondaryTextColor),
                if (point.distanceKm != null) ...[
                  const SizedBox(height: 8),
                  _DetailRow(icon: Icons.near_me_rounded, label: l10n.commonDistance, value: '${point.distanceKm!.toStringAsFixed(1)} km', color: secondaryTextColor),
                ],
                const SizedBox(height: AppSpacing.lg),
                GlassPanel(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(point.recommendedActionText(l10n), style: GoogleFonts.inter(fontSize: 14, height: 1.45, color: titleColor)),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () { Navigator.pop(context); _mapController.move(LatLng(point.latitude, point.longitude), 13); },
                        icon: const Icon(Icons.map_rounded),
                        label: Text(l10n.commonViewOnMap),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () { Navigator.pop(context); context.push('/fire-detail', extra: convertPointToFireEvent(point, l10n)); },
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
    final screenWidth = MediaQuery.of(context).size.width;
    final panelWidth = screenWidth * 0.78;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final titleColor = theme.textTheme.titleLarge?.color ?? (isDark ? AppColors.white : const Color(0xFF0F172A));
    final secondaryTextColor = isDark ? AppColors.white.withValues(alpha: 0.74) : Colors.black.withValues(alpha: 0.64);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.mapTitle, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
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
                if (_isOffline && _cachedAt != null) OfflineBanner(lastUpdated: _cachedAt!),
                GlassPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StatusChip(label: l10n.mapLiveMap, icon: Icons.map_rounded),
                      const SizedBox(height: AppSpacing.lg),
                      Text(l10n.mapHeaderTitle,
                          style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: titleColor)),
                      const SizedBox(height: AppSpacing.sm),
                      Text(l10n.mapHeaderSubtitle,
                          style: GoogleFonts.inter(fontSize: 15, height: 1.45, color: secondaryTextColor)),
                    ],
                  ),
                ).animate().fadeIn(duration: 450.ms).scale(begin: const Offset(0.97, 0.97), end: const Offset(1, 1), curve: Curves.easeOutCubic).slideY(begin: 0.06, end: 0),

                const SizedBox(height: AppSpacing.md),
                TrustInfoCardGroup(
                  meaning: l10n.trustMapMeaning,
                  source: l10n.trustMapSource,
                  interpret: l10n.trustMapInterpret,
                  action: l10n.trustMapAction,
                ),

                const SizedBox(height: AppSpacing.xxl),
                SectionHeader(title: l10n.mapArea, subtitle: l10n.mapAreaSubtitle, icon: Icons.public_rounded),
                const SizedBox(height: AppSpacing.md),

                GlassPanel(
                  key: CoachMarkKeys.mapArea,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: SizedBox(
                    height: 380,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius),
                      child: Stack(
                        children: [
                          FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: widget.focusLat != null ? LatLng(widget.focusLat!, widget.focusLng!) : const LatLng(39.0, 35.0),
                              initialZoom: widget.focusLat != null ? 13 : 5.6,
                              minZoom: 4, maxZoom: 16,
                              onTap: (_, __) => setState(() => _selectedPoint = null),
                            ),
                            children: [
                              TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.firewatchtr.app'),
                              MarkerLayer(
                                markers: _userPosition != null ? [
                                  Marker(point: LatLng(_userPosition!.latitude, _userPosition!.longitude), width: 54, height: 54,
                                      child: const Icon(Icons.my_location_rounded, size: 34, color: Colors.blue)),
                                ] : [],
                              ),
                              if (widget.focusLat != null && widget.focusLng != null)
                                MarkerLayer(markers: [
                                  Marker(point: LatLng(widget.focusLat!, widget.focusLng!), width: 60, height: 60,
                                      child: const Icon(Icons.local_fire_department_rounded, color: AppColors.danger, size: 44)),
                                ]),
                              MarkerClusterLayerWidget(
                                options: MarkerClusterLayerOptions(
                                  maxClusterRadius: 45, size: const Size(40, 40), alignment: Alignment.center,
                                  markers: _firePoints.map((point) {
                                    final color = _markerColor(point.confidence);
                                    return Marker(
                                      point: LatLng(point.latitude, point.longitude), width: 40, height: 40,
                                      child: GestureDetector(
                                        onTap: () => _openFireBottomSheet(point),
                                        child: Icon(Icons.local_fire_department_rounded, color: color, size: 30)
                                            .animate(onPlay: (c) => c.repeat(reverse: true))
                                            .scale(begin: const Offset(0.94, 0.94), end: const Offset(1.06, 1.06), duration: 1400.ms, curve: Curves.easeInOut),
                                      ),
                                    );
                                  }).toList(),
                                  builder: (context, markers) => Container(
                                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                    child: Center(child: Text(markers.length.toString(), style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700))),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_isLoading)
                            Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.12), child: const Center(child: CircularProgressIndicator()))),
                          if (_errorMessage != null)
                            Positioned(left: 12, right: 12, top: 12,
                              child: GlassPanel(padding: const EdgeInsets.all(AppSpacing.lg),
                                child: Row(children: [
                                  const Icon(Icons.info_outline_rounded, color: AppColors.warning),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(child: Text(_errorMessage!, style: GoogleFonts.inter(fontSize: 13, height: 1.45, color: titleColor))),
                                ]),
                              ),
                            ),
                          Positioned(
                            right: 12, bottom: 12,
                            child: Column(
                              children: [
                                GlassPanel(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), radius: 16,
                                  child: InkWell(onTap: _loadFirePoints,
                                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                                      const Icon(Icons.refresh_rounded, size: 18, color: AppColors.primary),
                                      const SizedBox(width: AppSpacing.sm),
                                      Text(l10n.commonRefresh, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: titleColor)),
                                    ]),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                if (_userPosition != null)
                                  GlassPanel(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), radius: 16,
                                    child: InkWell(onTap: _centerOnUser,
                                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                                        const Icon(Icons.near_me_rounded, size: 18, color: AppColors.primary),
                                        const SizedBox(width: AppSpacing.sm),
                                        Text(l10n.mapGoToMe, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: titleColor)),
                                      ]),
                                    ),
                                  ),
                              ],
                            ).animate(delay: 240.ms).fadeIn(duration: 280.ms).slideY(begin: 0.2, end: 0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 420.ms, delay: 120.ms).scale(begin: const Offset(0.98, 0.98), end: const Offset(1, 1)).slideY(begin: 0.05, end: 0),

                const SizedBox(height: AppSpacing.xxl),

                if (_nearbyFirePoints.isNotEmpty) ...[
                  SectionHeader(key: CoachMarkKeys.mapNearbyFiresSection, title: l10n.mapNearbyFires, subtitle: l10n.mapNearbyFiresSubtitle, icon: Icons.near_me_rounded),
                  const SizedBox(height: AppSpacing.md),
                  ..._nearbyFirePoints.asMap().entries.map((entry) {
                    final index = entry.key;
                    final point = entry.value;
                    final timeAgo = _timeAgo(context, point.acquisitionDate, point.acquisitionTime);
                    final bright = double.tryParse(point.brightness) ?? 0;
                    final tempC = bright > 200 ? (bright - 273.15).toStringAsFixed(1) : bright.toStringAsFixed(1);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: GlassPanel(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: InkWell(
                          onTap: () => _focusOnFire(point),
                          borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 44, height: 44,
                                    decoration: BoxDecoration(
                                      color: _markerColor(point.confidence).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(Icons.local_fire_department_rounded, color: _markerColor(point.confidence)),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // ── Şehir + Bölge ──────────────────────
                                        Text(
                                          point.cityName != null
                                              ? '${point.cityName} — ${point.nearestRegion ?? point.regionDisplayName(l10n)}'
                                              : point.regionDisplayName(l10n),
                                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: titleColor),
                                        ),
                                        Text(
                                          point.distanceKm != null
                                              ? l10n.notificationsDistanceAndTime(point.distanceKm!.toStringAsFixed(1), timeAgo)
                                              : timeAgo,
                                          style: GoogleFonts.inter(fontSize: 13, color: secondaryTextColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                  StatusChip(label: point.riskLevelLabel(l10n), icon: Icons.warning_amber_rounded, color: AppColors.forRiskTier(point.riskTier)),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: _markerColor(point.confidence).withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(point.riskReasonText(l10n), style: GoogleFonts.inter(fontSize: 13, height: 1.4, color: secondaryTextColor)),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(Icons.thermostat_rounded, size: 14, color: secondaryTextColor),
                                        const SizedBox(width: 4),
                                        Text('$tempC°C', style: GoogleFonts.inter(fontSize: 12, color: secondaryTextColor)),
                                        const SizedBox(width: 12),
                                        Icon(Icons.satellite_alt_rounded, size: 14, color: secondaryTextColor),
                                        const SizedBox(width: 4),
                                        Text(point.satellite, style: GoogleFonts.inter(fontSize: 12, color: secondaryTextColor)),
                                        const SizedBox(width: 12),
                                        Icon(Icons.location_on_rounded, size: 14, color: secondaryTextColor),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(point.locationLabelText(l10n),
                                              style: GoogleFonts.inter(fontSize: 12, color: secondaryTextColor),
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate()
                          .fadeIn(duration: 300.ms, delay: (180 + (index * 70)).ms)
                          .slideX(begin: 0.03, end: 0)
                          .scale(begin: const Offset(0.98, 0.98), end: const Offset(1, 1)),
                    );
                  }),
                  const SizedBox(height: AppSpacing.xxl),
                ],

                const SizedBox(height: 110),
              ],
            ),
            ),
          ),

          if (_isReportOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeReportPanel,
                child: Stack(children: [
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                      child: Container(color: Colors.black.withValues(alpha: 0.18)),
                    ),
                  ),
                ]),
              ),
            ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeInOutCubic,
            top: 0, bottom: 0,
            right: _isReportOpen ? 0 : -panelWidth - 30,
            child: SizedBox(
              width: panelWidth,
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md, right: AppSpacing.md, bottom: AppSpacing.md),
                child: ReportFirePanel(onClose: _closeReportPanel),
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
              label: Text(l10n.mapReport, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
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

  const _DetailRow({required this.icon, required this.label, required this.value, required this.color, this.info});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: AppSpacing.sm),
        Text('$label: ', style: GoogleFonts.inter(fontSize: 13, color: color)),
        Expanded(child: Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: color))),
        ?info,
      ],
    );
  }
}