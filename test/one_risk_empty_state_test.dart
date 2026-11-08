import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:firewatch_tr/features/map/widgets/region_risk_layer.dart';
import 'package:firewatch_tr/l10n/app_localizations.dart';
import 'package:firewatch_tr/models/detection_status.dart';
import 'package:firewatch_tr/services/point_risk_service.dart';
import 'package:firewatch_tr/services/render_api_service.dart';
import 'package:firewatch_tr/shared/widgets/detection_status_card.dart';
import 'package:firewatch_tr/shared/widgets/report_fire_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

class _Failing implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<Uint8List>? s, Future<void>? c) async =>
      ResponseBody.fromString(jsonEncode({'status': 'error'}), 503, headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      });

  @override
  void close({bool force = false}) {}
}

Widget _app(Widget child, {Locale locale = const Locale('tr')}) => MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

Map<String, dynamic> _arb(String file) =>
    jsonDecode(File('lib/l10n/$file').readAsStringSync().replaceFirst('﻿', '')) as Map<String, dynamic>;

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  group('point risk', () {
    test('only the rounded point is sent, and neighbours share one answer', () async {
      final sent = <List<double>>[];
      final service = PointRiskService(post: (lat, lng) async {
        sent.add([lat, lng]);
        return {'general_risk_score': 40};
      });
      await service.fetch(lat: 38.3456, lng: 26.7812);
      await service.fetch(lat: 38.31, lng: 26.79);
      expect(sent, [
        [38.3, 26.8],
      ]);
    });

    test('the answer expires', () async {
      var clock = DateTime(2026, 11, 8, 12);
      var calls = 0;
      final service = PointRiskService(post: (_, _) async => {'n': ++calls}, now: () => clock);
      await service.fetch(lat: 38.3, lng: 26.8);
      clock = clock.add(PointRiskService.ttl);
      expect((await service.fetch(lat: 38.3, lng: 26.8))['n'], 2);
    });

    test('a failure is not remembered', () async {
      var fail = true;
      final service = PointRiskService(post: (_, _) async {
        if (fail) throw const PointRiskException(PointRiskError.unavailable);
        return {'ok': true};
      });
      await expectLater(service.fetch(lat: 38.3, lng: 26.8), throwsA(isA<PointRiskException>()));
      fail = false;
      expect((await service.fetch(lat: 38.3, lng: 26.8))['ok'], true);
    });
  });

  group('detection status', () {
    Map<String, dynamic> json({bool fresh = true, Object? count = 0}) => {
          'pipeline_fresh': fresh,
          'strong_detections_24h': count,
          'last_update_at': '2026-11-08T09:40:00Z',
          'latest_detection': {'detected_at': '2026-11-05T09:40:00Z', 'city': 'Muğla'},
        };

    test('only a fresh pipeline can report none', () {
      expect(DetectionStatus.fromJson(json()).kind, DetectionStatusKind.none);
      expect(DetectionStatus.fromJson(json(count: 3)).kind, DetectionStatusKind.strong);
      expect(DetectionStatus.fromJson(json(fresh: false, count: null)).kind, DetectionStatusKind.stale);
      expect(DetectionStatus.fromJson(json(fresh: true, count: null)).kind, DetectionStatusKind.stale);
    });

    test('a failed request is unavailable, not quiet', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://x'))..httpClientAdapter = _Failing();
      final status = await RenderApiService(dio: dio).fetchDetectionStatus();
      expect(status.kind, DetectionStatusKind.unavailable);
    });
  });

  group('status card', () {
    final now = DateTime(2026, 11, 8, 12, 40);
    final quiet = DetectionStatus(
      kind: DetectionStatusKind.none,
      lastUpdateAt: DateTime(2026, 11, 8, 12, 40),
      latestDetectionAt: DateTime(2026, 11, 5, 12, 0),
      latestDetectionCity: 'Muğla',
    );

    testWidgets('quiet: careful wording, freshness, latest detection', (tester) async {
      await tester.pumpWidget(_app(DetectionStatusCard(status: quiet, now: now, onReport: () {}, onShowLast7Days: () {})));
      await tester.pumpAndSettle();
      expect(find.text("Son 24 saatte uydular Türkiye'de orman ve doğal alanlarda güçlü bir ısı tespit etmedi."), findsOneWidget);
      expect(find.textContaining('Son güncelleme: 12:40'), findsOneWidget);
      expect(find.textContaining('Uydular küçük veya bulut altındaki'), findsOneWidget);
      expect(find.text('En son tespit: 3 gün önce, Muğla'), findsOneWidget);
      expect(find.text('Son 7 günü göster'), findsOneWidget);
    });

    testWidgets('112 comes before Report, and each button does its job', (tester) async {
      var dialled = 0;
      var reported = 0;
      await tester.pumpWidget(_app(DetectionStatusCard(
        status: quiet,
        now: now,
        onReport: () => reported++,
        dial: () async {
          dialled++;
          return true;
        },
      )));
      await tester.pumpAndSettle();
      final call = find.byKey(const Key('detectionCall112'));
      final report = find.byKey(const Key('detectionReport'));
      expect(tester.getTopLeft(call).dy, lessThan(tester.getTopLeft(report).dy));
      expect(find.text("Yangın görürseniz önce 112'yi arayın."), findsOneWidget);
      expect(find.textContaining('Raporla ile bize bildirin'), findsOneWidget);
      await tester.tap(call);
      await tester.tap(report);
      expect((dialled, reported), (1, 1));
    });

    testWidgets('stale and unavailable never say nothing was seen', (tester) async {
      const title = "Son 24 saatte uydular Türkiye'de orman ve doğal alanlarda güçlü bir ısı tespit etmedi.";
      await tester.pumpWidget(_app(DetectionStatusCard(
        status: DetectionStatus(kind: DetectionStatusKind.stale, lastUpdateAt: DateTime(2026, 11, 8, 3, 5)),
        now: now,
        onReport: () {},
      )));
      await tester.pumpAndSettle();
      expect(find.text(title), findsNothing);
      expect(find.text('Uydu verisi güncel değil.'), findsOneWidget);
      expect(find.textContaining('Son güncelleme: 03:05'), findsOneWidget);

      await tester.pumpWidget(_app(DetectionStatusCard(status: DetectionStatus.unavailable, now: now, onReport: () {}, onRetry: () {})));
      await tester.pumpAndSettle();
      expect(find.text(title), findsNothing);
      expect(find.text('Uydu verisi alınamadı.'), findsOneWidget);
      expect(find.byKey(const Key('detectionRetry')), findsOneWidget);
    });

    testWidgets('the risk offer says the colours are not fires', (tester) async {
      await tester.pumpWidget(_app(DetectionStatusCard(status: quiet, now: now, onReport: () {}, onOpenRisk: () {})));
      await tester.pumpAndSettle();
      expect(find.text('Renkler yangın değil, yangın çıkma riskidir.'), findsOneWidget);
    });

    testWidgets('freshness line separates a stale feed from a normal one', (tester) async {
      await tester.pumpWidget(_app(DetectionFreshnessLine(
        status: DetectionStatus(kind: DetectionStatusKind.strong, lastUpdateAt: DateTime(2026, 11, 8, 12, 40)),
        now: now,
      )));
      expect(find.text('Son güncelleme: 12:40'), findsOneWidget);
      await tester.pumpWidget(_app(DetectionFreshnessLine(status: DetectionStatus.unavailable, now: now)));
      expect(find.text('Uydu verisi alınamadı.'), findsOneWidget);
    });

    testWidgets('English', (tester) async {
      await tester.pumpWidget(_app(DetectionStatusCard(status: quiet, now: now, onReport: () {}), locale: const Locale('en')));
      await tester.pumpAndSettle();
      expect(find.text('If you see a fire, call 112 first.'), findsOneWidget);
    });
  });

  group('report screen', () {
    Future<void> open(WidgetTester tester, {Future<void> Function(String)? send, ReportType type = ReportType.fire}) async {
      tester.view.physicalSize = const Size(1080, 3200);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        locale: const Locale('tr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: ReportFirePanel(onClose: () {}, sendWrongInfo: send, initialType: type)),
      ));
      await tester.pump(const Duration(seconds: 2));
    }

    testWidgets('the emergency notice is the first thing, above the title', (tester) async {
      await open(tester);
      final notice = find.text("Bu bildirim acil servislere iletilmez; acil durumda 112'yi arayın.");
      expect(notice, findsOneWidget);
      expect(tester.getTopLeft(notice).dy, lessThan(tester.getTopLeft(find.text('Yangın Raporla')).dy));
    });

    testWidgets('both new types are offered', (tester) async {
      await open(tester);
      expect(find.text('Uygulamada görünmeyen yangın'), findsOneWidget);
      expect(find.text('Hatalı bilgi/uygulama hatası'), findsOneWidget);
    });

    testWidgets('an app error needs no location and goes to feedback', (tester) async {
      final sent = <String>[];
      await open(tester, send: (m) async => sent.add(m));
      await tester.tap(find.byKey(const Key('reportType-wrongInfo')));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('GPS ile Konum Al'), findsNothing);

      await tester.tap(find.byKey(const Key('reportSubmit')));
      await tester.pump(const Duration(milliseconds: 100));
      expect(sent, isEmpty, reason: 'nothing to send yet');

      await tester.enterText(find.byType(TextField).first, 'Harita yanlış il gösteriyor');
      await tester.tap(find.byKey(const Key('reportSubmit')));
      await tester.pump(const Duration(milliseconds: 100));
      expect(sent, ['Hatalı bilgi/uygulama hatası: Harita yanlış il gösteriyor']);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('a missing fire still asks for the location', (tester) async {
      await open(tester, type: ReportType.missingFire);
      expect(find.text('GPS ile Konum Al'), findsOneWidget);
    });
  });

  group('one risk score on the map', () {
    test('every province has a region', () {
      expect(provinceRegion.length, 81);
      expect(provinceRegion['35'], 'ege');
      expect(provinceRegion['06'], 'ic anadolu');
      expect(provinceRegion['63'], 'guneydogu anadolu');
    });

    test('region names compare however they are spelled', () {
      expect(foldRegionName('İç Anadolu'), 'ic anadolu');
      expect(foldRegionName('Ic Anadolu'), 'ic anadolu');
      expect(foldRegionName('Güneydoğu Anadolu'), 'guneydogu anadolu');
    });

    test('the map has one Risk layer; the FWI layer and its texts are gone', () {
      for (final file in ['app_tr.arb', 'app_en.arb']) {
        final arb = _arb(file);
        expect(arb['mapRiskLayer'], 'Risk');
        for (final removed in ['riskLayerToggle', 'riskLegendTitle', 'riskLegendNote', 'riskAttribution', 'riskOpacityLabel', 'riskDayNotPublished']) {
          expect(arb.containsKey(removed), isFalse, reason: removed);
        }
        // The Risk screen's Copernicus card still credits its source.
        expect(arb['riskCopernicusAttribution'], contains('CC BY 4.0'));
        expect(arb['dataSourcesFwiBody'], isNot(contains('10')), reason: 'the forecast-day picker went with the layer');
      }
      final legend = _arb('app_tr.arb');
      expect(legend['mapRiskLegendMedium'], contains('25'));
      expect(legend['mapRiskLegendHigh'], contains('50'));
      expect(legend['mapRiskLegendCritical'], contains('75'));
    });

    test('a place row shows the score, not the Copernicus class', () {
      final row = File('lib/features/risk/widgets/tracked_places_section.dart').readAsStringSync();
      expect(row, contains('PointRiskService'));
      expect(row, isNot(contains('FwiPointService')));
    });

    test('Konumum and a place use the same section', () {
      final risk = File('lib/features/risk/risk_screen.dart').readAsStringSync();
      expect(RegExp(r'_PointRiskSection\(\s*\n\s*loading').allMatches(risk).length, 2);
      expect(risk, contains('TrackedPlacesSection(onPlaceTap: _openPlace)'));
      expect(risk, isNot(contains('getNearestCity')));
    });

    test('new texts exist in both languages', () {
      final tr = _arb('app_tr.arb').keys.where((k) => !k.startsWith('@')).toSet();
      final en = _arb('app_en.arb').keys.where((k) => !k.startsWith('@')).toSet();
      expect(tr.where((k) => k.startsWith('detection') || k.startsWith('riskPoint') || k.startsWith('reportType')).toSet().difference(en), isEmpty);
    });
  });
}
