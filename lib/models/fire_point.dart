import '../l10n/app_localizations.dart';

class FirePoint {
  final double latitude;
  final double longitude;
  final String brightness;
  final String confidence;
  final String satellite;
  final String acquisitionDate;
  final String acquisitionTime;
  final double? distanceKm;
  final String? cityName;
  final String? nearestRegion;

  const FirePoint({
    required this.latitude,
    required this.longitude,
    required this.brightness,
    required this.confidence,
    required this.satellite,
    required this.acquisitionDate,
    required this.acquisitionTime,
    this.distanceKm,
    this.cityName,
    this.nearestRegion,
  });

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'brightness': brightness,
        'confidence': confidence,
        'satellite': satellite,
        'acquisitionDate': acquisitionDate,
        'acquisitionTime': acquisitionTime,
        'distanceKm': distanceKm,
        'cityName': cityName,
        'nearestRegion': nearestRegion,
      };

  factory FirePoint.fromJson(Map<String, dynamic> json) => FirePoint(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        brightness: json['brightness'] as String,
        confidence: json['confidence'] as String,
        satellite: json['satellite'] as String,
        acquisitionDate: json['acquisitionDate'] as String,
        acquisitionTime: json['acquisitionTime'] as String,
        distanceKm: (json['distanceKm'] as num?)?.toDouble(),
        cityName: json['cityName'] as String?,
        nearestRegion: json['nearestRegion'] as String?,
      );

  FirePoint copyWith({
    double? latitude,
    double? longitude,
    String? brightness,
    String? confidence,
    String? satellite,
    String? acquisitionDate,
    String? acquisitionTime,
    double? distanceKm,
    String? cityName,
    String? nearestRegion,
  }) {
    return FirePoint(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      brightness: brightness ?? this.brightness,
      confidence: confidence ?? this.confidence,
      satellite: satellite ?? this.satellite,
      acquisitionDate: acquisitionDate ?? this.acquisitionDate,
      acquisitionTime: acquisitionTime ?? this.acquisitionTime,
      distanceKm: distanceKm ?? this.distanceKm,
      cityName: cityName ?? this.cityName,
      nearestRegion: nearestRegion ?? this.nearestRegion,
    );
  }

  /// Canonical (non-localized) region key derived from coordinates, used only
  /// as a bbox fallback when the backend hasn't supplied a city/region name.
  /// Null when [cityName] or [nearestRegion] is available (those are proper
  /// nouns and are shown as-is regardless of locale). Used for filter-chip
  /// matching — never shown to the user directly.
  String? get regionKey {
    if (cityName != null && cityName!.isNotEmpty) return null;
    if (nearestRegion != null && nearestRegion!.isNotEmpty) return null;

    final lat = latitude;
    final lng = longitude;

    if (lng >= 26.0 && lng <= 30.5 && lat >= 36.5 && lat <= 39.5) return 'ege';
    if (lng >= 29.5 && lng <= 37.0 && lat >= 36.0 && lat <= 38.5) return 'akdeniz';
    if (lng >= 26.0 && lng <= 32.0 && lat >= 39.5 && lat <= 42.0) return 'marmara';
    if (lat >= 40.5 && lat <= 42.2) return 'karadeniz';
    if (lng >= 30.0 && lng <= 37.5 && lat >= 38.0 && lat <= 41.0) return 'ic_anadolu';
    if (lng >= 37.5 && lng <= 44.8 && lat >= 38.0 && lat <= 42.0) return 'dogu_anadolu';
    if (lng >= 36.0 && lng <= 44.8 && lat >= 36.0 && lat <= 38.5) return 'guneydogu_anadolu';

    return null;
  }

  /// Display name for the point's region/city. City/region names coming from
  /// the backend are proper nouns and are shown as-is in every locale; only
  /// the coordinate-based fallback is translated.
  String regionDisplayName(AppLocalizations l10n) {
    if (cityName != null && cityName!.isNotEmpty) return cityName!;
    if (nearestRegion != null && nearestRegion!.isNotEmpty) return nearestRegion!;

    switch (regionKey) {
      case 'ege': return l10n.regionEge;
      case 'akdeniz': return l10n.regionAkdeniz;
      case 'marmara': return l10n.regionMarmara;
      case 'karadeniz': return l10n.regionKaradeniz;
      case 'ic_anadolu': return l10n.regionIcAnadolu;
      case 'dogu_anadolu': return l10n.regionDoguAnadolu;
      case 'guneydogu_anadolu': return l10n.regionGuneydoguAnadolu;
      default: return l10n.regionTurkiyeGeneli;
    }
  }

  /// Canonical (non-localized) risk tier, used for filtering/coloring logic.
  String get riskTier {
    final c = confidence.toLowerCase().trim();
    if (c.contains('high') || c == 'h') return 'high';
    if (c.contains('nominal') || c == 'n') return 'medium';
    return 'low';
  }

  String riskLevelLabel(AppLocalizations l10n) {
    switch (riskTier) {
      case 'high': return l10n.commonHigh;
      case 'medium': return l10n.commonMedium;
      default: return l10n.commonLow;
    }
  }

  String locationLabelText(AppLocalizations l10n) {
    final latDir = latitude >= 0 ? l10n.compassNorth : l10n.compassSouth;
    final lngDir = longitude >= 0 ? l10n.compassEast : l10n.compassWest;
    return '${latitude.abs().toStringAsFixed(2)}°$latDir ${longitude.abs().toStringAsFixed(2)}°$lngDir';
  }

  String get formattedDate {
    if (acquisitionDate.length == 10) {
      final parts = acquisitionDate.split('-');
      if (parts.length == 3) return '${parts[2]}.${parts[1]}.${parts[0]}';
    }
    return acquisitionDate;
  }

  String get formattedTime {
    if (acquisitionTime.length >= 4) {
      final t = acquisitionTime.padLeft(4, '0');
      return '${t.substring(0, 2)}:${t.substring(2, 4)}';
    }
    return acquisitionTime;
  }

  String riskReasonText(AppLocalizations l10n) {
    final bright = double.tryParse(brightness) ?? 0;
    final temp = bright.toStringAsFixed(0);
    switch (riskTier) {
      case 'high':
        return bright > 0
            ? l10n.riskReasonHighWithTemp(temp)
            : l10n.riskReasonHighNoTemp;
      case 'medium':
        return bright > 0
            ? l10n.riskReasonMediumWithTemp(temp)
            : l10n.riskReasonMediumNoTemp;
      default:
        return bright > 0
            ? l10n.riskReasonLowWithTemp(temp)
            : l10n.riskReasonLowNoTemp;
    }
  }

  String generatedDescriptionText(AppLocalizations l10n) {
    switch (riskTier) {
      case 'high': return l10n.fireGeneratedDescHigh;
      case 'medium': return l10n.fireGeneratedDescMedium;
      default: return l10n.fireGeneratedDescLow;
    }
  }

  String recommendedActionText(AppLocalizations l10n) {
    switch (riskTier) {
      case 'high': return l10n.fireRecommendedActionHigh;
      case 'medium': return l10n.fireRecommendedActionMedium;
      default: return l10n.fireRecommendedActionLow;
    }
  }
}