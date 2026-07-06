import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../l10n/app_localizations.dart';
import '../../models/news_item.dart';
import '../../services/news_service.dart';
import '../../shared/widgets/glass_panel.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/status_chip.dart';
import 'widgets/featured_news_card.dart';
import 'widgets/news_card.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final NewsService _newsService = NewsService();

  String _selectedCategory = 'Tümü';
  String _selectedRegion = 'Tümü';
  List<NewsItem> _allNews = [];
  bool _isLoading = true;
  String? _errorMessage;

  static const List<String> _categories = [
    'Tümü', 'Risk', 'Operasyon', 'Güvenlik', 'Güncelleme',
  ];

  static const List<String> _regions = [
    'Tümü', 'Ege', 'Akdeniz', 'Marmara', 'İç Anadolu',
    'Karadeniz', 'Doğu Anadolu', 'Güneydoğu Anadolu', 'Türkiye Geneli',
  ];

  static const Map<String, String?> _categoryParams = {
    'Tümü': null,
    'Risk': 'Risk',
    'Operasyon': 'Operasyon',
    'Güvenlik': 'Güvenlik',
    'Güncelleme': 'Güncelleme',
  };

  String _categoryLabel(AppLocalizations l10n, String key) {
    switch (key) {
      case 'Risk': return l10n.newsCategoryRisk;
      case 'Operasyon': return l10n.newsCategoryOperation;
      case 'Güvenlik': return l10n.newsCategorySafety;
      case 'Güncelleme': return l10n.newsCategoryUpdate;
      default: return l10n.commonAll;
    }
  }

  String _regionLabel(AppLocalizations l10n, String key) {
    switch (key) {
      case 'Ege': return l10n.regionEge;
      case 'Akdeniz': return l10n.regionAkdeniz;
      case 'Marmara': return l10n.regionMarmara;
      case 'İç Anadolu': return l10n.regionIcAnadolu;
      case 'Karadeniz': return l10n.regionKaradeniz;
      case 'Doğu Anadolu': return l10n.regionDoguAnadolu;
      case 'Güneydoğu Anadolu': return l10n.regionGuneydoguAnadolu;
      case 'Türkiye Geneli': return l10n.regionTurkiyeGeneli;
      default: return l10n.commonAll;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final news = await _newsService.fetchNewsFromRender(
        category: _categoryParams[_selectedCategory],
        limit: 50,
      );
      setState(() {
        _allNews = news;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.newsFetchFailed;
        _isLoading = false;
      });
    }
  }

  List<NewsItem> get _filteredItems {
    return _allNews.where((item) {
      final categoryMatch = _selectedCategory == 'Tümü' ||
          item.category.toLowerCase() == _selectedCategory.toLowerCase();
      final regionMatch = _selectedRegion == 'Tümü' ||
          item.relatedRegion == _selectedRegion;
      return categoryMatch && regionMatch;
    }).toList();
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.16)
              : (isDark
                  ? AppColors.white.withValues(alpha: 0.03)
                  : Colors.black.withValues(alpha: 0.03)),
          borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.34)
                : (isDark
                    ? AppColors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.08)),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isSelected
                ? AppColors.primary
                : (isDark
                    ? AppColors.white.withValues(alpha: 0.78)
                    : Colors.black.withValues(alpha: 0.72)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filteredItems = _filteredItems;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final titleColor = theme.textTheme.titleLarge?.color ??
        (isDark ? AppColors.white : const Color(0xFF0F172A));
    final secondaryTextColor = isDark
        ? AppColors.white.withValues(alpha: 0.74)
        : Colors.black.withValues(alpha: 0.66);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.newsTitle,
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadNews,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────
            GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatusChip(
                    label: l10n.newsLiveFeed,
                    icon: Icons.newspaper_rounded,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.newsCenterTitle,
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.newsCenterSubtitle,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      height: 1.45,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 450.ms).scale(
                  begin: const Offset(0.97, 0.97),
                  end: const Offset(1, 1),
                  curve: Curves.easeOutCubic,
                ).slideY(begin: 0.06, end: 0),

            const SizedBox(height: AppSpacing.xxl),

            // ── Featured Card ──────────────────────────────────
            if (_allNews.isNotEmpty) ...[
              SectionHeader(
                title: l10n.newsFeatured,
                subtitle: l10n.newsFeaturedSubtitle,
                icon: Icons.bolt_rounded,
              ).animate(delay: 80.ms).fadeIn(duration: 280.ms).slideX(begin: -0.03, end: 0),

              const SizedBox(height: AppSpacing.md),

              FeaturedNewsCard(
                item: _allNews.first,
                onTap: () => context.push('/news-detail', extra: _allNews.first),
              ).animate(delay: 140.ms).fadeIn(duration: 320.ms).slideY(begin: 0.08, end: 0),

              const SizedBox(height: AppSpacing.xxxl),
            ],

            // ── Kategoriler ────────────────────────────────────
            SectionHeader(
              title: l10n.newsCategories,
              subtitle: l10n.newsCategoriesSubtitle,
              icon: Icons.tune_rounded,
            ).animate(delay: 120.ms).fadeIn(duration: 280.ms).slideX(begin: -0.03, end: 0),

            const SizedBox(height: AppSpacing.md),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _categories.asMap().entries.map((entry) {
                final index = entry.key;
                final category = entry.value;
                return _buildFilterChip(
                  label: _categoryLabel(l10n, category),
                  isSelected: _selectedCategory == category,
                  isDark: isDark,
                  onTap: () {
                    setState(() => _selectedCategory = category);
                  },
                ).animate(delay: Duration(milliseconds: 160 + (index * 60)))
                    .fadeIn(duration: 240.ms)
                    .slideY(begin: 0.18, end: 0);
              }).toList(),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // ── Bölgeler ───────────────────────────────────────
            SectionHeader(
              title: l10n.newsRegions,
              subtitle: l10n.newsRegionsSubtitle,
              icon: Icons.map_rounded,
            ).animate(delay: 140.ms).fadeIn(duration: 280.ms).slideX(begin: -0.03, end: 0),

            const SizedBox(height: AppSpacing.md),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _regions.asMap().entries.map((entry) {
                final index = entry.key;
                final region = entry.value;
                return _buildFilterChip(
                  label: _regionLabel(l10n, region),
                  isSelected: _selectedRegion == region,
                  isDark: isDark,
                  onTap: () {
                    setState(() => _selectedRegion = region);
                  },
                ).animate(delay: Duration(milliseconds: 160 + (index * 60)))
                    .fadeIn(duration: 240.ms)
                    .slideY(begin: 0.18, end: 0);
              }).toList(),
            ),

            const SizedBox(height: AppSpacing.xxxl),

            // ── Son Haberler ───────────────────────────────────
            SectionHeader(
              title: l10n.newsLatest,
              subtitle: _isLoading
                  ? l10n.commonLoading
                  : l10n.newsRecordsFound(filteredItems.length),
              icon: Icons.article_rounded,
            ).animate(delay: 160.ms).fadeIn(duration: 280.ms).slideX(begin: -0.03, end: 0),

            const SizedBox(height: AppSpacing.md),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              )
            else if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.wifi_off_rounded, size: 48,
                          color: AppColors.primary.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      Text(_errorMessage!, style: GoogleFonts.inter(fontSize: 15)),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _loadNews,
                        icon: const Icon(Icons.refresh),
                        label: Text(l10n.commonTryAgain),
                      ),
                    ],
                  ),
                ),
              )
            else if (filteredItems.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Text(
                    _selectedRegion != 'Tümü'
                        ? l10n.newsNoneInRegion(_regionLabel(l10n, _selectedRegion))
                        : l10n.newsNoneInCategory,
                    style: GoogleFonts.inter(fontSize: 15),
                  ),
                ),
              )
            else
              ...filteredItems.asMap().entries.map((entry) {
                final index = entry.key;
                final NewsItem item = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: NewsCard(
                    item: item,
                    onTap: () => context.push('/news-detail', extra: item),
                  ).animate()
                      .fadeIn(duration: 300.ms, delay: (220 + (index * 70)).ms)
                      .slideX(begin: 0.03, end: 0)
                      .scale(begin: const Offset(0.98, 0.98), end: const Offset(1, 1)),
                );
              }),
          ],
        ),
      ),
    );
  }
}