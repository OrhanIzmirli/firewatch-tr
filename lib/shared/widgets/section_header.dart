import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final IconData? icon;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final titleColor = theme.textTheme.titleLarge?.color ??
        (isDark ? AppColors.white : const Color(0xFF0F172A));

    final subtitleColor = isDark
        ? AppColors.white.withValues(alpha: 0.66)
        : Colors.black.withValues(alpha: 0.58);

    return Row(
      crossAxisAlignment:
      subtitle != null ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle!,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.4,
                    color: subtitleColor,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppSpacing.md),
          trailing!,
        ],
      ],
    );
  }
}