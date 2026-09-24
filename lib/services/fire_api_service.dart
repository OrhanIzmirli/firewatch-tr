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

  static bool _isOnLand(double lat, double lng) {
    if (lat < 35.8 || lat > 42.1) return false;
    if (lng < 26.0 || lng > 44.8) return false;
    if (lng < 26.5 && lat < 41.0) return false;
    if (lat < 36.0 && lng < 36.0) return false;
    if (lat > 41.8 && lng < 31.0) return false;
    if (lng > 44.0 && lat < 37.5) return false;
    return true;
  }

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

  Future<List<FirePoint>> fetchTurkeyFires() async {
    // NASA credentials stay on the backend. The backend selects the first
    // currently populated VIIRS/MODIS product and returns the original CSV;
    // no generated or mock detections are ever substituted.
    final response = await _dio.get<String>('$_backendUrl/api/thermal');
    final raw = response.data;
    if (raw == null || raw.trim().isEmpty) return [];
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
      if (!_isOnLand(lat, lng)) continue;

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
  Future<List<FirePoint>> fetchTurkeyFiresWithCities() async {
    final fires = await fetchTurkeyFires();
    if (fires.isEmpty) return fires;

    String keyFor(FirePoint p) =>
        '${p.latitude.toStringAsFixed(2)}_${p.longitude.toStringAsFixed(2)}';

    final representativeByKey = <String, FirePoint>{};
    for (final p in fires) {
      representativeByKey.putIfAbsent(keyFor(p), () => p);
    }

    final keys = representativeByKey.keys.toList();
    final cityInfoByKey = <String, NearestCityResult>{};
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
        if (info != null) cityInfoByKey[chunkKeys[k]] = info;
      }
    }

    return fires.map((p) {
      final info = cityInfoByKey[keyFor(p)];
      if (info == null || info.outsideTurkey) return p;
      return p.copyWith(cityName: info.city, nearestRegion: info.region);
    }).toList();
  }
}
