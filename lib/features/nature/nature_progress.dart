import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'nature_content.dart';

/// All Nature progress. It lives only on this phone and is never sent
/// anywhere; deleting the app or using "delete" below removes it.
class NatureProgress {
  /// 'yyyy-MM-dd' to true (did it) or false (not today). Both keep the day.
  final Map<String, bool> days;
  final Set<String> lessons;
  final int shares;
  final int observations;
  final int longestStreak;
  final String? swappedOn;
  final bool hideStreak;
  final bool reminder;
  final String? plate;

  const NatureProgress({
    this.days = const {},
    this.lessons = const {},
    this.shares = 0,
    this.observations = 0,
    this.longestStreak = 0,
    this.swappedOn,
    this.hideStreak = false,
    this.reminder = false,
    this.plate,
  });

  NatureProgress copyWith({
    Map<String, bool>? days,
    Set<String>? lessons,
    int? shares,
    int? observations,
    int? longestStreak,
    String? swappedOn,
    bool? hideStreak,
    bool? reminder,
    String? plate,
  }) =>
      NatureProgress(
        days: days ?? this.days,
        lessons: lessons ?? this.lessons,
        shares: shares ?? this.shares,
        observations: observations ?? this.observations,
        longestStreak: longestStreak ?? this.longestStreak,
        swappedOn: swappedOn ?? this.swappedOn,
        hideStreak: hideStreak ?? this.hideStreak,
        reminder: reminder ?? this.reminder,
        plate: plate ?? this.plate,
      );

  Map<String, dynamic> toJson() => {
        'days': days,
        'lessons': lessons.toList(),
        'shares': shares,
        'observations': observations,
        'longestStreak': longestStreak,
        'swappedOn': swappedOn,
        'hideStreak': hideStreak,
        'reminder': reminder,
        'plate': plate,
      };

  factory NatureProgress.fromJson(Map<String, dynamic> j) => NatureProgress(
        days: (j['days'] as Map?)?.map((k, v) => MapEntry('$k', v == true)) ?? const {},
        lessons: ((j['lessons'] as List?) ?? const []).map((e) => '$e').toSet(),
        shares: (j['shares'] as num?)?.toInt() ?? 0,
        observations: (j['observations'] as num?)?.toInt() ?? 0,
        longestStreak: (j['longestStreak'] as num?)?.toInt() ?? 0,
        swappedOn: j['swappedOn'] as String?,
        hideStreak: j['hideStreak'] == true,
        reminder: j['reminder'] == true,
        plate: j['plate'] as String?,
      );
}

String dayKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime _monday(DateTime d) => DateTime(d.year, d.month, d.day).subtract(Duration(days: d.weekday - 1));

/// Marked days in a row, counted back from today. Up to two missed days per
/// Monday-to-Sunday week are forgiven without being asked; today not being
/// marked yet never counts against it.
int currentStreak(Map<String, bool> days, DateTime today) {
  var streak = 0;
  var misses = 0;
  var week = _monday(today);
  var cursor = DateTime(today.year, today.month, today.day);
  if (!days.containsKey(dayKey(cursor))) cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
  for (var i = 0; i < 3660; i++) {
    final monday = _monday(cursor);
    if (monday != week) {
      week = monday;
      misses = 0;
    }
    if (days.containsKey(dayKey(cursor))) {
      streak++;
    } else {
      misses++;
      if (misses > 2) break;
    }
    cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
  }
  return streak;
}

int daysThisWeek(Map<String, bool> days, DateTime today) {
  final monday = _monday(today);
  return List.generate(7, (i) => DateTime(monday.year, monday.month, monday.day + i)).where((d) => days.containsKey(dayKey(d))).length;
}

List<bool> weekDots(Map<String, bool> days, DateTime today) {
  final monday = _monday(today);
  return List.generate(7, (i) => days.containsKey(dayKey(DateTime(monday.year, monday.month, monday.day + i))));
}

/// One task a day, the same all day. "Another task" moves one step, once.
NatureTask taskFor(DateTime today, {required bool swapped}) {
  final pool = natureTasks.where((t) => t.months == null || t.months!.contains(today.month)).toList();
  final dayNumber = DateTime.utc(today.year, today.month, today.day).millisecondsSinceEpoch ~/ 86400000;
  return pool[(dayNumber + (swapped ? 1 : 0)) % pool.length];
}

NatureFact factFor(DateTime today) {
  final dayNumber = DateTime.utc(today.year, today.month, today.day).millisecondsSinceEpoch ~/ 86400000;
  return natureFacts[dayNumber % natureFacts.length];
}

WeeklyGoal goalFor(DateTime today) {
  final week = _monday(today).toUtc().millisecondsSinceEpoch ~/ (7 * 86400000);
  return WeeklyGoal.values[week % WeeklyGoal.values.length];
}

enum NatureBadge { firstStep, sevenDays, thirtyDays, fourSeasons, curious, knowledgeable, sharer, observer }

Set<NatureBadge> earnedBadges(NatureProgress p) {
  int season(String key) => ((int.parse(key.substring(5, 7)) % 12) / 3).floor();
  final allLessons = natureLessons.every((l) => p.lessons.contains(l.id));
  return {
    if (p.days.isNotEmpty) NatureBadge.firstStep,
    if (p.days.length >= 7) NatureBadge.sevenDays,
    if (p.days.length >= 30) NatureBadge.thirtyDays,
    if (p.days.keys.map(season).toSet().length == 4) NatureBadge.fourSeasons,
    if (p.lessons.length >= 2) NatureBadge.curious,
    if (allLessons) NatureBadge.knowledgeable,
    if (p.shares >= 5) NatureBadge.sharer,
    if (p.observations >= 3) NatureBadge.observer,
  };
}

class NatureStore extends ChangeNotifier {
  NatureStore._();
  static final NatureStore instance = NatureStore._();
  static const _key = 'nature_progress_v1';

  NatureProgress progress = const NatureProgress();
  bool loaded = false;

  Future<void> load() async {
    final raw = (await SharedPreferences.getInstance()).getString(_key);
    try {
      if (raw != null) progress = NatureProgress.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      progress = const NatureProgress();
    }
    loaded = true;
    notifyListeners();
  }

  Future<void> save(NatureProgress next) async {
    final today = DateTime.now();
    final streak = currentStreak(next.days, today);
    progress = streak > next.longestStreak ? next.copyWith(longestStreak: streak) : next;
    notifyListeners();
    await (await SharedPreferences.getInstance()).setString(_key, jsonEncode(progress.toJson()));
  }

  Future<void> mark(DateTime today, bool done) =>
      save(progress.copyWith(days: {...progress.days, dayKey(today): done}));

  Future<void> addShare() => save(progress.copyWith(shares: progress.shares + 1));
  Future<void> addObservation() => save(progress.copyWith(observations: progress.observations + 1));
  Future<void> finishLesson(String id) => save(progress.copyWith(lessons: {...progress.lessons, id}));

  Future<void> deleteAll() async {
    progress = const NatureProgress();
    notifyListeners();
    await (await SharedPreferences.getInstance()).remove(_key);
  }
}
