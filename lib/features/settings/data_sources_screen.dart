import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/glass_panel.dart';

/// Where every number in this app comes from, and what it does not mean.
///
/// It exists because several figures the app used to show were derived rather
/// than measured, and nothing on screen said so. A satellite pixel's footprint
/// was published as the fire's area, attributed to NASA; a regional weather
/// score was phrased as a statement about one specific fire. Both are fixed,
/// but the fix that lasts is a page a reader can check the claims against.
class DataSourcesScreen extends StatelessWidget {
  const DataSourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor =
        Theme.of(context).textTheme.titleLarge?.color ??
        (isDark ? AppColors.white : AppColors.lightText);
    final bodyColor = isDark
        ? AppColors.white.withValues(alpha: 0.72)
        : Colors.black.withValues(alpha: 0.68);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.dataSourcesTitle,
          style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _Section(
            icon: Icons.satellite_alt_rounded,
            title: l10n.dataSourcesSatelliteTitle,
            body: l10n.dataSourcesSatelliteBody,
            titleColor: titleColor,
            bodyColor: bodyColor,
          ),
          const SizedBox(height: AppSpacing.md),
          _Section(
            icon: Icons.hub_rounded,
            title: l10n.dataSourcesGroupingTitle,
            body: l10n.dataSourcesGroupingBody,
            titleColor: titleColor,
            bodyColor: bodyColor,
          ),
          const SizedBox(height: AppSpacing.md),
          _Section(
            icon: Icons.straighten_rounded,
            title: l10n.dataSourcesDerivedTitle,
            body: l10n.dataSourcesDerivedBody,
            titleColor: titleColor,
            bodyColor: bodyColor,
          ),
          const SizedBox(height: AppSpacing.md),
          _Section(
            icon: Icons.block_rounded,
            title: l10n.dataSourcesNotKnownTitle,
            body: l10n.dataSourcesNotKnownBody,
            titleColor: titleColor,
            bodyColor: bodyColor,
          ),
          const SizedBox(height: AppSpacing.md),
          _Section(
            icon: Icons.cloud_outlined,
            title: l10n.dataSourcesWeatherTitle,
            body: l10n.dataSourcesWeatherBody,
            titleColor: titleColor,
            bodyColor: bodyColor,
          ),
          const SizedBox(height: AppSpacing.md),
          _Section(
            icon: Icons.thermostat_rounded,
            title: l10n.dataSourcesFwiTitle,
            body: l10n.dataSourcesFwiBody,
            titleColor: titleColor,
            bodyColor: bodyColor,
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final Color titleColor;
  final Color bodyColor;

  const _Section({
    required this.icon,
    required this.title,
    required this.body,
    required this.titleColor,
    required this.bodyColor,
  });

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            body,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 13,
              height: 1.55,
              color: bodyColor,
            ),
          ),
        ],
      ),
    );
  }
}
