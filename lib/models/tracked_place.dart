import 'dart:math' as math;

/// A place in "Yerlerim". The server keeps it; this is its client-side shape.
///
/// Coordinates come back from the server already rounded to ~1 km
/// (firewatch-tr-backend migration 014), so what the app shows is exactly
/// what is stored.
class TrackedPlace {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final int radiusKm;
  final bool notifyHeat;

  /// Alert when the fire-danger level here reaches High or above.
  final bool notifyRisk;
  final DateTime? createdAt;
  final DateTime? lastAlertAt;

  const TrackedPlace({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusKm,
    required this.notifyHeat,
    this.notifyRisk = true,
    this.createdAt,
    this.lastAlertAt,
  });

  static const maxPlaces = 5;
  static const radiiKm = <int>[5, 10, 25];
  static const nameMaxLength = 40;

  /// Whether a point is inside this place's radius (haversine).
  bool isWithinRadius(double lat, double lng) {
    const earthKm = 6371.0;
    double rad(double d) => d * math.pi / 180;
    final dLat = rad(lat - latitude);
    final dLng = rad(lng - longitude);
    final a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(rad(latitude)) * math.cos(rad(lat)) * math.pow(math.sin(dLng / 2), 2);
    return earthKm * 2 * math.asin(math.min(1.0, math.sqrt(a))) <= radiusKm;
  }

  /// Half the width and height of the radius circle, in degrees.
  double get latSpanDegrees => radiusKm / 111.32;
  double get lngSpanDegrees => radiusKm / (111.32 * math.cos(latitude * math.pi / 180));

  TrackedPlace copyWith({String? name, int? radiusKm, bool? notifyHeat, bool? notifyRisk}) => TrackedPlace(
        id: id,
        name: name ?? this.name,
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm ?? this.radiusKm,
        notifyHeat: notifyHeat ?? this.notifyHeat,
        notifyRisk: notifyRisk ?? this.notifyRisk,
        createdAt: createdAt,
        lastAlertAt: lastAlertAt,
      );

  factory TrackedPlace.fromJson(Map<String, dynamic> json) {
    DateTime? time(Object? v) => v is String ? DateTime.tryParse(v) : null;
    return TrackedPlace(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radiusKm: (json['radius_km'] as num).round(),
      notifyHeat: json['notify_heat'] as bool? ?? true,
      notifyRisk: json['notify_risk'] as bool? ?? true,
      createdAt: time(json['created_at']),
      lastAlertAt: time(json['last_alert_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'radius_km': radiusKm,
        'notify_heat': notifyHeat,
        'notify_risk': notifyRisk,
        'created_at': createdAt?.toIso8601String(),
        'last_alert_at': lastAlertAt?.toIso8601String(),
      };
}
