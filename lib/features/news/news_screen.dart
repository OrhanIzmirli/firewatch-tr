import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../l10n/app_localizations.dart';
import '../../models/news_item.dart';
import '../../services/news_service.dart';
import '../../services/offline_cache_service.dart';
import '../../shared/coach_mark_keys.dart';
import '../../shared/widgets/coach_mark_overlay.dart';
import '../../shared/widgets/english_translation_banner.dart';
import '../../shared/widgets/glass_panel.dart';
import '../../shared/widgets/offline_banner.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/skeleton_loader.dart';
import '../../shared/widgets/state_views.dart';
import '../../shared/widgets/status_chip.dart';
import '../../shared/widgets/trust_info_card.dart';
import 'widgets/featured_news_card.dart';
import 'widgets/news_card.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  static const _cacheKey = 'news_list';
  static const _pageSize = 20;

  // Static (not instance) so it survives this screen being disposed and
  // recreated on every tab switch — "once per session" means once per app
  // launch, not once per visit to the News tab.
  static bool _englishBannerDismissed = false;

  final NewsService _newsService = NewsService();
  final ScrollController _scrollController = ScrollController();

  String _selectedCategory = 'Tümü';
  String _selectedRegion = 'Tümü';
  List<NewsItem> _allNews = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _isOffline = false;
  DateTime? _cachedAt;
  String? _errorMessage;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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
    _loadNews().then((_) => _maybeShowNewsCoachMarks());
    _scrollController.addListener(_onScroll);
  }

  void _maybeShowNewsCoachMarks() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      await maybeShowScreenCoachMarks(
        context,
        prefsKey: 'hasSeenNewsTour',
        steps: [
          CoachMarkStep(
            targetKey: CoachMarkKeys.newsFeatured,
            title: l10n.coachMarkNewsFeaturedTitle,
            description: l10n.coachMarkNewsFeaturedDesc,
          ),
          CoachMarkStep(
            targetKey: CoachMarkKeys.newsCategoryFilters,
            title: l10n.coachMarkNewsCategoryTitle,
            description: l10n.coachMarkNewsCategoryDesc,
          ),
          CoachMarkStep(
            targetKey: CoachMarkKeys.newsRegionFilters,
            title: l10n.coachMarkNewsRegionTitle,
            description: l10n.coachMarkNewsRegionDesc,
          ),
          CoachMarkStep(
            targetKey: CoachMarkKeys.newsList,
            title: l10n.coachMarkNewsListTitle,
            description: l10n.coachMarkNewsListDesc,
          ),
        ],
      );
    });
  }

  void _onScroll() {
    if (!_hasMore || _isLoadingMore || _isLoading) return;
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadNews() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _hasMore = true;
    });

    try {
      final news = await _newsService.fetchNewsFromRender(
        category: _categoryParams[_selectedCategory],
        limit: _pageSize,
        offset: 0,
      );
      if (_selectedCategory == 'Tümü') {
        await OfflineCacheService.instance.save(_cacheKey, news.map((n) => n.toJson()).toList());
      }
      if (!mounted) return;
      setState(() {
        _allNews = news;
        _isLoading = false;
        _isOffline = false;
        _hasMore = news.length >= _pageSize;
      });
    } catch (e) {
      if (!mounted) return;
      final cached = await OfflineCacheService.instance.load(_cacheKey);
      if (cached != null) {
        final (data, savedAt) = cached;
        setState(() {
          _allNews = (data as List).map((e) => NewsItem.fromJson(e as Map<String, dynamic>)).toList();
          _cachedAt = savedAt;
          _isOffline = true;
          _isLoading = false;
          _hasMore = false;
        });
      } else {
        setState(() {
          _errorMessage = AppLocalizations.of(context)!.newsFetchFailed;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);
    try {
      final more = await _newsService.fetchNewsFromRender(
        category: _categoryParams[_selectedCategory],
        limit: _pageSize,
        offset: _allNews.length,
      );
      if (!mounted) return;
      setState(() {
        _allNews = [..._allNews, ...more];
        _hasMore = more.length >= _pageSize;
        _isLoadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
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
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 48,
        child: Center(
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
      body: RefreshIndicator(
        onRefresh: _loadNews,
        color: AppColors.primary,
        child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isOffline && _cachedAt != null) OfflineBanner(lastUpdated: _cachedAt!),
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

            const SizedBox(height: AppSpacing.md),
            TrustInfoCardGroup(
              meaning: l10n.trustNewsMeaning,
              source: l10n.trustNewsSource,
              interpret: l10n.trustNewsInterpret,
              action: l10n.trustNewsAction,
            ),

            const SizedBox(height: AppSpacing.xxl),

            // ── Featured Card ──────────────────────────────────
            if (_allNews.isNotEmpty) ...[
              SectionHeader(
                key: CoachMarkKeys.newsFeatured,
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
              key: CoachMarkKeys.newsCategoryFilters,
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
              key: CoachMarkKeys.newsRegionFilters,
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
              key: CoachMarkKeys.newsList,
              title: l10n.newsLatest,
              subtitle: _isLoading
                  ? l10n.commonLoading
                  : l10n.newsRecordsFound(filteredItems.length),
              icon: Icons.article_rounded,
            ).animate(delay: 160.ms).fadeIn(duration: 280.ms).slideX(begin: -0.03, end: 0),

            const SizedBox(height: AppSpacing.md),

            if (Localizations.localeOf(context).languageCode == 'en' && !_englishBannerDismissed)
              EnglishTranslationBanner(
                onDismiss: () => setState(() => _englishBannerDismissed = true),
              ),

            if (_isLoading)
              const SkeletonListLoader(count: 4)
            else if (_errorMessage != null)
              ErrorStateView(message: _errorMessage, onRetry: _loadNews)
            else if (filteredItems.isEmpty)
              EmptyStateView(
                icon: Icons.article_outlined,
                title: _selectedRegion != 'Tümü'
                    ? l10n.newsNoneInRegion(_regionLabel(l10n, _selectedRegion))
                    : l10n.newsNoneInCategory,
              )
            else ...[
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
              if (_isLoadingMore)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.4)),
                ),
            ],
          ],
        ),
        ),
      ),
    );
  }
}