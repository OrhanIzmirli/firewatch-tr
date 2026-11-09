import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/risk_display.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/annual_province_data.dart';
import 'annual_province_layer.dart';
import 'map_sources.dart';

/// What the "Layers" button opens: each colour layer as a small preview, one
/// plain line and a switch. A layer that is on also shows its colour scale.
/// Rows, years and legends wrap, so nothing has to be scrolled sideways.
class MapLayersPanel extends StatelessWidget {
  final bool riskOn;
  final bool riskFailed;
  final VoidCallback onToggleRisk;

  final bool annualOn;
  final bool annualLoading;
  final bool annualFailed;
  final int annualYear;
  final double annualLogMax;
  final VoidCallback onToggleAnnual;
  final ValueChanged<int> onYearSelected;

  /// The marker key for whichever fire layer is on.
  final Widget markerLegend;

  const MapLayersPanel({
    super.key,
    required this.riskOn,
    required this.riskFailed,
    required this.onToggleRisk,
    required this.annualOn,
    required this.annualLoading,
    required this.annualFailed,
    required this.annualYear,
    required this.annualLogMax,
    required this.onToggleAnnual,
    required this.onYearSelected,
    required this.markerLegend,
  });

  static const _riskPreview = [
    AppColors.riskLow,
    AppColors.riskMedium,
    AppColors.riskHigh,
    AppColors.riskMedium,
    AppColors.riskHigh,
    AppColors.riskCritical,
  ];

  static final _annualPreview = [
    AnnualProvinceData.stops[0],
    AnnualProvinceData.stops[2],
    AnnualProvinceData.stops[1],
    AnnualProvinceData.stops[1],
    AnnualProvinceData.stops[0],
    AnnualProvinceData.stops[3],
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final divider = Divider(height: AppSpacing.xl, color: theme.dividerColor.withValues(alpha: 0.5));
    final textStyle = theme.textTheme.bodySmall;
    return Padding(
      key: const Key('mapLayersPanel'),
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.mapLayersButton,
            style: GoogleFonts.ibmPlexSans(fontSize: 18, fontWeight: FontWeight.w800, color: theme.textTheme.titleLarge?.color),
          ),
          const SizedBox(height: AppSpacing.md),
          _LayerRow(
            switchKey: const Key('layerSwitchRisk'),
            colors: _riskPreview,
            title: l10n.mapRiskLayer,
            description: l10n.mapLayerRiskDesc,
            value: riskOn,
            onToggle: onToggleRisk,
          ),
          if (riskOn) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              riskFailed ? l10n.mapRiskUnavailable : l10n.riskColorsNotFire,
              style: textStyle?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.sm),
            _Swatch(color: colorForApiRiskLevel('Low'), label: l10n.mapRiskLegendLow),
            _Swatch(color: colorForApiRiskLevel('Medium'), label: l10n.mapRiskLegendMedium),
            _Swatch(color: colorForApiRiskLevel('High'), label: l10n.mapRiskLegendHigh),
            _Swatch(color: colorForApiRiskLevel('Critical'), label: l10n.mapRiskLegendCritical),
            const MapSourcesLink(topic: MapSourcesTopic.risk),
          ],
          divider,
          _LayerRow(
            switchKey: const Key('layerSwitchAnnual'),
            colors: _annualPreview,
            title: l10n.annualLayerToggle,
            description: l10n.mapLayerAnnualDesc,
            value: annualOn,
            onToggle: onToggleAnnual,
          ),
          if (annualOn) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final year in AnnualProvinceData.years)
                  ChoiceChip(
                    key: Key('layerYear-$year'),
                    visualDensity: VisualDensity.compact,
                    label: Text('$year'),
                    selected: annualYear == year,
                    onSelected: (_) => onYearSelected(year),
                  ),
              ],
            ),
            if (annualLoading) const LinearProgressIndicator(minHeight: 2),
            if (annualFailed)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(l10n.annualLayerLoadError, style: textStyle?.copyWith(color: AppColors.warning)),
              ),
            AnnualLegend(logMax: annualLogMax, padding: const EdgeInsets.only(top: AppSpacing.md)),
            const MapSourcesLink(topic: MapSourcesTopic.annual),
          ],
          divider,
          Text(l10n.mapLegendTitle, style: textStyle?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          markerLegend,
        ],
      ),
    );
  }
}

class _LayerRow extends StatelessWidget {
  final Key switchKey;
  final List<Color> colors;
  final String title;
  final String description;
  final bool value;
  final VoidCallback onToggle;

  const _LayerRow({
    required this.switchKey,
    required this.colors,
    required this.title,
    required this.description,
    required this.value,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      onTap: onToggle,
      child: Row(
        children: [
          _LayerPreview(colors: colors),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.ibmPlexSans(fontSize: 14.5, fontWeight: FontWeight.w700, color: theme.textTheme.titleLarge?.color),
                ),
                Text(
                  description,
                  style: GoogleFonts.ibmPlexSans(fontSize: 12.5, height: 1.3, color: theme.textTheme.bodySmall?.color),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Switch(key: switchKey, value: value, onChanged: (_) => onToggle()),
        ],
      ),
    );
  }
}

/// A miniature choropleth in the layer's own colours.
class _LayerPreview extends StatelessWidget {
  final List<Color> colors;

  const _LayerPreview({required this.colors});

  @override
  Widget build(BuildContext context) {
    Widget row(Iterable<Color> cells) => Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final c in cells)
                Expanded(child: Padding(padding: const EdgeInsets.all(0.5), child: ColoredBox(color: c))),
            ],
          ),
        );
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: ColoredBox(
        color: AppColors.background,
        child: SizedBox(
          width: 56,
          height: 44,
          child: Column(children: [row(colors.take(3)), row(colors.skip(3))]),
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  final Color color;
  final String label;

  const _Swatch({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 12,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(label, style: Theme.of(context).textTheme.bodySmall)),
          ],
        ),
      );
}
