import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import 'glass_panel.dart';

/// A data-driven, color-coded, tappable overview card — used on the Home
/// and Risk screens' summary grids in place of the old static [SummaryCard]
/// so each card can carry a real signal (color + subtitle) and route
/// straight to the screen that explains it.
class SmartOverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final Duration delay;

  const SmartOverviewCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final valueColor = theme.textTheme.headlineSmall?.color ??
        (isDark ? AppColors.white : const Color(0xFF0F172A));
    final titleColor = isDark
        ? AppColors.white.withValues(alpha: 0.78)
        : Colors.black.withValues(alpha: 0.68);
    final subtitleColor = isDark
        ? AppColors.white.withValues(alpha: 0.55)
        : Colors.black.withValues(alpha: 0.48);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius),
        child: GlassPanel(
          padding: const EdgeInsets.all(AppSpacing.lg),
          border: Border.all(color: color.withValues(alpha: 0.24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  if (onTap != null) ...[
                    const Spacer(),
                    Icon(Icons.arrow_forward_ios_rounded, size: 13, color: titleColor.withValues(alpha: 0.5)),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              // Two lines each, and a long value steps down a size rather
              // than truncating. A card reading "13 detection…" or "Nearby
              // Thermal Det…" has spent its width on an ellipsis; these
              // strings fit if they are allowed to wrap.
              // The value is a live readout (counts, MW, distances) that
              // refreshes with the data — mono with tabular figures so the
              // digits never jitter as they change.
              Text(
                value,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.mono(
                  size: value.length > 22
                      ? 15
                      : value.length > 14
                          ? 17
                          : 20,
                  weight: FontWeight.w700,
                  color: valueColor,
                ).copyWith(height: 1.15),
              ),
              const SizedBox(height: 3),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.ibmPlexSans(
                    fontSize: 13,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    color: titleColor),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.ibmPlexSans(fontSize: 11, height: 1.3, color: subtitleColor),
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: delay).fadeIn(duration: 300.ms).slideY(begin: 0.12, end: 0).scale(
          begin: const Offset(0.97, 0.97),
          end: const Offset(1, 1),
        );
  }
}
