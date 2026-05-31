import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import 'glass_panel.dart';
import 'status_chip.dart';

class FireInfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;
  final VoidCallback? onTap;

  const FireInfoCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final titleColor = theme.textTheme.titleMedium?.color ??
        (isDark ? AppColors.white : const Color(0xFF0F172A));
    final subtitleColor = isDark
        ? AppColors.white.withValues(alpha: 0.72)
        : Colors.black.withValues(alpha: 0.64);
    final arrowColor = isDark
        ? AppColors.white.withValues(alpha: 0.5)
        : Colors.black.withValues(alpha: 0.35);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        splashColor: AppColors.primary.withValues(alpha: 0.08),
        highlightColor: AppColors.primary.withValues(alpha: 0.04),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          ),
          child: GlassPanel(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: titleColor,
                        ),
                      ),
                    ),
                    if (onTap != null)
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: arrowColor,
                      )
                          .animate(
                        onPlay: (controller) =>
                            controller.repeat(reverse: true),
                      )
                          .moveX(
                        begin: 0,
                        end: 3,
                        duration: 900.ms,
                        curve: Curves.easeInOut,
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.4,
                    color: subtitleColor,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 320.ms)
                    .slideY(begin: 0.08, end: 0),
                const SizedBox(height: AppSpacing.md),
                StatusChip(
                  label: status,
                  icon: Icons.local_fire_department_rounded,
                )
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .scale(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1, 1),
                  duration: 320.ms,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}