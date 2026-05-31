import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../models/news_item.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../../../shared/widgets/status_chip.dart';

class FeaturedNewsCard extends StatelessWidget {
  final NewsItem item;
  final VoidCallback? onTap;

  const FeaturedNewsCard({
    super.key,
    required this.item,
    this.onTap,
  });

  IconData _iconForCategory() {
    switch (item.category.toLowerCase()) {
      case 'risk':
        return Icons.auto_graph_rounded;
      case 'operasyon':
        return Icons.local_fire_department_rounded;
      case 'güvenlik':
        return Icons.shield_outlined;
      case 'güncelleme':
        return Icons.update_rounded;
      default:
        return Icons.article_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = Theme.of(context).textTheme.titleLarge?.color ??
        (isDark ? AppColors.white : const Color(0xFF0F172A));
    final summaryColor = isDark
        ? AppColors.white.withValues(alpha: 0.74)
        : Colors.black.withValues(alpha: 0.64);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius),
          ),
          child: GlassPanel(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (item.isBreaking)
                      const StatusChip(
                        label: 'Breaking',
                        icon: Icons.bolt_rounded,
                      ),
                    if (item.isBreaking) const SizedBox(width: AppSpacing.sm),
                    StatusChip(
                      label: item.category,
                      icon: _iconForCategory(),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    _iconForCategory(),
                    color: AppColors.primary,
                    size: 28,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 260.ms)
                    .scale(
                  begin: const Offset(0.82, 0.82),
                  end: const Offset(1, 1),
                  curve: Curves.easeOutBack,
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  item.title,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  item.summary,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.5,
                    color: summaryColor,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Icon(
                      Icons.place_rounded,
                      size: 16,
                      color: isDark
                          ? AppColors.white.withValues(alpha: 0.6)
                          : Colors.black.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        item.relatedRegion,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.white.withValues(alpha: 0.64)
                              : Colors.black.withValues(alpha: 0.54),
                        ),
                      ),
                    ),
                    Text(
                      '${item.readMinutes} dk',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}