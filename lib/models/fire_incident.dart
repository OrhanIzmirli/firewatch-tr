import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../l10n/app_localizations.dart';

/// A clustered fire event: many satellite pixels across several passes,
/// grouped by the backend into one thing that persists over time.
///
/// Deliberately separate from [FirePoint]/[FireStatus], which describe a
/// SINGLE detection and how fresh it is. The two answer different questions
/// and neither replaces the other — an incident asks "what is happening
/// here", a point asks "how recent is this pixel".
class FireIncident {
  final int id;
  final DateTime? firstDetectedAt;
  final DateTime? lastDetectedAt;
  final double durationHours;
  final int detectionCount;
  final int overpassCount;
  final double latitude;
  final double longitude;
  final double? maxFrpMw;
  final String? peakConfidenceTier;
  final int? cityId;
  final String? regionKey;

  /// What the satellite saw. Can never say a fire is out.
  final String satelliteState;
  final double hoursSinceLastDetection;

  /// Burnt-area confirmation. Null until the EFFIS integration lands.
  final double? opticalBurntAreaHa;
  final String? opticalSource;

  /// The ONLY field that may ever claim containment or extinction, and only
  /// when an official source confirmed it. Null everywhere today.
  final String? officialState;
  final String? officialSource;
  final String? officialSourceUrl;

  final double? spreadBearingDeg;
  final double? spreadSpeedMh;
  final String spreadConfidence;

  const FireIncident({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.satelliteState,
    required this.hoursSinceLastDetection,
    required this.durationHours,
    required this.detectionCount,
    required this.overpassCount,
    required this.spreadConfidence,
    this.firstDetectedAt,
    this.lastDetectedAt,
    this.maxFrpMw,
    this.peakConfidenceTier,
    this.cityId,
    this.regionKey,
    this.opticalBurntAreaHa,
    this.opticalSource,
    this.officialState,
    this.officialSource,
    this.officialSourceUrl,
    this.spreadBearingDeg,
    this.spreadSpeedMh,
  });

  factory FireIncident.fromJson(Map<String, dynamic> json) {
    final satellite = (json['satellite'] as Map?)?.cast<String, dynamic>() ?? const {};
    final optical = (json['optical'] as Map?)?.cast<String, dynamic>() ?? const {};
    final official = (json['official'] as Map?)?.cast<String, dynamic>() ?? const {};
    final spread = (json['spread'] as Map?)?.cast<String, dynamic>() ?? const {};

    return FireIncident(
      id: (json['id'] as num).toInt(),
      firstDetectedAt: _parseDate(json['first_detected_at']),
      lastDetectedAt: _parseDate(json['last_detected_at']),
      durationHours: _toDouble(json['duration_hours']) ?? 0,
      detectionCount: (json['detection_count'] as num?)?.toInt() ?? 0,
      overpassCount: (json['overpass_count'] as num?)?.toInt() ?? 0,
      latitude: _toDouble(json['latitude']) ?? 0,
      longitude: _toDouble(json['longitude']) ?? 0,
      maxFrpMw: _toDouble(json['max_frp_mw']),
      peakConfidenceTier: json['peak_confidence_tier'] as String?,
      cityId: (json['city_id'] as num?)?.toInt(),
      regionKey: json['region_key'] as String?,
      satelliteState: satellite['state'] as String? ?? 'no_recent_detection',
      hoursSinceLastDetection: _toDouble(satellite['hours_since_last_detection']) ?? 0,
      opticalBurntAreaHa: _toDouble(optical['burnt_area_ha']),
      opticalSource: optical['source'] as String?,
      officialState: official['state'] as String?,
      officialSource: official['source'] as String?,
      officialSourceUrl: official['source_url'] as String?,
      spreadBearingDeg: _toDouble(spread['bearing_deg']),
      spreadSpeedMh: _toDouble(spread['speed_m_per_hour']),
      spreadConfidence: spread['confidence'] as String? ?? 'insufficient',
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is! String) return null;
    return DateTime.tryParse(value)?.toUtc();
  }

  /// Which of the three map categories this belongs to.
  ///
  /// Only FIRMS' 'low' tier falls to the faded category. 'nominal' is its
  /// middle tier and a credible detection — greying it out would push 197 of
  /// the 237 live events into "probably nothing", which is both wrong and the
  /// kind of wrong that makes a real fire easy to miss.
  IncidentStatus get status {
    if (satelliteState == 'detected_recently') return IncidentStatus.activeDetection;
    return peakConfidenceTier == 'low'
        ? IncidentStatus.lowConfidence
        : IncidentStatus.awaitingConfirmation;
  }

  /// True only when a named official source confirmed a state. Never inferred.
  bool get hasOfficialStatus => officialState != null && officialState!.isNotEmpty;

  /// Spread is published only when the backend judged the evidence sufficient.
  bool get hasSpread =>
      spreadConfidence != 'insufficient' &&
      spreadBearingDeg != null &&
      spreadSpeedMh != null;
}

/// The three states a fire event can be shown in.
///
/// There is deliberately NO "extinguished" member. A satellite passes a few
/// times a day and sees nothing through cloud or smoke, so absence of
/// detection is not evidence a fire is out — showing it as such would be
/// wrong in the direction that gets people hurt. If an official source ever
/// confirms containment, that arrives through [FireIncident.officialState] as
/// a separate badge, not as a map category.
enum IncidentStatus {
  /// Seen by a satellite within the last few hours.
  activeDetection,

  /// Not seen recently, but the detections it does have were high confidence.
  awaitingConfirmation,

  /// Not seen recently and only ever low-confidence detections.
  lowConfidence,
}

/// Which slice of events the map draws.
///
/// [ended] means "no satellite has seen it for a while" and nothing more.
/// It is deliberately NOT called extinguished or contained: nothing in this
/// data can support that claim, and a filter label is exactly the kind of
/// place where a convenient word would quietly become a fact.
enum IncidentFilter { active, ended, all }

extension IncidentFilterX on IncidentFilter {
  String get storageValue => name;

  static IncidentFilter fromStorage(String? value) {
    return IncidentFilter.values.firstWhere(
      (f) => f.name == value,
      orElse: () => IncidentFilter.active,
    );
  }

  bool matches(FireIncident incident) {
    switch (this) {
      case IncidentFilter.active:
        return incident.status == IncidentStatus.activeDetection;
      case IncidentFilter.ended:
        return incident.status != IncidentStatus.activeDetection;
      case IncidentFilter.all:
        return true;
    }
  }

  String label(AppLocalizations l10n) {
    switch (this) {
      case IncidentFilter.active:
        return l10n.incidentFilterActive;
      case IncidentFilter.ended:
        return l10n.incidentFilterEnded;
      case IncidentFilter.all:
        return l10n.incidentFilterAll;
    }
  }
}

extension IncidentStatusStyle on IncidentStatus {
  Color get color {
    switch (this) {
      case IncidentStatus.activeDetection:
        return AppColors.danger;
      case IncidentStatus.awaitingConfirmation:
        return AppColors.primary;
      case IncidentStatus.lowConfidence:
        return const Color(0xFF94A3B8);
    }
  }

  /// One icon per category, never an emoji. The flame reads as burning, the
  /// outlined warning as "we cannot see it right now", and the faded dot as
  /// "there is something here but the evidence is thin".
  IconData get icon {
    switch (this) {
      case IncidentStatus.activeDetection:
        return Icons.local_fire_department_rounded;
      case IncidentStatus.awaitingConfirmation:
        return Icons.warning_amber_rounded;
      case IncidentStatus.lowConfidence:
        return Icons.blur_on_rounded;
    }
  }

  /// Base diameter at the reference zoom; the map scales it by current zoom
  /// at draw time and clamps it to [minMarkerSize]/[maxMarkerSize].
  ///
  /// The gap between the tiers is deliberately wide. Roughly nine out of ten
  /// live events sit in the middle tier, so if it is drawn anywhere near the
  /// size of an active one the handful of fires burning right now disappear
  /// into the crowd. Active events are the only ones allowed to be big.
  double get markerSize {
    switch (this) {
      case IncidentStatus.activeDetection:
        return 26;
      case IncidentStatus.awaitingConfirmation:
        return 17;
      case IncidentStatus.lowConfidence:
        return 11;
    }
  }

  double get minMarkerSize {
    switch (this) {
      case IncidentStatus.activeDetection:
        return 18;
      case IncidentStatus.awaitingConfirmation:
        return 12;
      case IncidentStatus.lowConfidence:
        return 8;
    }
  }

  double get maxMarkerSize {
    switch (this) {
      case IncidentStatus.activeDetection:
        return 34;
      case IncidentStatus.awaitingConfirmation:
        return 24;
      case IncidentStatus.lowConfidence:
        return 22;
    }
  }

  /// How solid the disc is. The middle and faded tiers sit back so the map
  /// underneath stays readable through them; an active fire is fully opaque.
  double get fillOpacity {
    switch (this) {
      case IncidentStatus.activeDetection:
        return 1;
      case IncidentStatus.awaitingConfirmation:
        return 0.88;
      case IncidentStatus.lowConfidence:
        return 0.62;
    }
  }

  String label(AppLocalizations l10n) {
    switch (this) {
      case IncidentStatus.activeDetection:
        return l10n.incidentStatusActive;
      case IncidentStatus.awaitingConfirmation:
        return l10n.incidentStatusAwaiting;
      case IncidentStatus.lowConfidence:
        return l10n.incidentStatusLowConfidence;
    }
  }
}

/// Turns a bearing in degrees into an eight-point compass direction.
String compassDirection(AppLocalizations l10n, double bearingDeg) {
  const sectors = 8;
  final normalised = ((bearingDeg % 360) + 360) % 360;
  final index = (((normalised + 22.5) % 360) / (360 / sectors)).floor();
  switch (index) {
    case 0:
      return l10n.compassTowardsNorth;
    case 1:
      return l10n.compassTowardsNorthEast;
    case 2:
      return l10n.compassTowardsEast;
    case 3:
      return l10n.compassTowardsSouthEast;
    case 4:
      return l10n.compassTowardsSouth;
    case 5:
      return l10n.compassTowardsSouthWest;
    case 6:
      return l10n.compassTowardsWest;
    default:
      return l10n.compassTowardsNorthWest;
  }
}
