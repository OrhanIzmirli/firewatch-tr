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

  // Önce cityName, yoksa koordinat bazlı bölge
  String get regionName {
    if (cityName != null && cityName!.isNotEmpty) return cityName!;
    if (nearestRegion != null && nearestRegion!.isNotEmpty) return nearestRegion!;

    final lat = latitude;
    final lng = longitude;

    if (lng >= 26.0 && lng <= 30.5 && lat >= 36.5 && lat <= 39.5) return 'Ege Bölgesi';
    if (lng >= 29.5 && lng <= 37.0 && lat >= 36.0 && lat <= 38.5) return 'Akdeniz Bölgesi';
    if (lng >= 26.0 && lng <= 32.0 && lat >= 39.5 && lat <= 42.0) return 'Marmara Bölgesi';
    if (lat >= 40.5 && lat <= 42.2) return 'Karadeniz Bölgesi';
    if (lng >= 30.0 && lng <= 37.5 && lat >= 38.0 && lat <= 41.0) return 'İç Anadolu';
    if (lng >= 37.5 && lng <= 44.8 && lat >= 38.0 && lat <= 42.0) return 'Doğu Anadolu';
    if (lng >= 36.0 && lng <= 44.8 && lat >= 36.0 && lat <= 38.5) return 'Güneydoğu Anadolu';

    return 'Türkiye';
  }

  String get riskLevel {
    final c = confidence.toLowerCase().trim();
    if (c.contains('high') || c == 'h') return 'Yüksek';
    if (c.contains('nominal') || c == 'n') return 'Orta';
    return 'Düşük';
  }

  String get locationLabel {
    final latDir = latitude >= 0 ? 'K' : 'G';
    final lngDir = longitude >= 0 ? 'D' : 'B';
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

  String get riskReason {
    final bright = double.tryParse(brightness) ?? 0;
    switch (riskLevel) {
      case 'Yüksek':
        return bright > 0
            ? 'Termal sensör ${bright.toStringAsFixed(0)}K ısı tespit etti. Aktif yangın ihtimali yüksek, bölgeye yaklaşma.'
            : 'Yüksek güven seviyesinde termal anomali tespit edildi. Aktif yangın olabilir.';
      case 'Orta':
        return bright > 0
            ? 'Termal sensör ${bright.toStringAsFixed(0)}K ısı ölçtü. Anız yakma, tarım faaliyeti veya erken evre yangın olabilir.'
            : 'Orta düzey termal anomali. Bölge izleme altında tutulmalı.';
      default:
        return bright > 0
            ? 'Düşük ısı değeri (${bright.toStringAsFixed(0)}K). Sanayi, seracılık veya doğal ısı kaynağı olabilir.'
            : 'Düşük seviye termal aktivite. Takip önerilir.';
    }
  }

  String get generatedDescription {
    switch (riskLevel) {
      case 'Yüksek':
        return 'Yüksek yoğunluklu termal aktivite. Aktif yangın olasılığı ciddi.';
      case 'Orta':
        return 'Orta seviye ısı artışı. Bölge izleme gerektirir.';
      default:
        return 'Düşük seviye termal aktivite. Takip önerilir.';
    }
  }

  String get recommendedAction {
    switch (riskLevel) {
      case 'Yüksek':
        return 'Bölgeden uzak dur, resmi yönlendirmeleri takip et ve tahliye hazırlığını yap.';
      case 'Orta':
        return 'Gelişmeleri takip et, bölgeye gereksiz yaklaşma.';
      default:
        return 'Şu an acil aksiyon gerekmiyor, bölgeyi takip et.';
    }
  }
}