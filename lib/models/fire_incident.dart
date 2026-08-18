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

  /// Province name resolved server-side. Null on an older backend, in
  /// which case the map falls back to matching a nearby raw detection.
  final String? cityName;
  final String? regionKey;

  /// Which FIRMS products and satellites contributed detections, and how
  /// many each. Empty when the backend predates this field or when the raw
  /// detections have aged past the 90-day prune.
  final List<IncidentSource> sources;

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

  /// How the radiated heat is changing: 'intensifying', 'stable',
  /// 'weakening', or null when the evidence does not support a direction.
  ///
  /// 'weakening' means less heat is being radiated and NOTHING else. It is
  /// not evidence that anyone is fighting the fire — a satellite cannot see
  /// a crew, a helicopter or a firebreak — and no string in this app may
  /// suggest otherwise.
  final String? frpTrend;

  /// Later-half mean FRP divided by earlier-half mean.
  final double? frpTrendRatio;
  final int? frpTrendPasses;

  /// Largest/smallest pixel area across the passes compared. The backend only
  /// publishes a trend when this stayed below 1.5; carried here so the number
  /// behind the claim is inspectable.
  final double? frpGeometryRatio;

  final int? distinctDaysSeen;
  final double? frpMean;
  final double? frpStddev;

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
    this.cityName,
    this.regionKey,
    this.sources = const [],
    this.opticalBurntAreaHa,
    this.opticalSource,
    this.officialState,
    this.officialSource,
    this.officialSourceUrl,
    this.frpTrend,
    this.frpTrendRatio,
    this.frpTrendPasses,
    this.frpGeometryRatio,
    this.distinctDaysSeen,
    this.frpMean,
    this.frpStddev,
    this.spreadBearingDeg,
    this.spreadSpeedMh,
  });

  factory FireIncident.fromJson(Map<String, dynamic> json) {
    final satellite = (json['satellite'] as Map?)?.cast<String, dynamic>() ?? const {};
    final optical = (json['optical'] as Map?)?.cast<String, dynamic>() ?? const {};
    final official = (json['official'] as Map?)?.cast<String, dynamic>() ?? const {};
    final spread = (json['spread'] as Map?)?.cast<String, dynamic>() ?? const {};
    final trend = (json['trend'] as Map?)?.cast<String, dynamic>() ?? const {};
    final persistence =
        (json['persistence'] as Map?)?.cast<String, dynamic>() ?? const {};

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
      cityName: json['city_name'] as String?,
      sources: ((json['sources'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => IncidentSource.fromJson(e.cast<String, dynamic>()))
          .toList(),
      regionKey: json['region_key'] as String?,
      satelliteState: satellite['state'] as String? ?? 'no_recent_detection',
      hoursSinceLastDetection: _toDouble(satellite['hours_since_last_detection']) ?? 0,
      opticalBurntAreaHa: _toDouble(optical['burnt_area_ha']),
      opticalSource: optical['source'] as String?,
      officialState: official['state'] as String?,
      officialSource: official['source'] as String?,
      officialSourceUrl: official['source_url'] as String?,
      frpTrend: trend['direction'] as String?,
      frpTrendRatio: _toDouble(trend['ratio']),
      frpTrendPasses: (trend['passes'] as num?)?.toInt(),
      frpGeometryRatio: _toDouble(trend['geometry_ratio']),
      distinctDaysSeen: (persistence['distinct_days_seen'] as num?)?.toInt(),
      frpMean: _toDouble(persistence['frp_mean']),
      frpStddev: _toDouble(persistence['frp_stddev']),
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

  /// Whether this event cleared the evidence bar in [IncidentSignificance].
  bool get isSignificant => IncidentSignificance.isMet(this);

  /// Whether this event looks more like a fixed heat source than a fire.
  ///
  /// This flags; it never hides. Labelling a real fire "industrial" and
  /// removing it is worse than showing a flare stack, so the map keeps
  /// everything and the detail panel adds an observation the reader can
  /// weigh. The wording is deliberately "may be", because that is the
  /// strength of the evidence.
  ///
  /// Caveat recorded in [persistentSourceHint]: duration is censored by the
  /// ingest window, so this cannot distinguish "burned for a day" from
  /// "burns permanently". Once the cluster job records distinct_days_seen
  /// and FRP variance, this getter should be rewritten to use those instead.
  bool get looksLikeFixedSource => PersistentSourceHint.isMet(this);

  /// True only when a named official source confirmed a state. Never inferred.
  bool get hasOfficialStatus => officialState != null && officialState!.isNotEmpty;

  /// A trend is shown only when the backend published one; it withholds
  /// rather than guesses, so there is nothing to re-check here.
  bool get hasTrend => frpTrend != null && frpTrend!.isNotEmpty;

  /// Spread is published only when the backend judged the evidence sufficient.
  bool get hasSpread =>
      spreadConfidence != 'insufficient' &&
      spreadBearingDeg != null &&
      spreadSpeedMh != null;
}

/// One instrument's contribution to an incident.
class IncidentSource {
  /// FIRMS product identifier, e.g. VIIRS_SNPP_NRT.
  final String product;

  /// Platform, e.g. N (Suomi-NPP), N20, Terra, Aqua. Null in older rows.
  final String? satellite;

  final int count;

  const IncidentSource({
    required this.product,
    required this.count,
    this.satellite,
  });

  factory IncidentSource.fromJson(Map<String, dynamic> json) => IncidentSource(
        product: json['product'] as String? ?? '',
        satellite: json['satellite'] as String?,
        count: (json['count'] as num?)?.toInt() ?? 0,
      );

  /// Instrument name as a reader recognises it, derived from the product id
  /// rather than invented: FIRMS names its products after the instrument.
  String get instrument {
    final p = product.toUpperCase();
    if (p.contains('VIIRS')) return 'VIIRS';
    if (p.contains('MODIS')) return 'MODIS';
    return product.isEmpty ? '?' : product;
  }

  /// Platform label, expanded only where FIRMS' own code is unambiguous.
  String get platform {
    switch (satellite) {
      case 'N':
        return 'Suomi-NPP';
      case 'N20':
        return 'NOAA-20';
      case 'N21':
        return 'NOAA-21';
      case 'Terra':
        return 'Terra';
      case 'Aqua':
        return 'Aqua';
      default:
        return satellite ?? '';
    }
  }

  String get label {
    final p = platform;
    return p.isEmpty ? instrument : '$instrument · $p';
  }
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

/// The single place the "is this worth showing as a past fire" bar is defined.
///
/// Of the 237 live events, 149 were seen on exactly one satellite pass and
/// never again. A single pass cannot distinguish a fire from a sun-glinted
/// roof, a flare stack or a warm quarry, and listing all 227 no-longer-seen
/// events made the map unreadable while saying nothing. The bar below leaves
/// 17, of which 15 are no longer being seen.
///
/// The numbers live here and nowhere else on the client. Duplicating them
/// into a filter, a summary and a marker builder is how three surfaces end up
/// disagreeing about how many fires there were. The backend's summary query
/// mirrors them and says so; if these move, that moves too.
abstract final class IncidentSignificance {
  /// One pass is a pixel; two is a thing that was still there next time.
  static const int minOverpasses = 2;

  /// Fire radiative power.
  ///
  /// 8 MW rather than 10: at 10 the best-observed event in the live data —
  /// nine overpasses, thirty-two detections, twenty-one hours — was excluded
  /// by 0.83 MW.
  ///
  /// Raising the overpass count instead was measured and rejected. Requiring
  /// four passes admits 55 events, and most of the 41 it adds share one
  /// signature: ~24 hours of continuous burning at 1-4 MW, visible on every
  /// single pass. That is not a wildfire, it is a fixed source that never
  /// goes out — gas flares over the south-eastern oil fields. Listing those
  /// as fires would be worse than missing a real one, because they would
  /// never leave the list.
  ///
  /// Movement does not separate them either: all 29 of the persistent
  /// low-power events carry spread data, because spread is derived from
  /// centroid drift and any multi-detection cluster drifts on pixel geometry
  /// alone. Spread is therefore NOT a significance criterion.
  ///
  /// The real answer is persistence by location — the same coordinates
  /// showing heat every day for weeks is infrastructure, not a fire — and
  /// that needs a few more weeks of fire_detections history than exists
  /// today. 8 MW is the practical bar until then.
  static const double minFrpMw = 8;

  /// FIRMS' own lowest confidence tier is excluded outright.
  static const String excludedConfidenceTier = 'low';

  static bool isMet(FireIncident incident) =>
      incident.overpassCount >= minOverpasses &&
      (incident.maxFrpMw ?? 0) >= minFrpMw &&
      incident.peakConfidenceTier != excludedConfidenceTier;
}

/// When the panel offers "this may be a fixed heat source" as an observation.
///
/// It is an observation, not a filter. Nothing here removes an event from the
/// map: calling a real fire industrial and hiding it fails in the direction
/// that gets people hurt, so where the evidence is ambiguous the event is
/// shown and the ambiguity is stated.
///
/// Measured on 262 live incidents: 38 are long-lived and weak, only 3 are
/// long-lived and powerful, so the two populations barely overlap on power.
///
/// KNOWN LIMITATION. The ingest window is two days, so duration is censored:
/// the longest event in the entire feed is 34.5 h and the values pile up at
/// 24.0 h (x19) and 24.8 h (x9). A gas flare burning for a month and a
/// wildfire burning for three days both report ~24-34 h. "Duration >= 20 h"
/// therefore means "seen on two different days" and can never mean more,
/// which is why this only ever produces a hint and why the real answer is
/// distinct_days_seen and FRP variance once the cluster job records them.
abstract final class PersistentSourceHint {
  /// Long enough to have been seen across two ingest days.
  static const double minDurationHours = 20;

  /// Fires this old that are still only putting out single-digit megawatts
  /// are not behaving like fires.
  static const double maxFrpMw = 10;

  /// Overpasses per hour of duration: seen at least once every eight hours,
  /// with no long gap where cloud or smoke hid it. A real fire is usually
  /// missed on some passes.
  static const double minOverpassesPerHour = 0.125;

  static bool isMet(FireIncident incident) {
    if (incident.durationHours < minDurationHours) return false;
    if ((incident.maxFrpMw ?? 0) >= maxFrpMw) return false;
    if (incident.durationHours <= 0) return false;
    return incident.overpassCount / incident.durationHours >=
        minOverpassesPerHour;
  }
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

  /// Note the asymmetry: [active] keeps everything currently being detected,
  /// however thin the evidence, because a weak signal happening *now* is
  /// exactly the thing a person opening this app wants to see. The evidence
  /// bar only applies once nothing is being detected any more, where a
  /// one-pixel event is no longer a warning, just clutter.
  ///
  /// Nothing is deleted by this. Everything below the bar is still on the
  /// possible-fire-points layer, one tap away.
  bool matches(FireIncident incident) {
    final isActive = incident.status == IncidentStatus.activeDetection;
    switch (this) {
      case IncidentFilter.active:
        return isActive;
      case IncidentFilter.ended:
        return !isActive && incident.isSignificant;
      case IncidentFilter.all:
        return isActive || incident.isSignificant;
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
        return AppColors.textMuted;
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
