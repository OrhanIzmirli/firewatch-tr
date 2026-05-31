import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import 'glass_panel.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final valueColor = theme.textTheme.headlineSmall?.color ??
        (isDark ? AppColors.white : const Color(0xFF0F172A));
    final titleColor = isDark
        ? AppColors.white.withValues(alpha: 0.72)
        : Colors.black.withValues(alpha: 0.62);

    return GlassPanel(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 22,
            ),
          )
              .animate()
              .scale(
            duration: 450.ms,
            curve: Curves.easeOutBack,
            begin: const Offset(0.7, 0.7),
            end: const Offset(1, 1),
          )
              .then(delay: 120.ms)
              .shimmer(duration: 900.ms),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          )
              .animate()
              .fadeIn(duration: 350.ms, delay: 100.ms)
              .slideY(begin: 0.18, end: 0),
          const SizedBox(height: 4),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: titleColor,
            ),
          )
              .animate()
              .fadeIn(duration: 300.ms, delay: 180.ms),
        ],
      ),
    );
  }
}