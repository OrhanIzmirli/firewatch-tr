import 'dart:io';

import 'package:firewatch_tr/l10n/app_localizations.dart';
import 'package:firewatch_tr/models/fire_incident.dart';
import 'package:firewatch_tr/features/map/widgets/incident_sheet.dart';
import 'package:firewatch_tr/services/location_disclosure.dart';
import 'package:firewatch_tr/shared/widgets/app_sheet.dart';
import 'package:firewatch_tr/shared/widgets/feedback_sheet.dart';
import 'package:firewatch_tr/shared/widgets/info_icon_button.dart';
import 'package:firewatch_tr/shared/widgets/report_fire_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _screen = Size(411, 800);

Future<BuildContext> _host(WidgetTester tester) async {
  tester.view.physicalSize = _screen * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  late BuildContext captured;
  await tester.pumpWidget(MaterialApp(
    locale: const Locale('tr'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: Builder(builder: (c) {
      captured = c;
      return const SizedBox.expand();
    })),
  ));
  return captured;
}

Future<void> _settle(WidgetTester tester) => tester.pump(const Duration(seconds: 1)).then((_) => tester.pump(const Duration(seconds: 1)));

/// The same four ways out and the same ceiling, for any window.
Future<void> _checkSheet(WidgetTester tester, void Function(BuildContext) open) async {
  final context = await _host(tester);
  bool isOpen() => find.byKey(const Key('sheetClose')).evaluate().isNotEmpty;

  open(context);
  await _settle(tester);
  expect(isOpen(), isTrue, reason: 'has a visible close button');
  expect(find.byKey(const Key('sheetHandle')), findsOneWidget);
  final top = tester.getTopLeft(find.byKey(const Key('sheetHeader'))).dy;
  expect(_screen.height - top, lessThanOrEqualTo(_screen.height * kSheetMaxHeightFraction + 1), reason: 'at most 85% of the screen');

  await tester.tap(find.byKey(const Key('sheetClose')));
  await _settle(tester);
  expect(isOpen(), isFalse, reason: 'X closes');

  open(context);
  await _settle(tester);
  await tester.tapAt(const Offset(200, 20));
  await _settle(tester);
  expect(isOpen(), isFalse, reason: 'tap outside closes');

  open(context);
  await _settle(tester);
  await tester.binding.handlePopRoute();
  await _settle(tester);
  expect(isOpen(), isFalse, reason: 'Back closes');

  open(context);
  await _settle(tester);
  await tester.fling(find.byKey(const Key('sheetHandle')), const Offset(0, 500), 2500);
  await _settle(tester);
  expect(isOpen(), isFalse, reason: 'swipe down closes');
}

FireIncident _incident() => FireIncident.fromJson({
      'id': 1,
      'first_detected_at': '2026-11-08T09:30:00.000Z',
      'last_detected_at': '2026-11-08T09:30:00.000Z',
      'duration_hours': 3,
      'detection_count': 4,
      'overpass_count': 3,
      'latitude': 39.5,
      'longitude': 33.7,
      'max_frp_mw': 22.0,
      'peak_confidence_tier': 'high',
      'city_name': 'Kırıkkale',
      'sources': const [],
      'satellite': {'state': 'detected_recently', 'hours_since_last_detection': 3},
      'official': const {},
      'optical': const {},
      'trend': const {},
      'spread': const {},
      'persistence': const {},
    });

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('a long sheet stops at 85% and still closes', (tester) async {
    await _checkSheet(tester, (c) => showAppSheet<void>(c, builder: (_) => const SizedBox(height: 3000)));
  });
  testWidgets('a short sheet', (tester) async {
    await _checkSheet(tester, (c) => showAppSheet<void>(c, builder: (_) => const SizedBox(height: 120)));
  });
  testWidgets('a sheet that scrolls itself', (tester) async {
    await _checkSheet(tester, (c) => showAppSheet<void>(c, scrollable: false, builder: (_) => ListView(shrinkWrap: true, children: const [SizedBox(height: 3000)])));
  });
  testWidgets('flat cards: a GlassPanel-like sheet closes too', (tester) async {
    await _checkSheet(tester, (c) => showAppSheet<void>(c, flatGlass: true, builder: (_) => const SizedBox(height: 900)));
  });
  testWidgets('feedback window', (tester) async {
    await _checkSheet(tester, (c) => showFeedbackSheet(c));
  });
  testWidgets('bug report window', (tester) async {
    await _checkSheet(tester, (c) => showBugReportSheet(c));
  });
  testWidgets('location disclosure window', (tester) async {
    await _checkSheet(tester, (c) => showAppSheet<bool>(c, scrollable: false, builder: (_) => const LocationDisclosureSheet()));
  });

  testWidgets('detection window: X, outside, Back', (tester) async {
    final context = await _host(tester);
    bool isOpen() => find.byKey(const Key('sheetClose')).evaluate().isNotEmpty;
    void open() => IncidentSheet.show(context, incident: _incident());

    open();
    await _settle(tester);
    expect(find.byKey(const Key('sheetHandle')), findsOneWidget);
    final top = tester.getTopLeft(find.byKey(const Key('sheetHeader'))).dy;
    expect(_screen.height - top, lessThanOrEqualTo(_screen.height * kSheetMaxHeightFraction + 1));
    await tester.tap(find.byKey(const Key('sheetClose')));
    await _settle(tester);
    expect(isOpen(), isFalse);

    open();
    await _settle(tester);
    await tester.tapAt(const Offset(200, 10));
    await _settle(tester);
    expect(isOpen(), isFalse);

    open();
    await _settle(tester);
    await tester.binding.handlePopRoute();
    await _settle(tester);
    expect(isOpen(), isFalse);
  });

  testWidgets('report window is capped and has its close button', (tester) async {
    final context = await _host(tester);
    showReportFirePanel(context);
    await _settle(tester);
    final top = tester.getTopLeft(find.byType(ReportFirePanel)).dy;
    final sheet = tester.getTopLeft(find.byIcon(Icons.close_rounded)).dy;
    expect(_screen.height - sheet, lessThanOrEqualTo(_screen.height * kSheetMaxHeightFraction + 1), reason: 'from $top');
    await tester.tap(find.byIcon(Icons.close_rounded));
    await _settle(tester);
    expect(find.byType(ReportFirePanel), findsNothing);
  });

  testWidgets('info dialog closes with X, outside and Back', (tester) async {
    tester.view.physicalSize = _screen * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(
      locale: Locale('tr'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: Center(child: InfoIconButton(title: 'Başlık', bodyLines: ['Metin']))),
    ));
    Future<void> open() async {
      await tester.tap(find.byType(InfoIconButton));
      await _settle(tester);
      expect(find.byKey(const Key('dialogClose')), findsOneWidget);
    }

    bool isOpen() => find.byKey(const Key('dialogClose')).evaluate().isNotEmpty;
    await open();
    await tester.tap(find.byKey(const Key('dialogClose')));
    await _settle(tester);
    expect(isOpen(), isFalse);
    await open();
    await tester.tapAt(const Offset(10, 10));
    await _settle(tester);
    expect(isOpen(), isFalse);
    await open();
    await tester.binding.handlePopRoute();
    await _settle(tester);
    expect(isOpen(), isFalse);
  });

  test('every window in the app goes through the shared opener', () {
    final offenders = <String>[];
    for (final f in Directory('lib').listSync(recursive: true).whereType<File>()) {
      if (!f.path.endsWith('.dart') || f.path.contains('l10n') || f.path.endsWith('app_sheet.dart')) continue;
      final s = f.readAsStringSync();
      if (s.contains('showModalBottomSheet') || s.contains('showBottomSheet(')) offenders.add(f.path);
      for (final m in RegExp(r'AlertDialog\(').allMatches(s)) {
        if (!s.substring(m.start, (m.start + 260).clamp(0, s.length)).contains('DialogTitleWithClose')) offenders.add('${f.path} dialog');
      }
      if (RegExp(r'barrierDismissible:\s*false|isDismissible:\s*false|enableDrag:\s*false').hasMatch(s)) offenders.add('${f.path} locks a window');
    }
    expect(offenders, isEmpty);
  });
}
