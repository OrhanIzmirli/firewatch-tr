import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/glass_panel.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/status_chip.dart';
import 'widgets/emergency_action_card.dart';
import 'widgets/emergency_contact_card.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  Future<void> _call(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _shareLocation(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final permission = await Geolocator.checkPermission();
      Position? position;

      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }

      position = await Geolocator.getCurrentPosition();

      final lat = position.latitude.toStringAsFixed(6);
      final lng = position.longitude.toStringAsFixed(6);
      final mapsUrl = 'https://maps.google.com/?q=$lat,$lng';

      await Share.share(
        l10n.emergencyShareLocationText(mapsUrl, lat, lng),
        subject: l10n.emergencyShareLocationSubject,
      );
    } catch (e) {
      await Share.share(
        l10n.emergencyShareFallbackText,
        subject: l10n.emergencyTitle,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final titleColor = theme.textTheme.titleLarge?.color ??
        (isDark ? AppColors.white : const Color(0xFF0F172A));
    final secondaryTextColor = isDark
        ? AppColors.white.withValues(alpha: 0.74)
        : Colors.black.withValues(alpha: 0.66);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.emergencyTitle,
            style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassPanel(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatusChip(
                    label: l10n.emergencyPrepCenter,
                    icon: Icons.emergency_rounded,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(l10n.emergencyQuickToolsTitle,
                      style: GoogleFonts.ibmPlexSans(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: titleColor)),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.emergencyQuickToolsSubtitle,
                    style: GoogleFonts.ibmPlexSans(
                        fontSize: 15, height: 1.45, color: secondaryTextColor),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      StatusChip(
                          label: l10n.emergencyStayReady, icon: Icons.bolt_rounded),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          l10n.emergencyStayReadyNote,
                          style: GoogleFonts.ibmPlexSans(
                              fontSize: 13, color: secondaryTextColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 450.ms).scale(
                  begin: const Offset(0.97, 0.97),
                  end: const Offset(1, 1),
                  curve: Curves.easeOutCubic,
                ).slideY(begin: 0.06, end: 0),

            const SizedBox(height: AppSpacing.xxl),

            SectionHeader(
              title: l10n.emergencyQuickActions,
              subtitle: l10n.emergencyQuickActionsSubtitle,
              icon: const Icon(Icons.flash_on_rounded),
            ).animate(delay: 90.ms).fadeIn(duration: 280.ms).slideX(begin: -0.03, end: 0),

            const SizedBox(height: AppSpacing.md),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 1.08,
              children: [
                EmergencyActionCard(
                  title: l10n.emergencyCall112,
                  subtitle: l10n.emergencyCall112Subtitle,
                  icon: Icons.call_rounded,
                  accent: AppColors.danger,
                  delay: const Duration(milliseconds: 140),
                  onTap: () => _call('112'),
                ),
                EmergencyActionCard(
                  title: l10n.emergencyCall177,
                  subtitle: l10n.emergencyCall177Subtitle,
                  icon: Icons.local_fire_department_rounded,
                  accent: AppColors.primary,
                  delay: const Duration(milliseconds: 220),
                  onTap: () => _call('177'),
                ),
                EmergencyActionCard(
                  title: l10n.emergencyShareLocation,
                  subtitle: l10n.emergencyShareLocationSubtitle,
                  icon: Icons.share_location_rounded,
                  accent: AppColors.warning,
                  delay: const Duration(milliseconds: 300),
                  onTap: () => _shareLocation(context),
                ),
                EmergencyActionCard(
                  title: l10n.emergencyEvacuationPlan,
                  subtitle: l10n.emergencyEvacuationPlanSubtitle,
                  icon: Icons.directions_run_rounded,
                  accent: AppColors.success,
                  delay: const Duration(milliseconds: 380),
                  onTap: () => context.push('/safety-guide'),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xxxl),

            SectionHeader(
              title: l10n.emergencyContactLines,
              subtitle: l10n.emergencyContactLinesSubtitle,
              icon: const Icon(Icons.phone_in_talk_rounded),
            ).animate(delay: 130.ms).fadeIn(duration: 280.ms).slideX(begin: -0.03, end: 0),

            const SizedBox(height: AppSpacing.md),

            EmergencyContactCard(
              title: l10n.emergencyCallCenter,
              number: '112',
              subtitle: l10n.emergencyCallCenterSubtitle,
              icon: Icons.call_rounded,
              accent: AppColors.danger,
              delay: const Duration(milliseconds: 180),
              onTap: () => _call('112'),
            ),
            const SizedBox(height: AppSpacing.md),
            EmergencyContactCard(
              title: l10n.emergencyForestLine,
              number: '177',
              subtitle: l10n.emergencyForestLineSubtitle,
              icon: Icons.forest_rounded,
              accent: AppColors.primary,
              delay: const Duration(milliseconds: 250),
              onTap: () => _call('177'),
            ),
            const SizedBox(height: AppSpacing.md),
            EmergencyContactCard(
              title: l10n.emergencyAfad,
              number: '122',
              subtitle: l10n.emergencyAfadSubtitle,
              icon: Icons.campaign_rounded,
              accent: AppColors.warning,
              delay: const Duration(milliseconds: 320),
              onTap: () => _call('122'),
            ),

            const SizedBox(height: AppSpacing.xxxl),

            SectionHeader(
              title: l10n.emergencyBag,
              subtitle: l10n.emergencyBagSubtitle,
              icon: const Icon(Icons.backpack_rounded),
            ).animate(delay: 170.ms).fadeIn(duration: 280.ms).slideX(begin: -0.03, end: 0),

            const SizedBox(height: AppSpacing.md),

            _ChecklistCard(
              title: l10n.emergencyBagDocs,
              subtitle: l10n.emergencyBagDocsSubtitle,
              delay: const Duration(milliseconds: 220),
            ),
            const SizedBox(height: AppSpacing.sm),
            _ChecklistCard(
              title: l10n.emergencyBagSupplies,
              subtitle: l10n.emergencyBagSuppliesSubtitle,
              delay: const Duration(milliseconds: 290),
            ),
            const SizedBox(height: AppSpacing.sm),
            _ChecklistCard(
              title: l10n.emergencyBagMeetingPoint,
              subtitle: l10n.emergencyBagMeetingPointSubtitle,
              delay: const Duration(milliseconds: 360),
            ),

            const SizedBox(height: AppSpacing.xxxl),

            SectionHeader(
              title: l10n.emergencyCommNote,
              subtitle: l10n.emergencyCommNoteSubtitle,
              icon: const Icon(Icons.sticky_note_2_rounded),
            ).animate(delay: 210.ms).fadeIn(duration: 280.ms).slideX(begin: -0.03, end: 0),

            const SizedBox(height: AppSpacing.md),

            GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.emergencyStep1,
                      style: GoogleFonts.ibmPlexSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: titleColor)),
                  const SizedBox(height: AppSpacing.sm),
                  Text(l10n.emergencyStep2,
                      style: GoogleFonts.ibmPlexSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: titleColor)),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.emergencyStep3,
                    style: GoogleFonts.ibmPlexSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: titleColor),
                  ),
                ],
              ),
            ).animate(delay: 260.ms).fadeIn(duration: 300.ms).slideY(begin: 0.08, end: 0),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _ChecklistCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Duration delay;

  const _ChecklistCard({
    required this.title,
    required this.subtitle,
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = Theme.of(context).textTheme.titleMedium?.color ??
        (isDark ? AppColors.white : const Color(0xFF0F172A));
    final subtitleColor = isDark
        ? AppColors.white.withValues(alpha: 0.66)
        : Colors.black.withValues(alpha: 0.58);

    return GlassPanel(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded,
                size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.ibmPlexSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: titleColor)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: GoogleFonts.ibmPlexSans(
                        fontSize: 13, height: 1.45, color: subtitleColor)),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: delay).fadeIn(duration: 260.ms).slideX(begin: 0.03, end: 0).scale(
          begin: const Offset(0.98, 0.98),
          end: const Offset(1, 1),
        );
  }
}