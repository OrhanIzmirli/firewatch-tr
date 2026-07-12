import '../../services/offline_cache_service.dart';

/// Races [fetch] against [timeout]. If [fetch] hasn't completed by then,
/// loads whatever is cached under [cacheKey] and passes it to
/// [onSlowFallback] so the caller can show something instead of leaving the
/// screen spinning. [fetch] keeps running in the background regardless —
/// this function ultimately resolves to (or throws) whatever [fetch] itself
/// resolves to (or throws), just like awaiting it directly would, except a
/// slow-loading fallback may fire first as a side effect.
Future<T> raceWithCacheFallback<T>({
  required Future<T> fetch,
  required Duration timeout,
  required String cacheKey,
  required void Function((dynamic data, DateTime savedAt) cached) onSlowFallback,
}) {
  return fetch.timeout(timeout, onTimeout: () async {
    final cached = await OfflineCacheService.instance.load(cacheKey);
    if (cached != null) onSlowFallback(cached);
    return fetch;
  });
}

/// Calls [fetch] and, if it throws, calls it a second time before giving up.
/// Covers one-off hiccups (e.g. a cold-starting backend instance) so a
/// single failed attempt doesn't immediately flip a screen into offline
/// mode.
Future<T> retryOnce<T>(Future<T> Function() fetch) async {
  try {
    return await fetch();
  } catch (_) {
    return await fetch();
  }
}

/// Whether cached data saved at [savedAt] is recent enough to show without
/// an offline banner.
bool isCacheFresh(DateTime savedAt, {Duration within = const Duration(minutes: 30)}) {
  return DateTime.now().difference(savedAt) < within;
}
