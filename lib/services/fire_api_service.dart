import 'package:csv/csv.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import '../l10n/l10n_lookup.dart';
import '../models/fire_point.dart';

class FireApiService {
  FireApiService();

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  static const String apiKey = '2fe2d1a21d4de517b1e877a27e308c6f';
  static const String turkeyArea = '25,35,45,43';
  static const String _backendUrl = 'https://firewatch-tr-backend.onrender.com';

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
  Future<Map<String, String>> getNearestCity(double lat, double lng) async {
    try {
      final response = await _dio.get(
        '$_backendUrl/api/fires/nearest-city',
        queryParameters: {'lat': lat, 'lng': lng},
      );
      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data['city'] != null && data['region'] != null) {
          return {'city': data['city'] as String, 'region': data['region'] as String};
        }
      }
    } catch (_) {}
    final l10n = await currentAppLocalizations();
    return {'city': l10n.regionTurkiyeGeneli, 'region': l10n.regionTurkiyeGeneli};
  }

  Future<List<FirePoint>> fetchTurkeyFires() async {
    final url =
        'https://firms.modaps.eosdis.nasa.gov/api/area/csv/$apiKey/VIIRS_SNPP_NRT/$turkeyArea/1';

    final response = await _dio.get<String>(url);

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
    final brightIndex = header.indexOf('bright_ti4');
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
    if (c.contains('high') || c == 'h') return 2;
    if (c.contains('nominal') || c == 'n') return 1;
    return 0;
  }

  static List<FirePoint> deduplicateFires(List<FirePoint> fires) {
    final sorted = [...fires]..sort((a, b) {
        final rankCompare = _confidenceRank(b.confidence).compareTo(_confidenceRank(a.confidence));
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
          candidate.latitude, candidate.longitude, existing.latitude, existing.longitude,
        );
        if (distanceMeters > _duplicateRadiusMeters) continue;

        final candidateTime = candidate.detectionDateTimeUtc;
        final existingTime = existing.detectionDateTimeUtc;
        if (candidateTime == null || existingTime == null) continue;
        if (candidateTime.difference(existingTime).abs() > _duplicateWindow) continue;

        matchIndex = i;
        break;
      }

      if (matchIndex == -1) {
        accepted.add(candidate);
      } else {
        final existing = accepted[matchIndex];
        final alreadyMerged = existing.satellite == candidate.satellite ||
            existing.mergedSatellites.contains(candidate.satellite);
        if (!alreadyMerged) {
          accepted[matchIndex] = existing.copyWith(
            mergedSatellites: [...existing.mergedSatellites, candidate.satellite],
          );
        }
      }
    }
    return accepted;
  }

  /// Enriches every fire point with its nearest city/region via PostGIS.
  ///
  /// Points are grouped by rounded coordinate (~1km) first, since fires
  /// cluster tightly and would resolve to the same nearest city anyway —
  /// this cuts a list of 100+ points down to a much smaller number of
  /// actual lookups. Those lookups run with bounded concurrency so we
  /// don't fire 100+ simultaneous requests at the (free-tier) backend.
  Future<List<FirePoint>> fetchTurkeyFiresWithCities() async {
    final fires = await fetchTurkeyFires();
    if (fires.isEmpty) return fires;

    String keyFor(FirePoint p) =>
        '${p.latitude.toStringAsFixed(2)}_${p.longitude.toStringAsFixed(2)}';

    final representativeByKey = <String, FirePoint>{};
    for (final p in fires) {
      representativeByKey.putIfAbsent(keyFor(p), () => p);
    }

    const concurrency = 10;
    final cityInfoByKey = <String, Map<String, String>>{};
    final keys = representativeByKey.keys.toList();
    for (var i = 0; i < keys.length; i += concurrency) {
      final batchKeys = keys.skip(i).take(concurrency);
      final results = await Future.wait(batchKeys.map((key) async {
        final p = representativeByKey[key]!;
        return MapEntry(key, await getNearestCity(p.latitude, p.longitude));
      }));
      for (final entry in results) {
        cityInfoByKey[entry.key] = entry.value;
      }
    }

    return fires.map((p) {
      final info = cityInfoByKey[keyFor(p)];
      if (info == null) return p;
      return p.copyWith(cityName: info['city'], nearestRegion: info['region']);
    }).toList();
  }
}