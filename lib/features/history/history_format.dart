// Helpers for the history screen that do not need a widget tree, so the
// contract with GET /api/history can be tested on its own.

/// The backend takes plain calendar days (YYYY-MM-DD), not timestamps.
String historyQueryDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

/// What the backend sends for a satellite record that has no measured area:
/// how often and how long the satellite saw heat, and how strong it was.
class HistoryDetectionInfo {
  final int count;
  final num? durationHours;
  final num? maxFrpMw;
  const HistoryDetectionInfo(this.count, this.durationHours, this.maxFrpMw);

  /// Null when the record carries no detection count (sample data, or a
  /// record from another source).
  static HistoryDetectionInfo? fromProperties(Map<String, dynamic> p) {
    final count = num.tryParse('${p['detection_count']}');
    if (count == null || count < 0) return null;
    return HistoryDetectionInfo(
      count.toInt(),
      num.tryParse('${p['duration_hours']}'),
      num.tryParse('${p['max_frp_mw']}'),
    );
  }
}

/// "0.5", "7.3", "41" — one decimal below ten hours, whole hours above.
String formatHours(num hours) =>
    hours < 10 ? hours.toStringAsFixed(1) : hours.round().toString();

/// The geometry is where the satellite saw heat, not a burn scar.
bool isHeatFootprint(Map<String, dynamic> p) =>
    p['geometry_kind'] == 'satellite_heat_detection_footprint';

/// The district was inferred from the nearest district centre.
bool isNearestDistrict(Map<String, dynamic> p) =>
    p['district_basis'] == 'nearest_district_center';
