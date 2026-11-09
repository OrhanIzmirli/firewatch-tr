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
import 'package:firewatch_tr/l10n/app_localizations.dart';
import 'package:firewatch_tr/l10n/app_localizations_en.dart';
import 'package:firewatch_tr/l10n/app_localizations_tr.dart';
import 'package:firewatch_tr/models/fire_incident.dart';
import 'package:firewatch_tr/models/geo_area.dart';
import 'package:firewatch_tr/models/news_item.dart';
import 'package:firewatch_tr/services/app_version.dart';
import 'package:firewatch_tr/services/device_position.dart';
import 'package:firewatch_tr/services/fire_api_service.dart';
import 'package:firewatch_tr/services/notification_service.dart';
import 'package:firewatch_tr/features/map/widgets/incident_legend.dart';
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

    testWidgets('old satellite data: a recent incident reads as last known', (tester) async {
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
      await tester.pumpWidget(_app(IncidentSheet(incident: incident, cityName: 'Antalya', outdated: true)));
      await tester.pumpAndSettle();
      expect(find.text(tr.incidentStatusLastKnown), findsOneWidget);
      expect(find.text(tr.incidentStatusActive), findsNothing);

      await tester.pumpWidget(_app(IncidentSheet(incident: incident, cityName: 'Antalya')));
      await tester.pumpAndSettle();
      expect(find.text(tr.incidentStatusActive), findsOneWidget);
    });

    testWidgets('the map legend follows the same rule', (tester) async {
      await tester.pumpWidget(_app(const IncidentLegend(outdated: true)));
      await tester.pumpAndSettle();
      expect(find.text('Son bilinen tespit'), findsOneWidget);
      expect(find.text('Güncel tespit'), findsNothing);
      expect(IncidentStatus.lowConfidence.label(tr, outdated: true), IncidentStatus.lowConfidence.label(tr));
      expect(IncidentStatus.activeDetection.label(en, outdated: true), 'Last known detection');

      await tester.pumpWidget(_app(const IncidentLegend()));
      await tester.pumpAndSettle();
      expect(find.text('Güncel tespit'), findsOneWidget);
    });

    test('the map passes the data age to the legend and the sheet', () {
      final map = File('lib/features/map/map_screen.dart').readAsStringSync();
      expect(map, contains('IncidentLegend(outdated: detectionsOutdated('));
      expect(map, contains(RegExp(r'cityName: _cityNameFor\(incident\),\s+outdated: detectionsOutdated\(')));
    });

    test('every map detail view embeds the shared notice', () {
      for (final path in [
        'lib/features/map/widgets/incident_sheet.dart', // event
        'lib/features/map/map_screen.dart', // single detection sheet
        'lib/features/fire_detail/fire_detail_screen.dart', // detection detail
      ]) {
        expect(File(path).readAsStringSync(), contains('DetectionSafetyNotice('), reason: path);
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

  group('general scan fixes', () {
    test('background monitoring initialises Firebase before the notification service', () {
      final src = File('lib/services/background_task_service.dart').readAsStringSync();
      final init = src.indexOf('Firebase.initializeApp(');
      expect(init, greaterThan(0));
      expect(init, lessThan(src.indexOf('NotificationService.instance.initializeLocal()')));
      // The service no longer touches Firebase when constructed.
      expect(File('lib/services/notification_service.dart').readAsStringSync(),
          contains('FirebaseMessaging get _fcm => FirebaseMessaging.instance;'));
    });

    test('FCM listeners are registered before any network call', () {
      final src = File('lib/services/notification_service.dart').readAsStringSync();
      final setup = src.substring(
          src.indexOf('Future<void> _setupFirebaseMessaging()'), src.indexOf('Future<void> _registerToken()'));
      final listen = setup.indexOf('FirebaseMessaging.onMessage.listen');
      expect(listen, greaterThan(0));
      expect(listen, lessThan(setup.indexOf('getInitialMessage()')));
      expect(listen, lessThan(setup.indexOf('_registerToken')));
      expect(setup.indexOf('_fcm.getToken()'), -1, reason: 'token fetch lives in _registerToken');
    });

    test('one malformed history feature is skipped, not fatal', () {
      final good = {
        'id': 1,
        'properties': {'city': 'Şanlıurfa', 'district': 'Siverek'},
        'geometry': {
          'type': 'Polygon',
          'coordinates': [
            [[39.0, 37.0], [39.1, 37.0], [39.1, 37.1], [39.0, 37.0]]
          ],
        },
      };
      final bad = {'id': 2, 'properties': {}, 'geometry': {'type': 'Point', 'coordinates': [39.0, 37.0]}};
      final areas = GeoArea.collection({'features': [good, bad, {'id': 3}]});
      expect(areas.map((a) => a.id), ['1']);
    });

    test('the featured "today" label only for items from the last 24 h', () {
      NewsItem item(String at) => NewsItem.fromJson({'id': 1, 'title': 't', 'published_at': at});
      final now = DateTime.utc(2026, 11, 7, 12);
      expect(item('2026-11-07T08:00:00Z').publishedWithin(const Duration(hours: 24), now: now), isTrue);
      expect(item('2026-10-25T08:00:00Z').publishedWithin(const Duration(hours: 24), now: now), isFalse);
      expect(item('').publishedWithin(const Duration(hours: 24), now: now), isFalse);
    });
  });

  group('thermal CSV', () {
    test('parsed off the UI thread, with duplicates merged and sea points dropped', () {
      expect(File('lib/services/fire_api_service.dart').readAsStringSync(), contains('compute(parseThermalCsv, raw)'));
      final csv = [
        'latitude,longitude,bright_ti4,confidence,instrument,acq_date,acq_time,frp',
        '36.90000,30.70000,340,h,VIIRS,2026-11-07,1030,12', // Antalya
        '36.90100,30.70100,330,n,MODIS,2026-11-07,1100,8', // 140 m away: same fire
        '36.95000,30.70000,320,n,VIIRS,2026-11-07,1030,5', // 5.5 km away: separate
        '35.00000,30.00000,330,h,VIIRS,2026-11-07,1030,9', // open sea
      ].join('\n');
      final points = FireApiService.parseThermalCsv(csv);
      expect(points, hasLength(2));
      expect(points.first.isMerged, isTrue);
    });
  });

  group('environmental factor cards', () {
    test('bands come from risk_factors.dart and an index of 21 is low', () {
      expect(indexBandLabel(tr, 21), tr.commonLow);
      expect([24, 25, 50, 75].map((v) => indexBandLabel(tr, v)),
          [tr.commonLow, tr.commonMedium, tr.commonHigh, tr.riskDrynessVeryHigh]);
      expect([19, 20, 35].map((v) => windBandLabel(tr, v)), [tr.commonLow, tr.commonMedium, tr.commonHigh]);
      expect([30, 50, 71].map((v) => humidityBandLabel(tr, v)), [tr.commonLow, tr.commonMedium, tr.commonHigh]);
      final src = File('lib/features/risk/risk_screen.dart').readAsStringSync();
      expect(RegExp(r'_avg(Dryness|Wind|Vegetation|Humidity) >=').hasMatch(src), isFalse);
    });
  });
}
