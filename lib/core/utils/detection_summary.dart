import '../../l10n/app_localizations.dart';

/// The plain sentence on every detection card: what the satellites saw,
/// that it is not verified (or that the news confirms it), what else it
/// could be, and when it was last seen.
String detectionSummaryText(
  AppLocalizations l10n, {
  required String? city,
  required bool strong,
  required bool newsVerified,
  required String? landCover,
  required Duration age,
}) {
  final place = city != null && city.isNotEmpty ? city : null;
  final parts = <String>[
    switch ((strong, place)) {
      (true, final String c) => l10n.dsStrong(c),
      (true, null) => l10n.dsStrongNoCity,
      (false, final String c) => l10n.dsNormal(c),
      (false, null) => l10n.dsNormalNoCity,
    },
    newsVerified ? l10n.dsNewsVerified : l10n.dsNotVerified,
  ];
  if (!newsVerified) {
    if (landCover == 'agriculture') parts.add(l10n.dsFarmland);
    if (landCover == 'built') parts.add(l10n.dsBuilt);
  }
  parts.add(
    age.inDays >= 1
        ? l10n.dsSeenDays(age.inDays)
        : age.inHours >= 1
            ? l10n.dsSeenHours(age.inHours)
            : l10n.dsSeenJustNow,
  );
  return parts.join(' ');
}
