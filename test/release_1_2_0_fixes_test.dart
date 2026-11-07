// Regression tests for the fixes from the 1.2.0 end-to-end test report
// (Desktop/firewatch-test-1.2.0/RAPOR.md).
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:firewatch_tr/core/utils/emergency_call.dart';
import 'package:firewatch_tr/core/utils/risk_display.dart';
import 'package:firewatch_tr/core/utils/risk_factors.dart';
import 'package:firewatch_tr/features/map/widgets/incident_sheet.dart';
import 'package:firewatch_tr/features/map/widgets/map_layer_bar.dart';
import 'package:firewatch_tr/l10n/app_localizations.dart';
import 'package:firewatch_tr/l10n/app_localizations_en.dart';
import 'package:firewatch_tr/l10n/app_localizations_tr.dart';
import 'package:firewatch_tr/models/fire_incident.dart';
import 'package:firewatch_tr/services/app_version.dart';
import 'package:firewatch_tr/services/device_position.dart';
import 'package:firewatch_tr/services/notification_service.dart';
import 'package:firewatch_tr/shared/widgets/detection_safety_notice.dart';

Widget _app(Widget child, {Locale locale = const Locale('tr')}) => MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(body: child),
    );

Position _position(DateTime at, {double lat = 36.89, double lng = 30.71}) => Position(
      latitude: lat,
      longitude: lng,
      timestamp: at,
      accuracy: 5,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );

void main() {
  final tr = AppLocalizationsTr();
  final en = AppLocalizationsEn();

  group('"not a confirmed fire" + 112 on every map detail card', () {
    testWidgets('the notice says it and its button dials', (tester) async {
      var calls = 0;
      await tester.pumpWidget(_app(DetectionSafetyNotice(onCall: () async {
        calls++;
        return true;
      })));
      expect(find.text(tr.detectionNotConfirmedNotice), findsOneWidget);
      expect(tr.detectionNotConfirmedNotice, contains('doğrulanmış yangın değildir'));
      expect(tr.detectionNotConfirmedNotice, contains('112'));
      await tester.tap(find.byKey(DetectionSafetyNotice.callButtonKey));
      expect(calls, 1);
    });

    testWidgets('the incident (event) sheet shows it near the top', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final incident = FireIncident.fromJson({
        'id': 1,
        'first_detected_at': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
        'last_detected_at': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
        'latitude': 36.9,
        'longitude': 30.7,
        'detection_count': 4,
        'overpass_count': 2,
        'satellite': {'state': 'detected_recently', 'hours_since_last_detection': 1},
      });
      await tester.pumpWidget(_app(IncidentSheet(incident: incident, cityName: 'Antalya')));
      await tester.pumpAndSettle();
      expect(find.byType(DetectionSafetyNotice), findsOneWidget);
      expect(find.text(tr.emergencyCall112), findsOneWidget);
      expect(tr.incidentPanelTitle, isNot(contains('Yangın')));
    });

    test('every map detail view embeds the shared notice', () {
      for (final path in [
        'lib/features/map/widgets/incident_sheet.dart', // event
        'lib/features/map/map_screen.dart', // single detection sheet
        'lib/features/fire_detail/fire_detail_screen.dart', // detection detail
      ]) {
        expect(File(path).readAsStringSync(), contains('DetectionSafetyNotice()'), reason: path);
      }
    });

    test('the dialer opens tel:112 in the phone app, without a canLaunchUrl gate', () async {
      Uri? opened;
      LaunchMode? usedMode;
      final ok = await openDialer('112', (uri, {mode = LaunchMode.platformDefault}) async {
        opened = uri;
        usedMode = mode;
        return true;
      });
      expect(ok, isTrue);
      expect(opened.toString(), 'tel:112');
      expect(usedMode, LaunchMode.externalApplication);
      expect(await openDialer('112', (uri, {mode = LaunchMode.platformDefault}) => throw Exception('no dialer')), isFalse);
      expect(File('lib/core/utils/emergency_call.dart').readAsStringSync(), isNot(contains('canLaunchUrl(')));
      expect(File('android/app/src/main/AndroidManifest.xml').readAsStringSync(), contains('android:scheme="tel"'));
    });
  });

  group('risk level has one source: 25/50/75, four levels', () {
    test('boundaries match the backend calculator', () {
      expect([0, 24, 25, 49, 50, 74, 75, 100].map(riskLevelForScore),
          ['Low', 'Low', 'Medium', 'Medium', 'High', 'High', 'Critical', 'Critical']);
      expect([riskMediumFrom, riskHighFrom, riskCriticalFrom], [25, 50, 75]);
      // The report's case: 46/100 is Medium everywhere.
      expect(riskLevelLabel(tr, riskLevelForScore(46)), tr.commonMedium);
    });

    test('no screen grades a score with its own thresholds', () {
      // Any `score >= 50`-style comparison outside risk_display.dart is a
      // second source of truth. Risk *factor* steps live in risk_factors.dart.
      final inline = RegExp(r'(?:[Ss]core|[Rr]isk)\w*\s*(?:>=|>|<=|<)\s*(?:25|30|50|60|75)\b');
      final offenders = <String>[];
      for (final f in Directory('lib').listSync(recursive: true).whereType<File>()) {
        final p = f.path.replaceAll('\\', '/');
        if (!p.endsWith('.dart') || p.contains('/l10n/') || p.endsWith('core/utils/risk_display.dart')) continue;
        final lines = f.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          if (inline.hasMatch(lines[i])) offenders.add('$p:${i + 1}: ${lines[i].trim()}');
        }
      }
      expect(offenders, isEmpty);
    });

    test('cards read the level from the score, not a stored level string', () {
      expect(File('lib/features/risk/risk_screen.dart').readAsStringSync(), isNot(contains("['risk_level']")));
    });
  });

  group('weather explanations follow the value and the backend steps', () {
    test('points per step mirror riskCalculatorJob.calculateRisk', () {
      expect([24.9, 25, 29.9, 30, 35, 40, 45].map(temperaturePoints), [0, 7, 7, 14, 22, 30, 30]);
      expect([85, 50.1, 50, 40, 30, 20, 5].map(humidityPoints), [0, 0, 6, 13, 20, 25, 25]);
      expect([9.9, 10, 20, 35, 50, 80].map(windPoints), [0, 5, 11, 18, 25, 25]);
    });

    test('the report case: 85% humidity at 8°C is not explained as dry heat', () {
      expect(humidityHint(tr, 85), tr.riskFactorHumidityHintNone);
      expect(humidityHint(tr, 85), isNot(contains('kurutur')));
      expect(temperatureHint(tr, 8), tr.riskFactorTempHintNone);
      expect(windHint(tr, 33), tr.riskFactorWindHint(11, 25));
      expect(humidityHint(en, 18), en.riskFactorHumidityHint(25, 25));
      expect(temperatureHint(en, 36), en.riskFactorTempHint(22, 30));
    });

    test('the summary line uses the same bands', () {
      expect(riskNote(tr, temperature: 8, humidity: 85, wind: 33),
          '${tr.riskNoteCoolTemp(8)} • ${tr.riskNoteHighHumidity(85)} • ${tr.riskNoteMediumWind(33)}');
      expect(riskNote(en, temperature: 36, humidity: 25, wind: 5),
          '${en.riskNoteHighTemp(36)} • ${en.riskNoteLowHumidity(25)}');
      expect(riskNote(en, temperature: 26, humidity: 45, wind: 12), contains(en.riskNoteLightWind(12)));
    });
  });

  group('version comes from the platform', () {
    test('formatting', () {
      expect(formatAppVersion(PackageInfo(appName: 'a', packageName: 'p', version: '1.2.0', buildNumber: '5')), 'v1.2.0 (5)');
      expect(formatAppVersion(PackageInfo(appName: 'a', packageName: 'p', version: '1.2.0', buildNumber: '')), 'v1.2.0');
    });

    test('the provider reads PackageInfo, and no hard-coded version string is left', () async {
      PackageInfo.setMockInitialValues(
          appName: 'FireWatch TR', packageName: 'p', version: '1.2.0', buildNumber: '5', buildSignature: '');
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(await container.read(appVersionProvider.future), 'v1.2.0 (5)');
      expect(File('lib/l10n/app_tr.arb').readAsStringSync(), isNot(contains('v1.0.0')));
    });
  });

  group('notification permission is asked in onboarding, not before it', () {
    test('a fresh install is not prompted at startup; onboarded installs keep the old behaviour', () {
      expect(NotificationService.shouldRequestPermissionAtStartup(hasSeenOnboarding: false), isFalse);
      expect(NotificationService.shouldRequestPermissionAtStartup(hasSeenOnboarding: true), isTrue);
    });
  });

  group('position falls back to the last known fix', () {
    final now = DateTime(2026, 11, 7, 17);

    test('a fresh fix wins', () async {
      final p = await DevicePosition.current(
        getCurrent: (_) async => _position(now),
        getLastKnown: () async => fail('not needed'),
        now: () => now,
      );
      expect(p.timestamp, now);
    });

    test('on timeout a recent last-known fix is used', () async {
      final p = await DevicePosition.current(
        getCurrent: (_) async => throw TimeoutException('no fix'),
        getLastKnown: () async => _position(now.subtract(const Duration(minutes: 10)), lat: 38.33),
        now: () => now,
      );
      expect(p.latitude, 38.33);
    });

    test('a stale or missing last-known fix rethrows the original error', () async {
      await expectLater(
        DevicePosition.current(
          getCurrent: (_) async => throw TimeoutException('no fix'),
          getLastKnown: () async => _position(now.subtract(const Duration(hours: 3))),
          now: () => now,
        ),
        throwsA(isA<TimeoutException>()),
      );
      await expectLater(
        DevicePosition.current(
          getCurrent: (_) async => throw TimeoutException('no fix'),
          getLastKnown: () async => null,
          now: () => now,
        ),
        throwsA(isA<TimeoutException>()),
      );
    });

    test('only the fire report still asks Geolocator directly', () {
      final direct = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart') && f.readAsStringSync().contains('Geolocator.getCurrentPosition('))
          .map((f) => f.path.replaceAll('\\', '/'))
          .toSet();
      expect(direct, {'lib/services/device_position.dart', 'lib/shared/widgets/report_fire_panel.dart'});
    });
  });

  group('map layer bar', () {
    testWidgets('four Turkish chips at 360 dp and 1.3× text do not overflow', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3; // 360 dp wide
      addTearDown(tester.view.reset);
      Widget chip(String label) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.circle, size: 16),
              const SizedBox(width: 6),
              Text(label),
            ]),
          );
      await tester.pumpWidget(MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
        child: _app(Padding(
          padding: const EdgeInsets.all(12),
          child: Align(
            alignment: Alignment.topLeft,
            child: MapLayerBar(children: [
              chip(tr.incidentToggleShowShort),
              chip(tr.incidentToggleDetectionsShort),
              chip(tr.riskLayerToggle),
              chip(tr.annualLayerToggle),
            ]),
          ),
        )),
      ));
      expect(tester.takeException(), isNull);
      // The last chip is reachable by scrolling.
      await tester.drag(find.byType(MapLayerBar), const Offset(-2000, 0));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final last = tester.getRect(find.text(tr.annualLayerToggle));
      expect(last.left, greaterThanOrEqualTo(0));
      expect(last.right, lessThanOrEqualTo(360));
    });
  });
}
