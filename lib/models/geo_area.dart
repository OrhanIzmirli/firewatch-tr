import 'package:latlong2/latlong.dart';

/// GeoJSON coordinates are longitude, latitude. Holes and islands are retained.
class GeoArea {
  final String id;
  final Map<String, dynamic> properties;
  final List<List<List<LatLng>>> polygons;
  const GeoArea(this.id, this.properties, this.polygons);
  String get city => '${properties['city'] ?? ''}';
  String get district => '${properties['district'] ?? ''}';
  num? get score => num.tryParse('${properties['risk_score']}');
  Iterable<LatLng> get points => polygons.expand((p) => p.first);
  factory GeoArea.fromJson(Map<String,dynamic> json) {
    final g = Map<String,dynamic>.from(json['geometry'] as Map);
    final coordinates = g['coordinates'] as List;
    final List raw = switch(g['type']) { 'Polygon' => [coordinates], 'MultiPolygon' => coordinates, _ => throw const FormatException('Polygon or MultiPolygon required') };
    final polygons = raw.map((p) => (p as List).map((r) => (r as List).map((xy) {
      final lng = (xy[0] as num).toDouble(), lat = (xy[1] as num).toDouble();
      if (!lat.isFinite || !lng.isFinite || lat.abs() > 90 || lng.abs() > 180) throw const FormatException('Invalid coordinate');
      return LatLng(lat,lng);
    }).toList()).toList()).toList();
    if (polygons.isEmpty || polygons.any((p) => p.isEmpty || p.any((r) => r.length < 4))) throw const FormatException('Invalid polygon rings');
    return GeoArea('${json['id']}', Map<String,dynamic>.from(json['properties'] as Map), polygons);
  }
  static List<GeoArea> collection(dynamic json) => (json['features'] as List).map((f) => GeoArea.fromJson(Map<String,dynamic>.from(f))).toList();
}
