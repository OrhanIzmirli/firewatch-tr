import 'dart:math' as math;

/// A location the backend has labelled a fixed heat source — a steelworks,
/// a refinery, a gas flare: something seen radiating on seven or more
/// separate days at low, unchanging power (migration 011, services/heatSource).
///
/// The label says where the heat comes from. It says nothing about any fire
/// being out, and no string built from it may suggest that.
class PersistentHeatSource {
  final int id;
  final double latitude;
  final double longitude;
  final String? cityName;
  final int? distinctDaysSeen;

  const PersistentHeatSource({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.cityName,
    this.distinctDaysSeen,
  });

  factory PersistentHeatSource.fromJson(Map<String, dynamic> json) {
    return PersistentHeatSource(
      id: (json['id'] as num).toInt(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      cityName: json['city_name'] as String?,
      distinctDaysSeen: (json['distinct_days_seen'] as num?)?.toInt(),
    );
  }

  /// Raw detections this close to a labelled source are drawn as the source,
  /// not as a fire. Two kilometres covers a plant's footprint plus VIIRS
  /// geolocation error; the incident's own detections cluster well inside it.
  static const double matchRadiusKm = 2;

  /// Whether ([lat], [lng]) sits within [matchRadiusKm] of any of [sources].
  static bool coversPoint(
    Iterable<PersistentHeatSource> sources,
    double lat,
    double lng,
  ) {
    for (final s in sources) {
      if (_haversineKm(s.latitude, s.longitude, lat, lng) <= matchRadiusKm) {
        return true;
      }
    }
    return false;
  }

  static double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = _rad(lat2 - lat1);
    final dLon = _rad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(lat1)) * math.cos(_rad(lat2)) * math.sin(dLon / 2) * math.sin(dLon / 2);
    return 2 * r * math.asin(math.min(1, math.sqrt(a)));
  }

  static double _rad(double deg) => deg * math.pi / 180;
}
