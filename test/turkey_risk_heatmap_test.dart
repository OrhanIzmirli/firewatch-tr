import 'dart:convert';
import 'dart:io';

import 'package:firewatch_tr/core/utils/risk_display.dart';
import 'package:firewatch_tr/features/risk/widgets/risk_region_geometry.dart';
import 'package:firewatch_tr/features/risk/widgets/turkey_risk_heatmap.dart';
import 'package:firewatch_tr/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

void main() {
  group('riskHeatBandFor uses the shared 25/50/75 bands', () {
    test('boundaries', () {
      expect(riskHeatBandFor(0), RiskHeatBand.low);
      expect(riskHeatBandFor(24.9), RiskHeatBand.low);
      expect(riskHeatBandFor(25), RiskHeatBand.medium);
      expect(riskHeatBandFor(49), RiskHeatBand.medium);
      expect(riskHeatBandFor(50), RiskHeatBand.high);
      expect(riskHeatBandFor(74), RiskHeatBand.high);
      expect(riskHeatBandFor(75), RiskHeatBand.veryHigh);
      expect(riskHeatBandFor(100), RiskHeatBand.veryHigh);
    });

    test('band colours are the design hex values', () {
      expect(riskHeatBandColor(RiskHeatBand.low), const Color(0xFF0CA30C));
      expect(riskHeatBandColor(RiskHeatBand.medium), const Color(0xFFFAB219));
      expect(riskHeatBandColor(RiskHeatBand.high), const Color(0xFFEC835A));
      expect(riskHeatBandColor(RiskHeatBand.veryHigh), const Color(0xFFD03B3B));
    });
  });

  group('flat region colours', () {
    test('each band is one colour, changing exactly at 25, 50 and 75', () {
      expect(riskRegionFillColor(0), riskRegionFillColor(24));
      expect(riskRegionFillColor(24), isNot(riskRegionFillColor(25)));
      expect(riskRegionFillColor(25), riskRegionFillColor(49));
      expect(riskRegionFillColor(49), isNot(riskRegionFillColor(50)));
      expect(riskRegionFillColor(50), riskRegionFillColor(74));
      expect(riskRegionFillColor(74), isNot(riskRegionFillColor(75)));
      expect(riskRegionFillColor(75), riskRegionFillColor(100));
    });

    test('fills are the shared level colours', () {
      for (final score in [0, 25, 50, 75]) {
        expect(riskRegionFillColor(score).withValues(alpha: 1), riskScoreColor(score));
      }
    });

    test('no blending is left in the map', () {
      final src = File('lib/features/risk/widgets/turkey_risk_heatmap.dart').readAsStringSync();
      expect(src, isNot(contains('Color.lerp')));
      expect(src, isNot(contains('OverlayImage')));
    });
  });

  group('dissolveRegions on the real province file', () {
    final shapes = dissolveRegions(
      jsonDecode(File('assets/data/il_sinirlari.geojson').readAsStringSync()) as Map<String, dynamic>,
    );

    bool inside(List<List<LatLng>> rings, LatLng p) {
      var hit = false;
      for (final ring in rings) {
        for (var i = 0, j = ring.length - 1; i < ring.length; j = i++) {
          final a = ring[i], b = ring[j];
          if ((a.latitude > p.latitude) != (b.latitude > p.latitude) &&
              p.longitude <
                  a.longitude + (p.latitude - a.latitude) / (b.latitude - a.latitude) * (b.longitude - a.longitude)) {
            hit = !hit;
          }
        }
      }
      return hit;
    }

    test('seven regions, every API region name has a shape', () {
      expect(shapes, hasLength(7));
      for (final name in ['Marmara', 'Ege', 'Akdeniz', 'Ic Anadolu', 'Karadeniz', 'Dogu Anadolu', 'Guneydogu Anadolu']) {
        expect(shapes[riskRegionShapeKey(name)], isNotNull, reason: name);
      }
    });

    test('all rings close, and province lines inside a region are gone', () {
      var vertices = 0;
      for (final rings in shapes.values) {
        for (final ring in rings) {
          expect(ring.first, ring.last);
          vertices += ring.length;
        }
      }
      // The file has 56k vertices in province rings.
      expect(vertices, lessThan(30000));
    });

    test('known cities fall in their own region and no other', () {
      const cities = {
        'marmara': LatLng(41.01, 28.97), // Istanbul
        'ege': LatLng(38.42, 27.14), // Izmir
        'akdeniz': LatLng(36.9, 30.7), // Antalya
        'ic anadolu': LatLng(39.93, 32.85), // Ankara
        'karadeniz': LatLng(41.0, 39.72), // Trabzon
        'dogu anadolu': LatLng(39.9, 41.27), // Erzurum
        'guneydogu anadolu': LatLng(37.07, 37.38), // Gaziantep
      };
      cities.forEach((region, point) {
        for (final other in shapes.keys) {
          expect(inside(shapes[other]!, point), other == region, reason: '$region in $other');
        }
      });
    });
  });

  group('TurkeyRiskHeatmap widget', () {
    Widget wrap(Widget child) => MaterialApp(
          locale: const Locale('tr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: child),
        );

    testWidgets('no data: renders without the pill and without throwing', (tester) async {
      await tester.pumpWidget(wrap(const TurkeyRiskHeatmap(regionScores: {})));
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
      expect(find.textContaining('/100'), findsNothing);
    });

    testWidgets('with data: pill shows the average and its band', (tester) async {
      await tester.pumpWidget(wrap(const TurkeyRiskHeatmap(
        regionScores: {'Ege': 82, 'Marmara': 58, 'Karadeniz': 10},
      )));
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
      // (82 + 58 + 10) / 3 = 50 -> "Yüksek" on the shared 25/50/75 bands.
      expect(find.text('Türkiye geneli · 50/100 · Yüksek'), findsOneWidget);
      expect(find.byKey(const Key('riskMapLegend')), findsOneWidget);
    });
  });
}
