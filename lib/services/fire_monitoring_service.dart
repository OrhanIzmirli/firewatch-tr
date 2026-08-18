import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/l10n_lookup.dart';
import '../models/alert_scope.dart';
import '../models/fire_point.dart';
import 'fire_api_service.dart';
import 'notification_service.dart';
import 'saved_places_provider.dart';

class FireMonitoringService {
  FireMonitoringService._();

  static final FireMonitoringService instance = FireMonitoringService._();

  final FireApiService _fireApiService = FireApiService();

  final ValueNotifier<bool> isRunningNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String> statusNotifier = ValueNotifier<String>('');
  final ValueNotifier<List<FirePoint>> nearbyMatchesNotifier =
      ValueNotifier<List<FirePoint>>(<FirePoint>[]);

  Timer? _timer;

  static const Duration _pollInterval = Duration(minutes: 5);
  static const double _nearbyRadiusMeters = 50000;
  static const int _cooldownMinutes = 30;

  static const String _lastAlertTimeKey = 'monitor_last_alert_time';
  static const String _lastAlertCountKey = 'monitor_last_alert_count';

  Future<void> initialize() async {
    final l10n = await currentAppLocalizations();
    statusNotifier.value = l10n.monitorStatusReady;
  }

  Future<void> startMonitoring() async {
    final l10n = await currentAppLocalizations();

    if (_timer != null) {
      statusNotifier.value = l10n.monitorStatusAlreadyRunning;
      isRunningNotifier.value = true;
      return;
    }

    isRunningNotifier.value = true;
    statusNotifier.value = l10n.monitorStatusStarted;

    await checkNow(triggerNotification: true);

    _timer = Timer.periodic(_pollInterval, (_) async {
      await checkNow(triggerNotification: true);
    });
  }

  Future<void> stopMonitoring() async {
    final l10n = await currentAppLocalizations();
    _timer?.cancel();
    _timer = null;
    isRunningNotifier.value = false;
    statusNotifier.value = l10n.monitorStatusStopped;
  }

  Future<void> checkNow({bool triggerNotification = false}) async {
    final l10n = await currentAppLocalizations();
    try {
      // AlertScope.places is enforced here, on the device: the backend does
      // not know that scope yet, and this scan is what makes it real. The
      // scope and the places are read straight from prefs because this
      // service runs outside the widget tree.
      final prefs = await SharedPreferences.getInstance();
      final scope =
          AlertScopeWire.fromWire(prefs.getString(kAlertScopePrefsKey));
      if (scope == AlertScope.places) {
        final places = SavedPlacesNotifier.decode(
          prefs.getString(SavedPlacesNotifier.prefsKey),
        );
        if (places.isNotEmpty) {
          statusNotifier.value = l10n.monitorStatusFetchingData;
          final fires = await _fireApiService.fetchTurkeyFires();
          if (fires.isEmpty) {
            statusNotifier.value = l10n.monitorStatusNoActiveFires;
            nearbyMatchesNotifier.value = <FirePoint>[];
            return;
          }
          final matches = fires
              .where(
                (fire) => places.any(
                  (place) => place.contains(fire.latitude, fire.longitude),
                ),
              )
              .toList();
          nearbyMatchesNotifier.value = matches;
          if (matches.isEmpty) {
            statusNotifier.value =
                l10n.monitorStatusNoNearbyFires(fires.length);
            return;
          }
          statusNotifier.value =
              l10n.monitorStatusNearbyFiresFound(matches.length);
          if (triggerNotification &&
              await _shouldSendNearbyAlert(matches.length)) {
            await NotificationService.instance.showSavedPlacesFireAlert(
              count: matches.length,
            );
            await _rememberNearbyAlert(matches.length);
          }
          return;
        }
        // No places saved: fall through to the GPS-based scan rather than
        // silently scanning nothing.
      }

      statusNotifier.value = l10n.monitorStatusGettingLocation;

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        statusNotifier.value = l10n.monitorStatusLocationServiceOff;
        nearbyMatchesNotifier.value = <FirePoint>[];
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        statusNotifier.value = l10n.monitorStatusLocationDenied;
        nearbyMatchesNotifier.value = <FirePoint>[];
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 10),
        ),
      );

      statusNotifier.value = l10n.monitorStatusFetchingData;

      final fires = await _fireApiService.fetchTurkeyFires();

      if (fires.isEmpty) {
        statusNotifier.value = l10n.monitorStatusNoActiveFires;
        nearbyMatchesNotifier.value = <FirePoint>[];
        return;
      }

      final nearby = fires.where((fire) {
        final meters = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          fire.latitude,
          fire.longitude,
        );
        return meters <= _nearbyRadiusMeters;
      }).toList();

      nearbyMatchesNotifier.value = nearby;

      if (nearby.isEmpty) {
        statusNotifier.value = l10n.monitorStatusNoNearbyFires(fires.length);
        return;
      }

      statusNotifier.value = l10n.monitorStatusNearbyFiresFound(nearby.length);

      if (triggerNotification) {
        final shouldNotify = await _shouldSendNearbyAlert(nearby.length);
        if (shouldNotify) {
          await NotificationService.instance.showNearbyFireAlert(
            count: nearby.length,
            distanceLabel: '50 km',
          );
          await _rememberNearbyAlert(nearby.length);
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Fire monitoring error: $e');

      if (e.toString().contains('timeout')) {
        statusNotifier.value = l10n.monitorStatusTimeout;
      } else if (e.toString().contains('location')) {
        statusNotifier.value = l10n.monitorStatusLocationFailed;
      } else {
        statusNotifier.value = l10n.monitorStatusScanFailed(e.toString().substring(0, 50));
      }
      nearbyMatchesNotifier.value = <FirePoint>[];
    }
  }

  Future<bool> _shouldSendNearbyAlert(int currentCount) async {
    final prefs = await SharedPreferences.getInstance();
    final lastTimeMillis = prefs.getInt(_lastAlertTimeKey);
    final lastCount = prefs.getInt(_lastAlertCountKey);

    if (lastTimeMillis == null || lastCount == null) return true;

    final lastTime = DateTime.fromMillisecondsSinceEpoch(lastTimeMillis);
    final diff = DateTime.now().difference(lastTime);

    if (currentCount > lastCount) return true;
    if (diff.inMinutes >= _cooldownMinutes) return true;

    return false;
  }

  Future<void> _rememberNearbyAlert(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastAlertTimeKey, DateTime.now().millisecondsSinceEpoch);
    await prefs.setInt(_lastAlertCountKey, count);
  }
}
