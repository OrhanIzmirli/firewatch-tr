import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/utils/news_content_analysis.dart';
import '../../core/utils/turkish_text.dart';
import '../../l10n/app_localizations.dart';
import '../../models/news_item.dart';
import '../../models/tracked_place.dart';
import '../../services/tracked_places_provider.dart';
import '../../services/fire_api_service.dart';
import '../../services/news_service.dart';
import '../../services/offline_cache_service.dart';
import '../../shared/coach_mark_keys.dart';
import '../../shared/widgets/coach_mark_overlay.dart';
import '../../shared/widgets/english_translation_banner.dart';
import '../../shared/widgets/skeleton_loader.dart';
import '../../shared/widgets/state_views.dart';
import '../../shared/widgets/trust_info_card.dart';
import 'news_story_screen.dart';
import 'widgets/news_visual.dart';
import '../../services/location_disclosure.dart';
import '../../services/device_position.dart';
import '../../shared/widgets/alerts_bell.dart';

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
  final FireApiService _fireApiService = FireApiService();
  final ScrollController _scrollController = ScrollController();

  final String _contentType = 'fires';
  Map<String, NewsStory> _storyByNews = const {};
  final Set<String> _placeCities = {};
  String? _myCityRaw;
  List<NewsItem> _allNews = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _showingCached = false;
  String? _errorMessage;

  /// Raw items fetched for the current tab, before the client-side
  /// content-type filter — the next page's offset.
  int _fetchedCount = 0;

  /// Bumped on every reload so a slow response for a tab the user already
  /// left cannot overwrite the tab they are looking at.
  int _loadGeneration = 0;

  bool get _isFiresTab => _contentType == 'fires';

  /// The fires tab keeps the original cache key so existing installs keep
  /// their saved feed; the new tabs get one key each.
  String get _tabCacheKey => _isFiresTab ? _cacheKey : 'news_$_contentType';

  String? get _contentTypeParam => _isFiresTab ? null : _contentType;

  List<NewsItem> _ofCurrentType(List<NewsItem> items) =>
      items.where((n) => n.contentType == _contentType).toList();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Best-effort location fetch for the "My Region" filter — silently does
  /// nothing if permission is denied, location is unavailable, or the user
  /// is outside Turkey, since that filter chip just won't match anything.
  Future<void> _loadMyRegion() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        permission = await LocationDisclosure.requestPermission(context);
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return;
      final position = await DevicePosition.current(accuracy: LocationAccuracy.low, timeLimit: const Duration(seconds: 8));
      final cityInfo = await _fireApiService.getNearestCity(position.latitude, position.longitude);
      if (!mounted || cityInfo.outsideTurkey) return;
      setState(() {
        _myCityRaw = cityInfo.city;
      });
    } catch (_) {
      // "My Region" filter just won't be available.
    }
  }

  @override
  void initState() {
    super.initState();
    _loadNews().then((_) => _maybeShowNewsCoachMarks());
    _loadMyRegion();
    _loadPlaceCities();
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
    final generation = ++_loadGeneration;
    _loadStories();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _hasMore = true;
    });
    await _showSavedWhileLoading(generation);

    try {
      final raw = await _newsService.fetchNewsFromRender(
        category: null,
        contentType: _contentTypeParam,
        limit: _pageSize,
        offset: 0,
      );
      final news = _ofCurrentType(raw);
      {
        await OfflineCacheService.instance.save(_tabCacheKey, news.map((n) => n.toJson()).toList());
      }
      if (!mounted || generation != _loadGeneration) return;
      setState(() {
        _allNews = news;
        _fetchedCount = raw.length;
        _isLoading = false;
        _showingCached = false;
        _hasMore = raw.length >= _pageSize;
      });
    } catch (e) {
      if (!mounted || generation != _loadGeneration) return;
      final cached = await OfflineCacheService.instance.load(_tabCacheKey);
      if (!mounted || generation != _loadGeneration) return;
      if (cached != null) {
        final (data, _) = cached;
        setState(() {
          _allNews = (data as List)
              .map((e) => NewsItem.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList();
          _isLoading = false;
          _hasMore = false;
          _showingCached = true;
        });
      } else {
        setState(() {
          _errorMessage = AppLocalizations.of(context)!.newsFetchFailed;
          _isLoading = false;
        });
      }
    }
  }

  /// The list from last time appears at once and is replaced when the new
  /// one arrives, so a slow connection does not mean an empty screen.
  Future<void> _showSavedWhileLoading(int generation) async {
    if (_allNews.isNotEmpty) return;
    final cached = await OfflineCacheService.instance.load(_tabCacheKey);
    if (cached == null || !mounted || generation != _loadGeneration) return;
    final (data, _) = cached;
    setState(() {
      _allNews = (data as List).map((e) => NewsItem.fromJson(Map<String, dynamic>.from(e as Map))).toList();
      _isLoading = false;
      _showingCached = true;
    });
  }

  Future<void> _loadMore() async {
    final generation = _loadGeneration;
    setState(() => _isLoadingMore = true);
    try {
      final raw = await _newsService.fetchNewsFromRender(
        category: null,
        contentType: _contentTypeParam,
        limit: _pageSize,
        offset: _fetchedCount,
      );
      if (!mounted || generation != _loadGeneration) return;
      setState(() {
        _allNews = [..._allNews, ..._ofCurrentType(raw)];
        _fetchedCount += raw.length;
        _hasMore = raw.length >= _pageSize;
        _isLoadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
    }
  }

  /// One row per fire: the newest headline stands for its story.
  List<NewsItem> get _feed {
    final seen = <String>{};
    return _allNews.where((n) {
      final story = _storyByNews[n.id];
      return story == null || seen.add(story.id);
    }).toList();
  }

  /// Headlines naming the province the phone is in or one of the Yerlerim.
  List<NewsItem> _localNews(List<NewsItem> feed) {
    final mine = {if (_myCityRaw != null) foldTurkish(_myCityRaw!), ..._placeCities};
    if (mine.isEmpty) return const [];
    return feed.skip(1).where((n) => n.province.isNotEmpty && mine.contains(foldTurkish(n.province))).take(4).toList();
  }

  Future<void> _loadStories() async {
    try {
      final stories = await _newsService.fetchStories();
      if (!mounted) return;
      setState(() {
        _storyByNews = {for (final s in stories) for (final i in s.items) '${i.id}': s};
      });
    } catch (_) {
      // The list simply stays ungrouped.
    }
  }

  Future<void> _loadPlaceCities() async {
    final raw = (await SharedPreferences.getInstance()).getString(TrackedPlacesNotifier.cacheKey);
    if (raw == null) return;
    final places = [for (final p in jsonDecode(raw) as List) TrackedPlace.fromJson(Map<String, dynamic>.from(p as Map))];
    for (final place in places) {
      try {
        final info = await _fireApiService.getNearestCity(place.latitude, place.longitude);
        if (!mounted) return;
        if (!info.outsideTurkey && info.city != null) setState(() => _placeCities.add(foldTurkish(info.city!)));
      } catch (_) {
        // Skip this place.
      }
    }
  }

  void _openStory(NewsStory story) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => NewsStoryScreen(story: story)));

  Widget? _groupLink(AppLocalizations l10n, NewsItem item) {
    final story = _storyByNews[item.id];
    if (story == null) return null;
    return InkWell(
      key: Key('newsGroup-${story.id}'),
      onTap: () => _openStory(story),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          const Icon(Icons.layers_outlined, size: 17, color: AppColors.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              story.isTimeline ? '${l10n.newsFireStory} · ${l10n.newsCount(story.count)}' : l10n.newsSameFire(story.count),
              style: GoogleFonts.ibmPlexSans(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
          const Icon(Icons.chevron_right, size: 18, color: AppColors.primary),
        ]),
      ),
    );
  }

  Widget _featured(AppLocalizations l10n, NewsItem item) {
    final muted = Theme.of(context).textTheme.bodySmall?.color;
    return Column(
      key: CoachMarkKeys.newsFeatured,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => openNewsSource(item.sourceUrl),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ClipRRect(borderRadius: BorderRadius.circular(16), child: SizedBox(height: 186, child: NewsImage(title: item.title, thumbPath: item.thumbPath, full: true))),
            const SizedBox(height: 9),
            Row(children: [
              NewsSourceMark(source: item.source, logoUrl: item.sourceLogoUrl, size: 22),
              const SizedBox(width: 7),
              Expanded(child: Text(item.source, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600, color: muted))),
              Text(formatNewsTimeAgo(l10n, item.publishedAt), style: GoogleFonts.ibmPlexSans(fontSize: 12.5, color: muted)),
            ]),
            const SizedBox(height: 5),
            NewsTitle(id: item.id, title: item.title, maxLines: 4, style: GoogleFonts.ibmPlexSans(fontSize: 22, fontWeight: FontWeight.w800, height: 1.2)),
            const SizedBox(height: 8),
          ]),
        ),
        ?_groupLink(l10n, item),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final feed = _feed;
    final local = _localNews(feed);
    const thinLine = Divider(height: 1, thickness: 0.6);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final secondaryTextColor = isDark
        ? AppColors.white.withValues(alpha: 0.74)
        : Colors.black.withValues(alpha: 0.66);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.newsTitle,
          style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700),
        ),
        actions: [
          const AlertsBell(),
          IconButton(
            tooltip: l10n.commonRefresh,
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
            if (_showingCached && !_isLoading)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Row(
                  children: [
                    const Icon(Icons.cloud_off_rounded, size: 16, color: AppColors.warning),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: Text(l10n.newsShowingSaved, style: GoogleFonts.ibmPlexSans(fontSize: 13, color: secondaryTextColor))),
                  ],
                ),
              ),
            if (Localizations.localeOf(context).languageCode == 'en' && !_englishBannerDismissed)
              EnglishTranslationBanner(onDismiss: () => setState(() => _englishBannerDismissed = true)),

            if (_isLoading)
              const SkeletonListLoader(count: 4)
            else if (_errorMessage != null)
              ErrorStateView(message: _errorMessage, onRetry: _loadNews)
            else if (feed.isEmpty)
              EmptyStateView(
                icon: Icons.article_outlined,
                title: _isFiresTab ? l10n.newsNoneInCategory : l10n.newsNoneInTab,
              )
            else ...[
              _featured(l10n, feed.first),
              thinLine,
              for (final item in feed.skip(1)) ...[
                NewsListRow(key: item.id == feed[1].id ? CoachMarkKeys.newsList : null, item: item),
                ?_groupLink(l10n, item),
                thinLine,
              ],
              if (local.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(l10n.newsInProvince, key: const Key('newsInProvince'), style: GoogleFonts.ibmPlexSans(fontSize: 19, fontWeight: FontWeight.w800)),
                for (final item in local) ...[NewsListRow(item: item), thinLine],
              ],
              if (_isLoadingMore)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.4)),
                ),
            ],
            const SizedBox(height: AppSpacing.lg),
            PageAboutLink(
              meaning: l10n.trustNewsMeaning,
              source: l10n.trustNewsSource,
              interpret: l10n.trustNewsInterpret,
              action: l10n.trustNewsAction,
            ),
          ],
        ),
        ),
      ),
    );
  }
}