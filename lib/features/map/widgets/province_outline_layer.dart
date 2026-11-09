import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../models/geo_area.dart';

/// Colours for the province lines and names over one kind of basemap.
class ProvinceOutlineStyle {
  final Color line;
  final Color casing;
  final Color mask;
  final Color label;
  final Color labelHalo;

  const ProvinceOutlineStyle({
    required this.line,
    required this.casing,
    required this.mask,
    required this.label,
    required this.labelHalo,
  });

  static const dark = ProvinceOutlineStyle(
    line: Color(0xFFE8E4DE),
    casing: Color(0x8C000000),
    mask: Color(0x73000000),
    label: Color(0xFFFFFFFF),
    labelHalo: Color(0xE6000000),
  );

  static const light = ProvinceOutlineStyle(
    line: Color(0xFF4A3F36),
    casing: Color(0xB3FFFFFF),
    mask: Color(0x38000000),
    label: Color(0xFF1C1814),
    labelHalo: Color(0xF2FFFFFF),
  );
}

/// Where a province's name goes: the area centroid of its largest polygon, so
/// an island or a coastal fragment cannot pull it away.
LatLng provinceLabelPoint(GeoArea area) {
  double signedArea(List<LatLng> r) {
    var sum = 0.0;
    for (var i = 0; i < r.length - 1; i++) {
      sum += r[i].longitude * r[i + 1].latitude - r[i + 1].longitude * r[i].latitude;
    }
    return sum / 2;
  }

  var ring = area.polygons.first.first;
  for (final polygon in area.polygons) {
    if (signedArea(polygon.first).abs() > signedArea(ring).abs()) ring = polygon.first;
  }
  final a = signedArea(ring);
  if (a == 0) return ring.first;
  var lat = 0.0;
  var lng = 0.0;
  for (var i = 0; i < ring.length - 1; i++) {
    final cross = ring[i].longitude * ring[i + 1].latitude - ring[i + 1].longitude * ring[i].latitude;
    lng += (ring[i].longitude + ring[i + 1].longitude) * cross;
    lat += (ring[i].latitude + ring[i + 1].latitude) * cross;
  }
  return LatLng(lat / (6 * a), lng / (6 * a));
}

/// Dims everything outside Türkiye, draws the province lines and, once zoomed
/// in, the province names. Sits above the colour layers and below the markers,
/// and never takes a tap.
class ProvinceOutlineLayer extends StatefulWidget {
  final List<GeoArea> areas;

  /// Whether the tiles under this are the dark basemap.
  final bool darkBase;

  const ProvinceOutlineLayer({super.key, required this.areas, required this.darkBase});

  /// Below this the names of neighbouring provinces run into each other.
  static const double labelMinZoom = 6.5;

  @override
  State<ProvinceOutlineLayer> createState() => _ProvinceOutlineLayerState();
}

class _ProvinceOutlineLayerState extends State<ProvinceOutlineLayer> {
  // Built once and reused: flutter_map re-projects every vertex of a layer
  // whose widget changes, and these carry all 81 provinces.
  late Widget _mask;
  late Widget _lines;
  late Widget _labels;

  @override
  void initState() {
    super.initState();
    _build();
  }

  @override
  void didUpdateWidget(covariant ProvinceOutlineLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.areas != widget.areas || oldWidget.darkBase != widget.darkBase) _build();
  }

  void _build() {
    final style = widget.darkBase ? ProvinceOutlineStyle.dark : ProvinceOutlineStyle.light;
    _mask = PolygonLayer<Object>(
      invertedFill: style.mask,
      // Every province is a hole in the mask. Even-odd cancels the shared edges
      // on its own; Path.combine would redo 81 boolean operations per frame.
      painterFillMethod: PolygonPainterFillMethod.evenOdd,
      polygons: [
        for (final area in widget.areas)
          for (final polygon in area.polygons) Polygon<Object>(points: polygon.first),
      ],
    );
    _lines = PolylineLayer<Object>(
      polylines: [
        for (final area in widget.areas)
          for (final polygon in area.polygons)
            for (final ring in polygon)
              Polyline<Object>(
                points: ring,
                color: style.line,
                strokeWidth: 1.1,
                // A contrasting edge keeps the line visible on the colour
                // layers as well as on bare ground.
                borderColor: style.casing,
                borderStrokeWidth: 1.6,
              ),
      ],
    );
    final labelStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: style.label,
      shadows: [
        for (final o in const [Offset(0, 1), Offset(0, -1), Offset(1, 0), Offset(-1, 0)])
          Shadow(color: style.labelHalo, offset: o, blurRadius: 2),
      ],
    );
    _labels = MarkerLayer(
      rotate: true,
      markers: [
        for (final area in widget.areas)
          Marker(
            point: provinceLabelPoint(area),
            width: 110,
            height: 18,
            child: Center(child: Text(area.city, maxLines: 1, softWrap: false, style: labelStyle)),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final showLabels = MapCamera.of(context).zoom >= ProvinceOutlineLayer.labelMinZoom;
    return IgnorePointer(
      child: Stack(children: [_mask, _lines, if (showLabels) _labels]),
    );
  }
}
