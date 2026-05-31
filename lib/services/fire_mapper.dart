import '../models/fire_event.dart';
import '../models/fire_point.dart';

FireEvent convertPointToFireEvent(FirePoint point) {
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
        timeAgo = '${diff.inMinutes} dakika önce';
      } else if (diff.inHours < 24) {
        timeAgo = '${diff.inHours} saat önce';
      } else {
        timeAgo = '${diff.inDays} gün önce';
      }
    } catch (_) {}
  }

  // Konum ismi
  final cityName = point.cityName ?? point.regionName;
  final distanceStr = point.distanceKm != null
      ? '${point.distanceKm!.toStringAsFixed(1)} km uzaklıkta'
      : point.locationLabel;

  // Etkilenen alan tahmini (brightness'a göre)
  String affectedArea;
  if (bright >= 370) {
    affectedArea = 'Geniş alan (>100 hektar tahmini)';
  } else if (bright >= 330) {
    affectedArea = 'Orta alan (10-100 hektar tahmini)';
  } else if (bright >= 300) {
    affectedArea = 'Küçük alan (<10 hektar tahmini)';
  } else {
    affectedArea = 'Uydu çözünürlüğü yetersiz';
  }

  // Rüzgar — Open-Meteo koordinat bazlı açıklama
  final windStatus = 'Gerçek veri için harita üzerinde kontrol et';

  return FireEvent(
    id: '${point.latitude}-${point.longitude}-${point.acquisitionDate}-${point.acquisitionTime}',
    title: cityName.isNotEmpty ? '$cityName Bölgesi Termal Tespiti' : 'Canlı Yangın Tespiti',
    city: cityName,
    district: distanceStr,
    description: point.riskReason,
    status: point.riskLevel == 'Yüksek'
        ? 'Aktif'
        : point.riskLevel == 'Orta'
            ? 'İzleniyor'
            : 'Kontrol Altında',
    riskLevel: point.riskLevel,
    updatedAt: timeAgo,
    startedAt: formattedStart,
    affectedArea: affectedArea,
    windStatus: windStatus,
    spreadRisk: point.riskLevel == 'Yüksek'
        ? 'Yüksek — aktif izleme gerekli'
        : point.riskLevel == 'Orta'
            ? 'Orta — dikkatli takip et'
            : 'Düşük',
    lat: point.latitude,
    lng: point.longitude,
    recommendedActions: [
      point.recommendedAction,
      'Sıcaklık: $tempC°C (Termal değer: ${bright.toStringAsFixed(0)}K)',
      'Uydu: ${point.satellite}',
      'Koordinat: ${point.locationLabel}',
      'Tespit: $formattedStart',
    ],
  );
}