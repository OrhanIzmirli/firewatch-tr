import 'dart:async';
import 'dart:convert';

import '../core/utils/turkey_land_filter.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:csv/csv.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import '../l10n/l10n_lookup.dart';
import '../models/fire_point.dart';
import '../core/config/api_config.dart';

/// Result of a nearest-city lookup. [outsideTurkey] is true when the
/// coordinate fell outside Turkey's bounding box — the backend refuses to
/// match it against a Turkish city in that case (rather than confidently
/// returning the "nearest" one anyway, which could be hundreds of km away).
class NearestCityResult {
  final bool outsideTurkey;
  final String? city;
  final String? region;
  final double? distanceKm;

  const NearestCityResult({
    required this.outsideTurkey,
    this.city,
    this.region,
    this.distanceKm,
  });
}

class FireApiService {
  // Every call site does `FireApiService()` expecting a fresh-looking
  // instance, but there's no per-instance state worth duplicating — this
  // factory transparently hands back one shared instance (and Dio/HTTP
  // client) instead of each of the ~8 call sites paying for its own.
  factory FireApiService() => _instance;
  FireApiService._internal();
  static final FireApiService _instance = FireApiService._internal();

  final Dio _dio = Dio(
    BaseOptions(
      // Generous enough to survive a Render free-tier cold start (can take
      // 10-30s to wake) without throwing a false "offline" failure.
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  static const String _backendUrl = ApiConfig.backendBaseUrl;

  // En yakın şehri PostGIS ile bul
  Future<NearestCityResult> getNearestCity(double lat, double lng) async {
    try {
      final response = await _dio.get(
        '$_backendUrl/api/fires/nearest-city',
        queryParameters: {'lat': lat, 'lng': lng},
      );
      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data['outsideTurkey'] == true) {
          return const NearestCityResult(outsideTurkey: true);
        }
        if (data['city'] != null && data['region'] != null) {
          return NearestCityResult(
            outsideTurkey: false,
            city: data['city'] as String,
            region: data['region'] as String,
            distanceKm: (data['distance_km'] as num?)?.toDouble(),
          );
        }
      }
    } catch (_) {}
    final l10n = await currentAppLocalizations();
    return NearestCityResult(
      outsideTurkey: false,
      city: l10n.regionTurkiyeGeneli,
      region: l10n.regionTurkiyeGeneli,
    );
  }

  /// How long one /api/thermal response is reused. Home, map, alerts and
  /// the background monitor all ask for the same feed within seconds of
  /// each other; FIRMS itself updates a few times an hour at most.
  static const Duration feedMemoTtl = Duration(minutes: 2);

  List<FirePoint>? _feedMemo;
  DateTime? _feedMemoAt;
  Future<List<FirePoint>>? _feedInFlight;

  /// Test hook: forget the memoised feed.
  @visibleForTesting
  void clearFeedMemo() {
    _feedMemo = null;
    _feedMemoAt = null;
    _feedInFlight = null;
  }

  /// Test hook: replaces the network fetch.
  @visibleForTesting
  Future<List<FirePoint>> Function()? feedFetcherForTest;

  /// The thermal feed, memoised for [feedMemoTtl] and shared between
  /// concurrent callers. [force] (pull-to-refresh, the refresh button,
  /// auto refresh) always goes to the network.
  Future<List<FirePoint>> fetchTurkeyFires({bool force = false}) {
    final at = _feedMemoAt;
    final memo = _feedMemo;
    if (!force &&
        memo != null &&
        at != null &&
        DateTime.now().difference(at) < feedMemoTtl) {
      return Future.value(memo);
    }
    final inFlight = _feedInFlight;
    if (!force && inFlight != null) return inFlight;
    final fetch = feedFetcherForTest ?? _fetchTurkeyFiresNetwork;
    final future = fetch().then((points) {
      _feedMemo = points;
      _feedMemoAt = DateTime.now();
      return points;
    });
    _feedInFlight = future;
    future.whenComplete(() {
      if (identical(_feedInFlight, future)) _feedInFlight = null;
    }).ignore();
    return future;
  }

  Future<List<FirePoint>> _fetchTurkeyFiresNetwork() async {
    // NASA credentials stay on the backend. The backend selects the first
    // currently populated VIIRS/MODIS product and returns the original CSV;
    // no generated or mock detections are ever substituted.
    final response = await _dio.get<String>('$_backendUrl/api/thermal');
    final raw = response.data;
    if (raw == null || raw.trim().isEmpty) return [];
    // Parsing, the land filter and the quadratic duplicate merge run in a
    // background isolate: on a busy day they held the UI thread long
    // enough for an ANR when the map fell back to raw detections.
    return compute(parseThermalCsv, raw);
  }

  /// CSV text from /api/thermal → deduplicated points on Turkish land.
  /// Static and pure so it can run via compute().
  static List<FirePoint> parseThermalCsv(String raw) {
    final rows = const CsvToListConverter(
      eol: '\n',
      shouldParseNumbers: false,
    ).convert(raw);

    if (rows.length <= 1) return [];

    final header = rows.first.map((e) => e.toString()).toList();
    final latIndex = header.indexOf('latitude');
    final lngIndex = header.indexOf('longitude');
    final viirsBrightnessIndex = header.indexOf('bright_ti4');
    final brightIndex = viirsBrightnessIndex >= 0
        ? viirsBrightnessIndex
        : header.indexOf('brightness');
    final confIndex = header.indexOf('confidence');
    // 'satellite' is a platform code (e.g. "N" for Suomi NPP) — not
    // meaningful to show directly. 'instrument' ("VIIRS"/"MODIS") is what
    // users actually recognize, so that's what we display as satellite.
    final satIndex = header.indexOf('instrument');
    final dateIndex = header.indexOf('acq_date');
    final timeIndex = header.indexOf('acq_time');
    final frpIndex = header.indexOf('frp');
    final scanIndex = header.indexOf('scan');
    final trackIndex = header.indexOf('track');

    if (latIndex == -1 || lngIndex == -1) {
      throw Exception('CSV columns are not in the expected format.');
    }

    final List<FirePoint> fires = [];

    for (final row in rows.skip(1)) {
      if (row.length <= lngIndex) continue;

      final lat = double.tryParse(row[latIndex].toString());
      final lng = double.tryParse(row[lngIndex].toString());

      if (lat == null || lng == null) continue;
      if (!isOnTurkishLand(lat, lng)) continue;

      fires.add(
        FirePoint(
          latitude: lat,
          longitude: lng,
          brightness: brightIndex >= 0 && row.length > brightIndex
              ? row[brightIndex].toString()
              : 'Bilinmiyor',
          confidence: confIndex >= 0 && row.length > confIndex
              ? row[confIndex].toString()
              : 'low',
          satellite: satIndex >= 0 && row.length > satIndex
              ? row[satIndex].toString()
              : 'Bilinmiyor',
          acquisitionDate: dateIndex >= 0 && row.length > dateIndex
              ? row[dateIndex].toString()
              : 'Bilinmiyor',
          acquisitionTime: timeIndex >= 0 && row.length > timeIndex
              ? row[timeIndex].toString()
              : 'Bilinmiyor',
          frp: frpIndex >= 0 && row.length > frpIndex
              ? double.tryParse(row[frpIndex].toString()) ?? 0
              : 0,
          scanKm: scanIndex >= 0 && row.length > scanIndex
              ? double.tryParse(row[scanIndex].toString()) ?? 0
              : 0,
          trackKm: trackIndex >= 0 && row.length > trackIndex
              ? double.tryParse(row[trackIndex].toString()) ?? 0
              : 0,
        ),
      );
    }

    return deduplicateFires(fires);
  }

  /// Merges detections of the same real-world fire reported multiple times
  /// (e.g. by both the VIIRS and MODIS instruments passing over the same
  /// spot minutes apart) into a single point, so the UI doesn't show two
  /// markers for one fire. Two points are considered the same fire when
  /// they're within 500m of each other AND detected within 3 hours of each
  /// other. Among duplicates, the higher-confidence point is kept (ties
  /// broken by higher brightness); the discarded point's satellite name is
  /// recorded on the survivor's [FirePoint.mergedSatellites] so the UI can
  /// show e.g. "VIIRS + MODIS". This also means EFFIS (once its API is
  /// usable again) can be merged in as just another source through the
  /// same pipeline, without any additional cross-source-specific logic.
  static const _duplicateRadiusMeters = 500.0;
  static const _duplicateWindow = Duration(hours: 3);
  static const _duplicateLatDeg = 0.005;
  static const _duplicateLngDeg = 0.0075;

  static int _confidenceRank(String confidence) {
    final c = confidence.toLowerCase().trim();
    final numeric = int.tryParse(c);
    if (numeric != null) {
      if (numeric >= 80) return 2;
      if (numeric >= 30) return 1;
      return 0;
    }
    if (c.contains('high') || c == 'h') return 2;
    if (c.contains('nominal') || c == 'n') return 1;
    return 0;
  }

  static List<FirePoint> deduplicateFires(List<FirePoint> fires) {
    final sorted = [...fires]
      ..sort((a, b) {
        final rankCompare = _confidenceRank(
          b.confidence,
        ).compareTo(_confidenceRank(a.confidence));
        if (rankCompare != 0) return rankCompare;
        final aBright = double.tryParse(a.brightness) ?? 0;
        final bBright = double.tryParse(b.brightness) ?? 0;
        return bBright.compareTo(aBright);
      });

    final accepted = <FirePoint>[];
    for (final candidate in sorted) {
      var matchIndex = -1;
      for (var i = 0; i < accepted.length; i++) {
        final existing = accepted[i];
        // Cheap bounding-box reject before the great-circle maths: this
        // loop is quadratic in the day's detections. 500 m is ~0.0045° of
        // latitude and, at Türkiye's latitudes (36–42°N), at most ~0.0061°
        // of longitude; the margins below are wider than both.
        if ((candidate.latitude - existing.latitude).abs() > _duplicateLatDeg ||
            (candidate.longitude - existing.longitude).abs() > _duplicateLngDeg) {
          continue;
        }
        final distanceMeters = Geolocator.distanceBetween(
          candidate.latitude,
          candidate.longitude,
          existing.latitude,
          existing.longitude,
        );
        if (distanceMeters > _duplicateRadiusMeters) continue;

        final candidateTime = candidate.detectionDateTimeUtc;
        final existingTime = existing.detectionDateTimeUtc;
        if (candidateTime == null || existingTime == null) continue;
        if (candidateTime.difference(existingTime).abs() > _duplicateWindow) {
          continue;
        }

        matchIndex = i;
        break;
      }

      if (matchIndex == -1) {
        accepted.add(candidate);
      } else {
        final existing = accepted[matchIndex];
        final alreadyMerged =
            existing.satellite == candidate.satellite ||
            existing.mergedSatellites.contains(candidate.satellite);
        if (!alreadyMerged) {
          accepted[matchIndex] = existing.copyWith(
            mergedSatellites: [
              ...existing.mergedSatellites,
              candidate.satellite,
            ],
          );
        }
      }
    }
    return accepted;
  }

  /// Resolves the nearest city for many coordinates in one round trip.
  ///
  /// POST /api/fires/nearest-city/batch takes up to 400 pairs and answers
  /// them with a single LATERAL KNN query; the per-item shape is identical
  /// to the single endpoint. A failure here returns null for the whole
  /// chunk rather than falling back to one request per point: on a bad day
  /// that is one failed request instead of sixty, and the points still
  /// render with their bounding-box region label.
  Future<List<NearestCityResult?>?> getNearestCities(
    List<({double lat, double lng})> coords,
  ) async {
    if (coords.isEmpty) return const [];
    try {
      final response = await _dio.post(
        '$_backendUrl/api/fires/nearest-city/batch',
        data: {
          'coords': [
            for (final c in coords) {'lat': c.lat, 'lng': c.lng},
          ],
        },
      );
      final data = response.data?['data'];
      if (response.statusCode != 200 || data is! List) return null;
      if (data.length != coords.length) return null;
      return data.map<NearestCityResult?>((item) {
        if (item is! Map) return null;
        if (item['outsideTurkey'] == true) {
          return const NearestCityResult(outsideTurkey: true);
        }
        final city = item['city'];
        final region = item['region'];
        if (city is! String || region is! String) return null;
        return NearestCityResult(
          outsideTurkey: false,
          city: city,
          region: region,
          distanceKm: (item['distance_km'] as num?)?.toDouble(),
        );
      }).toList();
    } catch (_) {
      return null;
    }
  }

  /// The batch endpoint's hard ceiling per request.
  static const int _nearestCityBatchSize = 400;

  /// Enriches every fire point with its nearest city/region via PostGIS.
  ///
  /// Points are grouped by rounded coordinate (~1km) first, since fires
  /// cluster tightly and would resolve to the same nearest city anyway.
  /// The distinct coordinates then go to the batch endpoint in chunks of
  /// 400 — one or two requests for the whole country, where this used to
  /// issue one GET per group (60+ on a normal day) and, on a free-tier
  /// backend, could take longer than the map's own timeout.
  ///
  /// Coordinates already in the persistent city memo ([NearestCityMemo])
  /// cost nothing; only the rest go to the backend.
  Future<List<FirePoint>> fetchTurkeyFiresWithCities({bool force = false}) async {
    final fires = await fetchTurkeyFires(force: force);
    if (fires.isEmpty) return fires;

    String keyFor(FirePoint p) => NearestCityMemo.keyFor(p.latitude, p.longitude);

    final representativeByKey = <String, FirePoint>{};
    for (final p in fires) {
      representativeByKey.putIfAbsent(keyFor(p), () => p);
    }

    final memo = NearestCityMemo.instance;
    await memo.load();
    final cityInfoByKey = <String, NearestCityResult>{};
    final keys = <String>[];
    for (final key in representativeByKey.keys) {
      final hit = memo.get(key);
      if (hit != null) {
        cityInfoByKey[key] = hit;
      } else {
        keys.add(key);
      }
    }
    for (var i = 0; i < keys.length; i += _nearestCityBatchSize) {
      final chunkKeys = keys.sublist(
        i,
        (i + _nearestCityBatchSize).clamp(0, keys.length),
      );
      final results = await getNearestCities([
        for (final key in chunkKeys)
          (
            lat: representativeByKey[key]!.latitude,
            lng: representativeByKey[key]!.longitude,
          ),
      ]);
      if (results == null) continue; // this chunk keeps its bbox labels
      for (var k = 0; k < chunkKeys.length; k++) {
        final info = results[k];
        if (info == null) continue; // generic fallback: shown, not cached
        cityInfoByKey[chunkKeys[k]] = info;
        memo.put(chunkKeys[k], info);
      }
    }
    if (keys.isNotEmpty) unawaited(memo.persist());

    return fires.map((p) {
      final info = cityInfoByKey[keyFor(p)];
      if (info == null || info.outsideTurkey) return p;
      return p.copyWith(cityName: info.city, nearestRegion: info.region);
    }).toList();
  }
}

/// Nearest-city answers keyed by the fire pixel's coordinate rounded to two
/// decimals (~1 km; never the user's position), kept in memory and in
/// SharedPreferences so a cold start does not re-ask the backend about
/// pixels it has already named. Ported from 1.0.5/1.0.6 with two TR
/// changes: the key is versioned v2, because migration 015 (7 Nov 2026)
/// moved provinces onto real boundaries and a v1 answer could name the
/// wrong province; and every entry expires after [ttl].
class NearestCityMemo {
  NearestCityMemo({DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  static final NearestCityMemo instance = NearestCityMemo();

  static const String prefsKey = 'nearest_city_cache_v2';

  /// 1.0.6's v1 key. Removed on load; never read.
  static const String legacyPrefsKey = 'nearest_city_cache_v1';

  static const Duration ttl = Duration(days: 30);
  static const int maxEntries = 1500;

  final DateTime Function() _clock;
  final Map<String, ({NearestCityResult result, DateTime at})> _entries = {};
  bool _loaded = false;

  static String keyFor(double lat, double lng) =>
      '${lat.toStringAsFixed(2)}_${lng.toStringAsFixed(2)}';

  int get length => _entries.length;

  NearestCityResult? get(String key) {
    final entry = _entries[key];
    if (entry == null) return null;
    if (_clock().difference(entry.at) > ttl) {
      _entries.remove(key);
      return null;
    }
    return entry.result;
  }

  void put(String key, NearestCityResult result) {
    _entries.remove(key);
    _entries[key] = (result: result, at: _clock());
    // Insertion order is age order: drop the oldest beyond the cap.
    while (_entries.length > maxEntries) {
      _entries.remove(_entries.keys.first);
    }
  }

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey(legacyPrefsKey)) {
        await prefs.remove(legacyPrefsKey);
      }
      final raw = prefs.getString(prefsKey);
      if (raw == null) return;
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;
      final now = _clock();
      final rows = <(String, NearestCityResult, DateTime)>[];
      decoded.forEach((key, value) {
        if (key is! String || value is! Map) return;
        final at = DateTime.fromMillisecondsSinceEpoch(
          (value['t'] as num?)?.toInt() ?? 0,
        );
        if (now.difference(at) > ttl) return;
        final outside = value['o'] == true;
        final city = value['c'];
        final region = value['r'];
        if (!outside && (city is! String || region is! String)) return;
        rows.add((
          key,
          NearestCityResult(
            outsideTurkey: outside,
            city: outside ? null : city as String,
            region: outside ? null : region as String,
            distanceKm: (value['d'] as num?)?.toDouble(),
          ),
          at,
        ));
      });
      rows.sort((a, b) => a.$3.compareTo(b.$3));
      for (final (key, result, at) in rows) {
        _entries.putIfAbsent(key, () => (result: result, at: at));
      }
      while (_entries.length > maxEntries) {
        _entries.remove(_entries.keys.first);
      }
    } catch (_) {
      // A corrupt memo only costs a few lookups.
    }
  }

  Future<void> persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(prefsKey, jsonEncode({
        for (final e in _entries.entries)
          e.key: {
            if (e.value.result.outsideTurkey) 'o': true,
            if (e.value.result.city != null) 'c': e.value.result.city,
            if (e.value.result.region != null) 'r': e.value.result.region,
            if (e.value.result.distanceKm != null) 'd': e.value.result.distanceKm,
            't': e.value.at.millisecondsSinceEpoch,
          },
      }));
    } catch (_) {}
  }

  @visibleForTesting
  void resetForTest() {
    _entries.clear();
    _loaded = false;
  }
}
