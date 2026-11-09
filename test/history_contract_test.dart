import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:firewatch_tr/features/history/history_format.dart';
import 'package:firewatch_tr/models/geo_area.dart';

/// Contract with GET /api/history. The fixture is three features copied
/// from the live response (2026-11-06, from=2023-11-06&to=2026-11-06): the
/// smallest Polygon and the two smallest MultiPolygons, unedited.
void main() {
  final live = jsonDecode(File('test/fixtures/history_live_sample.json').readAsStringSync()) as Map<String, dynamic>;

  test('live response parses into map areas', () {
    final areas = GeoArea.collection(live);
    expect(areas.length, 3);
    expect(areas.map((a) => a.polygons.isNotEmpty), everyElement(isTrue));
    for (final a in areas) {
      expect(a.city, isNotEmpty);
      expect(a.district, isNotEmpty);
    }
  });

  test('numeric and text feature ids are both accepted', () {
    final areas = GeoArea.collection(live);
    expect(areas.first.id, '${(live['features'] as List).first['id']}');
    final textId = GeoArea.fromJson({'id': 'history-demo-1', 'properties': {}, 'geometry': {
      'type': 'Polygon', 'coordinates': [[[27, 38], [28, 38], [28, 39], [27, 38]]]}});
    expect(textId.id, 'history-demo-1');
  });

  test('satellite records carry detections instead of an area', () {
    for (final f in (live['features'] as List).cast<Map<String, dynamic>>()) {
      final p = Map<String, dynamic>.from(f['properties'] as Map);
      expect(p['area_ha'], isNull);
      final info = HistoryDetectionInfo.fromProperties(p);
      expect(info, isNotNull);
      expect(info!.count, greaterThanOrEqualTo(5));
      expect(info.durationHours, isNotNull);
      expect(isHeatFootprint(p), isTrue);
      expect(isNearestDistrict(p), isTrue);
      expect(p['source'], 'NASA FIRMS');
    }
  });

  test('sample records have no detection info and keep their area', () {
    final p = {'area_ha': 2000, 'date_start': '2026-07-10'};
    expect(HistoryDetectionInfo.fromProperties(p), isNull);
    expect(isHeatFootprint(p), isFalse);
    expect(isNearestDistrict(p), isFalse);
  });

  test('provenance is NASA FIRMS, never EFFIS', () {
    final source = (live['metadata'] as Map)['source'] as Map;
    expect(source['provider'], 'NASA FIRMS');
    expect(jsonEncode(live), isNot(contains('EFFIS')));
  });

  test('query dates are plain calendar days', () {
    expect(historyQueryDate(DateTime(2026, 6, 1)), '2026-06-01');
    expect(historyQueryDate(DateTime(2026, 11, 6, 23, 59)), '2026-11-06');
    expect(historyQueryDate(DateTime(987, 1, 2)), '0987-01-02');
  });

  test('hours are shown with one decimal below ten, whole above', () {
    expect(formatHours(0), '0.0');
    expect(formatHours(7.34), '7.3');
    expect(formatHours(41.1), '41');
  });
}
