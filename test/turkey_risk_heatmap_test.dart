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

  group('riskHeatGradientColor', () {
    test('band middles are exactly the band colours, ends clamp', () {
      expect(riskHeatGradientColor(0), riskHeatLowColor);
      expect(riskHeatGradientColor(12.5), riskHeatLowColor);
      expect(riskHeatGradientColor(37.5), riskHeatMediumColor);
      expect(riskHeatGradientColor(62.5), riskHeatHighColor);
      expect(riskHeatGradientColor(87.5), riskHeatVeryHighColor);
      expect(riskHeatGradientColor(100), riskHeatVeryHighColor);
    });
  });

  group('buildRiskHeatRaster', () {
    // A square "country" around the Ege and Marmara centroids.
    final square = [
      [
        const LatLng(37, 26),
        const LatLng(37, 30),
        const LatLng(41.5, 30),
        const LatLng(41.5, 26),
      ],
    ];

    int alphaAt(RiskHeatRaster r, int col, int row) => r.rgba[(row * r.width + col) * 4 + 3];

    test('no scores gives a fully transparent raster', () {
      final r = buildRiskHeatRaster(const {}, square);
      expect(r.rgba.every((b) => b == 0), isTrue);
    });

    test('pixels outside the border stay transparent, inside are opaque', () {
      final r = buildRiskHeatRaster(const {'Ege': 82, 'Marmara': 58}, square);
      // Far east column (lon ≈ 44.9) is outside the square.
      expect(alphaAt(r, r.width - 1, r.height ~/ 2), 0);
      // lon ≈ 28 is column (28 - 25.5) / 0.05 = 50; middle row is inside.
      expect(alphaAt(r, 50, r.height ~/ 2), 255);
    });

    test('the field never leaves the range of the real scores', () {
      final r = buildRiskHeatRaster(const {'Ege': 82, 'Marmara': 58}, square);
      final lowest = riskHeatGradientColor(58);
      final highest = riskHeatGradientColor(82);
      for (var i = 0; i < r.rgba.length; i += 4) {
        if (r.rgba[i + 3] == 0) continue;
        // Between orange and red, red channel stays within the two ends.
        final red = r.rgba[i];
        final lo = (lowest.r * 255).round();
        final hi = (highest.r * 255).round();
        expect(red, inInclusiveRange(lo < hi ? lo : hi, lo < hi ? hi : lo));
      }
    });

    test('unknown region keys are ignored', () {
      final r = buildRiskHeatRaster(const {'Atlantis': 99}, square);
      expect(r.rgba.every((b) => b == 0), isTrue);
    });

    test('raster height follows the Mercator aspect of the bounds', () {
      final r = buildRiskHeatRaster(const {'Ege': 50}, square);
      expect(r.width, 390);
      expect(r.height, inInclusiveRange(160, 175));
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
    });
  });
}
