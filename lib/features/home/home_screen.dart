import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../models/fire_point.dart';
import '../../models/news_item.dart';
import '../../services/fire_api_service.dart';
import '../../services/fire_mapper.dart';
import '../../services/news_service.dart';
import '../../services/watchlist_provider.dart';
import '../../shared/widgets/glass_panel.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/status_chip.dart';
import '../../shared/widgets/summary_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final NewsService _newsService = NewsService();
  final FireApiService _fireApiService = FireApiService();

  List<NewsItem> _topNews = [];
  List<FirePoint> _firePoints = [];
  bool _newsLoading = true;
  bool _fireLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _loadNews();
    _loadFires();
  }

  Future<void> _loadNews() async {
    try {
      final news = await _newsService.fetchNewsFromRender(limit: 3);
      if (mounted) setState(() { _topNews = news; _newsLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _newsLoading = false);
    }
  }

  Future<void> _loadFires() async {
    try {
      final fires = await _fireApiService.fetchTurkeyFires();
      final enriched = <FirePoint>[];
      for (final point in fires.take(10)) {
        final cityInfo = await _fireApiService.getNearestCity(point.latitude, point.longitude);
        enriched.add(point.copyWith(cityName: cityInfo['city'], nearestRegion: cityInfo['region']));
      }
      if (mounted) setState(() {
        _firePoints = [...enriched, ...fires.skip(10)];
        _fireLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _fireLoading = false);
    }
  }

  void _showFirePreview(BuildContext context, FirePoint point) {
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
    if (bright >= 370) alanTahmini = '100 hektardan fazla';
    else if (bright >= 330) alanTahmini = '10–100 hektar';
    else if (bright >= 300) alanTahmini = '10 hektardan az';
    else alanTahmini = 'Uydu çözünürlüğü yetersiz';

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
                  StatusChip(label: point.riskLevel, icon: Icons.local_fire_department_rounded),
                  const SizedBox(width: 8),
                  StatusChip(label: '${point.formattedDate} ${point.formattedTime}', icon: Icons.access_time_rounded),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                '${point.regionName} Bölgesi',
                style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: titleColor),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                point.riskReason,
                style: GoogleFonts.inter(fontSize: 14, height: 1.45, color: secondaryTextColor),
              ),
              const SizedBox(height: AppSpacing.lg),
              _PreviewRow(icon: Icons.thermostat_rounded, label: 'Sıcaklık', value: '$tempC°C'),
              const SizedBox(height: 8),
              _PreviewRow(icon: Icons.area_chart_rounded, label: 'Tahmini Alan', value: alanTahmini),
              const SizedBox(height: 8),
              _PreviewRow(icon: Icons.satellite_alt_rounded, label: 'Uydu', value: point.satellite),
              const SizedBox(height: 8),
              _PreviewRow(icon: Icons.location_on_rounded, label: 'Koordinat', value: point.locationLabel),
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
                      label: const Text('Haritada Gör'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        context.push('/fire-detail', extra: convertPointToFireEvent(point));
                      },
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('Detay'),
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
        title: Text('FireWatch TR', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _loadData),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────
            GlassPanel(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const StatusChip(label: 'Canlı Durum Özeti', icon: Icons.bolt_rounded),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Türkiye Yangın Takibi',
                      style: GoogleFonts.inter(fontSize: 30, fontWeight: FontWeight.w800, color: primaryTextColor)),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Aktif olayları takip et, risk seviyelerini gör ve güvenlik rehberine hızlıca ulaş.',
                      style: GoogleFonts.inter(fontSize: 16, height: 1.45, color: secondaryTextColor)),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 18, color: tertiaryTextColor),
                      const SizedBox(width: AppSpacing.sm),
                      Text('NASA FIRMS • Canlı Veri',
                          style: GoogleFonts.inter(fontSize: 14, color: tertiaryTextColor)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => context.push('/risk'),
                          icon: const Icon(Icons.auto_graph_rounded),
                          label: const Text('Risk Analizi'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.push('/watchlist'),
                          icon: const Icon(Icons.bookmark_rounded),
                          label: Text('Kaydedilenler (${savedIds.length})'),
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
                          label: const Text('Güvenlik'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.push('/emergency'),
                          icon: const Icon(Icons.emergency_rounded),
                          label: const Text('Acil Durum'),
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

            const SizedBox(height: AppSpacing.xxl),

            // ── Genel Bakış ──────────────────────────────────
            const SectionHeader(
              title: 'Genel Bakış',
              subtitle: 'NASA FIRMS anlık verisi',
              icon: Icons.dashboard_customize_rounded,
            ),
            const SizedBox(height: AppSpacing.md),

            if (_fireLoading)
              const Center(child: CircularProgressIndicator(color: AppColors.primary))
            else
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.1,
                children: [
                  SummaryCard(title: 'Toplam Nokta', value: _firePoints.length.toString(), icon: Icons.local_fire_department),
                  SummaryCard(title: 'Yüksek Risk', value: highConfFires.toString(), icon: Icons.warning_amber_rounded),
                  SummaryCard(title: 'Normal', value: nominalFires.toString(), icon: Icons.verified_outlined),
                ],
              ),

            const SizedBox(height: AppSpacing.xxxl),

            // ── Son Haberler ─────────────────────────────────
            SectionHeader(
              title: 'Son Haberler',
              subtitle: 'Öne çıkan gelişmeler',
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
                    Text('${_topNews.where((e) => e.isBreaking).length} sıcak',
                        style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            if (_newsLoading)
              const Center(child: CircularProgressIndicator(color: AppColors.primary))
            else if (_topNews.isEmpty)
              GlassPanel(
                child: Text('Haber yükleniyor...',
                    style: GoogleFonts.inter(fontSize: 14, color: secondaryTextColor)),
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
              title: 'Aktif Termal Noktalar',
              subtitle: 'NASA FIRMS • PostGIS şehir tespiti',
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
                      Text('Harita', style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w800)),
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
                  _FilterChip(label: 'Tümü', selected: query.isEmpty, onTap: () { _searchController.clear(); setState(() {}); }),
                  const SizedBox(width: 8),
                  _FilterChip(label: 'Yüksek Risk', selected: query == 'yüksek', onTap: () { _searchController.text = 'yüksek'; setState(() {}); }),
                  const SizedBox(width: 8),
                  _FilterChip(label: 'Orta Risk', selected: query == 'orta', onTap: () { _searchController.text = 'orta'; setState(() {}); }),
                  const SizedBox(width: 8),
                  _FilterChip(label: 'Ege', selected: query == 'ege', onTap: () { _searchController.text = 'ege'; setState(() {}); }),
                  const SizedBox(width: 8),
                  _FilterChip(label: 'Akdeniz', selected: query == 'akdeniz', onTap: () { _searchController.text = 'akdeniz'; setState(() {}); }),
                  const SizedBox(width: 8),
                  _FilterChip(label: 'Marmara', selected: query == 'marmara', onTap: () { _searchController.text = 'marmara'; setState(() {}); }),
                  const SizedBox(width: 8),
                  _FilterChip(label: 'Karadeniz', selected: query == 'karadeniz', onTap: () { _searchController.text = 'karadeniz'; setState(() {}); }),
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
                  hintText: 'Şehir veya bölge ara...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: query.isNotEmpty
                      ? IconButton(onPressed: () { _searchController.clear(); setState(() {}); }, icon: const Icon(Icons.close_rounded))
                      : null,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            if (_fireLoading)
              const Center(child: CircularProgressIndicator(color: AppColors.primary))
            else if (_firePoints.isEmpty)
              GlassPanel(
                child: Center(child: Text('Aktif yangın noktası bulunamadı.', style: GoogleFonts.inter(fontSize: 14))),
              )
            else
              ..._firePoints
                  .where((p) => query.isEmpty ||
                      p.regionName.toLowerCase().contains(query) ||
                      (p.cityName?.toLowerCase().contains(query) ?? false) ||
                      (p.nearestRegion?.toLowerCase().contains(query) ?? false) ||
                      p.riskLevel.toLowerCase().contains(query) ||
                      p.acquisitionDate.contains(query))
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
                                  point.regionName,
                                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: primaryTextColor),
                                ),
                              ),
                              StatusChip(label: point.riskLevel, icon: Icons.warning_amber_rounded),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            '${point.formattedDate} • ${point.formattedTime} UTC',
                            style: GoogleFonts.inter(fontSize: 12, color: tertiaryTextColor),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            point.riskReason,
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
                              Text('Detay', style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
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