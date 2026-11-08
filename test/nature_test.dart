import 'dart:convert';
import 'dart:io';

import 'package:firewatch_tr/features/nature/fidan_account.dart';
import 'package:firewatch_tr/features/nature/fidan_screen.dart';
import 'package:firewatch_tr/features/nature/nature_content.dart';
import 'package:firewatch_tr/features/nature/nature_facts.dart';
import 'package:firewatch_tr/features/nature/nature_progress.dart';
import 'package:firewatch_tr/features/nature/tree.dart';
import 'package:firewatch_tr/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeCloud implements NatureCloud {
  Map<String, Map<String, dynamic>> docs = {};
  @override
  Future<Map<String, dynamic>?> read(String uid) async => docs[uid];
  @override
  Future<void> write(String uid, Map<String, dynamic> data) async => docs[uid] = data;
  @override
  Future<void> delete(String uid) async => docs.remove(uid);
}

List<NatureFact> _facts() => (jsonDecode(File('assets/data/nature_facts.json').readAsStringSync()) as List)
    .map((e) => NatureFact.fromJson(Map<String, dynamic>.from(e as Map)))
    .toList();

NatureFact _fact(String id, String season) =>
    NatureFact(id: id, tr: id, en: id, category: 'x', season: season, sourceName: 's', sourceUrl: 'https://a/b');

Map<String, bool> _days(DateTime from, int n) => {for (var i = 0; i < n; i++) dayKey(DateTime(from.year, from.month, from.day + i)): true};

Widget _app(Widget home) => MaterialApp(
      locale: const Locale('tr'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  TestWidgetsFlutterBinding.ensureInitialized();

  final texts = <String>[
    for (final l in natureLessons) ...[
      l.title.tr,
      for (final c in l.cards) ...[c.title.tr, c.body.tr],
      for (final q in l.quiz) ...[q.question.tr, q.feedback.tr, for (final o in q.options) o.tr],
    ],
    for (final t in natureTasks) ...[t.title.tr, t.text.tr],
  ];

  group('content', () {
    test('every card, quiz and prevention task has an https source', () {
      for (final l in natureLessons) {
        for (final c in l.cards) {
          expect(c.sources, isNotEmpty);
          for (final s in c.sources) {
            expect(s.url, startsWith('https://'));
          }
        }
        for (final q in l.quiz) {
          expect(q.source.url, startsWith('https://'));
          expect(q.correct, inInclusiveRange(0, q.options.length - 1));
        }
      }
      for (final t in natureTasks.where((t) => t.kind == NatureTaskKind.prevention)) {
        expect(t.source, isNotNull);
      }
    });

    test('short sentences, no technical words, no probability, no "it is out"', () {
      final banned = RegExp(r'hektar|yüzde \d|olasılık|ihtimal|ekosistem|baskın tür|gençleştirme', caseSensitive: false);
      for (final t in texts) {
        expect(banned.hasMatch(t), isFalse, reason: t);
      }
      for (final l in natureLessons) {
        for (final c in l.cards) {
          expect(RegExp(r'[.!?](\s|$)').allMatches(c.body.tr).length, lessThanOrEqualTo(2), reason: c.body.tr);
        }
      }
    });

    test('nothing rewards a fire report or a 112 call', () {
      for (final t in natureTasks) {
        expect('${t.title.tr} ${t.text.tr}'.contains('112'), isFalse);
        expect('${t.title.tr} ${t.text.tr}'.toLowerCase().contains('ihbar'), isFalse);
      }
    });

    test('TEMA is neither linked nor named', () {
      final src = File('lib/features/nature/fidan_screen.dart').readAsStringSync() + File('assets/data/nature_facts.json').readAsStringSync();
      expect(RegExp(r'tema\.org|TEMA').hasMatch(src), isFalse);
    });
  });

  group('fact pool', () {
    final facts = _facts();

    test('at least 120, none twice, each with a specific source page', () {
      expect(facts.length, greaterThanOrEqualTo(120));
      expect(facts.map((f) => f.tr).toSet().length, facts.length);
      expect(facts.map((f) => f.en).toSet().length, facts.length);
      expect(facts.map((f) => f.id).toSet().length, facts.length);
      for (final f in facts) {
        expect(f.tr.trim(), isNotEmpty);
        expect(f.en.trim(), isNotEmpty);
        expect(f.sourceName.trim(), isNotEmpty, reason: f.id);
        expect(RegExp(r'^https://[^/]+/.+').hasMatch(f.sourceUrl), isTrue, reason: f.id);
      }
    });

    test('every fact is in FACTS-DOGRULAMA.md', () {
      final table = File('FACTS-DOGRULAMA.md').readAsStringSync();
      for (final f in facts) {
        expect(table.contains('| ${f.id} |'), isTrue, reason: f.id);
      }
    });

    test('no repeat until the whole pool has been shown', () {
      var state = const FactDeckState(seed: 7);
      final seen = <String>{};
      var day = DateTime(2026, 1, 1);
      for (var i = 0; i < facts.length; i++) {
        final (f, next) = nextFact(facts, state, day);
        expect(seen.add(f.id), isTrue, reason: 'repeated ${f.id} on day $i');
        state = next;
        day = day.add(const Duration(days: 1));
      }
      final (again, _) = nextFact(facts, state, day);
      expect(seen.contains(again.id), isTrue, reason: 'a new round starts only now');
    });

    test('the same fact all day; another phone has another order', () {
      final day = DateTime(2026, 6, 2, 9);
      final (a, s) = nextFact(facts, const FactDeckState(seed: 1), day);
      final (b, s2) = nextFact(facts, s, DateTime(2026, 6, 2, 22));
      expect(b.id, a.id);
      expect(s2.shown.length, 1);
      final orders = {for (var seed = 0; seed < 8; seed++) nextFact(facts, FactDeckState(seed: seed), day).$1.id};
      expect(orders.length, greaterThan(1));
    });

    test('a fact of another season waits until nothing else is left', () {
      final pool = [_fact('w', 'winter'), _fact('a', 'all')];
      final july = DateTime(2026, 7, 2);
      final (first, s) = nextFact(pool, const FactDeckState(seed: 3), july);
      expect(first.id, 'a');
      final (second, _) = nextFact(pool, s, july.add(const Duration(days: 1)));
      expect(second.id, 'w');
    });

    test('the season gets its turn', () {
      final pool = [_fact('s', 'summer'), for (var i = 0; i < 30; i++) _fact('a$i', 'all')];
      // A day number divisible by three.
      var day = DateTime(2026, 7, 1);
      while (DateTime.utc(day.year, day.month, day.day).millisecondsSinceEpoch ~/ 86400000 % 3 != 0) {
        day = day.add(const Duration(days: 1));
      }
      expect(nextFact(pool, const FactDeckState(seed: 5), day).$1.id, 's');
    });

    test('works offline from the bundled list and marks what it showed', () async {
      SharedPreferences.setMockInitialValues({});
      final f = await NatureFacts.instance.today(DateTime(2026, 11, 8), bundle: _FileBundle(), refresh: false);
      expect(f.tr, isNotEmpty);
      final raw = (await SharedPreferences.getInstance()).getString('nature_facts_deck')!;
      expect((jsonDecode(raw)['shown'] as List), [f.id]);
    });
  });

  group('tree', () {
    final start = DateTime(2026, 1, 5);
    test('stages follow real days done', () {
      expect(treeStage(const NatureProgress()), 0);
      expect(treeStage(const NatureProgress(lessons: {'x'})), 1);
      expect(treeStage(NatureProgress(days: _days(start, 1))), 1);
      expect(treeStage(NatureProgress(days: _days(start, 6))), 1);
      expect(treeStage(NatureProgress(days: _days(start, 7))), 2);
      expect(treeStage(NatureProgress(days: _days(start, 30))), 3);
      expect(treeStage(NatureProgress(days: _days(start, 60))), 4);
      expect(treeStage(NatureProgress(days: _days(start, 90))), 5);
    });

    test('an old "not today" gives no growth or points', () {
      final p = NatureProgress(days: {dayKey(start): false});
      expect(activeDays(p), 0);
      expect(xpOf(p), 0);
    });

    test('xp and apples', () {
      final week = _days(DateTime(2026, 1, 5), 4);
      final p = NatureProgress(days: week, lessons: const {'see_fire'}, shares: 1);
      expect(xpOf(p), 40 + 20 + 5);
      final apples = applesOf(p);
      expect(apples.map((a) => a.id), ['lesson:see_fire', 'week:2026-01-05']);
      expect(applesOf(NatureProgress(days: _days(DateTime(2026, 1, 5), 3))), isEmpty);
    });

    test('seasons follow the calendar', () {
      expect(seasonOf(DateTime(2026, 1, 1)), Season.winter);
      expect(seasonOf(DateTime(2026, 4, 1)), Season.spring);
      expect(seasonOf(DateTime(2026, 7, 1)), Season.summer);
      expect(seasonOf(DateTime(2026, 11, 1)), Season.autumn);
    });

    test('thirsty after three dry days, never for a new user', () {
      final today = DateTime(2026, 3, 10);
      expect(isThirsty(const NatureProgress(), today), isFalse);
      expect(isThirsty(NatureProgress(days: {dayKey(DateTime(2026, 3, 8)): true}), today), isFalse);
      expect(isThirsty(NatureProgress(days: {dayKey(DateTime(2026, 3, 7)): true}), today), isTrue);
    });
  });

  group('streak', () {
    final today = DateTime(2026, 11, 8);
    test('counts days in a row', () {
      expect(currentStreak({dayKey(today): true, dayKey(today.subtract(const Duration(days: 1))): true}, today), 2);
    });
    test('today not marked yet costs nothing', () {
      expect(currentStreak({dayKey(today.subtract(const Duration(days: 1))): true}, today), 1);
    });
    test('task stays all day; another task changes it; seasonal only in season', () {
      expect(taskFor(today, swapped: false).id, taskFor(DateTime(2026, 11, 8, 22), swapped: false).id);
      expect(taskFor(today, swapped: true).id, isNot(taskFor(today, swapped: false).id));
      for (var d = 0; d < 400; d++) {
        final day = DateTime(2026, 1, 1 + d);
        final t = taskFor(day, swapped: false);
        expect(t.months == null || t.months!.contains(day.month), isTrue);
      }
    });
  });

  group('reminder', () {
    final now = DateTime(2026, 11, 8, 10);
    test('at the chosen time, one a day, a week ahead', () {
      final t = reminderTimes(now, hour: 19, minute: 30, doneToday: false);
      expect(t.length, 7);
      expect(t.first, DateTime(2026, 11, 8, 19, 30));
      expect(t[1], DateTime(2026, 11, 9, 19, 30));
    });
    test('not today once the task is marked or the time has passed', () {
      expect(reminderTimes(now, hour: 19, minute: 0, doneToday: true).first, DateTime(2026, 11, 9, 19));
      expect(reminderTimes(now, hour: 9, minute: 0, doneToday: false).first, DateTime(2026, 11, 9, 9));
    });
    test('off until asked for, in its own channel', () {
      expect(const NatureProgress().reminder, isFalse);
      expect(File('lib/features/nature/fidan_screen.dart').readAsStringSync(), contains('firewatch_nature_notes'));
    });
  });

  group('sync', () {
    test('only progress reaches the cloud, never province or settings', () {
      final json = cloudJson(const NatureProgress(plate: '07', reminder: true, reminderHour: 8, hideStreak: true, shares: 2));
      expect(json.keys.toSet(), {'days', 'lessons', 'shares', 'observations', 'longestStreak'});
      expect(jsonEncode(json).contains('07'), isFalse);
    });

    test('the Firestore rules allow exactly those fields', () {
      final rules = File('firestore.rules').readAsStringSync();
      for (final k in [...cloudJson(const NatureProgress()).keys, 'updatedAt']) {
        expect(rules, contains("'$k'"));
      }
      expect(rules, contains('hasOnly'));
    });

    test('merging loses nothing from either phone', () {
      const local = NatureProgress(days: {'2026-01-01': true, '2026-01-02': false}, lessons: {'a'}, shares: 1, observations: 5, longestStreak: 2, plate: '07', reminder: true);
      final merged = mergeProgress(local, {'days': {'2026-01-02': true, '2026-01-03': true}, 'lessons': ['b'], 'shares': 4, 'observations': 1, 'longestStreak': 9});
      expect(merged.days, {'2026-01-01': true, '2026-01-02': true, '2026-01-03': true});
      expect(merged.lessons, {'a', 'b'});
      expect(merged.shares, 4);
      expect(merged.observations, 5);
      expect(merged.longestStreak, 9);
      expect(merged.plate, '07', reason: 'phone settings stay');
      expect(merged.reminder, isTrue);
    });

    test('a new phone gets the old one back and the cloud gets the sum', () async {
      SharedPreferences.setMockInitialValues({});
      final store = NatureStore.instance;
      await store.deleteAll();
      await store.save(const NatureProgress(lessons: {'here'}));
      final cloud = _FakeCloud()..docs['u'] = {'days': {'2026-01-01': true}, 'lessons': ['there'], 'shares': 0, 'observations': 0, 'longestStreak': 1};
      await syncNatureProgress(store, cloud, 'u');
      expect(store.progress.lessons, {'here', 'there'});
      expect(store.progress.days.keys, ['2026-01-01']);
      expect((cloud.docs['u']!['lessons'] as List).toSet(), {'here', 'there'});
    });
  });

  group('storage and backup', () {
    test('old progress moves to its own file', () async {
      SharedPreferences.setMockInitialValues({'nature_progress_v1': jsonEncode(const NatureProgress(shares: 3).toJson())});
      final store = NatureStore.instance;
      await store.load();
      expect(store.progress.shares, 3);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('nature_progress_v1'), isNull);
      await store.deleteAll();
      await store.load();
      expect(store.progress.shares, 0);
    });

    test('backup takes the progress file and nothing else', () {
      for (final f in ['nature_data_extraction_rules.xml', 'nature_backup_rules.xml']) {
        final xml = File('android/app/src/main/res/xml/$f').readAsStringSync();
        final paths = RegExp(r'path="([^"]+)"').allMatches(xml).map((m) => m[1]).toSet();
        expect(paths, {'nature_progress.xml'});
        expect(xml, isNot(contains('<exclude')));
      }
      final m = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
      expect(m, contains('android:allowBackup="true"'));
      expect(m, contains('@xml/nature_data_extraction_rules'));
      expect(m, contains('@xml/nature_backup_rules'));
    });
  });

  group('screens', () {
    Future<void> settle(WidgetTester t, [int n = 30]) async {
      for (var i = 0; i < n; i++) {
        await t.pump(const Duration(milliseconds: 100));
      }
    }

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await NatureStore.instance.deleteAll();
    });

    for (final width in [360.0, 411.0]) {
      for (final scale in [1.0, 1.3]) {
        testWidgets('home card and lesson path fit at ${width.toInt()} dp, text x$scale', (t) async {
          t.view.physicalSize = Size(width, 800) * 2;
          t.view.devicePixelRatio = 2;
          addTearDown(t.view.reset);
          await t.pumpWidget(MediaQuery(
            data: MediaQueryData(size: Size(width, 800), textScaler: TextScaler.linear(scale)),
            child: _app(Scaffold(body: SingleChildScrollView(child: FidanHomeCard(today: DateTime(2026, 11, 8))))),
          ));
          await settle(t, 5);
          expect(t.takeException(), isNull);
          await t.pumpWidget(MediaQuery(
            data: MediaQueryData(size: Size(width, 800), textScaler: TextScaler.linear(scale)),
            child: _app(LessonPathScreen(today: DateTime(2026, 11, 8))),
          ));
          await settle(t, 5);
          expect(t.takeException(), isNull);
          expect(find.byKey(const Key('natureLesson-see_fire')), findsOneWidget);
        });
      }
    }

    testWidgets('a lesson: cards, quiz feedback, reward with an apple', (t) async {
      t.view.physicalSize = const Size(411, 891) * 2;
      t.view.devicePixelRatio = 2;
      addTearDown(t.view.reset);
      final lesson = natureLessons[1];
      await t.pumpWidget(_app(Builder(builder: (c) => Scaffold(body: Center(child: TextButton(onPressed: () => Navigator.of(c).push(MaterialPageRoute<void>(builder: (_) => NatureLessonScreen(lesson: lesson, today: DateTime(2026, 11, 8)))), child: const Text('go')))))));
      await t.tap(find.text('go'));
      await settle(t, 6);
      for (var i = 0; i < lesson.cards.length; i++) {
        expect(find.text(lesson.cards[i].title.tr), findsOneWidget);
        await t.tap(find.byKey(const Key('natureNext')));
        await settle(t, 6);
      }
      expect(find.text(lesson.quiz.first.question.tr), findsOneWidget);
      await t.tap(find.byKey(const Key('natureOption-1')));
      await settle(t, 6);
      expect(find.byKey(const Key('natureFeedback')), findsOneWidget);
      await t.tap(find.byKey(const Key('natureNext')));
      await settle(t, 8);
      expect(NatureStore.instance.progress.lessons, {lesson.id});
      expect(find.byKey(const Key('fidanXpGain')), findsOneWidget);
      expect(find.byKey(const Key('fidanNewApple')), findsOneWidget);
      await settle(t, 26);
    });

    testWidgets('sign-in screen carries the under-13 note and no e-mail field', (t) async {
      await t.pumpWidget(_app(const FidanSignInScreen()));
      await settle(t, 3);
      expect(find.byKey(const Key('fidanUnder13')), findsOneWidget);
      expect(find.byKey(const Key('fidanGoogleButton')), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
    });
  });
}

class _FileBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async => ByteData.sublistView(File(key).readAsBytesSync());
}
