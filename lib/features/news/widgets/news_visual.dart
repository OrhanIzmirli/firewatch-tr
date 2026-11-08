import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/api_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/news_content_analysis.dart';
import '../../../core/utils/turkish_text.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/news_item.dart';
import '../../../services/news_translation_service.dart';

/// News shows only a headline, its source and a link; tapping goes there.
Future<void> openNewsSource(String url) async {
  final uri = Uri.tryParse(url);
  if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
}

enum NewsArt { fire, recovery, solidarity, event }

/// Which of our own drawings fits a headline that has no province.
NewsArt newsArtFor(String title) {
  final t = foldTurkish(title);
  if (RegExp('agaclandir|fidan|yeniden yeser|restorasyon|yaban hayat').hasMatch(t)) return NewsArt.recovery;
  if (RegExp('destek|yardim|gonullu|dayanisma|bagis').hasMatch(t)) return NewsArt.solidarity;
  if (RegExp('etkinlik|toren|egitim|tatbikat|senlik').hasMatch(t)) return NewsArt.event;
  return NewsArt.fire;
}

/// The outline of Türkiye on the app's dark surface, tinted by subject.
class NewsArtView extends StatelessWidget {
  final NewsArt art;
  const NewsArtView(this.art, {super.key});

  static Future<List<List<Offset>>>? _outline;

  static Future<List<List<Offset>>> _load() => _outline ??= rootBundle.loadString('assets/data/turkey_outline.json').then((raw) => [
        for (final ring in (jsonDecode(raw) as Map<String, dynamic>)['rings'] as List)
          [for (final p in ring as List) Offset((p[0] as num).toDouble(), (p[1] as num).toDouble())],
      ]);

  Color get _tint => switch (art) {
        NewsArt.fire => AppColors.primary,
        NewsArt.recovery => AppColors.success,
        NewsArt.solidarity => AppColors.info,
        NewsArt.event => AppColors.warning,
      };

  @override
  Widget build(BuildContext context) => FutureBuilder<List<List<Offset>>>(
        future: _load(),
        builder: (context, snap) => DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Theme.of(context).colorScheme.surfaceContainerHighest, Theme.of(context).colorScheme.surface],
            ),
          ),
          child: SizedBox.expand(child: CustomPaint(painter: _OutlinePainter(snap.data ?? const [], _tint))),
        ),
      );
}

class _OutlinePainter extends CustomPainter {
  final List<List<Offset>> rings;
  final Color tint;
  _OutlinePainter(this.rings, this.tint);

  static const _west = 25.6, _east = 44.9, _south = 35.8, _north = 42.2;

  @override
  void paint(Canvas c, Size s) {
    if (rings.isEmpty) return;
    const aspect = (_east - _west) * 0.78 / (_north - _south);
    var w = s.width * 0.8;
    var h = w / aspect;
    if (h > s.height * 0.7) {
      h = s.height * 0.7;
      w = h * aspect;
    }
    final left = (s.width - w) / 2, top = (s.height - h) / 2;
    Offset at(Offset p) => Offset(left + (p.dx - _west) / (_east - _west) * w, top + (_north - p.dy) / (_north - _south) * h);
    final path = Path();
    for (final r in rings) {
      path.addPolygon([for (final p in r) at(p)], true);
    }
    c.drawPath(path, Paint()..color = tint.withValues(alpha: 0.16));
    c.drawPath(path, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeJoin = StrokeJoin.round
      ..color = tint.withValues(alpha: 0.7));
  }

  @override
  bool shouldRepaint(_OutlinePainter o) => o.rings != rings || o.tint != tint;
}

/// NASA picture of the province, served by our backend, or one of our own
/// drawings when there is no province or no usable picture. Never a
/// publisher's photo.
class NewsImage extends StatelessWidget {
  final String title;
  final String thumbPath;

  /// The credit needs room; a small square only says NASA.
  final bool full;
  const NewsImage({super.key, required this.title, required this.thumbPath, this.full = false});

  @override
  Widget build(BuildContext context) {
    final fallback = NewsArtView(newsArtFor(title));
    if (thumbPath.isEmpty) return fallback;
    final l10n = AppLocalizations.of(context)!;
    final date = DateTime.tryParse(thumbPath.split('/').last);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final credit = full && date != null ? l10n.newsImageCredit(DateFormat('d MMM y', locale).format(date)) : 'NASA';
    return Image.network(
      '${ApiConfig.backendBaseUrl}$thumbPath',
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, _, _) => fallback,
      frameBuilder: (_, child, frame, wasSync) => frame == null && !wasSync
          ? fallback
          : Stack(fit: StackFit.expand, children: [
              child,
              Positioned(
                left: 6,
                bottom: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(color: AppColors.scrimMedium, borderRadius: BorderRadius.circular(4)),
                  child: Text(credit, style: GoogleFonts.ibmPlexSans(fontSize: 10.5, color: Colors.white)),
                ),
              ),
            ]),
    );
  }
}

class NewsSourceMark extends StatelessWidget {
  final String source;
  final String logoUrl;
  final double size;
  const NewsSourceMark({super.key, required this.source, required this.logoUrl, this.size = 20});

  @override
  Widget build(BuildContext context) {
    final letter = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Text(source.isEmpty ? '?' : source.characters.first.toUpperCase(), style: GoogleFonts.ibmPlexSans(fontSize: size * 0.6, fontWeight: FontWeight.w800)),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: logoUrl.isEmpty ? letter : Image.network(logoUrl, width: size, height: size, fit: BoxFit.contain, errorBuilder: (_, _, _) => letter),
    );
  }
}

/// A headline, translated when the app is in English.
class NewsTitle extends StatefulWidget {
  final String id;
  final String title;
  final TextStyle style;
  final int maxLines;
  const NewsTitle({super.key, required this.id, required this.title, required this.style, this.maxLines = 3});

  @override
  State<NewsTitle> createState() => _NewsTitleState();
}

class _NewsTitleState extends State<NewsTitle> {
  String? _translated;
  bool _asked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_asked || Localizations.localeOf(context).languageCode != 'en') return;
    _asked = true;
    NewsTranslationService.instance.translate(articleId: widget.id, field: 'title', text: widget.title).then((t) {
      if (mounted) setState(() => _translated = t);
    }).catchError((Object _) {});
  }

  @override
  Widget build(BuildContext context) => Text(_translated ?? widget.title, maxLines: widget.maxLines, overflow: TextOverflow.ellipsis, style: widget.style);
}

/// One row of the list: logo and name on top, headline, age, square picture.
class NewsListRow extends StatelessWidget {
  final NewsItem item;
  const NewsListRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final muted = Theme.of(context).textTheme.bodySmall?.color;
    return InkWell(
      onTap: () => openNewsSource(item.sourceUrl),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                NewsSourceMark(source: item.source, logoUrl: item.sourceLogoUrl),
                const SizedBox(width: 7),
                Flexible(child: Text(item.source, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.ibmPlexSans(fontSize: 13, fontWeight: FontWeight.w600, color: muted))),
              ]),
              const SizedBox(height: 5),
              NewsTitle(id: item.id, title: item.title, style: GoogleFonts.ibmPlexSans(fontSize: 16, fontWeight: FontWeight.w600, height: 1.25)),
              const SizedBox(height: 5),
              Row(children: [
                Text(formatNewsTimeAgo(l10n, item.publishedAt), style: GoogleFonts.ibmPlexSans(fontSize: 12.5, color: muted)),
                const SizedBox(width: 5),
                Tooltip(message: l10n.newsReadAtSource, child: Icon(Icons.open_in_new_rounded, size: 13, color: muted)),
              ]),
            ]),
          ),
          const SizedBox(width: 12),
          ClipRRect(borderRadius: BorderRadius.circular(10), child: SizedBox.square(dimension: 86, child: NewsImage(title: item.title, thumbPath: item.thumbPath))),
        ]),
      ),
    );
  }
}
