import 'package:firewatch_tr/features/risk/widgets/risk_summary_card.dart';
import 'package:firewatch_tr/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('riskTierForScore uses the backend cut points', () {
    test('boundaries', () {
      expect(riskTierForScore(0), RiskTier.low);
      expect(riskTierForScore(24), RiskTier.low);
      expect(riskTierForScore(25), RiskTier.medium);
      expect(riskTierForScore(49), RiskTier.medium);
      expect(riskTierForScore(50), RiskTier.high);
      expect(riskTierForScore(74), RiskTier.high);
      expect(riskTierForScore(75), RiskTier.veryHigh);
      expect(riskTierForScore(100), RiskTier.veryHigh);
    });

    test('API level wins, unknown level falls back to score', () {
      expect(riskTierFor(apiLevel: 'Critical', score: 10), RiskTier.veryHigh);
      expect(riskTierFor(apiLevel: 'Low', score: 90), RiskTier.low);
      expect(riskTierFor(apiLevel: 'weird', score: 60), RiskTier.high);
      expect(riskTierFor(apiLevel: null, score: 30), RiskTier.medium);
    });
  });

  group('dominantRiskFactor', () {
    RiskFactor f(double t, double h, double w, [RiskTier tier = RiskTier.high]) =>
        dominantRiskFactor(temperature: t, humidity: h, windSpeed: w, tier: tier);

    test('low tier is always calm', () {
      expect(f(38, 15, 60, RiskTier.low), RiskFactor.calm);
    });
    test('hot and dry together (heat-index bonus) wins', () {
      expect(f(37, 25, 10), RiskFactor.hotAndDry);
    });
    test('strong wind beats a mild heat/dryness', () {
      expect(f(26, 45, 55), RiskFactor.wind);
    });
    test('dry air beats moderate heat', () {
      expect(f(31, 18, 5), RiskFactor.dry);
    });
    test('heat alone', () {
      expect(f(36, 60, 5), RiskFactor.heat);
    });
    test('closest buckets pick the larger contribution', () {
      expect(f(30, 40, 0), RiskFactor.heat); // 14 vs 13
      expect(f(25, 50, 10), RiskFactor.heat); // 7 vs 6 vs 5
    });
    test('a tie between dryness and wind goes to dryness', () {
      expect(f(20, 20, 50), RiskFactor.dry); // 25 vs 25
    });
    test('nothing contributes -> calm even at a higher tier', () {
      expect(f(20, 70, 5, RiskTier.medium), RiskFactor.calm);
    });
  });

  group('turkishLocative', () {
    test('region names', () {
      expect(turkishLocative('Ege'), "Ege'de");
      expect(turkishLocative('Akdeniz'), "Akdeniz'de");
      expect(turkishLocative('Marmara'), "Marmara'da");
      expect(turkishLocative('Karadeniz'), "Karadeniz'de");
      expect(turkishLocative('İç Anadolu'), "İç Anadolu'da");
      expect(turkishLocative('Doğu Anadolu'), "Doğu Anadolu'da");
      expect(turkishLocative('Güneydoğu Anadolu'), "Güneydoğu Anadolu'da");
    });
    test('hard consonant and front rounded vowels', () {
      expect(turkishLocative('Tokat'), "Tokat'ta");
      expect(turkishLocative('Muş'), "Muş'ta");
      expect(turkishLocative('Ürgüp'), "Ürgüp'te");
      expect(turkishLocative('Bolu'), "Bolu'da");
    });
  });

  group('RiskSummaryCard widget', () {
    Widget wrap(Widget child, {Locale locale = const Locale('tr')}) => MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: SingleChildScrollView(child: child)),
        );

    testWidgets('no data shows the unavailable message', (tester) async {
      await tester.pumpWidget(wrap(const RiskSummaryCard(data: null)));
      await tester.pumpAndSettle();
      expect(find.text('Risk verisi şu an alınamıyor'), findsOneWidget);
    });

    testWidgets('filled card builds the one-line sentence', (tester) async {
      await tester.pumpWidget(wrap(const RiskSummaryCard(
        data: RiskSummaryData(
          placeName: 'Ege',
          placeInSentence: "Ege'de",
          sourceLabel: 'Konumuna göre · İzmir',
          score: 62,
          tier: RiskTier.high,
          temperature: 33,
          humidity: 18,
          windSpeed: 12,
        ),
      )));
      await tester.pumpAndSettle();
      expect(find.text('Ege'), findsOneWidget);
      expect(find.text('Yüksek'), findsOneWidget);
      expect(
        find.text("Bugün Ege'de yangın riski yüksek çünkü hava kuru (nem %18)."),
        findsOneWidget,
      );
    });
  });
}
