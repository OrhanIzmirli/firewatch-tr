class FireEvent {
  final String id;
  final String title;
  final String city;
  final String district;
  final String description;
  final String status;
  final String riskLevel;
  /// Canonical (non-localized) risk tier — 'high' | 'medium' | 'low' — used
  /// for color-coding, independent of the localized [riskLevel] display text.
  final String riskTier;
  final String updatedAt;
  final String startedAt;
  final String affectedArea;
  final String windStatus;
  final String spreadRisk;
  final List<String> recommendedActions;
  final double lat;
  final double lng;

  const FireEvent({
    required this.id,
    required this.title,
    required this.city,
    required this.district,
    required this.description,
    required this.status,
    required this.riskLevel,
    required this.riskTier,
    required this.updatedAt,
    required this.startedAt,
    required this.affectedArea,
    required this.windStatus,
    required this.spreadRisk,
    required this.recommendedActions,
    required this.lat,
    required this.lng,
  });
}