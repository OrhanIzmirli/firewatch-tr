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
  /// Canonical Turkish region name (e.g. "Ege", "İç Anadolu"), independent
  /// of app locale — used to cross-reference backend data (news
  /// relatedRegion) that's always in Turkish. Not for display.
  final String regionNameTr;
  final String updatedAt;
  final String startedAt;
  /// Real measured area from NASA FIRMS' scan/track pixel-size fields
  /// (already formatted for display) — not a brightness-based estimate.
  final String affectedArea;
  final String spreadRisk;
  final List<String> recommendedActions;
  final double lat;
  final double lng;
  /// Fire Radiative Power (MW) from NASA FIRMS — 0 when not available.
  final double frp;

  const FireEvent({
    required this.id,
    required this.title,
    required this.city,
    required this.district,
    required this.description,
    required this.status,
    required this.riskLevel,
    required this.riskTier,
    required this.regionNameTr,
    required this.updatedAt,
    required this.startedAt,
    required this.affectedArea,
    required this.spreadRisk,
    required this.recommendedActions,
    required this.lat,
    required this.lng,
    this.frp = 0,
  });
}