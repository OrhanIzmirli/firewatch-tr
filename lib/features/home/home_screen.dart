import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../l10n/app_localizations.dart';
import '../../models/fire_point.dart';
import '../../models/news_item.dart';
import '../../services/fire_api_service.dart';
import '../../services/fire_mapper.dart';
import '../../services/news_service.dart';
import '../../services/offline_cache_service.dart';
import '../../services/watchlist_provider.dart';
import '../../shared/coach_mark_keys.dart';
import '../../shared/widgets/glass_panel.dart';
import '../../shared/widgets/offline_banner.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/skeleton_loader.dart';
import '../../shared/widgets/state_views.dart';
import '../../shared/widgets/status_chip.dart';
import '../../shared/widgets/summary_card.dart';
import '../../shared/widgets/trust_info_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const _newsCacheKey = 'home_news';
  static const _firesCacheKey = 'home_fires';

  final TextEditingController _searchController = TextEditingController();
  final NewsService _newsService = NewsService();
  final FireApiService _fireApiService = FireApiService();

  List<NewsItem> _topNews = [];
  List<FirePoint> _firePoints = [];
  // Canonical (non-localized) quick filter: 'high' | 'medium' | 'ege' | 'akdeniz' | 'marmara' | 'karadeniz'
  String? _quickFilter;
  bool _newsLoading = true;
  bool _fireLoading = true;
  bool _newsOffline = false;
  bool _firesOffline = false;
  DateTime? _newsCachedAt;
  DateTime? _firesCachedAt;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadNews(), _loadFires()]);
  }

  Future<void> _loadNews() async {
    if (mounted) setState(() => _newsLoading = true);
    try {
      final news = await _newsService.fetchNewsFromRender(limit: 3);
      await OfflineCacheService.instance.save(_newsCacheKey, news.map((n) => n.toJson()).toList());
      if (mounted) setState(() { _topNews = news; _newsLoading = false; _newsOffline = false; });
    } catch (_) {
      final cached = await OfflineCacheService.instance.load(_newsCacheKey);
      if (mounted) {
        setState(() {
          if (cached != null) {
            final (data, savedAt) = cached;
            _topNews = (data as List).map((e) => NewsItem.fromJson(e as Map<String, dynamic>)).toList();
            _newsCachedAt = savedAt;
            _newsOffline = true;
          }
          _newsLoading = false;
        });
      }
    }
  }

  Future<void> _loadFires() async {
    if (mounted) setState(() => _fireLoading = true);
    try {
      final fires = await _fireApiService.fetchTurkeyFires();
      final enriched = <FirePoint>[];
      for (final point in fires.take(10)) {
        final cityInfo = await _fireApiService.getNearestCity(point.latitude, point.longitude);
        enriched.add(point.copyWith(cityName: cityInfo['city'], nearestRegion: cityInfo['region']));
      }
      final allPoints = [...enriched, ...fires.skip(10)];
      await OfflineCacheService.instance.save(_firesCacheKey, allPoints.map((p) => p.toJson()).toList());
      if (mounted) setState(() {
        _firePoints = allPoints;
        _fireLoading = false;
        _firesOffline = false;
      });
    } catch (_) {
      final cached = await OfflineCacheService.instance.load(_firesCacheKey);
      if (mounted) {
        setState(() {
          if (cached != null) {
            final (data, savedAt) = cached;
            _firePoints = (data as List).map((e) => FirePoint.fromJson(e as Map<String, dynamic>)).toList();
            _firesCachedAt = savedAt;
            _firesOffline = true;
          }
          _fireLoading = false;
        });
      }
    }
  }

  bool _matchesQuickFilter(FirePoint p) {
    final filter = _quickFilter;
    if (filter == null) return true;
    if (filter == 'high' || filter == 'medium') return p.riskTier == filter;
    // Region filters: match the canonical bbox key, or the raw backend
    // city/region text (proper nouns, same in every locale).
    if (p.regionKey == filter) return true;
    final nr = p.nearestRegion?.toLowerCase();
    if (nr != null && nr.contains(filter)) return true;
    final cn = p.cityName?.toLowerCase();
    if (cn != null && cn.contains(filter)) return true;
    return false;
  }

  void _showFirePreview(BuildContext context, FirePoint point) {
    final l10n = AppLocalizations.of(context)!;
    final bright = double.tryParse(point.brightness) ?? 0;
    final tempC = bright > 200 ? (bright - 273.15).toStringAsFixed(0) : bright.toStringAsFixed(0);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final titleColor = theme.textTheme.titleLarge?.color ??
        (isDark ? AppColors.white : const Color(0xFF0F172A));
    final secondaryTextColor = isDark
        ? AppColors.white.withValues(alpha: 0.74)
        : Colors.black.withValues(alpha: 0.66);

    String alanTahmini;
    if (bright >= 370) alanTahmini = l10n.homeAreaOver100Ha;
    else if (bright >= 330) alanTahmini = l10n.homeArea10to100Ha;
    else if (bright >= 300) alanTahmini = l10n.homeAreaUnder10Ha;
    else alanTahmini = l10n.homeAreaInsufficientRes;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: GlassPanel(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  StatusChip(label: point.riskLevelLabel(l10n), icon: Icons.local_fire_department_rounded, color: AppColors.forRiskTier(point.riskTier)),
                  const SizedBox(width: 8),
                  StatusChip(label: '${point.formattedDate} ${point.formattedTime}', icon: Icons.access_time_rounded),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.homeFireRegionTitle(point.regionDisplayName(l10n)),
                style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: titleColor),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                point.riskReasonText(l10n),
                style: GoogleFonts.inter(fontSize: 14, height: 1.45, color: secondaryTextColor),
              ),
              const SizedBox(height: AppSpacing.lg),
              _PreviewRow(icon: Icons.thermostat_rounded, label: l10n.commonTemperature, value: '$tempC°C'),
              const SizedBox(height: 8),
              _PreviewRow(icon: Icons.area_chart_rounded, label: l10n.homeEstimatedArea, value: alanTahmini),
              const SizedBox(height: 8),
              _PreviewRow(icon: Icons.satellite_alt_rounded, label: l10n.commonSatellite, value: point.satellite),
              const SizedBox(height: 8),
              _PreviewRow(icon: Icons.location_on_rounded, label: l10n.commonCoordinate, value: point.locationLabelText(l10n)),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        context.push('/map', extra: {'lat': point.latitude, 'lng': point.longitude});
                      },
                      icon: const Icon(Icons.map_rounded),
                      label: Text(l10n.commonViewOnMap),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        context.push('/fire-detail', extra: convertPointToFireEvent(point, l10n));
                      },
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: Text(l10n.commonDetail),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryTextColor = theme.textTheme.titleLarge?.color ??
        (isDark ? AppColors.white : const Color(0xFF0F172A));
    final secondaryTextColor = isDark
        ? AppColors.white.withValues(alpha: 0.75)
        : Colors.black.withValues(alpha: 0.68);
    final tertiaryTextColor = isDark
        ? AppColors.white.withValues(alpha: 0.62)
        : Colors.black.withValues(alpha: 0.5);

    final savedIds = ref.watch(watchlistProvider);
    final query = _searchController.text.trim().toLowerCase();

    final highConfFires = _firePoints
        .where((p) => p.confidence.toLowerCase() == 'high' || p.confidence.toLowerCase() == 'h')
        .length;
    final nominalFires = _firePoints
        .where((p) => p.confidence.toLowerCase() == 'nominal' || p.confidence.toLowerCase() == 'n')
        .length;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _loadData),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primary,
        child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_firesOffline && _firesCachedAt != null) OfflineBanner(lastUpdated: _firesCachedAt!),
            // ── Header ──────────────────────────────────────
            GlassPanel(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatusChip(label: l10n.homeLiveSummary, icon: Icons.bolt_rounded),
                  const SizedBox(height: AppSpacing.lg),
                  Text(l10n.homeHeaderTitle,
                      style: GoogleFonts.inter(fontSize: 30, fontWeight: FontWeight.w800, color: primaryTextColor)),
                  const SizedBox(height: AppSpacing.sm),
                  Text(l10n.homeHeaderSubtitle,
                      style: GoogleFonts.inter(fontSize: 16, height: 1.45, color: secondaryTextColor)),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 18, color: tertiaryTextColor),
                      const SizedBox(width: AppSpacing.sm),
                      Text(l10n.homeNasaLiveData,
                          style: GoogleFonts.inter(fontSize: 14, color: tertiaryTextColor)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          key: CoachMarkKeys.riskButton,
                          onPressed: () => context.push('/risk'),
                          icon: const Icon(Icons.auto_graph_rounded),
                          label: Text(l10n.homeRiskAnalysis),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: OutlinedButton.icon(
                          key: CoachMarkKeys.savedButton,
                          onPressed: () => context.push('/watchlist'),
                          icon: const Icon(Icons.bookmark_rounded),
                          label: Text(l10n.homeSaved(savedIds.length)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.push('/safety-guide'),
                          icon: const Icon(Icons.shield_outlined),
                          label: Text(l10n.homeSafety),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.push('/emergency'),
                          icon: const Icon(Icons.emergency_rounded),
                          label: Text(l10n.commonEmergency),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms).scale(
                  begin: const Offset(0.96, 0.96),
                  end: const Offset(1, 1),
                  curve: Curves.easeOutCubic,
                ).slideY(begin: 0.08, end: 0),

            const SizedBox(height: AppSpacing.md),
            TrustInfoCard(text: l10n.trustHomeInfo),

            const SizedBox(height: AppSpacing.xxl),

            // ── Genel Bakış ──────────────────────────────────
            SectionHeader(
              title: l10n.homeOverview,
              subtitle: l10n.homeOverviewSubtitle,
              icon: Icons.dashboard_customize_rounded,
            ),
            const SizedBox(height: AppSpacing.md),

            if (_fireLoading)
              const SkeletonMetricGrid(count: 3)
            else
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.1,
                children: [
                  SummaryCard(title: l10n.homeTotalPoints, value: _firePoints.length.toString(), icon: Icons.local_fire_department),
                  SummaryCard(title: l10n.homeHighRisk, value: highConfFires.toString(), icon: Icons.warning_amber_rounded),
                  SummaryCard(title: l10n.homeNominal, value: nominalFires.toString(), icon: Icons.verified_outlined),
                ],
              ),

            const SizedBox(height: AppSpacing.xxxl),

            // ── Son Haberler ─────────────────────────────────
            SectionHeader(
              title: l10n.homeLatestNews,
              subtitle: l10n.homeLatestNewsSubtitle,
              icon: Icons.newspaper_rounded,
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt_rounded, size: 16, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Text(l10n.homeBreakingCount(_topNews.where((e) => e.isBreaking).length),
                        style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            if (_newsOffline && _newsCachedAt != null) OfflineBanner(lastUpdated: _newsCachedAt!),
            if (_newsLoading)
              const SkeletonListLoader(count: 2)
            else if (_topNews.isEmpty)
              EmptyStateView(
                icon: Icons.newspaper_outlined,
                title: l10n.emptyStateGenericTitle,
                subtitle: l10n.emptyStateGenericSubtitle,
              )
            else
              ..._topNews.asMap().entries.map((entry) {
                final index = entry.key;
                final NewsItem item = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _HomeNewsPreviewCard(
                    item: item,
                    onTap: () => context.push('/news-detail', extra: item),
                  ).animate()
                      .fadeIn(duration: 300.ms, delay: (100 + (index * 70)).ms)
                      .slideX(begin: 0.03, end: 0)
                      .scale(begin: const Offset(0.98, 0.98), end: const Offset(1, 1)),
                );
              }),

            const SizedBox(height: AppSpacing.xxxl),

            // ── Aktif Termal Noktalar ─────────────────────────
            SectionHeader(
              title: l10n.homeActiveThermalPoints,
              subtitle: l10n.homeActiveThermalSubtitle,
              icon: FontAwesomeIcons.fireFlameCurved,
              trailing: InkWell(
                onTap: () => context.push('/map'),
                borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.map_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.sm),
                      Text(l10n.homeMap, style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Filtre chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(label: l10n.commonAll, selected: _quickFilter == null && query.isEmpty, onTap: () { _searchController.clear(); setState(() => _quickFilter = null); }),
                  const SizedBox(width: 8),
                  _FilterChip(label: l10n.homeFilterHighRisk, selected: _quickFilter == 'high', onTap: () { setState(() => _quickFilter = _quickFilter == 'high' ? null : 'high'); }),
                  const SizedBox(width: 8),
                  _FilterChip(label: l10n.homeFilterMediumRisk, selected: _quickFilter == 'medium', onTap: () { setState(() => _quickFilter = _quickFilter == 'medium' ? null : 'medium'); }),
                  const SizedBox(width: 8),
                  _FilterChip(label: l10n.regionEge, selected: _quickFilter == 'ege', onTap: () { setState(() => _quickFilter = _quickFilter == 'ege' ? null : 'ege'); }),
                  const SizedBox(width: 8),
                  _FilterChip(label: l10n.regionAkdeniz, selected: _quickFilter == 'akdeniz', onTap: () { setState(() => _quickFilter = _quickFilter == 'akdeniz' ? null : 'akdeniz'); }),
                  const SizedBox(width: 8),
                  _FilterChip(label: l10n.regionMarmara, selected: _quickFilter == 'marmara', onTap: () { setState(() => _quickFilter = _quickFilter == 'marmara' ? null : 'marmara'); }),
                  const SizedBox(width: 8),
                  _FilterChip(label: l10n.regionKaradeniz, selected: _quickFilter == 'karadeniz', onTap: () { setState(() => _quickFilter = _quickFilter == 'karadeniz' ? null : 'karadeniz'); }),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            GlassPanel(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: l10n.homeSearchHint,
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: query.isNotEmpty
                      ? IconButton(onPressed: () { _searchController.clear(); setState(() {}); }, icon: const Icon(Icons.close_rounded))
                      : null,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            if (_fireLoading)
              const SkeletonListLoader(count: 3)
            else if (_firePoints.isEmpty)
              EmptyStateView(
                icon: Icons.local_fire_department_outlined,
                title: l10n.homeNoActiveFires,
              )
            else
              ..._firePoints
                  .where((p) => _matchesQuickFilter(p) && (query.isEmpty ||
                      p.regionDisplayName(l10n).toLowerCase().contains(query) ||
                      (p.cityName?.toLowerCase().contains(query) ?? false) ||
                      (p.nearestRegion?.toLowerCase().contains(query) ?? false) ||
                      p.riskLevelLabel(l10n).toLowerCase().contains(query) ||
                      p.acquisitionDate.contains(query)))
                  .take(10)
                  .toList()
                  .asMap()
                  .entries
                  .map((entry) {
                final index = entry.key;
                final FirePoint point = entry.value;
                final bright = double.tryParse(point.brightness) ?? 0;
                final tempC = bright > 200 ? (bright - 273.15).toStringAsFixed(0) : bright.toStringAsFixed(0);

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: GlassPanel(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: InkWell(
                      onTap: () => _showFirePreview(context, point),
                      borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  point.regionDisplayName(l10n),
                                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: primaryTextColor),
                                ),
                              ),
                              StatusChip(label: point.riskLevelLabel(l10n), icon: Icons.warning_amber_rounded, color: AppColors.forRiskTier(point.riskTier)),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            '${point.formattedDate} • ${point.formattedTime} UTC',
                            style: GoogleFonts.inter(fontSize: 12, color: tertiaryTextColor),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            point.riskReasonText(l10n),
                            style: GoogleFonts.inter(fontSize: 13, height: 1.4, color: secondaryTextColor),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            children: [
                              Icon(Icons.thermostat_rounded, size: 13, color: tertiaryTextColor),
                              const SizedBox(width: 4),
                              Text('$tempC°C', style: GoogleFonts.inter(fontSize: 12, color: tertiaryTextColor)),
                              const SizedBox(width: 12),
                              Icon(Icons.satellite_alt_rounded, size: 13, color: tertiaryTextColor),
                              const SizedBox(width: 4),
                              Text(point.satellite, style: GoogleFonts.inter(fontSize: 12, color: tertiaryTextColor)),
                              const SizedBox(width: 12),
                              Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.primary),
                              Text(l10n.commonDetail, style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ).animate()
                      .fadeIn(duration: 320.ms, delay: (120 + (index * 70)).ms)
                      .slideX(begin: 0.03, end: 0)
                      .scale(begin: const Offset(0.98, 0.98), end: const Offset(1, 1), duration: 280.ms),
                );
              }),

            const SizedBox(height: 110),
          ],
        ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.primary)),
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _PreviewRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark
        ? AppColors.white.withValues(alpha: 0.65)
        : Colors.black.withValues(alpha: 0.55);

    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text('$label: ', style: GoogleFonts.inter(fontSize: 13, color: color)),
        Expanded(
          child: Text(value,
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: color),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

class _HomeNewsPreviewCard extends StatelessWidget {
  final NewsItem item;
  final VoidCallback onTap;

  const _HomeNewsPreviewCard({required this.item, required this.onTap});

  IconData _iconForCategory() {
    switch (item.category.toLowerCase()) {
      case 'risk': return Icons.auto_graph_rounded;
      case 'operasyon': return Icons.local_fire_department_rounded;
      case 'güvenlik': return Icons.shield_outlined;
      case 'güncelleme': return Icons.update_rounded;
      default: return Icons.article_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = Theme.of(context).textTheme.titleMedium?.color ??
        (isDark ? AppColors.white : const Color(0xFF0F172A));
    final summaryColor = isDark
        ? AppColors.white.withValues(alpha: 0.7)
        : Colors.black.withValues(alpha: 0.64);
    final metaColor = isDark
        ? AppColors.white.withValues(alpha: 0.52)
        : Colors.black.withValues(alpha: 0.46);
    final arrowColor = isDark
        ? AppColors.white.withValues(alpha: 0.42)
        : Colors.black.withValues(alpha: 0.3);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius),
        child: Ink(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius)),
          child: GlassPanel(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(_iconForCategory(), color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8, runSpacing: 8,
                        children: [
                          StatusChip(label: item.category, icon: _iconForCategory()),
                          if (item.isBreaking) const StatusChip(label: 'Breaking', icon: Icons.bolt_rounded),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(item.title,
                          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, height: 1.2, color: titleColor)),
                      const SizedBox(height: AppSpacing.sm),
                      Text(item.summary, maxLines: 2, overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(fontSize: 13, height: 1.45, color: summaryColor)),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(child: Text('${item.source} • ${item.publishedAt}',
                              style: GoogleFonts.inter(fontSize: 12, color: metaColor))),
                          Text('${item.readMinutes} dk',
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(Icons.arrow_forward_ios_rounded, size: 15, color: arrowColor)
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .moveX(begin: 0, end: 3, duration: 900.ms, curve: Curves.easeInOut),
              ],
            ),
          ),
        ),
      ),
    );
  }
}