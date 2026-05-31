import 'package:csv/csv.dart';
import 'package:dio/dio.dart';
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
        return {
          'city': data['city'] ?? 'Türkiye',
          'region': data['region'] ?? 'Türkiye',
        };
      }
    } catch (_) {}
    return {'city': 'Türkiye', 'region': 'Türkiye'};
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
    final satIndex = header.indexOf('satellite');
    final dateIndex = header.indexOf('acq_date');
    final timeIndex = header.indexOf('acq_time');

    if (latIndex == -1 || lngIndex == -1) {
      throw Exception('CSV kolonları beklenen formatta değil.');
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
        ),
      );
    }

    return fires;
  }

  // Yangın noktalarını şehir bilgisiyle zenginleştir
  Future<List<FirePoint>> fetchTurkeyFiresWithCities() async {
    final fires = await fetchTurkeyFires();
    final enriched = <FirePoint>[];

    // İlk 10 nokta için şehir bilgisi çek, geri kalanlar için mevcut regionName
    for (int i = 0; i < fires.length; i++) {
      final point = fires[i];
      if (i < 10) {
        final cityInfo = await getNearestCity(point.latitude, point.longitude);
        enriched.add(point.copyWith(
          cityName: cityInfo['city'],
          nearestRegion: cityInfo['region'],
        ));
      } else {
        enriched.add(point);
      }
    }

    return enriched;
  }
}