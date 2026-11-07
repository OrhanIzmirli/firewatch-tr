import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

/// Drives Settings › "Veri yenileme aralığı", which until now controlled
/// nothing. Ticks once a minute; when the configured interval has passed
/// since the last load it runs [onRefresh], which screens pass as a
/// *silent* reload (data updates in place, no spinner). The setting is read
/// on every tick, so a change takes effect within a minute without any
/// provider plumbing into the screens. Ported from 1.0.5/1.0.6.
class AutoRefresher {
  AutoRefresher({
    required Future<void> Function() onRefresh,
    DateTime Function()? clock,
  })  : _onRefresh = onRefresh,
        _clock = clock ?? DateTime.now {
    _lastRun = _clock();
  }

  /// Must match SettingsNotifier's storage key.
  static const String prefsKey = 'settings_refresh_interval';

  static const int defaultMinutes = 15;

  final Future<void> Function() _onRefresh;
  final DateTime Function() _clock;
  Timer? _timer;
  late DateTime _lastRun;
  bool _running = false;

  /// Stored values are '5 dk' / '15 dk' / '30 dk' / '60 dk'. Anything
  /// unreadable falls back to the default rather than refreshing nonstop.
  static int parseMinutes(String? raw) {
    final minutes = int.tryParse((raw ?? '').trim().split(' ').first);
    if (minutes == null || minutes < 1) return defaultMinutes;
    return minutes;
  }

  void start() {
    _timer ??= Timer.periodic(const Duration(minutes: 1), (_) => tick());
  }

  /// Call after any manual or initial load so the countdown restarts.
  void markRefreshed() => _lastRun = _clock();

  /// One timer step; public so tests can drive it without waiting.
  Future<bool> tick() async {
    if (_running) return false;
    final prefs = await SharedPreferences.getInstance();
    final minutes = parseMinutes(prefs.getString(prefsKey));
    if (_clock().difference(_lastRun).inMinutes < minutes) return false;
    _running = true;
    try {
      await _onRefresh();
      _lastRun = _clock();
      return true;
    } catch (_) {
      // Leave _lastRun so the next tick retries.
      return false;
    } finally {
      _running = false;
    }
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
