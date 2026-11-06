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
  void _fit() {
    if (!_ready) return;
    final areas = widget.selected == null ? widget.focusAreas : [widget.selected!];
    final points = areas?.expand((a) => a.points).toList() ?? [const LatLng(35.8,25.6), const LatLng(42.2,44.8)];
    if (points.isNotEmpty) _controller.fitCamera(CameraFit.bounds(bounds: LatLngBounds.fromPoints(points), padding: const EdgeInsets.all(35)));
  }
  @override
  void didUpdateWidget(covariant AreaMap oldWidget) { super.didUpdateWidget(oldWidget); if (oldWidget.selected != widget.selected || oldWidget.focusAreas != widget.focusAreas) _fit(); }
  @override
  void dispose() { _hit.dispose(); _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Stack(children: [
    FlutterMap(mapController: _controller, options: MapOptions(
      backgroundColor: const Color(0xFF111827),
      initialCenter: const LatLng(39,35), initialZoom: 5, minZoom: 4, maxZoom: 18,
      onMapReady: () { _ready = true; _fit(); },
      onTap: (_,point) { final id = _hit.value?.hitValues.firstOrNull; final area = widget.areas.where((a) => a.id == id).firstOrNull; if (area != null) widget.onSelected(area); }),
      children: [const CartoTiles(), PolygonLayer<String>(hitNotifier: _hit, polygons: [
        for (final area in widget.areas) for (final polygon in area.polygons) Polygon<String>(
          points: polygon.first, holePointsList: polygon.skip(1).toList(), hitValue: area.id,
          color: widget.color(area).withValues(alpha: area == widget.selected ? 0.8 : 0.55),
          borderColor: area == widget.selected ? Colors.white : widget.color(area), borderStrokeWidth: area == widget.selected ? 3 : 1.5),
      ])]),
    const Positioned(left: 0, right: 0, bottom: 0, child: MapAttribution()),
  ]);
}
