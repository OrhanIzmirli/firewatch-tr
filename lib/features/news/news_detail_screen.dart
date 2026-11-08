import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/utils/news_content_analysis.dart';
import '../../l10n/app_localizations.dart';
import '../../models/news_item.dart';
import 'widgets/news_visual.dart';

/// Only the headline, the source and a way there: the article stays with
/// its publisher.
class NewsDetailScreen extends StatelessWidget {
  final NewsItem newsItem;

  const NewsDetailScreen({super.key, required this.newsItem});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final muted = Theme.of(context).textTheme.bodySmall?.color;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.newsTitle, style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700))),
      body: ListView(padding: const EdgeInsets.all(AppSpacing.lg), children: [
        ClipRRect(borderRadius: BorderRadius.circular(16), child: SizedBox(height: 186, child: NewsImage(title: newsItem.title, thumbPath: newsItem.thumbPath, full: true))),
        const SizedBox(height: AppSpacing.md),
        Row(children: [
          NewsSourceMark(source: newsItem.source, logoUrl: newsItem.sourceLogoUrl, size: 22),
          const SizedBox(width: 7),
          Expanded(child: Text(newsItem.source, style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600, color: muted))),
          Text(formatNewsTimeAgo(l10n, newsItem.publishedAt), style: GoogleFonts.ibmPlexSans(fontSize: 12.5, color: muted)),
        ]),
        const SizedBox(height: AppSpacing.sm),
        NewsTitle(id: newsItem.id, title: newsItem.title, maxLines: 6, style: GoogleFonts.ibmPlexSans(fontSize: 22, fontWeight: FontWeight.w800, height: 1.2)),
        const SizedBox(height: AppSpacing.lg),
        FilledButton.icon(
          key: const Key('newsReadAtSource'),
          onPressed: () => openNewsSource(newsItem.sourceUrl),
          icon: const Icon(Icons.open_in_new_rounded),
          label: Text(l10n.newsReadAtSource),
        ),
      ]),
    );
  }
}
