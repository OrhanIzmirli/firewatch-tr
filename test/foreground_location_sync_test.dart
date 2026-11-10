import 'dart:io';

import 'package:firewatch_tr/services/alert_preference.dart';
import 'package:firewatch_tr/services/foreground_location_sync.dart';
import 'package:firewatch_tr/services/location_disclosure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final sent = <(double, double)>[];
  var position = (latitude: 38.4192, longitude: 27.1287);
  var permitted = true;

  ForegroundLocationSync sync() => ForegroundLocationSync(
        permissionGranted: () async => permitted,
        readPosition: () async => position,
        send: (lat, lng) async {
          sent.add((lat, lng));
          return true;
        },
      );

  final ready = <String, Object>{
    ForegroundLocationSync.enabledKey: true,
    LocationDisclosure.prefsKey: true,
  };

  setUp(() {
    sent.clear();
    permitted = true;
    position = (latitude: 38.4192, longitude: 27.1287);
    SharedPreferences.setMockInitialValues({});
  });

  test('sends the location rounded to two decimals', () async {
    SharedPreferences.setMockInitialValues(ready);
    expect(await sync().sync(), isTrue);
    expect(sent, [(38.42, 27.13)]);
  });

  test('the same cell is not sent twice; a new one is', () async {
    SharedPreferences.setMockInitialValues(ready);
    final s = sync();
    await s.sync();
    position = (latitude: 38.4211, longitude: 27.1302);
    expect(await s.sync(), isFalse);
    position = (latitude: 39.92, longitude: 32.85);
    expect(await s.sync(), isTrue);
    expect(sent.last, (39.92, 32.85));
  });

  test('nothing is sent without monitoring, consent, permission or alerts', () async {
    SharedPreferences.setMockInitialValues({LocationDisclosure.prefsKey: true});
    expect(await sync().sync(), isFalse, reason: 'monitoring never started');

    SharedPreferences.setMockInitialValues({ForegroundLocationSync.enabledKey: true});
    expect(await sync().sync(), isFalse, reason: 'disclosure not accepted');

    SharedPreferences.setMockInitialValues({...ready, kAlertsWantedKey: false});
    expect(await sync().sync(), isFalse, reason: 'alerts turned off');

    SharedPreferences.setMockInitialValues(ready);
    permitted = false;
    expect(await sync().sync(), isFalse, reason: 'permission removed');
    expect(sent, isEmpty);
  });

  test('deleting the location stops the updates', () async {
    SharedPreferences.setMockInitialValues(ready);
    await sync().sync();
    await ForegroundLocationSync.disable();
    expect(await sync().sync(), isFalse);
    expect(sent, hasLength(1));
  });

  test('after the server erased the location the same cell is sent again', () async {
    SharedPreferences.setMockInitialValues(ready);
    await sync().sync();
    await ForegroundLocationSync.forgetLastCell();
    expect(await sync().sync(), isTrue);
    expect(sent, hasLength(2));
  });

  test('a failed send is retried next time', () async {
    SharedPreferences.setMockInitialValues(ready);
    final failing = ForegroundLocationSync(
      permissionGranted: () async => true,
      readPosition: () async => position,
      send: (lat, lng) async => false,
    );
    expect(await failing.sync(), isFalse);
    expect(await sync().sync(), isTrue);
  });

  group('no background location is left', () {
    final source = {
      for (final f in Directory('lib').listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart')))
        f.path: f.readAsStringSync(),
    };

    test('the manifest does not ask for it', () {
      expect(File('android/app/src/main/AndroidManifest.xml').readAsStringSync(), isNot(contains('ACCESS_BACKGROUND_LOCATION')));
    });

    test('no code asks for it or schedules a location check', () {
      for (final entry in source.entries) {
        expect(entry.value, isNot(contains('locationAlways')), reason: entry.key);
        expect(entry.value, isNot(contains('registerPeriodicTask')), reason: entry.key);
      }
    });

    test('the sync never raises a prompt', () {
      final sync = File('lib/services/foreground_location_sync.dart').readAsStringSync();
      expect(sync, isNot(contains('.requestPermission')));
    });

    test('the in-app scan does not run behind the screen', () {
      final monitor = File('lib/services/fire_monitoring_service.dart').readAsStringSync();
      expect(monitor, contains('AppLifecycleState.resumed'));
    });

    test('the location updates are tied to the app coming to the front', () {
      final main = File('lib/main.dart').readAsStringSync();
      expect(main, contains('onResume'));
      expect(main, contains('ForegroundLocationSync.instance.sync()'));
    });
  });
}
