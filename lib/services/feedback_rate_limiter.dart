import 'package:shared_preferences/shared_preferences.dart';

/// Client-side cooldown enforced before the feedback/bug-report sheet is
/// even shown — the backend enforces its own much looser per-IP limit
/// (10/category/24h) as defense in depth, but this is what actually keeps
/// a single device from re-submitting the same category repeatedly.
class FeedbackRateLimiter {
  FeedbackRateLimiter._();
  static final FeedbackRateLimiter instance = FeedbackRateLimiter._();

  static const _bugCountKey = 'bug_report_count';
  static const _bugDateKey = 'bug_report_date';
  static const _lastFeedbackPrefix = 'last_feedback_date_';

  static const int _bugReportsPerDay = 3;
  static const int _generalCooldownDays = 7;
  static const int _featureCooldownDays = 3;

  String _todayKey(DateTime now) =>
      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

  /// Returns null if a bug report may be submitted now, otherwise the
  /// number of days to show in the "wait X days" message (always 1 — the
  /// daily counter resets at midnight).
  Future<int?> bugReportBlockedDays() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey(DateTime.now());
    final storedDate = prefs.getString(_bugDateKey);
    final count = storedDate == today ? (prefs.getInt(_bugCountKey) ?? 0) : 0;
    return count >= _bugReportsPerDay ? 1 : null;
  }

  Future<void> recordBugReport() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey(DateTime.now());
    final storedDate = prefs.getString(_bugDateKey);
    final count = storedDate == today ? (prefs.getInt(_bugCountKey) ?? 0) : 0;
    await prefs.setString(_bugDateKey, today);
    await prefs.setInt(_bugCountKey, count + 1);
  }

  int _cooldownDaysFor(String category) =>
      category == 'feature' ? _featureCooldownDays : _generalCooldownDays;

  /// Returns null if [category] ('general' or 'feature') may be submitted
  /// now, otherwise the number of days remaining until it's allowed again.
  Future<int?> feedbackBlockedDays(String category) async {
    final prefs = await SharedPreferences.getInstance();
    final lastMillis = prefs.getInt('$_lastFeedbackPrefix$category');
    if (lastMillis == null) return null;
    final last = DateTime.fromMillisecondsSinceEpoch(lastMillis);
    final cooldown = _cooldownDaysFor(category);
    final elapsedDays = DateTime.now().difference(last).inHours / 24;
    if (elapsedDays >= cooldown) return null;
    final remaining = (cooldown - elapsedDays).ceil();
    return remaining < 1 ? 1 : remaining;
  }

  Future<void> recordFeedback(String category) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      '$_lastFeedbackPrefix$category',
      DateTime.now().millisecondsSinceEpoch,
    );
  }
}
