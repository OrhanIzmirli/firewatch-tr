import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/map_tiles.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/auto_refresh.dart';
import '../../core/utils/detection_score.dart';
import '../../core/utils/loading_race.dart';
import '../../l10n/app_localizations.dart';
import '../../models/fire_incident.dart';
import '../../models/persistent_heat_source.dart';
import '../../models/fire_point.dart';
import '../../models/annual_province_data.dart';
import '../../models/tracked_place.dart';
import '../../models/detection_status.dart';
import '../../services/fwi_point_service.dart';
import '../../services/risk_data_cache.dart';
import '../../core/utils/risk_display.dart';
import '../../shared/widgets/detection_status_card.dart';
import 'widgets/region_risk_layer.dart';
import '../../services/tracked_places_provider.dart';
import '../../services/fire_api_service.dart';
import '../../services/render_api_service.dart';
import '../../services/fire_mapper.dart';
import '../../services/offline_cache_service.dart';
import '../../shared/coach_mark_keys.dart';
import '../../shared/widgets/coach_mark_overlay.dart';
import '../../shared/widgets/color_dot.dart';
import '../../shared/widgets/carto_basemap.dart';
import '../../shared/widgets/detection_safety_notice.dart';
import '../../shared/widgets/glass_panel.dart';
import '../../shared/widgets/province_borders_credit.dart';
import '../../shared/widgets/osm_attribution.dart';
import '../../shared/widgets/report_fire_panel.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/slow_loading_banner.dart';
import '../../shared/widgets/status_chip.dart';
import '../../shared/widgets/trust_info_card.dart';
import 'widgets/incident_legend.dart';
import 'widgets/map_layer_bar.dart';
import 'widgets/marker_list_cache.dart';
import 'widgets/incident_sheet.dart';
import 'widgets/annual_province_layer.dart';
import 'widgets/my_places_sheet.dart';
import '../../services/location_disclosure.dart';
import '../tracked_places/add_tracked_place_flow.dart';
import '../../services/device_position.dart';
import '../../shared/widgets/app_sheet.dart';
import '../../core/utils/detection_summary.dart';
import '../../shared/widgets/alerts_bell.dart';

class MapScreen extends ConsumerStatefulWidget {
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
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  static const _cacheKey = 'map_fires';
  static const _filterPrefKey = 'map_incident_filter';

  bool _isLoading = true;
  String? _errorMessage;
  bool _isSlowLoading = false;

  /// The one collapsible surface over the map. It holds everything that used
  /// to float separately — the merged legend, the FWI day picker, opacity and
  /// attribution — and starts closed: the map is the product, not the panel.
  bool _isLayersPanelOpen = false;

  /// Whether the camera is currently zoomed to a saved place, which is what
  /// makes the one-tap "all of Türkiye" reset appear in the bottom bar.
  bool _isPlaceFocused = false;

  /// "Past years" layer: provinces coloured by OGM burned area for one year
  /// (bundled data, loaded on first use). Mutually exclusive with the FWI
  /// layer — two colour scales on the same ground cannot both be read.
  bool _showAnnualHistory = false;
  bool _annualLoading = false;
  bool _annualLoadFailed = false;
  int _annualYear = AnnualProvinceData.years.last;
  AnnualProvinceData? _annualData;
  final ScrollController _annualYearsController = ScrollController(
    initialScrollOffset: 800,
  );

  Future<void> _toggleAnnualHistory() async {
    final enabled = !_showAnnualHistory;
    setState(() {
      _showAnnualHistory = enabled;
      if (enabled) {
        _showFwiLayer = false;
        _showRegionRisk = false;
      }
    });
    if (!enabled || _annualData != null || _annualLoading) return;
    setState(() {
      _annualLoading = true;
      _annualLoadFailed = false;
    });
    try {
      final data = await AnnualProvinceData.load();
      if (mounted) setState(() => _annualData = data);
    } catch (_) {
      if (mounted) setState(() => _annualLoadFailed = true);
    } finally {
      if (mounted) setState(() => _annualLoading = false);
    }
  }
  late bool _confidenceFilterActive = widget.initialConfidenceFilter;
  /// Zoom drives only marker *size*, so it lives in a notifier the markers
  /// listen to; a setState here used to rebuild — and so re-cluster — every
  /// marker each 0.2 zoom of a pinch.
  final ValueNotifier<double> _zoom = ValueNotifier(_turkeyZoom);
  double get _currentZoom => _zoom.value;
  final MarkerListCache _incidentMarkerCache = MarkerListCache();
  final MarkerListCache _pointMarkerCache = MarkerListCache();

  List<FirePoint> _firePoints = [];
  List<FirePoint> _nearbyFirePoints = [];

  /// Clustered events from /api/incidents. Empty when the endpoint is
  /// unavailable, which is why the raw-detection layer is kept intact.
  List<FireIncident> _incidents = [];

  /// Fixed heat sources from the incident summary, fetched with the raw
  /// detections so their pixels can be drawn grey even when the events
  /// layer failed to load. Unioned with the labelled incidents in
  /// [_persistentSources].
  List<PersistentHeatSource> _summaryPersistentSources = const [];

  List<PersistentHeatSource> get _persistentSources => [
        for (final i in _incidents)
          if (i.isPersistentHeatSource)
            PersistentHeatSource(
              id: i.id,
              latitude: i.latitude,
              longitude: i.longitude,
              cityName: i.cityName,
              distinctDaysSeen: i.distinctDaysSeen,
            ),
        ..._summaryPersistentSources,
      ];

  /// A raw detection sitting on a labelled fixed source (2 km).
  bool _isFixedSourcePoint(FirePoint point) =>
      point.nearPersistentSource ||
      PersistentHeatSource.coversPoint(_persistentSources, point.latitude, point.longitude);

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
  bool _showFwiLayer = false;

  /// The FireWatch risk score by region: the map's "Risk" layer.
  bool _showRegionRisk = false;
  bool _regionRiskFailed = false;
  Map<String, int> _regionScores = const {};

  /// Either colour layer is on, so markers need the high-contrast style.
  bool get _showRiskLayer => _showFwiLayer || _showRegionRisk;

  DetectionStatus? _detectionStatus;
  bool _statusCardDismissed = false;

  /// Overlay opacity. 0.55 keeps the base map readable underneath while the
  /// danger classes stay clearly distinguishable.
  double _riskOpacity = 0.55;

  /// 0 = today … 9 = today+9. The `ecmwf.fwi` layer on EFFIS's global GWIS
  /// service (ECMWF model, worldwide coverage — unlike the old regional
  /// `mf010.fwi`, it does not stop at ~43°E and leave Van and Hakkari blank)
  /// serves a 10-day forecast, today included. The last day can come up
  /// empty until the day's model run is published; the transparent-image
  /// defence below covers that window.
  int _riskDayOffset = 0;

  /// Days the forecast-day picker offers, today included — the verified
  /// horizon of ecmwf.fwi.
  static const int _riskForecastDays = 10;

  /// How much of the screen the info sheet takes when it is resting. Enough
  /// for the title line and the Report button, and no more — the filters,
  /// captions and help text open on a drag. The map owns the rest.
  /// All of Türkiye on a phone: at 5.6 İzmir, Aydın and Muğla were off the
  /// left edge, so events there looked missing.
  static const double _turkeyZoom = 4.9;

  static const double _sheetCollapsedFraction = 0.17;

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
    if (widget.focusLat != null) _zoom.value = 13;
    if (widget.initialIncidentFilter != null) {
      _incidentFilter = widget.initialIncidentFilter!;
    } else {
      _restoreIncidentFilter();
    }
    // The nearby-detections list lives inside the sheet and is built from the
    // raw feed, so opening the sheet is the other thing that needs it.
    _sheetController.addListener(_onSheetMoved);
    _bootstrapMapData().then((_) => _maybeShowMapCoachMarks());
    _autoRefresher.start();
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
    _autoRefresher.dispose();
    _annualYearsController.dispose();
    _tileResetController.close();
    _sheetController.removeListener(_onSheetMoved);
    _sheetController.dispose();
    _mapController.dispose();
    _zoom.dispose();
    super.dispose();
  }

  /// What the on-map "Refresh" button does: re-fetch the fire points *and*
  /// force the tile layer to retry anything that failed, so a user who hit a
  /// dead network has a way back without restarting the app.
  Future<void> _refreshMap() async {
    if (!_tileResetController.isClosed) _tileResetController.add(null);
    await _loadIncidents();
    if (_firePointsRequested) await _loadFirePoints(force: true);
    _autoRefresher.markRefreshed();
  }

  /// Settings › data refresh interval: events and (if already loaded) the
  /// raw feed reload in place, without the loading veil.
  late final AutoRefresher _autoRefresher = AutoRefresher(
    onRefresh: () async {
      await _loadIncidents();
      if (_firePointsRequested) {
        await _loadFirePoints(force: true, silent: true);
      }
    },
  );

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
    if (mounted) _ensureFocusTargetVisible();
  }

  /// Being detected now, below the multi-pass bar, strong heat: counted
  /// from the incidents already loaded, so the events layer can point at
  /// them without fetching the raw feed.
  int get _strongUnverifiedCount =>
      _incidents.where((i) => i.isStrongUnverified).length;

  /// Deep links (a nearby-fire alert, a tracked place) carry coordinates
  /// only. Single-pass detections are no longer on the events layer, so when
  /// nothing on that layer is within 3 km of the target the map would open
  /// on an empty spot: switch to the possible-fire-points layer instead.
  void _ensureFocusTargetVisible() {
    final lat = widget.focusLat;
    final lng = widget.focusLng;
    if (lat == null || lng == null || !_showIncidents) return;
    final hasEventNearby = _incidents.any(
      (i) =>
          IncidentFilter.all.matches(i) &&
          Geolocator.distanceBetween(lat, lng, i.latitude, i.longitude) <=
              3000,
    );
    if (!hasEventNearby) _setLayer(showIncidents: false);
  }

  /// Banner tap: switch to the points layer AND aim the camera at the
  /// strong unverified detections the banner counted.
  void _showStrongUnverifiedOnMap() {
    final targets = _incidents.where((i) => i.isStrongUnverified).toList();
    _setLayer(showIncidents: false);
    if (targets.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (targets.length == 1) {
        _mapController.move(
          LatLng(targets.first.latitude, targets.first.longitude),
          9,
        );
      } else {
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: LatLngBounds.fromPoints([
              for (final t in targets) LatLng(t.latitude, t.longitude),
            ]),
            padding: const EdgeInsets.fromLTRB(48, 190, 48, 320),
            maxZoom: 10,
          ),
        );
      }
    });
  }

  /// Detection confidence is read several times per marker and each read
  /// scans the incident list for nearby multi-pass detections: memoised per
  /// pixel, cleared whenever either feed reloads.
  final Map<String, int> _scoreCache = {};

  int _scoreFor(FirePoint p) => _scoreCache.putIfAbsent(
        '${p.latitude},${p.longitude},${p.acquisitionDate}${p.acquisitionTime}',
        () => detectionConfidenceScoreFor(p, incidents: _incidents),
      );

  /// Attention marker: fresh and strong, never on a labelled fixed source.
  bool _strongUnverifiedPoint(FirePoint p) =>
      !_isFixedSourcePoint(p) &&
      isStrongUnverifiedPoint(p, score: _scoreFor(p));

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
      _showFwiLayer = !_showFwiLayer;
      if (_showFwiLayer) {
        _showAnnualHistory = false;
        _showRegionRisk = false;
      }
    });
    if (_showFwiLayer) _probeForecastDays();
  }

  Future<void> _toggleRegionRisk() async {
    final enabled = !_showRegionRisk;
    setState(() {
      _showRegionRisk = enabled;
      if (enabled) {
        _showFwiLayer = false;
        _showAnnualHistory = false;
        _statusCardDismissed = true;
        _regionRiskFailed = false;
      }
    });
    if (!enabled) return;
    try {
      _annualData ??= await AnnualProvinceData.load();
      await RiskDataCache.instance.warmUp();
      final scores = <String, int>{
        for (final row in RiskDataCache.instance.regions)
          if (row['general_risk_score'] is num)
            foldRegionName('${row['region']}'): (row['general_risk_score'] as num).toInt(),
      };
      if (mounted) {
        setState(() {
          _regionScores = scores;
          _regionRiskFailed = scores.isEmpty;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _regionRiskFailed = true);
    }
  }

  void _showRegionRiskSnack(AppLocalizations l10n, String region, int score) {
    final name = RiskDataCache.instance.regions
        .map((r) => '${r['region']}')
        .firstWhere((r) => foldRegionName(r) == region, orElse: () => region);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(l10n.mapRiskRegionTap(
          displayRegionName(l10n, name),
          score,
          riskLevelLabel(l10n, riskLevelForScore(score)),
        )),
      ));
  }

  Future<void> _loadDetectionStatus() async {
    final status = await _renderApi.fetchDetectionStatus();
    if (mounted) setState(() => _detectionStatus = status);
  }

  void _showLast7Days() {
    setState(() {
      _incidentFilter = IncidentFilter.all;
      _statusCardDismissed = true;
    });
    _setLayer(showIncidents: true);
  }

  void _openPlacesSheet() {
    MyPlacesSheet.show(
      context,
      detectionCount: (place) => _incidents
          .where((i) =>
              !i.looksLikeFixedSource &&
              !i.isKeptOffEvents &&
              i.hoursSinceLastDetection <= 24 &&
              place.isWithinRadius(i.latitude, i.longitude))
          .length,
      onFocusPlace: (place) => _focusPlaces([place]),
      onShowAll: _focusPlaces,
    );
  }

  /// Zooms to the box covering every given place — one place zooms to that
  /// place, "show all" zooms to the union.
  void _focusPlaces(List<TrackedPlace> places) {
    if (places.isEmpty) return;
    var west = double.infinity;
    var south = double.infinity;
    var east = -double.infinity;
    var north = -double.infinity;
    for (final p in places) {
      west = math.min(west, p.longitude - p.lngSpanDegrees);
      south = math.min(south, p.latitude - p.latSpanDegrees);
      east = math.max(east, p.longitude + p.lngSpanDegrees);
      north = math.max(north, p.latitude + p.latSpanDegrees);
    }
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds(LatLng(south, west), LatLng(north, east)),
        // Clear of the top chip row and the collapsed sheet.
        padding: const EdgeInsets.fromLTRB(40, 90, 40, 180),
      ),
    );
    setState(() => _isPlaceFocused = true);
  }

  void _resetTurkeyView() {
    _mapController.move(const LatLng(38.2, 35.0), _turkeyZoom);
    setState(() => _isPlaceFocused = false);
  }

  /// The date the FWI layer shows, as the WMS `TIME` value. TIME is
  /// mandatory: without it EFFIS answers HTTP 200 with a fully transparent
  /// image — the layer looks on and shows nothing, silently.
  String get _fwiDateParam => _fwiDateParamFor(_riskDayOffset);

  String _fwiDateParamFor(int offset) => DateFormat(
    'yyyy-MM-dd',
  ).format(DateTime.now().add(Duration(days: offset)));

  /// Which forecast days the server has actually published, keyed by date.
  /// Missing means "not probed yet" and is treated as published — the tap
  /// gate must never block on ignorance, only on observed emptiness.
  final Map<String, bool> _fwiDayPublished = {};

  /// Probes each picker day with a one-pixel sample over central Anatolia
  /// (always land, always inside coverage when the day is published). An
  /// unpublished day renders fully transparent, which is otherwise
  /// indistinguishable from an "on" layer — the user would just see an
  /// empty map and no reason.
  Future<void> _probeForecastDays() async {
    for (var offset = 0; offset < _riskForecastDays; offset++) {
      final date = _fwiDateParamFor(offset);
      // "Published" is final for the day; "unpublished" is re-probed, since
      // it flips the moment the daily run lands.
      if (_fwiDayPublished[date] == true) continue;
      final sample = await FwiPointService.instance.sample(
        lat: 39.5,
        lng: 34.5,
        date: date,
      );
      // Network failure is "unknown", not "unpublished" — don't block.
      if (sample == null || !mounted) continue;
      setState(() => _fwiDayPublished[date] = sample.hasData);
    }
  }

  String _riskDayLabel(AppLocalizations l10n, int offset) {
    if (offset == 0) return l10n.riskDayToday;
    if (offset == 1) return l10n.riskDayTomorrow;
    // Weekday + day of month: a 10-day picker wraps past one week, so a
    // bare weekday name would appear twice meaning two different dates.
    return DateFormat(
      'EEE d',
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
    _loadDetectionStatus();
    final incidents = await _renderApi.fetchIncidents(days: 7, limit: 300);
    if (!mounted) return;
    final fellBack = incidents.isEmpty && _showIncidents;
    setState(() {
      _incidents = incidents;
      // The nearby component of detection confidence depends on this list.
      _scoreCache.clear();
      if (incidents.isEmpty) _showIncidents = false;
      // The loading veil was only ever cleared by the raw-detection fetch,
      // which the events layer never triggers — so on the default layer it
      // sat over the map forever, dimming it and eating every gesture.
      // Events arriving is this layer's "loaded".
      if (incidents.isNotEmpty) _isLoading = false;
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

  /// Quiet: the card, unless the map is showing events anyway. A problem
  /// with the data: the card whatever the map shows, until it is closed.
  bool _showDetectionCard(DetectionStatus status) {
    if (_statusCardDismissed || status.kind == DetectionStatusKind.strong) return false;
    if (status.kind != DetectionStatusKind.none) return true;
    // Never beside the banner counting strong detections.
    return _visibleIncidents.isEmpty && _strongUnverifiedCount == 0;
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
        if (!mounted) return null;
        permission = await LocationDisclosure.requestPermission(context);
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
      return await DevicePosition.current(accuracy: LocationAccuracy.low, timeLimit: const Duration(seconds: 10));
    } catch (_) {
      return null;
    }
  }

  /// [force] skips the two-minute feed memo; [silent] keeps the loading
  /// veil down (auto refresh updates the markers in place).
  Future<void> _loadFirePoints({bool force = false, bool silent = false}) async {
    // Best-effort, in parallel with the feed: the summary carries the fixed
    // heat sources so their pixels are drawn grey on this layer too.
    _renderApi.fetchIncidentSummary().then((summary) {
      if (!mounted || summary == null) return;
      setState(() => _summaryPersistentSources = summary.persistentHeatSources);
    });
    if (!silent) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _isSlowLoading = false;
      });
    }
    try {
      final firePoints = await raceWithCacheFallback(
        fetch: retryOnce(
          () => _fireApiService.fetchTurkeyFiresWithCities(force: force),
        ),
        timeout: const Duration(seconds: 12),
        cacheKey: _cacheKey,
        onSlowFallback: (cached) {
          // A silent refresh never swaps fresh data for the offline copy.
          if (silent || !mounted) return;
          final (data, _) = cached;
          final points = (data as List)
              .map((e) => FirePoint.fromJson(e as Map<String, dynamic>))
              .toList();
          setState(() {
            _scoreCache.clear();
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
        _scoreCache.clear();
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
      // Silent refresh failed: keep the markers on screen, no error banner.
      if (silent) return;
      final cached = await OfflineCacheService.instance.load(_cacheKey);
      if (!mounted) return;
      if (cached != null) {
        final (data, _) = cached;
        final points = (data as List)
            .map((e) => FirePoint.fromJson(e as Map<String, dynamic>))
            .toList();
        setState(() {
          _scoreCache.clear();
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

  /// Marker colour by detection confidence (see detection_score.dart):
  /// ≥65 danger, ≥40 warning, else grey. It grades the evidence behind the
  /// pixel — tier, power, nearby multi-pass detections, age — and says
  /// nothing about whether it is a fire. FirePoint.detectionColor still
  /// drives the bottom sheet header and is deliberately left alone.
  Color _markerColor(FirePoint point) {
    // A pixel on a steelworks is not a fire of any confidence.
    if (_isFixedSourcePoint(point)) return AppColors.textFaint;
    final score = _scoreFor(point);
    if (score >= kDetectionConfidenceHigh) return AppColors.danger;
    if (score >= kDetectionConfidenceMedium) return AppColors.warning;
    return Colors.grey;
  }

  /// Base marker size (at the reference zoom) on the same bands, so weak
  /// pixels shrink and the map is not dominated by noise.
  double _baseMarkerSize(FirePoint point) {
    final score = _scoreFor(point);
    if (score >= kDetectionConfidenceHigh) return 28;
    if (score >= kDetectionConfidenceMedium) return 22;
    return 16;
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
    // Fresh, strong, unverified: an attention marker so the eye finds it —
    // an amber ring with an exclamation mark, never a flame. It does not
    // pulse (a single pixel has not earned "live"), and the sheet states
    // in words that it is not verified.
    if (_strongUnverifiedPoint(point)) {
      final d = (size * 0.9).clamp(20.0, 40.0);
      return Container(
        width: d,
        height: d,
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.warning, width: 2.4),
          boxShadow: [
            BoxShadow(
              color: AppColors.warning.withValues(alpha: 0.45),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(
          Icons.priority_high_rounded,
          color: AppColors.warning,
          size: d * 0.62,
        ),
      );
    }
    // Over the FWI raster the tier colours stop working: a red disc on the
    // red "very high" band is invisible. The risk-on variant is a near-black
    // disc with a white ring — the ring carries the edge on the dark FWI
    // bands, the disc on the light ones — and the tier colour moves to a
    // centre dot, where it reads against the dark disc instead of the map.
    if (_showRiskLayer) {
      return Container(
        width: size * 0.62,
        height: size * 0.62,
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.92),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Center(
          child: ColorDot(color: color, size: size * 0.26),
        ),
      );
    }
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
    // Official status markers, both unreachable while
    // FeatureFlags.officialStatus is off (no reliable TR source yet).
    // A conflict ("officially out", satellite still sees heat) never gets
    // the reassuring green check: it is drawn amber.
    if (incident.hasExtinguishedConflict || incident.isOfficiallyExtinguished) {
      final conflict = incident.hasExtinguishedConflict;
      final color = conflict ? AppColors.warning : AppColors.success;
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.9),
          border: Border.all(color: Colors.white, width: 1.6),
        ),
        child: showIcon
            ? Icon(
                conflict ? Icons.report_problem_rounded : Icons.check_rounded,
                color: Colors.white,
                size: size * 0.56,
              )
            : null,
      );
    }
    // Same contrast problem as the raw detections: a danger-red event disc
    // disappears on the FWI raster's red and maroon bands. With the risk
    // layer on, the disc goes near-black with a solid white ring and the
    // status colour moves to the glyph (or a centre dot when too small for
    // one), which stays readable on all six FWI class colours.
    if (_showRiskLayer) {
      return DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.background.withValues(alpha: 0.92),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: SizedBox(
          width: size,
          height: size,
          child: showIcon
              ? Icon(status.icon, color: status.color, size: size * 0.56)
              : Center(child: ColorDot(color: status.color, size: size * 0.3)),
        ),
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: (incident.looksLikeFixedSource ? Colors.grey : status.color)
            .withValues(
              alpha: incident.looksLikeFixedSource ? 0.55 : status.fillOpacity,
            ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.9),
          width: size >= 18 ? 1.6 : 1.1,
        ),
        boxShadow:
            status == IncidentStatus.activeDetection &&
                !incident.looksLikeFixedSource
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

  /// Event markers, rebuilt only when the events, the filter or the
  /// risk-layer styling change (see MarkerListCache). Marker size follows
  /// zoom through [_zoom] without rebuilding the list.
  List<Marker> get _incidentMarkers => _incidentMarkerCache.get(
        [_incidents, _incidentFilter, _showRiskLayer],
        () {
          _incidentByMarkerKey.clear();
          return [
            for (final incident in _visibleIncidents)
              _incidentMarker(incident),
          ];
        },
      );

  Marker _incidentMarker(FireIncident incident) {
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
        child: ValueListenableBuilder<double>(
          valueListenable: _zoom,
          builder: (context, _, _) => Center(child: _buildIncidentMarker(incident)),
        ),
      ),
    );
  }

  /// Raw detection markers, same rules as [_incidentMarkers]. The incident
  /// list is an input too: it feeds the nearby part of detection confidence.
  /// Strong unverified pixels are left out here and drawn on their own
  /// layer ([_attentionMarkers]) so they never average into a bubble.
  List<Marker> get _pointMarkers => _pointMarkerCache.get(
        [_firePoints, _incidents, _confidenceFilterActive, _showRiskLayer],
        () => [
          for (final point in _visibleFirePoints)
            if (!_strongUnverifiedPoint(point))
            Marker(
              point: LatLng(point.latitude, point.longitude),
              width: 48,
              height: 48,
              child: GestureDetector(
                onTap: () => _openFireBottomSheet(point),
                child: ValueListenableBuilder<double>(
                  valueListenable: _zoom,
                  builder: (context, _, _) => Center(child: _buildMarkerIcon(point)),
                ),
              ),
            ),
        ],
      );

  final MarkerListCache _attentionMarkerCache = MarkerListCache();

  /// Strong unverified pixels: always on top, never clustered.
  List<Marker> get _attentionMarkers => _attentionMarkerCache.get(
        [_firePoints, _incidents, _confidenceFilterActive, _showRiskLayer],
        () => [
          for (final point in _visibleFirePoints)
            if (_strongUnverifiedPoint(point))
              Marker(
                point: LatLng(point.latitude, point.longitude),
                width: 52,
                height: 52,
                child: GestureDetector(
                  onTap: () => _openFireBottomSheet(point),
                  child: ValueListenableBuilder<double>(
                    valueListenable: _zoom,
                    builder: (context, _, _) =>
                        Center(child: _buildMarkerIcon(point)),
                  ),
                ),
              ),
        ],
      );

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
      case IncidentStatus.persistentHeatSource:
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
      case IncidentStatus.persistentHeatSource:
        fill = AppColors.textFaint;
        fillAlpha = 0.8;
    }

    // High-contrast variant over the FWI raster: dark bubble, solid white
    // ring, and the status colour on the glyph instead of the fill — same
    // reasoning as the single markers.
    final onRisk = _showRiskLayer;

    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: onRisk
              ? AppColors.background.withValues(alpha: 0.92)
              : fill.withValues(alpha: fillAlpha),
          shape: BoxShape.circle,
          border: Border.all(
            color: onRisk
                ? Colors.white
                : Colors.white.withValues(alpha: hasActive ? 0.95 : 0.75),
            width: onRisk ? 2 : (hasActive ? 2.5 : 1.8),
          ),
          boxShadow: onRisk
              ? null
              : [
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
                  color: onRisk ? AppColors.danger : Colors.white,
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
    final cover = _farmOrBuiltNear(point);

    showAppSheet(
      context,
      flatGlass: true,
      scrollable: false,
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

        // Scrolls: with the safety notice the card is taller than a small
        // phone's sheet allowance.
        return SingleChildScrollView(
          child: Padding(
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
                DetectionSafetyNotice(
                  prominent: point.riskTier == 'high' &&
                      cover == null &&
                      (point.smartStatus == FireStatus.active || point.smartStatus == FireStatus.likelyActive),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    StatusChip(
                      label: fireStatusLabel(l10n, point.smartStatus, seenAt: point.detectionDateTimeUtc),
                      showDot: true,
                      color: fireStatusColor(point.smartStatus),
                    ),
                  ],
                ),
                if (_strongUnverifiedPoint(point)) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.mapStrongUnverifiedReason,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warning,
                    ),
                  ),
                ],
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
                  detectionSummaryText(
                    l10n,
                    city: point.cityName,
                    strong: point.riskTier == 'high' || _strongUnverifiedPoint(point),
                    newsVerified: false,
                    // The line below says it; once is enough.
                    landCover: null,
                    age: DateTime.now().toUtc().difference(point.detectionDateTimeUtc ?? DateTime.now().toUtc()),
                  ),
                  key: const Key('pointSummary'),
                  style: GoogleFonts.ibmPlexSans(fontSize: 14.5, height: 1.5, fontWeight: FontWeight.w600, color: titleColor),
                ),
                if (cover != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    cover == 'agriculture' ? l10n.mapPointFarmland : l10n.mapPointBuilt,
                    key: const Key('pointLandCover'),
                    style: GoogleFonts.ibmPlexSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.warning),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
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
        actions: const [AlertsBell()],
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
              backgroundColor: AppColors.surface,
              initialCenter: widget.focusLat != null
                  ? LatLng(widget.focusLat!, widget.focusLng!)
                  // Biased south of Turkey's true centre: the map now runs
                  // full-bleed and its lower quarter sits behind the info
                  // sheet, so centring on 39N put a third of the country
                  // under the sheet and filled the visible half with the
                  // Black Sea.
                  : const LatLng(38.2, 35.0),
              initialZoom: widget.focusLat != null ? 13 : _turkeyZoom,
              minZoom: 4,
              // z16 only gets you to neighbourhood level,
              // which isn't enough to place a fire; 18 is
              // street level and still within OSM's z19
              // native limit, so tiles stay sharp.
              maxZoom: 18,
              onPositionChanged: (camera, hasGesture) {
                if ((camera.zoom - _currentZoom).abs() > 0.2) {
                  _zoom.value = camera.zoom;
                }
              },
              // Long-press: add this point to "Yerlerim".
              onLongPress: (tapPosition, point) {
                showAddTrackedPlaceFlow(context, initialPoint: point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: CartoBasemap.configured ? CartoBasemap.url : MapTiles.osmUrl,
                // Disk-cached when it is OSM; CARTO always from the network.
                tileProvider: MapTiles.providerFor(
                  CartoBasemap.configured ? CartoBasemap.url : MapTiles.osmUrl,
                ),
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
              if (_showAnnualHistory && _annualData != null)
                AnnualProvinceLayer(data: _annualData!, year: _annualYear),
              // The FWI raster sits between the base map and the markers:
              // danger paints the ground, detections stay on top. Built only
              // while the risk toggle is on, so no WMS request ever leaves
              // the device with the layer off.
              if (_showRegionRisk && _annualData != null && _regionScores.isNotEmpty)
                RegionRiskLayer(
                  areas: _annualData!.areas,
                  scores: _regionScores,
                  onRegionTap: (region, score) => _showRegionRiskSnack(l10n, region, score),
                ),
              if (_showFwiLayer)
                Opacity(
                  opacity: _riskOpacity,
                  child: TileLayer(
                    // TileLayer does not watch wmsOptions for changes, so a
                    // new date has to replace the layer outright or stale
                    // tiles would survive the switch.
                    key: ValueKey('fwi-$_fwiDateParam'),
                    wmsOptions: WMSTileLayerOptions(
                      baseUrl:
                          'https://maps.effis.emergency.copernicus.eu/gwis?',
                      layers: const ['ecmwf.fwi'],
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
              // Saved pins stay visible: unlike a province, a dropped pin
              // has no border on the basemap, so without a marker "zoom to
              // my pin" would land on anonymous terrain.
              MarkerLayer(
                markers: [
                  for (final place in ref.watch(trackedPlacesProvider).places)
                      Marker(
                        point: LatLng(place.latitude, place.longitude),
                        width: 36,
                        height: 36,
                        child: const Icon(
                          Icons.push_pin_rounded,
                          size: 26,
                          color: AppColors.info,
                          shadows: [
                            Shadow(color: Colors.white, blurRadius: 4),
                          ],
                        ),
                      ),
                ],
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
                    maxClusterRadius: 88,
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
                    markers: _incidentMarkers,
                    builder: (context, markers) =>
                        _buildIncidentCluster(markers),
                  ),
                )
              else ...[
                MarkerClusterLayerWidget(
                  options: MarkerClusterLayerOptions(
                    maxClusterRadius: 72,
                    size: const Size(40, 40),
                    alignment: Alignment.center,
                    markers: _pointMarkers,
                    builder: (context, markers) => Container(
                      decoration: BoxDecoration(
                        // Dark + ringed over the FWI raster, like the
                        // single markers: orange-on-orange is invisible.
                        color: _showRiskLayer
                            ? AppColors.background.withValues(alpha: 0.92)
                            : AppColors.primary,
                        shape: BoxShape.circle,
                        border: _showRiskLayer
                            ? Border.all(color: Colors.white, width: 2)
                            : null,
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
                MarkerLayer(markers: _attentionMarkers),
              ],
            ],
          ),
        ),
        if (_isLoading && !_showAnnualHistory)
          // A translucent veil, not a barrier: the map stays usable while
          // data loads.
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: Colors.black.withValues(alpha: 0.12),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
        // The one permanent surface at the top: which layers are on. The
        // filters and captions that used to stack here live in the sheet
        // now, and the FWI controls live in the layers panel. The error
        // banner shares this column so it can never cover the chips.
        Positioned(
          left: 12,
          top: 12,
          right: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MapLayerBar(
                    children: [
                      _LayerChip(
                        label: l10n.incidentToggleShowShort,
                        icon: Icons.local_fire_department_rounded,
                        selected: _showIncidents,
                        onTap: () => _setLayer(showIncidents: true),
                      ),
                      _LayerChip(
                        label: l10n.incidentToggleDetectionsShort,
                        icon: Icons.grain_rounded,
                        selected: !_showIncidents,
                        onTap: () => _setLayer(showIncidents: false),
                      ),
                      _LayerChip(
                        key: const Key('mapRiskChip'),
                        label: l10n.mapRiskLayer,
                        icon: Icons.thermostat_rounded,
                        selected: _showRegionRisk,
                        onTap: _toggleRegionRisk,
                      ),
                      _LayerChip(
                        label: l10n.riskLayerToggle,
                        icon: Icons.public_rounded,
                        selected: _showFwiLayer,
                        onTap: _toggleRiskLayer,
                      ),
                      _LayerChip(
                        label: l10n.annualLayerToggle,
                        icon: Icons.history_rounded,
                        selected: _showAnnualHistory,
                        onTap: _toggleAnnualHistory,
                      ),
                    ],
                ),
              if (_showIncidents && _strongUnverifiedCount > 0) ...[
                const SizedBox(height: 6),
                GestureDetector(
                  key: const ValueKey('strong-unverified-banner'),
                  onTap: _showStrongUnverifiedOnMap,
                  child: GlassPanel(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    radius: AppSpacing.cardRadius,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.priority_high_rounded,
                          size: 16,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            l10n.mapStrongUnverifiedBanner(
                              _strongUnverifiedCount,
                            ),
                            style: GoogleFonts.ibmPlexSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: titleColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: titleColor.withValues(alpha: 0.7),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (_showRegionRisk) ...[
                const SizedBox(height: 6),
                GlassPanel(
                  key: const Key('mapRiskNotFire'),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  radius: AppSpacing.cardRadius,
                  child: Text(
                    _regionRiskFailed ? l10n.mapRiskUnavailable : l10n.riskColorsNotFire,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: _regionRiskFailed ? AppColors.warning : titleColor,
                    ),
                  ),
                ),
              ],
              if (_detectionStatus case final status?) ...[
                const SizedBox(height: 6),
                if (_showDetectionCard(status))
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.46),
                    child: SingleChildScrollView(
                      child: DetectionStatusCard(
                        status: status,
                        onRetry: _refreshMap,
                        onDismiss: () => setState(() => _statusCardDismissed = true),
                        onReport: () => showReportFirePanel(context, initialType: ReportType.missingFire),
                        onShowLast7Days: status.kind == DetectionStatusKind.unavailable ? null : _showLast7Days,
                        onOpenRisk: _showRegionRisk ? null : _toggleRegionRisk,
                      ),
                    ),
                  )
                else
                  GlassPanel(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    radius: AppSpacing.cardRadius,
                    child: DetectionFreshnessLine(status: status),
                  ),
              ],
              if (_showAnnualHistory) ...[
                const SizedBox(height: 6),
                _buildAnnualStrip(l10n, titleColor),
              ],
              if (_errorMessage != null) ...[
                const SizedBox(height: 6),
                GlassPanel(
                  padding: const EdgeInsets.all(AppSpacing.md),
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
              ],
            ],
          ),
        ),
        // The one permanent surface at the bottom: the layers-panel toggle
        // plus refresh and go-to-me as icon actions, in a single bar. Go-to
        // -me stays visible even without a fix — the silent bootstrap fetch
        // can race the permission dialog, and tapping this is what
        // (re)fetches a fresh one.
        Positioned(
          left: 12,
          bottom: bottomInset + 12,
          child: GlassPanel(
            padding: const EdgeInsets.all(4),
            radius: AppSpacing.pillRadius,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _LayerChip(
                  label: l10n.mapLayersButton,
                  icon: Icons.layers_rounded,
                  selected: _isLayersPanelOpen,
                  onTap: () {
                    setState(
                      () => _isLayersPanelOpen = !_isLayersPanelOpen,
                    );
                    // Refresh which days are published every time the panel
                    // opens — an unpublished day flips when the run lands.
                    if (_isLayersPanelOpen && _showFwiLayer) {
                      _probeForecastDays();
                    }
                  },
                ),
                _MapIconAction(
                  icon: Icons.bookmark_rounded,
                  tooltip: l10n.placesButton,
                  onTap: _openPlacesSheet,
                ),
                _MapIconAction(
                  icon: Icons.refresh_rounded,
                  tooltip: l10n.commonRefresh,
                  onTap: _refreshMap,
                ),
                _MapIconAction(
                  icon: Icons.near_me_rounded,
                  tooltip: l10n.mapGoToMe,
                  onTap: _centerOnUser,
                ),
                if (_isPlaceFocused)
                  _MapIconAction(
                    icon: Icons.zoom_out_map_rounded,
                    tooltip: l10n.placesResetView,
                    onTap: _resetTurkeyView,
                  ),
              ],
            ),
          ).animate(delay: 240.ms).fadeIn(duration: 280.ms).slideY(begin: 0.2, end: 0),
        ),
        // Attribution is a legal requirement, not a UI element: bare text on
        // the map edge, no box. The halo keeps it readable over any of the
        // six FWI band colours. Repeated inside the layers panel.
        Positioned(
            right: 12,
            bottom: bottomInset + 18,
            // Tappable: opens openstreetmap.org/copyright.
            child: OsmAttribution(
              extra: [
                if (CartoBasemap.configured) '© CARTO',
                if (_showFwiLayer) l10n.riskAttribution,
              ],
            ),
          ),
        if (_isLayersPanelOpen)
          Positioned(
            left: 12,
            bottom: bottomInset + 64,
            child: _buildLayersPanel(l10n, titleColor)
                .animate()
                .fadeIn(duration: 180.ms)
                .slideY(begin: 0.08, end: 0),
          ),
      ],
    );
  }

  /// The layers panel: the merged legend for whatever is currently on, plus
  /// the FWI forecast-day picker, opacity slider and attribution while the
  /// risk layer is active. One collapsible panel instead of the two legends
  /// and three floating boxes it replaced.
  /// Year picker and one-line caption for the "Past years" layer, under the
  /// layer chips. Province taps open their own detail sheet.
  Widget _buildAnnualStrip(AppLocalizations l10n, Color titleColor) {
    final caption = _annualLoadFailed
        ? l10n.annualLayerLoadError
        : l10n.annualLayerCaption(_annualYear);
    return GlassPanel(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, AppSpacing.sm),
      radius: AppSpacing.cardRadius,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 36,
            child: ListView(
              controller: _annualYearsController,
              scrollDirection: Axis.horizontal,
              children: [
                for (final year in AnnualProvinceData.years)
                  _DayChip(
                    label: '$year',
                    selected: _annualYear == year,
                    onTap: () => setState(() => _annualYear = year),
                  ),
              ],
            ),
          ),
          if (_annualLoading)
            const LinearProgressIndicator(minHeight: 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Text(
              caption,
              style: GoogleFonts.ibmPlexSans(
                fontSize: 11,
                height: 1.3,
                color: _annualLoadFailed
                    ? AppColors.warning
                    : titleColor.withValues(alpha: 0.78),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayersPanel(AppLocalizations l10n, Color titleColor) {
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
    final sectionStyle = GoogleFonts.ibmPlexSans(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: titleColor,
    );
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300, maxHeight: 420),
      child: GlassPanel(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
        ),
        radius: AppSpacing.largeCardRadius,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.layers_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      l10n.mapLayersButton,
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 13,
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
                        setState(() => _isLayersPanelOpen = false),
                    icon: Icon(
                      Icons.close_rounded,
                      color: titleColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              if (_showRegionRisk) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(l10n.mapRiskLegendTitle, style: sectionStyle),
                const SizedBox(height: 6),
                _LegendRow(color: colorForApiRiskLevel('Low'), label: l10n.mapRiskLegendLow, textColor: titleColor),
                const SizedBox(height: 5),
                _LegendRow(color: colorForApiRiskLevel('Medium'), label: l10n.mapRiskLegendMedium, textColor: titleColor),
                const SizedBox(height: 5),
                _LegendRow(color: colorForApiRiskLevel('High'), label: l10n.mapRiskLegendHigh, textColor: titleColor),
                const SizedBox(height: 5),
                _LegendRow(color: colorForApiRiskLevel('Critical'), label: l10n.mapRiskLegendCritical, textColor: titleColor),
                const SizedBox(height: 6),
                Text(
                  l10n.riskColorsNotFire,
                  style: GoogleFonts.ibmPlexSans(fontSize: 10.5, height: 1.35, fontWeight: FontWeight.w700, color: titleColor),
                ),
                Divider(height: AppSpacing.lg, color: titleColor.withValues(alpha: 0.12)),
              ],
              if (_showFwiLayer) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(l10n.riskLegendTitle, style: sectionStyle),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 2,
                  runSpacing: 2,
                  children: [
                    for (var offset = 0; offset < _riskForecastDays; offset++)
                      _DayChip(
                        label: _riskDayLabel(l10n, offset),
                        selected: _riskDayOffset == offset,
                        // Dimmed but still tappable: a dead-looking chip
                        // with no reason teaches nothing. The tap explains
                        // instead of selecting, so nobody lands on the
                        // blank layer an unpublished day renders as.
                        dimmed: _fwiDayPublished[_fwiDateParamFor(offset)] ==
                            false,
                        onTap: () {
                          if (_fwiDayPublished[_fwiDateParamFor(offset)] ==
                              false) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.riskDayNotPublished),
                              ),
                            );
                            return;
                          }
                          setState(() => _riskDayOffset = offset);
                        },
                      ),
                  ],
                ),
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
                for (var i = 0; i < fwiColors.length; i++) ...[
                  _LegendRow(
                    color: fwiColors[i],
                    label: classLabels[i],
                    textColor: titleColor,
                  ),
                  if (i < fwiColors.length - 1) const SizedBox(height: 5),
                ],
                const SizedBox(height: 6),
                Text(
                  l10n.riskLegendNote,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 10,
                    height: 1.35,
                    color: titleColor.withValues(alpha: 0.66),
                  ),
                ),
                Divider(
                  height: AppSpacing.lg,
                  color: titleColor.withValues(alpha: 0.12),
                ),
              ] else
                const SizedBox(height: AppSpacing.sm),
              if (_showAnnualHistory) ...[
                AnnualLegend(
                  logMax: _annualData?.logMax ?? AnnualLegend.defaultLogMax,
                ),
                ProvinceBordersCredit(color: titleColor.withValues(alpha: 0.66)),
                Divider(
                  height: AppSpacing.lg,
                  color: titleColor.withValues(alpha: 0.12),
                ),
              ],
              // The marker key for whichever fire layer is on. One legend at
              // a time — stacking both produced "low confidence" twice,
              // meaning two different things.
              Text(l10n.mapLegendTitle, style: sectionStyle),
              const SizedBox(height: 6),
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
              if (_showFwiLayer) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.riskAttribution,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 9.5,
                    color: titleColor.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
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
            // What the chosen layer contains, and which slice of it is
            // drawn. Both moved down from the map surface: the caption is
            // read once, the filter is adjusted occasionally, and neither
            // earns a permanent box over the map.
            Text(
              _showIncidents
                  ? l10n.incidentLayerCaptionEvents
                  : l10n.incidentLayerCaptionDetections,
              style: GoogleFonts.ibmPlexSans(
                fontSize: 12,
                height: 1.4,
                color: secondaryTextColor,
              ),
            ),
            if (_showIncidents && _incidents.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
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

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
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

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
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
      ),
    );
  }
}

/// Icon-only action in the bottom bar. A [_LayerChip] without the label:
/// refresh and go-to-me are verbs the icon already carries, and two labelled
/// buttons were most of what made the old bottom row two panels tall.
class _MapIconAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _MapIconAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Icon(icon, size: 18, color: AppColors.primary),
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

  /// The forecast for this day has not been published yet: drawn faded, and
  /// the caller's onTap explains instead of selecting.
  final bool dimmed;
  final VoidCallback onTap;

  const _DayChip({
    required this.label,
    required this.selected,
    this.dimmed = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final idle = isDark
        ? AppColors.white.withValues(alpha: dimmed ? 0.28 : 0.66)
        : Colors.black.withValues(alpha: dimmed ? 0.25 : 0.6);

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
    super.key,
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
