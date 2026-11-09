import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_android/shared_preferences_android.dart';

import 'nature_content.dart';
import 'tree.dart';

/// All Fidan progress. Kept on this phone, in a file of its own so that
/// Android backup can take this file and nothing else. It reaches the cloud
/// only for someone who signs in with Google, and then only [cloudJson].
class NatureProgress {
  /// 'yyyy-MM-dd' to true (did it) or false (not today). Both keep the day.
  final Map<String, bool> days;
  final Set<String> lessons;

  /// Finished lessons played again. Worth less than a first finish.
  final int replays;
  final int shares;
  final int observations;
  final int longestStreak;
  final String? swappedOn;
  final bool hideStreak;
  final bool reminder;
  final int reminderHour;
  final int reminderMinute;
  final String? plate;

  const NatureProgress({
    this.days = const {},
    this.lessons = const {},
    this.replays = 0,
    this.shares = 0,
    this.observations = 0,
    this.longestStreak = 0,
    this.swappedOn,
    this.hideStreak = false,
    this.reminder = false,
    this.reminderHour = 19,
    this.reminderMinute = 0,
    this.plate,
  });

  NatureProgress copyWith({
    Map<String, bool>? days,
    Set<String>? lessons,
    int? replays,
    int? shares,
    int? observations,
    int? longestStreak,
    String? swappedOn,
    bool? hideStreak,
    bool? reminder,
    int? reminderHour,
    int? reminderMinute,
    String? plate,
  }) =>
      NatureProgress(
        days: days ?? this.days,
        lessons: lessons ?? this.lessons,
        replays: replays ?? this.replays,
        shares: shares ?? this.shares,
        observations: observations ?? this.observations,
        longestStreak: longestStreak ?? this.longestStreak,
        swappedOn: swappedOn ?? this.swappedOn,
        hideStreak: hideStreak ?? this.hideStreak,
        reminder: reminder ?? this.reminder,
        reminderHour: reminderHour ?? this.reminderHour,
        reminderMinute: reminderMinute ?? this.reminderMinute,
        plate: plate ?? this.plate,
      );

  Map<String, dynamic> toJson() => {
        'days': days,
        'lessons': lessons.toList(),
        'replays': replays,
        'shares': shares,
        'observations': observations,
        'longestStreak': longestStreak,
        'swappedOn': swappedOn,
        'hideStreak': hideStreak,
        'reminder': reminder,
        'reminderHour': reminderHour,
        'reminderMinute': reminderMinute,
        'plate': plate,
      };

  factory NatureProgress.fromJson(Map<String, dynamic> j) => NatureProgress(
        days: (j['days'] as Map?)?.map((k, v) => MapEntry('$k', v == true)) ?? const {},
        lessons: ((j['lessons'] as List?) ?? const []).map((e) => '$e').toSet(),
        replays: (j['replays'] as num?)?.toInt() ?? 0,
        shares: (j['shares'] as num?)?.toInt() ?? 0,
        observations: (j['observations'] as num?)?.toInt() ?? 0,
        longestStreak: (j['longestStreak'] as num?)?.toInt() ?? 0,
        swappedOn: j['swappedOn'] as String?,
        hideStreak: j['hideStreak'] == true,
        reminder: j['reminder'] == true,
        reminderHour: (j['reminderHour'] as num?)?.toInt() ?? 19,
        reminderMinute: (j['reminderMinute'] as num?)?.toInt() ?? 0,
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

/// The next reminders, one a day at most. Today is left out when its task
/// is already marked or the time has passed. Only a week is ever queued, so
/// someone who stops opening the tab stops being reminded.
List<DateTime> reminderTimes(DateTime now, {required int hour, required int minute, required bool doneToday, int count = 7}) {
  final out = <DateTime>[];
  for (var i = 0; out.length < count; i++) {
    final at = DateTime(now.year, now.month, now.day + i, hour, minute);
    if (i == 0 && (doneToday || !at.isAfter(now))) continue;
    out.add(at);
  }
  return out;
}

/// Days the task was really done; an old "not today" keeps the streak only.
int activeDays(NatureProgress p) => p.days.values.where((done) => done).length;

const lessonXp = 20;
const replayXp = 5;
const sectionXp = 50;

/// Sections with every lesson finished, in the order of the path.
List<NatureSection> sectionsDone(NatureProgress p) =>
    natureSections.where((s) => s.lessons.every((l) => p.lessons.contains(l.id))).toList();

bool allLessonsDone(NatureProgress p) => natureLessons.every((l) => p.lessons.contains(l.id));

/// Ten for a task, twenty for a lesson, fifty for a whole section, five for a
/// replay, a share or an observation. Nothing here counts a fire report or a
/// call to 112.
int xpOf(NatureProgress p) =>
    activeDays(p) * 10 + p.lessons.length * lessonXp + sectionsDone(p).length * sectionXp + p.replays * replayXp + p.shares * 5 + p.observations * 5;

/// 0 seed, 1 sprout, 2 sapling, 3 young tree, 4 in blossom, 5 with fruit.
int treeStage(NatureProgress p) {
  final n = activeDays(p);
  if (n >= 90) return 5;
  if (n >= 60) return 4;
  if (n >= 30) return 3;
  if (n >= 7) return 2;
  return n > 0 || p.lessons.isNotEmpty ? 1 : 0;
}

const weeklyGoalDays = 4;

Season seasonOf(DateTime d) => switch (d.month) {
      12 || 1 || 2 => Season.winter,
      3 || 4 || 5 => Season.spring,
      6 || 7 || 8 => Season.summer,
      _ => Season.autumn,
    };

/// Three days without water. The tree only looks a little thirsty; it never dies.
bool isThirsty(NatureProgress p, DateTime today) {
  if (p.days.isEmpty) return false;
  return !List.generate(3, (i) => DateTime(today.year, today.month, today.day - i)).any((d) => p.days[dayKey(d)] == true);
}

class Apple {
  final String id;

  /// A lesson id, or null when the apple is for a week's goal.
  final String? lesson;

  /// 'yyyy-MM-dd' of the Monday, for a week's goal.
  final String? week;

  /// A section id, for finishing every lesson in it.
  final String? section;
  const Apple.lesson(String this.lesson)
      : id = 'lesson:$lesson',
        week = null,
        section = null;
  const Apple.week(String this.week)
      : id = 'week:$week',
        lesson = null,
        section = null;
  const Apple.section(String this.section)
      : id = 'section:$section',
        lesson = null,
        week = null;
}

/// One apple per finished lesson, per finished section and per week with the
/// goal met.
List<Apple> applesOf(NatureProgress p) {
  final perWeek = <String, int>{};
  for (final e in p.days.entries) {
    if (!e.value) continue;
    final week = dayKey(_monday(DateTime.parse(e.key)));
    perWeek[week] = (perWeek[week] ?? 0) + 1;
  }
  final weeks = perWeek.entries.where((e) => e.value >= weeklyGoalDays).map((e) => e.key).toList()..sort();
  return [for (final l in natureLessons) if (p.lessons.contains(l.id)) Apple.lesson(l.id), for (final s in sectionsDone(p)) Apple.section(s.id), for (final w in weeks) Apple.week(w)];
}

/// The only fields that ever reach the cloud. Province, reminder settings
/// and anything about location stay on the phone.
Map<String, dynamic> cloudJson(NatureProgress p) => {
      'days': p.days,
      'lessons': p.lessons.toList()..sort(),
      'replays': p.replays,
      'shares': p.shares,
      'observations': p.observations,
      'longestStreak': p.longestStreak,
    };

/// Nothing earned on either phone is lost: days and lessons add up, counts
/// keep the larger value, and a day done on one phone stays done.
NatureProgress mergeProgress(NatureProgress local, Map<String, dynamic> remote) {
  final other = NatureProgress.fromJson(remote);
  final days = {...other.days};
  local.days.forEach((k, v) => days[k] = v || (days[k] ?? false));
  int max(int a, int b) => a > b ? a : b;
  return local.copyWith(
    days: days,
    lessons: {...local.lessons, ...other.lessons},
    replays: max(local.replays, other.replays),
    shares: max(local.shares, other.shares),
    observations: max(local.observations, other.observations),
    longestStreak: max(local.longestStreak, other.longestStreak),
  );
}

abstract class NatureStorage {
  Future<String?> read();
  Future<void> write(String value);
  Future<void> clear();
}

/// `nature_progress.xml`, the one file the backup rules include.
class _AndroidFileStorage implements NatureStorage {
  static const _key = 'progress';
  final _prefs = SharedPreferencesAsync(
    options: const SharedPreferencesAsyncAndroidOptions(
      backend: SharedPreferencesAndroidBackendLibrary.SharedPreferences,
      originalSharedPreferencesOptions: AndroidSharedPreferencesStoreOptions(fileName: 'nature_progress'),
    ),
  );
  @override
  Future<String?> read() => _prefs.getString(_key);
  @override
  Future<void> write(String value) => _prefs.setString(_key, value);
  @override
  Future<void> clear() => _prefs.remove(_key);
}

class _PrefsStorage implements NatureStorage {
  static const _key = 'nature_progress_file';
  @override
  Future<String?> read() async => (await SharedPreferences.getInstance()).getString(_key);
  @override
  Future<void> write(String value) async => (await SharedPreferences.getInstance()).setString(_key, value);
  @override
  Future<void> clear() async => (await SharedPreferences.getInstance()).remove(_key);
}

class NatureStore extends ChangeNotifier {
  NatureStore._();
  static final NatureStore instance = NatureStore._();

  /// Where progress lived before it had a file of its own.
  static const _legacyKey = 'nature_progress_v1';

  NatureStorage storage = !kIsWeb && Platform.isAndroid ? _AndroidFileStorage() : _PrefsStorage();

  /// Called after every change; the signed-in account uses it to sync.
  void Function(NatureProgress)? onSaved;

  NatureProgress progress = const NatureProgress();
  bool loaded = false;

  Future<void> load() async {
    try {
      var raw = await storage.read();
      if (raw == null) {
        final prefs = await SharedPreferences.getInstance();
        raw = prefs.getString(_legacyKey);
        if (raw != null) {
          await storage.write(raw);
          await prefs.remove(_legacyKey);
        }
      }
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
    await storage.write(jsonEncode(progress.toJson()));
    onSaved?.call(progress);
  }

  /// A merge from the cloud; saved here but not sent straight back.
  Future<void> replace(NatureProgress next) async {
    progress = next;
    notifyListeners();
    await storage.write(jsonEncode(progress.toJson()));
  }

  Future<void> mark(DateTime today, bool done) =>
      save(progress.copyWith(days: {...progress.days, dayKey(today): done}));

  Future<void> addShare() => save(progress.copyWith(shares: progress.shares + 1));
  Future<void> addObservation() => save(progress.copyWith(observations: progress.observations + 1));
  Future<void> finishLesson(String id) => save(progress.copyWith(lessons: {...progress.lessons, id}));
  Future<void> addReplay() => save(progress.copyWith(replays: progress.replays + 1));

  Future<void> deleteAll() async {
    progress = const NatureProgress();
    notifyListeners();
    await storage.clear();
    await (await SharedPreferences.getInstance()).remove(_legacyKey);
  }
}
