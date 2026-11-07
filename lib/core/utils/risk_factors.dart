import '../../l10n/app_localizations.dart';

/// Weather contributions to the regional risk score, mirrored step for step
/// from the backend's calculator (firewatch-tr-backend
/// src/jobs/riskCalculatorJob.ts, calculateRisk). The explanations under
/// each reading are generated from these, so the app says exactly what the
/// score did with the value — "%85 humidity" can never again be explained
/// as "low humidity dries out vegetation".
///
/// If the backend's steps change, change them here; test/risk_factors_test
/// pins every boundary.

/// (lower bound inclusive, points), highest first.
const List<(double, int)> temperatureSteps = [(40, 30), (35, 22), (30, 14), (25, 7)];

/// (upper bound inclusive, points), driest first.
const List<(double, int)> humiditySteps = [(20, 25), (30, 20), (40, 13), (50, 6)];

/// (lower bound inclusive, points), strongest first.
const List<(double, int)> windSteps = [(50, 25), (35, 18), (20, 11), (10, 5)];

const int temperatureMaxPoints = 30;
const int humidityMaxPoints = 25;
const int windMaxPoints = 25;

int temperaturePoints(num celsius) {
  for (final (from, points) in temperatureSteps) {
    if (celsius >= from) return points;
  }
  return 0;
}

int humidityPoints(num percent) {
  for (final (upTo, points) in humiditySteps) {
    if (percent <= upTo) return points;
  }
  return 0;
}

int windPoints(num kmh) {
  for (final (from, points) in windSteps) {
    if (kmh >= from) return points;
  }
  return 0;
}

/// What this temperature added to the score, in words.
String temperatureHint(AppLocalizations l10n, num celsius) {
  final points = temperaturePoints(celsius);
  return points == 0
      ? l10n.riskFactorTempHintNone
      : l10n.riskFactorTempHint(points, temperatureMaxPoints);
}

String humidityHint(AppLocalizations l10n, num percent) {
  final points = humidityPoints(percent);
  return points == 0
      ? l10n.riskFactorHumidityHintNone
      : l10n.riskFactorHumidityHint(points, humidityMaxPoints);
}

String windHint(AppLocalizations l10n, num kmh) {
  final points = windPoints(kmh);
  return points == 0
      ? l10n.riskFactorWindHintNone
      : l10n.riskFactorWindHint(points, windMaxPoints);
}

/// The one-line summary under a region ("Cool weather (8°C) • High
/// humidity (85%) • Strong wind (36 km/h)"), banded on the same steps:
///  - temperature: hot from 35°C (22+ points), mild from 25°C (scores at
///    all), cool below;
///  - humidity: low up to 30% (20+ points), medium up to 50% (scores at
///    all), high above;
///  - wind: strong from 35 km/h, moderate from 20, light from 10, and not
///    mentioned below 10 (it adds nothing).
String riskNote(AppLocalizations l10n, {required num temperature, required num humidity, required num wind}) {
  final t = temperature.round();
  final h = humidity.round();
  final w = wind.round();
  final parts = <String>[
    temperature >= 35
        ? l10n.riskNoteHighTemp(t)
        : temperature >= 25
            ? l10n.riskNoteMildTemp(t)
            : l10n.riskNoteCoolTemp(t),
    humidity <= 30
        ? l10n.riskNoteLowHumidity(h)
        : humidity <= 50
            ? l10n.riskNoteMediumHumidity(h)
            : l10n.riskNoteHighHumidity(h),
    if (wind >= 35)
      l10n.riskNoteStrongWind(w)
    else if (wind >= 20)
      l10n.riskNoteMediumWind(w)
    else if (wind >= 10)
      l10n.riskNoteLightWind(w),
  ];
  return parts.join(' • ');
}

/// Band of a derived 0–100 index (dryness, vegetation pressure) for the
/// "environmental factors" cards. Quarters, like the risk score: an index
/// of 21 is low — the cards used to floor these at "medium".
String indexBandLabel(AppLocalizations l10n, num index) => index >= 75
    ? l10n.riskDrynessVeryHigh
    : index >= 50
        ? l10n.commonHigh
        : index >= 25
            ? l10n.commonMedium
            : l10n.commonLow;

/// Wind band on the same steps as [riskNote]: strong from 35 km/h,
/// moderate from 20, low below.
String windBandLabel(AppLocalizations l10n, num kmh) =>
    kmh >= 35 ? l10n.commonHigh : kmh >= 20 ? l10n.commonMedium : l10n.commonLow;

/// Humidity band on the same steps as [riskNote]: low up to 30%, medium
/// up to 50%, high above.
String humidityBandLabel(AppLocalizations l10n, num percent) =>
    percent <= 30 ? l10n.commonLow : percent <= 50 ? l10n.commonMedium : l10n.commonHigh;
