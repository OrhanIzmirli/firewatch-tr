import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/risk_display.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/color_dot.dart';
import '../../../shared/widgets/glass_panel.dart';

num? _number(Object? value) => value is num ? value : num.tryParse('$value');

/// Change in the national average since the previous run, over the regions
/// that have a previous score. Null when there is no real change to report:
/// no history, or a move of less than one point.
double? riskTrendDelta(List<Map<String, dynamic>> regions) {
  var current = 0.0;
  var previous = 0.0;
  var count = 0;
  for (final region in regions) {
    final now = _number(region['general_risk_score']);
    final before = region['previous_risk_score'] == null ? null : _number(region['previous_risk_score']);
    if (now == null || before == null) continue;
    current += now;
    previous += before;
    count++;
  }
  if (count == 0) return null;
  final delta = (current - previous) / count;
  return delta.abs() >= 1 ? delta : null;
}

/// "Akdeniz: Orta". A level is never shown without the place it belongs to.
String riskPlaceLevel(AppLocalizations l10n, String place, num score) =>
    l10n.riskRegionLevel(place, riskLevelLabel(l10n, riskLevelForScore(score)));

/// The one region list of the Risk screen: name with level, score and a
/// short weather line, highest score first. Tapping a row opens its detail.
class RiskRegionList extends StatelessWidget {
  /// Rows of /risk/summary, in display order.
  final List<Map<String, dynamic>> regions;

  /// Raw region key of the user's region, highlighted when known.
  final String? myRegion;
  final ValueChanged<Map<String, dynamic>> onRegionTap;

  const RiskRegionList({super.key, required this.regions, required this.onRegionTap, this.myRegion});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs, horizontal: AppSpacing.xs),
      child: Column(
        children: [
          for (final (index, region) in regions.indexed) ...[
            if (index > 0) const Divider(height: 1),
            _RegionRow(
              region: region,
              isMine: myRegion != null && region['region'] == myRegion,
              onTap: () => onRegionTap(region),
            ),
          ],
        ],
      ),
    );
  }
}

class _RegionRow extends StatelessWidget {
  final Map<String, dynamic> region;
  final bool isMine;
  final VoidCallback onTap;

  const _RegionRow({required this.region, required this.isMine, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final titleColor = theme.textTheme.titleMedium?.color;
    final muted = theme.textTheme.bodySmall?.color;
    final raw = '${region['region']}';
    final score = (region['general_risk_score'] as num).toInt();
    String reading(String key) => '${(_number(region[key]) ?? 0).round()}';

    return InkWell(
      key: Key('riskRegionRow-$raw'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 11),
        decoration: isMine
            ? BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              )
            : null,
        child: Row(
          children: [
            ColorDot(color: riskScoreColor(score), size: 12),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    riskPlaceLevel(l10n, displayRegionName(l10n, raw), score),
                    style: GoogleFonts.ibmPlexSans(fontSize: 15, fontWeight: FontWeight.w700, color: titleColor),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.riskRegionWeather(reading('temperature'), reading('humidity'), reading('wind_speed')),
                    style: GoogleFonts.ibmPlexSans(fontSize: 12, color: muted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text('$score/100', style: AppTheme.mono(size: 14, weight: FontWeight.w700, color: titleColor)),
            Icon(Icons.chevron_right_rounded, size: 20, color: muted),
          ],
        ),
      ),
    );
  }
}
