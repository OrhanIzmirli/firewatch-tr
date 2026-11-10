import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'alert_preference.dart';
import 'device_position.dart';
import 'location_disclosure.dart';
import 'notification_service.dart';

/// Keeps the server's copy of this device's location current, only while the
/// app is on screen. Region alerts then go by the last place the app was
/// opened. Rounded here, so the exact fix never leaves the phone on this path.
///
/// Runs only for someone who started automatic monitoring and accepted the
/// disclosure. It never raises a permission prompt.
class ForegroundLocationSync {
  ForegroundLocationSync({
    Future<bool> Function()? permissionGranted,
    Future<({double latitude, double longitude})> Function()? readPosition,
    Future<bool> Function(double latitude, double longitude)? send,
  })  : _permissionGranted = permissionGranted ?? _defaultPermission,
        _readPosition = readPosition ?? _defaultPosition,
        _send = send ?? NotificationService.instance.sendForegroundLocation;

  static final ForegroundLocationSync instance = ForegroundLocationSync();

  static const enabledKey = 'server_location_updates';
  static const lastCellKey = 'server_location_last_cell';

  final Future<bool> Function() _permissionGranted;
  final Future<({double latitude, double longitude})> Function() _readPosition;
  final Future<bool> Function(double latitude, double longitude) _send;
  bool _running = false;

  static Future<bool> _defaultPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse || permission == LocationPermission.always;
  }

  static Future<({double latitude, double longitude})> _defaultPosition() async {
    final p = await DevicePosition.current(accuracy: LocationAccuracy.low, timeLimit: const Duration(seconds: 10));
    return (latitude: p.latitude, longitude: p.longitude);
  }

  /// "Start automatic monitoring".
  static Future<void> enable() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(enabledKey, true);
  }

  /// "Stop automatic monitoring" and "Delete my location data".
  static Future<void> disable() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(enabledKey, false);
    await prefs.remove(lastCellKey);
  }

  /// The server erased the location, so the next update must not be skipped.
  static Future<void> forgetLastCell() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(lastCellKey);
  }

  /// Returns whether an update was sent. A location still in the same
  /// roughly 1 km cell is not sent again.
  Future<bool> sync() async {
    if (_running) return false;
    _running = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!(prefs.getBool(enabledKey) ?? false)) return false;
      if (!alertsWanted(prefs)) return false;
      if (!(prefs.getBool(LocationDisclosure.prefsKey) ?? false)) return false;
      if (!await _permissionGranted()) return false;

      final position = await _readPosition();
      final lat = position.latitude.toStringAsFixed(2);
      final lng = position.longitude.toStringAsFixed(2);
      final cell = '$lat,$lng';
      if (prefs.getString(lastCellKey) == cell) return false;

      if (!await _send(double.parse(lat), double.parse(lng))) return false;
      await prefs.setString(lastCellKey, cell);
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Foreground location sync: $e');
      return false;
    } finally {
      _running = false;
    }
  }
}
