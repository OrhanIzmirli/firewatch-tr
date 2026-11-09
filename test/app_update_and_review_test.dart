import 'dart:io';

import 'package:firewatch_tr/features/update/force_update_screen.dart';
import 'package:firewatch_tr/l10n/app_localizations.dart';
import 'package:firewatch_tr/router/app_router.dart';
import 'package:firewatch_tr/services/app_update_gate.dart';
import 'package:firewatch_tr/services/review_prompt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeReview implements InAppReview {
  bool available = true;
  int requests = 0;
  @override
  Future<bool> isAvailable() async => available;
  @override
  Future<void> requestReview() async => requests++;
  @override
  Future<void> openStoreListing({String? appStoreId, String? microsoftStoreId}) async {}
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  group('isUpdateRequired', () {
    test('only a readable, lower version is required to update', () {
      expect(isUpdateRequired('1.2.0', '1.2.1'), isTrue);
      expect(isUpdateRequired('1.2.0+8', '1.10.0'), isTrue);
      expect(isUpdateRequired('1.2.0', '1.2.0'), isFalse);
      expect(isUpdateRequired('1.3', '1.2.9'), isFalse);
      expect(isUpdateRequired('1.2.0', '0.0.0'), isFalse);
    });
    test('anything unreadable never locks anyone out', () {
      expect(isUpdateRequired('1.2.0', null), isFalse);
      expect(isUpdateRequired('1.2.0', ''), isFalse);
      expect(isUpdateRequired('1.2.0', 'latest'), isFalse);
      expect(isUpdateRequired(null, '9.0.0'), isFalse);
    });
  });

  group('AppUpdateGate', () {
    AppUpdateGate gate(Future<String?> Function() min, void Function() flexible) => AppUpdateGate(
          minimumVersion: min,
          installedVersion: () async => '1.2.0',
          offerFlexible: () async => flexible(),
        );

    test('a lower version locks and skips the flexible update', () async {
      var flexible = 0;
      final g = gate(() async => '2.0.0', () => flexible++);
      var told = 0;
      g.addListener(() => told++);
      await g.check();
      expect(g.updateRequired, isTrue);
      expect(told, 1);
      expect(flexible, 0);
    });
    test('the default does not force and offers the flexible update', () async {
      var flexible = 0;
      final g = gate(() async => '0.0.0', () => flexible++);
      await g.check();
      expect(g.updateRequired, isFalse);
      expect(flexible, 1);
    });
    test('no answer from the server does not lock', () async {
      final g = gate(() async => null, () {});
      await g.check();
      expect(g.updateRequired, isFalse);
    });
    test('a server failure does not lock', () async {
      final g = gate(() async => throw StateError('down'), () {});
      await g.check();
      expect(g.updateRequired, isFalse);
    });
    test('a failing Play call does not lock or escape', () async {
      final g = AppUpdateGate(
        minimumVersion: () async => '0.0.0',
        installedVersion: () async => '1.2.0',
        offerFlexible: () async => throw StateError('not from Play'),
      );
      await g.check();
      expect(g.updateRequired, isFalse);
    });
  });

  group('routing', () {
    test('only the emergency pages stay open during a forced update', () {
      expect(forcedUpdateRedirect(required: false, location: '/app'), isNull);
      expect(forcedUpdateRedirect(required: true, location: '/app'), '/update-required');
      expect(forcedUpdateRedirect(required: true, location: '/'), '/update-required');
      expect(forcedUpdateRedirect(required: true, location: '/emergency'), isNull);
      expect(forcedUpdateRedirect(required: true, location: '/update-required'), isNull);
    });
  });

  testWidgets('the update screen keeps 112 and the emergency page reachable', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      locale: Locale('tr'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: ForceUpdateScreen(),
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('forceUpdateButton')), findsOneWidget);
    expect(find.byKey(const Key('forceUpdate112')), findsOneWidget);
    expect(find.byKey(const Key('forceUpdateEmergencyInfo')), findsOneWidget);
  });

  group('review policy', () {
    final now = DateTime(2026, 11, 9, 12);
    test('needs three different days and ninety days between requests', () {
      expect(reviewAllowed(openDays: {'a', 'b'}, lastAsked: null, now: now), isFalse);
      expect(reviewAllowed(openDays: {'a', 'b', 'c'}, lastAsked: null, now: now), isTrue);
      expect(reviewAllowed(openDays: {'a', 'b', 'c'}, lastAsked: now.subtract(const Duration(days: 89)), now: now), isFalse);
      expect(reviewAllowed(openDays: {'a', 'b', 'c'}, lastAsked: now.subtract(const Duration(days: 90)), now: now), isTrue);
    });

    test('opening twice on one day counts once; the request is limited', () async {
      SharedPreferences.setMockInitialValues({});
      final fake = _FakeReview();
      await ReviewPrompt.noteAppOpen(DateTime(2026, 11, 1, 9));
      await ReviewPrompt.noteAppOpen(DateTime(2026, 11, 1, 20));
      await ReviewPrompt.noteAppOpen(DateTime(2026, 11, 2, 9));
      expect(await ReviewPrompt.maybeAsk(review: fake, now: now), isFalse);
      await ReviewPrompt.noteAppOpen(DateTime(2026, 11, 3, 9));
      expect(await ReviewPrompt.maybeAsk(review: fake, now: now), isTrue);
      expect(await ReviewPrompt.maybeAsk(review: fake, now: now.add(const Duration(days: 30))), isFalse);
      expect(fake.requests, 1);
      expect(await ReviewPrompt.maybeAsk(review: fake, now: now.add(const Duration(days: 91))), isTrue);
      expect(fake.requests, 2);
    });

    test('an unavailable Play review does not use up the ninety days', () async {
      SharedPreferences.setMockInitialValues({});
      final fake = _FakeReview()..available = false;
      for (final d in [1, 2, 3]) {
        await ReviewPrompt.noteAppOpen(DateTime(2026, 11, d));
      }
      expect(await ReviewPrompt.maybeAsk(review: fake, now: now), isFalse);
      fake.available = true;
      expect(await ReviewPrompt.maybeAsk(review: fake, now: now), isTrue);
    });

    test('the request is reachable only from the Fidan reward screen', () {
      final callers = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart') && f.readAsStringSync().contains('ReviewPrompt.maybeAsk'))
          .map((f) => f.path.replaceAll(r'\', '/'))
          .toList();
      expect(callers, ['lib/features/nature/fidan_lessons.dart']);
    });

    test('a rating earns nothing', () {
      final source = File('lib/services/review_prompt.dart').readAsStringSync();
      expect(source, isNot(contains('NatureStore')));
      expect(source, isNot(contains('xpOf')));
      expect(source, isNot(contains('apples')));
    });
  });
}
