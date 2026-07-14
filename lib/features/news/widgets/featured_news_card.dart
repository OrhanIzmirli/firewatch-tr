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

class FeaturedNewsCard extends StatefulWidget {
  final NewsItem item;
  final VoidCallback? onTap;

  const FeaturedNewsCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  State<FeaturedNewsCard> createState() => _FeaturedNewsCardState();
}

class _FeaturedNewsCardState extends State<FeaturedNewsCard> {
  bool _translating = false;
  String? _translatedTitle;
  String? _translatedSummary;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maybeAutoTranslate();
  }

  @override
  void didUpdateWidget(covariant FeaturedNewsCard oldWidget) {
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
    final titleColor = Theme.of(context).textTheme.titleLarge?.color ??
        (isDark ? AppColors.white : const Color(0xFF0F172A));
    final summaryColor = isDark
        ? AppColors.white.withValues(alpha: 0.74)
        : Colors.black.withValues(alpha: 0.64);
    final fullText = '${widget.item.title} ${widget.item.summary}';
    final category = classifyNewsCategory(fullText);
    final riskLevel = classifyNewsRiskLevel(fullText);
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final timeAgo = formatNewsTimeAgo(l10n, widget.item.publishedAt);

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
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (widget.item.isBreaking)
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
                if (_translating)
                  ShimmerWrap(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SkeletonBox(width: double.infinity, height: 22),
                        const SizedBox(height: 8),
                        SkeletonBox(width: MediaQuery.of(context).size.width * 0.5, height: 22),
                      ],
                    ),
                  )
                else
                  RichText(
                    text: TextSpan(
                      children: highlightFireKeywords(
                        displayTitle,
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
                if (showTranslatedCaption) ...[
                  const SizedBox(height: 6),
                  Text(
                    l10n.newsTranslatedCaption,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: AppColors.primary.withValues(alpha: 0.8),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                if (_translating)
                  const ShimmerWrap(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: double.infinity, height: 14),
                        SizedBox(height: 6),
                        SkeletonBox(width: double.infinity, height: 14),
                      ],
                    ),
                  )
                else
                  Text(
                    displaySummary,
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
                        '${widget.item.source} • ${widget.item.relatedRegion}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.white.withValues(alpha: 0.64)
                              : Colors.black.withValues(alpha: 0.54),
                        ),
                      ),
                    ),
                    Text(
                      timeAgo,
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
