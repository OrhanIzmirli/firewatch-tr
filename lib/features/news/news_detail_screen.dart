import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../models/news_item.dart';
import '../../shared/widgets/glass_panel.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/status_chip.dart';

class NewsDetailScreen extends StatelessWidget {
  final NewsItem newsItem;

  const NewsDetailScreen({
    super.key,
    required this.newsItem,
  });

  IconData _iconForCategory() {
    switch (newsItem.category.toLowerCase()) {
      case 'risk':
        return Icons.auto_graph_rounded;
      case 'operasyon':
        return Icons.local_fire_department_rounded;
      case 'güvenlik':
        return Icons.shield_outlined;
      case 'güncelleme':
        return Icons.update_rounded;
      default:
        return Icons.article_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Haber Detayı',
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
                        label: newsItem.category,
                        icon: _iconForCategory(),
                      ),
                      if (newsItem.isBreaking)
                        const StatusChip(
                          label: 'Breaking',
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
                      _iconForCategory(),
                      color: AppColors.primary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    newsItem.title,
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    newsItem.summary,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      height: 1.5,
                      color: secondaryTextColor,
                    ),
                  ),
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
                        '${newsItem.readMinutes} dk okuma',
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

            const SizedBox(height: AppSpacing.xxl),

            const SectionHeader(
              title: 'Öne Çıkan Noktalar',
              subtitle: 'Hızlı özet',
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

            const SectionHeader(
              title: 'Detaylı İçerik',
              subtitle: 'Gelişmenin tam özeti',
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

            const SectionHeader(
              title: 'İlgili Bölge',
              subtitle: 'Bağlantılı risk alanı',
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
                          'Bu gelişme ilgili bölgesel risk ve operasyon akışına bağlı olabilir.',
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

            const SizedBox(height: AppSpacing.xxxl),

            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      context.push('/risk');
                    },
                    icon: const Icon(Icons.auto_graph_rounded),
                    label: const Text('Risk Analizi'),
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
                    label: const Text('Güvenlik'),
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