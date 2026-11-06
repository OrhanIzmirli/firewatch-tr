import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firewatch_tr/l10n/app_localizations.dart';
import 'package:firewatch_tr/features/risk/district_risk_screen.dart';
import 'package:firewatch_tr/features/history/history_screen.dart';

Widget localized(Widget child) => MaterialApp(
  locale: const Locale('tr'),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: const [AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate],
  theme: ThemeData.dark(), home: child);

void main() {
  testWidgets('District selector, legend and ranking fit a narrow phone', (tester) async {
    tester.view.physicalSize = const Size(320,640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(localized(const DistrictRiskScreen()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Çok yüksek'), findsOneWidget);
    await tester.tap(find.text('Risk sıralamasını aç'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('İzmir / Örnek ilçe A'));
    await tester.pumpAndSettle();
    expect(find.text('İzmir / Örnek ilçe A · 82/100'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('History details show concrete area without unsupported restoration claims', (tester) async {
    tester.view.physicalSize = const Size(320,640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(localized(const HistoryScreen()));
    await tester.pumpAndSettle();
    // The fixture is in 2026; choose the wide range independently of current summer.
    await tester.ensureVisible(find.text('Son 3 yıl'));
    await tester.tap(find.text('Son 3 yıl'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Muğla / Örnek alan A'));
    await tester.pumpAndSettle();
    expect(find.textContaining('2801 futbol sahası'), findsOneWidget);
    expect(find.textContaining('kaynakla doğrulanmış restorasyon'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
