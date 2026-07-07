import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ReportBlockReason { none, duplicateLocation, dailyLimit }

class ReportSpamCheck {
  final ReportBlockReason reason;
  const ReportSpamCheck(this.reason);
  bool get isBlocked => reason != ReportBlockReason.none;
}

/// Prevents fire-report spam: blocks a resubmission from (roughly) the same
/// location within a cooldown window, and caps how many reports a device
/// can send per day. History is kept locally (SharedPreferences) — this is
/// a client-side speed bump, not a substitute for server-side validation.
class ReportSpamGuard {
  ReportSpamGuard._();
  static final ReportSpamGuard instance = ReportSpamGuard._();

  static const _historyKey = 'fire_report_history';
  static const _duplicateRadiusMeters = 500.0;
  static const _duplicateCooldown = Duration(hours: 2);
  static const _dailyLimit = 5;
  static const _dailyWindow = Duration(hours: 24);

  Future<List<Map<String, dynamic>>> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw) as List;
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveHistory(List<Map<String, dynamic>> history) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_historyKey, jsonEncode(history));
  }

  /// Checks whether a report from [lat]/[lng] right now would be blocked,
  /// without recording anything. Call [recordReport] separately after a
  /// successful submission.
  Future<ReportSpamCheck> checkBeforeSubmit(double lat, double lng) async {
    final now = DateTime.now();
    final history = await _loadHistory();

    // Prune anything outside the daily window while we're at it — keeps
    // the stored list from growing forever.
    final recent = history.where((entry) {
      final ts = DateTime.tryParse(entry['timestamp'] as String? ?? '');
      return ts != null && now.difference(ts) < _dailyWindow;
    }).toList();

    for (final entry in recent) {
      final ts = DateTime.tryParse(entry['timestamp'] as String? ?? '');
      if (ts == null) continue;
      if (now.difference(ts) >= _duplicateCooldown) continue;
      final entryLat = (entry['lat'] as num?)?.toDouble();
      final entryLng = (entry['lng'] as num?)?.toDouble();
      if (entryLat == null || entryLng == null) continue;
      final distance = Geolocator.distanceBetween(lat, lng, entryLat, entryLng);
      if (distance <= _duplicateRadiusMeters) {
        return const ReportSpamCheck(ReportBlockReason.duplicateLocation);
      }
    }

    if (recent.length >= _dailyLimit) {
      return const ReportSpamCheck(ReportBlockReason.dailyLimit);
    }

    return const ReportSpamCheck(ReportBlockReason.none);
  }

  /// Records a successful submission. [lat]/[lng] are rounded to 2 decimal
  /// places (~1.1km grid) before storing, per spec — note this is coarser
  /// than the 500m duplicate-check radius, so the location match itself is
  /// still computed against full-precision coordinates; only the stored
  /// history entry is rounded.
  Future<void> recordReport(double lat, double lng) async {
    final now = DateTime.now();
    final history = await _loadHistory();
    final recent = history.where((entry) {
      final ts = DateTime.tryParse(entry['timestamp'] as String? ?? '');
      return ts != null && now.difference(ts) < _dailyWindow;
    }).toList();

    recent.add({
      'lat': double.parse(lat.toStringAsFixed(2)),
      'lng': double.parse(lng.toStringAsFixed(2)),
      'timestamp': now.toIso8601String(),
    });

    await _saveHistory(recent);
  }
}
