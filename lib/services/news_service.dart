import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/news_item.dart';
import '../core/config/api_config.dart';

class NewsService {
  NewsService();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  // RENDER API'DEN HABERLER
  // Deliberately does not catch: callers fall back to their own offline
  // cache on failure, which only works if a real fetch failure actually
  // throws instead of silently resolving to an empty list (an empty
  // success would otherwise overwrite good cached data with nothing).
  Future<List<NewsItem>> fetchNewsFromRender({
    String? category,
    int limit = 20,
    int offset = 0,
  }) async {
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

      return newsList
          .map((newsJson) => NewsItem.fromJson(newsJson))
          .toList();
    }

    return [];
  }

  // TEK HABERİ GET
  Future<NewsItem?> fetchNewsById(String id) async {
    try {
      final response = await _dio.get('/news/$id');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final newsData = data['data'] as Map<String, dynamic>?;
        
        return newsData != null ? NewsItem.fromJson(newsData) : null;
      }

      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching news by id: $e');
      return null;
    }
  }
}
