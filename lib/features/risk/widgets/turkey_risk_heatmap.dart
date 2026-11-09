import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/widgets/osm_attribution.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/utils/map_tiles.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/risk_display.dart';
import '../../../l10n/app_localizations.dart';
import 'risk_region_geometry.dart';

// ── Scale ──────────────────────────────────────────────────────────────────
//
// The four FireWatch TR status colours and their score bands come from one
// place: AppColors.risk* and riskLevelForScore() (25/50/75). A region has one
// score, so it is painted one flat colour; nothing blends between regions.

const Color riskHeatLowColor = AppColors.riskLow; // 0–24
const Color riskHeatMediumColor = AppColors.riskMedium; // 25–49
const Color riskHeatHighColor = AppColors.riskHigh; // 50–74
const Color riskHeatVeryHighColor = AppColors.riskCritical; // 75–100

enum RiskHeatBand { low, medium, high, veryHigh }

RiskHeatBand riskHeatBandFor(num score) => switch (riskLevelForScore(score)) {
  'Critical' => RiskHeatBand.veryHigh,
  'High' => RiskHeatBand.high,
  'Medium' => RiskHeatBand.medium,
  _ => RiskHeatBand.low,
};

Color riskHeatBandColor(RiskHeatBand band) {
  switch (band) {
    case RiskHeatBand.low:
      return riskHeatLowColor;
    case RiskHeatBand.medium:
      return riskHeatMediumColor;
    case RiskHeatBand.high:
      return riskHeatHighColor;
    case RiskHeatBand.veryHigh:
      return riskHeatVeryHighColor;
  }
}

/// Flat fill of a region. Strong enough to read as the legend's colour over
/// the greyscale base map.
const double riskRegionFillAlpha = 0.85;

Color riskRegionFillColor(num score) => riskScoreColor(score).withValues(alpha: riskRegionFillAlpha);

// ── Geometry ───────────────────────────────────────────────────────────────

/// The box the camera opens on.
final LatLngBounds turkeyHeatBounds =
    LatLngBounds(const LatLng(35.7, 25.5), const LatLng(42.2, 45.0));

/// Outer rings of the national border from assets/data/turkey_outline.json
/// (Natural Earth 1:50m, public domain). Loaded once per app run.
Future<List<List<LatLng>>>? _outlineFuture;

Future<List<List<LatLng>>> loadTurkeyOutline() {
  return _outlineFuture ??= rootBundle.loadString('assets/data/turkey_outline.json').then((raw) {
    final rings = (jsonDecode(raw) as Map<String, dynamic>)['rings'] as List;
    return [
      for (final ring in rings)
        [
          for (final p in ring as List)
            LatLng(((p as List)[1] as num).toDouble(), (p[0] as num).toDouble()),
        ],
    ];
  });
}

// ── Widget ─────────────────────────────────────────────────────────────────

/// Nationwide wildfire-risk map for the Risk screen: the seven regions in the
/// flat colour of their level, with clear borders. Separate from the incident
/// map: no fires, no markers, only the regional risk scores.
///
/// With [regionScores] empty (API down, nothing cached) it shows a grey
/// outline of Türkiye and no pill; the caller shows the "no data" note.
class TurkeyRiskHeatmap extends StatefulWidget {
  /// Raw region key → 0–100 score, as /api/risk/summary returns them.
  final Map<String, double> regionScores;
  final double height;

  const TurkeyRiskHeatmap({
    super.key,
    required this.regionScores,
    this.height = 250,
  });

  @override
  State<TurkeyRiskHeatmap> createState() => _TurkeyRiskHeatmapState();
}

class _TurkeyRiskHeatmapState extends State<TurkeyRiskHeatmap> {
  List<List<LatLng>>? _outline;
  Map<String, List<List<LatLng>>>? _regionShapes;

  // Built once per data and theme and reused: flutter_map re-projects every
  // vertex of a PolygonLayer whose widget changes.
  Widget? _regionLayer;
  Map<String, double>? _layerScores;
  bool? _layerDark;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final outline = await loadTurkeyOutline();
      if (mounted) setState(() => _outline = outline);
      final shapes = await loadRiskRegionShapes();
      if (mounted) setState(() => _regionShapes = shapes);
    } catch (e) {
      // A broken asset must not take the Risk screen down; the map simply
      // stays without the region colours.
      if (kDebugMode) debugPrint('Risk map build failed: $e');
    }
  }

  Widget? _regionsLayer(bool isDark) {
    final shapes = _regionShapes;
    if (shapes == null || widget.regionScores.isEmpty) return null;
    if (_regionLayer == null || _layerDark != isDark || !mapEquals(_layerScores, widget.regionScores)) {
      final scores = {
        for (final e in widget.regionScores.entries) riskRegionShapeKey(e.key): e.value,
      };
      final border = isDark ? Colors.white : const Color(0xFF1B1916);
      _layerDark = isDark;
      _layerScores = widget.regionScores;
      _regionLayer = PolygonLayer(
        polygons: [
          for (final entry in shapes.entries)
            for (final ring in entry.value)
              Polygon(
                points: ring,
                color: scores[entry.key] == null
                    ? (isDark ? Colors.white : Colors.black).withValues(alpha: 0.10)
                    : riskRegionFillColor(scores[entry.key]!),
                borderColor: border,
                borderStrokeWidth: 1.4,
              ),
        ],
      );
    }
    return _regionLayer;
  }

  double get _average {
    final scores = widget.regionScores.values;
    return scores.isEmpty ? 0 : scores.reduce((a, b) => a + b) / scores.length;
  }

  String _bandLabel(AppLocalizations l10n, RiskHeatBand band) {
    switch (band) {
      case RiskHeatBand.low:
        return l10n.commonLow;
      case RiskHeatBand.medium:
        return l10n.commonMedium;
      case RiskHeatBand.high:
        return l10n.commonHigh;
      case RiskHeatBand.veryHigh:
        return l10n.commonCritical;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasData = widget.regionScores.isNotEmpty;
    final avg = _average.round();
    final band = riskHeatBandFor(avg);
    final bandLabel = _bandLabel(l10n, band);
    final outline = _outline ?? const <List<LatLng>>[];

    final background = isDark ? const Color(0xFF1B1916) : const Color(0xFFE9E6E1);
    final borderColor = isDark
        ? AppColors.white.withValues(alpha: 0.55)
        : AppColors.lightText.withValues(alpha: 0.55);
    final regionsLayer = _regionsLayer(isDark);

    final map = Semantics(
      label: hasData ? l10n.riskHeatMapSemantics(avg, bandLabel) : l10n.riskHeatUnavailable,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius),
        child: SizedBox(
          height: widget.height,
          child: Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCameraFit: CameraFit.bounds(
                    bounds: turkeyHeatBounds,
                    padding: const EdgeInsets.fromLTRB(8, 36, 8, 8),
                  ),
                  minZoom: 3.5,
                  maxZoom: 10,
                  // Panning stays around Türkiye: a page scroll that started
                  // on the map used to drag it off to Finland.
                  cameraConstraint: CameraConstraint.containCenter(
                    bounds: LatLngBounds(
                      LatLng(turkeyHeatBounds.south - 2, turkeyHeatBounds.west - 3),
                      LatLng(turkeyHeatBounds.north + 2, turkeyHeatBounds.east + 3),
                    ),
                  ),
                  backgroundColor: background,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: MapTiles.osmUrl,
                    tileProvider: MapTiles.providerFor(MapTiles.osmUrl),
                    userAgentPackageName: 'com.oguzh.firewatch.firewatch_tr',
                    // Greyscale (and dimmed in dark mode) so the only colour
                    // on the map is the risk itself.
                    tileBuilder: (context, tile, _) => ColorFiltered(
                      colorFilter: ColorFilter.matrix(_greyscale(isDark ? 0.55 : 1.0)),
                      child: tile,
                    ),
                  ),
                  ?regionsLayer,
                  if (outline.isNotEmpty && regionsLayer == null)
                    PolygonLayer(
                      polygons: [
                        for (final ring in outline)
                          Polygon(
                            points: ring,
                            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.10),
                            borderColor: borderColor.withValues(alpha: 0.35),
                            borderStrokeWidth: 1.2,
                          ),
                      ],
                    ),
                ],
              ),
              if (hasData)
                Positioned(
                  top: 10,
                  right: 10,
                  child: IgnorePointer(
                    child: _Pill(
                      text: l10n.riskHeatPill(l10n.riskHeatTurkeyWide, avg, bandLabel),
                      dotColor: riskHeatBandColor(band),
                      isDark: isDark,
                    ),
                  ),
                ),
              Positioned(
                right: 8,
                bottom: 4,
                child: OsmAttribution(
                  fontSize: 9,
                  halo: false,
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!hasData) return map;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        map,
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          key: const Key('riskMapLegend'),
          spacing: AppSpacing.md,
          runSpacing: 4,
          children: [
            _LegendEntry(color: riskHeatLowColor, label: l10n.mapRiskLegendLow),
            _LegendEntry(color: riskHeatMediumColor, label: l10n.mapRiskLegendMedium),
            _LegendEntry(color: riskHeatHighColor, label: l10n.mapRiskLegendHigh),
            _LegendEntry(color: riskHeatVeryHighColor, label: l10n.mapRiskLegendCritical),
          ],
        ),
      ],
    );
  }
}

class _LegendEntry extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendEntry({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 12, height: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.ibmPlexSans(fontSize: 11, color: Theme.of(context).textTheme.bodySmall?.color),
          ),
        ],
      );
}

List<double> _greyscale(double brightness) {
  const r = 0.2126, g = 0.7152, b = 0.0722;
  final k = brightness;
  return [
    r * k, g * k, b * k, 0, 0,
    r * k, g * k, b * k, 0, 0,
    r * k, g * k, b * k, 0, 0,
    0, 0, 0, 1, 0,
  ];
}

class _Pill extends StatelessWidget {
  final String text;
  final Color dotColor;
  final bool isDark;

  const _Pill({required this.text, required this.dotColor, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.surface : AppColors.lightSurface).withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimary : AppColors.lightText,
            ),
          ),
        ],
      ),
    );
  }
}
