import 'dart:convert';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// What sampling the FWI raster at one point yielded.
///
/// [classIndex] is 0 (very low) … 5 (extreme), or null when the raster has
/// no data there (sea, or outside coverage) — "no data" is the answer then,
/// never "zero risk".
class FwiPointSample {
  final int? classIndex;
  const FwiPointSample(this.classIndex);

  bool get hasData => classIndex != null;
}

/// Reads the FWI danger class at a single coordinate by fetching a 3×3 px
/// GetMap image around it and reading the centre pixel.
///
/// This is the only per-point query the EFFIS server supports here:
/// GetFeatureInfo is disabled for mf010.fwi (returns LayerNotDefined), so
/// the class has to come from the rendered colour. The six legend colours
/// are exact server output; resampling can still blend edges, so an
/// off-palette pixel is snapped to the nearest of the six rather than
/// invented into an intermediate class.
class FwiPointService {
  FwiPointService._();

  static final FwiPointService instance = FwiPointService._();

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 12),
      responseType: ResponseType.bytes,
    ),
  );

  static const _cachePrefsKey = 'fwi_point_cache_v1';

  /// The exact palette, index-aligned with the legend and with
  /// AppColors.fwi* (very low → extreme).
  static const List<_Rgb> _palette = [
    _Rgb(0x9C, 0xFF, 0xC0),
    _Rgb(0xCD, 0xE2, 0x4E),
    _Rgb(0xE6, 0xAC, 0x00),
    _Rgb(0xD9, 0x70, 0x10),
    _Rgb(0xAD, 0x06, 0x0E),
    _Rgb(0x3A, 0x00, 0x15),
  ];

  final Map<String, FwiPointSample> _memory = {};
  Map<String, int>? _persisted;

  static String _key(String date, double lat, double lng) =>
      '${date}_${lat.toStringAsFixed(2)}_${lng.toStringAsFixed(2)}';

  /// Samples the FWI class at ([lat], [lng]) for [date] (YYYY-MM-DD).
  /// Returns null on network failure — unknown, distinct from "no data".
  Future<FwiPointSample?> sample({
    required double lat,
    required double lng,
    required String date,
  }) async {
    final key = _key(date, lat, lng);
    final cached = _memory[key] ?? await _readPersisted(key);
    if (cached != null) return cached;

    try {
      // 0.06° ≈ 6 km: comfortably inside one ~10 km model cell, so the 3×3
      // request reads the cell under the point, not a neighbourhood average.
      const half = 0.03;
      final bbox =
          '${(lng - half).toStringAsFixed(4)},${(lat - half).toStringAsFixed(4)},'
          '${(lng + half).toStringAsFixed(4)},${(lat + half).toStringAsFixed(4)}';
      final response = await _dio.get(
        'https://maps.effis.emergency.copernicus.eu/effis',
        queryParameters: {
          'SERVICE': 'WMS',
          'VERSION': '1.1.1',
          'REQUEST': 'GetMap',
          'LAYERS': 'mf010.fwi',
          // Empty but mandatory: the server errors when STYLES is absent.
          'STYLES': '',
          'FORMAT': 'image/png',
          'TRANSPARENT': 'true',
          'SRS': 'EPSG:4326',
          'WIDTH': '3',
          'HEIGHT': '3',
          'BBOX': bbox,
          'TIME': date,
        },
      );
      final bytes = response.data as List<int>;
      final rgba = await _centerPixel(Uint8List.fromList(bytes));
      if (rgba == null) return null;

      final FwiPointSample sample;
      if (rgba[3] == 0) {
        sample = const FwiPointSample(null);
      } else {
        sample = FwiPointSample(_nearestClass(rgba[0], rgba[1], rgba[2]));
      }
      _memory[key] = sample;
      await _writePersisted(key, sample, date);
      return sample;
    } catch (e) {
      if (kDebugMode) debugPrint('FWI point sample failed: $e');
      return null;
    }
  }

  /// Nearest FWI class for an opaque pixel. Public so tests can pin the
  /// snapping behaviour — resampled edge pixels must round to a real class,
  /// never invent an intermediate one.
  static int nearestClass(int r, int g, int b) => _nearestClass(r, g, b);

  static int _nearestClass(int r, int g, int b) {
    var best = 0;
    var bestDist = 1 << 30;
    for (var i = 0; i < _palette.length; i++) {
      final p = _palette[i];
      final d = (r - p.r) * (r - p.r) +
          (g - p.g) * (g - p.g) +
          (b - p.b) * (b - p.b);
      if (d < bestDist) {
        bestDist = d;
        best = i;
      }
    }
    return best;
  }

  static Future<List<int>?> _centerPixel(Uint8List png) async {
    try {
      final codec = await ui.instantiateImageCodec(png);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      image.dispose();
      if (data == null) return null;
      final w = image.width;
      final cx = w ~/ 2;
      final cy = image.height ~/ 2;
      final offset = (cy * w + cx) * 4;
      if (data.lengthInBytes < offset + 4) return null;
      return [
        data.getUint8(offset),
        data.getUint8(offset + 1),
        data.getUint8(offset + 2),
        data.getUint8(offset + 3),
      ];
    } catch (_) {
      return null;
    }
  }

  Future<FwiPointSample?> _readPersisted(String key) async {
    final map = await _loadPersisted();
    final value = map[key];
    if (value == null) return null;
    final sample = FwiPointSample(value < 0 ? null : value);
    _memory[key] = sample;
    return sample;
  }

  Future<Map<String, int>> _loadPersisted() async {
    if (_persisted != null) return _persisted!;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cachePrefsKey);
    if (raw == null) return _persisted = {};
    try {
      return _persisted = (jsonDecode(raw) as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, (v as num).toInt()));
    } catch (_) {
      return _persisted = {};
    }
  }

  Future<void> _writePersisted(
    String key,
    FwiPointSample sample,
    String date,
  ) async {
    final map = await _loadPersisted();
    map[key] = sample.classIndex ?? -1;
    // The forecast horizon is 4 days; entries older than today are stale by
    // definition. Pruning on write keeps the cache from growing for years.
    map.removeWhere((k, _) => k.compareTo(date) < 0 && k.length >= 10);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cachePrefsKey, jsonEncode(map));
  }
}

class _Rgb {
  final int r, g, b;
  const _Rgb(this.r, this.g, this.b);
}
