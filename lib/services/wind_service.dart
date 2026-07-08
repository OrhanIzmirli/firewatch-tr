import 'package:dio/dio.dart';

class WindReading {
  final double speedKmh;
  final double directionDeg;

  const WindReading({required this.speedKmh, required this.directionDeg});
}

class _CacheEntry {
  final WindReading reading;
  final DateTime fetchedAt;

  const _CacheEntry(this.reading, this.fetchedAt);
}

/// Fetches real-time wind speed/direction for a specific fire location from
/// Open-Meteo — the same provider already used for the regional risk
/// calculation, just queried per-coordinate here instead of per-region.
/// Results are cached in memory, keyed by coordinate rounded to 1 decimal
/// (~11km) since wind doesn't meaningfully vary at finer resolution and
/// nearby fires can share one request.
class WindService {
  WindService._();
  static final WindService instance = WindService._();

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  static const _ttl = Duration(minutes: 30);
  final Map<String, _CacheEntry> _cache = {};

  String _keyFor(double lat, double lng) =>
      '${lat.toStringAsFixed(1)}_${lng.toStringAsFixed(1)}';

  /// Returns null on any failure — callers should show an honest
  /// "unavailable" state rather than fabricating a value.
  Future<WindReading?> getWind(double lat, double lng) async {
    final key = _keyFor(lat, lng);
    final cached = _cache[key];
    if (cached != null && DateTime.now().difference(cached.fetchedAt) < _ttl) {
      return cached.reading;
    }

    try {
      final response = await _dio.get(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': lat,
          'longitude': lng,
          'current': 'wind_speed_10m,wind_direction_10m',
          'wind_speed_unit': 'kmh',
        },
      );
      final current = response.data['current'];
      final speed = (current['wind_speed_10m'] as num?)?.toDouble();
      final direction = (current['wind_direction_10m'] as num?)?.toDouble();
      if (speed == null || direction == null) return null;

      final reading = WindReading(speedKmh: speed, directionDeg: direction);
      _cache[key] = _CacheEntry(reading, DateTime.now());
      return reading;
    } catch (_) {
      return cached?.reading;
    }
  }
}
