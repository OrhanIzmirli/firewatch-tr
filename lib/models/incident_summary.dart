import 'fire_incident.dart';

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
  final int detectionEndedLast24h;

  final int? longestActiveId;
  final String? longestActiveCityName;
  final double? longestActiveDurationHours;

  const IncidentSummary({
    required this.recentDetectionHours,
    required this.activeCount,
    required this.detectionEndedLast24h,
    this.longestActiveId,
    this.longestActiveCityName,
    this.longestActiveDurationHours,
  });

  bool get hasLongestActive => longestActiveDurationHours != null;

  factory IncidentSummary.fromJson(Map<String, dynamic> json) {
    final longest = (json['longest_active'] as Map?)?.cast<String, dynamic>();
    return IncidentSummary(
      recentDetectionHours:
          (json['recent_detection_hours'] as num?)?.toInt() ?? 6,
      activeCount: (json['active_count'] as num?)?.toInt() ?? 0,
      detectionEndedLast24h:
          (json['detection_ended_24h'] as num?)?.toInt() ?? 0,
      longestActiveId: (longest?['id'] as num?)?.toInt(),
      longestActiveCityName: longest?['city_name'] as String?,
      longestActiveDurationHours: _toDouble(longest?['duration_hours']),
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

    final endedRecently = incidents
        .where(
          (i) =>
              i.status != IncidentStatus.activeDetection &&
              i.hoursSinceLastDetection <= recentDetectionHours + 24,
        )
        .length;

    FireIncident? longest;
    for (final incident in active) {
      if (longest == null || incident.durationHours > longest.durationHours) {
        longest = incident;
      }
    }

    return IncidentSummary(
      recentDetectionHours: recentDetectionHours,
      activeCount: active.length,
      detectionEndedLast24h: endedRecently,
      longestActiveId: longest?.id,
      longestActiveDurationHours: longest?.durationHours,
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
