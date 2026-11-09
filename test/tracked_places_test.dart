import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firewatch_tr/features/risk/widgets/tracked_places_section.dart';
import 'package:firewatch_tr/features/tracked_places/add_tracked_place_flow.dart';
import 'package:firewatch_tr/features/tracked_places/tracked_places_screen.dart';
import 'package:latlong2/latlong.dart';
import 'package:firewatch_tr/l10n/app_localizations.dart';
import 'package:firewatch_tr/models/alert_scope.dart';
import 'package:firewatch_tr/models/tracked_place.dart';
import 'package:firewatch_tr/services/alert_scope_provider.dart';
import 'package:firewatch_tr/services/notification_service.dart';
import 'package:firewatch_tr/services/place_identity.dart';
import 'package:firewatch_tr/services/tracked_places_api.dart';
import 'package:firewatch_tr/services/tracked_places_provider.dart';

/// Answers each request with the next scripted (status, body) and records it.
class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this.responder);
  final (int, Object?) Function(RequestOptions) responder;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    final (status, body) = responder(options);
    return ResponseBody.fromString(jsonEncode(body ?? {}), status, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

final _fixture = jsonDecode(File('test/fixtures/places_list.json').readAsStringSync()) as Map<String, dynamic>;

TrackedPlacesApi _api(_ScriptedAdapter adapter) => TrackedPlacesApi(
      dio: Dio(BaseOptions(baseUrl: 'https://example.test/api'))..httpClientAdapter = adapter,
      fcmToken: () async => 'fcm-token-for-tests-xxxxxxxx',
      locale: () async => 'tr',
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
    PlaceIdentity.storage = const FlutterSecureStorage();
  });

  group('TrackedPlace', () {
    test('reads the backend list contract', () {
      final places = (_fixture['data'] as List).cast<Map<String, dynamic>>().map(TrackedPlace.fromJson).toList();
      expect(places, hasLength(2));
      expect(places[0].name, 'Ev');
      expect(places[0].radiusKm, 10);
      expect(places[0].lastAlertAt, isNull);
      expect(places[1].notifyHeat, isFalse);
      expect(places[1].lastAlertAt, DateTime.utc(2026, 11, 7, 16, 30));
      final back = TrackedPlace.fromJson(places[1].toJson());
      expect(back.latitude, 36.85);
      expect(back.radiusKm, 25);
    });

    test('limits match the backend', () {
      expect(TrackedPlace.maxPlaces, 5);
      expect(TrackedPlace.radiiKm, [5, 10, 25]);
      expect(TrackedPlace.nameMaxLength, 40);
    });
  });

  group('PlaceIdentity', () {
    test('a v4 UUID and a 32-byte base64url secret, kept across reads', () async {
      final id = await PlaceIdentity.readOrCreate();
      expect(id.installId, matches(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')));
      expect(id.secret, matches(RegExp(r'^[A-Za-z0-9_-]{43}$')));
      expect(base64Url.decode('${id.secret}='), hasLength(32));
      final again = await PlaceIdentity.readOrCreate();
      expect(again.installId, id.installId);
      expect(again.secret, id.secret);
      await PlaceIdentity.clear();
      expect(await PlaceIdentity.read(), isNull);
    });
  });

  group('TrackedPlacesApi', () {
    test('registers on first use, then sends the secret as headers; coordinates only in bodies', () async {
      final adapter = _ScriptedAdapter((o) {
        if (o.path == '/places/devices') return (201, {'status': 'success'});
        if (o.method == 'POST' && o.path == '/places') {
          return (201, {'status': 'success', 'data': (_fixture['data'] as List).first});
        }
        return (200, _fixture);
      });
      final api = _api(adapter);

      final added = await api.add(name: 'Ev', latitude: 38.4234, longitude: 27.1428, radiusKm: 10);
      expect(added.name, 'Ev');

      final register = adapter.requests[0];
      expect(register.method, 'POST');
      expect(register.path, '/places/devices');
      final body = register.data as Map;
      final id = await PlaceIdentity.read();
      expect(body['install_id'], id!.installId);
      expect(body['secret'], id.secret);
      expect(body['locale'], 'tr');
      expect(body['fcm_token'], 'fcm-token-for-tests-xxxxxxxx');

      final post = adapter.requests[1];
      expect(post.headers['X-Install-Id'], id.installId);
      expect(post.headers['X-Install-Secret'], id.secret);
      expect(post.data, {'name': 'Ev', 'latitude': 38.4234, 'longitude': 27.1428, 'radius_km': 10, 'notify_heat': true, 'notify_risk': true});
      for (final r in adapter.requests) {
        expect(r.uri.query, isEmpty, reason: 'no coordinates in URLs: ${r.uri}');
      }

      await api.list();
      expect(adapter.requests.where((r) => r.path == '/places/devices'), hasLength(1), reason: 'registers once');
    });

    test('a 401 (server forgot this install) re-registers and retries once', () async {
      var listCalls = 0;
      final adapter = _ScriptedAdapter((o) {
        if (o.path == '/places/devices') return (201, {'status': 'success'});
        listCalls++;
        return listCalls == 1 ? (401, {'code': 'unauthorized'}) : (200, _fixture);
      });
      await PlaceIdentity.readOrCreate();
      await PlaceIdentity.markRegistered(true);
      final places = await _api(adapter).list();
      expect(places, hasLength(2));
      expect(adapter.requests.map((r) => '${r.method} ${r.path}').toList(),
          ['GET /places', 'POST /places/devices', 'GET /places']);
    });

    test('server errors map to what the UI says', () async {
      Future<TrackedPlacesError> errorFor(int status, Map<String, dynamic> body) async {
        final adapter = _ScriptedAdapter((o) => o.path == '/places/devices' ? (201, {}) : (status, body));
        try {
          await _api(adapter).add(name: 'x', latitude: 38, longitude: 27, radiusKm: 5);
        } on TrackedPlacesException catch (e) {
          return e.error;
        }
        fail('expected an error');
      }

      expect(await errorFor(409, {'code': 'place_limit'}), TrackedPlacesError.placeLimit);
      expect(await errorFor(422, {'code': 'outside_turkey'}), TrackedPlacesError.outsideTurkey);
      expect(await errorFor(503, {'code': 'places_unavailable'}), TrackedPlacesError.unavailable);
      expect(await errorFor(400, {'code': 'invalid_place'}), TrackedPlacesError.invalid);
    });

    test('deleteAll deletes on the server and forgets the identity', () async {
      final adapter = _ScriptedAdapter((o) => (200, {'status': 'success'}));
      await PlaceIdentity.readOrCreate();
      await PlaceIdentity.markRegistered(true);
      expect(await _api(adapter).deleteAll(), isTrue);
      expect(adapter.requests.single.method, 'DELETE');
      expect(adapter.requests.single.path, '/places/devices/me');
      expect(await PlaceIdentity.read(), isNull);
    });

    test('updateDevice refreshes a registered install (token, language); otherwise does nothing', () async {
      final adapter = _ScriptedAdapter((o) => (200, {'status': 'success'}));
      final api = _api(adapter);
      await api.updateDevice(fcmToken: 'fcm-token-new-xxxxxxxxxxxx', locale: 'en');
      expect(adapter.requests, isEmpty, reason: 'never registered: no identity is created');
      expect(await PlaceIdentity.read(), isNull);

      await PlaceIdentity.readOrCreate();
      await PlaceIdentity.markRegistered(true);
      await api.updateDevice(fcmToken: 'fcm-token-new-xxxxxxxxxxxx', locale: 'en');
      final r = adapter.requests.single;
      expect('${r.method} ${r.path}', 'PATCH /places/devices/me');
      expect(r.data, {'fcm_token': 'fcm-token-new-xxxxxxxxxxxx', 'locale': 'en'});
      expect(r.headers['X-Install-Id'], isNotNull);

      // A failing server is swallowed: app start and language change go on.
      await _api(_ScriptedAdapter((o) => (500, {}))).updateDevice(locale: 'tr');
    });

    test('deleteAll with nothing registered sends nothing', () async {
      final adapter = _ScriptedAdapter((o) => (500, {}));
      expect(await _api(adapter).deleteAll(), isTrue);
      expect(adapter.requests, isEmpty);
    });
  });

  group('TrackedPlacesNotifier', () {
    test('never registers just to learn there is nothing', () async {
      final adapter = _ScriptedAdapter((o) => (200, _fixture));
      final n = TrackedPlacesNotifier(_api(adapter));
      await n.load();
      expect(n.state.loaded, isTrue);
      expect(n.state.places, isEmpty);
      expect(adapter.requests, isEmpty);
      expect(await PlaceIdentity.read(), isNull);
    });

    test('add caches; deleteAll clears server, cache and identity', () async {
      final adapter = _ScriptedAdapter((o) {
        if (o.path == '/places/devices') return (201, {});
        if (o.method == 'POST') return (201, {'data': (_fixture['data'] as List).first});
        return (200, {'status': 'success'});
      });
      final n = TrackedPlacesNotifier(_api(adapter));
      await n.add(name: 'Ev', latitude: 38.42, longitude: 27.14, radiusKm: 10);
      final prefs = await SharedPreferences.getInstance();
      expect(TrackedPlacesNotifier.decodeCache(prefs.getString(TrackedPlacesNotifier.cacheKey)), hasLength(1));

      expect(await n.deleteAll(), isTrue);
      expect(n.state.places, isEmpty);
      expect(prefs.getString(TrackedPlacesNotifier.cacheKey), isNull);
      expect(await PlaceIdentity.read(), isNull);
    });

    test('a full list refuses before calling the server', () async {
      final five = List.generate(5, (i) => TrackedPlace(id: '$i', name: 'p$i', latitude: 38, longitude: 27, radiusKm: 5, notifyHeat: true));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(TrackedPlacesNotifier.cacheKey, jsonEncode(five.map((p) => p.toJson()).toList()));
      await PlaceIdentity.readOrCreate();
      await PlaceIdentity.markRegistered(true);
      // A garbled list response leaves the cached five in place, with an error.
      final garbled = TrackedPlacesNotifier(_api(_ScriptedAdapter((o) => (200, {}))));
      await garbled.load();
      expect(garbled.state.places, hasLength(5));
      expect(garbled.state.lastError, TrackedPlacesError.unknown);
      // The five are cached and the server agrees there are five.
      await prefs.setString(TrackedPlacesNotifier.cacheKey, jsonEncode(five.map((p) => p.toJson()).toList()));
      final adapter = _ScriptedAdapter((o) => (200, {'data': five.map((p) => p.toJson()).toList()}));
      final full = TrackedPlacesNotifier(_api(adapter));
      await full.load();
      expect(full.state.isFull, isTrue);
      await expectLater(full.add(name: 'x', latitude: 38, longitude: 27, radiusKm: 5),
          throwsA(isA<TrackedPlacesException>().having((e) => e.error, 'error', TrackedPlacesError.placeLimit)));
      expect(adapter.requests.where((r) => r.method == 'POST'), isEmpty);
    });
  });

  group('notification payloads', () {
    test('a tracked-place alert opens the map at the incident', () {
      expect(
        NotificationService.payloadForData({'type': 'place_heat', 'place_id': 'p', 'incident_id': '7', 'lat': '38.5012', 'lng': '27.2'}),
        'place:38.5012,27.2',
      );
      expect(NotificationService.payloadForData({'type': 'place_heat'}), 'alerts_tab');
      expect(NotificationService.payloadForData({'type': 'place_heat_summary', 'count': '3'}), 'places');
      expect(NotificationService.payloadForData({'fire_id': 'a_b'}), 'fire:a_b');
      expect(NotificationService.payloadForData({}), 'alerts_tab');
    });
  });

  group('1.1 "my places" scope migration (decision 1a)', () {
    test('adopts the scope the server holds', () async {
      SharedPreferences.setMockInitialValues({kAlertScopePrefsKey: 'all'});
      final notifier = AlertScopeNotifier();
      while (!notifier.state.isLoaded) {
        await Future<void>.delayed(const Duration(milliseconds: 1));
      }
      await notifier.migrateLegacyPlacesScope(() async => const ServerScope(scope: AlertScope.city, cityId: 34));
      expect(notifier.state.scope, AlertScope.city);
      expect(notifier.state.cityId, 34);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(kAlertScopePrefsKey), 'city');
    });

    test('falls back to all when the server cannot be asked', () async {
      SharedPreferences.setMockInitialValues({kAlertScopePrefsKey: 'all'});
      final notifier = AlertScopeNotifier();
      while (!notifier.state.isLoaded) {
        await Future<void>.delayed(const Duration(milliseconds: 1));
      }
      await notifier.migrateLegacyPlacesScope(() async => throw Exception('offline'));
      expect(notifier.state.scope, AlertScope.all);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(kAlertScopePrefsKey), 'all');
    });
  });

  group('TrackedPlacesSection', () {
    Widget host(TrackedPlacesApi api) => ProviderScope(
          overrides: [trackedPlacesApiProvider.overrideWithValue(api)],
          child: const MaterialApp(
            locale: Locale('tr'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: Scaffold(body: SingleChildScrollView(child: TrackedPlacesSection())),
          ),
        );

    testWidgets('empty: explains and offers to add', (tester) async {
      await tester.pumpWidget(host(_api(_ScriptedAdapter((o) => (200, _fixture)))));
      await tester.pumpAndSettle();
      expect(find.text('Yerlerim'), findsOneWidget);
      expect(find.textContaining('en fazla 5 yer'), findsOneWidget);
      expect(find.byKey(const Key('trackedPlaceAdd')), findsOneWidget);
      expect(find.text('0/5'), findsOneWidget);
    });

    testWidgets('lists the server places with radius and switch', (tester) async {
      await PlaceIdentity.readOrCreate();
      await PlaceIdentity.markRegistered(true);
      await tester.pumpWidget(host(_api(_ScriptedAdapter((o) => (200, _fixture)))));
      await tester.pumpAndSettle();
      expect(find.text('Ev'), findsOneWidget);
      expect(find.text('Yazlık'), findsOneWidget);
      expect(find.textContaining('10 km yarıçap'), findsOneWidget);
      expect(find.textContaining('Henüz uyarı yok'), findsOneWidget);
      expect(find.byType(Switch), findsNWidgets(2));
      expect(find.text('2/5'), findsOneWidget);
    });

    testWidgets('server without the feature says so', (tester) async {
      await PlaceIdentity.readOrCreate();
      await PlaceIdentity.markRegistered(true);
      await tester.pumpWidget(host(_api(_ScriptedAdapter((o) => (503, {'code': 'places_unavailable'})))));
      await tester.pumpAndSettle();
      expect(find.text('Bu özellik yakında açılacak.'), findsOneWidget);
      expect(find.byKey(const Key('trackedPlaceAdd')), findsNothing);
    });
  });

  group('AddTrackedPlaceForm', () {
    Widget host(TrackedPlacesApi api, ValueSetter<TrackedPlace?> done) => ProviderScope(
          overrides: [trackedPlacesApiProvider.overrideWithValue(api)],
          child: MaterialApp(
            locale: const Locale('tr'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () async => done(await showModalBottomSheet<TrackedPlace>(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => const AddTrackedPlaceForm(point: LatLng(38.4234, 27.1428)),
                    )),
                    child: const Text('open'),
                  ),
                ),
              ),
            ),
          ),
        );

    testWidgets('needs a name; sends name, point and chosen radius', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final adapter = _ScriptedAdapter((o) {
        if (o.path == '/places/devices') return (201, {});
        if (o.method == 'POST' && o.path == '/places') {
          return (201, {'data': {...(_fixture['data'] as List).first as Map<String, dynamic>, 'name': 'Bağ evi', 'radius_km': 25}});
        }
        return (200, _fixture);
      });
      TrackedPlace? result;
      await tester.pumpWidget(host(_api(adapter), (p) => result = p));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('trackedPlaceSave')));
      await tester.pumpAndSettle();
      expect(find.text('Bir ad girin.'), findsOneWidget);
      expect(adapter.requests, isEmpty);

      await tester.enterText(find.byKey(const Key('trackedPlaceName')), '  Bağ evi ');
      await tester.tap(find.text('25 km'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('trackedPlaceSave')));
      await tester.pumpAndSettle();

      final post = adapter.requests.singleWhere((r) => r.method == 'POST' && r.path == '/places');
      expect(post.data, {'name': 'Bağ evi', 'latitude': 38.4234, 'longitude': 27.1428, 'radius_km': 25, 'notify_heat': true, 'notify_risk': true});
      expect(result?.name, 'Bağ evi');
    });

    testWidgets('outside Turkey is shown on the form', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final adapter = _ScriptedAdapter((o) => o.path == '/places/devices' ? (201, {}) : (422, {'code': 'outside_turkey'}));
      await tester.pumpWidget(host(_api(adapter), (_) {}));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('trackedPlaceName')), 'Atina');
      await tester.tap(find.byKey(const Key('trackedPlaceSave')));
      await tester.pumpAndSettle();
      expect(find.text('Bu nokta Türkiye sınırları dışında.'), findsOneWidget);
    });
  });

  testWidgets('the summary push opens the places list; back goes home', (tester) async {
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(path: '/home', builder: (_, _) => const Scaffold(body: Text('home'))),
        GoRoute(path: '/app', builder: (_, s) => Scaffold(body: Text('app ${s.uri.query}'))),
        GoRoute(path: '/tracked-places', builder: (_, _) => const TrackedPlacesScreen()),
      ],
    );
    await tester.pumpWidget(ProviderScope(
      overrides: [trackedPlacesApiProvider.overrideWithValue(_api(_ScriptedAdapter((o) => (200, _fixture))))],
      child: MaterialApp.router(
        routerConfig: router,
        locale: const Locale('tr'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
      ),
    ));
    NotificationService.openPayload(router, NotificationService.payloadForData({'type': 'place_heat_summary', 'count': '2'}));
    await tester.pumpAndSettle();
    expect(find.byType(TrackedPlacesScreen), findsOneWidget);
    expect(find.text('Yerlerim'), findsWidgets);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.textContaining('app'), findsOneWidget);
  });
}
