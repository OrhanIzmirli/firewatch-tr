import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/news_content_analysis.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/news_item.dart';
import '../../../services/news_translation_service.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../../shared/widgets/news_source_mark.dart';

class NewsCard extends StatefulWidget {
  final NewsItem item;
  final VoidCallback? onTap;

  const NewsCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  bool _translating = false;
  String? _translatedTitle;
  String? _translatedSummary;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maybeAutoTranslate();
  }

  @override
  void didUpdateWidget(covariant NewsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _translatedTitle = null;
      _translatedSummary = null;
      _maybeAutoTranslate();
    }
  }

  Future<void> _maybeAutoTranslate() async {
    if (Localizations.localeOf(context).languageCode != 'en') return;
    if (_translatedTitle != null || _translating) return;

    final service = NewsTranslationService.instance;
    final cachedTitle = await service.getCached(widget.item.id, 'title');
    final cachedSummary = await service.getCached(widget.item.id, 'summary');
    if (cachedTitle != null) {
      if (!mounted) return;
      setState(() {
        _translatedTitle = cachedTitle;
        _translatedSummary = cachedSummary;
      });
      return;
    }

    if (!mounted) return;
    setState(() => _translating = true);
    try {
      final title = await service.translate(
        articleId: widget.item.id,
        field: 'title',
        text: widget.item.title,
      );
      final summary = await service.translate(
        articleId: widget.item.id,
        field: 'summary',
        text: widget.item.summary,
      );
      if (!mounted) return;
      setState(() {
        _translatedTitle = title;
        _translatedSummary = summary;
      });
    } catch (_) {
      // Falls back to showing the original Turkish text below.
    } finally {
      if (mounted) setState(() => _translating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = Theme.of(context).textTheme.titleMedium?.color ??
        (isDark ? AppColors.white : AppColors.lightText);
    final summaryColor = isDark
        ? AppColors.white.withValues(alpha: 0.7)
        : Colors.black.withValues(alpha: 0.62);
    final metaColor = isDark
        ? AppColors.white.withValues(alpha: 0.52)
        : Colors.black.withValues(alpha: 0.48);
    final arrowColor = isDark
        ? AppColors.white.withValues(alpha: 0.42)
        : Colors.black.withValues(alpha: 0.3);

    final fullText = '${widget.item.title} ${widget.item.summary}';
    final category = classifyNewsCategory(fullText);
    final riskLevel = classifyNewsRiskLevel(fullText);
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final timeAgo = formatNewsTimeAgo(l10n, widget.item.publishedAt);
    final wordCount = newsWordCount(widget.item);

    final displayTitle = _translatedTitle ?? widget.item.title;
    final displaySummary = _translatedSummary ?? widget.item.summary;
    final showTranslatedCaption = isEnglish && _translatedTitle != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
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
                NewsSourceMark(
                  source: widget.item.source,
                  logoUrl: widget.item.sourceLogoUrl,
                  size: 52,
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
                            label: newsRiskLevelLabel(l10n, riskLevel),
                            showDot: true,
                            color: newsRiskLevelColor(riskLevel),
                          ),
                          if (widget.item.isBreaking)
                            StatusChip(
                              label: l10n.newsBreakingBadge,
                              icon: Icons.bolt_rounded,
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (_translating)
                        ShimmerWrap(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SkeletonBox(width: double.infinity, height: 16),
                              const SizedBox(height: 6),
                              SkeletonBox(width: MediaQuery.of(context).size.width * 0.5, height: 16),
                            ],
                          ),
                        )
                      else
                        RichText(
                          text: TextSpan(
                            children: highlightFireKeywords(
                              displayTitle,
                              GoogleFonts.ibmPlexSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                                color: titleColor,
                              ),
                              GoogleFonts.ibmPlexSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      if (showTranslatedCaption) ...[
                        const SizedBox(height: 4),
                        Text(
                          l10n.newsTranslatedCaption,
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: AppColors.primary.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.sm),
                      if (_translating)
                        const ShimmerWrap(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SkeletonBox(width: double.infinity, height: 12),
                              SizedBox(height: 6),
                              SkeletonBox(width: double.infinity, height: 12),
                            ],
                          ),
                        )
                      else
                        Text(
                          displaySummary,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.ibmPlexSans(
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
                              '${widget.item.source.toUpperCase()}  •  $timeAgo',
                              style: GoogleFonts.ibmPlexSans(
                                fontSize: 12,
                                color: metaColor,
                              ),
                            ),
                          ),
                          if (wordCount != null) ...[
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              l10n.newsWordCount(wordCount),
                              style: GoogleFonts.ibmPlexSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ],
                      ),
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
