import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:firewatch_tr/features/tracked_places/add_tracked_place_flow.dart';
import 'package:firewatch_tr/features/tracked_places/place_search_screen.dart';
import 'package:firewatch_tr/l10n/app_localizations.dart';
import 'package:firewatch_tr/models/tracked_place.dart';
import 'package:firewatch_tr/services/place_identity.dart';
import 'package:firewatch_tr/services/tracked_places_api.dart';
import 'package:firewatch_tr/services/tracked_places_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Adapter implements HttpClientAdapter {
  _Adapter(this.responder);
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

TrackedPlacesApi _api(_Adapter a) => TrackedPlacesApi(
      dio: Dio(BaseOptions(baseUrl: 'https://example.test/api'))..httpClientAdapter = a,
      fcmToken: () async => 'fcm-token-for-tests-xxxxxxxx',
      locale: () async => 'tr',
    );

const _place = TrackedPlace(id: 'a', name: 'Ev', latitude: 38.30, longitude: 26.77, radiusKm: 10, notifyHeat: true);

Map<String, dynamic> _json({String name = 'Ev', int radius = 10, bool heat = true, bool risk = true}) => {
      'id': 'a',
      'name': name,
      'latitude': 38.30,
      'longitude': 26.77,
      'radius_km': radius,
      'notify_heat': heat,
      'notify_risk': risk,
    };

Widget _host(TrackedPlacesApi api, Widget child) => ProviderScope(
      overrides: [trackedPlacesApiProvider.overrideWithValue(api)],
      child: MaterialApp(
        locale: const Locale('tr'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: child,
      ),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
    PlaceIdentity.storage = const FlutterSecureStorage();
    await PlaceIdentity.readOrCreate();
    await PlaceIdentity.markRegistered(true);
  });

  test('radius is measured in kilometres around the place', () {
    expect(_place.isWithinRadius(38.30, 26.77), isTrue);
    expect(_place.isWithinRadius(38.30 + 9 / 111.32, 26.77), isTrue);
    expect(_place.isWithinRadius(38.30 + 11 / 111.32, 26.77), isFalse);
  });

  test('a place from an older server counts the risk switch as on', () {
    expect(TrackedPlace.fromJson({'id': 'a', 'name': 'x', 'latitude': 38, 'longitude': 27, 'radius_km': 5}).notifyRisk, isTrue);
  });

  test('update sends only what changed', () async {
    final a = _Adapter((_) => (200, {'data': _json(name: 'Yazlık')}));
    final updated = await _api(a).update('a', name: 'Yazlık');
    expect(updated.name, 'Yazlık');
    expect(a.requests.single.data, {'name': 'Yazlık'});
    expect(a.requests.single.method, 'PATCH');
  });

  test('search puts the text in the body, never the URL, and needs no device', () async {
    await PlaceIdentity.clear();
    final a = _Adapter((_) => (200, {
          'data': [
            {'name': 'Zeytinalanı', 'label': 'Zeytinalanı, Urla, İzmir', 'latitude': 38.36, 'longitude': 26.83}
          ]
        }));
    final results = await _api(a).search('Urla Zeytinalanı');
    expect(results.single.name, 'Zeytinalanı');
    final r = a.requests.single;
    expect(r.method, 'POST');
    expect(r.path, '/places/search');
    expect(r.uri.query, isEmpty);
    expect(r.data, {'q': 'Urla Zeytinalanı'});
    expect(r.headers.containsKey('X-Install-Id'), isFalse);
  });

  group('search screen', () {
    (int, Object?) found(RequestOptions _) => (200, {
          'data': [
            {'name': 'Zeytinalanı', 'label': 'Zeytinalanı, Urla, İzmir', 'latitude': 38.36, 'longitude': 26.83}
          ]
        });

    Future<void> search(WidgetTester tester, String text) async {
      await tester.enterText(find.byKey(const Key('placeSearchField')), text);
      await tester.tap(find.byKey(const Key('placeSearchButton')));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 500)));
      await tester.pumpAndSettle();
    }

    testWidgets('typing sends nothing; only the button searches', (tester) async {
      final a = _Adapter(found);
      await tester.pumpWidget(_host(_api(a), const PlaceSearchScreen()));
      await tester.enterText(find.byKey(const Key('placeSearchField')), 'Urla Zeytinalanı');
      await tester.pump(const Duration(seconds: 2));
      expect(a.requests, isEmpty);
    });

    testWidgets('a district stays on the phone, an address goes to the server', (tester) async {
      final a = _Adapter(found);
      await tester.pumpWidget(_host(_api(a), const PlaceSearchScreen()));
      await search(tester, 'Urla');
      expect(find.text('Urla'), findsWidgets);
      expect(a.requests, isEmpty);

      await search(tester, 'Urla Zeytinalanı');
      expect(a.requests.single.data, {'q': 'Urla Zeytinalanı'});
      expect(find.text('Zeytinalanı'), findsOneWidget);
      expect(find.byKey(const Key('placeSearchAttribution')), findsOneWidget);
    });

    testWidgets('a failed search says so and leaves the map option', (tester) async {
      final a = _Adapter((_) => (502, {'code': 'search_failed'}));
      await tester.pumpWidget(_host(_api(a), const PlaceSearchScreen()));
      await search(tester, 'Bilinmeyen Sokak');
      expect(find.byKey(const Key('placeSearchMessage')), findsOneWidget);
      expect(find.byKey(const Key('trackedSourceMap')), findsOneWidget);
    });
  });

  group('settings form', () {
    Widget form(TrackedPlacesApi api) => _host(
          api,
          Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => const AddTrackedPlaceForm(point: LatLng(38.30, 26.77), existing: _place),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        );

    void bigScreen(WidgetTester tester) {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    testWidgets('rename sends just the name', (tester) async {
      bigScreen(tester);
      final a = _Adapter((_) => (200, {'data': _json(name: 'Yazlık')}));
      await tester.pumpWidget(form(_api(a)));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Yeri düzenle'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('trackedPlaceName')), 'Yazlık');
      await tester.tap(find.byKey(const Key('trackedPlaceSave')));
      await tester.pumpAndSettle();
      expect(a.requests.single.data, {'name': 'Yazlık'});
    });

    testWidgets('each switch can be set on its own', (tester) async {
      bigScreen(tester);
      final a = _Adapter((_) => (200, {'data': _json(risk: false)}));
      await tester.pumpWidget(form(_api(a)));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('trackedNotifyRisk')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('trackedPlaceSave')));
      await tester.pumpAndSettle();
      expect(a.requests.single.data, {'notify_risk': false});
    });

    testWidgets('delete asks first', (tester) async {
      bigScreen(tester);
      final a = _Adapter((_) => (200, {'data': {'deleted': true}}));
      await tester.pumpWidget(form(_api(a)));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('trackedPlaceDelete')));
      await tester.pumpAndSettle();
      expect(a.requests, isEmpty);
      await tester.tap(find.byKey(const Key('trackedPlaceDeleteConfirm')));
      await tester.pumpAndSettle();
      expect(a.requests.single.method, 'DELETE');
    });
  });
}
