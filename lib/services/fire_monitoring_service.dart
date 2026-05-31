import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/fire_point.dart';
import 'fire_api_service.dart';
import 'notification_service.dart';

class FireMonitoringService {
  FireMonitoringService._();

  static final FireMonitoringService instance = FireMonitoringService._();

  final FireApiService _fireApiService = FireApiService();

  final ValueNotifier<bool> isRunningNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String> statusNotifier =
      ValueNotifier<String>('Monitoring servisi hazır.');
  final ValueNotifier<List<FirePoint>> nearbyMatchesNotifier =
      ValueNotifier<List<FirePoint>>(<FirePoint>[]);

  Timer? _timer;

  static const Duration _pollInterval = Duration(minutes: 5);
  static const double _nearbyRadiusMeters = 50000;
  static const int _cooldownMinutes = 30;

  static const String _lastAlertTimeKey = 'monitor_last_alert_time';
  static const String _lastAlertCountKey = 'monitor_last_alert_count';

  Future<void> initialize() async {
    statusNotifier.value = 'Monitoring servisi hazır.';
  }

  Future<void> startMonitoring() async {
    if (_timer != null) {
      statusNotifier.value = 'Otomatik tarama zaten çalışıyor.';
      isRunningNotifier.value = true;
      return;
    }

    isRunningNotifier.value = true;
    statusNotifier.value = 'Otomatik tarama başlatıldı...';

    await checkNow(triggerNotification: true);

    _timer = Timer.periodic(_pollInterval, (_) async {
      await checkNow(triggerNotification: true);
    });
  }

  Future<void> stopMonitoring() async {
    _timer?.cancel();
    _timer = null;
    isRunningNotifier.value = false;
    statusNotifier.value = 'Otomatik tarama durduruldu.';
  }

  Future<void> checkNow({bool triggerNotification = false}) async {
    try {
      statusNotifier.value = 'Konum alınıyor...';

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        statusNotifier.value = 'Konum servisi kapalı. Lütfen konumu açın.';
        nearbyMatchesNotifier.value = <FirePoint>[];
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        statusNotifier.value = 'Konum izni verilmedi.';
        nearbyMatchesNotifier.value = <FirePoint>[];
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 10),
        ),
      );

      statusNotifier.value = 'NASA FIRMS verisi çekiliyor...';

      final fires = await _fireApiService.fetchTurkeyFires();

      if (fires.isEmpty) {
        statusNotifier.value = 'Şu an aktif yangın verisi bulunamadı.';
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
        statusNotifier.value =
            '✅ 50 km içinde canlı yangın tespiti yok. (${fires.length} nokta tarandı)';
        return;
      }

      statusNotifier.value =
          '⚠️ 50 km içinde ${nearby.length} yangın noktası bulundu!';

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
        statusNotifier.value =
            'NASA API bağlantı zaman aşımı. İnternet bağlantınızı kontrol edin.';
      } else if (e.toString().contains('location')) {
        statusNotifier.value = 'Konum alınamadı. Lütfen tekrar deneyin.';
      } else {
        statusNotifier.value = 'Tarama başarısız: ${e.toString().substring(0, 50)}';
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