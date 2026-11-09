import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../services/news_service.dart';
import 'widgets/news_visual.dart';

/// All headlines about one fire. With at least two different stages it reads
/// as the fire's story; a stage nobody reported simply is not there.
class NewsStoryScreen extends StatelessWidget {
  final NewsStory story;
  const NewsStoryScreen({super.key, required this.story});

  Color _color(String stage) => switch (stage) {
        'started' => AppColors.danger,
        'controlled' => AppColors.warning,
        'out' => AppColors.success,
        _ => AppColors.info,
      };

  String _label(AppLocalizations l10n, String stage) => switch (stage) {
        'started' => l10n.newsStageStarted,
        'controlled' => l10n.newsStageControlled,
        'out' => l10n.newsStageOut,
        _ => l10n.newsStageRestoration,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final muted = Theme.of(context).textTheme.bodySmall?.color;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final date = DateFormat('d MMM', locale);
    String day(String iso) {
      final d = DateTime.tryParse(iso);
      return d == null ? '' : date.format(d.toLocal());
    }

    Widget row(NewsStoryItem i) => InkWell(
          onTap: () => openNewsSource(i.url),
          child: Padding(
            padding: const EdgeInsets.only(top: 9),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(padding: const EdgeInsets.only(top: 2), child: NewsSourceMark(source: i.source, logoUrl: i.logoUrl)),
              const SizedBox(width: 8),
              Expanded(child: NewsTitle(id: '${i.id}', title: i.title, style: GoogleFonts.ibmPlexSans(fontSize: 15, height: 1.25))),
            ]),
          ),
        );

    final timeline = story.isTimeline;
    final others = story.items.where((i) => i.stage == null || !timeline).toList();
    final first = story.items.first;
    final last = story.items.last;
    return Scaffold(
      appBar: AppBar(title: Text(timeline ? l10n.newsFireStory : l10n.newsSameFire(story.count), style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700))),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        ClipRRect(borderRadius: BorderRadius.circular(16), child: SizedBox(height: 150, child: NewsImage(title: first.title, thumbPath: story.thumbPath, full: true))),
        const SizedBox(height: 10),
        Text(story.province, style: GoogleFonts.ibmPlexSans(fontSize: 23, fontWeight: FontWeight.w800)),
        Text('${l10n.newsCount(story.count)} · ${day(first.publishedAt)} - ${day(last.publishedAt)}', style: GoogleFonts.ibmPlexSans(fontSize: 14.5, color: muted)),
        const SizedBox(height: 16),
        if (timeline)
          for (final (n, stage) in story.stages.indexed)
            IntrinsicHeight(
              key: Key('newsStage-$stage'),
              child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                SizedBox(
                  width: 26,
                  child: Column(children: [
                    Container(width: 18, height: 18, margin: const EdgeInsets.only(top: 3), decoration: BoxDecoration(color: _color(stage), shape: BoxShape.circle)),
                    if (n < story.stages.length - 1) Expanded(child: Container(width: 2.5, color: Theme.of(context).dividerColor)),
                  ]),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(_label(l10n, stage), style: GoogleFonts.ibmPlexSans(fontSize: 18.5, fontWeight: FontWeight.w800)),
                      Text(day(story.items.firstWhere((i) => i.stage == stage).publishedAt), style: GoogleFonts.ibmPlexSans(fontSize: 13.5, color: muted)),
                      for (final i in story.items.where((i) => i.stage == stage)) row(i),
                    ]),
                  ),
                ),
              ]),
            ),
        if (others.isNotEmpty && timeline) Text(l10n.newsStoryOther, style: GoogleFonts.ibmPlexSans(fontSize: 16, fontWeight: FontWeight.w800)),
        for (final i in others) row(i),
        const SizedBox(height: 16),
        if (timeline) Text(l10n.newsStoryNote, style: GoogleFonts.ibmPlexSans(fontSize: 13.5, height: 1.3, color: muted)),
      ]),
    );
  }
}
