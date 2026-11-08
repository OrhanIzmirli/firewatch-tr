/// What can honestly be said about satellite detections right now.
///
/// [none] is only ever a fresh pipeline reporting a real zero. A stale
/// pipeline or a failed request is its own state, so "no detections" and
/// "we could not find out" can never read the same.
enum DetectionStatusKind { strong, none, stale, unavailable }

class DetectionStatus {
  final DetectionStatusKind kind;
  final DateTime? lastUpdateAt;
  final DateTime? latestDetectionAt;
  final String? latestDetectionCity;

  const DetectionStatus({
    required this.kind,
    this.lastUpdateAt,
    this.latestDetectionAt,
    this.latestDetectionCity,
  });

  static const unavailable = DetectionStatus(kind: DetectionStatusKind.unavailable);

  factory DetectionStatus.fromJson(Map<String, dynamic> json) {
    final fresh = json['pipeline_fresh'] == true;
    final count = json['strong_detections_24h'];
    final latest = json['latest_detection'];
    final DetectionStatusKind kind;
    if (!fresh || count is! num) {
      kind = DetectionStatusKind.stale;
    } else {
      kind = count > 0 ? DetectionStatusKind.strong : DetectionStatusKind.none;
    }
    return DetectionStatus(
      kind: kind,
      lastUpdateAt: DateTime.tryParse('${json['last_update_at']}')?.toLocal(),
      latestDetectionAt: latest is Map ? DateTime.tryParse('${latest['detected_at']}')?.toLocal() : null,
      latestDetectionCity: latest is Map ? latest['city'] as String? : null,
    );
  }
}
