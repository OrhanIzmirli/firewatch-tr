import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/app_sheet.dart';
import '../../shared/widgets/glass_panel.dart';
import 'nature_facts.dart';
import 'nature_progress.dart';
import 'tree.dart';

/// A fact that belongs to one place in the app for the day.
mixin FactSlot<T extends StatefulWidget> on State<T> {
  NatureFact? fact;
  String get slot;

  void loadFact() {
    NatureFacts.instance.forSlot(slot, DateTime.now()).then((f) {
      if (mounted) setState(() => fact = f);
    }).catchError((Object _) {});
  }

  void anotherFact() {
    NatureFacts.instance.another(slot, DateTime.now()).then((f) {
      if (mounted) setState(() => fact = f);
    }).catchError((Object _) {});
  }
}

Future<void> openFactSource(NatureFact f) => launchUrl(Uri.parse(f.sourceUrl), mode: LaunchMode.externalApplication);

void shareFact(BuildContext context, NatureFact fact) =>
    showAppSheet<void>(context, builder: (_) => _FactShareSheet(fact: fact));

class _FactShareSheet extends StatefulWidget {
  final NatureFact fact;
  const _FactShareSheet({required this.fact});

  @override
  State<_FactShareSheet> createState() => _FactShareSheetState();
}

class _FactShareSheetState extends State<_FactShareSheet> {
  final _key = GlobalKey();

  Future<void> _share(String text) async {
    final boundary = _key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('${(await getTemporaryDirectory()).path}/bilgi.png');
    await file.writeAsBytes(bytes!.buffer.asUint8List());
    await Share.shareXFiles([XFile(file.path, mimeType: 'image/png')], text: text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final f = widget.fact;
    const ink = Color(0xFF24401A);
    final now = DateTime.now();
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        RepaintBoundary(
          key: _key,
          child: Container(
            key: const Key('factShareCard'),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFD8F1FF), Color(0xFFEAF8DA)]),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(children: [
              TreeView(stage: 3, season: seasonOf(now), mood: Mood.happy, apples: 3, size: 150),
              const SizedBox(height: 6),
              Text(l10n.fidanDidYouKnow, style: GoogleFonts.ibmPlexSans(fontSize: 18, fontWeight: FontWeight.w900, color: ink)),
              const SizedBox(height: 8),
              Text(f.of(lang), textAlign: TextAlign.center, style: GoogleFonts.ibmPlexSans(fontSize: 18, height: 1.3, fontWeight: FontWeight.w600, color: ink)),
              const SizedBox(height: 10),
              Text('${l10n.natureSource(f.sourceName)} · FireWatch TR', textAlign: TextAlign.center, style: GoogleFonts.ibmPlexSans(fontSize: 12, color: ink.withValues(alpha: 0.75))),
            ]),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        FilledButton.icon(
          key: const Key('factShareSend'),
          onPressed: () => _share('${f.of(lang)}\n${l10n.natureSource(f.sourceName)}: ${f.sourceUrl}'),
          icon: const Icon(Icons.ios_share_rounded),
          label: Text(l10n.natureShare),
        ),
      ]),
    );
  }
}

/// The home screen card: one fact a day, another on request.
class HomeFactCard extends StatefulWidget {
  const HomeFactCard({super.key});

  @override
  State<HomeFactCard> createState() => _HomeFactCardState();
}

class _HomeFactCardState extends State<HomeFactCard> with FactSlot {
  @override
  String get slot => 'home';

  @override
  void initState() {
    super.initState();
    loadFact();
  }

  @override
  Widget build(BuildContext context) {
    final f = fact;
    if (f == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final muted = Theme.of(context).textTheme.bodySmall?.color;
    return InkWell(
      key: const Key('homeFactCard'),
      borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius),
      onTap: () => openFactSource(f),
      child: GlassPanel(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.sm, AppSpacing.xs),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l10n.fidanDidYouKnow, style: GoogleFonts.ibmPlexSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.success)),
          const SizedBox(height: 6),
          Padding(padding: const EdgeInsets.only(right: AppSpacing.sm), child: Text(f.of(lang), style: GoogleFonts.ibmPlexSans(fontSize: 15.5, height: 1.35, fontWeight: FontWeight.w600))),
          const SizedBox(height: 4),
          Text(l10n.natureSource(f.sourceName), style: GoogleFonts.ibmPlexSans(fontSize: 12, color: muted, decoration: TextDecoration.underline, decorationColor: muted)),
          Row(children: [
            TextButton(key: const Key('homeFactAnother'), onPressed: anotherFact, child: Text(l10n.factAnother)),
            const Spacer(),
            IconButton(key: const Key('homeFactShare'), tooltip: l10n.natureShare, onPressed: () => shareFact(context, f), icon: const Icon(Icons.ios_share_rounded, size: 20)),
          ]),
        ]),
      ),
    );
  }
}

/// Between news rows. A tinted strip, so it cannot be taken for a story.
class InlineFactCard extends StatefulWidget {
  final int index;
  const InlineFactCard({super.key, required this.index});

  @override
  State<InlineFactCard> createState() => _InlineFactCardState();
}

class _InlineFactCardState extends State<InlineFactCard> with FactSlot {
  @override
  String get slot => 'news-${widget.index}';

  @override
  void initState() {
    super.initState();
    loadFact();
  }

  @override
  Widget build(BuildContext context) {
    final f = fact;
    if (f == null) return const SizedBox.shrink();
    final lang = Localizations.localeOf(context).languageCode;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Material(
        color: AppColors.success.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          key: Key('newsFact-${widget.index}'),
          borderRadius: BorderRadius.circular(14),
          onTap: () => openFactSource(f),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('💡', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 9),
              Expanded(child: Text(f.of(lang), style: GoogleFonts.ibmPlexSans(fontSize: 14, height: 1.35, fontWeight: FontWeight.w500))),
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: AppLocalizations.of(context)!.natureShare,
                onPressed: () => shareFact(context, f),
                icon: const Icon(Icons.ios_share_rounded, size: 18),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

/// One line for the splash and empty states.
class FactLine extends StatefulWidget {
  final String place;
  final Color? color;
  final TextAlign align;
  const FactLine({super.key, required this.place, this.color, this.align = TextAlign.start});

  @override
  State<FactLine> createState() => _FactLineState();
}

class _FactLineState extends State<FactLine> with FactSlot {
  @override
  String get slot => widget.place;

  @override
  void initState() {
    super.initState();
    loadFact();
  }

  @override
  Widget build(BuildContext context) {
    final f = fact;
    if (f == null) return const SizedBox.shrink();
    final lang = Localizations.localeOf(context).languageCode;
    return Text('💡 ${f.of(lang)}', key: Key('factLine-${widget.place}'), textAlign: widget.align, style: GoogleFonts.ibmPlexSans(fontSize: 14, height: 1.35, color: widget.color));
  }
}
