import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/glass_panel.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/status_chip.dart';

class SafetyGuideScreen extends StatelessWidget {
  const SafetyGuideScreen({super.key});

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
        title: Text(
          l10n.safetyGuideTitle,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
          ),
        ),
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
                    label: l10n.safetyGuideEmergencyInfo,
                    icon: Icons.shield_outlined,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.safetyGuideCenterTitle,
                    style: GoogleFonts.inter(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.safetyGuideCenterSubtitle,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      height: 1.45,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 450.ms)
                .scale(
              begin: const Offset(0.97, 0.97),
              end: const Offset(1, 1),
              curve: Curves.easeOutCubic,
            )
                .slideY(begin: 0.06, end: 0),

            const SizedBox(height: AppSpacing.xxl),

            SectionHeader(
              title: l10n.safetyGuideQuickActions,
              subtitle: l10n.safetyGuideQuickActionsSubtitle,
              icon: Icons.flash_on_rounded,
            )
                .animate(delay: 80.ms)
                .fadeIn(duration: 280.ms)
                .slideX(begin: -0.03, end: 0),

            const SizedBox(height: AppSpacing.md),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 1.08,
              children: [
                _QuickActionCard(
                  title: l10n.safetyGuideReadyEvacuate,
                  subtitle: l10n.safetyGuideReadyEvacuateSubtitle,
                  icon: Icons.directions_run_rounded,
                  accent: AppColors.primary,
                  delay: const Duration(milliseconds: 140),
                ),
                _QuickActionCard(
                  title: l10n.safetyGuideTakeSmokeSeriously,
                  subtitle: l10n.safetyGuideTakeSmokeSeriouslySubtitle,
                  icon: Icons.masks_rounded,
                  accent: AppColors.warning,
                  delay: const Duration(milliseconds: 220),
                ),
                _QuickActionCard(
                  title: l10n.safetyGuideFollowOfficials,
                  subtitle: l10n.safetyGuideFollowOfficialsSubtitle,
                  icon: Icons.campaign_rounded,
                  accent: AppColors.primary,
                  delay: const Duration(milliseconds: 300),
                ),
                _QuickActionCard(
                  title: l10n.safetyGuideDontDelay,
                  subtitle: l10n.safetyGuideDontDelaySubtitle,
                  icon: Icons.warning_amber_rounded,
                  accent: AppColors.danger,
                  delay: const Duration(milliseconds: 380),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xxxl),

            SectionHeader(
              title: l10n.safetyGuideChecklist,
              subtitle: l10n.safetyGuideChecklistSubtitle,
              icon: Icons.checklist_rounded,
            )
                .animate(delay: 130.ms)
                .fadeIn(duration: 280.ms)
                .slideX(begin: -0.03, end: 0),

            const SizedBox(height: AppSpacing.md),

            _ChecklistTile(
              title: l10n.safetyGuideChecklist1Title,
              description: l10n.safetyGuideChecklist1Desc,
              delay: const Duration(milliseconds: 180),
            ),
            const SizedBox(height: AppSpacing.sm),
            _ChecklistTile(
              title: l10n.safetyGuideChecklist2Title,
              description: l10n.safetyGuideChecklist2Desc,
              delay: const Duration(milliseconds: 250),
            ),
            const SizedBox(height: AppSpacing.sm),
            _ChecklistTile(
              title: l10n.safetyGuideChecklist3Title,
              description: l10n.safetyGuideChecklist3Desc,
              delay: const Duration(milliseconds: 320),
            ),
            const SizedBox(height: AppSpacing.sm),
            _ChecklistTile(
              title: l10n.safetyGuideChecklist4Title,
              description: l10n.safetyGuideChecklist4Desc,
              delay: const Duration(milliseconds: 390),
            ),

            const SizedBox(height: AppSpacing.xxxl),

            SectionHeader(
              title: l10n.safetyGuideDetailedGuide,
              subtitle: l10n.safetyGuideDetailedGuideSubtitle,
              icon: Icons.menu_book_rounded,
            )
                .animate(delay: 180.ms)
                .fadeIn(duration: 280.ms)
                .slideX(begin: -0.03, end: 0),

            const SizedBox(height: AppSpacing.md),

            _GuideAccordion(
              title: l10n.safetyGuideAtHomeTitle,
              icon: Icons.home_rounded,
              points: [
                l10n.safetyGuideAtHome1,
                l10n.safetyGuideAtHome2,
                l10n.safetyGuideAtHome3,
                l10n.safetyGuideAtHome4,
              ],
              delay: const Duration(milliseconds: 230),
            ),
            const SizedBox(height: AppSpacing.md),
            _GuideAccordion(
              title: l10n.safetyGuideInCarTitle,
              icon: Icons.directions_car_filled_rounded,
              points: [
                l10n.safetyGuideInCar1,
                l10n.safetyGuideInCar2,
                l10n.safetyGuideInCar3,
                l10n.safetyGuideInCar4,
              ],
              delay: const Duration(milliseconds: 300),
            ),
            const SizedBox(height: AppSpacing.md),
            _GuideAccordion(
              title: l10n.safetyGuideOutsideTitle,
              icon: Icons.terrain_rounded,
              points: [
                l10n.safetyGuideOutside1,
                l10n.safetyGuideOutside2,
                l10n.safetyGuideOutside3,
                l10n.safetyGuideOutside4,
              ],
              delay: const Duration(milliseconds: 370),
            ),
            const SizedBox(height: AppSpacing.md),
            _GuideAccordion(
              title: l10n.safetyGuideEvacOrderTitle,
              icon: Icons.gpp_good_rounded,
              points: [
                l10n.safetyGuideEvacOrder1,
                l10n.safetyGuideEvacOrder2,
                l10n.safetyGuideEvacOrder3,
                l10n.safetyGuideEvacOrder4,
              ],
              delay: const Duration(milliseconds: 440),
            ),

            const SizedBox(height: AppSpacing.xxxl),

            SectionHeader(
              title: l10n.safetyGuideEmergencyNumbers,
              subtitle: l10n.safetyGuideEmergencyNumbersSubtitle,
              icon: Icons.phone_in_talk_rounded,
            )
                .animate(delay: 230.ms)
                .fadeIn(duration: 280.ms)
                .slideX(begin: -0.03, end: 0),

            const SizedBox(height: AppSpacing.md),

            _EmergencyNumberCard(
              title: l10n.emergencyCallCenter,
              number: '112',
              subtitle: l10n.safetyGuideCallCenterSubtitle,
              delay: const Duration(milliseconds: 280),
            ),
            const SizedBox(height: AppSpacing.md),
            _EmergencyNumberCard(
              title: l10n.safetyGuideForestNotice,
              number: '177',
              subtitle: l10n.safetyGuideForestNoticeSubtitle,
              delay: const Duration(milliseconds: 350),
            ),
            const SizedBox(height: AppSpacing.md),
            _EmergencyNumberCard(
              title: l10n.safetyGuideAfadLocal,
              number: l10n.safetyGuideAfadLocalNumber,
              subtitle: l10n.safetyGuideAfadLocalSubtitle,
              delay: const Duration(milliseconds: 420),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final Duration delay;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = Theme.of(context).textTheme.titleMedium?.color ??
        (isDark ? AppColors.white : const Color(0xFF0F172A));
    final subtitleColor = isDark
        ? AppColors.white.withValues(alpha: 0.62)
        : Colors.black.withValues(alpha: 0.56);

    return GlassPanel(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: accent,
              size: 22,
            ),
          ),
          const Spacer(),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: titleColor,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 12,
              height: 1.35,
              color: subtitleColor,
            ),
          ),
        ],
      ),
    )
        .animate(delay: delay)
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.14, end: 0)
        .scale(
      begin: const Offset(0.96, 0.96),
      end: const Offset(1, 1),
    );
  }
}

class _ChecklistTile extends StatelessWidget {
  final String title;
  final String description;
  final Duration delay;

  const _ChecklistTile({
    required this.title,
    required this.description,
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = Theme.of(context).textTheme.titleMedium?.color ??
        (isDark ? AppColors.white : const Color(0xFF0F172A));
    final descriptionColor = isDark
        ? AppColors.white.withValues(alpha: 0.66)
        : Colors.black.withValues(alpha: 0.58);

    return GlassPanel(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    height: 1.4,
                    color: descriptionColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate(delay: delay)
        .fadeIn(duration: 260.ms)
        .slideX(begin: 0.03, end: 0)
        .scale(
      begin: const Offset(0.98, 0.98),
      end: const Offset(1, 1),
    );
  }
}

class _GuideAccordion extends StatefulWidget {
  final String title;
  final IconData icon;
  final List<String> points;
  final Duration delay;

  const _GuideAccordion({
    required this.title,
    required this.icon,
    required this.points,
    this.delay = Duration.zero,
  });

  @override
  State<_GuideAccordion> createState() => _GuideAccordionState();
}

class _GuideAccordionState extends State<_GuideAccordion> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = Theme.of(context).textTheme.titleMedium?.color ??
        (isDark ? AppColors.white : const Color(0xFF0F172A));
    final pointColor = isDark
        ? AppColors.white.withValues(alpha: 0.72)
        : Colors.black.withValues(alpha: 0.64);
    final arrowColor = isDark
        ? AppColors.white.withValues(alpha: 0.7)
        : Colors.black.withValues(alpha: 0.5);

    return GlassPanel(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.icon,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    widget.title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                  ),
                ),
                AnimatedRotation(
                  duration: const Duration(milliseconds: 220),
                  turns: _expanded ? 0.5 : 0,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: arrowColor,
                  ),
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.lg),
              child: Column(
                children: widget.points
                    .map(
                      (point) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Icon(
                            Icons.circle,
                            size: 8,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            point,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              height: 1.45,
                              color: pointColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    )
        .animate(delay: widget.delay)
        .fadeIn(duration: 280.ms)
        .slideY(begin: 0.1, end: 0)
        .scale(
      begin: const Offset(0.98, 0.98),
      end: const Offset(1, 1),
    );
  }
}

class _EmergencyNumberCard extends StatelessWidget {
  final String title;
  final String number;
  final String subtitle;
  final Duration delay;

  const _EmergencyNumberCard({
    required this.title,
    required this.number,
    required this.subtitle,
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = Theme.of(context).textTheme.titleMedium?.color ??
        (isDark ? AppColors.white : const Color(0xFF0F172A));
    final subtitleColor = isDark
        ? AppColors.white.withValues(alpha: 0.64)
        : Colors.black.withValues(alpha: 0.56);

    return GlassPanel(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.phone_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Flexible(
            child: Text(
              number,
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    )
        .animate(delay: delay)
        .fadeIn(duration: 280.ms)
        .slideX(begin: 0.03, end: 0)
        .scale(
      begin: const Offset(0.98, 0.98),
      end: const Offset(1, 1),
    );
  }
}