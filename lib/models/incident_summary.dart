import 'fire_incident.dart';
import 'persistent_heat_source.dart';

/// The last 24 hours of fire events in three numbers, for the Home overview.
///
/// [detectionEndedLast24h] counts events that stopped being detected. It is
/// NOT a count of fires that were put out — nothing in the satellite data can
/// support that claim — and every string that renders it must say so.
class IncidentSummary {
  /// The recency threshold the backend used, so the UI can explain what
  /// "active" means instead of asserting it.
  final int recentDetectionHours;

  final int activeCount;

  /// How many of [activeCount] clear the evidence bar. The two are shown
  /// together because the larger number alone reads as a count of fires,
  /// when most of it is single fresh pixels awaiting a second overpass.
  final int activeSignificantCount;

  final int detectionEndedLast24h;

  final int? strongestActiveId;
  final String? strongestActiveCityName;
  final double? strongestActiveMaxFrpMw;

  /// A LOWER BOUND, not a measurement. The ingest window is two days, so an
  /// incident burning for a month still reports about a day: the number says
  /// "at least this long" and the UI must phrase it that way.
  final double? strongestActiveDurationHoursAtLeast;

  /// Fixed heat sources currently radiating, left OUT of [activeCount] by
  /// the backend and listed here so the client can grey out the raw
  /// detections sitting on them. Empty on a backend before migration 011.
  final int persistentHeatSourcesActive;
  final List<PersistentHeatSource> persistentHeatSources;

  const IncidentSummary({
    required this.recentDetectionHours,
    required this.activeCount,
    required this.activeSignificantCount,
    required this.detectionEndedLast24h,
    this.strongestActiveId,
    this.strongestActiveCityName,
    this.strongestActiveMaxFrpMw,
    this.strongestActiveDurationHoursAtLeast,
    this.persistentHeatSourcesActive = 0,
    this.persistentHeatSources = const [],
  });

  bool get hasStrongestActive => strongestActiveMaxFrpMw != null;

  factory IncidentSummary.fromJson(Map<String, dynamic> json) {
    final strongest =
        (json['strongest_active'] as Map?)?.cast<String, dynamic>();
    return IncidentSummary(
      recentDetectionHours:
          (json['recent_detection_hours'] as num?)?.toInt() ?? 6,
      activeCount: (json['active_count'] as num?)?.toInt() ?? 0,
      activeSignificantCount:
          (json['active_significant_count'] as num?)?.toInt() ?? 0,
      detectionEndedLast24h:
          (json['detection_ended_24h'] as num?)?.toInt() ?? 0,
      strongestActiveId: (strongest?['id'] as num?)?.toInt(),
      strongestActiveCityName: strongest?['city_name'] as String?,
      strongestActiveMaxFrpMw: _toDouble(strongest?['max_frp_mw']),
      strongestActiveDurationHoursAtLeast:
          _toDouble(strongest?['duration_hours_at_least']),
      persistentHeatSourcesActive:
          (json['persistent_heat_sources_active'] as num?)?.toInt() ?? 0,
      persistentHeatSources: ((json['persistent_heat_sources'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => PersistentHeatSource.fromJson(e.cast<String, dynamic>()))
          .toList(),
    );
  }

  /// Client-side fallback for when the summary endpoint is not deployed yet.
  ///
  /// It can only see the incidents the client already fetched, so the counts
  /// are bounded by that page — good enough to keep the card alive, and the
  /// same definitions as the server so the two never disagree in kind.
  factory IncidentSummary.fromIncidents(
    List<FireIncident> incidents, {
    int recentDetectionHours = 6,
  }) {
    final active = incidents
        .where((i) => i.status == IncidentStatus.activeDetection)
        .toList();

    // Same evidence bar the map's "no longer seen" filter uses. Without it
    // this counted 194 while the map showed 13, and one of the two numbers
    // would have been read as the number of fires that stopped burning.
    final endedRecently = incidents
        .where(
          (i) =>
              i.status != IncidentStatus.activeDetection &&
              i.isSignificant &&
              i.hoursSinceLastDetection <= recentDetectionHours + 24,
        )
        .length;

    // Ranked by radiative power, not duration. Duration is censored by the
    // ingest window, so ranking on it selects for whatever is closest to the
    // window edge — which is whatever never stops, i.e. a fixed industrial
    // source rather than a fire.
    FireIncident? strongest;
    for (final incident in active) {
      if (!incident.isSignificant) continue;
      if (strongest == null ||
          (incident.maxFrpMw ?? 0) > (strongest.maxFrpMw ?? 0)) {
        strongest = incident;
      }
    }

    return IncidentSummary(
      recentDetectionHours: recentDetectionHours,
      activeCount: active.length,
      activeSignificantCount:
          active.where((i) => i.isSignificant).length,
      detectionEndedLast24h: endedRecently,
      strongestActiveId: strongest?.id,
      strongestActiveMaxFrpMw: strongest?.maxFrpMw,
      strongestActiveDurationHoursAtLeast: strongest?.durationHours,
      persistentHeatSourcesActive: incidents
          .where((i) => i.isPersistentHeatSource && i.hoursSinceLastDetection <= recentDetectionHours)
          .length,
      persistentHeatSources: [
        for (final i in incidents)
          if (i.isPersistentHeatSource)
            PersistentHeatSource(
              id: i.id,
              latitude: i.latitude,
              longitude: i.longitude,
              cityName: i.cityName,
              distinctDaysSeen: i.distinctDaysSeen,
            ),
      ],
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
