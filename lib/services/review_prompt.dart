import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The app has to have been opened on this many different days.
const int reviewMinOpenDays = 3;

/// At most one request in this period. Google adds its own limit on top.
const Duration reviewCooldown = Duration(days: 90);

String _dayKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

bool reviewAllowed({required Set<String> openDays, required DateTime? lastAsked, required DateTime now}) {
  if (openDays.length < reviewMinOpenDays) return false;
  return lastAsked == null || now.difference(lastAsked) >= reviewCooldown;
}

/// Asks for a Play review only after a good moment in Fidan.
///
/// Called from the Fidan reward screen and nowhere else, so it can never
/// appear on an alert, risk, map detection or 112 screen. Nothing is ever
/// given in return for a rating: Play policy forbids it.
class ReviewPrompt {
  ReviewPrompt._();
  static const _daysKey = 'review_open_days';
  static const _askedKey = 'review_last_asked';

  static Future<void> noteAppOpen([DateTime? now]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = _dayKey(now ?? DateTime.now());
      final days = prefs.getStringList(_daysKey) ?? const <String>[];
      if (days.contains(today)) return;
      final next = [...days, today];
      await prefs.setStringList(_daysKey, next.length > reviewMinOpenDays ? next.sublist(next.length - reviewMinOpenDays) : next);
    } catch (e) {
      if (kDebugMode) debugPrint('Review days: $e');
    }
  }

  /// Returns whether Play was asked to show the request.
  static Future<bool> maybeAsk({InAppReview? review, DateTime? now}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final at = now ?? DateTime.now();
      final last = DateTime.tryParse(prefs.getString(_askedKey) ?? '');
      final days = (prefs.getStringList(_daysKey) ?? const <String>[]).toSet();
      if (!reviewAllowed(openDays: days, lastAsked: last, now: at)) return false;
      final api = review ?? InAppReview.instance;
      if (!await api.isAvailable()) return false;
      // Saved first: Play does not say whether the dialog was shown.
      await prefs.setString(_askedKey, at.toIso8601String());
      await api.requestReview();
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Review request: $e');
      return false;
    }
  }

  /// The Settings link: the user asked, so no limits apply.
  static Future<void> openStore({InAppReview? review}) => (review ?? InAppReview.instance).openStoreListing();
}
