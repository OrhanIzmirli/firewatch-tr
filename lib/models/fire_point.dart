import '../core/utils/turkish_text.dart';
import '../l10n/app_localizations.dart';
import '../services/risk_data_cache.dart';

enum FireLocationType { forest, coastal, agricultural, urban, generic }

/// Data-driven fire status derived from detection freshness, NASA confidence
/// tier, and radiative power — distinct from [FirePoint.riskTier], which
/// only reflects NASA's own confidence value. Checked most-specific-first:
/// a `low` confidence detection is always [historical] regardless of age.
enum FireStatus { active, likelyActive, monitoring, historical }

String fireStatusEmoji(FireStatus status) {
  switch (status) {
    case FireStatus.active: return '🔴';
    case FireStatus.likelyActive: return '🟠';
    case FireStatus.monitoring: return '🟡';
    case FireStatus.historical: return '⚫';
  }
}

String fireStatusLabel(AppLocalizations l10n, FireStatus status) {
  switch (status) {
    case FireStatus.active: return l10n.fireStatusActive;
    case FireStatus.likelyActive: return l10n.fireStatusLikelyActive;
    case FireStatus.monitoring: return l10n.fireStatusMonitoring;
    case FireStatus.historical: return l10n.fireStatusHistorical;
  }
}

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
  /// Fire Radiative Power (MW) — energy release rate, from NASA FIRMS.
  final double frp;
  /// Along-scan and along-track pixel size (km) — used to estimate the
  /// area of the detection.
  final double scanKm;
  final double trackKm;
  /// Other satellite/instrument names (beyond [satellite]) that reported a
  /// detection within 500m and 3 hours of this point during
  /// deduplication — e.g. this point's [satellite] is "VIIRS" and
  /// [mergedSatellites] is ["MODIS"] when both sources saw the same fire.
  /// Empty when this point wasn't merged with anything.
  final List<String> mergedSatellites;

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
    this.frp = 0,
    this.scanKm = 0,
    this.trackKm = 0,
    this.mergedSatellites = const [],
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
        'frp': frp,
        'scanKm': scanKm,
        'trackKm': trackKm,
        'mergedSatellites': mergedSatellites,
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
        // Absent in data cached before these fields were added.
        frp: (json['frp'] as num?)?.toDouble() ?? 0,
        scanKm: (json['scanKm'] as num?)?.toDouble() ?? 0,
        trackKm: (json['trackKm'] as num?)?.toDouble() ?? 0,
        mergedSatellites: (json['mergedSatellites'] as List?)?.map((e) => e.toString()).toList() ?? const [],
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
    double? frp,
    double? scanKm,
    double? trackKm,
    List<String>? mergedSatellites,
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
      frp: frp ?? this.frp,
      scanKm: scanKm ?? this.scanKm,
      trackKm: trackKm ?? this.trackKm,
      mergedSatellites: mergedSatellites ?? this.mergedSatellites,
    );
  }

  bool get isMerged => mergedSatellites.isNotEmpty;

  /// "VIIRS + MODIS"-style label combining the primary satellite with any
  /// merged ones — for display on fire cards when [isMerged] is true.
  String get mergedSatelliteLabel => [satellite, ...mergedSatellites].join(' + ');

  static String? _bboxRegionKey(double lat, double lng) {
    if (lng >= 26.0 && lng <= 30.5 && lat >= 36.5 && lat <= 39.5) return 'ege';
    if (lng >= 29.5 && lng <= 37.0 && lat >= 36.0 && lat <= 38.5) return 'akdeniz';
    if (lng >= 26.0 && lng <= 32.0 && lat >= 39.5 && lat <= 42.0) return 'marmara';
    if (lat >= 40.5 && lat <= 42.2) return 'karadeniz';
    if (lng >= 30.0 && lng <= 37.5 && lat >= 38.0 && lat <= 41.0) return 'ic_anadolu';
    if (lng >= 37.5 && lng <= 44.8 && lat >= 38.0 && lat <= 42.0) return 'dogu_anadolu';
    if (lng >= 36.0 && lng <= 44.8 && lat >= 36.0 && lat <= 38.5) return 'guneydogu_anadolu';
    return null;
  }

  /// Canonical (non-localized) region key derived from coordinates, used only
  /// as a bbox fallback when the backend hasn't supplied a city/region name.
  /// Null when [cityName] or [nearestRegion] is available (those are proper
  /// nouns and are shown as-is regardless of locale). Used for filter-chip
  /// matching — never shown to the user directly.
  String? get regionKey {
    if (cityName != null && cityName!.isNotEmpty) return null;
    if (nearestRegion != null && nearestRegion!.isNotEmpty) return null;
    return _bboxRegionKey(latitude, longitude);
  }

  /// Always-computed bbox region key (regardless of whether a display city
  /// name is available), used purely to cross-reference this point against
  /// backend risk-summary data — never shown to the user directly.
  String? get riskRegionKey => _bboxRegionKey(latitude, longitude);

  static const _forestCities = [
    'mugla', 'antalya', 'izmir', 'bursa', 'canakkale', 'bolu',
    'kastamonu', 'artvin', 'zonguldak', 'duzce', 'manisa', 'aydin', 'denizli',
  ];
  static const _agriculturalCities = [
    'konya', 'eskisehir', 'corum', 'sivas', 'yozgat', 'kirsehir', 'aksaray', 'karaman',
  ];
  static const _urbanCities = [
    'istanbul', 'ankara', 'gaziantep',
  ];

  /// Rough location-type classification used to flavor generated
  /// descriptions. Based on the resolved city name where available (a
  /// point's cityName is a specific settlement, not the region), falling
  /// back to a coastal coordinate check. Best-effort — city-level data
  /// can't distinguish e.g. a city center from surrounding countryside.
  FireLocationType get locationType {
    final city = cityName != null ? foldTurkish(cityName!) : '';
    if (city.isNotEmpty) {
      if (_urbanCities.any(city.contains)) return FireLocationType.urban;
      if (_forestCities.any(city.contains)) return FireLocationType.forest;
      if (_agriculturalCities.any(city.contains)) return FireLocationType.agricultural;
    }
    if (longitude >= 26.0 && longitude <= 30.0 && latitude >= 36.0 && latitude <= 38.5) {
      return FireLocationType.coastal;
    }
    return FireLocationType.generic;
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

  /// Canonical Turkish region name, independent of app locale — used to
  /// cross-reference this point against other backend data (e.g. news
  /// articles' relatedRegion field) that is always in Turkish regardless
  /// of the app's display language. Not for display — use
  /// [regionDisplayName] for that.
  String get canonicalRegionNameTr {
    if (nearestRegion != null && nearestRegion!.isNotEmpty) return nearestRegion!;
    switch (regionKey ?? _bboxRegionKey(latitude, longitude)) {
      case 'ege': return 'Ege';
      case 'akdeniz': return 'Akdeniz';
      case 'marmara': return 'Marmara';
      case 'karadeniz': return 'Karadeniz';
      case 'ic_anadolu': return 'İç Anadolu';
      case 'dogu_anadolu': return 'Doğu Anadolu';
      case 'guneydogu_anadolu': return 'Güneydoğu Anadolu';
      default: return 'Türkiye Geneli';
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

  /// Data-driven status combining detection age, NASA confidence, and FRP:
  /// - <1h + high confidence + FRP>50MW → [FireStatus.active]
  /// - <3h + high confidence → [FireStatus.likelyActive]
  /// - <12h + nominal confidence → [FireStatus.monitoring]
  /// - >=12h, or low confidence at any age → [FireStatus.historical]
  FireStatus get smartStatus {
    if (riskTier == 'low') return FireStatus.historical;

    final detectedAt = detectionDateTimeUtc;
    if (detectedAt == null) return FireStatus.historical;
    final hours = DateTime.now().toUtc().difference(detectedAt).inHours;
    if (hours < 0 || hours >= 12) return FireStatus.historical;

    if (hours < 1 && riskTier == 'high' && frp > 50) return FireStatus.active;
    if (hours < 3 && riskTier == 'high') return FireStatus.likelyActive;
    if (riskTier == 'medium') return FireStatus.monitoring;
    return FireStatus.historical;
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

  /// Smart, data-driven fire description combining several independent
  /// clauses: intensity (brightness + FRP/area), location + location-type
  /// hint, NASA detection confidence, the region's current spread risk
  /// (cross-referenced against the cached risk summary, when available),
  /// and how long ago this was detected. Composed as short standalone
  /// sentences rather than one giant run-on sentence, for readability and
  /// to keep the Turkish/English grammar clean without a template for
  /// every possible combination.
  String riskReasonText(AppLocalizations l10n) {
    final bright = double.tryParse(brightness) ?? 0;
    final location = regionDisplayName(l10n);
    final sentences = <String>[];

    // 1. Intensity (brightness-based tiers; FRP/area add supporting detail
    // rather than gating the tier, since FRP can be low even for a
    // genuinely hot detection depending on pixel footprint).
    final buffer = StringBuffer();
    if (bright > 400) {
      buffer.write(l10n.smartIntensityIntense(location));
    } else if (bright >= 380) {
      buffer.write(l10n.smartIntensityHigh(location));
    } else if (bright >= 360) {
      buffer.write(l10n.smartIntensityModerate(location));
    } else if (bright >= 340) {
      buffer.write(l10n.smartIntensityEarly(location));
    } else {
      buffer.write(l10n.smartIntensityAnomaly(location));
    }

    final hint = switch (locationType) {
      FireLocationType.forest => l10n.smartLocationHintForest,
      FireLocationType.coastal => l10n.smartLocationHintCoastal,
      FireLocationType.urban => l10n.smartLocationHintUrban,
      FireLocationType.agricultural => l10n.smartLocationHintAgricultural,
      FireLocationType.generic => null,
    };
    if (hint != null) {
      buffer.write(' ($hint)');
    }
    sentences.add(buffer.toString());

    // 2. FRP / estimated area — supporting evidence for intensity.
    if (frp > 100) {
      sentences.add(l10n.smartFrpHigh);
    }
    final areaKm2 = scanKm * trackKm;
    final hectares = (areaKm2 * 100).round();
    if (areaKm2 > 1.0) {
      sentences.add(l10n.smartAreaLarge(hectares));
    } else if (areaKm2 > 0.1) {
      sentences.add(l10n.smartAreaMedium(hectares));
    }

    // 3. NASA detection confidence.
    switch (riskTier) {
      case 'high':
        sentences.add(l10n.smartConfidenceHigh);
        break;
      case 'medium':
        sentences.add(l10n.smartConfidenceMedium);
        break;
      default:
        sentences.add(l10n.smartConfidenceLow);
    }

    // 4. Region spread risk, cross-referenced from the cached risk summary.
    final regionRisk = RiskDataCache.instance.riskForRegionKeySync(riskRegionKey);
    final regionScore = regionRisk?['general_risk_score'] as int?;
    if (regionScore != null) {
      if (regionScore >= 60) {
        sentences.add(l10n.smartSpreadDangerous);
      } else if (regionScore >= 30) {
        sentences.add(l10n.smartSpreadModerate);
      } else {
        sentences.add(l10n.smartSpreadLow);
      }
    }

    // 5. Time since detection.
    final detectedAt = detectionDateTimeUtc;
    if (detectedAt != null) {
      final diff = DateTime.now().toUtc().difference(detectedAt);
      if (diff.inHours < 1) {
        sentences.add(l10n.smartTimeJustNow(mergedSatelliteLabel));
      } else if (diff.inHours < 3) {
        sentences.add(l10n.smartTimeRecent(diff.inHours, mergedSatelliteLabel));
      } else if (diff.inHours < 12) {
        sentences.add(l10n.smartTimeOlder(diff.inHours));
      } else {
        sentences.add(l10n.smartTimeHistorical(diff.inDays));
      }
    }

    return sentences.join(' ');
  }

  DateTime? get detectionDateTimeUtc {
    final dateParts = acquisitionDate.split('-');
    if (dateParts.length != 3) return null;
    final timeStr = acquisitionTime.padLeft(4, '0');
    final hour = int.tryParse(timeStr.substring(0, 2));
    final minute = int.tryParse(timeStr.substring(2, 4));
    final year = int.tryParse(dateParts[0]);
    final month = int.tryParse(dateParts[1]);
    final day = int.tryParse(dateParts[2]);
    if (hour == null || minute == null || year == null || month == null || day == null) return null;
    return DateTime.utc(year, month, day, hour, minute);
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