import 'dart:async';
import 'dart:convert';

import 'package:firewatch_tr/core/utils/auto_refresh.dart';
import 'package:firewatch_tr/models/fire_point.dart';
import 'package:firewatch_tr/services/fire_api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

FirePoint _p(double lat) => FirePoint(
      latitude: lat,
      longitude: 30.7,
      brightness: '330',
      confidence: 'h',
      satellite: 'VIIRS',
      acquisitionDate: '2026-08-10',
      acquisitionTime: '1100',
    );

const _antalya = NearestCityResult(
  outsideTurkey: false,
  city: 'Antalya',
  region: 'Akdeniz',
  distanceKm: 3.2,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NearestCityMemo', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('key is the fire pixel rounded to 2 decimals', () {
      expect(NearestCityMemo.keyFor(36.8969, 30.7133), '36.90_30.71');
    });

    test('entries expire after 30 days', () {
      var now = DateTime(2026, 11, 7);
      final memo = NearestCityMemo(clock: () => now);
      memo.put('k', _antalya);
      now = now.add(const Duration(days: 30));
      expect(memo.get('k')?.city, 'Antalya');
      now = now.add(const Duration(minutes: 1));
      expect(memo.get('k'), isNull);
      expect(memo.length, 0);
    });

    test('capped at 1500 entries, oldest dropped first', () {
      final memo = NearestCityMemo();
      for (var i = 0; i < NearestCityMemo.maxEntries + 10; i++) {
        memo.put('k$i', _antalya);
      }
      expect(memo.length, NearestCityMemo.maxEntries);
      expect(memo.get('k0'), isNull);
      expect(memo.get('k9'), isNull);
      expect(memo.get('k10'), isNotNull);
    });

    test('persists under the v2 key and reloads, outside-Turkey included', () async {
      final now = DateTime(2026, 11, 7);
      final a = NearestCityMemo(clock: () => now)
        ..put('a', _antalya)
        ..put('b', const NearestCityResult(outsideTurkey: true));
      await a.persist();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(NearestCityMemo.prefsKey), isNotNull);

      final b = NearestCityMemo(clock: () => now);
      await b.load();
      expect(b.get('a')?.city, 'Antalya');
      expect(b.get('a')?.distanceKm, 3.2);
      expect(b.get('b')?.outsideTurkey, isTrue);
    });

    test('v1 entries from 1.0.6 are deleted, never read', () async {
      SharedPreferences.setMockInitialValues({
        NearestCityMemo.legacyPrefsKey: jsonEncode({
          '37.50_38.90': {'c': 'Şanlıurfa', 'r': 'Güneydoğu'},
        }),
      });
      final memo = NearestCityMemo();
      await memo.load();
      expect(memo.length, 0);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey(NearestCityMemo.legacyPrefsKey), isFalse);
    });

    test('stored entries older than 30 days are skipped on load', () async {
      final now = DateTime(2026, 11, 7);
      SharedPreferences.setMockInitialValues({
        NearestCityMemo.prefsKey: jsonEncode({
          'old': {
            'c': 'Antalya',
            'r': 'Akdeniz',
            't': now.subtract(const Duration(days: 31)).millisecondsSinceEpoch,
          },
          'new': {
            'c': 'Muğla',
            'r': 'Ege',
            't': now.subtract(const Duration(days: 1)).millisecondsSinceEpoch,
          },
        }),
      });
      final memo = NearestCityMemo(clock: () => now);
      await memo.load();
      expect(memo.get('old'), isNull);
      expect(memo.get('new')?.city, 'Muğla');
    });

    test('a corrupt stored memo is ignored', () async {
      SharedPreferences.setMockInitialValues({NearestCityMemo.prefsKey: '{nope'});
      final memo = NearestCityMemo();
      await memo.load();
      expect(memo.length, 0);
    });
  });

  group('feed memo', () {
    final api = FireApiService();
    late int calls;

    setUp(() {
      calls = 0;
      api.clearFeedMemo();
      api.feedFetcherForTest = () async {
        calls++;
        return [_p(36.9)];
      };
    });
    tearDown(() {
      api.feedFetcherForTest = null;
      api.clearFeedMemo();
    });

    test('a second call within 2 minutes reuses the response', () async {
      await api.fetchTurkeyFires();
      await api.fetchTurkeyFires();
      expect(calls, 1);
      expect(FireApiService.feedMemoTtl, const Duration(minutes: 2));
    });

    test('concurrent callers share one request', () async {
      final c = Completer<List<FirePoint>>();
      api.feedFetcherForTest = () {
        calls++;
        return c.future;
      };
      final a = api.fetchTurkeyFires();
      final b = api.fetchTurkeyFires();
      c.complete([_p(1)]);
      expect((await a).length, 1);
      expect((await b).length, 1);
      expect(calls, 1);
    });

    test('force always goes to the network', () async {
      await api.fetchTurkeyFires();
      await api.fetchTurkeyFires(force: true);
      expect(calls, 2);
    });

    test('a failed fetch is not memoised', () async {
      api.feedFetcherForTest = () async {
        calls++;
        throw Exception('offline');
      };
      await expectLater(api.fetchTurkeyFires(), throwsException);
      await expectLater(api.fetchTurkeyFires(), throwsException);
      expect(calls, 2);
    });
  });

  group('AutoRefresher', () {
    test('parses the settings values, falls back to 15', () {
      expect(AutoRefresher.parseMinutes('5 dk'), 5);
      expect(AutoRefresher.parseMinutes('60 dk'), 60);
      expect(AutoRefresher.parseMinutes(null), 15);
      expect(AutoRefresher.parseMinutes('abc'), 15);
      expect(AutoRefresher.parseMinutes('0 dk'), 15);
    });

    test('runs only once the configured interval has passed', () async {
      SharedPreferences.setMockInitialValues({AutoRefresher.prefsKey: '5 dk'});
      var now = DateTime(2026, 11, 7, 12);
      var runs = 0;
      final r = AutoRefresher(onRefresh: () async => runs++, clock: () => now);
      now = now.add(const Duration(minutes: 4));
      expect(await r.tick(), isFalse);
      now = now.add(const Duration(minutes: 1));
      expect(await r.tick(), isTrue);
      expect(runs, 1);
      // Countdown restarts from the refresh.
      now = now.add(const Duration(minutes: 4));
      expect(await r.tick(), isFalse);
    });

    test('a manual load restarts the countdown', () async {
      SharedPreferences.setMockInitialValues({AutoRefresher.prefsKey: '15 dk'});
      var now = DateTime(2026, 11, 7, 12);
      var runs = 0;
      final r = AutoRefresher(onRefresh: () async => runs++, clock: () => now);
      now = now.add(const Duration(minutes: 14));
      r.markRefreshed();
      now = now.add(const Duration(minutes: 14));
      expect(await r.tick(), isFalse);
      expect(runs, 0);
    });

    test('a failed refresh is retried on the next tick', () async {
      SharedPreferences.setMockInitialValues({AutoRefresher.prefsKey: '5 dk'});
      var now = DateTime(2026, 11, 7, 12);
      var fail = true;
      var runs = 0;
      final r = AutoRefresher(
        onRefresh: () async {
          runs++;
          if (fail) throw Exception('offline');
        },
        clock: () => now,
      );
      now = now.add(const Duration(minutes: 5));
      expect(await r.tick(), isFalse);
      fail = false;
      now = now.add(const Duration(minutes: 1));
      expect(await r.tick(), isTrue);
      expect(runs, 2);
    });

    test('the settings key matches SettingsNotifier', () {
      expect(AutoRefresher.prefsKey, 'settings_refresh_interval');
    });
  });
}
