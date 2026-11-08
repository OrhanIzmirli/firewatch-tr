import 'package:firewatch_tr/core/constants/app_colors.dart';
import 'package:firewatch_tr/l10n/app_localizations.dart';
import 'package:firewatch_tr/models/detection_status.dart';
import 'package:firewatch_tr/shared/widgets/system_status_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

double _luminanceContrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (la > lb ? la + 0.05 : lb + 0.05) / (la > lb ? lb + 0.05 : la + 0.05);
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  final now = DateTime(2026, 11, 8, 12, 40);
  DetectionStatus quiet(Duration age) => DetectionStatus(kind: DetectionStatusKind.none, lastUpdateAt: now.subtract(age));

  group('systemFreshness', () {
    test('recent data is fresh, whether or not anything was detected', () {
      expect(systemFreshness(quiet(const Duration(minutes: 10)), now), SystemFreshness.fresh);
      expect(
        systemFreshness(DetectionStatus(kind: DetectionStatusKind.strong, lastUpdateAt: now), now),
        SystemFreshness.fresh,
      );
    });

    test('the two-hour boundary: exactly two hours is fresh, a moment more is stale', () {
      expect(systemFreshness(quiet(const Duration(hours: 2)), now), SystemFreshness.fresh);
      expect(systemFreshness(quiet(const Duration(hours: 2, seconds: 1)), now), SystemFreshness.stale);
    });

    test('a pipeline the backend still calls fresh goes stale here after two hours', () {
      expect(systemFreshness(quiet(const Duration(hours: 5)), now), SystemFreshness.stale);
    });

    test('the backend saying stale wins over a recent timestamp', () {
      expect(
        systemFreshness(DetectionStatus(kind: DetectionStatusKind.stale, lastUpdateAt: now), now),
        SystemFreshness.stale,
      );
    });

    test('no timestamp cannot be called fresh', () {
      expect(systemFreshness(const DetectionStatus(kind: DetectionStatusKind.none), now), SystemFreshness.stale);
    });

    test('no answer and a failed request are unavailable', () {
      expect(systemFreshness(null, now), SystemFreshness.unavailable);
      expect(systemFreshness(DetectionStatus.unavailable, now), SystemFreshness.unavailable);
    });

    test('compares instants, not wall clocks', () {
      final utc = now.toUtc().subtract(const Duration(minutes: 30));
      expect(systemFreshness(DetectionStatus(kind: DetectionStatusKind.none, lastUpdateAt: utc), now), SystemFreshness.fresh);
    });
  });

  group('SystemStatusLine', () {
    Future<void> pump(WidgetTester tester, DetectionStatus? status, {Locale locale = const Locale('tr'), ThemeData? theme}) async {
      await tester.pumpWidget(MaterialApp(
        locale: locale,
        theme: theme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: SystemStatusLine(status: status, now: now)),
      ));
    }

    Color iconColor(WidgetTester tester) => tester.widget<Icon>(find.byType(Icon)).color!;

    testWidgets('fresh says it is working, in green', (tester) async {
      await pump(tester, DetectionStatus(kind: DetectionStatusKind.none, lastUpdateAt: DateTime(2026, 11, 8, 12, 5)));
      expect(find.text('Sistem çalışıyor · Son kontrol: 12:05'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
      expect(iconColor(tester), SystemStatusLine.colorFor(SystemFreshness.fresh, Brightness.light));
    });

    testWidgets('stale is yellow, says so, and never says working', (tester) async {
      await pump(tester, DetectionStatus(kind: DetectionStatusKind.none, lastUpdateAt: DateTime(2026, 11, 8, 9, 7)));
      expect(find.text('Uydu verisi güncel değil · Son kontrol: 09:07'), findsOneWidget);
      expect(find.textContaining('çalışıyor'), findsNothing);
      expect(iconColor(tester), SystemStatusLine.colorFor(SystemFreshness.stale, Brightness.light));
    });

    testWidgets('a last check on another day carries the date', (tester) async {
      await pump(tester, DetectionStatus(kind: DetectionStatusKind.stale, lastUpdateAt: DateTime(2026, 11, 7, 23, 50)));
      expect(find.text('Uydu verisi güncel değil · Son kontrol: 07.11 23:50'), findsOneWidget);
    });

    testWidgets('stale without a timestamp still says out of date', (tester) async {
      await pump(tester, const DetectionStatus(kind: DetectionStatusKind.stale));
      expect(find.text('Uydu verisi güncel değil.'), findsOneWidget);
    });

    testWidgets('unavailable and a missing status are red', (tester) async {
      for (final status in [DetectionStatus.unavailable, null]) {
        await pump(tester, status);
        expect(find.text('Uydu verisi alınamadı.'), findsOneWidget);
        expect(find.textContaining('çalışıyor'), findsNothing);
        expect(iconColor(tester), SystemStatusLine.colorFor(SystemFreshness.unavailable, Brightness.light));
      }
    });

    testWidgets('English', (tester) async {
      await pump(tester, DetectionStatus(kind: DetectionStatusKind.none, lastUpdateAt: DateTime(2026, 11, 8, 12, 5)), locale: const Locale('en'));
      expect(find.text('System working · Last check: 12:05'), findsOneWidget);
    });

    test('every state is readable on the cards of both themes', () {
      for (final state in SystemFreshness.values) {
        expect(_luminanceContrast(SystemStatusLine.colorFor(state, Brightness.dark), AppColors.surface), greaterThanOrEqualTo(4.5), reason: '$state dark');
        expect(_luminanceContrast(SystemStatusLine.colorFor(state, Brightness.light), AppColors.white), greaterThanOrEqualTo(4.5), reason: '$state light');
      }
    });
  });
}
