import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/fire_incident.dart';

/// Compact key for the three event categories.
///
/// Kept to three rows and no more: the map has one job, and a legend that
/// needs reading twice has already failed. There is deliberately no fourth
/// "extinguished" row — that state cannot be derived from satellite data.
class IncidentLegend extends StatelessWidget {
  const IncidentLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark
        ? AppColors.white.withValues(alpha: 0.78)
        : Colors.black.withValues(alpha: 0.7);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final status in IncidentStatus.values)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(status.icon, size: 16, color: status.color),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  status.label(l10n),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: labelColor,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
