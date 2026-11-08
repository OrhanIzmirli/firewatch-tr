import 'dart:convert';
import 'dart:io';

import 'package:firewatch_tr/core/utils/risk_display.dart';
import 'package:firewatch_tr/core/utils/risk_factors.dart' as factors;
import 'package:firewatch_tr/features/risk/risk_components.dart';
import 'package:firewatch_tr/features/risk/widgets/risk_components_list.dart';
import 'package:firewatch_tr/features/risk/widgets/risk_region_list.dart';
import 'package:firewatch_tr/l10n/app_localizations.dart';
import 'package:firewatch_tr/l10n/app_localizations_tr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

RiskComponents calc(num t, num h, num w, int fires) =>
    calculateRiskComponents(temperature: t, humidity: h, windSpeed: w, fireCount: fires);

Map<String, dynamic> row(int score, num t, num h, num w, int? fires, {String region = 'Akdeniz', int? previous}) => {
      'region': region,
      'general_risk_score': score,
      // The summary sends readings as strings, the point endpoint as numbers.
      'temperature': '$t',
      'humidity': '$h',
      'wind_speed': w,
      'nearby_fire_count': fires,
      'previous_risk_score': previous,
    };

Widget wrap(Widget child) => MaterialApp(
      locale: const Locale('tr'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

void main() {
  group('port of the backend calculateRisk', () {
    // The backend's own examples: scripts/test-point-risk.ts.
    test('the bucket values', () {
      expect(calc(10, 80, 5, 0).score, 0);
      expect(calc(25, 50, 10, 1).score, 7 + 6 + 5 + 5);
      expect(calc(30, 40, 20, 2).score, 14 + 13 + 11 + 10);
      expect(calc(35, 30, 35, 5).score, 22 + 20 + 18 + 15);
      expect(calc(39, 29, 0, 0).score, 22 + 20 + 10);
      expect(calc(41, 19, 60, 10).score, 100);
    });

    test('components of the capped example', () {
      final c = calc(41, 19, 60, 10);
      expect([c.temperature, c.humidity, c.wind, c.detections, c.heatBonus], [30, 25, 25, 20, 20]);
      expect(c.rawTotal, 120);
    });

    test('bonus bounds are exclusive and only the higher tier applies', () {
      expect(calc(41, 19, 0, 0).heatBonus, 20);
      expect(calc(40, 19, 0, 0).heatBonus, 10);
      expect(calc(41, 20, 0, 0).heatBonus, 10);
      expect(calc(35, 10, 0, 0).heatBonus, 0);
      expect(calc(36, 30, 0, 0).heatBonus, 0);
    });

    test('step boundaries', () {
      expect([24.9, 25, 30, 35, 40].map((t) => calc(t, 100, 0, 0).temperature), [0, 7, 14, 22, 30]);
      expect([50.1, 50, 40, 30, 20].map((h) => calc(0, h, 0, 0).humidity), [0, 6, 13, 20, 25]);
      expect([9.9, 10, 20, 35, 50].map((w) => calc(0, 100, w, 0).wind), [0, 5, 11, 18, 25]);
      expect([0, 1, 2, 5, 10].map((f) => calc(0, 100, 0, f).detections), [0, 5, 10, 15, 20]);
    });

    test('agrees with the older weather steps in core/utils/risk_factors', () {
      for (var v = -10.0; v <= 110; v += 0.5) {
        expect(calc(v, 100, 0, 0).temperature, factors.temperaturePoints(v), reason: 'temperature $v');
        expect(calc(0, v, 0, 0).humidity, factors.humidityPoints(v), reason: 'humidity $v');
        expect(calc(0, 100, v, 0).wind, factors.windPoints(v), reason: 'wind $v');
      }
    });

    test('maxima shown in the UI are the highest step of each table', () {
      expect(riskTemperatureSteps.first.$2, riskTemperatureMax);
      expect(riskHumiditySteps.first.$2, riskHumidityMax);
      expect(riskWindSteps.first.$2, riskWindMax);
      expect(riskDetectionSteps.first.$2, riskDetectionsMax);
      expect(riskHeatBonusTiers.first.$3, riskHeatBonusMax);
    });
  });

  group('riskBreakdownFromRow is checked against the server score', () {
    test('every region of the live 2026-11-08 sample adds up exactly', () {
      final live = [
        row(37, 12, 47, 22, 10),
        row(15, -6, 80, 15, 2),
        row(25, 9, 71, 10, 14),
        row(16, 3, 43, 18, 1),
        row(20, 1, 75, 2, 45),
        row(21, 5, 74, 24, 3),
        row(20, 4, 78, 7, 24),
      ];
      for (final r in live) {
        final b = riskBreakdownFromRow(r)!;
        expect(b.components.score, r['general_risk_score']);
        expect(b.fireCountMatchesScore, isTrue);
      }
    });

    test('the recorded fixture always yields a breakdown that sums to the score', () {
      final data = jsonDecode(File('test/fixtures/risk_summary_live.json').readAsStringSync())['data'] as List;
      expect(data, isNotEmpty);
      for (final r in data.cast<Map<String, dynamic>>()) {
        final b = riskBreakdownFromRow(r);
        expect(b, isNotNull, reason: '${r['region']}');
        expect(b!.components.score, r['general_risk_score'], reason: '${r['region']}');
      }
    });

    test('a count newer than the score keeps the points the score really used', () {
      // Ege as scored with 14 detections (+20), but the live count is now 3.
      final b = riskBreakdownFromRow(row(25, 9, 71, 10, 3, region: 'Ege'))!;
      expect(b.components.detections, 20);
      expect(b.components.score, 25);
      expect(b.fireCount, 3);
      expect(b.fireCountMatchesScore, isFalse);
    });

    test('unknown count: never drawn as zero detections, points from the score', () {
      final b = riskBreakdownFromRow(row(25, 9, 71, 10, null, region: 'Ege'))!;
      expect(b.fireCount, isNull);
      expect(b.components.detections, 20);
    });

    test('a score the formula cannot produce hides the breakdown', () {
      expect(riskBreakdownFromRow(row(99, 12, 47, 22, 10)), isNull);
      expect(riskBreakdownFromRow(row(3, 12, 47, 22, 10)), isNull);
    });

    test('missing weather hides the breakdown', () {
      expect(riskBreakdownFromRow({'general_risk_score': 10, 'temperature': null, 'humidity': '5', 'wind_speed': '1'}), isNull);
    });
  });

  group('riskTrendDelta shows only real change', () {
    test('no history or no movement gives nothing', () {
      expect(riskTrendDelta([row(20, 1, 1, 1, 0)]), isNull);
      expect(riskTrendDelta([row(20, 1, 1, 1, 0, previous: 20)]), isNull);
      expect(riskTrendDelta([row(25, 1, 1, 1, 0, previous: 20), row(16, 1, 1, 1, 0, previous: 21)]), isNull);
    });

    test('a real move is reported with its sign', () {
      expect(riskTrendDelta([row(30, 1, 1, 1, 0, previous: 20)]), 10);
      expect(riskTrendDelta([row(20, 1, 1, 1, 0, previous: 30)]), -10);
    });

    test('only regions with history are compared', () {
      expect(riskTrendDelta([row(30, 1, 1, 1, 0, previous: 20), row(90, 1, 1, 1, 0)]), 10);
    });
  });

  test('only a row the server marks as stale reads as stale', () {
    expect(isRiskRowStale({'is_stale': true}), isTrue);
    expect(isRiskRowStale({'is_stale': false}), isFalse);
    expect(isRiskRowStale({}), isFalse);
  });

  group('RiskRegionList', () {
    testWidgets('every level is written with its region, with score and weather', (tester) async {
      Map<String, dynamic>? tapped;
      await tester.pumpWidget(wrap(RiskRegionList(
        regions: [row(37, 12, 47, 22, 10), row(0, 1, 100, 6, 0, region: 'Dogu Anadolu')],
        onRegionTap: (r) => tapped = r,
      )));
      expect(find.text('Akdeniz: Orta'), findsOneWidget);
      expect(find.text('Doğu Anadolu: Düşük'), findsOneWidget);
      expect(find.text('Orta'), findsNothing);
      expect(find.text('37/100'), findsOneWidget);
      expect(find.text('12°C · %47 nem · 22 km/h'), findsOneWidget);
      await tester.tap(find.byKey(const Key('riskRegionRow-Akdeniz')));
      expect(tapped?['region'], 'Akdeniz');
    });
  });

  group('RiskComponentsList', () {
    testWidgets('real points with readings, no bonus row when there is no bonus', (tester) async {
      await tester.pumpWidget(wrap(RiskComponentsList(row: row(37, 12, 47, 22, 10))));
      expect(find.text('+0/30'), findsOneWidget);
      expect(find.text('+6/25'), findsOneWidget);
      expect(find.text('+11/25'), findsOneWidget);
      expect(find.text('+20/20'), findsOneWidget);
      expect(find.text('37/100'), findsOneWidget);
      expect(find.text('Sıcaklık · 12°C'), findsOneWidget);
      expect(find.text('Nem · %47'), findsOneWidget);
      expect(find.text('Rüzgâr · 22 km/h'), findsOneWidget);
      expect(find.text('Yakın tespitler · 10 tespit'), findsOneWidget);
      expect(find.byKey(const Key('riskComponent-bonus')), findsNothing);
    });

    testWidgets('bonus row appears when the formula gave one', (tester) async {
      await tester.pumpWidget(wrap(RiskComponentsList(row: row(52, 39, 29, 0, 0))));
      expect(find.byKey(const Key('riskComponent-bonus')), findsOneWidget);
      expect(find.text('+10/20'), findsOneWidget);
    });

    testWidgets('bars use the colour of the score level', (tester) async {
      await tester.pumpWidget(wrap(RiskComponentsList(row: row(37, 12, 47, 22, 10))));
      for (final bar in tester.widgetList<LinearProgressIndicator>(find.byType(LinearProgressIndicator))) {
        expect((bar.valueColor as AlwaysStoppedAnimation<Color>).value, riskScoreColor(37));
      }
    });

    testWidgets('unknown count reads as unknown', (tester) async {
      await tester.pumpWidget(wrap(RiskComponentsList(row: row(17, 12, 47, 22, null))));
      expect(find.text('Yakın tespitler · Bilinmiyor'), findsOneWidget);
    });

    testWidgets('impossible score shows the note, not invented points', (tester) async {
      await tester.pumpWidget(wrap(RiskComponentsList(row: row(99, 12, 47, 22, 10))));
      expect(find.byKey(const Key('riskComponentsUnavailable')), findsOneWidget);
      expect(find.textContaining('/30'), findsNothing);
    });

    test('the written thresholds come from the same tables', () {
      final text = riskThresholdsText(AppLocalizationsTr());
      expect(text, contains('≥25°C +7 · ≥30°C +14 · ≥35°C +22 · ≥40°C +30'));
      expect(text, contains('≤%50 +6 · ≤%40 +13 · ≤%30 +20 · ≤%20 +25'));
      expect(text, contains('≥10 km/h +5 · ≥20 km/h +11 · ≥35 km/h +18 · ≥50 km/h +25'));
      expect(text, contains('≥1 +5 · ≥2 +10 · ≥5 +15 · ≥10 +20'));
      expect(text, contains('35°C üstü ve nem %30 altı +10'));
      expect(text, contains('40°C üstü ve nem %20 altı +20'));
    });
  });

  group('source guards', () {
    final src = File('lib/features/risk/risk_screen.dart').readAsStringSync();

    test('derived indicators and the duplicate sections are gone', () {
      for (final gone in [
        'dryness_index',
        'vegetation_density',
        'riskEnvironmentalFactors',
        'riskKeyIndicators',
        'riskRegionalDistribution',
        'riskRegionDetails',
        'SmartOverviewCard',
        'riskOverviewTrendStable',
        'riskOverviewTrendNoData',
      ]) {
        expect(src, isNot(contains(gone)), reason: gone);
      }
    });

    test('details use showAppSheet and the one list', () {
      expect(src, contains('showAppSheet('));
      expect(RegExp(r'RiskRegionList\(').allMatches(src).length, 1);
      expect(RegExp(r'RiskComponentsList\(').allMatches(src).length, 2);
    });
  });
}
