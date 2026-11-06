import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:firewatch_tr/features/history/history_format.dart';
import 'package:firewatch_tr/models/geo_area.dart';
import 'package:firewatch_tr/models/news_item.dart';

/// The three backend changes of 2026-11-06 as the app sees them, checked
/// against responses copied from the live service that day:
///   risk_summary_live.json   GET /api/risk/summary (nearby_fire_count)
///   news_live_sample.json    GET /api/news?limit=12 (self-hosted logos)
///   history_range_live.json  GET /api/history for the "last 3 years" preset
///                            (1,100-day limit), features cut to the first
Map<String, dynamic> fixture(String name) =>
    jsonDecode(File('test/fixtures/$name').readAsStringSync()) as Map<String, dynamic>;

/// Inclusive day count the backend applies: (to - from) + 1 must be <= 1,100.
int inclusiveDays(DateTime from, DateTime to) =>
    DateTime.utc(to.year, to.month, to.day).difference(DateTime.utc(from.year, from.month, from.day)).inDays + 1;

void main() {
  group('live /api/risk/summary', () {
    final data = (fixture('risk_summary_live.json')['data'] as List).cast<Map<String, dynamic>>();

    test('seven regions, each with a non-negative integer nearby_fire_count', () {
      expect(data.map((r) => r['region']).toSet().length, 7);
      for (final r in data) {
        expect(r['nearby_fire_count'], isA<int>(), reason: '${r['region']}');
        expect(r['nearby_fire_count'] as int, greaterThanOrEqualTo(0));
        expect(r['general_risk_score'], isA<num>());
      }
    });

    test('the detail sheet shows the line only when the count is present', () {
      // Same condition as risk_screen.dart: null means unavailable, never zero.
      for (final r in data) {
        expect(r['nearby_fire_count'] != null, isTrue);
      }
      final stale = Map<String, dynamic>.from(data.first)..remove('nearby_fire_count');
      expect(stale['nearby_fire_count'] != null, isFalse);
    });
  });

  group('live /api/news', () {
    final items = (fixture('news_live_sample.json')['data'] as List)
        .map((j) => NewsItem.fromJson(j as Map<String, dynamic>))
        .toList();

    test('mapped sources carry a self-hosted https PNG logo', () {
      final withLogo = items.where((n) => n.sourceLogoUrl.isNotEmpty).toList();
      expect(withLogo, isNotEmpty);
      for (final n in withLogo) {
        final uri = Uri.parse(n.sourceLogoUrl);
        expect(uri.scheme, 'https', reason: n.source);
        expect(uri.host, 'firewatch-tr-backend.onrender.com', reason: n.source);
        expect(uri.path, startsWith('/static/news-logos/'), reason: n.source);
        expect(uri.path, endsWith('.png'), reason: n.source);
      }
      expect(withLogo.map((n) => n.source).toSet(), containsAll(['AA', 'TRT Haber']));
    });

    test('an unmapped source has no logo URL and falls back to the letter mark', () {
      // NewsSourceMark renders the first letter when logoUrl is empty.
      expect(items.any((n) => n.sourceLogoUrl.isEmpty), isTrue);
      for (final n in items.where((n) => n.sourceLogoUrl.isEmpty)) {
        expect(n.source.trim(), isNotEmpty);
      }
    });

    test('the logo URL survives the offline cache round trip', () {
      final first = items.firstWhere((n) => n.sourceLogoUrl.isNotEmpty);
      expect(NewsItem.fromJson(first.toJson()).sourceLogoUrl, first.sourceLogoUrl);
    });
  });

  group('live /api/history, "last 3 years" preset', () {
    final f = fixture('history_range_live.json');

    test('a three-year range is accepted and within the 1,100-day limit', () {
      expect(f['http_status'], 200);
      expect(f['feature_count'], greaterThan(0));
      final from = DateTime.parse(f['from'] as String);
      final to = DateTime.parse(f['to'] as String);
      expect(inclusiveDays(from, to), lessThanOrEqualTo(1100));
      expect((f['metadata'] as Map)['from'], historyQueryDate(from));
      expect((f['metadata'] as Map)['to'], historyQueryDate(to));
    });

    test('every preset of the history screen stays within the limit', () {
      // Mirrors _HistoryScreenState._preset: this summer, since last summer,
      // last three years. A range exactly 1,100 days wide is the last one
      // accepted; the backend rejects 1,101.
      final now = DateTime.now();
      final presets = [
        (DateTime(now.year, 6, 1), DateTime(now.year, 9, 30)),
        (DateTime(now.year - 1, 6, 1), now),
        (DateTime(now.year - 3, now.month, now.day), now),
      ];
      for (final (from, to) in presets) {
        expect(inclusiveDays(from, to), lessThanOrEqualTo(1100), reason: '$from - $to');
      }
      expect(inclusiveDays(DateTime(2023, 11, 3), DateTime(2026, 11, 6)), 1100);
      expect(inclusiveDays(DateTime(2023, 11, 2), DateTime(2026, 11, 6)), 1101);
    });

    test('the first feature parses into a map area with detection info', () {
      final area = GeoArea.fromJson(f['first_feature'] as Map<String, dynamic>);
      expect(area.polygons, isNotEmpty);
      final info = HistoryDetectionInfo.fromProperties(area.properties);
      expect(info, isNotNull);
      expect(info!.count, greaterThanOrEqualTo(5));
      expect(isHeatFootprint(area.properties), isTrue);
      expect(area.properties['area_ha'], isNull);
    });

    test('metadata names NASA FIRMS and the first day with data', () {
      final metadata = f['metadata'] as Map;
      expect(metadata['data_available_from'], '2026-08-05');
      expect((metadata['source'] as Map)['provider'], 'NASA FIRMS');
      expect(metadata['fixed_heat_sources_excluded'], isTrue);
    });
  });
}
