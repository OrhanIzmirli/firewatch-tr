import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../l10n/app_localizations.dart';
import '../../services/news_service.dart';

/// "İlgili haberler": forest-fire stories about this province in this period,
/// chosen on the server by the same rule as "Haberlerde doğrulandı". With
/// nothing to show the section is not there at all.
class RelatedNewsSection extends StatefulWidget {
  final String? city;
  final DateTime from;
  final DateTime to;
  final Future<List<RelatedNews>> Function({String? city, required DateTime from, required DateTime to})? fetch;

  const RelatedNewsSection({super.key, required this.city, required this.from, required this.to, this.fetch});

  @override
  State<RelatedNewsSection> createState() => _RelatedNewsSectionState();
}

class _RelatedNewsSectionState extends State<RelatedNewsSection> {
  late Future<List<RelatedNews>> _news = _load();

  Future<List<RelatedNews>> _load() async {
    try {
      final fetch = widget.fetch ?? NewsService().fetchRelated;
      return await fetch(city: widget.city, from: widget.from, to: widget.to);
    } catch (_) {
      return const [];
    }
  }

  @override
  void didUpdateWidget(RelatedNewsSection old) {
    super.didUpdateWidget(old);
    if (old.city != widget.city) _news = _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final muted = Theme.of(context).textTheme.bodySmall?.color;
    return FutureBuilder<List<RelatedNews>>(
      future: _news,
      builder: (context, snapshot) {
        final items = snapshot.data ?? const <RelatedNews>[];
        if (items.isEmpty) return const SizedBox.shrink();
        String two(int n) => n.toString().padLeft(2, '0');
        return Padding(
          key: const Key('relatedNews'),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.relatedNewsTitle, style: GoogleFonts.ibmPlexSans(fontSize: 15, fontWeight: FontWeight.w800)),
              const SizedBox(height: AppSpacing.sm),
              for (final n in items)
                InkWell(
                  onTap: n.url == null ? null : () => launchUrl(Uri.parse(n.url!), mode: LaunchMode.externalApplication),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(n.title, style: GoogleFonts.ibmPlexSans(fontSize: 13.5, height: 1.35, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 2),
                              Text(
                                '${n.source} · ${two(n.publishedAt.day)}.${two(n.publishedAt.month)} ${two(n.publishedAt.hour)}:${two(n.publishedAt.minute)}',
                                style: GoogleFonts.ibmPlexSans(fontSize: 12, color: muted),
                              ),
                            ],
                          ),
                        ),
                        if (n.url != null) const Icon(Icons.open_in_new_rounded, size: 16, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
