import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/config/api_config.dart';
import '../models/alert_scope.dart';

class RenderApiService {
  RenderApiService();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );

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
  Future<bool> subscribeToNotifications(
    String token, {
    double? latitude,
    double? longitude,
    AlertScope? alertScope,
    String? regionKey,
    int? cityId,
  }) async {
    try {
      final response = await _dio.post(
        '/notify/subscribe',
        data: {
          'token': token,
          'device_info': 'FireWatch TR App',
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
