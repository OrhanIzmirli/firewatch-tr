import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/risk_display.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/trust_info_card.dart';
import '../risk_components.dart';

/// What the score is made of, for a region, "Konumum" or a saved place:
/// one row per real component of the formula, with the reading behind it.
/// The points use the colour of the score's level, as on the map and list.
class RiskComponentsList extends StatelessWidget {
  /// A row of /risk/summary or the answer of /risk/point.
  final Map<String, dynamic> row;

  /// Replaces the region wording under the detections row. Points use it to
  /// name their search radius.
  final String? detectionsNote;

  const RiskComponentsList({super.key, required this.row, this.detectionsNote});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final titleColor = theme.textTheme.titleMedium?.color;
    final muted = theme.textTheme.bodySmall?.color;
    final score = (row['general_risk_score'] as num).toInt();
    final color = riskScoreColor(score);
    final breakdown = riskBreakdownFromRow(row);
    final heading = Text(
      l10n.riskComponentsTitle,
      style: GoogleFonts.ibmPlexSans(fontSize: 14, fontWeight: FontWeight.w700, color: titleColor),
    );

    if (breakdown == null) {
      return Column(
        key: const Key('riskComponentsUnavailable'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          heading,
          const SizedBox(height: 4),
          Text(l10n.riskComponentsUnavailable, style: GoogleFonts.ibmPlexSans(fontSize: 13, height: 1.4, color: muted)),
        ],
      );
    }

    final c = breakdown.components;
    final fireCount = breakdown.fireCount;
    final detectionsText = detectionsNote ??
        (fireCount == null
            ? l10n.riskComponentDetectionsUnknown
            : fireCount == 0
                ? l10n.riskComponentDetectionsNone
                : l10n.riskComponentDetections);

    return Column(
      key: const Key('riskComponents'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        heading,
        const SizedBox(height: AppSpacing.md),
        _ComponentRow(
          key: const Key('riskComponent-temperature'),
          icon: Icons.thermostat_rounded,
          label: l10n.commonTemperature,
          points: c.temperature,
          max: riskTemperatureMax,
          color: color,
          reading: '${breakdown.temperature.round()}°C',
          note: c.temperature == 0
              ? l10n.riskFactorTempHintNone
              : c.temperature >= 22
                  ? l10n.riskComponentTempHot
                  : l10n.riskComponentTempMild,
        ),
        _ComponentRow(
          key: const Key('riskComponent-humidity'),
          icon: Icons.water_drop_outlined,
          label: l10n.riskHumidity,
          points: c.humidity,
          max: riskHumidityMax,
          color: color,
          reading: l10n.riskPercent(breakdown.humidity.round()),
          note: c.humidity == 0
              ? l10n.riskFactorHumidityHintNone
              : c.humidity >= 20
                  ? l10n.riskComponentHumidityLow
                  : l10n.riskComponentHumidityMid,
        ),
        _ComponentRow(
          key: const Key('riskComponent-wind'),
          icon: Icons.air_rounded,
          label: l10n.riskComponentWindLabel,
          points: c.wind,
          max: riskWindMax,
          color: color,
          reading: '${breakdown.windSpeed.round()} km/h',
          note: c.wind == 0
              ? l10n.riskFactorWindHintNone
              : c.wind >= 18
                  ? l10n.riskComponentWindHigh
                  : l10n.riskComponentWindMid,
        ),
        _ComponentRow(
          key: const Key('riskComponent-detections'),
          icon: Icons.local_fire_department_rounded,
          label: l10n.riskPointNearbyTitle,
          points: c.detections,
          max: riskDetectionsMax,
          color: color,
          reading: fireCount == null ? l10n.riskComponentUnknownValue : l10n.riskComponentDetectionsValue(fireCount),
          note: breakdown.fireCountMatchesScore
              ? detectionsText
              : '$detectionsText ${l10n.riskComponentDetectionsChanged}',
        ),
        if (c.heatBonus > 0)
          _ComponentRow(
            key: const Key('riskComponent-bonus'),
            icon: Icons.wb_sunny_outlined,
            label: l10n.riskComponentBonus,
            points: c.heatBonus,
            max: riskHeatBonusMax,
            color: color,
            reading: null,
            note: l10n.riskComponentBonusNote,
          ),
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.riskComponentsTotal,
                style: GoogleFonts.ibmPlexSans(fontSize: 14, fontWeight: FontWeight.w800, color: titleColor),
              ),
            ),
            Text('$score/100', style: AppTheme.mono(size: 14, weight: FontWeight.w700, color: titleColor)),
          ],
        ),
        if (c.rawTotal > 100) ...[
          const SizedBox(height: 2),
          Text(l10n.riskComponentsCapped, style: GoogleFonts.ibmPlexSans(fontSize: 11.5, color: muted)),
        ],
        const SizedBox(height: AppSpacing.md),
        TrustInfoCard(
          key: const Key('riskComponentsMeaning'),
          title: l10n.trustAspectMeaningTitle,
          icon: Icons.info_outline_rounded,
          text: riskThresholdsText(l10n),
        ),
      ],
    );
  }
}

/// The real steps of the formula, written out from the tables of the port so
/// the text cannot disagree with the points shown above it.
String riskThresholdsText(AppLocalizations l10n) {
  String steps(List<(int, int)> table, String Function(int) bound) =>
      table.reversed.map((s) => '${bound(s.$1)} +${s.$2}').join(' · ');
  final [hot, warm] = riskHeatBonusTiers;
  return [
    l10n.riskScoresAreIndices,
    l10n.riskExplainSum,
    '${l10n.commonTemperature}: ${steps(riskTemperatureSteps, (v) => '≥$v°C')}',
    '${l10n.riskHumidity}: ${steps(riskHumiditySteps, (v) => '≤${l10n.riskPercent(v)}')}',
    '${l10n.riskComponentWindLabel}: ${steps(riskWindSteps, (v) => '≥$v km/h')}',
    '${l10n.riskPointNearbyTitle}: ${steps(riskDetectionSteps, (v) => '≥$v')}',
    l10n.riskExplainBonus(warm.$1, warm.$2, warm.$3, hot.$1, hot.$2, hot.$3),
    [l10n.mapRiskLegendLow, l10n.mapRiskLegendMedium, l10n.mapRiskLegendHigh, l10n.mapRiskLegendCritical].join(', '),
  ].join('\n');
}

class _ComponentRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final int points;
  final int max;
  final Color color;

  /// The measured value; null for the bonus, which has none of its own.
  final String? reading;
  final String note;

  const _ComponentRow({
    super.key,
    required this.icon,
    required this.label,
    required this.points,
    required this.max,
    required this.color,
    required this.reading,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleColor = theme.textTheme.titleMedium?.color;
    final muted = theme.textTheme.bodySmall?.color;
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: muted),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  reading == null ? label : '$label · $reading',
                  style: GoogleFonts.ibmPlexSans(fontSize: 13.5, fontWeight: FontWeight.w600, color: titleColor),
                ),
              ),
              Text('+$points/$max', style: AppTheme.mono(size: 13, weight: FontWeight.w700, color: titleColor)),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
            child: LinearProgressIndicator(
              value: points / max,
              minHeight: 4,
              backgroundColor: isDark ? AppColors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 4),
          Text(note, style: GoogleFonts.ibmPlexSans(fontSize: 12, height: 1.35, color: muted)),
        ],
      ),
    );
  }
}
