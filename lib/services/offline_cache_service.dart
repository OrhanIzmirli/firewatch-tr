import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Caches the last successful API response per key so screens can fall
/// back to it (with a "last updated" timestamp) when a live fetch fails.
class OfflineCacheService {
  OfflineCacheService._();
  static final OfflineCacheService instance = OfflineCacheService._();

  String _dataKey(String key) => 'offline_cache_$key';
  String _timeKey(String key) => 'offline_cache_time_$key';

  Future<void> save(String key, Object jsonEncodable) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dataKey(key), jsonEncode(jsonEncodable));
    await prefs.setInt(_timeKey(key), DateTime.now().millisecondsSinceEpoch);
  }

  /// Returns (decoded data, savedAt) or null if nothing cached.
  Future<(dynamic, DateTime)?> load(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_dataKey(key));
    final millis = prefs.getInt(_timeKey(key));
    if (raw == null || millis == null) return null;
    try {
      return (jsonDecode(raw), DateTime.fromMillisecondsSinceEpoch(millis));
    } catch (_) {
      return null;
    }
  }
}
