import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../l10n/app_localizations.dart';
import '../../models/fire_point.dart';
import '../../services/fire_api_service.dart';
import '../../services/fire_mapper.dart';
import '../../services/offline_cache_service.dart';
import '../../services/watchlist_provider.dart';
import '../../shared/coach_mark_keys.dart';
import '../../shared/widgets/coach_mark_overlay.dart';
import '../../shared/widgets/glass_panel.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/skeleton_loader.dart';
import '../../shared/widgets/status_chip.dart';

class WatchlistScreen extends ConsumerStatefulWidget {
  const WatchlistScreen({super.key});

  @override
  ConsumerState<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends ConsumerState<WatchlistScreen> {
  static const _cacheKey = 'watchlist_fires';

  final FireApiService _fireApiService = FireApiService();
  List<FirePoint> _allFires = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFires().then((_) => _maybeShowWatchlistCoachMarks());
  }

  void _maybeShowWatchlistCoachMarks() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      await maybeShowScreenCoachMarks(
        context,
        prefsKey: 'hasSeenWatchlistTour',
        steps: [
          CoachMarkStep(
            targetKey: CoachMarkKeys.watchlistHeader,
            title: l10n.coachMarkWatchlistPurposeTitle,
            description: l10n.coachMarkWatchlistPurposeDesc,
          ),
          CoachMarkStep(
            targetKey: CoachMarkKeys.watchlistEmptyState,
            title: l10n.coachMarkWatchlistHowToAddTitle,
            description: l10n.coachMarkWatchlistHowToAddDesc,
          ),
          CoachMarkStep(
            targetKey: CoachMarkKeys.watchlistClearButton,
            title: l10n.coachMarkWatchlistClearTitle,
            description: l10n.coachMarkWatchlistClearDesc,
          ),
          CoachMarkStep(
            targetKey: CoachMarkKeys.watchlistList,
            title: l10n.coachMarkWatchlistTapTitle,
            description: l10n.coachMarkWatchlistTapDesc,
          ),
        ],
      );
    });
  }

  Future<void> _loadFires() async {
    if (mounted) setState(() => _loading = true);
    try {
      final fires = await _fireApiService.fetchTurkeyFiresWithCities();
      await OfflineCacheService.instance.save(_cacheKey, fires.map((p) => p.toJson()).toList());
      if (mounted) setState(() { _allFires = fires; _loading = false; });
    } catch (_) {
      final cached = await OfflineCacheService.instance.load(_cacheKey);
      if (mounted) {
        setState(() {
          if (cached != null) {
            final (data, _) = cached;
            _allFires = (data as List).map((e) => FirePoint.fromJson(e as Map<String, dynamic>)).toList();
          }
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final savedIds = ref.watch(watchlistProvider);

    // Kaydedilen yangın noktalarını bul
    final savedFires = _allFires.where((fire) {
      final id = '${fire.latitude}-${fire.longitude}-${fire.acquisitionDate}-${fire.acquisitionTime}';
      return savedIds.contains(id);
    }).toList();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final titleColor = theme.textTheme.titleLarge?.color ??
        (isDark ? AppColors.white : const Color(0xFF0F172A));
    final secondaryTextColor = isDark
        ? AppColors.white.withValues(alpha: 0.74)
        : Colors.black.withValues(alpha: 0.66);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.watchlistTitle, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        actions: [
          if (savedIds.isNotEmpty)
            TextButton(
              key: CoachMarkKeys.watchlistClearButton,
              onPressed: () => ref.read(watchlistProvider.notifier).clear(),
              child: Text(l10n.watchlistClear,
                  style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w700)),
            ).animate().fadeIn(duration: 240.ms).slideX(begin: 0.2, end: 0),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadFires,
        color: AppColors.primary,
        child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassPanel(
              key: CoachMarkKeys.watchlistHeader,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatusChip(
                    label: savedIds.isEmpty ? l10n.watchlistNoRecords : l10n.watchlistRecordCount(savedIds.length),
                    icon: Icons.bookmark_rounded,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(l10n.watchlistHeading,
                      style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: titleColor)),
                  const SizedBox(height: AppSpacing.sm),
                  Text(l10n.watchlistHeadingSubtitle,
                      style: GoogleFonts.inter(fontSize: 15, height: 1.45, color: secondaryTextColor)),
                ],
              ),
            ).animate().fadeIn(duration: 450.ms).scale(
                  begin: const Offset(0.97, 0.97), end: const Offset(1, 1), curve: Curves.easeOutCubic,
                ).slideY(begin: 0.06, end: 0),

            const SizedBox(height: AppSpacing.xxl),

            if (_loading)
              const SkeletonListLoader(count: 2)
            else if (savedIds.isEmpty)
              GlassPanel(
                key: CoachMarkKeys.watchlistEmptyState,
                child: Column(
                  children: [
                    Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), shape: BoxShape.circle),
                      child: const Icon(Icons.bookmark_border_rounded, color: AppColors.primary, size: 34),
                    ).animate(onPlay: (c) => c.repeat(reverse: true))
                        .scale(begin: const Offset(0.96, 0.96), end: const Offset(1.04, 1.04), duration: 1400.ms, curve: Curves.easeInOut),
                    const SizedBox(height: AppSpacing.lg),
                    Text(l10n.watchlistEmptyTitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: titleColor))
                        .animate(delay: 100.ms).fadeIn(duration: 260.ms).slideY(begin: 0.1, end: 0),
                    const SizedBox(height: AppSpacing.sm),
                    Text(l10n.watchlistEmptySubtitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontSize: 14, height: 1.45, color: secondaryTextColor))
                        .animate(delay: 170.ms).fadeIn(duration: 260.ms).slideY(begin: 0.1, end: 0),
                  ],
                ),
              ).animate(delay: 120.ms).fadeIn(duration: 320.ms).scale(begin: const Offset(0.98, 0.98), end: const Offset(1, 1)).slideY(begin: 0.05, end: 0)
            else ...[
              SectionHeader(
                key: CoachMarkKeys.watchlistList,
                title: l10n.watchlistSavedPoints,
                subtitle: l10n.watchlistSavedPointsSubtitle(savedIds.length),
                icon: const Icon(Icons.local_fire_department_rounded),
              ).animate(delay: 100.ms).fadeIn(duration: 280.ms).slideX(begin: -0.03, end: 0),
              const SizedBox(height: AppSpacing.md),

              if (savedFires.isEmpty)
                GlassPanel(
                  child: Column(
                    children: [
                      const Icon(Icons.sync_rounded, color: AppColors.primary, size: 32),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        l10n.watchlistSyncingTitle(savedIds.length),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: titleColor),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        l10n.watchlistSyncingSubtitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontSize: 13, height: 1.45, color: secondaryTextColor),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      OutlinedButton.icon(
                        onPressed: _loadFires,
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(l10n.commonRefresh),
                      ),
                    ],
                  ),
                )
              else
                ...savedFires.asMap().entries.map((entry) {
                  final index = entry.key;
                  final point = entry.value;
                  final bright = double.tryParse(point.brightness) ?? 0;
                  final tempC = bright > 200 ? (bright - 273.15).toStringAsFixed(0) : bright.toStringAsFixed(0);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: GlassPanel(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: InkWell(
                        onTap: () => context.push('/fire-detail', extra: convertPointToFireEvent(point, l10n)),
                        borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    point.cityName != null
                                        ? '${point.cityName} — ${point.nearestRegion ?? point.regionDisplayName(l10n)}'
                                        : point.regionDisplayName(l10n),
                                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: titleColor),
                                  ),
                                ),
                                StatusChip(label: point.detectionTitle(l10n), icon: Icons.satellite_alt_rounded, color: point.detectionColor),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text('${point.formattedDate} • ${point.formattedTime} UTC',
                                style: GoogleFonts.inter(fontSize: 12, color: secondaryTextColor.withValues(alpha: 0.7))),
                            const SizedBox(height: AppSpacing.sm),
                            Text(point.riskReasonText(l10n),
                                maxLines: 2, overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(fontSize: 13, height: 1.4, color: secondaryTextColor)),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              children: [
                                Icon(Icons.thermostat_rounded, size: 13, color: secondaryTextColor),
                                const SizedBox(width: 4),
                                Text('$tempC°C', style: GoogleFonts.inter(fontSize: 12, color: secondaryTextColor)),
                                const SizedBox(width: 12),
                                Icon(Icons.satellite_alt_rounded, size: 13, color: point.isMerged ? AppColors.success : secondaryTextColor),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(point.mergedSatelliteLabel,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: point.isMerged ? FontWeight.w700 : FontWeight.normal,
                                          color: point.isMerged ? AppColors.success : secondaryTextColor)),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () {
                                    final id = '${point.latitude}-${point.longitude}-${point.acquisitionDate}-${point.acquisitionTime}';
                                    ref.read(watchlistProvider.notifier).toggle(id);
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: const SizedBox(
                                    width: 48,
                                    height: 48,
                                    child: Center(child: Icon(Icons.bookmark_rounded, color: AppColors.primary, size: 20)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ).animate()
                        .fadeIn(duration: 300.ms, delay: (160 + (index * 70)).ms)
                        .slideX(begin: 0.03, end: 0)
                        .scale(begin: const Offset(0.98, 0.98), end: const Offset(1, 1), duration: 260.ms),
                  );
                }),
            ],
          ],
        ),
        ),
      ),
    );
  }
}
