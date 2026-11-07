import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/geo_area.dart';
import 'carto_basemap.dart';

class AreaMap extends StatefulWidget {
  final List<GeoArea> areas;
  final GeoArea? selected;
  final List<GeoArea>? focusAreas;
  final Color Function(GeoArea) color;
  final ValueChanged<GeoArea> onSelected;
  const AreaMap({super.key, required this.areas, required this.color, required this.onSelected, this.selected, this.focusAreas});
  @override
  State<AreaMap> createState() => _AreaMapState();
}
class _AreaMapState extends State<AreaMap> {
  final _controller = MapController();
  final LayerHitNotifier<String> _hit = ValueNotifier(null);
  bool _ready = false;

  /// Built once per data change and reused as the *same widget instance*.
  /// flutter_map's PolygonLayer drops its projection cache whenever its
  /// widget updates, so rebuilding it on every setState (a tap, a sheet)
  /// re-projected every vertex — ~83k for a fire season of history. The
  /// selection is drawn by a separate, tiny layer on top.
  late PolygonLayer<String> _baseLayer;

  @override
  void initState() {
    super.initState();
    _baseLayer = _buildBaseLayer();
  }

  PolygonLayer<String> _buildBaseLayer() => PolygonLayer<String>(hitNotifier: _hit, polygons: [
        for (final area in widget.areas)
          for (final polygon in area.polygons)
            Polygon<String>(
              points: polygon.first,
              holePointsList: polygon.skip(1).toList(),
              hitValue: area.id,
              color: widget.color(area).withValues(alpha: 0.55),
              borderColor: widget.color(area),
              borderStrokeWidth: 1.5,
            ),
      ]);
  void _fit() {
    if (!_ready) return;
    final areas = widget.selected == null ? widget.focusAreas : [widget.selected!];
    final points = areas?.expand((a) => a.points).toList() ?? [const LatLng(35.8,25.6), const LatLng(42.2,44.8)];
    if (points.isNotEmpty) _controller.fitCamera(CameraFit.bounds(bounds: LatLngBounds.fromPoints(points), padding: const EdgeInsets.all(35)));
  }
  @override
  void didUpdateWidget(covariant AreaMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Callers pass a freshly filtered list on each build; compare contents.
    if (!listEquals(oldWidget.areas, widget.areas)) _baseLayer = _buildBaseLayer();
    if (oldWidget.selected != widget.selected || oldWidget.focusAreas != widget.focusAreas) _fit();
  }
  @override
  void dispose() { _hit.dispose(); _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Stack(children: [
    FlutterMap(mapController: _controller, options: MapOptions(
      backgroundColor: const Color(0xFF111827),
      initialCenter: const LatLng(39,35), initialZoom: 5, minZoom: 4, maxZoom: 18,
      onMapReady: () { _ready = true; _fit(); },
      onTap: (_,point) { final id = _hit.value?.hitValues.firstOrNull; final area = widget.areas.where((a) => a.id == id).firstOrNull; if (area != null) widget.onSelected(area); }),
      children: [
        const CartoTiles(),
        _baseLayer,
        if (widget.selected case final selected?)
          PolygonLayer<String>(polygons: [
            for (final polygon in selected.polygons)
              Polygon<String>(
                points: polygon.first,
                holePointsList: polygon.skip(1).toList(),
                color: widget.color(selected).withValues(alpha: 0.8),
                borderColor: Colors.white,
                borderStrokeWidth: 3,
              ),
          ]),
      ]),
    const Positioned(left: 0, right: 0, bottom: 0, child: MapAttribution()),
  ]);
}
