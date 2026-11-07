import 'package:geolocator/geolocator.dart';

typedef CurrentPositionGetter = Future<Position> Function(LocationSettings settings);
typedef LastKnownPositionGetter = Future<Position?> Function();

/// A position for "where am I roughly" features (region, nearby fires, a
/// tracked place from my location).
///
/// Asks for a fresh fix first. When none arrives in [timeLimit] — indoors,
/// GPS warming up, an emulator that only replays its last fix — it falls
/// back to the OS's last known position if that is younger than
/// [maxLastKnownAge], instead of telling the user "location unavailable"
/// while the phone knows perfectly well where it is. If neither is usable,
/// the original error is rethrown, so callers keep their existing handling.
///
/// Not for the fire report, which needs a precise, current fix.
class DevicePosition {
  DevicePosition._();

  static const Duration defaultTimeLimit = Duration(seconds: 10);
  static const Duration defaultMaxLastKnownAge = Duration(minutes: 30);

  static Future<Position> current({
    LocationAccuracy accuracy = LocationAccuracy.low,
    Duration timeLimit = defaultTimeLimit,
    Duration maxLastKnownAge = defaultMaxLastKnownAge,
    CurrentPositionGetter? getCurrent,
    LastKnownPositionGetter? getLastKnown,
    DateTime Function()? now,
  }) async {
    final fresh = getCurrent ??
        ((settings) => Geolocator.getCurrentPosition(locationSettings: settings));
    final lastKnown = getLastKnown ?? Geolocator.getLastKnownPosition;
    try {
      return await fresh(LocationSettings(accuracy: accuracy, timeLimit: timeLimit));
    } catch (error, stack) {
      Position? fallback;
      try {
        fallback = await lastKnown();
      } catch (_) {
        fallback = null;
      }
      if (fallback != null && isRecent(fallback, maxLastKnownAge, (now ?? DateTime.now)())) {
        return fallback;
      }
      Error.throwWithStackTrace(error, stack);
    }
  }

  static bool isRecent(Position position, Duration maxAge, DateTime now) =>
      now.difference(position.timestamp).abs() <= maxAge;
}
