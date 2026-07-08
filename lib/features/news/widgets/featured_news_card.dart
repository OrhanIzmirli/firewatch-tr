import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/news_content_analysis.dart';
import '../../../l10n/app_localizations.dart';
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = Theme.of(context).textTheme.titleLarge?.color ??
        (isDark ? AppColors.white : const Color(0xFF0F172A));
    final summaryColor = isDark
        ? AppColors.white.withValues(alpha: 0.74)
        : Colors.black.withValues(alpha: 0.64);
    final fullText = '${item.title} ${item.summary}';
    final category = classifyNewsCategory(fullText);
    final riskLevel = classifyNewsRiskLevel(fullText);
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

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
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (item.isBreaking)
                      StatusChip(
                        label: l10n.newsBreakingBadge,
                        icon: Icons.bolt_rounded,
                      ),
                    StatusChip(
                      label: newsCategoryLabel(l10n, category),
                      icon: newsCategoryIcon(category),
                    ),
                    StatusChip(
                      label: '${newsRiskLevelEmoji(riskLevel)} ${newsRiskLevelLabel(l10n, riskLevel)}',
                      color: newsRiskLevelColor(riskLevel),
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
                    newsCategoryIcon(category),
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
                RichText(
                  text: TextSpan(
                    children: highlightFireKeywords(
                      item.title,
                      GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        color: titleColor,
                      ),
                      GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        color: AppColors.primary,
                      ),
                    ),
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
                      l10n.newsDetailReadMinutes(item.readMinutes),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                if (isEnglish) ...[
                  const SizedBox(height: AppSpacing.md),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: onTap,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
                        ),
                        icon: const Icon(Icons.translate_rounded, size: 16),
                        label: Text(
                          l10n.newsTranslateCardButton,
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}