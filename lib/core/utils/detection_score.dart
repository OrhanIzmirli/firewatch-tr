import 'package:geolocator/geolocator.dart';

import '../../models/fire_incident.dart';
import '../../models/fire_point.dart';

/// Detection confidence ("Tespit güveni"), 0–100: how strong the evidence
/// behind ONE satellite pixel is. It decides how loudly the possible-fire-
/// points layer draws the pixel. It does not say whether there is a fire,
/// and it is not a probability — no string may present it as one.
///
/// Ported from 1.0.6 with one deliberate change: 1.0.6 added up to 20 points
/// from the region's weather risk. Dry, windy weather says a fire *could*
/// start, not that this pixel *is* one, so mixing it in made a weak pixel in
/// a hot week look like strong evidence. It is gone. The four components that
/// remain are all evidence about the detection itself:
///
/// | component                                   | raw points |
/// |---------------------------------------------|-----------|
/// | NASA confidence tier (high / nominal / low) | 30 / 18 / 5 |
/// | radiated power, FRP (≥50/≥20/≥8/≥2 MW)      | 20 / 15 / 10 / 5 |
/// | multi-pass detections within 20 km (≥3/2/1) | 20 / 15 / 10 |
/// | age (≤3 h / ≤12 h / ≤24 h)                   | 10 / 7 / 3 |
///
/// The raw maximum is 80; it is scaled to 0–100 so the display stays
/// "…/100" and the 65/40 marker bands keep the meaning they had.
const int kDetectionConfidenceRawMax = 80;

/// Marker bands on the scaled score.
const int kDetectionConfidenceHigh = 65;
const int kDetectionConfidenceMedium = 40;

/// A fresh pixel at or above this power is drawn as an attention marker even
/// when nothing else corroborates it.
const double kStrongUnverifiedFrpMw = 15;

/// "Fresh" for the attention marker.
const int kStrongUnverifiedMaxAgeHours = 12;

/// Radius within which an existing multi-pass detection raises a new pixel's
/// score. Wide enough to cover a fire complex, narrow enough that a fire in
/// the next province says nothing.
const double kNearbyFireRadiusMeters = 20000;

/// Raw (unscaled) points, exposed for tests and for anyone checking the sum.
int detectionConfidenceRaw(
  FirePoint point, {
  int nearbyMultiPass = 0,
  DateTime? now,
}) {
  var score = 0;

  switch (point.riskTier) {
    case 'high':
      score += 30;
    case 'medium':
      score += 18;
    default:
      score += 5;
  }

  final frp = point.frp;
  if (frp >= 50) {
    score += 20;
  } else if (frp >= 20) {
    score += 15;
  } else if (frp >= 8) {
    score += 10;
  } else if (frp >= 2) {
    score += 5;
  }

  if (nearbyMultiPass >= 3) {
    score += 20;
  } else if (nearbyMultiPass == 2) {
    score += 15;
  } else if (nearbyMultiPass == 1) {
    score += 10;
  }

  final detected = point.detectionDateTimeUtc;
  if (detected != null) {
    final ageHours = (now ?? DateTime.now()).toUtc().difference(detected).inHours;
    if (ageHours <= 3) {
      score += 10;
    } else if (ageHours <= 12) {
      score += 7;
    } else if (ageHours <= 24) {
      score += 3;
    }
  }

  return score;
}

/// The scaled 0–100 score shown as "Tespit güveni: N/100".
int detectionConfidenceScore(
  FirePoint point, {
  int nearbyMultiPass = 0,
  DateTime? now,
}) {
  final raw = detectionConfidenceRaw(
    point,
    nearbyMultiPass: nearbyMultiPass,
    now: now,
  );
  return (raw * 100 / kDetectionConfidenceRawMax).round().clamp(0, 100);
}

/// Multi-pass detections ([FireIncident.isMultiPassDetection]) within
/// [kNearbyFireRadiusMeters] of [point]. The incidents feed spans about a
/// week, so this reads as "corroborated heat in this area recently".
int multiPassDetectionsNear(FirePoint point, List<FireIncident> incidents) {
  var count = 0;
  for (final incident in incidents) {
    if (!incident.isMultiPassDetection) continue;
    final distance = Geolocator.distanceBetween(
      point.latitude,
      point.longitude,
      incident.latitude,
      incident.longitude,
    );
    if (distance <= kNearbyFireRadiusMeters) count++;
  }
  return count;
}

/// [detectionConfidenceScore] with the nearby component counted from the
/// loaded incident list (an empty list simply leaves that component out).
int detectionConfidenceScoreFor(
  FirePoint point, {
  List<FireIncident> incidents = const [],
  DateTime? now,
}) =>
    detectionConfidenceScore(
      point,
      nearbyMultiPass: multiPassDetectionsNear(point, incidents),
      now: now,
    );

/// A fresh pixel whose signal is too strong to sit among the ordinary dots,
/// yet which has not cleared the multi-pass bar: drawn with an attention
/// marker and stated as unverified. Neither hidden nor inflated.
bool isStrongUnverifiedPoint(
  FirePoint point, {
  required int score,
  DateTime? now,
}) {
  final detected = point.detectionDateTimeUtc;
  if (detected == null) return false;
  final age = (now ?? DateTime.now()).toUtc().difference(detected);
  if (age.inHours > kStrongUnverifiedMaxAgeHours) return false;
  return point.frp >= kStrongUnverifiedFrpMw ||
      score >= kDetectionConfidenceHigh;
}
