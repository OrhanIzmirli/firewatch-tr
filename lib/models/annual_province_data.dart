import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'geo_area.dart';

/// Bundled historical totals. These are not today's risk or fire perimeters.
class AnnualProvinceData {
  final List<GeoArea> areas;
  final Map<String, dynamic> provinces;
  final double logMax;
  final String source;
  const AnnualProvinceData(
    this.areas,
    this.provinces,
    this.logMax,
    this.source,
  );

  static const years = [
    2016,
    2017,
    2018,
    2019,
    2020,
    2021,
    2022,
    2023,
    2024,
    2025,
  ];
  static const stops = [
    Color(0xFFFFF7ED),
    Color(0xFFFDBA74),
    Color(0xFFF97316),
    Color(0xFF7C2D12),
  ];

  static Future<AnnualProvinceData> load({AssetBundle? bundle}) async {
    final assets = bundle ?? rootBundle;
    final raw = await Future.wait([
      assets.loadString('assets/data/il_sinirlari.geojson'),
      assets.loadString('assets/data/il_yil_veri.json'),
    ]);
    return AnnualProvinceData.fromJson(
      jsonDecode(raw[0]) as Map<String, dynamic>,
      jsonDecode(raw[1]) as Map<String, dynamic>,
    );
  }

  factory AnnualProvinceData.fromJson(
    Map<String, dynamic> geometry,
    Map<String, dynamic> data,
  ) {
    final areas = (geometry['features'] as List).map((raw) {
      final f = Map<String, dynamic>.from(raw as Map);
      final p = Map<String, dynamic>.from(f['properties'] as Map);
      f['id'] = '${p['plaka']}'.padLeft(2, '0');
      f['properties'] = {...p, 'city': p['il']};
      return GeoArea.fromJson(f);
    }).toList();
    if (areas.map((a) => a.id).toSet().length != areas.length) {
      throw const FormatException('Duplicate province code');
    }
    final logMax = (data['renk']['log_max'] as num).toDouble();
    if (!logMax.isFinite || logMax <= 0) {
      throw const FormatException('Invalid color scale');
    }
    return AnnualProvinceData(
      areas,
      Map<String, dynamic>.from(data['iller'] as Map),
      logMax,
      '${data['kaynak']}',
    );
  }

  num? value(String code, int year, String metric) {
    final raw = provinces[code]?['yillar']?['$year']?[metric];
    return raw is num && raw.isFinite && raw >= 0 ? raw : null;
  }

  Color color(String code, int year) {
    final hectares = value(code, year, 'ogm_yanan_alan_ha');
    if (hectares == null) return Colors.transparent;
    final t = (math.log(hectares + 1) / math.ln10 / logMax).clamp(0.0, 1.0) * 3;
    final i = math.min(2, t.floor());
    return Color.lerp(stops[i], stops[i + 1], t - i)!.withValues(alpha: 0.8);
  }
}
