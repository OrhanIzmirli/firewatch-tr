import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/news_item.dart';
import '../core/config/api_config.dart';

class RelatedNews {
  final String title;
  final String source;
  final String? url;
  final DateTime publishedAt;

  const RelatedNews({required this.title, required this.source, this.url, required this.publishedAt});

  factory RelatedNews.fromJson(Map<String, dynamic> json) => RelatedNews(
        title: '${json['title']}',
        source: '${json['source']}',
        url: json['url'] as String?,
        publishedAt: DateTime.parse('${json['published_at']}').toLocal(),
      );
}

class NewsStoryItem {
  final int id;
  final String title;
  final String source;
  final String url;
  final String publishedAt;
  final String? stage;
  final String logoUrl;
  const NewsStoryItem({required this.id, required this.title, required this.source, required this.url, required this.publishedAt, required this.stage, required this.logoUrl});

  factory NewsStoryItem.fromJson(Map<String, dynamic> j) => NewsStoryItem(
        id: (j['id'] as num).toInt(),
        title: '${j['title']}',
        source: '${j['source'] ?? ''}',
        url: '${j['source_url'] ?? ''}',
        publishedAt: '${j['published_at'] ?? ''}',
        stage: j['stage'] as String?,
        logoUrl: '${j['source_logo_url'] ?? ''}',
      );
}

/// Headlines about one fire, oldest first.
class NewsStory {
  final String id;
  final String province;
  final int count;
  final List<String> stages;
  final List<NewsStoryItem> items;
  const NewsStory({required this.id, required this.province, required this.count, required this.stages, required this.items});

  bool get isTimeline => stages.length >= 2;

  String get thumbPath {
    final d = items.last.publishedAt;
    return d.length < 10 ? '' : '/api/news/thumb/${Uri.encodeComponent(province)}/${d.substring(0, 10)}';
  }

  factory NewsStory.fromJson(Map<String, dynamic> j) => NewsStory(
        id: '${j['id']}',
        province: '${j['province']}',
        count: (j['count'] as num).toInt(),
        stages: [for (final s in j['stages'] as List) '$s'],
        items: [for (final i in j['items'] as List) NewsStoryItem.fromJson(Map<String, dynamic>.from(i as Map))],
      );
}

class NewsService {
  // Same rationale as FireApiService: no per-instance state, so share one
  // instance (and Dio/HTTP client) across every call site instead of each
  // screen creating its own.
  factory NewsService() => _instance;
  NewsService._internal();
  static final NewsService _instance = NewsService._internal();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.apiBaseUrl,
      // Generous enough to survive a Render free-tier cold start (can take
      // 10-30s to wake) without throwing a false "offline" failure.
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  // RENDER API'DEN HABERLER
  // Deliberately does not catch: callers fall back to their own offline
  // cache on failure, which only works if a real fetch failure actually
  // throws instead of silently resolving to an empty list (an empty
  // success would otherwise overwrite good cached data with nothing).
  /// Forest-fire stories about one province, or anywhere when [city] is null.
  Future<List<RelatedNews>> fetchRelated({String? city, required DateTime from, required DateTime to}) async {
    final response = await _dio.get('/news/related', queryParameters: {
      'city': ?city,
      'from': from.toUtc().toIso8601String(),
      'to': to.toUtc().toIso8601String(),
      'limit': 3,
    });
    final data = response.data['data'];
    if (data is! List) return const [];
    return data.whereType<Map<String, dynamic>>().map(RelatedNews.fromJson).toList();
  }

  Future<List<NewsItem>> fetchNewsFromRender({
    String? category,
    String? contentType,
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _dio.get(
      '/news',
      queryParameters: {
        'category': ?category,
        'content_type': ?contentType,
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
  Future<List<NewsStory>> fetchStories() async {
    final response = await _dio.get('/news/stories');
    return [for (final s in response.data['data'] as List) NewsStory.fromJson(Map<String, dynamic>.from(s as Map))];
  }

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
