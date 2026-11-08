import 'package:dio/dio.dart';

import '../core/config/api_config.dart';

/// Why a point has no risk score.
enum PointRiskError { outsideTurkey, unavailable }

class PointRiskException implements Exception {
  final PointRiskError error;
  const PointRiskException(this.error);
}

/// The FireWatch risk score at one point, calculated on the server by the
/// same function as the regions. The answer has the same keys as a row of
/// `/risk/summary`, plus `risk_level`, `city`, `nearby_fire_count` and
/// `nearby_radius_km`.
///
/// The point is rounded to about 10 km before it leaves the phone, and
/// neighbouring places share one answer for ten minutes.
class PointRiskService {
  PointRiskService({Future<Map<String, dynamic>> Function(double lat, double lng)? post, DateTime Function()? now})
      : _post = post ?? _httpPost,
        _now = now ?? DateTime.now;

  static final PointRiskService instance = PointRiskService();

  static const ttl = Duration(minutes: 10);

  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 15),
  ));

  final Future<Map<String, dynamic>> Function(double lat, double lng) _post;
  final DateTime Function() _now;
  final Map<String, ({DateTime at, Map<String, dynamic> data})> _memo = {};
  final Map<String, Future<Map<String, dynamic>>> _inFlight = {};

  static double roundToGrid(double value) => (value * 10).round() / 10;

  static Future<Map<String, dynamic>> _httpPost(double lat, double lng) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.apiBaseUrl}/risk/point',
        data: {'latitude': lat, 'longitude': lng},
      );
      final data = response.data['data'];
      if (data is Map<String, dynamic>) return data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        throw const PointRiskException(PointRiskError.outsideTurkey);
      }
    }
    throw const PointRiskException(PointRiskError.unavailable);
  }

  /// Throws [PointRiskException].
  Future<Map<String, dynamic>> fetch({required double lat, required double lng}) {
    final rLat = roundToGrid(lat);
    final rLng = roundToGrid(lng);
    final key = '$rLat,$rLng';
    final memo = _memo[key];
    if (memo != null && _now().difference(memo.at) < ttl) return Future.value(memo.data);
    return _inFlight[key] ??= _post(rLat, rLng).then((data) {
      _memo[key] = (at: _now(), data: data);
      return data;
    }).whenComplete(() {
      // A block on purpose: whenComplete waits for a returned future, and
      // remove() returns this very one.
      _inFlight.remove(key);
    });
  }
}
