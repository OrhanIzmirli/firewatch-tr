import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firewatch_tr/features/settings/settings_screen.dart';
import 'package:firewatch_tr/l10n/app_localizations.dart';
import 'package:firewatch_tr/l10n/app_localizations_en.dart';
import 'package:firewatch_tr/l10n/app_localizations_tr.dart';
import 'package:firewatch_tr/services/location_disclosure.dart';
import 'package:firewatch_tr/services/render_api_service.dart';

/// Captures the requests RenderApiService sends, answering each with [status].
class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter(this.status);
  final int status;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      jsonEncode({'status': status == 200 ? 'success' : 'error'}),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// A screen with one button that runs [onPressed] with a live context.
Widget _host(Future<void> Function(BuildContext) onPressed, {Locale locale = const Locale('tr')}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: Scaffold(
      body: Builder(
        builder: (context) => Center(
          child: ElevatedButton(
            onPressed: () => onPressed(context),
            child: const Text('go'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    LocationDisclosure.resetForTest();
  });

  group('location disclosure text matches the backend rules', () {
    // The server rounds to 2 decimals (~1 km), erases on "notifications off"
    // and on "Delete my location data", and deletes after 90 days
    // (firewatch-tr-backend utils/locationPrivacy.ts). The disclosure must
    // say exactly that, in both languages.
    final tr = AppLocalizationsTr();
    final en = AppLocalizationsEn();

    test('says the location is stored at ~1 km, not exactly', () {
      expect(tr.locDisclosureStored, contains('1 km'));
      expect(tr.locDisclosureStored, contains('saklanır'));
      expect(en.locDisclosureStored, contains('1 km'));
      expect(en.locDisclosureStored, contains('exact location is never stored'));
    });

    test('says how to delete it and the 90-day expiry', () {
      expect(tr.locDisclosureDelete, contains('Konum verimi sil'));
      expect(tr.locDisclosureDelete, contains('90 gün'));
      expect(en.locDisclosureDelete, contains('Delete my location data'));
      expect(en.locDisclosureDelete, contains('90 days'));
      expect(tr.settingsDeleteLocation, 'Konum verimi sil');
      expect(en.settingsDeleteLocation, 'Delete my location data');
    });

    test('no in-app text still claims location is never stored', () {
      for (final text in [tr.locDisclosureStored, tr.trustAlertsSource]) {
        expect(text.toLowerCase(), isNot(contains('hiç saklanmaz')));
      }
      for (final text in [en.locDisclosureStored, en.trustAlertsSource]) {
        expect(text.toLowerCase(), isNot(contains('never stored server-side')));
      }
    });
  });

  group('LocationDisclosure.ensureAccepted', () {
    testWidgets('shows the explanation, and Continue is remembered', (tester) async {
      final results = <bool>[];
      await tester.pumpWidget(_host((ctx) async => results.add(await LocationDisclosure.ensureAccepted(ctx))));

      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      expect(find.byType(LocationDisclosurePage), findsOneWidget);
      expect(find.text(AppLocalizationsTr().locDisclosureTitle), findsOneWidget);
      expect(find.textContaining('1 km'), findsWidgets);

      await tester.ensureVisible(find.byKey(const Key('locDisclosureContinue')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('locDisclosureContinue')));
      await tester.pumpAndSettle();
      expect(results, [true]);
      expect(await LocationDisclosure.isAccepted(), isTrue);

      // Second time: no sheet, straight through.
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      expect(find.byType(LocationDisclosurePage), findsNothing);
      expect(results, [true, true]);
    });

    testWidgets('Not now is not stored and is not asked again this session', (tester) async {
      final results = <bool>[];
      await tester.pumpWidget(_host((ctx) async => results.add(await LocationDisclosure.ensureAccepted(ctx))));

      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('locDisclosureNotNow')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('locDisclosureNotNow')));
      await tester.pumpAndSettle();
      expect(results, [false]);
      expect(await LocationDisclosure.isAccepted(), isFalse);

      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      expect(find.byType(LocationDisclosurePage), findsNothing);
      expect(results, [false, false]);
    });

    testWidgets('force shows it again after Not now (start monitoring)', (tester) async {
      final results = <bool>[];
      var force = false;
      await tester.pumpWidget(
        _host((ctx) async => results.add(await LocationDisclosure.ensureAccepted(ctx, force: force))),
      );

      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('locDisclosureNotNow')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('locDisclosureNotNow')));
      await tester.pumpAndSettle();

      force = true;
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      expect(find.byType(LocationDisclosurePage), findsOneWidget);
      await tester.ensureVisible(find.byKey(const Key('locDisclosureContinue')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('locDisclosureContinue')));
      await tester.pumpAndSettle();
      expect(results, [false, true]);
    });

    testWidgets('English sheet renders', (tester) async {
      await tester.pumpWidget(
        _host((ctx) => LocationDisclosure.ensureAccepted(ctx), locale: const Locale('en')),
      );
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      expect(find.text('We collect your location data'), findsOneWidget);
      expect(find.text('I agree'), findsOneWidget);
      expect(find.text('No, thanks'), findsOneWidget);
    });
  });

  group('Delete my location data', () {
    testWidgets('confirm → delete → success message', (tester) async {
      var calls = 0;
      await tester.pumpWidget(_host((ctx) => confirmAndDeleteServerLocation(
            ctx,
            AppLocalizations.of(ctx)!,
            () async {
              calls++;
              return true;
            },
          )));

      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      expect(find.text(AppLocalizationsTr().settingsDeleteLocationConfirmTitle), findsOneWidget);

      await tester.tap(find.byKey(const Key('settingsDeleteLocationConfirm')));
      await tester.pumpAndSettle();
      expect(calls, 1);
      expect(find.text(AppLocalizationsTr().settingsDeleteLocationDone), findsOneWidget);
    });

    testWidgets('cancel deletes nothing', (tester) async {
      var calls = 0;
      await tester.pumpWidget(_host((ctx) => confirmAndDeleteServerLocation(
            ctx,
            AppLocalizations.of(ctx)!,
            () async {
              calls++;
              return true;
            },
          )));

      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppLocalizationsTr().commonCancel));
      await tester.pumpAndSettle();
      expect(calls, 0);
    });

    testWidgets('a failed request says so', (tester) async {
      await tester.pumpWidget(_host((ctx) => confirmAndDeleteServerLocation(
            ctx,
            AppLocalizations.of(ctx)!,
            () async => false,
          )));

      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('settingsDeleteLocationConfirm')));
      await tester.pumpAndSettle();
      expect(find.text(AppLocalizationsTr().settingsDeleteLocationFailed), findsOneWidget);
    });

    test('RenderApiService posts the token to /notify/location/delete', () async {
      final adapter = _RecordingAdapter(200);
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api'))..httpClientAdapter = adapter;
      final api = RenderApiService(dio: dio);

      final ok = await api.deleteStoredLocation('t' * 40);

      expect(ok, isTrue);
      expect(adapter.requests, hasLength(1));
      expect(adapter.requests.single.method, 'POST');
      expect(adapter.requests.single.path, '/notify/location/delete');
      expect(adapter.requests.single.data, {'token': 't' * 40});
    });

    test('RenderApiService reports a server error as failure', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api'))..httpClientAdapter = _RecordingAdapter(500);
      expect(await RenderApiService(dio: dio).deleteStoredLocation('t' * 40), isFalse);
    });
  });
}
