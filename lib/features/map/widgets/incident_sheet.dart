import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/fire_incident.dart';
import '../../../shared/widgets/detection_safety_notice.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../../../shared/widgets/app_sheet.dart';
import '../../../core/utils/detection_summary.dart';
import '../../../shared/widgets/related_news_section.dart';
import 'package:url_launcher/url_launcher.dart';

/// Detail panel for one clustered fire event.
///
/// The layout is ordered by what a worried person asks first: what is this,
/// where, how long, is it still being seen, how strong, which way is it
/// going. Everything the data cannot support is absent rather than shown
/// empty — an unknown spread direction is simply not a section.
class IncidentSheet extends StatelessWidget {
  final FireIncident incident;
  final String? cityName;

  const IncidentSheet({super.key, required this.incident, this.cityName});

  static Future<void> show(
    BuildContext context, {
    required FireIncident incident,
    String? cityName,
  }) {
    return showAppSheet(
      context,
      bare: true,
      builder: (_) => IncidentSheet(incident: incident, cityName: cityName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final status = incident.status;
    final place = cityName ?? incident.cityName;
    final strong = incident.isSignificant || (incident.maxFrpMw ?? 0) >= 15;
    final fresh = incident.hoursSinceLastDetection <= 6;
    final titleColor = Theme.of(context).textTheme.titleMedium?.color ??
        (isDark ? AppColors.white : AppColors.lightText);
    final bodyColor = isDark
        ? AppColors.white.withValues(alpha: 0.72)
        : Colors.black.withValues(alpha: 0.66);

    return DraggableScrollableSheet(
      initialChildSize: 0.62,
      minChildSize: 0.4,
      maxChildSize: kSheetMaxHeightFraction,
      expand: false,
      builder: (context, controller) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surface : Colors.white,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSpacing.largeCardRadius),
          ),
        ),
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xxl,
          ),
          children: [
            const SheetHeader(),
            const SizedBox(height: AppSpacing.xl),

            _StatusHeader(status: status, titleColor: titleColor),
            const SizedBox(height: AppSpacing.lg),
            Text(
              detectionSummaryText(
                l10n,
                city: place,
                strong: strong,
                newsVerified: incident.newsVerification != null,
                landCover: incident.landCover,
                age: Duration(minutes: (incident.hoursSinceLastDetection * 60).round()),
              ),
              key: const Key('incidentSummary'),
              style: GoogleFonts.ibmPlexSans(fontSize: 15, height: 1.5, fontWeight: FontWeight.w600, color: titleColor),
            ),
            const SizedBox(height: AppSpacing.md),
            // 112 is on every card; only how loud it is changes.
            DetectionSafetyNotice(prominent: fresh && strong && !incident.isKeptOffEvents),
            const SizedBox(height: AppSpacing.lg),

            if (incident.newsVerification case final news?) ...[
              _NewsVerified(news: news, titleColor: titleColor, bodyColor: bodyColor),
              const SizedBox(height: AppSpacing.md),
            ],

            // Official "extinguished" while a satellite still sees heat.
            // Only reachable behind FeatureFlags.officialStatus.
            if (incident.hasExtinguishedConflict) ...[
              _Line(
                icon: Icons.report_problem_rounded,
                text: l10n.incidentExtinguishedConflict,
                color: AppColors.warning,
                emphasis: true,
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            _Line(
              icon: Icons.satellite_alt_rounded,
              text: incident.overpassCount >= 2
                  ? l10n.incidentSeenPasses(incident.overpassCount)
                  : l10n.incidentSeenOnce,
              color: bodyColor,
            ),
            if (incident.overpassCount >= 2 && incident.durationHours >= 1) ...[
              const SizedBox(height: AppSpacing.sm),
              _Line(
                icon: Icons.schedule_rounded,
                text: l10n.incidentDurationOngoing(_hours(incident.durationHours)),
                color: bodyColor,
              ),
            ],

            if (incident.maxFrpMw != null) ...[
              const SizedBox(height: AppSpacing.xl),
              _HeatMeter(frpMw: incident.maxFrpMw!, titleColor: titleColor, bodyColor: bodyColor),
            ],

            // Shown only when the backend judged the evidence sufficient.
            // An unknown direction is not displayed as unknown — it is not
            // displayed at all.
            if (incident.hasSpread) ...[
              const SizedBox(height: AppSpacing.xl),
              _SpreadCard(incident: incident, titleColor: titleColor, bodyColor: bodyColor),
            ],

            // Direction of change in radiated heat. Absent unless the
            // backend published one, and the caveat underneath is not
            // optional: the satellite measures heat, not firefighting.
            if (incident.hasTrend) ...[
              const SizedBox(height: AppSpacing.xl),
              _TrendCard(
                incident: incident,
                titleColor: titleColor,
                bodyColor: bodyColor,
              ),
            ],

            // An observation, not a verdict, and never a reason to hide the
            // event. "May be" is the honest strength of this evidence.
            if (incident.looksLikeFixedSource) ...[
              const SizedBox(height: AppSpacing.xl),
              GlassPanel(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.factory_outlined,
                      size: 18,
                      color: bodyColor,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        incident.isPersistentHeatSource
                            ? l10n.incidentPersistentHeatSourceNote(
                                incident.distinctDaysSeen ?? 7,
                              )
                            : l10n.incidentFixedSourceHint,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 12.5,
                          height: 1.5,
                          color: bodyColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Reads official.state but never invents it, and only behind
            // FeatureFlags.officialStatus (off until a TR source exists).
            if (incident.hasShownOfficialStatus) ...[
              const SizedBox(height: AppSpacing.xl),
              _OfficialCard(incident: incident, titleColor: titleColor, bodyColor: bodyColor),
            ],

            RelatedNewsSection(city: place, from: incident.firstDetectedAt ?? DateTime.now(), to: incident.lastDetectedAt ?? DateTime.now()),

            Material(
              type: MaterialType.transparency,
              child: ExpansionTile(
                key: const Key('incidentTechnicalDetails'),
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(bottom: AppSpacing.sm),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                title: Text(
                  l10n.commonAllTechnical,
                  style: GoogleFonts.ibmPlexSans(fontSize: 13.5, fontWeight: FontWeight.w600, color: titleColor),
                ),
                children: [
                  _Line(
                    icon: Icons.scatter_plot_rounded,
                    text: l10n.incidentEvidence(incident.detectionCount, incident.overpassCount),
                    color: bodyColor,
                  ),
                  if (incident.maxFrpMw != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      l10n.incidentPeakPowerDetail(incident.maxFrpMw!.toStringAsFixed(incident.maxFrpMw! < 10 ? 1 : 0)),
                      style: AppTheme.mono(size: 13, weight: FontWeight.w700, color: bodyColor),
                    ),
                  ],
                  if (incident.sources.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _Line(
                      icon: Icons.sensors_rounded,
                      text: incident.sources.map((s) => '${s.label} (${s.count})').join(' · '),
                      color: bodyColor,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),
            GlassPanel(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, size: 18, color: bodyColor),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      l10n.incidentSatelliteLimitNote,
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 12.5, height: 1.5, color: bodyColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _hours(double value) =>
      value < 10 ? value.toStringAsFixed(1) : value.round().toString();
}

class _NewsVerified extends StatelessWidget {
  final IncidentNews news;
  final Color titleColor;
  final Color bodyColor;

  const _NewsVerified({required this.news, required this.titleColor, required this.bodyColor});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      key: const Key('incidentNewsVerified'),
      onTap: news.url == null ? null : () => launchUrl(Uri.parse(news.url!), mode: LaunchMode.externalApplication),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.verified_rounded, size: 18, color: AppColors.success),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.newsVerifiedLabel, style: GoogleFonts.ibmPlexSans(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.success)),
                Text(news.title, style: GoogleFonts.ibmPlexSans(fontSize: 13.5, height: 1.35, color: titleColor)),
                if (news.source != null) Text(news.source!, style: GoogleFonts.ibmPlexSans(fontSize: 12, color: bodyColor)),
              ],
            ),
          ),
          if (news.url != null) const Icon(Icons.open_in_new_rounded, size: 16, color: AppColors.primary),
        ],
      ),
    );
  }
}

class _StatusHeader extends StatelessWidget {
  final IncidentStatus status;
  final Color titleColor;

  const _StatusHeader({required this.status, required this.titleColor});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: status.color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          ),
          child: Icon(status.icon, color: status.color, size: 28),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.incidentPanelTitle,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                  color: titleColor.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                status.label(l10n),
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: status.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final bool emphasis;

  const _Line({
    required this.icon,
    required this.text,
    required this.color,
    this.emphasis = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color.withValues(alpha: emphasis ? 1 : 0.7)),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.ibmPlexSans(
              fontSize: emphasis ? 16 : 14,
              fontWeight: emphasis ? FontWeight.w700 : FontWeight.w500,
              height: 1.45,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

/// Radiative power turned into something a person can act on. The number
/// itself is under "Tüm teknik bilgiler".
class _HeatMeter extends StatelessWidget {
  final double frpMw;
  final Color titleColor;
  final Color bodyColor;

  const _HeatMeter({
    required this.frpMw,
    required this.titleColor,
    required this.bodyColor,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Same words as the sentence above it: what counts as strong there
    // (8 MW and up) never reads "weak" here.
    final (label, fill, color) = frpMw >= 50
        ? (l10n.incidentHeatVeryHigh, 1.0, AppColors.danger)
        : frpMw >= 8
            ? (l10n.incidentHeatHigh, 0.6, AppColors.primary)
            : (l10n.incidentHeatLow, 0.25, AppColors.warning);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.whatshot_rounded, size: 18, color: bodyColor),
            const SizedBox(width: AppSpacing.md),
            Text(
              l10n.incidentHeatLabel,
              style: GoogleFonts.ibmPlexSans(
                fontSize: 13, fontWeight: FontWeight.w600, color: bodyColor,
              ),
            ),
            const Spacer(),
            Text(
              label,
              style: GoogleFonts.ibmPlexSans(
                fontSize: 13, fontWeight: FontWeight.w700, color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
          child: LinearProgressIndicator(
            value: fill,
            minHeight: 6,
            backgroundColor: bodyColor.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

/// "Heat intensity is decreasing" — and a line saying what that is not.
class _TrendCard extends StatelessWidget {
  final FireIncident incident;
  final Color titleColor;
  final Color bodyColor;

  const _TrendCard({
    required this.incident,
    required this.titleColor,
    required this.bodyColor,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (IconData icon, Color color, String text) = switch (incident.frpTrend) {
      'weakening' => (
          Icons.trending_down_rounded,
          AppColors.success,
          l10n.incidentTrendWeakening,
        ),
      'intensifying' => (
          Icons.trending_up_rounded,
          AppColors.danger,
          l10n.incidentTrendIntensifying,
        ),
      _ => (
          Icons.trending_flat_rounded,
          AppColors.warning,
          l10n.incidentTrendStable,
        ),
    };

    return GlassPanel(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  text,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.incidentTrendNote,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 12,
              height: 1.5,
              color: bodyColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpreadCard extends StatelessWidget {
  final FireIncident incident;
  final Color titleColor;
  final Color bodyColor;

  const _SpreadCard({
    required this.incident,
    required this.titleColor,
    required this.bodyColor,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bearing = incident.spreadBearingDeg!;
    final speed = incident.spreadSpeedMh!;

    return GlassPanel(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // The arrow points along the measured bearing. 0 degrees is
              // north, and the icon's own default points up, so the rotation
              // is the bearing itself.
              Transform.rotate(
                angle: bearing * 3.14159265359 / 180,
                child: const Icon(
                  Icons.navigation_rounded,
                  size: 22,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                l10n.incidentSpreadTitle,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 14, fontWeight: FontWeight.w700, color: titleColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.incidentSpreadLine(
              compassDirection(l10n, bearing),
              speed.round().toString(),
            ),
            style: GoogleFonts.ibmPlexSans(
              fontSize: 15, fontWeight: FontWeight.w600, height: 1.4,
              color: titleColor,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.incidentSpreadEstimateNote,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 12, height: 1.5, color: bodyColor,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 260.ms).slideY(begin: 0.06, end: 0);
  }
}

/// Only ever rendered when a named source confirmed a state. Nothing here is
/// derived from satellite data.
class _OfficialCard extends StatelessWidget {
  final FireIncident incident;
  final Color titleColor;
  final Color bodyColor;

  const _OfficialCard({
    required this.incident,
    required this.titleColor,
    required this.bodyColor,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GlassPanel(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_rounded, size: 20, color: AppColors.info),
              const SizedBox(width: AppSpacing.md),
              Text(
                l10n.incidentOfficialTitle,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 14, fontWeight: FontWeight.w700, color: titleColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            [incident.officialState, incident.officialSource]
                .whereType<String>()
                .join('  ·  '),
            style: GoogleFonts.ibmPlexSans(fontSize: 14, color: bodyColor),
          ),
        ],
      ),
    );
  }
}
