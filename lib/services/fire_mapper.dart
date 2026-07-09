import '../l10n/app_localizations.dart';
import '../models/fire_event.dart';
import '../models/fire_point.dart';

FireEvent convertPointToFireEvent(FirePoint point, AppLocalizations l10n) {
  // Kelvin → Celsius
  final bright = double.tryParse(point.brightness) ?? 0;
  final tempC = bright > 200 ? (bright - 273.15).toStringAsFixed(1) : bright.toStringAsFixed(1);

  // Zaman formatı
  final timeStr = point.acquisitionTime.padLeft(4, '0');
  final hour = int.tryParse(timeStr.substring(0, 2)) ?? 0;
  final minute = int.tryParse(timeStr.substring(2, 4)) ?? 0;
  final dateParts = point.acquisitionDate.split('-');
  String formattedStart = point.acquisitionDate;
  String timeAgo = point.acquisitionTime;

  if (dateParts.length == 3) {
    formattedStart = '${dateParts[2]}.${dateParts[1]}.${dateParts[0]} $hour:${minute.toString().padLeft(2, '0')}';
    try {
      final dt = DateTime.utc(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
        hour, minute,
      );
      final diff = DateTime.now().toUtc().difference(dt);
      if (diff.inMinutes < 60) {
        timeAgo = l10n.timeAgoMinutes(diff.inMinutes);
      } else if (diff.inHours < 24) {
        timeAgo = l10n.timeAgoHours(diff.inHours);
      } else {
        timeAgo = l10n.timeAgoDays(diff.inDays);
      }
    } catch (_) {}
  }

  // Konum ismi
  final cityName = point.cityName ?? point.regionDisplayName(l10n);
  final distanceStr = point.distanceKm != null
      ? l10n.mapKmAway(point.distanceKm!.toStringAsFixed(1))
      : point.locationLabelText(l10n);

  // Gerçek etkilenen alan — NASA'nın scan × track piksel boyutu alanlarından
  // (km cinsinden) hesaplanır, brightness tahmini değil.
  final areaKm2 = point.scanKm * point.trackKm;
  final hectares = (areaKm2 * 100).round();
  final affectedArea = areaKm2 > 0
      ? l10n.fireDetailAreaMeasured(hectares)
      : l10n.homeAreaInsufficientRes;

  return FireEvent(
    id: '${point.latitude}-${point.longitude}-${point.acquisitionDate}-${point.acquisitionTime}',
    title: cityName.isNotEmpty ? l10n.fireEventRegionTitle(cityName) : l10n.fireEventLiveDetectionTitle,
    city: cityName,
    district: distanceStr,
    description: point.riskReasonText(l10n),
    status: point.riskTier == 'high'
        ? l10n.fireEventStatusActive
        : point.riskTier == 'medium'
            ? l10n.fireEventStatusMonitoring
            : l10n.fireEventStatusControlled,
    riskLevel: point.riskLevelLabel(l10n),
    riskTier: point.riskTier,
    regionNameTr: point.canonicalRegionNameTr,
    updatedAt: timeAgo,
    startedAt: formattedStart,
    affectedArea: affectedArea,
    frp: point.frp,
    spreadRisk: point.riskTier == 'high'
        ? l10n.fireEventSpreadHigh
        : point.riskTier == 'medium'
            ? l10n.fireEventSpreadMedium
            : l10n.fireEventSpreadLow,
    lat: point.latitude,
    lng: point.longitude,
    smartStatus: point.smartStatus,
    recommendedActions: [
      point.recommendedActionText(l10n),
      l10n.fireEventTempLine(tempC, bright.toStringAsFixed(0)),
      l10n.fireEventSatelliteLine(point.mergedSatelliteLabel),
      l10n.fireEventCoordinateLine(point.locationLabelText(l10n)),
      l10n.fireEventDetectionLine(formattedStart),
    ],
  );
}
