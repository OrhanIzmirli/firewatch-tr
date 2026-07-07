import 'package:dio/dio.dart';

/// Caches /api/risk/summary in memory so fire descriptions can cheaply
/// cross-reference a region's current risk conditions without every call
/// site needing to be async. Warmed up once at app startup and refreshed
/// transparently at most every 30 minutes.
class RiskDataCache {
  RiskDataCache._();
  static final RiskDataCache instance = RiskDataCache._();

  final Dio _dio = Dio();
  static const _ttl = Duration(minutes: 30);

  List<Map<String, dynamic>> _regions = [];
  DateTime? _fetchedAt;
  Future<void>? _inFlight;

  bool get _isStale =>
      _fetchedAt == null || DateTime.now().difference(_fetchedAt!) > _ttl;

  /// Fetches (or refreshes, if stale) the risk summary. Safe to call
  /// repeatedly — concurrent calls share the same in-flight request.
  Future<void> warmUp() async {
    if (!_isStale) return;
    if (_inFlight != null) return _inFlight;
    _inFlight = _fetch();
    await _inFlight;
    _inFlight = null;
  }

  Future<void> _fetch() async {
    try {
      final response = await _dio.get(
        'https://firewatch-tr-backend.onrender.com/api/risk/summary',
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        _regions = data.map((e) => Map<String, dynamic>.from(e)).toList();
        _fetchedAt = DateTime.now();
      }
    } catch (_) {
      // Keep serving the previous snapshot (if any) on failure.
    }
  }

  static const Map<String, String> _keyToApiRegion = {
    'ege': 'Ege',
    'akdeniz': 'Akdeniz',
    'marmara': 'Marmara',
    'karadeniz': 'Karadeniz',
    'ic_anadolu': 'Ic Anadolu',
    'dogu_anadolu': 'Dogu Anadolu',
    'guneydogu_anadolu': 'Guneydogu Anadolu',
  };

  /// Synchronous lookup against whatever snapshot is currently cached
  /// (possibly none, if warmUp() hasn't completed yet or the network
  /// call failed) — used by FirePoint's description methods, which need
  /// to stay synchronous.
  Map<String, dynamic>? riskForRegionKeySync(String? regionKey) {
    if (regionKey == null) return null;
    final apiRegion = _keyToApiRegion[regionKey];
    if (apiRegion == null) return null;
    for (final r in _regions) {
      if (r['region'] == apiRegion) return r;
    }
    return null;
  }
}
