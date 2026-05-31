import 'package:dio/dio.dart';
import '../models/news_item.dart';

class NewsService {
  NewsService();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://firewatch-tr-backend.onrender.com/api',
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );

  // RENDER API'DEN HABERLER
  Future<List<NewsItem>> fetchNewsFromRender({
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
        
        return newsList
            .map((newsJson) => NewsItem.fromJson(newsJson))
            .toList();
      }

      return [];
    } catch (e) {
      print('Error fetching news from Render: $e');
      return [];
    }
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
      print('Error fetching news by id: $e');
      return null;
    }
  }
}