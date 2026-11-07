// Before/after measurement for map re-clustering (RAPOR.md "Düzeltmeler").
//
// Reproduces the map screen's situation: a MarkerClusterLayerWidget whose
// parent rebuilds often (a pinch calls setState every 0.2 zoom). "Before"
// hands the layer a new marker list on every build, as map_screen did;
// "after" goes through MarkerListCache. Timings are printed; the assertion
// is on the work done, which is deterministic.
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'package:firewatch_tr/features/map/widgets/marker_list_cache.dart';

class _Harness extends StatefulWidget {
  final List<LatLng> points;
  final bool cached;
  final ValueChanged<int> onBuildList;
  const _Harness({super.key, required this.points, required this.cached, required this.onBuildList});
  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  final cache = MarkerListCache();
  int tick = 0;
  int listBuilds = 0;

  void rebuild() => setState(() => tick++);

  List<Marker> _build() {
    listBuilds++;
    widget.onBuildList(listBuilds);
    return [
      for (final p in widget.points)
        Marker(point: p, width: 24, height: 24, child: const SizedBox.square(dimension: 12)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final markers = widget.cached ? cache.get([widget.points], _build) : _build();
    return FlutterMap(
      options: const MapOptions(initialCenter: LatLng(39, 35), initialZoom: 5.6, minZoom: 4, maxZoom: 18),
      children: [
        MarkerClusterLayerWidget(
          options: MarkerClusterLayerOptions(
            maxClusterRadius: 88,
            size: const Size(40, 40),
            markers: markers,
            builder: (context, ms) => Text('${ms.length}'),
          ),
        ),
      ],
    );
  }
}

List<LatLng> _turkeyPoints(int n) {
  final r = math.Random(7);
  return [for (var i = 0; i < n; i++) LatLng(36 + r.nextDouble() * 6, 26 + r.nextDouble() * 18)];
}

Future<({Duration time, int listBuilds})> _run(WidgetTester tester, int n, {required bool cached}) async {
  final points = _turkeyPoints(n);
  var builds = 0;
  await tester.pumpWidget(MaterialApp(
    home: SizedBox(width: 400, height: 800, child: _Harness(key: ValueKey(cached), points: points, cached: cached, onBuildList: (b) => builds = b)),
  ));
  await tester.pump();
  final state = tester.state<_HarnessState>(find.byType(_Harness));
  final sw = Stopwatch()..start();
  for (var i = 0; i < 30; i++) {
    state.rebuild();
    await tester.pump();
  }
  sw.stop();
  return (time: sw.elapsed, listBuilds: builds);
}

void main() {
  for (final n in [300, 900]) {
    testWidgets('$n markers, 30 parent rebuilds: before vs after', (tester) async {
      final before = await _run(tester, n, cached: false);
      final after = await _run(tester, n, cached: true);
      // ignore: avoid_print
      print('re-cluster benchmark n=$n: before ${before.time.inMilliseconds} ms '
          '(${before.listBuilds} new lists → ${before.listBuilds} re-clusters), '
          'after ${after.time.inMilliseconds} ms (${after.listBuilds} list, 1 cluster pass)');
      expect(before.listBuilds, 31); // initial + one per rebuild: the old behaviour
      expect(after.listBuilds, 1); // built once, reused across all rebuilds
    });
  }

  test('the cache rebuilds only when an input changes', () {
    final cache = MarkerListCache();
    final data = [const LatLng(39, 35)];
    List<Marker> build() => [Marker(point: data.first, child: const SizedBox())];
    final a = cache.get([data, 'active', false], build);
    expect(identical(cache.get([data, 'active', false], build), a), isTrue);
    expect(cache.builds, 1);
    cache.get([data, 'ended', false], build); // filter changed
    cache.get([data, 'ended', true], build); // risk-layer styling changed
    cache.get([[...data], 'ended', true], build); // new data list
    expect(cache.builds, 4);
  });

  test('map_screen feeds the cluster layers from the caches, and zoom never calls setState', () {
    final src = File('lib/features/map/map_screen.dart').readAsStringSync();
    expect(src, contains('markers: _incidentMarkers,'));
    expect(src, contains('markers: _pointMarkers,'));
    expect(src, isNot(contains('setState(() => _currentZoom')));
    expect(src, isNot(contains('_visibleIncidents.map(')));
    final annual = File('lib/features/map/widgets/annual_province_layer.dart').readAsStringSync();
    expect(annual, contains('_baseLayer'));
    expect(annual, isNot(contains('0xFF111828')));
  });
}
