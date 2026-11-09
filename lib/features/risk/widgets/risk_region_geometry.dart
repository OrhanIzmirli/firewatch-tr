import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

import '../../map/widgets/region_risk_layer.dart' show foldRegionName, provinceRegion;

/// Region outlines, by folded region name, made by merging the provinces of
/// assets/data/il_sinirlari.geojson. The risk score is per region, so the
/// Risk screen's map draws these seven shapes and no province lines.
///
/// A province edge shared inside a region cancels out; what is left is the
/// region's border. Neighbouring provinces share exact vertices in this file
/// (test/turkey_risk_heatmap_test.dart pins it).
Map<String, List<List<LatLng>>> dissolveRegions(Map<String, dynamic> geojson) {
  final edgesByRegion = <String, Set<(int, int)>>{};
  final vertexIds = <(double, double), int>{};
  final vertices = <LatLng>[];

  int idOf(List point) {
    final lng = (point[0] as num).toDouble();
    final lat = (point[1] as num).toDouble();
    return vertexIds.putIfAbsent((lng, lat), () {
      vertices.add(LatLng(lat, lng));
      return vertices.length - 1;
    });
  }

  for (final feature in geojson['features'] as List) {
    final properties = feature['properties'] as Map;
    final region = provinceRegion['${properties['plaka']}'.padLeft(2, '0')];
    if (region == null) continue;
    final geometry = feature['geometry'] as Map;
    final coordinates = geometry['coordinates'] as List;
    final polygons = geometry['type'] == 'Polygon' ? [coordinates] : coordinates;
    final edges = edgesByRegion.putIfAbsent(region, () => <(int, int)>{});
    for (final polygon in polygons) {
      for (final ring in polygon as List) {
        final points = ring as List;
        for (var i = 0; i + 1 < points.length; i++) {
          final a = idOf(points[i] as List);
          final b = idOf(points[i + 1] as List);
          if (a == b) continue;
          final edge = a < b ? (a, b) : (b, a);
          if (!edges.remove(edge)) edges.add(edge);
        }
      }
    }
  }

  return {
    for (final entry in edgesByRegion.entries) entry.key: _chainRings(entry.value, vertices),
  };
}

List<List<LatLng>> _chainRings(Set<(int, int)> edges, List<LatLng> vertices) {
  final neighbours = <int, List<int>>{};
  for (final (a, b) in edges) {
    neighbours.putIfAbsent(a, () => []).add(b);
    neighbours.putIfAbsent(b, () => []).add(a);
  }

  void unlink(int from, int to) {
    final list = neighbours[from]!..remove(to);
    if (list.isEmpty) neighbours.remove(from);
  }

  final rings = <List<LatLng>>[];
  while (neighbours.isNotEmpty) {
    final start = neighbours.keys.first;
    final ring = [start];
    var current = start;
    while (neighbours.containsKey(current)) {
      final next = neighbours[current]!.last;
      unlink(current, next);
      unlink(next, current);
      ring.add(next);
      current = next;
      if (current == start) break;
    }
    if (ring.length >= 4 && ring.first == ring.last) {
      rings.add([for (final id in ring) vertices[id]]);
    }
  }
  return rings;
}

Map<String, List<List<LatLng>>> _parseAndDissolve(String raw) =>
    dissolveRegions(jsonDecode(raw) as Map<String, dynamic>);

Future<Map<String, List<List<LatLng>>>>? _regionsFuture;

/// Loaded once per app run, off the UI thread (56k vertices).
Future<Map<String, List<List<LatLng>>>> loadRiskRegionShapes() =>
    _regionsFuture ??= rootBundle
        .loadString('assets/data/il_sinirlari.geojson')
        .then((raw) => compute(_parseAndDissolve, raw));

/// The key [dissolveRegions] uses for a region name from the API.
String riskRegionShapeKey(String apiRegion) => foldRegionName(apiRegion);
