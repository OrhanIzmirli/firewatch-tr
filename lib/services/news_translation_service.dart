import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Translates Turkish news text to English on demand using the free
/// MyMemory API (no key required). Results are cached in memory and in
/// SharedPreferences, keyed by article id + field, so the same article is
/// never translated twice.
class NewsTranslationService {
  NewsTranslationService._();
  static final NewsTranslationService instance = NewsTranslationService._();

  final Map<String, String> _memoryCache = {};

  String _cacheKey(String articleId, String field) =>
      'news_translation_${articleId}_$field';

  Future<String?> getCached(String articleId, String field) async {
    final key = _cacheKey(articleId, field);
    final fromMemory = _memoryCache[key];
    if (fromMemory != null) return fromMemory;

    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(key);
    if (stored != null) _memoryCache[key] = stored;
    return stored;
  }

  Future<String> translate({
    required String articleId,
    required String field,
    required String text,
    String sourceLang = 'tr',
    String targetLang = 'en',
  }) async {
    if (text.trim().isEmpty) return text;

    final cached = await getCached(articleId, field);
    if (cached != null) return cached;

    final uri = Uri.https('api.mymemory.translated.net', '/get', {
      'q': text,
      'langpair': '$sourceLang|$targetLang',
    });

    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception('Translation request failed (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final translated = (data['responseData'] as Map<String, dynamic>?)?['translatedText'] as String?;
    if (translated == null || translated.trim().isEmpty) {
      throw Exception('Translation response was empty');
    }

    final key = _cacheKey(articleId, field);
    _memoryCache[key] = translated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, translated);

    return translated;
  }
}
