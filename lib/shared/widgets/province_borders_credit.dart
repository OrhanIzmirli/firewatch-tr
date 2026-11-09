import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';

/// OpenStreetMap's copyright page, which the ODbL attribution must point to.
const osmCopyrightUrl = 'https://www.openstreetmap.org/copyright';

/// The licence itself (ODbL 1.0).
const odblLicenseUrl = 'https://opendatacommons.org/licenses/odbl/1-0/';

/// What the "Past years" layer is made of, and the ODbL attribution its
/// province boundaries require: "© OpenStreetMap contributors, ODbL" with a
/// link to the copyright page and to the licence.
///
/// The province totals come from a separate data set whose own statement
/// says its satellite counts were made with GADM 4.1 boundaries; the
/// boundaries drawn are geoBoundaries / OSM. Both are said plainly, so the
/// legend no longer reads as if the drawn borders were GADM.
class ProvinceBordersCredit extends StatelessWidget {
  final Color color;
  final double fontSize;

  const ProvinceBordersCredit({super.key, required this.color, this.fontSize = 10});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final style = TextStyle(fontSize: fontSize, height: 1.35, color: color);
    final link = style.copyWith(decoration: TextDecoration.underline, fontWeight: FontWeight.w600);
    Widget open(String label, String url) => InkWell(
          onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(label, style: link),
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.annualLayerProvenance, style: style),
        Wrap(
          spacing: 12,
          children: [
            open(l10n.osmAttribution, osmCopyrightUrl),
            open(l10n.odblLicenseLink, odblLicenseUrl),
          ],
        ),
      ],
    );
  }
}
