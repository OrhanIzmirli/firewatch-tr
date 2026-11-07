import '../l10n/app_localizations.dart';

/// How wide a net the user wants their fire alerts cast over.
///
/// The wire values ('all' | 'region' | 'city') are what the backend stores in
/// fcm_tokens.alert_scope — keep them in sync with
/// database/migrations/001_add_notification_scope.sql.
///
/// [places] is the 1.1 "my saved places" scope, which was enforced only by
/// this device's own scans. 1.2 replaced it with tracked places (server-side
/// alerts, risk screen); the value remains so a stored 'places' can still be
/// read and migrated by AlertScopeNotifier, and is never offered or set.
enum AlertScope { all, region, city, places }

/// SharedPreferences key the chosen scope is stored under. Shared between
/// AlertScopeNotifier (writes) and FireMonitoringService (reads outside the
/// widget tree), so the two can never drift apart.
const String kAlertScopePrefsKey = 'alert_scope';

/// The scope the backend has stored for this device's token.
class ServerScope {
  final AlertScope scope;
  final String? regionKey;
  final int? cityId;
  const ServerScope({required this.scope, this.regionKey, this.cityId});
}

extension AlertScopeWire on AlertScope {
  String get wireValue {
    switch (this) {
      case AlertScope.all:
        return 'all';
      case AlertScope.region:
        return 'region';
      case AlertScope.city:
        return 'city';
      case AlertScope.places:
        return 'places';
    }
  }

  static AlertScope fromWire(String? value) {
    switch (value) {
      case 'region':
        return AlertScope.region;
      case 'city':
        return AlertScope.city;
      case 'places':
        return AlertScope.places;
      default:
        return AlertScope.all;
    }
  }
}

/// The seven region keys, identical to FirePoint's `_bboxRegionKey` output and
/// to the backend's src/utils/regions.ts. Order is display order, not the
/// matching order — the matching order lives in the bbox functions.
const List<String> kRegionKeys = <String>[
  'marmara',
  'ege',
  'akdeniz',
  'ic_anadolu',
  'karadeniz',
  'dogu_anadolu',
  'guneydogu_anadolu',
];

String regionKeyLabel(AppLocalizations l10n, String key) {
  switch (key) {
    case 'ege':
      return l10n.regionEge;
    case 'akdeniz':
      return l10n.regionAkdeniz;
    case 'marmara':
      return l10n.regionMarmara;
    case 'karadeniz':
      return l10n.regionKaradeniz;
    case 'ic_anadolu':
      return l10n.regionIcAnadolu;
    case 'dogu_anadolu':
      return l10n.regionDoguAnadolu;
    case 'guneydogu_anadolu':
      return l10n.regionGuneydoguAnadolu;
    default:
      return key;
  }
}

/// One province, as returned by GET /api/notify/cities.
class TurkeyCity {
  final int id;
  final String name;
  final String? regionKey;

  const TurkeyCity({required this.id, required this.name, this.regionKey});

  factory TurkeyCity.fromJson(Map<String, dynamic> json) {
    return TurkeyCity(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      regionKey: json['region_key'] as String?,
    );
  }
}

/// What the backend says a coordinate resolves to. This is the authoritative
/// answer — the client never derives a region key of its own for alerting.
class ResolvedLocation {
  final int? cityId;
  final String? cityName;
  final String? regionKey;
  final String? regionName;

  const ResolvedLocation({
    this.cityId,
    this.cityName,
    this.regionKey,
    this.regionName,
  });

  factory ResolvedLocation.fromJson(Map<String, dynamic> json) {
    return ResolvedLocation(
      cityId: (json['city_id'] as num?)?.toInt(),
      cityName: json['city'] as String?,
      regionKey: json['region_key'] as String?,
      regionName: json['region'] as String?,
    );
  }
}
