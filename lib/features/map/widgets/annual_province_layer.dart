import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/annual_province_data.dart';
import '../../../models/geo_area.dart';
import '../../../shared/widgets/province_borders_credit.dart';
import '../../../shared/widgets/app_sheet.dart';

class AnnualProvinceLayer extends StatefulWidget {
  final AnnualProvinceData data;
  final int year;
  const AnnualProvinceLayer({
    super.key,
    required this.data,
    required this.year,
  });
  @override
  State<AnnualProvinceLayer> createState() => _AnnualProvinceLayerState();
}

class _AnnualProvinceLayerState extends State<AnnualProvinceLayer> {
  final LayerHitNotifier<String> _hit = ValueNotifier(null);
  String? _selected;
  @override
  void dispose() {
    _hit.dispose();
    super.dispose();
  }

  void _select() {
    final id = _hit.value?.hitValues.firstOrNull;
    final area = widget.data.areas.where((a) => a.id == id).firstOrNull;
    if (area == null) return;
    setState(() => _selected = id);
    showAppSheet<void>(
      context,
      // The app's own dark surface (the content below is styled for a dark
      // sheet); the navy used here matched nothing else in the app.
      color: AppColors.surface,
      builder: (_) => AnnualProvinceDetails(
        data: widget.data,
        area: area,
        year: widget.year,
      ),
    );
  }

  /// Built once per data/year and reused as the same widget instance:
  /// flutter_map re-projects every vertex of a PolygonLayer whose widget
  /// changes, and this one is all 81 provinces. The tapped province is
  /// outlined by a small layer of its own on top.
  late PolygonLayer<String> _baseLayer = _buildBaseLayer();

  @override
  void didUpdateWidget(covariant AnnualProvinceLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data || oldWidget.year != widget.year) {
      _baseLayer = _buildBaseLayer();
    }
  }

  PolygonLayer<String> _buildBaseLayer() => PolygonLayer<String>(
        hitNotifier: _hit,
        polygons: [
          for (final area in widget.data.areas)
            for (final polygon in area.polygons)
              Polygon<String>(
                points: polygon.first,
                holePointsList: polygon.skip(1).toList(),
                hitValue: area.id,
                color: widget.data.color(area.id, widget.year),
                borderColor: const Color(0x590E0500),
                borderStrokeWidth: 0.8,
              ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final selected = _selected == null
        ? null
        : widget.data.areas.where((a) => a.id == _selected).firstOrNull;
    return GestureDetector(
      onTap: _select,
      child: Stack(
        children: [
          _baseLayer,
          if (selected != null)
            PolygonLayer<String>(
              polygons: [
                for (final polygon in selected.polygons)
                  Polygon<String>(
                    points: polygon.first,
                    holePointsList: polygon.skip(1).toList(),
                    color: Colors.transparent,
                    borderColor: const Color(0xFFF97316),
                    borderStrokeWidth: 2,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class AnnualProvinceDetails extends StatefulWidget {
  final AnnualProvinceData data;
  final GeoArea area;
  final int year;
  const AnnualProvinceDetails({
    super.key,
    required this.data,
    required this.area,
    required this.year,
  });
  @override
  State<AnnualProvinceDetails> createState() => _AnnualProvinceDetailsState();
}

class _AnnualProvinceDetailsState extends State<AnnualProvinceDetails> {
  /// Which value's explanation is shown. Selecting a chip only changes the
  /// explanation and highlights that value's card; the province colour on
  /// the map is always OGM burned area.
  int _metric = 0;
  static const keys = [
    'ogm_yanan_alan_ha',
    'ogm_yangin_sayisi',
    'uydu_orman_maki_noktasi',
    'effis_yanan_alan_ha',
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final labels = [
      l10n.annualMetricOgmArea,
      l10n.annualMetricOgmCount,
      l10n.annualMetricSatellite,
      l10n.annualMetricEffisArea,
    ];
    final descriptions = [
      l10n.annualMetricOgmAreaDesc,
      l10n.annualMetricOgmCountDesc,
      l10n.annualMetricSatelliteDesc,
      l10n.annualMetricEffisAreaDesc,
    ];
    return SafeArea(
    child: SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.72,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Chip(
              label: Text(l10n.annualPastYearChip(widget.year)),
              backgroundColor: const Color(0xFF422B25),
              labelStyle: const TextStyle(color: Color(0xFFF97316)),
            ),
          ),
          Text(
            widget.area.city,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) => Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(4, (i) {
                final value = widget.data.value(
                  widget.area.id,
                  widget.year,
                  keys[i],
                );
                final formatted = value == null
                    ? l10n.annualNoData
                    : NumberFormat(
                        i == 0 || i == 3 ? '#,##0.##' : '#,##0',
                        l10n.localeName,
                      ).format(value);
                return SizedBox(
                  width:
                      constraints.maxWidth >= 320 &&
                          MediaQuery.textScalerOf(context).scale(1) <= 1.3
                      ? (constraints.maxWidth - 10) / 2
                      : constraints.maxWidth,
                  child: Card(
                    color: const Color(0xFF121826),
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(
                        color: _metric == i
                            ? const Color(0xFFF97316)
                            : const Color(0xFF222836),
                        width: _metric == i ? 1.5 : 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            labels[i],
                            style: const TextStyle(color: Color(0xFF9CA3AF)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$formatted${value != null && (i == 0 || i == 3) ? ' ha' : ''}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                              color: i == 0
                                  ? const Color(0xFFF97316)
                                  : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.annualMetricExplainTitle,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 2),
          Text(
            l10n.annualMetricExplainHint,
            style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: List.generate(
              4,
              (i) => ChoiceChip(
                avatar: const Icon(Icons.info_outline, size: 16),
                label: Text(labels[i]),
                selected: _metric == i,
                onSelected: (_) => setState(() => _metric = i),
              ),
            ),
          ),
          Text(descriptions[_metric]),
          const SizedBox(height: 12),
          Text(l10n.annualProvinceNote),
          const SizedBox(height: 16),
          const ProvinceBordersCredit(color: Color(0xFF9CA3AF), fontSize: 11),
        ],
      ),
    ),
  );
  }
}

/// Colour key for the province layer. The gradient's stops sit at equal
/// steps, and so do [AnnualProvinceData.color]'s on the log scale, so each
/// tick is labelled with the hectares its stop stands for (≈ 0 · 40 · 1.500 ·
/// 60.000 ha for the bundled log_max of 4.7808).
class AnnualLegend extends StatelessWidget {
  /// The data file's renk.log_max; the bundled file's value by default.
  final double logMax;
  const AnnualLegend({super.key, this.logMax = defaultLogMax});

  static const double defaultLogMax = 4.7808;

  /// Rounds to the nearest half of the leading power of ten, so the ticks
  /// read as round numbers: 38.2 → 40, 1537.9 → 1500, 60366 → 60000.
  static double roundedTick(double hectares) {
    if (hectares < 1) return 0;
    final step =
        math.pow(10, (math.log(hectares) / math.ln10).floor()).toDouble() / 2;
    return (hectares / step).round() * step;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final format = NumberFormat('#,##0', l10n.localeName);
    final ticks = [
      for (var i = 0; i < AnnualProvinceData.stops.length; i++)
        format.format(
          roundedTick(AnnualProvinceData.hectaresAtStop(logMax, i)),
        ),
    ];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.annualLegendTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Container(
            height: 18,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              gradient: const LinearGradient(colors: AnnualProvinceData.stops),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < ticks.length; i++)
                Text(
                  i == ticks.length - 1
                      ? l10n.annualLegendTickMax(ticks[i])
                      : ticks[i],
                  style: const TextStyle(
                    fontSize: 12,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(l10n.annualLegendNote, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
