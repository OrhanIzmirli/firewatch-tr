import 'dart:io';

import 'package:firewatch_tr/features/location_permission/location_permission_screen.dart';
import 'package:firewatch_tr/features/notification_permission/notification_permission_screen.dart';
import 'package:firewatch_tr/l10n/app_localizations.dart';
import 'package:firewatch_tr/l10n/app_localizations_en.dart';
import 'package:firewatch_tr/l10n/app_localizations_tr.dart';
import 'package:firewatch_tr/services/location_disclosure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _app(Widget home, String locale) => MaterialApp(
      locale: Locale(locale),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: home,
    );

Iterable<File> _dartFiles() => Directory('lib')
    .listSync(recursive: true)
    .whereType<File>()
    .where((f) => f.path.endsWith('.dart') && !f.path.contains('l10n'));

void _expectPlainBodyText(WidgetTester tester, List<String> paragraphs) {
  for (final text in paragraphs) {
    final style = tester.widget<Text>(find.text(text)).style!;
    expect(style.fontSize, greaterThanOrEqualTo(16), reason: text);
    expect(style.color!.a, 1, reason: 'full contrast: $text');
  }
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    LocationDisclosure.resetForTest();
  });

  group('what the location disclosure says', () {
    final tr = AppLocalizationsTr();
    final en = AppLocalizationsEn();

    test('names the data and the uses', () {
      expect(tr.locDisclosureLead, contains('konum verilerinizi toplar'));
      for (final use in ['tespit', 'risk', 'bildirim']) {
        expect(tr.locDisclosureLead, contains(use));
      }
      expect(en.locDisclosureLead, contains('collects your location data'));
      for (final use in ['detections', 'risk', 'notifications']) {
        expect(en.locDisclosureLead, contains(use));
      }
    });

    test('uses Google\'s background wording, on both pages', () {
      expect(tr.locDisclosureBackground, contains('uygulama kapalıyken veya kullanılmıyorken de'));
      expect(tr.backgroundDisclosureLead, contains('uygulama kapalıyken veya kullanılmıyorken de'));
      expect(en.locDisclosureBackground, contains('when the app is closed or not in use'));
      expect(en.backgroundDisclosureLead, contains('when the app is closed or not in use'));
    });

    test('says server, about 1 km, not shared, how to delete', () {
      expect(tr.locDisclosureServer, contains('sunucumuza gönderilir'));
      expect(en.locDisclosureServer, contains('sent to our server'));
      expect(tr.locDisclosureStored, contains('1 km'));
      expect(en.locDisclosureStored, contains('1 km'));
      expect(tr.locDisclosureShared, contains('paylaşılmaz'));
      expect(en.locDisclosureShared, contains('not shared'));
      expect(tr.locDisclosureDelete, contains('Konum verimi sil'));
      expect(en.locDisclosureDelete, contains('Delete my location data'));
    });

    test('the buttons are the ones Play expects', () {
      expect(tr.disclosureAccept, 'Kabul ediyorum');
      expect(tr.disclosureDecline, 'Hayır, teşekkürler');
      expect(en.disclosureAccept, 'I agree');
      expect(en.disclosureDecline, 'No, thanks');
    });

    test('background checks stay on the phone', () {
      expect(tr.backgroundDisclosureDevice, contains('sunucumuza gönderilmez'));
      expect(en.backgroundDisclosureDevice, contains('not sent to our server'));
    });
  });

  group('every prompt goes through the disclosure', () {
    test('only location_disclosure.dart raises a location prompt', () {
      final raising = _dartFiles()
          .where((f) {
            final s = f.readAsStringSync();
            return s.contains('Geolocator.requestPermission(') || s.contains('locationAlways.request(');
          })
          .map((f) => f.path.replaceAll(r'\', '/'))
          .toList();
      expect(raising, ['lib/services/location_disclosure.dart']);
    });

    test('app start never raises the notification prompt', () {
      final source = File('lib/services/notification_service.dart').readAsStringSync();
      expect(source, isNot(contains('_fcm.requestPermission')));
    });

    test('the camera is offered with its explanation', () {
      final panel = File('lib/shared/widgets/report_fire_panel.dart').readAsStringSync();
      final sheet = panel.indexOf('reportPanelPhotoDisclosure');
      expect(sheet, greaterThan(0));
      expect(sheet, lessThan(panel.indexOf('reportPanelPhotoSourceCamera')));
    });
  });

  for (final locale in ['tr', 'en']) {
    final AppLocalizations l10n = locale == 'tr' ? AppLocalizationsTr() : AppLocalizationsEn();

    testWidgets('$locale: the onboarding page is plain body text', (tester) async {
      await tester.pumpWidget(_app(const LocationPermissionScreen(), locale));
      await tester.pump();
      expect(find.text(l10n.locDisclosureTitle), findsOneWidget);
      expect(find.text(l10n.disclosureAccept), findsOneWidget);
      expect(find.text(l10n.disclosureDecline), findsOneWidget);
      _expectPlainBodyText(tester, locationDisclosureParagraphs(l10n));
      expect(find.byKey(const Key('disclosurePrivacyPolicy')), findsOneWidget);
      expect(find.byType(BackdropFilter), findsNothing);
    });

    testWidgets('$locale: the background page is plain body text', (tester) async {
      await tester.pumpWidget(_app(const BackgroundLocationDisclosurePage(), locale));
      await tester.pump();
      expect(find.text(l10n.backgroundDisclosureTitle), findsOneWidget);
      _expectPlainBodyText(tester, [
        l10n.backgroundDisclosureLead,
        l10n.backgroundDisclosureDevice,
        l10n.backgroundDisclosureStop,
        l10n.backgroundDisclosureOptional,
      ]);
    });

    testWidgets('$locale: the notification page says what is stored', (tester) async {
      await tester.pumpWidget(_app(const NotificationPermissionScreen(), locale));
      await tester.pump();
      _expectPlainBodyText(tester, [l10n.notifPermSubtitle, l10n.notifPermData, l10n.notifPermNote]);
      expect(l10n.notifPermData, contains('FCM'));
    });
  }

  testWidgets('the page fits a small phone without overflow', (tester) async {
    tester.view.physicalSize = const Size(720, 1280);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(const LocationDisclosurePage(), 'tr'));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('locDisclosureContinue')), findsOneWidget);
  });
}
