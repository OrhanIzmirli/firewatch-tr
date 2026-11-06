import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:firewatch_tr/models/annual_province_data.dart';
import 'package:firewatch_tr/features/map/widgets/annual_province_layer.dart';

void main() {
  final geometry =
      jsonDecode(File('assets/data/il_sinirlari.geojson').readAsStringSync())
          as Map<String, dynamic>;
  final values =
      jsonDecode(File('assets/data/il_yil_veri.json').readAsStringSync())
          as Map<String, dynamic>;
  final data = AnnualProvinceData.fromJson(geometry, values);

  test('All 81 provinces join by plate across 2016–2025', () {
    expect(data.areas.length, 81);
    expect(data.areas.map((a) => a.id).toSet(), data.provinces.keys.toSet());
    for (final area in data.areas) {
      for (final year in AnnualProvinceData.years) {
        for (final key in [
          'ogm_yanan_alan_ha',
          'ogm_yangin_sayisi',
          'uydu_orman_maki_noktasi',
          'effis_yanan_alan_ha',
        ]) {
          expect(
            data.value(area.id, year, key),
            isNotNull,
            reason: '${area.id}/$year/$key',
          );
        }
      }
    }
    expect(data.value('01', 2021, 'ogm_yanan_alan_ha'), 4919.3);
    expect(data.value('01', 2025, 'ogm_yanan_alan_ha'), 586);
    expect(data.color('01', 2021), isNot(data.color('01', 2025)));
  });

  test('Missing data stays transparent and zero stays a real value', () {
    const sample = AnnualProvinceData(
      [],
      {
        '01': {
          'yillar': {
            '2025': {'ogm_yanan_alan_ha': 0},
          },
        },
        '02': {
          'yillar': {
            '2025': {'ogm_yanan_alan_ha': 1e9},
          },
        },
      },
      4.7808,
      'test',
    );
    expect(sample.color('99', 2025), Colors.transparent);
    expect(
      sample.color('01', 2025),
      AnnualProvinceData.stops.first.withValues(alpha: .8),
    );
    expect(
      sample.color('02', 2025),
      AnnualProvinceData.stops.last.withValues(alpha: .8),
    );
    expect(sample.value('01', 2024, 'ogm_yanan_alan_ha'), isNull);
  });

  testWidgets('Local assets load without a network service', (tester) async {
    final bundled = await tester.runAsync(() => AnnualProvinceData.load());
    expect(bundled!.areas.length, 81);
    expect(bundled.value('01', 2021, 'ogm_yangin_sayisi'), 126);
  });

  testWidgets('Province details fit a narrow phone with readable values', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: AnnualProvinceDetails(
            data: data,
            area: data.areas.first,
            year: 2021,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Adana'), findsOneWidget);
    expect(find.text('4.919,3 ha'), findsOneWidget);
    expect(find.text('126'), findsOneWidget);
    expect(find.text('293'), findsOneWidget);
    expect(find.text('6.076 ha'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Current markers remain tappable above the province layer', (
    tester,
  ) async {
    final square = AnnualProvinceData.fromJson({
      'features': [
        {
          'properties': {'plaka': '01', 'il': 'Adana'},
          'geometry': {
            'type': 'Polygon',
            'coordinates': [
              [
                [30, 35],
                [40, 35],
                [40, 45],
                [30, 45],
                [30, 35],
              ],
            ],
          },
        },
      ],
    }, values);
    var markerTaps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(39, 35),
              initialZoom: 5,
            ),
            children: [
              AnnualProvinceLayer(data: square, year: 2021),
              MarkerLayer(
                markers: [
                  Marker(
                    point: const LatLng(39, 35),
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () => markerTaps++,
                      child: const ColoredBox(
                        key: Key('current-marker'),
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('current-marker')));
    await tester.pumpAndSettle();
    expect(markerTaps, 1);
    expect(find.byType(AnnualProvinceDetails), findsNothing);
    await tester.tapAt(
      tester.getCenter(find.byType(FlutterMap)) + const Offset(80, 0),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AnnualProvinceDetails), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
