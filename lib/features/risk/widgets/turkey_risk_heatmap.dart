import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../l10n/app_localizations.dart';

// ── Scale ──────────────────────────────────────────────────────────────────
//
// The four FireWatch TR status colours and their score bands, as fixed in
// the design document. The heat layer blends between them; the pill uses
// the band a score falls in.

const Color riskHeatLowColor = Color(0xFF0CA30C); // 0–30
const Color riskHeatMediumColor = Color(0xFFFAB219); // 30–55
const Color riskHeatHighColor = Color(0xFFEC835A); // 55–80
const Color riskHeatVeryHighColor = Color(0xFFD03B3B); // 80–100

enum RiskHeatBand { low, medium, high, veryHigh }

/// Lower bound inclusive: 30 is medium, 55 is high, 80 is very high.
RiskHeatBand riskHeatBandFor(num score) {
  if (score >= 80) return RiskHeatBand.veryHigh;
  if (score >= 55) return RiskHeatBand.high;
  if (score >= 30) return RiskHeatBand.medium;
  return RiskHeatBand.low;
}

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

// Each colour sits at the middle of its band, so a score in the middle of
// a band gets exactly that band's colour and the edges blend.
const List<(double, Color)> _gradientStops = [
  (15, riskHeatLowColor),
  (42.5, riskHeatMediumColor),
  (67.5, riskHeatHighColor),
  (90, riskHeatVeryHighColor),
];

/// Continuous green → yellow → orange → red colour for a 0–100 score.
Color riskHeatGradientColor(double score) {
  if (score <= _gradientStops.first.$1) return _gradientStops.first.$2;
  for (var i = 1; i < _gradientStops.length; i++) {
    final (hi, hiColor) = _gradientStops[i];
    if (score <= hi) {
      final (lo, loColor) = _gradientStops[i - 1];
      return Color.lerp(loColor, hiColor, (score - lo) / (hi - lo))!;
    }
  }
  return _gradientStops.last.$2;
}

// ── Geometry ───────────────────────────────────────────────────────────────

/// Rough geographic centre of each of the seven regions, keyed by the raw
/// region name /api/risk/summary returns.
const Map<String, LatLng> riskRegionCentroids = {
  'Marmara': LatLng(40.35, 28.2),
  'Ege': LatLng(38.55, 28.4),
  'Akdeniz': LatLng(37.2, 33.2),
  'Ic Anadolu': LatLng(39.3, 33.6),
  'Karadeniz': LatLng(40.9, 36.8),
  'Dogu Anadolu': LatLng(39.2, 41.6),
  'Guneydogu Anadolu': LatLng(37.6, 39.8),
};

/// The box the raster covers and the camera opens on.
final LatLngBounds turkeyHeatBounds =
    LatLngBounds(const LatLng(35.7, 25.5), const LatLng(42.2, 45.0));

/// How far a region's score reaches, in degrees of latitude (≈200 km).
/// Large enough that neighbouring regions melt into each other instead of
/// reading as seven separate dots.
const double _kernelSigmaDeg = 1.8;

/// Raster width in pixels (≈0.05° per pixel). Height follows from the
/// Mercator aspect of [turkeyHeatBounds].
const int _rasterWidth = 390;

class RiskHeatRaster {
  final int width;
  final int height;

  /// Straight (non-premultiplied) RGBA, row-major, top row first.
  final Uint8List rgba;

  const RiskHeatRaster(this.width, this.height, this.rgba);
}

double _mercatorY(double latDeg) {
  final lat = latDeg * math.pi / 180;
  return math.log(math.tan(math.pi / 4 + lat / 2));
}

double _latFromMercatorY(double y) =>
    (2 * math.atan(math.exp(y)) - math.pi / 2) * 180 / math.pi;

/// Paints the smoothed score field into a raster that lines up with
/// [turkeyHeatBounds] once flutter_map projects it.
///
/// Every pixel gets a Gaussian-weighted average of the region scores, so
/// the field shades smoothly between centroids and never exceeds the
/// highest real score. Rows are spaced evenly in Mercator Y, the space
/// OverlayImage stretches the picture in, so the heat stays aligned with
/// the border at every zoom. Pixels outside [rings] (the national border,
/// even-odd rule) are left transparent.
RiskHeatRaster buildRiskHeatRaster(
  Map<String, double> regionScores,
  List<List<LatLng>> rings,
) {
  final points = <(LatLng, double)>[
    for (final e in regionScores.entries)
      if (riskRegionCentroids[e.key] != null)
        (riskRegionCentroids[e.key]!, e.value.clamp(0, 100).toDouble()),
  ];

  final west = turkeyHeatBounds.west;
  final east = turkeyHeatBounds.east;
  final yTop = _mercatorY(turkeyHeatBounds.north);
  final yBottom = _mercatorY(turkeyHeatBounds.south);
  final lonSpanRad = (east - west) * math.pi / 180;
  const width = _rasterWidth;
  final height = math.max(1, (width * (yTop - yBottom) / lonSpanRad).round());
  final rgba = Uint8List(width * height * 4);
  if (points.isEmpty) return RiskHeatRaster(width, height, rgba);

  const twoSigmaSq = 2 * _kernelSigmaDeg * _kernelSigmaDeg;
  final lonStep = (east - west) / width;

  for (var row = 0; row < height; row++) {
    final lat = _latFromMercatorY(yTop - (row + 0.5) / height * (yTop - yBottom));
    // Degrees of longitude are shorter than degrees of latitude here.
    final lonScale = math.cos(lat * math.pi / 180);

    // Where this row crosses the border; inside is between pairs.
    final crossings = <double>[];
    for (final ring in rings) {
      for (var i = 0, j = ring.length - 1; i < ring.length; j = i++) {
        final a = ring[i];
        final b = ring[j];
        if ((a.latitude > lat) != (b.latitude > lat)) {
          crossings.add(a.longitude +
              (lat - a.latitude) / (b.latitude - a.latitude) * (b.longitude - a.longitude));
        }
      }
    }
    crossings.sort();

    for (var k = 0; k + 1 < crossings.length; k += 2) {
      final startCol = math.max(0, ((crossings[k] - west) / lonStep - 0.5).ceil());
      final endCol = math.min(width - 1, ((crossings[k + 1] - west) / lonStep - 0.5).floor());
      for (var col = startCol; col <= endCol; col++) {
        final lon = west + (col + 0.5) * lonStep;
        var weightSum = 0.0;
        var scoreSum = 0.0;
        for (final (c, s) in points) {
          final dLat = lat - c.latitude;
          final dLon = (lon - c.longitude) * lonScale;
          final w = math.exp(-(dLat * dLat + dLon * dLon) / twoSigmaSq);
          weightSum += w;
          scoreSum += w * s;
        }
        // Far from every centroid all weights underflow; nearest wins then.
        final score = weightSum > 1e-12 ? scoreSum / weightSum : _nearestScore(points, lat, lon);
        final color = riskHeatGradientColor(score);
        final o = (row * width + col) * 4;
        rgba[o] = (color.r * 255).round();
        rgba[o + 1] = (color.g * 255).round();
        rgba[o + 2] = (color.b * 255).round();
        rgba[o + 3] = 255;
      }
    }
  }
  return RiskHeatRaster(width, height, rgba);
}

double _nearestScore(List<(LatLng, double)> points, double lat, double lon) {
  var best = double.infinity;
  var score = 0.0;
  for (final (c, s) in points) {
    final d = math.pow(lat - c.latitude, 2) + math.pow(lon - c.longitude, 2);
    if (d < best) {
      best = d.toDouble();
      score = s;
    }
  }
  return score;
}

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

Future<Uint8List> _encodePng(RiskHeatRaster raster) async {
  final buffer = await ui.ImmutableBuffer.fromUint8List(raster.rgba);
  final descriptor = ui.ImageDescriptor.raw(
    buffer,
    width: raster.width,
    height: raster.height,
    pixelFormat: ui.PixelFormat.rgba8888,
  );
  final codec = await descriptor.instantiateCodec();
  final frame = await codec.getNextFrame();
  final bytes = await frame.image.toByteData(format: ui.ImageByteFormat.png);
  frame.image.dispose();
  codec.dispose();
  descriptor.dispose();
  buffer.dispose();
  return bytes!.buffer.asUint8List();
}

// ── Widget ─────────────────────────────────────────────────────────────────

/// Nationwide wildfire-risk heat map for the Risk screen. Separate from the
/// incident map: no fires, no markers, only the regional risk scores.
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
  ImageProvider? _heatImage;
  int _buildToken = 0;

  @override
  void initState() {
    super.initState();
    _rebuild();
  }

  @override
  void didUpdateWidget(TurkeyRiskHeatmap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!mapEquals(oldWidget.regionScores, widget.regionScores)) _rebuild();
  }

  Future<void> _rebuild() async {
    final token = ++_buildToken;
    try {
      final outline = await loadTurkeyOutline();
      if (!mounted || token != _buildToken) return;
      setState(() => _outline = outline);
      if (widget.regionScores.isEmpty) {
        setState(() => _heatImage = null);
        return;
      }
      final png = await _encodePng(buildRiskHeatRaster(widget.regionScores, outline));
      if (!mounted || token != _buildToken) return;
      setState(() => _heatImage = MemoryImage(png));
    } catch (e) {
      // A broken asset or codec must not take the Risk screen down; the
      // map simply stays without the heat layer.
      if (kDebugMode) debugPrint('Risk heat map build failed: $e');
    }
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
        return l10n.riskHeatLevelVeryHigh;
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

    return Semantics(
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
                  backgroundColor: background,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.oguzh.firewatch.firewatch_tr',
                    // Greyscale (and dimmed in dark mode) so the only colour
                    // on the map is the risk itself.
                    tileBuilder: (context, tile, _) => ColorFiltered(
                      colorFilter: ColorFilter.matrix(_greyscale(isDark ? 0.55 : 1.0)),
                      child: tile,
                    ),
                  ),
                  if (hasData && _heatImage != null)
                    OverlayImageLayer(
                      overlayImages: [
                        OverlayImage(
                          bounds: turkeyHeatBounds,
                          imageProvider: _heatImage!,
                          opacity: 0.78,
                          filterQuality: FilterQuality.high,
                        ),
                      ],
                    ),
                  if (outline.isNotEmpty)
                    PolygonLayer(
                      polygons: [
                        for (final ring in outline)
                          Polygon(
                            points: ring,
                            color: hasData
                                ? null
                                : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.10),
                            borderColor: hasData ? borderColor : borderColor.withValues(alpha: 0.35),
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
                child: IgnorePointer(
                  child: Text(
                    '© OpenStreetMap',
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 9,
                      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.55),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
