import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/utils/turkish_text.dart';
import '../../core/utils/wind_direction.dart';
import '../../l10n/app_localizations.dart';
import '../../models/fire_event.dart';
import '../../models/fire_point.dart';
import '../../models/news_item.dart';
import '../../services/news_service.dart';
import '../../services/news_translation_service.dart';
import '../../services/watchlist_provider.dart';
import '../../services/wind_service.dart';
import '../../shared/widgets/glass_panel.dart';
import '../../shared/widgets/info_icon_button.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/skeleton_loader.dart';
import '../../shared/widgets/status_chip.dart';

enum _RelatedNewsTier { region, city, generic }

class FireDetailScreen extends ConsumerStatefulWidget {
  final FireEvent fireEvent;

  const FireDetailScreen({super.key, required this.fireEvent});

  @override
  ConsumerState<FireDetailScreen> createState() => _FireDetailScreenState();
}

class _FireDetailScreenState extends ConsumerState<FireDetailScreen> {
  final NewsService _newsService = NewsService();
  Future<List<NewsItem>>? _newsFuture;
  Future<WindReading?>? _windFuture;

  bool _autoTranslateKicked = false;
  final Set<String> _translatingIds = {};
  final Map<String, String> _translatedTitles = {};
  final Map<String, String> _translatedSummaries = {};

  @override
  void initState() {
    super.initState();
    // Fetch a larger candidate pool so _selectRelatedNews has enough to
    // work with — only the top 3 after tiering are actually shown/translated.
    _newsFuture = _newsService.fetchNewsFromRender(limit: 20);
    _windFuture = WindService.instance.getWind(widget.fireEvent.lat, widget.fireEvent.lng);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_autoTranslateKicked) return;
    _autoTranslateKicked = true;
    if (Localizations.localeOf(context).languageCode != 'en') return;
    _newsFuture?.then((items) {
      if (!mounted) return;
      final (selected, _) = _selectRelatedNews(items, widget.fireEvent);
      for (final item in selected) {
        _autoTranslateItem(item);
      }
    });
  }

  /// Picks up to 3 related news articles, preferring the most specific
  /// match: (1) the article's relatedRegion matches the fire's region,
  /// (2) the fire's city/region name appears in the article title, (3)
  /// falls back to the most recent fire-related news already returned.
  (List<NewsItem>, _RelatedNewsTier) _selectRelatedNews(List<NewsItem> allNews, FireEvent fire) {
    final fireRegionFold = foldTurkish(fire.regionNameTr);
    final cityFold = foldTurkish(fire.city);

    final regionMatches = allNews.where((n) => foldTurkish(n.relatedRegion) == fireRegionFold).toList();
    if (regionMatches.isNotEmpty) {
      return (regionMatches.take(3).toList(), _RelatedNewsTier.region);
    }

    final titleMatches = allNews.where((n) {
      final titleFold = foldTurkish(n.title);
      return (cityFold.isNotEmpty && titleFold.contains(cityFold)) || titleFold.contains(fireRegionFold);
    }).toList();
    if (titleMatches.isNotEmpty) {
      return (titleMatches.take(3).toList(), _RelatedNewsTier.city);
    }

    return (allNews.take(3).toList(), _RelatedNewsTier.generic);
  }

  Future<void> _autoTranslateItem(NewsItem item) async {
    if (!mounted) return;
    setState(() => _translatingIds.add(item.id));
    try {
      final title = await NewsTranslationService.instance.translate(
        articleId: item.id,
        field: 'title',
        text: item.title,
      );
      final summary = await NewsTranslationService.instance.translate(
        articleId: item.id,
        field: 'summary',
        text: item.summary,
      );
      if (!mounted) return;
      setState(() {
        _translatedTitles[item.id] = title;
        _translatedSummaries[item.id] = summary;
        _translatingIds.remove(item.id);
      });
    } catch (_) {
      // Falls back to showing the original Turkish text below.
      if (!mounted) return;
      setState(() => _translatingIds.remove(item.id));
    }
  }

  // "1041" → "10:41" → "X saat önce"
  String _formatUpdatedAt(BuildContext context, String raw) {
    final l10n = AppLocalizations.of(context)!;
    try {
      // Eğer sayısal ise saat formatına çevir
      if (RegExp(r'^\d{3,4}$').hasMatch(raw.trim())) {
        final padded = raw.trim().padLeft(4, '0');
        final hour = int.parse(padded.substring(0, 2));
        final minute = int.parse(padded.substring(2, 4));
        final now = DateTime.now();
        final dt = DateTime(now.year, now.month, now.day, hour, minute);
        final diff = now.difference(dt);
        if (diff.inMinutes < 1) return l10n.timeAgoJustNow;
        if (diff.inMinutes < 60) return l10n.timeAgoMinutes(diff.inMinutes);
        if (diff.inHours < 24) return l10n.timeAgoHours(diff.inHours);
        return l10n.timeAgoDays(diff.inDays);
      }
      return raw;
    } catch (_) {
      return raw;
    }
  }

  String _frpDisplayValue(AppLocalizations l10n, double frp) {
    if (frp <= 0) return l10n.fireDetailFrpUnavailable;
    final String intensity;
    if (frp > 100) {
      intensity = l10n.frpIntensityVeryHigh;
    } else if (frp > 50) {
      intensity = l10n.frpIntensityHigh;
    } else if (frp >= 10) {
      intensity = l10n.frpIntensityModerate;
    } else {
      intensity = l10n.frpIntensityLow;
    }
    return l10n.fireDetailFrpValue(frp.round().toString(), intensity);
  }

  Future<void> _openNewsUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _openInAppMap() {
    context.push('/map');
  }

  Future<void> _shareFireEvent() async {
    final l10n = AppLocalizations.of(context)!;
    final fire = widget.fireEvent;
    final text = l10n.fireDetailShareText(
      fire.title,
      fire.city,
      fire.district,
      fire.status,
      fire.riskLevel,
      fire.description,
    );
    await Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final fire = widget.fireEvent;
    final savedIds = ref.watch(watchlistProvider);
    final isSaved = savedIds.contains(fire.id);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final titleColor = theme.textTheme.titleLarge?.color ??
        (isDark ? AppColors.white : const Color(0xFF0F172A));
    final secondaryTextColor = isDark
        ? AppColors.white.withValues(alpha: 0.74)
        : Colors.black.withValues(alpha: 0.66);
    final tertiaryTextColor = isDark
        ? AppColors.white.withValues(alpha: 0.62)
        : Colors.black.withValues(alpha: 0.5);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.fireDetailTitle,
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
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
                  StatusChip(
                    label: fire.status,
                    icon: Icons.local_fire_department_rounded,
                    color: AppColors.forRiskTier(fire.riskTier),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: fireStatusColor(fire.smartStatus).withValues(alpha: isDark ? 0.16 : 0.12),
                      borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
                      border: Border.all(color: fireStatusColor(fire.smartStatus).withValues(alpha: 0.35)),
                    ),
                    child: Row(
                      children: [
                        Text(fireStatusEmoji(fire.smartStatus), style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          fireStatusLabel(l10n, fire.smartStatus),
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: fireStatusColor(fire.smartStatus)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(fire.title,
                      style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: titleColor)),
                  const SizedBox(height: AppSpacing.sm),
                  Text(fire.description,
                      style: GoogleFonts.inter(fontSize: 15, height: 1.45, color: secondaryTextColor)),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 18, color: tertiaryTextColor),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        l10n.fireDetailLastUpdate(_formatUpdatedAt(context, fire.updatedAt)),
                        style: GoogleFonts.inter(fontSize: 14, color: tertiaryTextColor),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.08, end: 0),

            const SizedBox(height: AppSpacing.xxl),

            SectionHeader(title: l10n.fireDetailKeyMetrics, icon: Icons.analytics_rounded),
            const SizedBox(height: AppSpacing.md),

            Row(
              children: [
                Expanded(child: _MetricCard(
                  title: l10n.commonRisk,
                  value: fire.riskLevel,
                  info: InfoIconButton(
                    title: l10n.tooltipConfidenceTitle,
                    bodyLines: [l10n.smartConfidenceHigh, l10n.smartConfidenceMedium, l10n.smartConfidenceLow],
                  ),
                )),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _MetricCard(title: l10n.commonStatus, value: fire.status)),
              ],
            ),

            const SizedBox(height: AppSpacing.xxl),

            SectionHeader(title: l10n.fireDetailEventInfo, icon: Icons.info_outline_rounded),
            const SizedBox(height: AppSpacing.md),

            _InfoRow(label: l10n.fireDetailCity, value: fire.city),
            const SizedBox(height: AppSpacing.sm),
            _InfoRow(label: l10n.fireDetailDistrict, value: fire.district),
            const SizedBox(height: AppSpacing.sm),
            _InfoRow(label: l10n.fireDetailStarted, value: fire.startedAt),
            const SizedBox(height: AppSpacing.sm),
            FutureBuilder<WindReading?>(
              future: _windFuture,
              builder: (context, snapshot) {
                final String value;
                if (snapshot.connectionState != ConnectionState.done) {
                  value = l10n.fireDetailWindLoading;
                } else if (snapshot.data == null) {
                  value = l10n.fireDetailWindUnavailable;
                } else {
                  final wind = snapshot.data!;
                  value = l10n.fireDetailWindValue(
                    wind.speedKmh.round().toString(),
                    windDirectionLabel(l10n, wind.directionDeg),
                  );
                }
                return _InfoRow(label: l10n.commonWind, value: value);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            _InfoRow(label: l10n.fireDetailSpreadRisk, value: fire.spreadRisk),
            const SizedBox(height: AppSpacing.sm),
            _InfoRow(label: l10n.fireDetailAffectedArea, value: fire.affectedArea),
            const SizedBox(height: AppSpacing.sm),
            _InfoRow(label: l10n.fireDetailFireRadiativePower, value: _frpDisplayValue(l10n, fire.frp)),

            const SizedBox(height: AppSpacing.xxl),

            SectionHeader(title: l10n.fireDetailRecommendedActions, icon: Icons.checklist_rounded),
            const SizedBox(height: AppSpacing.md),

            ...fire.recommendedActions.map((action) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _ActionCard(text: action),
                )),

            const SizedBox(height: AppSpacing.xxl),

            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _openInAppMap,
                    icon: const Icon(Icons.map),
                    label: Text(l10n.commonOpenOnMap),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _shareFireEvent,
                    icon: const Icon(Icons.share),
                    label: Text(l10n.commonShare),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xxl),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  ref.read(watchlistProvider.notifier).toggle(fire.id);
                  final nowSaved = !isSaved;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        nowSaved
                            ? l10n.fireDetailAddedToWatchlist
                            : l10n.fireDetailRemovedFromWatchlist,
                        style: GoogleFonts.inter(),
                      ),
                    ),
                  );
                },
                icon: Icon(isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded),
                label: Text(isSaved ? l10n.fireDetailSaved : l10n.fireDetailSaveToWatchlist),
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            SectionHeader(title: l10n.fireDetailRelatedNews, icon: Icons.article),
            const SizedBox(height: AppSpacing.md),

            FutureBuilder<List<NewsItem>>(
              future: _newsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final allNews = snapshot.data ?? [];
                if (allNews.isEmpty) {
                  return GlassPanel(
                    child: Text(l10n.fireDetailNoNewsFound,
                        style: GoogleFonts.inter(color: secondaryTextColor)),
                  );
                }
                final (news, tier) = _selectRelatedNews(allNews, fire);
                if (news.isEmpty) {
                  return GlassPanel(
                    child: Text(l10n.fireDetailNoNewsFound,
                        style: GoogleFonts.inter(color: secondaryTextColor)),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (tier != _RelatedNewsTier.generic) ...[
                      Text(
                        tier == _RelatedNewsTier.city
                            ? l10n.fireDetailRelatedToCity(fire.city)
                            : l10n.fireDetailRegionalNews,
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    ...news.map((item) {
                    final isTranslating = _translatingIds.contains(item.id);
                    final displayTitle = _translatedTitles[item.id] ?? item.title;
                    final displaySummary = _translatedSummaries[item.id] ?? item.summary;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: InkWell(
                        onTap: () => _openNewsUrl(item.sourceUrl),
                        borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius),
                        child: GlassPanel(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isTranslating)
                                ShimmerWrap(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SkeletonBox(width: double.infinity, height: 16),
                                      const SizedBox(height: 8),
                                      const SkeletonBox(width: double.infinity, height: 12),
                                      const SizedBox(height: 6),
                                      SkeletonBox(width: MediaQuery.of(context).size.width * 0.4, height: 12),
                                    ],
                                  ),
                                )
                              else ...[
                                Text(displayTitle,
                                    style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: titleColor)),
                                const SizedBox(height: 6),
                                Text(displaySummary,
                                    style: GoogleFonts.inter(fontSize: 13, color: secondaryTextColor)),
                              ],
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(item.source,
                                        style: GoogleFonts.inter(fontSize: 11, color: AppColors.primary)),
                                  ),
                                  Icon(Icons.open_in_new_rounded, size: 16, color: tertiaryTextColor),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  ],
                );
              },
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final Widget? info;

  const _MetricCard({required this.title, required this.value, this.info});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final valueColor = theme.textTheme.titleLarge?.color ??
        (isDark ? AppColors.white : const Color(0xFF0F172A));
    final labelColor = isDark
        ? AppColors.white.withValues(alpha: 0.7)
        : Colors.black.withValues(alpha: 0.58);

    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: valueColor)),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(title, style: GoogleFonts.inter(fontSize: 13, color: labelColor)),
              ?info,
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final labelColor = isDark
        ? AppColors.white.withValues(alpha: 0.72)
        : Colors.black.withValues(alpha: 0.58);
    final valueColor = theme.textTheme.bodyLarge?.color ??
        (isDark ? AppColors.white : const Color(0xFF0F172A));

    return GlassPanel(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 15, color: labelColor)),
          const SizedBox(width: AppSpacing.md),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: valueColor)),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String text;

  const _ActionCard({required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? AppColors.white.withValues(alpha: 0.8)
        : Colors.black.withValues(alpha: 0.68);

    return GlassPanel(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline_rounded, color: AppColors.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(text, style: GoogleFonts.inter(fontSize: 14, height: 1.45, color: textColor)),
          ),
        ],
      ),
    );
  }
}