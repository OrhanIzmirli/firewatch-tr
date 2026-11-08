/// How the FireWatch risk score adds up, for display only.
///
/// The score itself always comes from the server; nothing here replaces it.
/// The API returns only the total, so this is a line-for-line port of the
/// point rules of `calculateRisk` in firewatch-tr-backend
/// src/services/riskScore.ts. When the API returns per-component points,
/// delete this file and read them from the response instead.
///
/// [riskBreakdownFromRow] checks every result against the server's score, so
/// a backend formula change hides the breakdown instead of showing wrong
/// points. test/risk_components_test.dart uses the backend's own examples.
library;

/// (lower bound inclusive, points), highest first.
const List<(int, int)> riskTemperatureSteps = [(40, 30), (35, 22), (30, 14), (25, 7)];

/// (upper bound inclusive, points), driest first.
const List<(int, int)> riskHumiditySteps = [(20, 25), (30, 20), (40, 13), (50, 6)];

/// (lower bound inclusive, points), strongest first.
const List<(int, int)> riskWindSteps = [(50, 25), (35, 18), (20, 11), (10, 5)];

/// (lower bound inclusive, points), most detections first.
const List<(int, int)> riskDetectionSteps = [(10, 20), (5, 15), (2, 10), (1, 5)];

/// Heat bonus tiers: (above °C, below humidity %, points), highest first.
/// Exclusive bounds; only the first match applies.
const List<(int, int, int)> riskHeatBonusTiers = [(40, 20, 20), (35, 30, 10)];

const int riskTemperatureMax = 30;
const int riskHumidityMax = 25;
const int riskWindMax = 25;
const int riskDetectionsMax = 20;
const int riskHeatBonusMax = 20;

class RiskComponents {
  final int temperature;
  final int humidity;
  final int wind;
  final int detections;
  final int heatBonus;

  const RiskComponents({
    required this.temperature,
    required this.humidity,
    required this.wind,
    required this.detections,
    required this.heatBonus,
  });

  int get weatherPoints => temperature + humidity + wind + heatBonus;
  int get rawTotal => weatherPoints + detections;

  /// The score, capped at 100 as on the server.
  int get score => rawTotal > 100 ? 100 : rawTotal;
}

int _atLeast(List<(int, int)> steps, num value) {
  for (final (from, points) in steps) {
    if (value >= from) return points;
  }
  return 0;
}

int _atMost(List<(int, int)> steps, num value) {
  for (final (upTo, points) in steps) {
    if (value <= upTo) return points;
  }
  return 0;
}

int _heatBonus(num temperature, num humidity) {
  for (final (above, below, points) in riskHeatBonusTiers) {
    if (temperature > above && humidity < below) return points;
  }
  return 0;
}

/// The port of the backend's calculateRisk point rules.
RiskComponents calculateRiskComponents({
  required num temperature,
  required num humidity,
  required num windSpeed,
  required int fireCount,
}) =>
    RiskComponents(
      temperature: _atLeast(riskTemperatureSteps, temperature),
      humidity: _atMost(riskHumiditySteps, humidity),
      wind: _atLeast(riskWindSteps, windSpeed),
      detections: _atLeast(riskDetectionSteps, fireCount),
      heatBonus: _heatBonus(temperature, humidity),
    );

/// The components of one score the server returned, with the readings.
class RiskBreakdown {
  final RiskComponents components;
  final num temperature;
  final num humidity;
  final num windSpeed;

  /// Null means unknown, never zero.
  final int? fireCount;

  /// False when [fireCount] is not the number the score was built from: the
  /// summary reads the count live while the score is from the last run.
  final bool fireCountMatchesScore;

  const RiskBreakdown({
    required this.components,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.fireCount,
    required this.fireCountMatchesScore,
  });
}

num? _number(Object? value) => value is num ? value : num.tryParse('$value');

/// Reads a row of /risk/summary or the answer of /risk/point.
///
/// Weather readings are stored with the score, so their points are exact.
/// The detection count may be newer than the score (or null), so when the
/// total does not match, the detection points are what the server's score
/// leaves after the weather. Returns null when that is not a value the
/// formula can produce: the readings are missing or the formula has changed.
RiskBreakdown? riskBreakdownFromRow(Map<String, dynamic> row) {
  final score = _number(row['general_risk_score']);
  final temperature = _number(row['temperature']);
  final humidity = _number(row['humidity']);
  final windSpeed = _number(row['wind_speed']);
  if (score == null || temperature == null || humidity == null || windSpeed == null) return null;
  final fireCount = _number(row['nearby_fire_count'])?.toInt();

  final computed = calculateRiskComponents(
    temperature: temperature,
    humidity: humidity,
    windSpeed: windSpeed,
    fireCount: fireCount ?? 0,
  );
  if (fireCount != null && computed.score == score) {
    return RiskBreakdown(
      components: computed,
      temperature: temperature,
      humidity: humidity,
      windSpeed: windSpeed,
      fireCount: fireCount,
      fireCountMatchesScore: true,
    );
  }

  final remainder = score.toInt() - computed.weatherPoints;
  final possible = remainder == 0 || riskDetectionSteps.any((step) => step.$2 == remainder);
  if (!possible) return null;
  return RiskBreakdown(
    components: RiskComponents(
      temperature: computed.temperature,
      humidity: computed.humidity,
      wind: computed.wind,
      detections: remainder,
      heatBonus: computed.heatBonus,
    ),
    temperature: temperature,
    humidity: humidity,
    windSpeed: windSpeed,
    fireCount: fireCount,
    fireCountMatchesScore: fireCount == null,
  );
}
