import 'dart:io';

import 'package:firewatch_tr/features/nature/fidan_screen.dart';
import 'package:firewatch_tr/features/nature/nature_content.dart';
import 'package:firewatch_tr/features/nature/nature_progress.dart';
import 'package:firewatch_tr/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _app(Widget home) => MaterialApp(
      locale: const Locale('tr'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );

final _today = DateTime(2026, 11, 8);

Iterable<LessonQuestion> get _questions => natureLessons.expand((l) => l.quiz);

Iterable<NatureSource> get _allSources sync* {
  for (final l in natureLessons) {
    for (final c in l.cards) {
      yield* c.sources;
    }
    for (final q in l.quiz) {
      yield* q.sources;
    }
  }
}

Set<String> _allIds() => natureLessons.map((l) => l.id).toSet();

Future<void> _settle(WidgetTester t, [int n = 8]) async {
  for (var i = 0; i < n; i++) {
    await t.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _tap(WidgetTester t, Finder f) async {
  await t.ensureVisible(f);
  await t.pump();
  await t.tap(f);
  await t.pump(const Duration(milliseconds: 60));
}

/// Answers any kind of question, rightly unless told otherwise.
Future<void> _answer(WidgetTester t, LessonQuestion q, {bool right = true}) async {
  switch (q) {
    case QuizQuestion():
      final order = optionOrder(q);
      final option = right ? q.correct : order.firstWhere((o) => o != q.correct);
      await _tap(t, find.byKey(Key('natureOption-${order.indexOf(option)}')));
    case TrueFalseQuestion():
      await _tap(t, find.byKey(Key(q.isTrue == right ? 'natureTrue' : 'natureFalse')));
    case OrderQuestion():
      if (right) {
        final order = [...stepOrder(q)];
        for (var step = 0; step < order.length; step++) {
          for (var at = order.indexOf(step); at > step; at--) {
            await _tap(t, find.byKey(Key('natureUp-$at')));
            await t.pump(const Duration(milliseconds: 300));
            order.insert(at - 1, order.removeAt(at));
          }
        }
      }
      await _tap(t, find.byKey(const Key('natureCheck')));
    case MatchQuestion():
      for (var i = 0; i < q.pairs.length; i++) {
        await _tap(t, find.byKey(Key('natureMatchLeft-$i')));
        if (!right && i == 0) await _tap(t, find.byKey(const Key('natureMatchRight-1')));
        await _tap(t, find.byKey(Key('natureMatchRight-$i')));
      }
  }
  await _settle(t, 4);
}

Future<void> _openLesson(WidgetTester t, NatureLesson lesson) async {
  await t.pumpWidget(_app(Builder(
    builder: (c) => Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () => Navigator.of(c).push(MaterialPageRoute<void>(builder: (_) => NatureLessonScreen(lesson: lesson, today: _today))),
          child: const Text('go'),
        ),
      ),
    ),
  )));
  await t.tap(find.text('go'));
  await _settle(t, 6);
}

Future<void> _playThrough(WidgetTester t, NatureLesson lesson) async {
  for (final card in lesson.cards) {
    expect(find.text(card.title.tr), findsOneWidget);
    await t.tap(find.byKey(const Key('natureNext')));
    await _settle(t, 6);
  }
  for (final q in lesson.quiz) {
    await _answer(t, q);
    expect(find.byKey(const Key('natureFeedback')), findsOneWidget);
    await t.tap(find.byKey(const Key('natureNext')));
    await _settle(t, 6);
  }
}

void _tall(WidgetTester t, {double width = 411, double height = 1000}) {
  t.view.physicalSize = Size(width, height) * 2;
  t.view.devicePixelRatio = 2;
  addTearDown(t.view.reset);
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  TestWidgetsFlutterBinding.ensureInitialized();

  group('lesson content', () {
    test('at least 25 lessons in the five sections, ids unique, old ids kept', () {
      expect(natureLessons.length, greaterThanOrEqualTo(25));
      expect(natureSections.map((s) => s.title.tr), ['Yangın güvenliği', 'Orman ve ağaçlar', 'Ormanın hayvanları', 'Yanan orman nasıl yenilenir', 'Afetlere hazırlık']);
      expect(_allIds().length, natureLessons.length);
      expect(_allIds(), containsAll(['see_fire', 'how_fires_start', 'after_fire', 'turkey_numbers']));
      for (final s in natureSections) {
        expect(s.lessons.length, greaterThanOrEqualTo(5), reason: s.id);
      }
    });

    test('no multiple choice under three options, exactly one right answer', () {
      for (final q in _questions.whereType<QuizQuestion>()) {
        expect(q.options.length, inInclusiveRange(3, 4), reason: q.question.tr);
        expect(q.correct, inInclusiveRange(0, q.options.length - 1), reason: q.question.tr);
        expect(q.options.map((o) => o.tr).toSet().length, q.options.length, reason: q.question.tr);
      }
    });

    test('every kind of question is used, and see_fire shows all of them', () {
      expect(_questions.whereType<TrueFalseQuestion>(), isNotEmpty);
      expect(_questions.whereType<OrderQuestion>().length, greaterThanOrEqualTo(3));
      expect(_questions.whereType<MatchQuestion>().length, greaterThanOrEqualTo(3));
      final seeFire = natureLessons.firstWhere((l) => l.id == 'see_fire');
      expect(seeFire.quiz.map((q) => q.runtimeType).toSet(), {QuizQuestion, TrueFalseQuestion, OrderQuestion, MatchQuestion});
    });

    test('every question has a source and one sentence of feedback', () {
      expect(_allSources, isNotEmpty);
      for (final s in _allSources) {
        expect(s.url, startsWith('https://'));
        expect(s.name.trim(), isNotEmpty);
      }
      for (final q in _questions) {
        expect(q.sources, isNotEmpty);
        expect(RegExp(r'[.!?](\s|$)').allMatches(q.feedback.tr).length, 1, reason: q.feedback.tr);
      }
    });

    test('no blog, encyclopedia, news site or TEMA among the sources', () {
      final banned = RegExp(r'wikipedia|tema\.org|blogspot|wordpress|medium\.com|hurriyet|milliyet|sabah\.com|ntv\.com|cnn', caseSensitive: false);
      for (final s in _allSources) {
        expect(banned.hasMatch(s.url), isFalse, reason: s.url);
      }
    });

    test('the fire sequence calls 112 before anything else', () {
      final seeFire = natureLessons.firstWhere((l) => l.id == 'see_fire');
      final order = seeFire.quiz.whereType<OrderQuestion>().single;
      expect(order.steps.first.tr, contains('112'));
      final first = seeFire.quiz.whereType<QuizQuestion>().first;
      expect(first.options[first.correct].tr, contains('112'));
    });

    test('nothing teaches going to a fire, putting one out, or trusting a satellite', () {
      final rightAnswers = [
        for (final q in _questions.whereType<QuizQuestion>()) q.options[q.correct].tr,
        for (final q in _questions.whereType<OrderQuestion>()) ...q.steps.map((s) => s.tr),
        for (final q in _questions.whereType<MatchQuestion>()) ...q.pairs.map((p) => p.$2.tr),
      ];
      for (final a in rightAnswers) {
        expect(RegExp(r'yaklaşıp|söndürürüm|(^|\s)kesin', caseSensitive: false).hasMatch(a), isFalse, reason: a);
      }
      for (final l in natureLessons) {
        for (final c in l.cards) {
          final body = c.body.tr;
          // "Söndürme araçları" is the only firefighting word allowed: a vehicle to keep clear for.
          expect(RegExp(r'söndür(?!me araç)', caseSensitive: false).hasMatch(body), isFalse, reason: body);
          expect(RegExp(r'(^|\s)kesin', caseSensitive: false).hasMatch(body), isFalse, reason: body);
        }
      }
    });
  });

  group('sequence and matching logic', () {
    test('a scramble is never already solved, and stays the same', () {
      for (var n = 2; n <= 6; n++) {
        for (var seed = 0; seed < 300; seed++) {
          final s = scrambled(n, seed);
          expect(isInOrder(s), isFalse, reason: 'n=$n seed=$seed');
          expect(s.toSet().length, n);
          expect(s, scrambled(n, seed));
        }
      }
    });

    test('moving steps to the right order solves the question', () {
      expect(isInOrder([0, 1, 2]), isTrue);
      expect(isInOrder([1, 0, 2]), isFalse);
      expect(movedItem([1, 0, 2], 1, 0), [0, 1, 2]);
      expect(movedItem([0, 2, 1], 2, 1), [0, 1, 2]);
    });

    test('every ordering and matching question starts unsolved', () {
      for (final q in _questions.whereType<OrderQuestion>()) {
        expect(isInOrder(stepOrder(q)), isFalse, reason: q.prompt.tr);
      }
      for (final q in _questions.whereType<MatchQuestion>()) {
        expect(isInOrder(matchOrder(q)), isFalse, reason: q.prompt.tr);
      }
    });
  });

  group('progress', () {
    NatureProgress done(Iterable<String> ids) => NatureProgress(lessons: ids.toSet());

    test('a replay is worth less than a first finish, and never removes anything', () {
      expect(replayXp, lessThan(lessonXp));
      const p = NatureProgress(lessons: {'see_fire'});
      expect(xpOf(p.copyWith(replays: 1)) - xpOf(p), replayXp);
      expect(p.copyWith(replays: 3).lessons, p.lessons);
    });

    test('a section finished brings a flower-sized reward, once', () {
      final first = natureSections.first;
      final p = done(first.lessons.map((l) => l.id));
      expect(sectionsDone(p).map((s) => s.id), [first.id]);
      expect(xpOf(p), first.lessons.length * lessonXp + sectionXp);
      expect(applesOf(p).any((a) => a.id == 'section:${first.id}'), isTrue);
      expect(sectionsDone(const NatureProgress()), isEmpty);
      expect(allLessonsDone(done(_allIds())), isTrue);
      expect(allLessonsDone(p), isFalse);
    });

    test('replays sync: stored, merged by the larger count', () {
      expect(cloudJson(const NatureProgress(replays: 4))['replays'], 4);
      const local = NatureProgress(replays: 1, lessons: {'a'});
      expect(mergeProgress(local, {'replays': 7, 'lessons': <String>[]}).replays, 7);
      expect(mergeProgress(const NatureProgress(replays: 9), {'replays': 2, 'lessons': <String>[]}).replays, 9);
      expect(NatureProgress.fromJson(const {}).replays, 0);
      expect(NatureProgress.fromJson(const NatureProgress(replays: 2).toJson()).replays, 2);
    });

    test('the Firestore rules accept the new field and require a number', () {
      final rules = File('firestore.rules').readAsStringSync();
      expect(rules, contains("'replays'"));
      expect(rules, contains('replays is int'));
    });

    test('someone who finished the old lessons keeps every one of them', () {
      final p = done(['see_fire', 'how_fires_start', 'after_fire', 'turkey_numbers']);
      expect(applesOf(p).where((a) => a.lesson != null).length, 4);
      expect(allLessonsDone(p), isFalse);
    });
  });

  group('screens', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await NatureStore.instance.deleteAll();
    });

    for (final (width, scale) in const [(360.0, 1.0), (360.0, 1.3), (411.0, 1.3)]) {
      testWidgets('finished path, celebration, replay mode at ${width.toInt()} dp, text x$scale', (t) async {
        await NatureStore.instance.save(NatureProgress(lessons: _allIds()));
        t.view.physicalSize = Size(width, 800) * 2;
        t.view.devicePixelRatio = 2;
        addTearDown(t.view.reset);
        await t.pumpWidget(MediaQuery(
          data: MediaQueryData(size: Size(width, 800), textScaler: TextScaler.linear(scale)),
          child: _app(LessonPathScreen(today: _today)),
        ));
        await _settle(t, 5);
        expect(t.takeException(), isNull);
        expect(find.text('Tüm dersleri bitirdin!'), findsOneWidget);
        expect(find.byKey(const Key('fidanAllDone')), findsOneWidget);
        expect(find.byKey(const Key('natureReplay-see_fire')), findsOneWidget);
      });
    }

    testWidgets('a section ends in a reward on a fresh path, later lessons stay locked', (t) async {
      _tall(t);
      await t.pumpWidget(_app(LessonPathScreen(today: _today)));
      await _settle(t, 5);
      expect(find.byKey(const Key('natureSection-fire_safety')), findsOneWidget);
      expect(find.byKey(const Key('natureSectionReward-fire_safety')), findsOneWidget);
      expect(find.byKey(const Key('fidanAllDone')), findsNothing);
      await t.ensureVisible(find.byKey(const Key('natureLesson-how_fires_start')));
      await t.tap(find.byKey(const Key('natureLesson-how_fires_start')));
      await _settle(t, 3);
      expect(find.text('Önce önceki dersi bitir.'), findsOneWidget);
    });

    testWidgets('a lesson with every question type runs to the reward with an apple', (t) async {
      _tall(t);
      final lesson = natureLessons.firstWhere((l) => l.id == 'see_fire');
      await _openLesson(t, lesson);
      await _playThrough(t, lesson);
      expect(NatureStore.instance.progress.lessons, {lesson.id});
      expect(find.byKey(const Key('fidanXpGain')), findsOneWidget);
      expect(find.text('+$lessonXp XP'), findsOneWidget);
      expect(find.byKey(const Key('fidanNewApple')), findsOneWidget);
      await _settle(t, 26);
    });

    testWidgets('a wrong answer still explains and shows the right order', (t) async {
      _tall(t);
      final q = natureLessons.first.quiz.whereType<OrderQuestion>().single;
      var result = true;
      await t.pumpWidget(_app(Scaffold(body: LessonQuestionView(question: q, onAnswered: (r) => result = r))));
      await _settle(t, 3);
      await _tap(t, find.byKey(const Key('natureCheck')));
      await _settle(t, 4);
      expect(result, isFalse);
      expect(find.byKey(const Key('natureFeedback')), findsOneWidget);
      expect(t.getTopLeft(find.byKey(const Key('natureStepText-0'))).dy, lessThan(t.getTopLeft(find.byKey(const Key('natureStepText-1'))).dy));
    });

    testWidgets('a step can be dragged by its handle', (t) async {
      _tall(t);
      final q = natureLessons.first.quiz.whereType<OrderQuestion>().single;
      await t.pumpWidget(_app(Scaffold(body: LessonQuestionView(question: q, onAnswered: (_) {}))));
      await _settle(t, 3);
      final first = stepOrder(q).first;
      double top() => t.getTopLeft(find.byKey(Key('natureStepText-$first'))).dy;
      final before = top();
      final gesture = await t.startGesture(t.getCenter(find.byKey(const Key('natureDrag-0'))));
      await t.pump(const Duration(milliseconds: 100));
      await gesture.moveBy(const Offset(0, 90));
      await t.pump(const Duration(milliseconds: 100));
      await gesture.moveBy(const Offset(0, 90));
      await t.pump(const Duration(milliseconds: 500));
      await gesture.up();
      await _settle(t, 8);
      expect(top(), greaterThan(before));
    });

    testWidgets('a right sequence and a wrong match are told apart', (t) async {
      _tall(t);
      final order = natureLessons.first.quiz.whereType<OrderQuestion>().single;
      var result = false;
      await t.pumpWidget(_app(Scaffold(body: LessonQuestionView(key: const Key('o'), question: order, onAnswered: (r) => result = r))));
      await _settle(t, 3);
      await _answer(t, order);
      expect(result, isTrue);

      final match = natureLessons.first.quiz.whereType<MatchQuestion>().single;
      var called = 0;
      await t.pumpWidget(_app(Scaffold(body: LessonQuestionView(key: const Key('m'), question: match, onAnswered: (r) {
        called++;
        result = r;
      }))));
      await _settle(t, 3);
      await _answer(t, match, right: false);
      expect(called, 1, reason: 'only once every pair is joined');
      expect(result, isFalse);
    });

    testWidgets('replaying a finished lesson gives the small reward and no new apple', (t) async {
      _tall(t);
      final lesson = natureLessons[1];
      await NatureStore.instance.save(NatureProgress(lessons: {lesson.id}));
      final apples = applesOf(NatureStore.instance.progress).length;
      await _openLesson(t, lesson);
      await _playThrough(t, lesson);
      final p = NatureStore.instance.progress;
      expect(p.replays, 1);
      expect(p.lessons, {lesson.id});
      expect(applesOf(p).length, apples);
      expect(find.text('+$replayXp XP'), findsOneWidget);
      expect(find.byKey(const Key('fidanNewApple')), findsNothing);
      await _settle(t, 26);
    });

    testWidgets('the last lesson of a section brings the section reward', (t) async {
      _tall(t);
      final section = natureSections.first;
      final last = section.lessons.last;
      await NatureStore.instance.save(NatureProgress(lessons: section.lessons.take(section.lessons.length - 1).map((l) => l.id).toSet()));
      await _openLesson(t, last);
      await _playThrough(t, last);
      expect(find.byKey(const Key('fidanSectionReward')), findsOneWidget);
      expect(find.byKey(const Key('fidanAllDoneReward')), findsNothing);
      await _settle(t, 26);
    });

    testWidgets('the very last lesson brings the celebration', (t) async {
      _tall(t);
      final last = natureLessons.last;
      await NatureStore.instance.save(NatureProgress(lessons: _allIds()..remove(last.id)));
      await _openLesson(t, last);
      await _playThrough(t, last);
      expect(find.byKey(const Key('fidanAllDoneReward')), findsOneWidget);
      expect(find.text('Tüm dersleri bitirdin!'), findsOneWidget);
      await _settle(t, 26);
    });

    testWidgets('every question fits at 360 dp with 1.3x text', (t) async {
      t.view.physicalSize = const Size(360, 800) * 2;
      t.view.devicePixelRatio = 2;
      addTearDown(t.view.reset);
      var n = 0;
      for (final q in _questions) {
        await t.pumpWidget(MediaQuery(
          data: const MediaQueryData(size: Size(360, 800), textScaler: TextScaler.linear(1.3)),
          child: _app(Scaffold(body: Center(child: SizedBox(key: ValueKey(n++), width: 332, child: LessonQuestionView(question: q, onAnswered: (_) {}))))),
        ));
        await t.pump(const Duration(milliseconds: 100));
        await _answer(t, q);
        expect(t.takeException(), isNull, reason: 'question $n');
      }
    });

    testWidgets('every lesson card fits at 360 dp with 1.3x text', (t) async {
      t.view.physicalSize = const Size(360, 800) * 2;
      t.view.devicePixelRatio = 2;
      addTearDown(t.view.reset);
      for (final lesson in natureLessons) {
        await t.pumpWidget(MediaQuery(
          data: const MediaQueryData(size: Size(360, 800), textScaler: TextScaler.linear(1.3)),
          child: _app(NatureLessonScreen(key: ValueKey(lesson.id), lesson: lesson, today: _today)),
        ));
        for (var i = 0; i < lesson.cards.length; i++) {
          await t.pump(const Duration(milliseconds: 100));
          expect(t.takeException(), isNull, reason: '${lesson.id} card $i');
          await t.tap(find.byKey(const Key('natureNext')));
          await t.pump(const Duration(milliseconds: 300));
          await t.pump(const Duration(milliseconds: 300));
        }
      }
    });
  });
}
