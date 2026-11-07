/// A place the user follows for satellite heat alerts ("Takip ettiğim
/// yerler", 1.2.0). The server keeps it; this is its client-side shape.
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
  final DateTime? createdAt;
  final DateTime? lastAlertAt;

  const TrackedPlace({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusKm,
    required this.notifyHeat,
    this.createdAt,
    this.lastAlertAt,
  });

  static const maxPlaces = 5;
  static const radiiKm = <int>[5, 10, 25];
  static const nameMaxLength = 40;

  TrackedPlace copyWith({bool? notifyHeat}) => TrackedPlace(
        id: id,
        name: name,
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
        notifyHeat: notifyHeat ?? this.notifyHeat,
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
        'created_at': createdAt?.toIso8601String(),
        'last_alert_at': lastAlertAt?.toIso8601String(),
      };
}
