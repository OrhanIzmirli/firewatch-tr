import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firewatch_tr/core/utils/detection_summary.dart';
import 'package:firewatch_tr/l10n/app_localizations.dart';
import 'package:firewatch_tr/l10n/app_localizations_tr.dart';
import 'package:firewatch_tr/models/detection_status.dart';
import 'package:firewatch_tr/models/fire_incident.dart';
import 'package:firewatch_tr/shared/coach_mark_keys.dart';
import 'package:firewatch_tr/shared/widgets/coach_mark_overlay.dart';
import 'package:firewatch_tr/shared/widgets/bottom_bar_fit.dart';
import 'package:firewatch_tr/shared/widgets/detection_safety_notice.dart';
import 'package:firewatch_tr/shared/widgets/related_news_section.dart';
import 'package:firewatch_tr/services/news_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

FireIncident incident({int passes = 3, double frp = 20, String? cover, Object? news, double hours = 2, String tier = 'high', String? heat}) =>
    FireIncident.fromJson({
      'id': 1,
      'first_detected_at': '2026-11-08T09:30:00.000Z',
      'last_detected_at': '2026-11-08T09:30:00.000Z',
      'duration_hours': 3,
      'detection_count': 4,
      'overpass_count': passes,
      'latitude': 39.5,
      'longitude': 33.7,
      'max_frp_mw': frp,
      'peak_confidence_tier': tier,
      'city_name': 'Kırşehir',
      'sources': const [],
      'land_cover': cover,
      'news_verification': news,
      'satellite': {'state': hours <= 6 ? 'detected_recently' : 'awaiting_confirmation', 'hours_since_last_detection': hours},
      'official': const {},
      'optical': const {},
      'trend': const {},
      'spread': const {},
      'persistence': const {},
      'heat_source': {'class': heat},
    });

Widget app(Widget child, {double scale = 1, Locale locale = const Locale('tr')}) => MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (c, w) => MediaQuery(data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(scale)), child: w!),
      home: Scaffold(body: child),
    );

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('main layer', () {
    test('natural ground with multi-pass evidence is on it', () {
      expect(incident(cover: 'natural').belongsOnEventsLayer, isTrue);
    });
    test('unclassified stays on it: a failed lookup must not hide a fire', () {
      expect(incident().belongsOnEventsLayer, isTrue);
      expect(incident(cover: 'unknown').belongsOnEventsLayer, isTrue);
    });
    test('farmland, industry and bare ground are not', () {
      for (final c in ['agriculture', 'built', 'other']) {
        expect(incident(cover: c).belongsOnEventsLayer, isFalse, reason: c);
      }
    });
    test('a news confirmation brings it back, even with one pass', () {
      expect(incident(cover: 'agriculture', passes: 1, frp: 3, news: {'title': 'x'}).belongsOnEventsLayer, isTrue);
    });
    test('a strong single pass on farmland does not raise the banner', () {
      expect(incident(cover: 'natural', passes: 1, frp: 20).isStrongUnverified, isTrue);
      expect(incident(cover: 'agriculture', passes: 1, frp: 20).isStrongUnverified, isFalse);
    });
  });

  group('card sentence', () {
    final l10n = AppLocalizationsTr();
    test('the example from the brief', () {
      expect(
        detectionSummaryText(l10n, city: 'Kırşehir', strong: true, newsVerified: false, landCover: 'agriculture', age: const Duration(hours: 3)),
        'Uydular Kırşehir yakınında güçlü bir yangın izi tespit etti. Henüz doğrulanmadı. Tarım alanı olduğu için anız yakma da olabilir. 3 saat önce görüldü.',
      );
    });
    test('confirmed by news drops the doubt', () {
      final t = detectionSummaryText(l10n, city: 'Muğla', strong: true, newsVerified: true, landCover: 'agriculture', age: const Duration(days: 1));
      expect(t, contains('Haberlerde doğrulandı.'));
      expect(t, isNot(contains('anız')));
      expect(t, contains('1 gün önce'));
    });
  });

  group('112 is on every card', () {
    testWidgets('large when fresh and strong', (t) async {
      await t.pumpWidget(app(const DetectionSafetyNotice(prominent: true)));
      expect(find.byKey(DetectionSafetyNotice.callButtonKey), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });
    testWidgets('one line and a small link otherwise, never gone', (t) async {
      await t.pumpWidget(app(const DetectionSafetyNotice(prominent: false)));
      expect(find.byKey(DetectionSafetyNotice.callButtonKey), findsOneWidget);
      expect(find.byType(FilledButton), findsNothing);
      expect(find.text("Yangın görürseniz önce 112'yi arayın."), findsOneWidget);
    });
  });

  group('related news', () {
    RelatedNewsSection section(List<RelatedNews> items) => RelatedNewsSection(
          city: 'Muğla',
          from: DateTime(2026, 8, 9),
          to: DateTime(2026, 8, 11),
          fetch: ({city, required from, required to}) async => items,
        );
    testWidgets('title, source and time', (t) async {
      await t.pumpWidget(app(section([RelatedNews(title: 'Datça orman yangını', source: 'AA', url: 'https://x', publishedAt: DateTime(2026, 8, 10, 14, 5))])));
      await t.pump();
      expect(find.text('İlgili haberler'), findsOneWidget);
      expect(find.text('AA · 10.08 14:05'), findsOneWidget);
    });
    testWidgets('no match, no section', (t) async {
      await t.pumpWidget(app(section(const [])));
      await t.pump();
      expect(find.text('İlgili haberler'), findsNothing);
    });
  });

  test('status counts', () {
    final s = DetectionStatus.fromJson({'pipeline_fresh': true, 'strong_detections_24h': 0, 'strong_other_24h': 12});
    expect(s.kind, DetectionStatusKind.none);
    expect(s.otherCount, 12);
  });

  group('tips', () {
    const sizes = [Size(360, 640), Size(360, 800), Size(411, 891)];
    const padding = EdgeInsets.only(top: 24, bottom: 24);

    test('the card never covers the target and stays in the safe area', () {
      for (final size in sizes) {
        for (final target in [
          const Rect.fromLTWH(16, 30, 200, 48),
          Rect.fromLTWH(16, size.height / 2, size.width - 32, 80),
          Rect.fromLTWH(0, size.height - 80, 90, 56),
          Rect.fromLTWH(16, 60, size.width - 32, size.height - 120),
        ]) {
          final p = placeCoachMark(target: target, screen: size, padding: padding);
          expect(p.card.overlaps(p.spotlight), isFalse, reason: '$size $target');
          expect(p.card.top, greaterThanOrEqualTo(padding.top));
          expect(p.card.bottom, lessThanOrEqualTo(size.height - padding.bottom));
          expect(p.spotlight.height, lessThanOrEqualTo(size.height * 0.4 + 8));
        }
      }
    });

    for (final size in sizes) {
      for (final scale in [1.0, 1.3]) {
        testWidgets('real overlay at ${size.width.toInt()} dp, text x$scale', (t) async {
          t.view.physicalSize = size * 2;
          t.view.devicePixelRatio = 2;
          addTearDown(t.view.reset);
          final key = GlobalKey();
          late BuildContext ctx;
          await t.pumpWidget(app(Builder(builder: (c) {
            ctx = c;
            return Align(alignment: const Alignment(0, 0.7), child: SizedBox(key: key, width: 200, height: 60));
          }), scale: scale));
          unawaited(maybeShowScreenCoachMarks(ctx, prefsKey: 'k', steps: [
            CoachMarkStep(targetKey: key, title: 'Başlık', description: 'Uzun bir açıklama ' * 8),
            CoachMarkStep(targetKey: key, title: 'İkinci', description: 'Metin'),
            CoachMarkStep(targetKey: key, title: 'Üçüncü', description: 'Gösterilmez'),
          ]));
          for (var i = 0; i < 20; i++) {
            await t.pump(const Duration(milliseconds: 100));
          }
          expect(t.takeException(), isNull);
          expect(find.text('1/2'), findsOneWidget, reason: 'at most two tips');
          final target = t.getRect(find.byKey(key));
          final area = t.getRect(find.byKey(const Key('coachMarkCardArea')));
          expect(area.overlaps(target), isFalse);
          await t.tap(find.byKey(const Key('coachMarksDisableAll')));
          await t.pump();
          await t.pump(const Duration(milliseconds: 50));
          expect(await coachMarksEnabled(), isFalse);
        });
      }
    }

    test('turning tips back on shows them again', () async {
      SharedPreferences.setMockInitialValues({'hasSeenMapTour': true, coachMarksOffPrefsKey: true});
      await setCoachMarksEnabled(true);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('hasSeenMapTour'), isNull);
      expect(await coachMarksEnabled(), isTrue);
    });
    test('keys exist', () {
      expect(CoachMarkKeys.mapNavIcon, isNotNull);
    });
  });

  group('bottom bar', () {
    const labels = ['Ana Sayfa', 'Harita', 'Risk', 'Haberler'];
    for (final width in [360.0, 411.0]) {
      for (final scale in [1.0, 1.3]) {
        testWidgets('four tabs at ${width.toInt()} dp, text x$scale', (t) async {
          t.view.physicalSize = Size(width, 800) * 2;
          t.view.devicePixelRatio = 2;
          addTearDown(t.view.reset);
          await t.pumpWidget(app(Align(
            alignment: Alignment.bottomCenter,
            child: BottomBarFit(
              tabs: labels.length,
              child: NavigationBar(
                selectedIndex: 0,
                destinations: [for (final l in labels) NavigationDestination(icon: const Icon(Icons.circle), label: l)],
              ),
            ),
          ), scale: scale));
          await t.pump();
          expect(t.takeException(), isNull);
          for (final l in labels) {
            expect(find.text(l), findsOneWidget);
            final text = t.widget<RichText>(find.descendant(of: find.text(l), matching: find.byType(RichText)));
            expect(text.textScaler.scale(10) / 10, lessThanOrEqualTo(width / labels.length < 82 ? 1.1 : 1.3));
          }
        });
      }
    }

    test('alerts left the bar and moved to a bell on every tab', () {
      final shell = File('lib/features/home/main_shell_screen.dart').readAsStringSync();
      expect(RegExp('NavigationDestination\\(').allMatches(shell).length, 4);
      expect(shell, isNot(contains('navAlerts')));
      for (final f in ['home/home_screen', 'map/map_screen', 'risk/risk_screen', 'news/news_screen']) {
        expect(File('lib/features/$f.dart').readAsStringSync(), contains('AlertsBell()'), reason: f);
      }
      expect(File('lib/router/app_router.dart').readAsStringSync(), contains("path: '/alerts'"));
    });
  });

  group('source guards', () {
    String read(String p) => File(p).readAsStringSync();
    test('map card: no temperature or instrument rows', () {
      final m = read('lib/features/map/map_screen.dart');
      expect(m, isNot(contains('commonTemperature')));
      expect(m, contains('commonAllTechnical'));
    });
    test('home: safety, Fidan, places, then the simple cards; only recent news counts as new', () {
      final h = read('lib/features/home/home_screen.dart');
      expect(h.indexOf('_TodayCard('), lessThan(h.indexOf('TrackedPlacesSection(')));
      expect(h.indexOf('_TodayCard('), lessThan(h.indexOf('FidanHomeCard(')));
      expect(h.indexOf('FidanHomeCard('), lessThan(h.indexOf('TrackedPlacesSection(')));
      expect(h.indexOf('TrackedPlacesSection('), lessThan(h.lastIndexOf('GridView.count')), reason: 'the info cards stay, below the personal part');
      expect(h, contains('recentPoints.take(5)'), reason: 'a short detection list stays');
      expect(h, contains('publishedWithin(const Duration(hours: 72))'));
      expect(h, isNot(contains('homeLast24hStrongestPower')));
      expect(h, isNot(contains('commonTemperature')));
    });
    test('the grid and summary texts are the corrected ones', () {
      final data = jsonDecode(read('lib/l10n/app_tr.arb').replaceFirst('\uFEFF', '')) as Map<String, dynamic>;
      expect(data['homeLast24hStrongestTitle'], 'En güçlü uydu tespiti — doğrulanmadı');
      expect(data['homeOverviewActiveFiresTitle'], 'Güncel Uydu Tespitleri');
      expect(data['homeOverviewNewsNoFresh'], 'Yeni haber yok');
      expect(data['durationDaysHours'], '{days} gün {hours} saat');
    });
    test('the TR strings address the reader as siz, except in the Fidan voice', () {
      final data = jsonDecode(read('lib/l10n/app_tr.arb').replaceFirst('﻿', '')) as Map<String, dynamic>;
      final informal = RegExp(r'\b(yapabilirsin|edebilirsin|görürsen|istediğin|konumuna|seni|sana)\b');
      final bad = [
        for (final e in data.entries)
          if (!e.key.startsWith('@') && !e.key.startsWith('fidan') && e.value is String && informal.hasMatch(e.value as String)) e.key,
      ];
      expect(bad, isEmpty);
    });
  });
}
