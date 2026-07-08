import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firewatch_tr/core/utils/loading_race.dart';
import 'package:firewatch_tr/services/offline_cache_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('falls back to cache when fetch exceeds the timeout, then resolves to the real result', () async {
    await OfflineCacheService.instance.save('test_key', {'value': 'cached'});

    var fallbackCalled = false;
    final result = await raceWithCacheFallback<String>(
      fetch: Future.delayed(const Duration(milliseconds: 200), () => 'fresh'),
      timeout: const Duration(milliseconds: 50),
      cacheKey: 'test_key',
      onSlowFallback: (cached) {
        fallbackCalled = true;
        expect(cached.$1, {'value': 'cached'});
      },
    );

    expect(fallbackCalled, isTrue, reason: 'slow fallback should fire before the real fetch resolves');
    expect(result, 'fresh', reason: 'should still resolve to the real fetch result once it lands');
  });

  test('never triggers fallback when fetch completes before the timeout', () async {
    await OfflineCacheService.instance.save('test_key2', {'value': 'cached'});

    var fallbackCalled = false;
    final result = await raceWithCacheFallback<String>(
      fetch: Future.delayed(const Duration(milliseconds: 10), () => 'fast'),
      timeout: const Duration(milliseconds: 200),
      cacheKey: 'test_key2',
      onSlowFallback: (_) => fallbackCalled = true,
    );

    expect(fallbackCalled, isFalse);
    expect(result, 'fast');
  });

  test('propagates the real error if the fetch eventually fails after a slow fallback', () async {
    await OfflineCacheService.instance.save('test_key3', {'value': 'cached'});

    var fallbackCalled = false;
    await expectLater(
      raceWithCacheFallback<String>(
        fetch: Future.delayed(const Duration(milliseconds: 100), () => throw Exception('network down')),
        timeout: const Duration(milliseconds: 20),
        cacheKey: 'test_key3',
        onSlowFallback: (_) => fallbackCalled = true,
      ),
      throwsA(isA<Exception>()),
    );
    expect(fallbackCalled, isTrue);
  });

  test('does nothing if fetch times out and there is no cached data', () async {
    var fallbackCalled = false;
    final result = await raceWithCacheFallback<String>(
      fetch: Future.delayed(const Duration(milliseconds: 100), () => 'fresh'),
      timeout: const Duration(milliseconds: 20),
      cacheKey: 'nonexistent_key',
      onSlowFallback: (_) => fallbackCalled = true,
    );

    expect(fallbackCalled, isFalse, reason: 'onSlowFallback should not be invoked when there is nothing cached');
    expect(result, 'fresh');
  });
}
