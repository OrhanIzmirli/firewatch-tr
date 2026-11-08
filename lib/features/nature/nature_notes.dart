import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../l10n/app_localizations.dart';
import 'nature_facts.dart';
import 'nature_progress.dart';

/// Days of the coming weeks that get a fact: Monday, Wednesday and Saturday.
List<DateTime> noteDays(DateTime now, {int weeks = 3, int hour = 11}) {
  final out = <DateTime>[];
  for (var i = 0; i < weeks * 7; i++) {
    final at = DateTime(now.year, now.month, now.day + i, hour);
    if (at.isAfter(now) && const {DateTime.monday, DateTime.wednesday, DateTime.saturday}.contains(at.weekday)) out.add(at);
  }
  return out;
}

/// "Doğa notları": two or three facts a week, on by default, in a channel of
/// their own so turning them off never touches fire alerts.
class NatureNotes {
  NatureNotes._();
  static const _enabledKey = 'nature_notes_enabled';
  static const _planKey = 'nature_notes_plan';
  static const channelId = 'firewatch_nature_notes';
  static const _firstId = 7401;
  static const _maxIds = 12;
  static const _sampleId = 7420;
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<bool> enabled() async => (await SharedPreferences.getInstance()).getBool(_enabledKey) ?? true;

  static NotificationDetails _details(AppLocalizations l10n, String body) => NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          l10n.fidanReminderChannel,
          importance: Importance.low,
          priority: Priority.low,
          styleInformation: BigTextStyleInformation(body),
        ),
      );

  static Future<void> setEnabled(bool on, AppLocalizations l10n, String lang) async {
    await (await SharedPreferences.getInstance()).setBool(_enabledKey, on);
    await sync(l10n, lang);
  }

  /// Keeps three weeks queued. A day already planned keeps its fact, so
  /// opening the app does not use up the pool.
  static Future<void> sync(AppLocalizations l10n, String lang, {DateTime? now}) async {
    try {
      for (var i = 0; i < _maxIds; i++) {
        await _plugin.cancel(_firstId + i);
      }
      if (!await enabled()) return;
      final at = now ?? DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_planKey);
      final old = raw == null ? const <String, dynamic>{} : jsonDecode(raw) as Map<String, dynamic>;
      final plan = <String, String>{};
      for (final (i, day) in noteDays(at).take(_maxIds).indexed) {
        final key = dayKey(day);
        final fact = await NatureFacts.instance.planned(old[key] as String?, day);
        plan[key] = fact.id;
        final body = fact.of(lang);
        await _plugin.zonedSchedule(
          _firstId + i,
          l10n.fidanDidYouKnow,
          body,
          tz.TZDateTime.from(day.toUtc(), tz.UTC),
          _details(l10n, body),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
      await prefs.setString(_planKey, jsonEncode(plan));
    } catch (e) {
      if (kDebugMode) debugPrint('Nature notes: $e');
    }
  }

  /// One straight away, so people can see what they will get.
  static Future<void> showSample(AppLocalizations l10n, String lang) async {
    final fact = await NatureFacts.instance.forSlot('sample', DateTime.now());
    final body = fact.of(lang);
    await _plugin.show(_sampleId, l10n.fidanDidYouKnow, body, _details(l10n, body));
  }
}
