import 'package:flutter/material.dart';
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

enum NewsArt { fire, field, recovery, preparation, nature, solidarity, event }

/// Which picture fits a headline that has no province.
NewsArt newsArtFor(String title, [String? kind]) {
  switch (kind) {
    case 'field':
      return NewsArt.field;
    case 'recovery':
      return NewsArt.recovery;
    case 'preparation':
      return NewsArt.preparation;
    case 'nature':
      return NewsArt.nature;
  }
  final t = foldTurkish(title);
  if (RegExp('agaclandir|fidan|yeniden yeser|restorasyon').hasMatch(t)) return NewsArt.recovery;
  if (RegExp('yaban hayat').hasMatch(t)) return NewsArt.nature;
  if (RegExp('destek|yardim|gonullu|dayanisma|bagis').hasMatch(t)) return NewsArt.solidarity;
  if (RegExp('etkinli|toren|senlik').hasMatch(t)) return NewsArt.event;
  if (RegExp('tatbikat|egitim').hasMatch(t)) return NewsArt.preparation;
  return NewsArt.fire;
}

/// A calm tile for a headline with no place: its own colour and symbol per
/// subject, and a slightly different composition per headline.
class NewsArtView extends StatelessWidget {
  final NewsArt art;
  final String title;
  const NewsArtView(this.art, {super.key, this.title = ''});

  (Color, Color, IconData) get _look => switch (art) {
        NewsArt.fire => (const Color(0xFF8A4B21), const Color(0xFF3D2A1F), Icons.landscape_rounded),
        NewsArt.field => (const Color(0xFF9A7B2E), const Color(0xFF4A3D1C), Icons.agriculture_rounded),
        NewsArt.recovery => (const Color(0xFF3E8A4F), const Color(0xFF1F4530), Icons.park_rounded),
        NewsArt.preparation => (const Color(0xFF356E95), const Color(0xFF1D3B52), Icons.health_and_safety_rounded),
        NewsArt.nature => (const Color(0xFF4E8E7B), const Color(0xFF234A42), Icons.pets_rounded),
        NewsArt.solidarity => (const Color(0xFF8B5E8E), const Color(0xFF47304B), Icons.volunteer_activism_rounded),
        NewsArt.event => (const Color(0xFF7A6BA8), const Color(0xFF3B3360), Icons.event_rounded),
      };

  @override
  Widget build(BuildContext context) {
    final (light, dark, icon) = _look;
    final flip = title.hashCode.isEven;
    return LayoutBuilder(builder: (_, box) {
      final side = box.biggest.shortestSide;
      return ClipRect(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: flip ? Alignment.topLeft : Alignment.topRight, end: flip ? Alignment.bottomRight : Alignment.bottomLeft, colors: [light, dark]),
          ),
          child: Stack(fit: StackFit.expand, children: [
            Positioned(
              right: flip ? -side * 0.18 : null,
              left: flip ? null : -side * 0.18,
              bottom: -side * 0.2,
              child: Icon(icon, size: side * 1.05, color: Colors.white.withValues(alpha: 0.13)),
            ),
            Center(child: Icon(icon, size: side * 0.36, color: Colors.white.withValues(alpha: 0.92))),
          ]),
        ),
      );
    });
  }
}

/// NASA picture of the province, served by our backend, or one of our own
/// drawings when there is no province or no usable picture. Never a
/// publisher's photo.
class NewsImage extends StatelessWidget {
  final String title;
  final String thumbPath;
  final String kind;

  /// The credit needs room; a small square only says NASA.
  final bool full;
  const NewsImage({super.key, required this.title, required this.thumbPath, this.kind = '', this.full = false});

  @override
  Widget build(BuildContext context) {
    final fallback = NewsArtView(newsArtFor(title, kind), title: title);
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
          ClipRRect(borderRadius: BorderRadius.circular(10), child: SizedBox.square(dimension: 86, child: NewsImage(title: item.title, thumbPath: item.thumbPath, kind: item.kind))),
        ]),
      ),
    );
  }
}
