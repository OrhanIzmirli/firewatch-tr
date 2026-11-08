import 'dart:convert';
import 'dart:io';

import 'package:firewatch_tr/features/nature/nature_content.dart';
import 'package:firewatch_tr/features/nature/nature_progress.dart';
import 'package:firewatch_tr/features/nature/nature_screen.dart';
import 'package:firewatch_tr/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget app(Widget c) => MaterialApp(
      locale: const Locale('tr'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: c,
    );

Iterable<Bi> allTexts() sync* {
  for (final f in natureFacts) {
    yield f.text;
  }
  for (final t in natureTasks) {
    yield t.text;
  }
  for (final l in natureLessons) {
    yield l.title;
    for (final c in l.cards) {
      yield c.title;
      yield c.body;
    }
    for (final q in l.quiz) {
      yield q.question;
      yield q.feedback;
      yield* q.options;
    }
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    GoogleFonts.config.allowRuntimeFetching = false;
    NatureStore.instance.progress = const NatureProgress();
  });

  group('content', () {
    test('every fact and card has an https source', () {
      for (final f in natureFacts) {
        expect(f.source.url, startsWith('https://'));
      }
      for (final l in natureLessons) {
        expect(l.cards.length, inInclusiveRange(3, 5), reason: l.id);
        expect(l.quiz.length, inInclusiveRange(1, 2), reason: l.id);
        for (final c in l.cards) {
          expect(c.sources, isNotEmpty);
          expect(c.sources.every((s) => s.url.startsWith('https://')), isTrue);
        }
      }
    });

    test('no probability claims, no guilt, no "it is out", no informal address', () {
      final bad = RegExp(r'olası|muhtemel|ihtimal|kaybedeceksiniz|unuttunuz|bozulacak|(^|\s)söndü([\s.,]|$)|(^|\s)sen(\s|$)|yapmalısın', caseSensitive: false);
      for (final t in allTexts()) {
        expect(bad.hasMatch(t.tr), isFalse, reason: t.tr);
        expect(t.en.isNotEmpty, isTrue);
      }
    });

    test('nothing rewards a fire report or a 112 call', () {
      for (final t in natureTasks) {
        expect(t.text.tr.contains('112'), isFalse);
        expect(t.text.tr.toLowerCase().contains('ihbar'), isFalse);
      }
    });

    test('quiz answers exist', () {
      for (final l in natureLessons) {
        for (final q in l.quiz) {
          expect(q.correct, inInclusiveRange(0, q.options.length - 1));
        }
      }
    });

    test('the national numbers match the bundled OGM data', () {
      final data = jsonDecode(File('assets/data/il_yil_veri.json').readAsStringSync()) as Map<String, dynamic>;
      final ha = <String, double>{};
      final fires = <String, int>{};
      for (final v in (data['iller'] as Map<String, dynamic>).values) {
        (v['yillar'] as Map<String, dynamic>).forEach((y, r) {
          ha[y] = (ha[y] ?? 0) + ((r['ogm_yanan_alan_ha'] as num?)?.toDouble() ?? 0);
          fires[y] = (fires[y] ?? 0) + ((r['ogm_yangin_sayisi'] as num?)?.toInt() ?? 0);
        });
      }
      final byHa = ha.keys.toList()..sort((a, b) => ha[a]!.compareTo(ha[b]!));
      final byFires = fires.keys.toList()..sort((a, b) => fires[a]!.compareTo(fires[b]!));
      expect(byHa.last, '2021');
      expect(ha['2021']!.round(), 139503);
      expect(byHa.first, '2018');
      expect(ha['2018']!.round(), 5644);
      expect(byFires.last, '2024');
      expect(fires['2024'], 3797);
      expect(ha['2024']!.round(), 27485);
      expect(ha['2025']!.round(), 81473);
    });
  });

  group('streak', () {
    final mon = DateTime(2026, 11, 2);
    Map<String, bool> mark(List<int> offsets) => {for (final o in offsets) dayKey(mon.add(Duration(days: o))): true};

    test('counts days in a row, and a "not today" counts too', () {
      expect(currentStreak({...mark([0, 1]), dayKey(mon.add(const Duration(days: 2))): false}, mon.add(const Duration(days: 2))), 3);
    });
    test('today not marked yet costs nothing', () {
      expect(currentStreak(mark([0, 1]), mon.add(const Duration(days: 2))), 2);
    });
    test('two missed days a week are forgiven, the third ends it', () {
      expect(currentStreak(mark([0, 3, 4]), mon.add(const Duration(days: 4))), 3);
      expect(currentStreak(mark([0, 4]), mon.add(const Duration(days: 4))), 1);
    });
    test('task and fact stay the same all day; another task changes it', () {
      final d = DateTime(2026, 11, 8, 9);
      expect(taskFor(d, swapped: false).id, taskFor(DateTime(2026, 11, 8, 22), swapped: false).id);
      expect(taskFor(d, swapped: true).id, isNot(taskFor(d, swapped: false).id));
      expect(factFor(d).text.tr, factFor(DateTime(2026, 11, 8, 22)).text.tr);
    });
    test('seasonal tasks only in season', () {
      final july = List.generate(31, (i) => taskFor(DateTime(2026, 7, i + 1), swapped: false).id);
      expect(july, isNot(contains('ash')));
      final january = List.generate(31, (i) => taskFor(DateTime(2026, 1, i + 1), swapped: false).id);
      expect(january, isNot(contains('wood')));
    });
    test('badges', () {
      expect(earnedBadges(const NatureProgress()), isEmpty);
      final p = NatureProgress(days: {for (var i = 1; i <= 7; i++) '2026-11-0$i': true}, lessons: {for (final l in natureLessons) l.id}, shares: 5, observations: 3);
      expect(earnedBadges(p), containsAll([NatureBadge.firstStep, NatureBadge.sevenDays, NatureBadge.curious, NatureBadge.knowledgeable, NatureBadge.sharer, NatureBadge.observer]));
      expect(earnedBadges(p), isNot(contains(NatureBadge.thirtyDays)));
    });
  });

  group('privacy and defaults', () {
    test('the reminder is off until asked for', () {
      expect(const NatureProgress().reminder, isFalse);
    });
    test('progress code makes no network calls', () {
      for (final f in ['lib/features/nature/nature_progress.dart', 'lib/features/nature/nature_content.dart']) {
        final s = File(f).readAsStringSync();
        expect(s.contains('Dio('), isFalse, reason: f);
        expect(s.contains('http.'), isFalse, reason: f);
      }
      expect(File('lib/features/nature/nature_screen.dart').readAsStringSync().contains('Geolocator'), isFalse);
    });
    test('progress survives a save and load', () async {
      await NatureStore.instance.load();
      await NatureStore.instance.mark(DateTime(2026, 11, 8), true);
      await NatureStore.instance.addShare();
      NatureStore.instance.progress = const NatureProgress();
      await NatureStore.instance.load();
      expect(NatureStore.instance.progress.days['2026-11-08'], isTrue);
      expect(NatureStore.instance.progress.shares, 1);
      await NatureStore.instance.deleteAll();
      expect(NatureStore.instance.progress.days, isEmpty);
    });
  });

  group('screens', () {
    testWidgets('a lesson: cards, source, quiz feedback, finished', (t) async {
      t.view.physicalSize = const Size(1080, 2400);
      t.view.devicePixelRatio = 3;
      addTearDown(t.view.reset);
      final lesson = natureLessons.firstWhere((l) => l.id == 'how_fires_start');
      await t.pumpWidget(app(Builder(builder: (c) => Scaffold(body: TextButton(onPressed: () => Navigator.of(c).push(MaterialPageRoute<void>(builder: (_) => NatureLessonScreen(lesson: lesson))), child: const Text('go'))))));
      await t.tap(find.text('go'));
      await t.pumpAndSettle();
      expect(find.text('Küçük bir kor yeter'), findsOneWidget);
      expect(find.textContaining('Kaynak: FAO'), findsOneWidget);
      for (var i = 0; i < lesson.cards.length; i++) {
        await t.tap(find.byKey(const Key('natureNext')));
        await t.pump();
      }
      expect(t.widget<FilledButton>(find.byKey(const Key('natureNext'))).onPressed, isNull, reason: 'answer first');
      await t.tap(find.byKey(const Key('natureOption-1')));
      await t.pump();
      expect(find.byKey(const Key('natureFeedback')), findsOneWidget);
      await t.tap(find.byKey(const Key('natureNext')));
      await t.pumpAndSettle();
      expect(NatureStore.instance.progress.lessons, contains('how_fires_start'));
    });
  });
}
