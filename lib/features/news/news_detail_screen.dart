import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/utils/news_content_analysis.dart';
import '../../l10n/app_localizations.dart';
import '../../models/news_item.dart';
import '../../services/news_translation_service.dart';
import '../../shared/widgets/glass_panel.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/status_chip.dart';

class NewsDetailScreen extends StatefulWidget {
  final NewsItem newsItem;

  const NewsDetailScreen({
    super.key,
    required this.newsItem,
  });

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  bool _showTranslated = false;
  bool _translating = false;
  bool _translationFailed = false;
  String? _translatedTitle;
  String? _translatedSummary;
  bool _autoTranslateKicked = false;

  @override
  void initState() {
    super.initState();
    _loadCachedTranslation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_autoTranslateKicked) return;
    _autoTranslateKicked = true;
    // "Tap any article to translate it to English" (news list banner) only
    // holds true if opening an article actually translates it — so in
    // English mode, kick off translation automatically rather than making
    // the user find and press the button themselves.
    if (Localizations.localeOf(context).languageCode != 'en') return;
    if (_translatedTitle != null && _translatedSummary != null) return;
    _translate();
  }

  Future<void> _loadCachedTranslation() async {
    final title = await NewsTranslationService.instance.getCached(widget.newsItem.id, 'title');
    final summary = await NewsTranslationService.instance.getCached(widget.newsItem.id, 'summary');
    if (!mounted) return;
    if (title != null && summary != null) {
      setState(() {
        _translatedTitle = title;
        _translatedSummary = summary;
      });
    }
  }

  Future<void> _translate() async {
    setState(() {
      _translating = true;
      _translationFailed = false;
    });
    try {
      final title = await NewsTranslationService.instance.translate(
        articleId: widget.newsItem.id,
        field: 'title',
        text: widget.newsItem.title,
      );
      final summary = await NewsTranslationService.instance.translate(
        articleId: widget.newsItem.id,
        field: 'summary',
        text: widget.newsItem.summary,
      );
      if (!mounted) return;
      setState(() {
        _translatedTitle = title;
        _translatedSummary = summary;
        _showTranslated = true;
        _translating = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _translating = false;
        _translationFailed = true;
      });
    }
  }

  Future<void> _openSourceUrl() async {
    final uri = Uri.tryParse(widget.newsItem.sourceUrl);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  NewsItem get newsItem => widget.newsItem;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final canTranslate = locale.languageCode == 'en';

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final titleColor = theme.textTheme.titleLarge?.color ??
        (isDark ? AppColors.white : const Color(0xFF0F172A));
    final secondaryTextColor = isDark
        ? AppColors.white.withValues(alpha: 0.74)
        : Colors.black.withValues(alpha: 0.66);
    final metaColor = isDark
        ? AppColors.white.withValues(alpha: 0.58)
        : Colors.black.withValues(alpha: 0.5);
    final paragraphColor = isDark
        ? AppColors.white.withValues(alpha: 0.76)
        : Colors.black.withValues(alpha: 0.68);

    final displayTitle = _showTranslated && _translatedTitle != null ? _translatedTitle! : newsItem.title;
    final displaySummary = _showTranslated && _translatedSummary != null ? _translatedSummary! : newsItem.summary;
    final hasTranslation = _translatedTitle != null && _translatedSummary != null;
    final fullText = '${newsItem.title} ${newsItem.summary}';
    final category = classifyNewsCategory(fullText);
    final riskLevel = classifyNewsRiskLevel(fullText);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.newsDetailTitle,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      StatusChip(
                        label: newsCategoryLabel(l10n, category),
                        icon: newsCategoryIcon(category),
                      ),
                      StatusChip(
                        label: '${newsRiskLevelEmoji(riskLevel)} ${newsRiskLevelLabel(l10n, riskLevel)}',
                        color: newsRiskLevelColor(riskLevel),
                      ),
                      if (newsItem.isBreaking)
                        StatusChip(
                          label: l10n.newsBreakingBadge,
                          icon: Icons.bolt_rounded,
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      newsCategoryIcon(category),
                      color: AppColors.primary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  RichText(
                    text: TextSpan(
                      children: highlightFireKeywords(
                        displayTitle,
                        GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                          color: titleColor,
                        ),
                        GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    displaySummary,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      height: 1.5,
                      color: secondaryTextColor,
                    ),
                  ),
                  if (canTranslate) ...[
                    const SizedBox(height: AppSpacing.md),
                    if (_translating)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(l10n.newsTranslating,
                              style: GoogleFonts.inter(fontSize: 13, color: secondaryTextColor)),
                        ],
                      )
                    else
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          TextButton.icon(
                            onPressed: hasTranslation
                                ? () => setState(() => _showTranslated = !_showTranslated)
                                : _translate,
                            icon: Icon(hasTranslation && _showTranslated ? Icons.undo_rounded : Icons.translate_rounded, size: 18),
                            label: Text(
                              hasTranslation
                                  ? (_showTranslated ? l10n.newsShowOriginal : l10n.newsTranslated)
                                  : l10n.newsTranslate,
                            ),
                          ),
                          if (_translationFailed)
                            Text(l10n.newsTranslationFailed,
                                style: GoogleFonts.inter(fontSize: 12, color: AppColors.danger)),
                        ],
                      ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${newsItem.source} • ${newsItem.publishedAt}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: metaColor,
                          ),
                        ),
                      ),
                      Text(
                        l10n.newsDetailReadMinutes(newsItem.readMinutes),
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
            )
                .animate()
                .fadeIn(duration: 450.ms)
                .scale(
              begin: const Offset(0.97, 0.97),
              end: const Offset(1, 1),
            )
                .slideY(begin: 0.06, end: 0),

            const SizedBox(height: AppSpacing.lg),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _openSourceUrl,
                icon: const Icon(Icons.open_in_new_rounded),
                label: Text(l10n.newsReadFullArticle),
              ),
            ).animate(delay: 100.ms).fadeIn(duration: 280.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: AppSpacing.xxl),

            SectionHeader(
              title: l10n.newsDetailHighlightsTitle,
              subtitle: l10n.newsDetailHighlightsSubtitle,
              icon: Icons.stars_rounded,
            )
                .animate(delay: 90.ms)
                .fadeIn(duration: 280.ms)
                .slideX(begin: -0.03, end: 0),

            const SizedBox(height: AppSpacing.md),

            ...newsItem.highlights.asMap().entries.map((entry) {
              final index = entry.key;
              final point = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: GlassPanel(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          point,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            height: 1.45,
                            color: paragraphColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(
                  duration: 260.ms,
                  delay: (140 + (index * 70)).ms,
                )
                    .slideY(begin: 0.12, end: 0)
                    .scale(
                  begin: const Offset(0.98, 0.98),
                  end: const Offset(1, 1),
                ),
              );
            }),

            const SizedBox(height: AppSpacing.xxxl),

            SectionHeader(
              title: l10n.newsDetailFullContentTitle,
              subtitle: l10n.newsDetailFullContentSubtitle,
              icon: Icons.menu_book_rounded,
            )
                .animate(delay: 150.ms)
                .fadeIn(duration: 280.ms)
                .slideX(begin: -0.03, end: 0),

            const SizedBox(height: AppSpacing.md),

            ...newsItem.paragraphs.asMap().entries.map((entry) {
              final index = entry.key;
              final paragraph = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: GlassPanel(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    paragraph,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      height: 1.6,
                      color: paragraphColor,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(
                  duration: 280.ms,
                  delay: (200 + (index * 70)).ms,
                )
                    .slideX(begin: 0.03, end: 0)
                    .scale(
                  begin: const Offset(0.98, 0.98),
                  end: const Offset(1, 1),
                ),
              );
            }),

            const SizedBox(height: AppSpacing.xxxl),

            SectionHeader(
              title: l10n.newsDetailRelatedRegionTitle,
              subtitle: l10n.newsDetailRelatedRegionSubtitle,
              icon: Icons.place_rounded,
            )
                .animate(delay: 220.ms)
                .fadeIn(duration: 280.ms)
                .slideX(begin: -0.03, end: 0),

            const SizedBox(height: AppSpacing.md),

            GlassPanel(
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.public_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          newsItem.relatedRegion,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.newsDetailRelatedRegionNote,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            height: 1.45,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
                .animate(delay: 260.ms)
                .fadeIn(duration: 280.ms)
                .slideY(begin: 0.08, end: 0),

            const SizedBox(height: AppSpacing.xxl),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _openSourceUrl,
                icon: const Icon(Icons.open_in_new_rounded),
                label: Text(l10n.newsReadFullArticle),
              ),
            ).animate(delay: 280.ms).fadeIn(duration: 280.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: AppSpacing.xxxl),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.push('/risk');
                    },
                    icon: const Icon(Icons.auto_graph_rounded),
                    label: Text(l10n.homeRiskAnalysis),
                  )
                      .animate(delay: 300.ms)
                      .fadeIn(duration: 280.ms)
                      .slideY(begin: 0.14, end: 0),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.push('/safety-guide');
                    },
                    icon: const Icon(Icons.shield_outlined),
                    label: Text(l10n.homeSafety),
                  )
                      .animate(delay: 360.ms)
                      .fadeIn(duration: 280.ms)
                      .slideY(begin: 0.14, end: 0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
