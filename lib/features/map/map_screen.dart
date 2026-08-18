import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/loading_race.dart';
import '../../l10n/app_localizations.dart';
import '../../models/fire_incident.dart';
import '../../models/fire_point.dart';
import '../../services/fire_api_service.dart';
import '../../services/render_api_service.dart';
import '../../services/fire_mapper.dart';
import '../../services/offline_cache_service.dart';
import '../../shared/coach_mark_keys.dart';
import '../../shared/widgets/coach_mark_overlay.dart';
import '../../shared/widgets/color_dot.dart';
import '../../shared/widgets/glass_panel.dart';
import '../../shared/widgets/info_icon_button.dart';
import '../../shared/widgets/report_fire_panel.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/slow_loading_banner.dart';
import '../../shared/widgets/status_chip.dart';
import '../../shared/widgets/trust_info_card.dart';
import 'widgets/incident_legend.dart';
import 'widgets/incident_sheet.dart';

class MapScreen extends StatefulWidget {
  final double? focusLat;
  final double? focusLng;

  /// When true, only fires with 'high' or 'nominal' confidence are shown
  /// on the map — used when arriving from the Home screen's "Active Fire
  /// Points" overview card, which counts the same subset.
  final bool initialConfidenceFilter;

  /// Overrides the stored event filter for this visit only — used when the
  /// Home summary card sends the user here to look at one specific slice.
  /// Null means "use whatever the user last chose".
  final IncidentFilter? initialIncidentFilter;

  const MapScreen({
    super.key,
    this.focusLat,
    this.focusLng,
    this.initialConfidenceFilter = false,
    this.initialIncidentFilter,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _cacheKey = 'map_fires';
  static const _filterPrefKey = 'map_incident_filter';

  bool _isLoading = true;
  String? _errorMessage;
  bool _isSlowLoading = false;
  bool _isLegendOpen = false;
  late bool _confidenceFilterActive = widget.initialConfidenceFilter;
  double _currentZoom = 5.6;

  List<FirePoint> _firePoints = [];
  List<FirePoint> _nearbyFirePoints = [];

  /// Clustered events from /api/incidents. Empty when the endpoint is
  /// unavailable, which is why the raw-detection layer is kept intact.
  List<FireIncident> _incidents = [];

  /// Events are the primary layer. The raw detection layer is still one tap
  /// away — with the thermal window now spanning two days it can carry ~600
  /// points, most of them historical, and that reads as noise on a country
  /// map. Grouping them into events is the whole point of showing events.
  bool _showIncidents = true;

  /// Which events are drawn. Defaults to [IncidentFilter.active] — of ~240
  /// live events only about ten are currently being detected, so showing
  /// everything by default buries the ones that matter under a fortnight of
  /// history. The rest stay one tap away.
  IncidentFilter _incidentFilter = IncidentFilter.active;

  /// The EFFIS fire-danger (FWI) raster. An on/off overlay, not a third
  /// position of the events/detections choice: a danger *forecast* composes
  /// with either fire layer and must never read as a detection itself.
  bool _showRiskLayer = false;

  /// Overlay opacity. 0.55 keeps the base map readable underneath while the
  /// danger classes stay clearly distinguishable.
  double _riskOpacity = 0.55;

  /// 0 = today … 3 = today+3. The `mf010.fwi` layer is MeteoFrance's 10 km
  /// model, which only forecasts 3 days ahead — later dates return an empty
  /// (fully transparent) image, so offering them would show a blank layer.
  int _riskDayOffset = 0;

  /// Days the forecast-day picker offers, today included.
  static const int _riskForecastDays = 4;

  bool _isRiskLegendOpen = true;

  /// How much of the screen the info sheet takes when it is resting. Enough
  /// for the title, the one-line description and the Report button, and no
  /// more — the rest of the screen belongs to the map.
  static const double _sheetCollapsedFraction = 0.25;

  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  final MapController _mapController = MapController();
  final FireApiService _fireApiService = FireApiService();
  final RenderApiService _renderApi = RenderApiService();

  /// Drives [TileLayer.reset]. Tiles that failed to load are never re-requested
  /// on their own, so without an explicit reset a connectivity blip leaves the
  /// map permanently grey until the app is restarted. Pushing an event here
  /// clears the tile manager and reloads everything in view.
  final StreamController<void> _tileResetController =
      StreamController<void>.broadcast();
  late final Stream<void> _tileResetStream = _tileResetController.stream;

  Position? _userPosition;

  @override
  void initState() {
    super.initState();
    if (widget.focusLat != null) _currentZoom = 13;
    if (widget.initialIncidentFilter != null) {
      _incidentFilter = widget.initialIncidentFilter!;
    } else {
      _restoreIncidentFilter();
    }
    // The nearby-detections list lives inside the sheet and is built from the
    // raw feed, so opening the sheet is the other thing that needs it.
    _sheetController.addListener(_onSheetMoved);
    _bootstrapMapData().then((_) => _maybeShowMapCoachMarks());
    if (widget.focusLat != null && widget.focusLng != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _mapController.move(LatLng(widget.focusLat!, widget.focusLng!), 13);
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _tileResetController.close();
    _sheetController.removeListener(_onSheetMoved);
    _sheetController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  /// What the on-map "Refresh" button does: re-fetch the fire points *and*
  /// force the tile layer to retry anything that failed, so a user who hit a
  /// dead network has a way back without restarting the app.
  Future<void> _refreshMap() async {
    if (!_tileResetController.isClosed) _tileResetController.add(null);
    await _loadIncidents();
    if (_firePointsRequested) await _loadFirePoints();
  }

  void _onSheetMoved() {
    if (_firePointsRequested || !_sheetController.isAttached) return;
    if (_sheetController.size <= _sheetCollapsedFraction + 0.02) return;
    _firePointsRequested = true;
    _loadFirePoints();
  }

  Future<void> _bootstrapMapData() async {
    await _loadUserLocation();
    await _loadIncidents();
    // The events layer is what opens. Fetching the raw feed as well meant
    // every visit paid for ~600 CSV rows nobody was looking at, on a backend
    // that scales to zero and charges a cold start for the privilege. It is
    // fetched the first time the detections layer is actually selected.
    if (!_showIncidents) {
      _firePointsRequested = true;
      await _loadFirePoints();
    }
  }

  /// True once the raw feed has been fetched, so switching layers back and
  /// forth does not re-fetch it.
  bool _firePointsRequested = false;

  /// Switches layer, pulling the raw feed in on first use.
  void _setLayer({required bool showIncidents}) {
    setState(() => _showIncidents = showIncidents);
    if (!showIncidents && !_firePointsRequested) {
      _firePointsRequested = true;
      _loadFirePoints();
    }
  }

  void _toggleRiskLayer() {
    setState(() {
      _showRiskLayer = !_showRiskLayer;
      // Reopen the legend on every activation: the colours mean nothing
      // without the key, and the user may have closed it days ago.
      if (_showRiskLayer) _isRiskLegendOpen = true;
    });
  }

  /// The date the FWI layer shows, as the WMS `TIME` value. TIME is
  /// mandatory: without it EFFIS answers HTTP 200 with a fully transparent
  /// image — the layer looks on and shows nothing, silently.
  String get _fwiDateParam => DateFormat('yyyy-MM-dd')
      .format(DateTime.now().add(Duration(days: _riskDayOffset)));

  String _riskDayLabel(AppLocalizations l10n, int offset) {
    if (offset == 0) return l10n.riskDayToday;
    if (offset == 1) return l10n.riskDayTomorrow;
    return DateFormat.EEEE(
      Localizations.localeOf(context).toString(),
    ).format(DateTime.now().add(Duration(days: offset)));
  }

  List<String> _riskClassLabels(AppLocalizations l10n) => [
    l10n.riskClassVeryLow,
    l10n.riskClassLow,
    l10n.riskClassModerate,
    l10n.riskClassHigh,
    l10n.riskClassVeryHigh,
    l10n.riskClassExtreme,
  ];

  /// Best-effort: a failure or an empty result silently leaves the detection
  /// view in charge rather than showing an error, so adding events cannot
  /// regress the map that already worked.
  Future<void> _loadIncidents() async {
    final incidents = await _renderApi.fetchIncidents(days: 7, limit: 300);
    if (!mounted) return;
    final fellBack = incidents.isEmpty && _showIncidents;
    setState(() {
      _incidents = incidents;
      if (incidents.isEmpty) _showIncidents = false;
    });
    // Falling back to the detection layer is the one path that selects it
    // without a tap, so it has to trigger the same lazy fetch.
    if (fellBack && !_firePointsRequested) {
      _firePointsRequested = true;
      await _loadFirePoints();
    }
  }

  Future<void> _restoreIncidentFilter() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = IncidentFilterX.fromStorage(prefs.getString(_filterPrefKey));
    if (!mounted || stored == _incidentFilter) return;
    setState(() => _incidentFilter = stored);
  }

  Future<void> _setIncidentFilter(IncidentFilter filter) async {
    if (filter == _incidentFilter) return;
    setState(() => _incidentFilter = filter);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_filterPrefKey, filter.storageValue);
  }

  List<FireIncident> get _visibleIncidents =>
      _incidents.where(_incidentFilter.matches).toList();

  int _incidentCountFor(IncidentFilter filter) =>
      _incidents.where(filter.matches).length;

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
    final position = await _fetchFreshPosition();
    if (position == null || !mounted) return;
    setState(() => _userPosition = position);
  }

  /// Same permission/service checks and LocationSettings used by
  /// home_screen.dart / risk_screen.dart, so a fresh fix is requested here
  /// too instead of reusing whatever _userPosition was set to when the map
  /// first loaded.
  Future<Position?> _fetchFreshPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      return null;
    }
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
          final (data, _) = cached;
          final points = (data as List)
              .map((e) => FirePoint.fromJson(e as Map<String, dynamic>))
              .toList();
          setState(() {
            _firePoints = points;
            _nearbyFirePoints = _buildNearbyList(points);
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
        _isSlowLoading = false;
      });
      debugPrint(
        'Fire points count: ${_firePoints.length} (visible: ${_visibleFirePoints.length}, confidenceFilterActive: $_confidenceFilterActive)',
      );
    } catch (e) {
      debugPrint('Fire points fetch FAILED: $e');
      final cached = await OfflineCacheService.instance.load(_cacheKey);
      if (!mounted) return;
      if (cached != null) {
        final (data, _) = cached;
        final points = (data as List)
            .map((e) => FirePoint.fromJson(e as Map<String, dynamic>))
            .toList();
        setState(() {
          _firePoints = points;
          _nearbyFirePoints = _buildNearbyList(points);
          _isSlowLoading = false;
          _isLoading = false;
        });
        debugPrint('Fire points count (from cache): ${_firePoints.length}');
      } else {
        setState(() {
          _errorMessage = AppLocalizations.of(context)!.mapFetchError;
          _isSlowLoading = false;
          _isLoading = false;
        });
        debugPrint('Fire points count: 0 (no cache available)');
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
    showReportFirePanel(context);
  }

  /// Marker color by NASA confidence tier only — high: danger (red),
  /// nominal: warning (orange), low: grey — independent of
  /// FirePoint.detectionColor (which still drives the bottom sheet/cards
  /// elsewhere and is deliberately left alone).
  Color _markerColor(FirePoint point) {
    switch (point.riskTier) {
      case 'high':
        return AppColors.danger;
      case 'medium':
        return AppColors.warning;
      default:
        return Colors.grey;
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
        return 22;
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
  /// A raw detection: a plain disc, never a flame.
  ///
  /// A thermal detection is one hot pixel. It might be a fire, and it might
  /// equally be a factory, a flare stack or sun off a greenhouse roof — the
  /// layer is called "possible fire points" for that reason. Drawing a flame
  /// on it asserts the very thing the layer cannot establish, and drawing 600
  /// of them asserted it 600 times.
  ///
  /// The flame now belongs only to the events layer, where detections have
  /// been grouped and weighed. There is no pulse either: a pulsing marker
  /// reads as "live, urgent, happening now", which a single pixel of unknown
  /// provenance has not earned.
  Widget _buildMarkerIcon(FirePoint point) {
    final size = _markerSize(point);
    final color = _markerColor(point);
    return Container(
      width: size * 0.62,
      height: size * 0.62,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.85),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.9),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }

  // Uses FirePoint.riskTier (not a local confidence parse) so it handles
  // both VIIRS text confidence ("high"/"nominal") and MODIS numeric
  // confidence (e.g. "79") the same way markers/badges do elsewhere —
  // a duplicated text-only parser here previously misclassified all
  // MODIS numeric-confidence points as low, filtering out every marker.
  bool _isLowConfidence(FirePoint p) => p.riskTier == 'low';

  /// Diameter this event should be drawn at right now. The base size comes
  /// from the category and is scaled by zoom, so a country view stays a map
  /// with fires on it rather than a field of discs with a map somewhere
  /// underneath.
  double _incidentMarkerSize(IncidentStatus status) {
    return (status.markerSize * (_currentZoom / 7.0)).clamp(
      status.minMarkerSize,
      status.maxMarkerSize,
    );
  }

  /// One marker per event: a filled disc, ringed in white so it stays legible
  /// over both the pale steppe and the dark forest of the basemap.
  ///
  /// The category icon is only drawn once the disc is big enough to hold it.
  /// Below roughly 20 px a glyph inside a circle is a smudge, and a smudge
  /// that pretends to be a symbol is worse than a clean dot — the colour and
  /// size already carry the category, and the legend and the detail sheet
  /// carry the icon at a size where it can actually be read.
  Widget _buildIncidentMarker(FireIncident incident) {
    final status = incident.status;
    final size = _incidentMarkerSize(status);
    final showIcon = size >= 20;
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: status.color.withValues(alpha: status.fillOpacity),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.9),
          width: size >= 18 ? 1.6 : 1.1,
        ),
        boxShadow: status == IncidentStatus.activeDetection
            ? [
                BoxShadow(
                  color: AppColors.danger.withValues(alpha: 0.45),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: showIcon
            ? Icon(status.icon, color: Colors.white, size: size * 0.56)
            : null,
      ),
    );
  }

  /// Marker key to event, so the cluster builder can see what it is hiding
  /// without the marker having to carry the model around.
  final Map<Key?, FireIncident> _incidentByMarkerKey = {};

  /// The most severe status inside a cluster. A bubble hiding one actively
  /// burning fire among ninety quiet ones has to read as urgent, not average.
  IncidentStatus _clusterStatus(List<Marker> markers) {
    var worst = IncidentStatus.lowConfidence;
    for (final marker in markers) {
      final status = _incidentByMarkerKey[marker.key]?.status;
      if (status == null) continue;
      if (status.index < worst.index) worst = status;
    }
    return worst;
  }

  /// Cluster bubbles grow with how much they are hiding, sub-linearly so a
  /// group of ninety is visibly heavier than a group of two without being
  /// forty-five times the area. A fixed size made "2" and "90" identical,
  /// which is the one thing a cluster count exists to distinguish.
  /// Cluster size is driven by what is inside first and how much of it second.
  ///
  /// A bubble holding one burning fire is bigger than a bubble holding thirty
  /// quiet ones, because that is the order a person needs to read them in.
  /// Count still grows the bubble, but only within its tier's band.
  double _clusterDiameter(int count, [IncidentStatus? status]) {
    final tier = status ?? IncidentStatus.awaitingConfirmation;
    final growth = (math.log(count.clamp(1, 500)) / math.ln10) * 10;
    switch (tier) {
      case IncidentStatus.activeDetection:
        return (44 + growth).clamp(44.0, 62.0);
      case IncidentStatus.awaitingConfirmation:
        return (32 + growth).clamp(32.0, 46.0);
      case IncidentStatus.lowConfidence:
        return (22 + growth * 0.6).clamp(22.0, 30.0);
    }
  }

  /// The bubble says WHAT before it says HOW MANY.
  ///
  /// Previously every cluster was the same dark disc with a number, so a
  /// bubble hiding one fire that is burning right now and a bubble hiding
  /// thirty-one week-old single-pixel detections were indistinguishable —
  /// which is the one thing this bubble exists to distinguish. Now a cluster
  /// containing an actively detected fire is a red disc with a flame and the
  /// count beneath it; one holding only fires that are no longer being seen
  /// is neutral grey; one holding only thin evidence is small and faded.
  Widget _buildIncidentCluster(List<Marker> markers) {
    final status = _clusterStatus(markers);
    final count = markers.length;
    final size = _clusterDiameter(count, status);
    final hasActive = status == IncidentStatus.activeDetection;

    final Color fill;
    final double fillAlpha;
    switch (status) {
      case IncidentStatus.activeDetection:
        fill = AppColors.danger;
        fillAlpha = 1;
      case IncidentStatus.awaitingConfirmation:
        fill = AppColors.textFaint;
        fillAlpha = 0.95;
      case IncidentStatus.lowConfidence:
        fill = AppColors.textMuted;
        fillAlpha = 0.6;
    }

    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: fill.withValues(alpha: fillAlpha),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: hasActive ? 0.95 : 0.75),
            width: hasActive ? 2.5 : 1.8,
          ),
          boxShadow: [
            BoxShadow(
              color: hasActive
                  ? AppColors.danger.withValues(alpha: 0.5)
                  : Colors.black.withValues(alpha: 0.26),
              blurRadius: hasActive ? 12 : 6,
              spreadRadius: hasActive ? 1 : 0,
              offset: hasActive ? Offset.zero : const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasActive)
                Icon(
                  Icons.local_fire_department_rounded,
                  color: Colors.white,
                  size: size * 0.38,
                ),
              Text(
                count.toString(),
                style: AppTheme.mono(
                  size: hasActive ? size * 0.26 : size * 0.36,
                  weight: FontWeight.w700,
                  color: Colors.white,
                ).copyWith(height: 1.05),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The province label for an incident.
  ///
  /// Server-resolved when the backend provides it. The proximity fallback
  /// below only runs against raw detections that happen to be loaded, so it
  /// silently produced nothing whenever the thermal feed was not fetched —
  /// which is now the normal case on the events layer.
  String? _cityNameFor(FireIncident incident) {
    final resolved = incident.cityName;
    if (resolved != null && resolved.isNotEmpty) return resolved;
    for (final point in _firePoints) {
      if (point.cityName == null) continue;
      final dLat = (point.latitude - incident.latitude).abs();
      final dLng = (point.longitude - incident.longitude).abs();
      if (dLat < 0.25 && dLng < 0.25) return point.cityName;
    }
    return null;
  }

  List<FirePoint> get _visibleFirePoints => _confidenceFilterActive
      ? _firePoints.where((p) => !_isLowConfidence(p)).toList()
      : _firePoints;

  void _focusOnFire(FirePoint point) {
    _mapController.move(LatLng(point.latitude, point.longitude), 10);
    _openFireBottomSheet(point);
  }

  Future<void> _centerOnUser() async {
    final fresh = await _fetchFreshPosition();
    if (!mounted) return;
    final position = fresh ?? _userPosition;
    if (position == null) return;
    if (fresh != null) setState(() => _userPosition = fresh);
    _mapController.move(LatLng(position.latitude, position.longitude), 8);
  }

  void _openFireBottomSheet(FirePoint point) {
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
            (isDark ? AppColors.white : AppColors.lightText);
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
                          style: GoogleFonts.ibmPlexSans(
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
                      label: fireStatusLabel(l10n, point.smartStatus),
                      showDot: true,
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
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  point.riskReasonText(l10n),
                  style: GoogleFonts.ibmPlexSans(
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
                    style: GoogleFonts.ibmPlexSans(
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
        (isDark ? AppColors.white : AppColors.lightText);
    final secondaryTextColor = isDark
        ? AppColors.white.withValues(alpha: 0.74)
        : Colors.black.withValues(alpha: 0.64);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _screenTitle(l10n),
          style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700),
        ),
      ),
      // The map is the screen, not a card on it. Everything that explains the
      // map -- what a detection is, what to do about one, what is near you --
      // now lives in the sheet below, one drag away instead of one scroll
      // above. Before this, opening the Map tab showed two help accordions
      // and a section heading, and the map itself started below the fold.
      body: LayoutBuilder(
        builder: (context, constraints) {
          // The sheet's fraction is of the body, not of the screen. Measuring
          // it here rather than from MediaQuery is what keeps the on-map
          // controls sitting just above the sheet instead of floating a
          // status bar and an app bar's worth of space too high.
          final sheetHeight = constraints.maxHeight * _sheetCollapsedFraction;
          return Stack(
            children: [
              Positioned.fill(
                child: _buildMapSurface(l10n, titleColor, sheetHeight),
              ),
              if (_isSlowLoading)
                const Positioned(
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  top: AppSpacing.lg,
                  child: SlowLoadingBanner(),
                ),
              DraggableScrollableSheet(
                controller: _sheetController,
                initialChildSize: _sheetCollapsedFraction,
                minChildSize: _sheetCollapsedFraction,
                maxChildSize: 0.92,
                snap: true,
                snapSizes: const [_sheetCollapsedFraction, 0.55, 0.92],
                builder: (context, scrollController) => _buildInfoSheet(
                  scrollController,
                  l10n,
                  titleColor,
                  secondaryTextColor,
                  isDark,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Title follows the layer in view. "Thermal Anomaly Map" described the raw
  /// pixel layer, which is no longer the primary one.
  String _screenTitle(AppLocalizations l10n) =>
      _showIncidents ? l10n.mapTitleEvents : l10n.mapTitleDetections;

  /// The full-bleed map plus everything that floats on it. The inset keeps the
  /// on-map controls clear of the collapsed sheet.
  Widget _buildMapSurface(
    AppLocalizations l10n,
    Color titleColor,
    double bottomInset,
  ) {
    return Stack(
      children: [
        RepaintBoundary(
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.focusLat != null
                  ? LatLng(widget.focusLat!, widget.focusLng!)
                  // Biased south of Turkey's true centre: the map now runs
                  // full-bleed and its lower quarter sits behind the info
                  // sheet, so centring on 39N put a third of the country
                  // under the sheet and filled the visible half with the
                  // Black Sea.
                  : const LatLng(38.2, 35.0),
              initialZoom: widget.focusLat != null ? 13 : 5.6,
              minZoom: 4,
              // z16 only gets you to neighbourhood level,
              // which isn't enough to place a fire; 18 is
              // street level and still within OSM's z19
              // native limit, so tiles stay sharp.
              maxZoom: 18,
              onPositionChanged: (camera, hasGesture) {
                if ((camera.zoom - _currentZoom).abs() > 0.2) {
                  setState(() => _currentZoom = camera.zoom);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.oguzh.firewatch.firewatch_tr',
                // A tile that fails (typically a brief
                // connectivity drop) is otherwise kept
                // forever in the tile manager and never
                // re-requested, leaving permanently grey
                // squares. This evicts the off-screen
                // ones; the reset stream below is what
                // recovers the ones still on screen.
                evictErrorTileStrategy: EvictErrorTileStrategy.notVisible,
                reset: _tileResetStream,
                errorTileCallback: (tile, error, stack) {
                  if (kDebugMode) {
                    debugPrint(
                      'Map tile failed '
                      'z=${tile.coordinates.z} '
                      'x=${tile.coordinates.x} '
                      'y=${tile.coordinates.y}: $error',
                    );
                  }
                },
              ),
              // The FWI raster sits between the base map and the markers:
              // danger paints the ground, detections stay on top. Built only
              // while the risk toggle is on, so no WMS request ever leaves
              // the device with the layer off.
              if (_showRiskLayer)
                Opacity(
                  opacity: _riskOpacity,
                  child: TileLayer(
                    // TileLayer does not watch wmsOptions for changes, so a
                    // new date has to replace the layer outright or stale
                    // tiles would survive the switch.
                    key: ValueKey('fwi-$_fwiDateParam'),
                    wmsOptions: WMSTileLayerOptions(
                      baseUrl:
                          'https://maps.effis.emergency.copernicus.eu/effis?',
                      layers: const ['mf010.fwi'],
                      format: 'image/png',
                      version: '1.1.1',
                      transparent: true,
                      otherParameters: {'TIME': _fwiDateParam},
                    ),
                    userAgentPackageName: 'com.oguzh.firewatch.firewatch_tr',
                    evictErrorTileStrategy: EvictErrorTileStrategy.notVisible,
                  ),
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
              if (widget.focusLat != null && widget.focusLng != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(widget.focusLat!, widget.focusLng!),
                      width: 60,
                      height: 60,
                      child: const Icon(
                        Icons.local_fire_department_rounded,
                        color: AppColors.danger,
                        size: 44,
                      ),
                    ),
                  ],
                ),
              if (_showIncidents)
                MarkerClusterLayerWidget(
                  options: MarkerClusterLayerOptions(
                    maxClusterRadius: 72,
                    size: const Size(52, 52),
                    computeSize: (markers) {
                      final d = _clusterDiameter(
                        markers.length,
                        _clusterStatus(markers),
                      );
                      return Size(d, d);
                    },
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(40),
                    markers: _visibleIncidents.map((incident) {
                      final key = ValueKey<String>('incident-${incident.id}');
                      _incidentByMarkerKey[key] = incident;
                      return Marker(
                        key: key,
                        point: LatLng(incident.latitude, incident.longitude),
                        width: 48,
                        height: 48,
                        child: GestureDetector(
                          onTap: () => IncidentSheet.show(
                            context,
                            incident: incident,
                            cityName: _cityNameFor(incident),
                          ),
                          child: Center(child: _buildIncidentMarker(incident)),
                        ),
                      );
                    }).toList(),
                    builder: (context, markers) =>
                        _buildIncidentCluster(markers),
                  ),
                )
              else
                MarkerClusterLayerWidget(
                  options: MarkerClusterLayerOptions(
                    maxClusterRadius: 45,
                    size: const Size(40, 40),
                    alignment: Alignment.center,
                    markers: _visibleFirePoints.map((point) {
                      return Marker(
                        point: LatLng(point.latitude, point.longitude),
                        width: 48,
                        height: 48,
                        child: GestureDetector(
                          onTap: () => _openFireBottomSheet(point),
                          child: Center(child: _buildMarkerIcon(point)),
                        ),
                      );
                    }).toList(),
                    builder: (context, markers) => Container(
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          markers.length.toString(),
                          style: AppTheme.mono(
                            weight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (_isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.12),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
        if (_incidents.isNotEmpty)
          Positioned(
            left: 12,
            top: 12,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: GlassPanel(
                    padding: const EdgeInsets.all(4),
                    radius: AppSpacing.pillRadius,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _LayerChip(
                          label: l10n.incidentToggleShow,
                          icon: Icons.local_fire_department_rounded,
                          selected: _showIncidents,
                          onTap: () => _setLayer(showIncidents: true),
                        ),
                        _LayerChip(
                          label: l10n.incidentToggleDetections,
                          icon: Icons.grain_rounded,
                          selected: !_showIncidents,
                          onTap: () => _setLayer(showIncidents: false),
                        ),
                        _LayerChip(
                          label: l10n.riskLayerToggle,
                          icon: Icons.thermostat_rounded,
                          selected: _showRiskLayer,
                          onTap: _toggleRiskLayer,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_showIncidents) ...[
                  const SizedBox(height: 6),
                  // Scrollable because the honest filter label is longer than
                  // a convenient one and is worth more than a row that never
                  // scrolls.
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: GlassPanel(
                      padding: const EdgeInsets.all(3),
                      radius: AppSpacing.pillRadius,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: IncidentFilter.values
                            .map(
                              (filter) => _FilterChip(
                                label: filter.label(l10n),
                                count: _incidentCountFor(filter),
                                selected: _incidentFilter == filter,
                                onTap: () => _setIncidentFilter(filter),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ],
                // One line saying what the chosen layer actually contains.
                // "Detections" told the user nothing: the word describes how
                // the data was produced, not what they are looking at.
                const SizedBox(height: 6),
                GlassPanel(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  radius: AppSpacing.cardRadius,
                  child: Text(
                    _showIncidents
                        ? l10n.incidentLayerCaptionEvents
                        : l10n.incidentLayerCaptionDetections,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 11,
                      height: 1.3,
                      color: titleColor.withValues(alpha: 0.78),
                    ),
                  ),
                ),
                if (_showRiskLayer) ...[
                  const SizedBox(height: 6),
                  _buildRiskControls(l10n, titleColor),
                ],
              ],
            ),
          ),

        if (_errorMessage != null)
          Positioned(
            left: 12,
            right: 12,
            top: 12,
            child: GlassPanel(
              padding: const EdgeInsets.all(AppSpacing.lg),
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
                      style: GoogleFonts.ibmPlexSans(
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
          bottom: bottomInset + 12,
          child:
              Column(
                    children: [
                      GlassPanel(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        radius: AppSpacing.largeCardRadius,
                        child: InkWell(
                          onTap: _refreshMap,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.refresh_rounded,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                l10n.commonRefresh,
                                style: GoogleFonts.ibmPlexSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: titleColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      // Always shown (not gated on
                      // _userPosition) — the silent
                      // bootstrap fetch in initState
                      // can race the permission
                      // dialog and come back null;
                      // tapping this is what
                      // (re)fetches a fresh fix now.
                      GlassPanel(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        radius: AppSpacing.largeCardRadius,
                        child: InkWell(
                          onTap: _centerOnUser,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.near_me_rounded,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                l10n.mapGoToMe,
                                style: GoogleFonts.ibmPlexSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: titleColor,
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
          bottom: bottomInset + 12,
          child: GlassPanel(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            radius: AppSpacing.largeCardRadius,
            child: InkWell(
              onTap: () => setState(() => _isLegendOpen = !_isLegendOpen),
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
                    style: GoogleFonts.ibmPlexSans(
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
            bottom: bottomInset + 66,
            child: GlassPanel(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // One legend at a time. The
                  // two layers use different
                  // symbols for different
                  // things, and stacking both
                  // keys produced six rows
                  // with "low confidence"
                  // appearing twice, meaning
                  // two different things.
                  if (_showIncidents)
                    const IncidentLegend()
                  else ...[
                    _LegendRow(
                      color: AppColors.danger,
                      label: l10n.legendProbableFire,
                      textColor: titleColor,
                    ),
                    const SizedBox(height: 8),
                    _LegendRow(
                      color: AppColors.primary,
                      label: l10n.legendHighThermal,
                      textColor: titleColor,
                    ),
                    const SizedBox(height: 8),
                    _LegendRow(
                      color: AppColors.textMuted,
                      label: l10n.legendLowConfidence,
                      textColor: titleColor,
                    ),
                  ],
                ],
              ),
            ).animate().fadeIn(duration: 180.ms).slideY(begin: 0.08, end: 0),
          ),
      ],
    );
  }

  /// Everything the FWI overlay needs while it is on: the forecast-day
  /// picker, the closable legend with the opacity slider, and the CC BY 4.0
  /// attribution — a legal requirement, so it stays even with the legend
  /// closed.
  Widget _buildRiskControls(AppLocalizations l10n, Color titleColor) {
    final classLabels = _riskClassLabels(l10n);
    // The official EFFIS class colours, very low → extreme, defined once in
    // [AppColors] so the legend cannot drift from the raster.
    const fwiColors = [
      AppColors.fwiVeryLow,
      AppColors.fwiLow,
      AppColors.fwiModerate,
      AppColors.fwiHigh,
      AppColors.fwiVeryHigh,
      AppColors.fwiExtreme,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: GlassPanel(
            padding: const EdgeInsets.all(3),
            radius: AppSpacing.pillRadius,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var offset = 0; offset < _riskForecastDays; offset++)
                  _DayChip(
                    label: _riskDayLabel(l10n, offset),
                    selected: _riskDayOffset == offset,
                    onTap: () => setState(() => _riskDayOffset = offset),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        if (_isRiskLegendOpen)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 250),
            child: GlassPanel(
              padding: const EdgeInsets.fromLTRB(12, 8, 8, 10),
              radius: AppSpacing.cardRadius,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.riskLegendTitle,
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: titleColor,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.riskLegendHide,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        iconSize: 16,
                        onPressed: () =>
                            setState(() => _isRiskLegendOpen = false),
                        icon: Icon(
                          Icons.close_rounded,
                          color: titleColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  for (var i = 0; i < fwiColors.length; i++) ...[
                    _LegendRow(
                      color: fwiColors[i],
                      label: classLabels[i],
                      textColor: titleColor,
                    ),
                    if (i < fwiColors.length - 1) const SizedBox(height: 5),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        l10n.riskOpacityLabel,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: titleColor.withValues(alpha: 0.78),
                        ),
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 2,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 7,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 14,
                            ),
                          ),
                          child: Slider(
                            value: _riskOpacity,
                            min: 0.2,
                            max: 1.0,
                            onChanged: (value) =>
                                setState(() => _riskOpacity = value),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    l10n.riskLegendNote,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 10,
                      height: 1.35,
                      color: titleColor.withValues(alpha: 0.66),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          GlassPanel(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            radius: AppSpacing.cardRadius,
            child: InkWell(
              onTap: () => setState(() => _isRiskLegendOpen = true),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.legend_toggle,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.riskLegendTitle,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 6),
        GlassPanel(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          radius: AppSpacing.controlRadius,
          child: Text(
            l10n.riskAttribution,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 9.5,
              color: titleColor.withValues(alpha: 0.72),
            ),
          ),
        ),
      ],
    );
  }

  /// Everything that is not the map. Collapsed it is a title, a one-line
  /// description and the Report button; dragged up it is the help cards and
  /// the nearby-detections list that used to sit above the map.
  Widget _buildInfoSheet(
    ScrollController scrollController,
    AppLocalizations l10n,
    Color titleColor,
    Color secondaryTextColor,
    bool isDark,
  ) {
    final surface = Theme.of(context).scaffoldBackgroundColor;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.largeCardRadius),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.16),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppColors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
      ),
      child: RefreshIndicator(
        onRefresh: _refreshMap,
        color: AppColors.primary,
        child: ListView(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.white.withValues(alpha: 0.22)
                      : Colors.black.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.mapHeaderTitle,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.mapHeaderSubtitle,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 13,
                          height: 1.35,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // Report lives here rather than as a floating button: as a FAB
                // it sat on top of the section heading below it, and there is
                // no scroll position at which a fixed FAB does not cover
                // something in a list this dense.
                FilledButton.icon(
                  key: CoachMarkKeys.mapReportFab,
                  onPressed: _openReportPanel,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 12,
                    ),
                  ),
                  icon: const Icon(Icons.edit_location_alt_rounded, size: 18),
                  label: Text(
                    l10n.mapReport,
                    style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // The colour is a widget, not a character: the dot is drawn in the
            // same red the marker uses, so the sentence and the map cannot
            // drift apart the way a hard-coded emoji did.
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '${l10n.mapMarkerDisclaimerBefore} '),
                  const WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: ColorDot(color: AppColors.danger, size: 9),
                    ),
                  ),
                  TextSpan(text: l10n.mapMarkerDisclaimerAfter),
                ],
              ),
              style: GoogleFonts.ibmPlexSans(
                fontSize: 11.5,
                height: 1.45,
                color: secondaryTextColor,
              ),
            ),
            if (_confidenceFilterActive) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
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
                        style: GoogleFonts.ibmPlexSans(
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
                            style: GoogleFonts.ibmPlexSans(
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

            if (_nearbyFirePoints.isNotEmpty) ...[
              SectionHeader(
                key: CoachMarkKeys.mapNearbyFiresSection,
                title: l10n.mapNearbyFires,
                subtitle: l10n.mapNearbyFiresSubtitle,
                icon: const Icon(Icons.near_me_rounded),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.local_fire_department_rounded,
                                            color: _markerColor(point),
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.md),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // ── Şehir + Bölge ──────────────────────
                                              // Two lines, because a real
                                              // Turkish place name plus its
                                              // region routinely exceeds one:
                                              // "Afyonkarahisar — İç Anadolu"
                                              // was rendering as "Afyonkar…".
                                              Text(
                                                point.cityName != null
                                                    ? '${point.cityName} — ${point.nearestRegion ?? point.regionDisplayName(l10n)}'
                                                    : point.regionDisplayName(
                                                        l10n,
                                                      ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.ibmPlexSans(
                                                  fontSize: 16,
                                                  height: 1.25,
                                                  fontWeight: FontWeight.w800,
                                                  color: titleColor,
                                                ),
                                              ),
                                              Text(
                                                point.distanceKm != null
                                                    ? l10n.notificationsDistanceAndTime(
                                                        point.distanceKm!
                                                            .toStringAsFixed(1),
                                                        timeAgo,
                                                      )
                                                    : timeAgo,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.ibmPlexSans(
                                                  fontSize: 13,
                                                  color: secondaryTextColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    // The chips used to share the title's row,
                                    // where their intrinsic width won and the
                                    // place name lost. On their own row they
                                    // take what they need and the name gets
                                    // the full card width.
                                    Wrap(
                                      spacing: AppSpacing.xs,
                                      runSpacing: AppSpacing.xs,
                                      children: [
                                        StatusChip(
                                          label: point.riskLevelLabel(l10n),
                                          icon: Icons.warning_amber_rounded,
                                          color: AppColors.forRiskTier(
                                            point.riskTier,
                                          ),
                                        ),
                                        StatusChip(
                                          label: fireStatusLabel(
                                            l10n,
                                            point.smartStatus,
                                          ),
                                          showDot: true,
                                          color: fireStatusColor(
                                            point.smartStatus,
                                          ),
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
                                        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            point.riskReasonText(l10n),
                                            style: GoogleFonts.ibmPlexSans(
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
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.ibmPlexSans(
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
                                                  point.mergedSatelliteLabel,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.ibmPlexSans(
                                                    fontSize: 12,
                                                    fontWeight: point.isMerged
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
                                                  point.locationLabelText(l10n),
                                                  style: GoogleFonts.ibmPlexSans(
                                                    fontSize: 12,
                                                    color: secondaryTextColor,
                                                  ),
                                                  maxLines: 1,
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
          ],
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
        Text('$label: ', style: GoogleFonts.ibmPlexSans(fontSize: 13, color: color)),
        Expanded(
          child: Text(
            value,
            // Readout values are mono with tabular figures: a temperature or
            // distance that refreshes must not jitter as its digits change.
            style: AppTheme.mono(
              size: 13,
              weight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
        ?info,
      ],
    );
  }
}

/// One half of the layer switch. Deliberately plain: a filled pill when
/// selected, nothing when not, so the control reads instantly at a glance and
/// never competes with the map itself.
/// A key row for the raw-detection layer: the marker's colour as a dot, then
/// what that colour means. The dot is a widget rather than a coloured emoji
/// so it matches the marker it explains exactly.
class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final Color textColor;

  const _LegendRow({
    required this.color,
    required this.label,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ColorDot(color: color, size: 11),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: GoogleFonts.ibmPlexSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ],
    );
  }
}

/// Compact, icon-free sibling of [_LayerChip]. The count sits inside the chip
/// because "Aktif" alone gives no sense of whether the empty-looking map is
/// empty because nothing is burning or because the filter is hiding things.
class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final idle = isDark
        ? AppColors.white.withValues(alpha: 0.66)
        : Colors.black.withValues(alpha: 0.6);

    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label · ',
              style: GoogleFonts.ibmPlexSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : idle,
              ),
            ),
            // The count refreshes with the data; tabular figures keep the
            // chip from changing width digit by digit.
            Text(
              count.toString(),
              style: AppTheme.mono(
                size: 11.5,
                weight: FontWeight.w700,
                color: selected ? Colors.white : idle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sibling of [_FilterChip] for the FWI forecast-day picker: same compact
/// pill, no count — a forecast day has nothing to count.
class _DayChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DayChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final idle = isDark
        ? AppColors.white.withValues(alpha: 0.66)
        : Colors.black.withValues(alpha: 0.6);

    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
        ),
        child: Text(
          label,
          style: GoogleFonts.ibmPlexSans(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : idle,
          ),
        ),
      ),
    );
  }
}

class _LayerChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _LayerChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final idle = isDark
        ? AppColors.white.withValues(alpha: 0.66)
        : Colors.black.withValues(alpha: 0.6);

    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: selected ? Colors.white : idle),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.ibmPlexSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : idle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
