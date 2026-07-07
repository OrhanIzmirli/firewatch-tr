import 'package:csv/csv.dart';
import 'package:dio/dio.dart';
import '../l10n/l10n_lookup.dart';
import '../models/fire_point.dart';

class FireApiService {
  FireApiService();

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
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

    return fires;
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