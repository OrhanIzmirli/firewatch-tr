import '../../l10n/app_localizations.dart';

/// Converts a wind direction in degrees (meteorological convention — the
/// direction the wind is blowing FROM) into a localized 8-point compass
/// label, e.g. 225° → "Güneybatı" / "Southwest".
String windDirectionLabel(AppLocalizations l10n, double degrees) {
  final normalized = degrees % 360;
  final labels = [
    l10n.windDirectionN,
    l10n.windDirectionNE,
    l10n.windDirectionE,
    l10n.windDirectionSE,
    l10n.windDirectionS,
    l10n.windDirectionSW,
    l10n.windDirectionW,
    l10n.windDirectionNW,
  ];
  final index = ((normalized / 45) + 0.5).floor() % 8;
  return labels[index];
}
