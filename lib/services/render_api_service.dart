import 'package:package_info_plus/package_info_plus.dart';
import 'package:dio/dio.dart';
import '../models/detection_status.dart';
import 'package:flutter/foundation.dart';
import '../core/config/api_config.dart';
import '../models/alert_scope.dart';
import '../models/fire_incident.dart';
import '../models/incident_summary.dart';

class RenderApiService {
  RenderApiService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConfig.apiBaseUrl,
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 20),
              ),
            );

  final Dio _dio;

  // HABERLER
  Future<List<Map<String, dynamic>>> fetchNews({
    String? category,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/news',
        queryParameters: {
          'category': ?category,
          'limit': limit,
          'offset': offset,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final newsList = (data['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        return newsList;
      }

      return [];
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching news: $e');
      return [];
    }
  }

  // TEK HABERİ GET
  Future<Map<String, dynamic>?> fetchNewsById(int id) async {
    try {
      final response = await _dio.get('/news/$id');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return data['data'] as Map<String, dynamic>?;
      }

      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching news by id: $e');
      return null;
    }
  }

  // PUSH NOTIFICATION TOKEN KAYDET (isteğe bağlı konum ile — bölgesel
  // uyarıların hedeflenebilmesi için backend'de fcm_tokens.latitude/
  // longitude alanlarını doldurur)
  /// "FireWatch TR/1.2.0+8": lets the server tell which installs are old.
  Future<String> _deviceInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return 'FireWatch TR/${info.version}+${info.buildNumber}';
    } catch (_) {
      return 'FireWatch TR App';
    }
  }

  Future<bool> subscribeToNotifications(
    String token, {
    double? latitude,
    double? longitude,
    AlertScope? alertScope,
    String? regionKey,
    int? cityId,
    bool? isActive,
  }) async {
    try {
      final response = await _dio.post(
        '/notify/subscribe',
        data: {
          'token': token,
          'device_info': await _deviceInfo(),
          // Omitted when null so the server keeps the user's on/off choice.
          'is_active': ?isActive,
          'latitude': ?latitude,
          'longitude': ?longitude,
          // Omitted entirely when null so the backend leaves whatever scope is
          // already stored alone, instead of resetting it to 'all'.
          'alert_scope': ?alertScope?.wireValue,
          'region_key': ?regionKey,
          'city_id': ?cityId,
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      if (kDebugMode) debugPrint('Error subscribing to notifications: $e');
      return false;
    }
  }

  // SUNUCUDAKİ KONUMU SİL — Ayarlar > "Konum verimi sil". Yalnızca
  // fcm_tokens.latitude/longitude silinir; bildirimler ve kapsam aynen kalır.
  Future<bool> deleteStoredLocation(String token) async {
    try {
      final response = await _dio.post(
        '/notify/location/delete',
        data: {'token': token},
      );
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) debugPrint('Error deleting stored location: $e');
      return false;
    }
  }

  // PUSH NOTIFICATION TOKEN'I PASİFLEŞTİR (eski POST /unsubscribe — hâlâ
  // destekleniyor, bkz. setNotificationActive için PATCH tabanlı alternatif)
  Future<bool> unsubscribeFromNotifications(String token) async {
    try {
      final response = await _dio.post(
        '/notify/unsubscribe',
        data: {'token': token},
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) debugPrint('Error unsubscribing from notifications: $e');
      return false;
    }
  }

  // is_active bayrağını aç/kapat — konum verildiyse onu da günceller
  // (verilmezse mevcut konum backend'de korunur).
  Future<bool> setNotificationActive(
    String token,
    bool isActive, {
    double? latitude,
    double? longitude,
    AlertScope? alertScope,
    String? regionKey,
    int? cityId,
  }) async {
    try {
      final response = await _dio.patch(
        '/notify/subscribe',
        data: {
          'token': token,
          'is_active': isActive,
          'latitude': ?latitude,
          'longitude': ?longitude,
          'alert_scope': ?alertScope?.wireValue,
          'region_key': ?regionKey,
          'city_id': ?cityId,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) debugPrint('Error updating notification status: $e');
      return false;
    }
  }

  /// Reads the scope the backend holds for [token] without changing it: a
  /// PATCH that carries only is_active (the caller passes the current push
  /// setting, so that doesn't change either) answers with the stored row.
  Future<ServerScope?> readServerScope(String token, {required bool isActive}) async {
    try {
      final response = await _dio.patch(
        '/notify/subscribe',
        data: {'token': token, 'is_active': isActive},
      );
      final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>?;
      if (data == null) return null;
      return ServerScope(
        scope: AlertScopeWire.fromWire(data['alert_scope'] as String?),
        regionKey: data['region_key'] as String?,
        cityId: (data['city_id'] as num?)?.toInt(),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error reading server scope: $e');
      return null;
    }
  }

  /// Clustered fire events. Returns an empty list on any failure so the
  /// caller keeps the existing raw-detection view rather than showing an
  /// error — /api/incidents is additive, not a replacement.
  Future<List<FireIncident>> fetchIncidents({
    int days = 7,
    int limit = 200,
    String? regionKey,
    int? cityId,
  }) async {
    try {
      final response = await _dio.get(
        '/incidents',
        queryParameters: {
          'days': days,
          'limit': limit,
          'region_key': ?regionKey,
          'city_id': ?cityId,
        },
      );
      final data = response.data['data'];
      if (data is! List) return const [];
      return data
          .whereType<Map<String, dynamic>>()
          .map(FireIncident.fromJson)
          .toList();
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching incidents: $e');
      return const [];
    }
  }

  /// The last-24-hours event summary for the Home overview.
  ///
  /// Falls back to computing the same three numbers from a page of
  /// /api/incidents when the summary route is missing — an app update can
  /// ship ahead of a backend deploy, and a Home card that silently vanishes
  /// is harder to diagnose than one that is merely bounded by the page.
  Future<IncidentSummary?> fetchIncidentSummary() async {
    try {
      final response = await _dio.get('/incidents/summary');
      final data = response.data['data'];
      if (data is Map<String, dynamic>) return IncidentSummary.fromJson(data);
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching incident summary: $e');
    }

    final incidents = await fetchIncidents(days: 3, limit: 500);
    if (incidents.isEmpty) return null;
    return IncidentSummary.fromIncidents(incidents);
  }

  /// Never null and never an empty answer: a failed request is
  /// [DetectionStatus.unavailable], which the app must not read as "quiet".
  Future<DetectionStatus> fetchDetectionStatus() async {
    try {
      final response = await _dio.get('/incidents/status');
      final data = response.data['data'];
      if (data is Map<String, dynamic>) return DetectionStatus.fromJson(data);
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching detection status: $e');
    }
    return DetectionStatus.unavailable;
  }

  /// Asks the backend which province/region a coordinate falls in.
  ///
  /// The client deliberately does NOT work this out locally: FirePoint's
  /// bounding boxes disagree with the province table (they put Konya,
  /// Karaman, Nigde and Aksaray in Akdeniz and Burdur in Ege), and the server
  /// alerts on the province table's regions. Deriving it here would put a
  /// device in a different region than the alerts meant for it.
  Future<ResolvedLocation?> resolveLocation(double lat, double lng) async {
    try {
      final response = await _dio.get(
        '/fires/nearest-city',
        queryParameters: {'lat': lat, 'lng': lng},
      );
      final data = response.data['data'];
      if (data is! Map<String, dynamic>) return null;
      if (data['outsideTurkey'] == true) return null;
      return ResolvedLocation.fromJson(data);
    } catch (e) {
      if (kDebugMode) debugPrint('Error resolving location: $e');
      return null;
    }
  }

  /// The 81 provinces, used to populate the notification scope picker.
  /// Returns an empty list on failure — the caller falls back to region-level
  /// selection rather than blocking the whole settings screen.
  Future<List<TurkeyCity>> fetchCities() async {
    try {
      final response = await _dio.get('/notify/cities');
      final data = response.data['data'];
      if (data is! List) return const [];
      return data
          .whereType<Map<String, dynamic>>()
          .map(TurkeyCity.fromJson)
          .toList();
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching cities: $e');
      return const [];
    }
  }

  // KONUM GÖNDER (İsteğe bağlı)
  Future<bool> sendLocation(double latitude, double longitude) async {
    try {
      final response = await _dio.post(
        '/notify/send-location',
        data: {
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) debugPrint('Error sending location: $e');
      return false;
    }
  }

  // HEALTH CHECK
  Future<bool> healthCheck() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) debugPrint('Health check failed: $e');
      return false;
    }
  }
}
