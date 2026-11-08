import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firewatch_tr/core/constants/app_colors.dart';
import 'package:firewatch_tr/features/map/map_screen.dart';
import 'package:firewatch_tr/features/map/widgets/map_layers_panel.dart';
import 'package:firewatch_tr/features/map/widgets/map_status_card.dart';
import 'package:firewatch_tr/features/map/widgets/province_outline_layer.dart';
import 'package:firewatch_tr/l10n/app_localizations.dart';
import 'package:firewatch_tr/models/annual_province_data.dart';
import 'package:firewatch_tr/models/detection_status.dart';
import 'package:firewatch_tr/models/geo_area.dart';
import 'package:firewatch_tr/services/render_api_service.dart';
import 'package:firewatch_tr/shared/widgets/app_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _noneBody = 'Son 24 saatte uydular orman alanlarında yangın tespit etmedi.';

Widget _app(Widget child, {Locale locale = const Locale('tr'), double textScale = 1}) => MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, page) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
        child: page!,
      ),
      home: child,
    );

/// Answers the map's two backend calls.
class _Backend implements HttpClientAdapter {
  final Map<String, dynamic>? status;

  _Backend({this.status});

  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<Uint8List>? s, Future<void>? c) async {
    final isStatus = o.path.endsWith('/incidents/status');
    final failed = isStatus && status == null;
    return ResponseBody.fromString(
      jsonEncode({'data': isStatus ? status : <Object>[]}),
      failed ? 503 : 200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Map<String, dynamic> _statusJson({bool fresh = true, int strong = 0, int other = 0, Duration age = const Duration(minutes: 5)}) => {
      'pipeline_fresh': fresh,
      'strong_detections_24h': strong,
      'strong_other_24h': other,
      'last_update_at': DateTime.now().subtract(age).toUtc().toIso8601String(),
      'latest_detection': null,
    };

Future<void> _openMap(WidgetTester tester, _Backend backend, {double textScale = 1}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3; // 360 dp wide
  addTearDown(tester.view.reset);
  final dio = Dio(BaseOptions(baseUrl: 'http://x/api'))..httpClientAdapter = backend;
  await tester.pumpWidget(ProviderScope(
    child: _app(MapScreen(renderApi: RenderApiService(dio: dio)), textScale: textScale),
  ));
  // Real time passes too: the fake backend and the plugin channels answer
  // outside the test's fake clock.
  for (var i = 0; i < 12; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _closeMap(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 1));
}

List<GeoArea> _provinceAreas() {
  final doc = jsonDecode(File('assets/data/il_sinirlari.geojson').readAsStringSync()) as Map<String, dynamic>;
  final data = jsonDecode(File('assets/data/il_yil_veri.json').readAsStringSync()) as Map<String, dynamic>;
  return AnnualProvinceData.fromJson(doc, data).areas;
}

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (la > lb ? la + 0.05 : lb + 0.05) / (la > lb ? lb + 0.05 : la + 0.05);
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
    // The tile cache asks where to keep its files.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (_) async => Directory.systemTemp.path,
    );
  });

  setUp(() => SharedPreferences.setMockInitialValues({'hasSeenMapTour': true}));

  group('the map screen with an empty events layer', () {
    testWidgets('stays on events and explains itself', (tester) async {
      await _openMap(tester, _Backend(status: _statusJson()));

      expect(find.byKey(const Key('mapStatusCard')), findsOneWidget);
      expect(find.text(_noneBody), findsOneWidget);
      expect(find.textContaining('Sistem çalışıyor · Son kontrol: '), findsOneWidget);
      final call = tester.getTopLeft(find.byKey(const Key('mapStatusCall112')));
      final report = tester.getTopLeft(find.byKey(const Key('mapStatusReport')));
      expect(call.dy, lessThan(report.dy));
      // Nothing to show on the points layer, so nothing offers it.
      expect(find.byKey(const Key('mapStatusShowPoints')), findsNothing);
      expect(tester.takeException(), isNull);
      await _closeMap(tester);
    });

    testWidgets('offers the points when farmland or industry has detections', (tester) async {
      await _openMap(tester, _Backend(status: _statusJson(other: 4)));
      expect(find.text('Tarım/sanayi alanlarında 4 tespit var'), findsOneWidget);
      await tester.tap(find.byKey(const Key('mapStatusShowPoints')));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(const Key('mapStatusCard')), findsNothing);
      expect(find.byKey(const Key('systemStatusLine')), findsOneWidget);
      await _closeMap(tester);
    });

    testWidgets('old data turns the card into a warning, even if the backend calls it fresh', (tester) async {
      await _openMap(tester, _Backend(status: _statusJson(age: const Duration(hours: 3))));
      expect(find.byKey(const Key('mapStatusCard')), findsOneWidget);
      expect(find.text(_noneBody), findsNothing);
      expect(find.textContaining('çalışıyor'), findsNothing);
      expect(find.textContaining('Uydu verisi güncel değil · Son kontrol: '), findsOneWidget);
      await _closeMap(tester);
    });

    testWidgets('a failed status request is said plainly', (tester) async {
      await _openMap(tester, _Backend());
      expect(find.text('Uydu verisi alınamadı.'), findsOneWidget);
      expect(find.text(_noneBody), findsNothing);
      expect(find.byKey(const Key('mapStatusRetry')), findsOneWidget);
      await _closeMap(tester);
    });

    testWidgets('closing the card leaves the status line; Events brings it back', (tester) async {
      await _openMap(tester, _Backend(status: _statusJson()));
      await tester.tap(find.byKey(const Key('mapStatusDismiss')));
      await tester.pump();
      expect(find.byKey(const Key('mapStatusCard')), findsNothing);
      expect(find.byKey(const Key('systemStatusLine')), findsOneWidget);
      await tester.tap(find.byKey(const Key('mapModeEvents')));
      await tester.pump();
      expect(find.byKey(const Key('mapStatusCard')), findsOneWidget);
      await _closeMap(tester);
    });
  });

  group('the layer controls', () {
    for (final scale in [1.0, 1.5, 2.0]) {
      testWidgets('the top holds only Events and Points at 360 dp, text x$scale', (tester) async {
        await _openMap(tester, _Backend(status: _statusJson()), textScale: scale);
        expect(tester.takeException(), isNull);
        final bar = find.byKey(const Key('mapModeSwitch'));
        for (final label in ['Olaylar', 'Noktalar']) {
          final rect = tester.getRect(find.descendant(of: bar, matching: find.text(label)));
          expect(rect.left, greaterThanOrEqualTo(0));
          expect(rect.right, lessThanOrEqualTo(360));
        }
        expect(find.descendant(of: bar, matching: find.text('Risk')), findsNothing);
        expect(find.descendant(of: bar, matching: find.text('Geçmiş yıllar')), findsNothing);
        expect(find.descendant(of: bar, matching: find.byType(Scrollable)), findsNothing);
        await _closeMap(tester);
      });
    }

    testWidgets('Layers opens a sheet with both layers and no FWI', (tester) async {
      await _openMap(tester, _Backend(status: _statusJson()));
      await tester.tap(find.byKey(const Key('mapLayersButton')));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byKey(const Key('appSheet')), findsOneWidget);
      expect(find.byKey(const Key('mapLayersPanel')), findsOneWidget);
      expect(find.byKey(const Key('layerSwitchRisk')), findsOneWidget);
      expect(find.byKey(const Key('layerSwitchAnnual')), findsOneWidget);
      expect(find.textContaining('FWI'), findsNothing);
      expect(find.textContaining('Copernicus'), findsNothing);
      expect(tester.takeException(), isNull);
      await _closeMap(tester);
    });

    Widget panel({bool risk = false, bool annual = false, double textScale = 1}) => _app(
          Builder(
            builder: (context) => Scaffold(
              body: SingleChildScrollView(
                child: MapLayersPanel(
                  riskOn: risk,
                  riskFailed: false,
                  onToggleRisk: () {},
                  annualOn: annual,
                  annualLoading: false,
                  annualFailed: false,
                  annualYear: AnnualProvinceData.years.last,
                  annualLogMax: 4.78,
                  onToggleAnnual: () {},
                  onYearSelected: (_) {},
                  markerLegend: const SizedBox(),
                ),
              ),
            ),
          ),
          textScale: textScale,
        );

    testWidgets('open layers fit 360 dp with larger text', (tester) async {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(panel(risk: true, annual: true, textScale: 1.5));
      expect(tester.takeException(), isNull);
      for (final year in AnnualProvinceData.years) {
        final rect = tester.getRect(find.byKey(Key('layerYear-$year')));
        expect(rect.right, lessThanOrEqualTo(360));
      }
    });

    testWidgets('explanations are plain; sources are behind the link', (tester) async {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(panel(risk: true, annual: true));
      final technical = RegExp('GADM|ODbL|VIIRS|OGM|EFFIS|geoBoundaries|Logaritmik');
      final visible = find.byWidgetPredicate((w) => w is Text && technical.hasMatch(w.data ?? ''));
      expect(visible, findsNothing);
      expect(find.byKey(const Key('mapSourcesLink')), findsNWidgets(2));
      await tester.tap(find.byKey(const Key('mapSourcesLink')).last);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('mapSources')), findsOneWidget);
      expect(find.textContaining('GADM'), findsOneWidget);
    });

    test('the FWI layer has left the map code', () {
      final dir = Directory('lib/features/map');
      for (final f in dir.listSync(recursive: true).whereType<File>()) {
        final src = f.readAsStringSync();
        expect(src.contains('FWI') || src.toLowerCase().contains('ecmwf') || src.contains('FwiPoint'), isFalse, reason: f.path);
      }
      expect(File('lib/features/map/widgets/map_layer_bar.dart').existsSync(), isFalse);
    });

    test('the layers sheet goes through showAppSheet', () {
      final src = File('lib/features/map/map_screen.dart').readAsStringSync();
      expect(RegExp(r'showModalBottomSheet').hasMatch(src), isFalse);
      expect(kSheetMaxHeightFraction, lessThan(1));
    });
  });

  group('status card rule', () {
    final now = DateTime(2026, 11, 8, 12, 40);
    final fresh = DetectionStatus(kind: DetectionStatusKind.none, lastUpdateAt: now);
    bool show({
      DetectionStatus? status,
      bool events = true,
      bool loaded = true,
      int visible = 0,
      int banner = 0,
      bool color = false,
      bool dismissed = false,
    }) =>
        shouldShowMapStatusCard(
          status: status,
          now: now,
          eventsLayerOn: events,
          eventsLoaded: loaded,
          visibleEvents: visible,
          strongUnverified: banner,
          colorLayerOn: color,
          dismissed: dismissed,
        );

    test('fresh: only over an empty, loaded events layer', () {
      expect(show(status: fresh), isTrue);
      expect(show(status: fresh, visible: 2), isFalse);
      expect(show(status: fresh, loaded: false), isFalse, reason: 'no flash while events are on their way');
      expect(show(status: fresh, events: false), isFalse);
      expect(show(status: fresh, banner: 1), isFalse);
    });

    test('a data problem shows whatever is on the map', () {
      final stale = DetectionStatus(kind: DetectionStatusKind.stale, lastUpdateAt: now);
      expect(show(status: stale, visible: 5, events: false), isTrue);
      expect(show(status: DetectionStatus.unavailable, visible: 5), isTrue);
    });

    test('colour layers, closing it and no answer yet all hide it', () {
      expect(show(status: fresh, color: true), isFalse);
      expect(show(status: fresh, dismissed: true), isFalse);
      expect(show(status: null), isFalse);
    });
  });

  group('status card', () {
    final now = DateTime(2026, 11, 8, 12, 40);

    Future<void> pump(WidgetTester tester, DetectionStatus? status, {VoidCallback? onShowPoints}) async {
      await tester.pumpWidget(_app(Scaffold(
        body: SingleChildScrollView(
          child: MapStatusCard(status: status, now: now, onReport: () {}, onShowPoints: onShowPoints ?? () {}, onRetry: () {}),
        ),
      )));
    }

    testWidgets('strong detections outside the events layer are not called quiet', (tester) async {
      await pump(tester, DetectionStatus(kind: DetectionStatusKind.strong, lastUpdateAt: now, strongCount: 3));
      expect(find.text(_noneBody), findsNothing);
      expect(find.textContaining('3 güçlü tespit'), findsOneWidget);
      expect(find.byKey(const Key('mapStatusShowPoints')), findsOneWidget);
    });

    testWidgets('stale: yellow, no count, still offers the points', (tester) async {
      await pump(tester, DetectionStatus(kind: DetectionStatusKind.stale, lastUpdateAt: DateTime(2026, 11, 8, 3, 5), otherCount: 9));
      expect(find.text('Bu yüzden şu an tespit olup olmadığını söyleyemiyoruz.'), findsOneWidget);
      expect(find.textContaining('9 tespit'), findsNothing);
      expect(find.byKey(const Key('mapStatusShowPoints')), findsOneWidget);
    });

    testWidgets('no wording that reads as a fault or an all-clear', (tester) async {
      await pump(tester, DetectionStatus(kind: DetectionStatusKind.none, lastUpdateAt: now));
      for (final bad in ['Doğrulanmış yangın yok', 'yangın yok', 'söndü', 'ihtimal']) {
        expect(find.textContaining(bad), findsNothing, reason: bad);
      }
    });
  });

  group('province outline', () {
    final areas = _provinceAreas();

    Future<void> pumpMap(WidgetTester tester, double zoom) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        home: FlutterMap(
          key: ValueKey(zoom),
          options: MapOptions(initialCenter: const LatLng(39.9, 32.9), initialZoom: zoom),
          children: [ProvinceOutlineLayer(areas: areas, darkBase: false)],
        ),
      ));
      await tester.pump();
    }

    testWidgets('names appear only when zoomed in', (tester) async {
      await pumpMap(tester, 4.9);
      expect(find.text('Ankara'), findsNothing);
      expect(tester.takeException(), isNull);
      await pumpMap(tester, ProvinceOutlineLayer.labelMinZoom);
      expect(find.text('Ankara'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('masks outside Türkiye and takes no taps', (tester) async {
      await pumpMap(tester, 5);
      final mask = tester.widget<PolygonLayer<Object>>(find.byType(PolygonLayer<Object>));
      expect(mask.invertedFill, ProvinceOutlineStyle.light.mask);
      expect(mask.polygons.length, greaterThanOrEqualTo(81));
      expect(find.ancestor(of: find.byType(PolylineLayer<Object>), matching: find.byType(IgnorePointer)), findsWidgets);
    });

    test('every name sits inside its province box', () {
      expect(areas, hasLength(81));
      for (final area in areas) {
        final point = provinceLabelPoint(area);
        final box = LatLngBounds.fromPoints(area.points.toList());
        expect(box.contains(point), isTrue, reason: area.city);
      }
    });

    test('lines and names stand out on both basemaps', () {
      const darkGround = Color(0xFF262626);
      const lightGround = Color(0xFFF2EFE9);
      expect(_contrast(ProvinceOutlineStyle.dark.line, darkGround), greaterThanOrEqualTo(3));
      expect(_contrast(ProvinceOutlineStyle.light.line, lightGround), greaterThanOrEqualTo(3));
      expect(_contrast(ProvinceOutlineStyle.dark.label, darkGround), greaterThanOrEqualTo(4.5));
      expect(_contrast(ProvinceOutlineStyle.light.label, lightGround), greaterThanOrEqualTo(4.5));
      expect(ProvinceOutlineStyle.dark.line, isNot(AppColors.primary));
    });
  });
}
