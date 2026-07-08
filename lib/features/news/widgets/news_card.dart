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

class NewsCard extends StatelessWidget {
  final NewsItem item;
  final VoidCallback? onTap;

  const NewsCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = Theme.of(context).textTheme.titleMedium?.color ??
        (isDark ? AppColors.white : const Color(0xFF0F172A));
    final summaryColor = isDark
        ? AppColors.white.withValues(alpha: 0.7)
        : Colors.black.withValues(alpha: 0.62);
    final metaColor = isDark
        ? AppColors.white.withValues(alpha: 0.52)
        : Colors.black.withValues(alpha: 0.48);
    final arrowColor = isDark
        ? AppColors.white.withValues(alpha: 0.42)
        : Colors.black.withValues(alpha: 0.3);

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
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    newsCategoryIcon(category),
                    color: AppColors.primary,
                    size: 24,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 220.ms)
                    .scale(
                  begin: const Offset(0.88, 0.88),
                  end: const Offset(1, 1),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          StatusChip(
                            label: newsCategoryLabel(l10n, category),
                            icon: newsCategoryIcon(category),
                          ),
                          StatusChip(
                            label: '${newsRiskLevelEmoji(riskLevel)} ${newsRiskLevelLabel(l10n, riskLevel)}',
                            color: newsRiskLevelColor(riskLevel),
                          ),
                          if (item.isBreaking)
                            StatusChip(
                              label: l10n.newsBreakingBadge,
                              icon: Icons.bolt_rounded,
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      RichText(
                        text: TextSpan(
                          children: highlightFireKeywords(
                            item.title,
                            GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                              color: titleColor,
                            ),
                            GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        item.summary,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          height: 1.45,
                          color: summaryColor,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${item.source} • ${item.publishedAt}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: metaColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            l10n.newsDetailReadMinutes(item.readMinutes),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      if (isEnglish) ...[
                        const SizedBox(height: AppSpacing.sm),
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
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 15,
                  color: arrowColor,
                )
                    .animate(onPlay: (controller) => controller.repeat(reverse: true))
                    .moveX(
                  begin: 0,
                  end: 3,
                  duration: 900.ms,
                  curve: Curves.easeInOut,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}