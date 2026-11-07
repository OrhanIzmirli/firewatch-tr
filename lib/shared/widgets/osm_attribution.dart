import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import 'province_borders_credit.dart' show osmCopyrightUrl;

/// "© OpenStreetMap katkıcıları" on a map that draws OSM tiles, as OSM's
/// tile usage policy and attribution guidelines require: visible on the map
/// itself and linking to openstreetmap.org/copyright. [extra] adds other
/// credits on the same line (CARTO, the FWI source).
class OsmAttribution extends StatelessWidget {
  const OsmAttribution({
    super.key,
    this.color = Colors.white,
    this.fontSize = 10,
    this.halo = true,
    this.extra = const [],
  });

  final Color color;
  final double fontSize;

  /// A dark shadow so the text stays legible over any map colour.
  final bool halo;
  final List<String> extra;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      link: true,
      label: l10n.osmTileAttribution,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => launchUrl(
          Uri.parse(osmCopyrightUrl),
          mode: LaunchMode.externalApplication,
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Text(
            [l10n.osmTileAttribution, ...extra].join(' · '),
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: color,
              shadows: halo
                  ? const [
                      Shadow(color: Colors.black87, blurRadius: 3),
                      Shadow(color: Colors.black54, blurRadius: 1),
                    ]
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
