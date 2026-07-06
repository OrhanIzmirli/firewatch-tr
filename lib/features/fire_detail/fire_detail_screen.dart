import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../models/fire_event.dart';
import '../../models/news_item.dart';
import '../../services/news_service.dart';
import '../../services/watchlist_provider.dart';
import '../../shared/widgets/glass_panel.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/status_chip.dart';

class FireDetailScreen extends ConsumerStatefulWidget {
  final FireEvent fireEvent;

  const FireDetailScreen({super.key, required this.fireEvent});

  @override
  ConsumerState<FireDetailScreen> createState() => _FireDetailScreenState();
}

class _FireDetailScreenState extends ConsumerState<FireDetailScreen> {
  final NewsService _newsService = NewsService();
  Future<List<NewsItem>>? _newsFuture;

  @override
  void initState() {
    super.initState();
    _newsFuture = _newsService.fetchNewsFromRender(limit: 3);
  }

  // "1041" → "10:41" → "X saat önce"
  String _formatUpdatedAt(String raw) {
    try {
      // Eğer sayısal ise saat formatına çevir
      if (RegExp(r'^\d{3,4}$').hasMatch(raw.trim())) {
        final padded = raw.trim().padLeft(4, '0');
        final hour = int.parse(padded.substring(0, 2));
        final minute = int.parse(padded.substring(2, 4));
        final now = DateTime.now();
        final dt = DateTime(now.year, now.month, now.day, hour, minute);
        final diff = now.difference(dt);
        if (diff.inMinutes < 1) return 'Az önce';
        if (diff.inMinutes < 60) return '${diff.inMinutes} dakika önce';
        if (diff.inHours < 24) return '${diff.inHours} saat önce';
        return '${diff.inDays} gün önce';
      }
      return raw;
    } catch (_) {
      return raw;
    }
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
    final fire = widget.fireEvent;
    final text = '''
🔥 Yangın Uyarısı

📍 ${fire.title}
📌 ${fire.city} / ${fire.district}

🚨 Durum: ${fire.status}
⚠️ Risk: ${fire.riskLevel}

📝 ${fire.description}

FireWatch TR ile takip ediliyor.
''';
    await Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text('Yangın Detayı',
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
                  StatusChip(label: fire.status, icon: Icons.local_fire_department_rounded),
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
                        'Son güncelleme: ${_formatUpdatedAt(fire.updatedAt)}',
                        style: GoogleFonts.inter(fontSize: 14, color: tertiaryTextColor),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.08, end: 0),

            const SizedBox(height: AppSpacing.xxl),

            const SectionHeader(title: 'Temel Metrikler', icon: Icons.analytics_rounded),
            const SizedBox(height: AppSpacing.md),

            Row(
              children: [
                Expanded(child: _MetricCard(title: 'Risk', value: fire.riskLevel)),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _MetricCard(title: 'Durum', value: fire.status)),
              ],
            ),

            const SizedBox(height: AppSpacing.xxl),

            const SectionHeader(title: 'Olay Bilgileri', icon: Icons.info_outline_rounded),
            const SizedBox(height: AppSpacing.md),

            _InfoRow(label: 'Şehir', value: fire.city),
            const SizedBox(height: AppSpacing.sm),
            _InfoRow(label: 'İlçe', value: fire.district),
            const SizedBox(height: AppSpacing.sm),
            _InfoRow(label: 'Başlangıç', value: fire.startedAt),
            const SizedBox(height: AppSpacing.sm),
            _InfoRow(label: 'Rüzgar', value: fire.windStatus),
            const SizedBox(height: AppSpacing.sm),
            _InfoRow(label: 'Yayılım Riski', value: fire.spreadRisk),
            const SizedBox(height: AppSpacing.sm),
            _InfoRow(label: 'Etkilenen Alan', value: fire.affectedArea),

            const SizedBox(height: AppSpacing.xxl),

            const SectionHeader(title: 'Önerilen Aksiyonlar', icon: Icons.checklist_rounded),
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
                    label: const Text('Haritada Aç'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _shareFireEvent,
                    icon: const Icon(Icons.share),
                    label: const Text('Paylaş'),
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
                            ? 'Olay watchlist listesine eklendi.'
                            : 'Olay watchlist listesinden kaldırıldı.',
                        style: GoogleFonts.inter(),
                      ),
                    ),
                  );
                },
                icon: Icon(isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded),
                label: Text(isSaved ? 'Kaydedildi' : 'Watchlist\'e Kaydet'),
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            const SectionHeader(title: 'İlgili Haberler', icon: Icons.article),
            const SizedBox(height: AppSpacing.md),

            FutureBuilder<List<NewsItem>>(
              future: _newsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final news = snapshot.data ?? [];
                if (news.isEmpty) {
                  return GlassPanel(
                    child: Text('Haber bulunamadı',
                        style: GoogleFonts.inter(color: secondaryTextColor)),
                  );
                }
                return Column(
                  children: news.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: InkWell(
                        onTap: () => _openNewsUrl(item.sourceUrl),
                        borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius),
                        child: GlassPanel(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.title,
                                  style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: titleColor)),
                              const SizedBox(height: 6),
                              Text(item.summary,
                                  style: GoogleFonts.inter(fontSize: 13, color: secondaryTextColor)),
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
                  }).toList(),
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

  const _MetricCard({required this.title, required this.value});

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
          Text(title, style: GoogleFonts.inter(fontSize: 13, color: labelColor)),
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