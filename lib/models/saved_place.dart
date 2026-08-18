import 'package:latlong2/latlong.dart';

/// What kind of place the user saved. Provinces and districts come from the
/// bundled list and carry a real administrative bounding box; a pin is a
/// user-dropped point whose "area" is only a small viewing window around it.
enum SavedPlaceKind { province, district, pin }

/// One place the user chose to watch: a name, a centre, and a bounding box
/// the map can zoom to. Persisted as JSON in SharedPreferences.
class SavedPlace {
  final String id;
  final String name;

  /// The province a district belongs to; empty for provinces and pins.
  final String subtitle;
  final SavedPlaceKind kind;
  final double lat;
  final double lng;
  final double west;
  final double south;
  final double east;
  final double north;

  const SavedPlace({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.kind,
    required this.lat,
    required this.lng,
    required this.west,
    required this.south,
    required this.east,
    required this.north,
  });

  LatLng get center => LatLng(lat, lng);

  /// A pin has no administrative area, so its box is a ~10 km viewing
  /// window — enough to frame the point without pretending it has borders.
  factory SavedPlace.pin({
    required String id,
    required String name,
    required double lat,
    required double lng,
  }) {
    const half = 0.05;
    return SavedPlace(
      id: id,
      name: name,
      subtitle: '',
      kind: SavedPlaceKind.pin,
      lat: lat,
      lng: lng,
      west: lng - half,
      south: lat - half,
      east: lng + half,
      north: lat + half,
    );
  }

  /// Whether a coordinate falls inside this place's box, padded by [padDeg]
  /// degrees so a fire just over an administrative line still counts.
  bool contains(double pLat, double pLng, {double padDeg = 0.05}) {
    return pLat >= south - padDeg &&
        pLat <= north + padDeg &&
        pLng >= west - padDeg &&
        pLng <= east + padDeg;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'subtitle': subtitle,
    'kind': kind.name,
    'lat': lat,
    'lng': lng,
    'west': west,
    'south': south,
    'east': east,
    'north': north,
  };

  factory SavedPlace.fromJson(Map<String, dynamic> json) {
    return SavedPlace(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      kind: SavedPlaceKind.values.firstWhere(
        (k) => k.name == json['kind'],
        orElse: () => SavedPlaceKind.pin,
      ),
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      west: (json['west'] as num).toDouble(),
      south: (json['south'] as num).toDouble(),
      east: (json['east'] as num).toDouble(),
      north: (json['north'] as num).toDouble(),
    );
  }
}
