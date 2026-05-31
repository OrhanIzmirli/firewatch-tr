import 'package:dio/dio.dart';

class RenderApiService {
  RenderApiService();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://firewatch-tr-backend.onrender.com/api',
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
      print('Error fetching news: $e');
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
      print('Error fetching news by id: $e');
      return null;
    }
  }

  // PUSH NOTIFICATION TOKEN KAYDET
  Future<bool> subscribeToNotifications(String token) async {
    try {
      final response = await _dio.post(
        '/notify/subscribe',
        data: {
          'token': token,
          'device_info': 'FireWatch TR App',
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error subscribing to notifications: $e');
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
      print('Error sending location: $e');
      return false;
    }
  }

  // HEALTH CHECK
  Future<bool> healthCheck() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      print('Health check failed: $e');
      return false;
    }
  }
}