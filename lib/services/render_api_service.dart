import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/config/api_config.dart';

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
          if (category != null) 'category': category,
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
  }) async {
    try {
      final response = await _dio.post(
        '/notify/subscribe',
        data: {
          'token': token,
          'device_info': 'FireWatch TR App',
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
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
  }) async {
    try {
      final response = await _dio.patch(
        '/notify/subscribe',
        data: {
          'token': token,
          'is_active': isActive,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) debugPrint('Error updating notification status: $e');
      return false;
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
