import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../../core/utils/risk_display.dart';
import '../../../models/geo_area.dart';

/// Region of each province by plate number, as in the server's province
/// table. Regions are named in the folded form of [foldRegionName].
const Map<String, List<int>> _regionPlates = {
  'akdeniz': [1, 7, 15, 31, 32, 33, 46, 80],
  'guneydogu anadolu': [2, 21, 27, 47, 56, 63, 72, 73, 79],
  'ege': [3, 9, 20, 35, 43, 45, 48, 64],
  'dogu anadolu': [4, 12, 13, 23, 24, 25, 30, 36, 44, 49, 62, 65, 75, 76],
  'karadeniz': [5, 8, 14, 19, 28, 29, 37, 52, 53, 55, 57, 60, 61, 67, 69, 74, 78, 81],
  'ic anadolu': [6, 18, 26, 38, 40, 42, 50, 51, 58, 66, 68, 70, 71],
  'marmara': [10, 11, 16, 17, 22, 34, 39, 41, 54, 59, 77],
};

final Map<String, String> provinceRegion = {
  for (final entry in _regionPlates.entries)
    for (final plate in entry.value) plate.toString().padLeft(2, '0'): entry.key,
};

/// 'İç Anadolu', 'Ic Anadolu' and 'iç anadolu' all compare equal.
String foldRegionName(String name) {
  const map = {'İ': 'i', 'I': 'i', 'ı': 'i', 'ç': 'c', 'Ç': 'c', 'ğ': 'g', 'Ğ': 'g', 'ü': 'u', 'Ü': 'u', 'ş': 's', 'Ş': 's', 'ö': 'o', 'Ö': 'o'};
  return name.split('').map((c) => map[c] ?? c.toLowerCase()).join().trim();
}

/// The FireWatch risk score painted on the map: every province takes its
/// region's score from `/risk/summary`, the same numbers as the Risk tab,
/// coloured by the same 25/50/75 levels.
class RegionRiskLayer extends StatefulWidget {
  final List<GeoArea> areas;

  /// Score by folded region name.
  final Map<String, int> scores;
  final void Function(String regionKey, int score) onRegionTap;

  const RegionRiskLayer({super.key, required this.areas, required this.scores, required this.onRegionTap});

  static const double fillAlpha = 0.5;

  @override
  State<RegionRiskLayer> createState() => _RegionRiskLayerState();
}

class _RegionRiskLayerState extends State<RegionRiskLayer> {
  final LayerHitNotifier<String> _hit = ValueNotifier(null);
  late PolygonLayer<String> _layer = _build();

  @override
  void dispose() {
    _hit.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant RegionRiskLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.areas != widget.areas || oldWidget.scores != widget.scores) _layer = _build();
  }

  // Built once and reused: flutter_map re-projects every vertex of a
  // PolygonLayer whose widget changes, and this one is all 81 provinces.
  PolygonLayer<String> _build() => PolygonLayer<String>(
        hitNotifier: _hit,
        polygons: [
          for (final area in widget.areas)
            if (widget.scores[provinceRegion[area.id]] case final int score)
              for (final polygon in area.polygons)
                Polygon<String>(
                  points: polygon.first,
                  holePointsList: polygon.skip(1).toList(),
                  hitValue: area.id,
                  color: riskScoreColor(score).withValues(alpha: RegionRiskLayer.fillAlpha),
                  borderColor: const Color(0x400E0500),
                  borderStrokeWidth: 0.6,
                ),
        ],
      );

  void _onTap() {
    final region = provinceRegion[_hit.value?.hitValues.firstOrNull];
    final score = widget.scores[region];
    if (region != null && score != null) widget.onRegionTap(region, score);
  }

  @override
  Widget build(BuildContext context) => GestureDetector(onTap: _onTap, child: _layer);
}
