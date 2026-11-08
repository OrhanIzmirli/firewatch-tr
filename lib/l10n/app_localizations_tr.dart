// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'FireWatch TR';

  @override
  String get navHome => 'Ana Sayfa';

  @override
  String get navMap => 'Harita';

  @override
  String get navNews => 'Haberler';

  @override
  String get navAlerts => 'Uyarılar';

  @override
  String get navSettings => 'Ayarlar';

  @override
  String get commonDetail => 'Detay';

  @override
  String get commonRefresh => 'Yenile';

  @override
  String get commonViewOnMap => 'Haritada Gör';

  @override
  String get commonOpenOnMap => 'Haritada Aç';

  @override
  String get commonShare => 'Paylaş';

  @override
  String get commonCancel => 'Vazgeç';

  @override
  String get commonSave => 'Kaydet';

  @override
  String get commonLoading => 'Yükleniyor...';

  @override
  String get commonTemperature => 'Sıcaklık';

  @override
  String get commonSatellite => 'Uydu';

  @override
  String get commonCoordinate => 'Koordinat';

  @override
  String get commonWind => 'Rüzgar';

  @override
  String get commonRisk => 'Risk';

  @override
  String get commonStatus => 'Durum';

  @override
  String get commonAnonymous => 'Anonim';

  @override
  String get commonAll => 'Tümü';

  @override
  String get commonHigh => 'Yüksek';

  @override
  String get commonMedium => 'Orta';

  @override
  String get commonLow => 'Düşük';

  @override
  String get commonCritical => 'Kritik';

  @override
  String get commonEmergency => 'Acil Durum';

  @override
  String get commonTryAgain => 'Tekrar Dene';

  @override
  String get commonRetry => 'Yenile';

  @override
  String get commonDistance => 'Uzaklık';

  @override
  String get commonDetection => 'Tespit';

  @override
  String get regionEge => 'Ege';

  @override
  String get regionAkdeniz => 'Akdeniz';

  @override
  String get regionMarmara => 'Marmara';

  @override
  String get regionKaradeniz => 'Karadeniz';

  @override
  String get regionIcAnadolu => 'İç Anadolu';

  @override
  String get regionDoguAnadolu => 'Doğu Anadolu';

  @override
  String get regionGuneydoguAnadolu => 'Güneydoğu Anadolu';

  @override
  String get regionTurkiyeGeneli => 'Türkiye Geneli';

  @override
  String get timeAgoJustNow => 'Az önce';

  @override
  String timeAgoMinutes(int minutes) {
    return '$minutes dakika önce';
  }

  @override
  String timeAgoHours(int hours) {
    return '$hours saat önce';
  }

  @override
  String timeAgoDays(int days) {
    return '$days gün önce';
  }

  @override
  String get splashTagline => 'Yangınları takip edin, güvende kalın';

  @override
  String get onboardingSkip => 'Geç';

  @override
  String get onboardingNext => 'Sonraki';

  @override
  String get onboardingContinue => 'Devam Et';

  @override
  String get onboardingTitle1 => 'Aktif olayları takip edin';

  @override
  String get onboardingDesc1 =>
      'Türkiye genelindeki uydu tespitlerini tek ekranda takip edin ve durum değişikliklerini hızlıca görün.';

  @override
  String get onboardingTitle2 => 'Yakınınızdaki bölgeleri görün';

  @override
  String get onboardingDesc2 =>
      'Harita ve bölge odaklı ekranlarla size yakın olayları daha hızlı fark edin.';

  @override
  String get onboardingTitle3 => 'Güvenlik yönlendirmeleri alın';

  @override
  String get onboardingDesc3 =>
      'Risk seviyelerini inceleyin, önerilen aksiyonları görün ve gerektiğinde hızlı hareket edin.';

  @override
  String get homeLiveSummary => 'Güncel Durum Özeti';

  @override
  String get homeHeaderTitle => 'Türkiye Uydu Tespitleri';

  @override
  String get homeHeaderSubtitle =>
      'Aktif olayları takip edin, risk seviyelerini görün ve güvenlik rehberine hızlıca ulaşın.';

  @override
  String get homeNasaLiveData => 'NASA FIRMS • Uydu Verisi';

  @override
  String get homeOutsideTurkeyLocation => 'Yurt dışı konumu';

  @override
  String get homeLocationUnavailable => 'Konum alınamadı';

  @override
  String get homeLocationEmulatorTest => 'Emülatör konumu';

  @override
  String get homeRiskAnalysis => 'Risk Analizi';

  @override
  String homeSaved(int count) {
    return 'Kaydedilenler ($count)';
  }

  @override
  String get homeSafety => 'Güvenlik';

  @override
  String get homeOverview => 'Genel Bakış';

  @override
  String get homeOverviewSubtitle => 'NASA FIRMS uydu verisi';

  @override
  String homeOverviewUniqueCount(int count) {
    return 'Uydular $count ayrı konumda tespit yaptı';
  }

  @override
  String get homeTotalPoints => 'Toplam Nokta';

  @override
  String get homeHighRisk => 'Yüksek Risk';

  @override
  String get homeNominal => 'Normal';

  @override
  String get homeOverviewActiveFiresTitle => 'Güncel Uydu Tespitleri';

  @override
  String get homeOverviewActiveFiresSubtitle => 'Son 24 saatte tespit edildi';

  @override
  String get homeOverviewHighestRiskTitle => 'En Yüksek Riskli Bölge';

  @override
  String homeOverviewHighestRiskValue(String region, int score) {
    return '$region - $score puan';
  }

  @override
  String get homeOverviewHighestRiskSubtitle =>
      'Şu an Türkiye\'deki en yüksek risk';

  @override
  String get homeOverviewNearbyTitle => 'Yakındaki Uydu Tespitleri';

  @override
  String homeOverviewNearbyValueWithLocation(int count) {
    return '100 km içinde $count tespit';
  }

  @override
  String homeOverviewNearbyValueNationwide(int count) {
    return 'Türkiye genelinde $count tespit';
  }

  @override
  String get homeOverviewNearbySubtitleLocated => 'GPS konumunuza göre';

  @override
  String get homeOverviewNearbySubtitleFallback =>
      'Konum bulunamadı — ülke geneli gösteriliyor';

  @override
  String get homeOverviewNewsTitle => 'Haber Güncellemesi';

  @override
  String homeOverviewNewsValue(int count) {
    return '$count yeni haber';
  }

  @override
  String homeOverviewNewsSubtitleUpdated(String timeAgo) {
    return 'Son haber: $timeAgo';
  }

  @override
  String get homeOverviewNewsNone => 'Henüz haber yok';

  @override
  String get homeLatestNews => 'Son Haberler';

  @override
  String get homeLatestNewsSubtitle => 'Öne çıkan gelişmeler';

  @override
  String homeBreakingCount(int count) {
    return '$count son dakika';
  }

  @override
  String get homeNewsLoading => 'Haber yükleniyor...';

  @override
  String get homeActiveThermalPoints => 'Güncel Uydu Tespitleri';

  @override
  String get homeActiveThermalSubtitle => 'NASA uydu verisi';

  @override
  String get homeMap => 'Harita';

  @override
  String get homeFilterHighRisk => 'Yüksek Risk';

  @override
  String get homeFilterMediumRisk => 'Orta Risk';

  @override
  String get homeSearchHint => 'Şehir veya bölge ara...';

  @override
  String get homeNoActiveFires => 'Uydular şu an güncel bir tespit bildirmedi.';

  @override
  String homeFireRegionTitle(String region) {
    return '$region Bölgesi';
  }

  @override
  String get homeEstimatedArea => 'Tahmini Alan';

  @override
  String get homeAreaOver100Ha => '100 hektardan fazla';

  @override
  String get homeArea10to100Ha => '10–100 hektar';

  @override
  String get homeAreaUnder10Ha => '10 hektardan az';

  @override
  String get homeAreaInsufficientRes => 'Uydu çözünürlüğü yetersiz';

  @override
  String get mapFetchError => 'Yangın verileri alınamadı.';

  @override
  String get mapTitle => 'Uydu Tespit Haritası';

  @override
  String get mapTitleEvents => 'Yangın Haritası';

  @override
  String get mapTitleDetections => 'Uydu Tespit Haritası';

  @override
  String get mapLiveMap => 'Güncel Harita';

  @override
  String get mapConfidenceFilterActive =>
      'Yalnızca yüksek/nominal güvenilirlikli tespitler gösteriliyor';

  @override
  String get mapConfidenceFilterClear => 'Temizle';

  @override
  String get mapHeaderTitle => 'Türkiye Geneli Yangın Görünümü';

  @override
  String get mapHeaderSubtitle =>
      'NASA FIRMS uydu verisi. Olaylar ve ham tespitler.';

  @override
  String get mapArea => 'Harita Alanı';

  @override
  String get mapAreaSubtitle => 'NASA FIRMS işaret görünümü';

  @override
  String get mapGoToMe => 'Bana Git';

  @override
  String get mapNearbyFires => 'Yakınımdaki Uydu Tespitleri';

  @override
  String get mapNearbyFiresSubtitle => 'Konumunuza en yakın güncel tespitler';

  @override
  String get mapReport => 'Raporla';

  @override
  String mapKmAway(String distance) {
    return '$distance km uzaklıkta';
  }

  @override
  String get fireDetailTitle => 'Tespit Detayı';

  @override
  String fireDetailLastUpdate(String time) {
    return 'Son güncelleme: $time';
  }

  @override
  String get fireDetailKeyMetrics => 'Temel Metrikler';

  @override
  String get fireDetailEventInfo => 'Olay Bilgileri';

  @override
  String get fireDetailCity => 'Şehir';

  @override
  String get fireDetailDistrict => 'İlçe';

  @override
  String get fireDetailStarted => 'Başlangıç';

  @override
  String get fireDetailSpreadRisk => 'Yayılım Riski';

  @override
  String get fireDetailAffectedArea => 'Etkilenen Alan';

  @override
  String get fireDetailRecommendedActions => 'Önerilen Aksiyonlar';

  @override
  String get fireDetailAddedToWatchlist => 'Olay watchlist listesine eklendi.';

  @override
  String get fireDetailRemovedFromWatchlist =>
      'Olay watchlist listesinden kaldırıldı.';

  @override
  String get fireDetailSaved => 'Kaydedildi';

  @override
  String get fireDetailSaveToWatchlist => 'Watchlist\'e Kaydet';

  @override
  String get fireDetailRelatedNews => 'İlgili Haberler';

  @override
  String get fireDetailNoNewsFound => 'Haber bulunamadı';

  @override
  String get notificationsTitle => 'Bildirimler';

  @override
  String notificationsNewAlerts(int count) {
    return '$count yeni uyarı';
  }

  @override
  String get notificationsUpToDate => 'Güncel';

  @override
  String get notificationsFeedTitle => 'Olay Bildirim Akışı';

  @override
  String get notificationsFeedSubtitle =>
      'Yakındaki olaylar, durum değişimleri ve saha güncellemelerini tek akışta takip edin.';

  @override
  String get notificationsTools => 'Bildirim Araçları';

  @override
  String get notificationsToolsSubtitle =>
      'İzinleri ve otomatik uydu tespiti takibini yönetin';

  @override
  String get notificationsPermissionGranted => 'İzin Var';

  @override
  String get notificationsPermissionDenied => 'İzin Yok';

  @override
  String get notificationsMonitoringOn => 'Takip Açık';

  @override
  String get notificationsMonitoringOff => 'Takip Kapalı';

  @override
  String get notificationsRequestPermission => 'Bildirim İzni İste';

  @override
  String get notificationsSendTest => 'Test Bildirimi Gönder';

  @override
  String get notificationsScanNow => 'Şimdi Tara';

  @override
  String get notificationsStartMonitoring => 'Otomatik Taramayı Başlat';

  @override
  String get notificationsStopMonitoring => 'Otomatik Taramayı Durdur';

  @override
  String get notificationsBackgroundTitle => 'Arka Planda Takip';

  @override
  String get notificationsBackgroundSubtitle =>
      'Uygulama kapalıyken uydu tespitlerini aralıklarla kontrol edin. Android bu kontrolleri geciktirebilir, uydu verisi de saatlerce gecikebilir.';

  @override
  String get notificationsEnableBackground => 'Arka Plan Takibini Aç';

  @override
  String get notificationsDisableBackground => 'Arka Plan Takibini Kapat';

  @override
  String get backgroundLocationDialogTitle => 'Arka Plan Konum İzni';

  @override
  String get backgroundLocationDialogBody =>
      'FireWatch TR, uygulama kapalıyken de yakınınızdaki yangınları kontrol edip sizi uyarabilmek için konumunuza arka planda erişim istiyor. Bu kontroller telefonunuzda yapılır; bu sırada konumunuz sunucuya gönderilmez. Bu izni vermezseniz uygulama sadece açıkken tarama yapabilir. Sistem izin ekranında \"Her zaman izin ver\" seçeneğini seçmeniz gerekir.';

  @override
  String get backgroundLocationDialogConfirm => 'Devam Et';

  @override
  String get backgroundLocationPermissionDenied =>
      'Arka plan konum izni verilmedi. Arka plan takibi açılamadı.';

  @override
  String get backgroundMonitoringEnabled => 'Arka plan takibi açıldı.';

  @override
  String get backgroundMonitoringDisabled => 'Arka plan takibi kapatıldı.';

  @override
  String get notificationsNearbyLiveFires => 'Yakındaki Uydu Tespitleri';

  @override
  String get notificationsNearbyLiveFiresSubtitle =>
      'Konumunuza 50 km içinde bulunan noktalar';

  @override
  String notificationsDistanceAndTime(String distance, String timeAgo) {
    return '$distance km uzaklıkta • $timeAgo';
  }

  @override
  String notificationsRiskLabel(String level) {
    return 'Risk: $level';
  }

  @override
  String get notificationsRecentAlerts => 'Son Uyarılar';

  @override
  String notificationsHighRiskCount(int count) {
    return '$count yüksek riskli nokta';
  }

  @override
  String notificationsUnreadCount(int count) {
    return '$count okunmadı';
  }

  @override
  String get notificationsNoHighRisk =>
      'Uydular şu an güçlü bir tespit bildirmedi.';

  @override
  String get notificationsHighRiskDetectionTitle => 'Güçlü Uydu Tespiti';

  @override
  String notificationsHighRiskDetectionBody(String region, String temp) {
    return 'Uydular $region bölgesinde güçlü bir ısı tespit etti (${temp}K). Doğrulanmadı.';
  }

  @override
  String get watchlistTitle => 'Kaydedilenler';

  @override
  String get watchlistClear => 'Temizle';

  @override
  String get watchlistNoRecords => 'Kayıt Yok';

  @override
  String watchlistRecordCount(int count) {
    return '$count kayıt';
  }

  @override
  String get watchlistHeading => 'Watchlist';

  @override
  String get watchlistHeadingSubtitle =>
      'Takip etmek istediğiniz uydu tespitlerini burada saklayabilirsiniz.';

  @override
  String get watchlistEmptyTitle => 'Henüz kaydedilmiş olay yok';

  @override
  String get watchlistEmptySubtitle =>
      'Tespit detay ekranındaki Kaydet butonunu kullanarak ekleyebilirsiniz.';

  @override
  String get watchlistSavedPoints => 'Kaydedilen Noktalar';

  @override
  String watchlistSavedPointsSubtitle(int count) {
    return '$count uydu tespiti takipte';
  }

  @override
  String watchlistSyncingTitle(int count) {
    return '$count kaydedilmiş uydu tespiti var.';
  }

  @override
  String get watchlistSyncingSubtitle =>
      'NASA verisi yenileniyor olabilir. Kaydedilen noktalar uydu güncellemesinde değişebilir.';

  @override
  String emergencyShareLocationText(String url, String lat, String lng) {
    return 'Acil Durum - Konumum:\n$url\n\nLat: $lat\nLng: $lng\n\nFireWatch TR ile paylaşıldı.';
  }

  @override
  String get emergencyShareLocationSubject => 'Acil Konum Paylaşımı';

  @override
  String get emergencyShareFallbackText =>
      'Acil Durum bildirimi - FireWatch TR';

  @override
  String get emergencyTitle => 'Acil Durum';

  @override
  String get emergencyPrepCenter => 'Acil Hazırlık Merkezi';

  @override
  String get emergencyQuickToolsTitle => 'Hızlı Müdahale Araçları';

  @override
  String get emergencyQuickToolsSubtitle =>
      'Acil durum anında hızlı erişim, temel hazırlık ve kritik yönlendirmeleri tek ekranda toplayın.';

  @override
  String get emergencyStayReady => 'Hazır Kalın';

  @override
  String get emergencyStayReadyNote =>
      'Tahliye ve iletişim adımlarını önceden planlamak zaman kazandırır.';

  @override
  String get emergencyQuickActions => 'Hızlı Eylemler';

  @override
  String get emergencyQuickActionsSubtitle => 'Tek dokunuşta kritik aksiyonlar';

  @override
  String get emergencyCall112 => '112 Ara';

  @override
  String get emergencyCall112Subtitle => 'Genel acil yardım hattı';

  @override
  String get emergencyCall177 => '177 Orman';

  @override
  String get emergencyCall177Subtitle => 'Yangın bildirimi hattı';

  @override
  String get emergencyShareLocation => 'Konum Paylaş';

  @override
  String get emergencyShareLocationSubtitle => 'Yakınlarınıza yer bildirin';

  @override
  String get emergencyEvacuationPlan => 'Tahliye Planı';

  @override
  String get emergencyEvacuationPlanSubtitle =>
      'Çıkış adımlarını gözden geçirin';

  @override
  String get emergencyContactLines => 'Acil İletişim Hatları';

  @override
  String get emergencyContactLinesSubtitle => 'Temel numaraları hazır tutun';

  @override
  String get emergencyCallCenter => 'Acil Çağrı Merkezi';

  @override
  String get emergencyCallCenterSubtitle =>
      'Sağlık, itfaiye, polis ve genel acil durum';

  @override
  String get emergencyForestLine => 'Orman Yangını Hattı';

  @override
  String get emergencyForestLineSubtitle =>
      'Orman ve yangın bildirimi için hızlı erişim';

  @override
  String get emergencyAfad => 'AFAD Acil';

  @override
  String get emergencyAfadSubtitle => 'Afet ve acil durum yönetimi';

  @override
  String get emergencyBag => 'Tahliye Çantası';

  @override
  String get emergencyBagSubtitle => 'Hazır bulunsun';

  @override
  String get emergencyBagDocs => 'Kimlik ve temel belgeler';

  @override
  String get emergencyBagDocsSubtitle =>
      'Kimlik, önemli evrak ve telefonunuzu tek yerde tutun.';

  @override
  String get emergencyBagSupplies => 'Su, ilaç ve şarj ekipmanı';

  @override
  String get emergencyBagSuppliesSubtitle =>
      'Kısa süreli tahliyede kritik olacak temel ihtiyaçlar.';

  @override
  String get emergencyBagMeetingPoint => 'Yakınlarla buluşma noktası';

  @override
  String get emergencyBagMeetingPointSubtitle =>
      'Ayrı düşme ihtimaline karşı önceden karar verin.';

  @override
  String get emergencyCommNote => 'İletişim Notu';

  @override
  String get emergencyCommNoteSubtitle => 'Panik anında kısa hareket planı';

  @override
  String get emergencyStep1 => '1. Resmi uyarıları doğrulayın';

  @override
  String get emergencyStep2 => '2. Yakınlarınızı kısa mesajla haberdar edin';

  @override
  String get emergencyStep3 =>
      '3. Gerekliyse temel çantanızı alın ve güvenli çıkış rotasına yönelin';

  @override
  String get safetyGuideTitle => 'Güvenlik Rehberi';

  @override
  String get safetyGuideEmergencyInfo => 'Acil Durum Bilgisi';

  @override
  String get safetyGuideCenterTitle => 'Yangın Güvenlik Merkezi';

  @override
  String get safetyGuideCenterSubtitle =>
      'Yangın sırasında ne yapacağınızı hızlıca görmek, tahliye mantığını anlamak ve doğru adımları takip etmek için hazırlanmış rehber ekranı.';

  @override
  String get safetyGuideQuickActions => 'Hızlı Aksiyonlar';

  @override
  String get safetyGuideQuickActionsSubtitle =>
      'İlk bakışta kritik davranışlar';

  @override
  String get safetyGuideReadyEvacuate => 'Tahliyeye Hazır Olun';

  @override
  String get safetyGuideReadyEvacuateSubtitle => 'Çıkış planını netleştirin';

  @override
  String get safetyGuideTakeSmokeSeriously => 'Dumanı Ciddiye Alın';

  @override
  String get safetyGuideTakeSmokeSeriouslySubtitle =>
      'Kapalı alana geçin, maske kullanın';

  @override
  String get safetyGuideFollowOfficials => 'Yetkili Duyuruları İzleyin';

  @override
  String get safetyGuideFollowOfficialsSubtitle =>
      'Resmi kaynakları takip edin';

  @override
  String get safetyGuideDontDelay => 'Geç Kalmayın';

  @override
  String get safetyGuideDontDelaySubtitle => 'Tahliye çağrısını bekletmeyin';

  @override
  String get safetyGuideChecklist => 'Acil Kontrol Listesi';

  @override
  String get safetyGuideChecklistSubtitle => 'Yangın anında temel adımlar';

  @override
  String get safetyGuideChecklist1Title =>
      'Kimlik, telefon ve şarj aletini hazır tutun';

  @override
  String get safetyGuideChecklist1Desc =>
      'Zorunlu temel eşyaları tek yerde toplayın.';

  @override
  String get safetyGuideChecklist2Title =>
      'Kapı ve pencere durumunu kontrol edin';

  @override
  String get safetyGuideChecklist2Desc =>
      'Duman girişini azaltmak için açık alanları gözden geçirin.';

  @override
  String get safetyGuideChecklist3Title =>
      'Aile / yakınlarınızla buluşma planı belirleyin';

  @override
  String get safetyGuideChecklist3Desc =>
      'Ayrı düşerseniz nerede buluşacağınızı önceden bilin.';

  @override
  String get safetyGuideChecklist4Title => 'Resmi tahliye rotasını takip edin';

  @override
  String get safetyGuideChecklist4Desc =>
      'Kendi başınıza riskli güzergah uydurmayın.';

  @override
  String get safetyGuideDetailedGuide => 'Detaylı Rehber';

  @override
  String get safetyGuideDetailedGuideSubtitle =>
      'Senaryoya göre açılır bilgi kartları';

  @override
  String get safetyGuideAtHomeTitle => 'Evdeyseniz ne yapmalısınız?';

  @override
  String get safetyGuideAtHome1 =>
      'Duman yoğunluğu varsa kapı ve pencereleri kapalı tutun.';

  @override
  String get safetyGuideAtHome2 =>
      'Elektrik, gaz ve hızlı çıkış güzergahını kontrol edin.';

  @override
  String get safetyGuideAtHome3 =>
      'Tahliye çağrısı varsa eşyaları toplamaya çalışmayın, çıkışa odaklanın.';

  @override
  String get safetyGuideAtHome4 =>
      'Evcil hayvanları mümkünse hızlıca güvenli taşıma düzenine alın.';

  @override
  String get safetyGuideInCarTitle => 'Araçtayken ne yapmalısınız?';

  @override
  String get safetyGuideInCar1 => 'Yoğun duman içinden geçmeye çalışmayın.';

  @override
  String get safetyGuideInCar2 =>
      'Mümkünse güvenli açık alana veya yerleşim merkezine yönelin.';

  @override
  String get safetyGuideInCar3 =>
      'Aracı kuru otların ve ağaç altlarının yanında bırakmayın.';

  @override
  String get safetyGuideInCar4 =>
      'Resmi yönlendirme varsa navigasyondan değil, duyurudan ilerleyin.';

  @override
  String get safetyGuideOutsideTitle => 'Dışarıdaysanız ne yapmalısınız?';

  @override
  String get safetyGuideOutside1 =>
      'Rüzgar yönünü gözlemleyin ve yangının önüne geçmeyin.';

  @override
  String get safetyGuideOutside2 =>
      'Yüksek bitki örtüsünden ve dar vadilerden uzaklaşın.';

  @override
  String get safetyGuideOutside3 =>
      'Topluluk halinde hareket ediyorsanız dağılmadan ilerleyin.';

  @override
  String get safetyGuideOutside4 =>
      'Acil durumda açık, çıplak ve yanıcı olmayan alana çıkın.';

  @override
  String get safetyGuideEvacOrderTitle =>
      'Tahliye emri geldiyse ne yapmalısınız?';

  @override
  String get safetyGuideEvacOrder1 =>
      'Emri geciktirmeyin, \"biraz daha bekleyeyim\" demeyin.';

  @override
  String get safetyGuideEvacOrder2 =>
      'Sadece temel eşyaları alın ve çıkışa odaklanın.';

  @override
  String get safetyGuideEvacOrder3 =>
      'Yakınlarınızı tek tek arayıp vakit kaybetmeyin, önceden plan kullanın.';

  @override
  String get safetyGuideEvacOrder4 =>
      'Yetkililerin toplama alanı duyurusunu takip edin.';

  @override
  String get safetyGuideEmergencyNumbers => 'Acil Numaralar';

  @override
  String get safetyGuideEmergencyNumbersSubtitle =>
      'Hızlı erişim için not düşün';

  @override
  String get safetyGuideCallCenterSubtitle => 'Genel acil durum hattı';

  @override
  String get safetyGuideForestNotice => 'Orman Yangını Bildirimi';

  @override
  String get safetyGuideForestNoticeSubtitle => 'Yangın ve orman hattı';

  @override
  String get safetyGuideAfadLocal => 'AFAD / Yerel Yönlendirme';

  @override
  String get safetyGuideAfadLocalNumber => 'Yerel duyuruları takip edin';

  @override
  String get safetyGuideAfadLocalSubtitle =>
      'Bölgesel anons ve yönlendirme önemli';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get settingsPreferences => 'Tercihler';

  @override
  String get settingsAppSettings => 'Uygulama Ayarları';

  @override
  String get settingsAppSettingsSubtitle =>
      'Bildirimleri, konum tabanlı uyarıları ve uygulama davranışını buradan özelleştirin.';

  @override
  String get settingsNotifications => 'Bildirimler';

  @override
  String get settingsNotificationsSubtitle => 'Uyarı tercihlerini yönetin';

  @override
  String get settingsPushNotifications => 'Push Bildirimleri';

  @override
  String get settingsPushNotificationsSubtitle =>
      'Yeni olaylar ve önemli değişiklikler için bildirim alın';

  @override
  String get settingsNearbyAlerts => 'Yakındaki Olay Uyarıları';

  @override
  String get settingsNearbyAlertsSubtitle =>
      'Konumunuza yakın bölgelerde olay varsa öncelikli gösterin';

  @override
  String get settingsAppBehavior => 'Uygulama Davranışı';

  @override
  String get settingsAppBehaviorSubtitle => 'Görünüm ve yenileme sıklığı';

  @override
  String get settingsDarkMode => 'Koyu Tema';

  @override
  String get settingsDarkModeSubtitle => 'Premium koyu görünümü aktif tutun';

  @override
  String get settingsRefreshInterval => 'Veri Yenileme Aralığı';

  @override
  String get settingsRefreshIntervalSubtitle =>
      'Saha verilerinin ne sıklıkla yenileneceğini seçin';

  @override
  String get settingsLanguage => 'Dil';

  @override
  String get settingsLanguageSubtitle => 'Uygulama dilini seçin';

  @override
  String get settingsLanguageTurkish => 'Türkçe';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get dataSourcesTitle => 'Veri kaynakları';

  @override
  String get dataSourcesEntry => 'Veri kaynakları';

  @override
  String get dataSourcesEntrySubtitle =>
      'Rakamlar nereden geliyor, neyi ifade etmiyor';

  @override
  String get dataSourcesSatelliteTitle => 'Uydu tespitleri — ölçülen';

  @override
  String get dataSourcesSatelliteBody =>
      'NASA FIRMS. VIIRS (NOAA-20, NOAA-21; Suomi-NPP 2 Kasım 2026\'da veri vermeyi bıraktı) ve MODIS (Terra, Aqua). Uydular gün içinde birkaç kez geçer. Her tespit bir sıcak pikseldir: konum, ışıma gücü (FRP, megawatt), parlaklık sıcaklığı ve NASA\'nın güvenilirlik derecesi ölçülen değerlerdir. Bir olayın panelinde hangi ürünün kaç tespit verdiğini görebilirsiniz.';

  @override
  String get dataSourcesGroupingTitle => 'Olaylar — hesaplanan';

  @override
  String get dataSourcesGroupingBody =>
      'Aynı yangının pikselleri geçişler boyunca 1,2 km yarıçapta kümelenip tek bir olaya dönüştürülür. Süre, geçiş sayısı ve tepe güç bu gruplamadan gelir. Süre iki günlük veri penceresiyle sınırlıdır; bu yüzden her yerde \"en az\" diye yazılır — bir aydır yanan bir kaynak da yaklaşık bir gün gösterir.';

  @override
  String get dataSourcesDerivedTitle => 'Türetilen — ölçüm değil';

  @override
  String get dataSourcesDerivedBody =>
      'Yayılma yönü ve hızı, tespit deseninin merkezindeki kaymadan hesaplanır; yangının gerçek ilerleyişi farklı olabilir. \"Tespit pikseli ~N hektar\" uydunun çözünürlüğüdür, yanan alan değildir: ısı kaynağı o pikselin içindedir, gerçek boyutu bilinmiyor. Bu rakam uydunun bakış açısına göre büyür, yangına göre değil.';

  @override
  String get dataSourcesNotKnownTitle => 'Bilinmeyen';

  @override
  String get dataSourcesNotKnownBody =>
      'Bir yangının söndüğü, kontrol altına alındığı veya güvenli olduğu uydudan çıkarılamaz. Uydu bulut ve duman altını göremez; tespit olmaması yalnızca uydunun görmediği anlamına gelir. Bu uygulama böyle bir iddiada bulunmaz — yalnızca resmi bir kaynak doğrularsa, kaynağıyla birlikte gösterilir.';

  @override
  String get dataSourcesWeatherTitle => 'Bölgesel risk — ayrı bir kaynak';

  @override
  String get dataSourcesWeatherBody =>
      'Risk skorları hava durumu verisinden bölge genelinde hesaplanır. Tek bir yangına ait ölçüm değildir; o yangının nasıl davranacağını söylemez. Hava verisi Open-Meteo\'dan gelir (CC BY 4.0); Open-Meteo yanıt vermediğinde Norveç Meteoroloji Enstitüsü MET Norway\'in Locationforecast verisi kullanılır (NLOD 2.0 / CC BY 4.0). Sıcaklık, nem ve rüzgar iki kaynakta da aynı anlama gelir.';

  @override
  String get dataSourcesWeatherOpenMeteoCredit =>
      'Weather data by Open-Meteo.com';

  @override
  String get dataSourcesWeatherMetCredit => 'Data from MET Norway';

  @override
  String get dataSourcesPlacesTitle => 'Yer verisi — il ve ilçe sınırları';

  @override
  String get dataSourcesPlacesBody =>
      'Bölge seçimindeki il ve ilçe listesi, merkezleri ve sınır kutuları uygulamaya gömülüdür; ağdan çekilmez. İdari sınır ve yer verisi © OpenStreetMap katkıcıları, Açık Veri Tabanı Lisansı (ODbL) altındadır; adlar ve il üyeliği resmî il/ilçe listesiyle eşleştirilmiştir. Bu veri harita yakınlaştırma ve bildirim kapsamı içindir; yangın verisi değildir. Adres ve mahalle aramaları OpenStreetMap Nominatim ile yapılır; yazdığınız metin saklanmaz, sonuçlar metnin geri çevrilemez özetiyle en fazla 7 gün önbellekte tutulur.';

  @override
  String get dataSourcesFwiTitle =>
      'Copernicus yangın tehlike indeksi (FWI) — ayrı bir kaynak';

  @override
  String get dataSourcesFwiBody =>
      'Haritadaki FWI (Copernicus) katmanı Copernicus EFFIS\'in Yangın Hava Endeksi\'ni (FWI) gösterir. FWI sıcaklık, nem, rüzgar ve yağıştan hesaplanan bir tehlike göstergesidir: hava koşullarının bir yangını ne kadar besleyeceğini söyler, bir yangın olduğunu söylemez. Veri ECMWF\'nin küresel hava modelinden gelir ve bugün dahil 10 güne kadar (9 gün ileriye) tahmin sunar; günün model koşusu yayımlanana dek son gün boş kalabilir. Uydu tespitlerinden tamamen ayrı bir kaynaktır; herhangi bir yangına ait ölçüm değildir. Veri: © European Union, Copernicus EFFIS (CC BY 4.0). FireWatch risk puanından ayrıdır ve puana katılmaz.';

  @override
  String get settingsAppInfo => 'Uygulama Bilgisi';

  @override
  String get settingsAppInfoSubtitle => 'Sürüm ve ürün özeti';

  @override
  String get settingsInfoApp => 'Uygulama';

  @override
  String get settingsInfoVersion => 'Sürüm';

  @override
  String get settingsInfoPlatform => 'Platform';

  @override
  String get settingsInfoPlatformValue => 'Flutter / Android';

  @override
  String get settingsInfoPurpose => 'Amaç';

  @override
  String get settingsInfoPurposeValue => 'Yangın odaklı afet takibi';

  @override
  String get settingsFooterNote =>
      'Tercihleriniz cihazınızda saklanır ve uygulamayı her açtığınızda otomatik olarak uygulanır.';

  @override
  String get settingsLegal => 'Yasal';

  @override
  String get settingsPrivacyPolicy => 'Gizlilik Politikası';

  @override
  String get settingsTermsOfService => 'Kullanım Koşulları';

  @override
  String get settingsLinkOpenFailed =>
      'Bağlantı açılamadı. Lütfen tekrar deneyin.';

  @override
  String get riskTitle => 'Risk Analizi';

  @override
  String get riskLiveView => 'Güncel Risk Görünümü';

  @override
  String get riskSummaryTitle => 'Türkiye Yangın Risk Özeti';

  @override
  String get riskSummarySubtitle =>
      'Open-Meteo / MET Norway hava verisi ve NASA FIRMS uydu tespitleriyle yaklaşık 3 saatte bir hesaplanır. Her bölgenin havası tek bir temsilî noktadan alınır.';

  @override
  String riskHighestRisk(String region, int score) {
    return 'En yüksek risk: $region ($score/100)';
  }

  @override
  String get riskDataLoading => 'Veri yükleniyor...';

  @override
  String get riskKeyIndicators => 'Ana Göstergeler';

  @override
  String get riskOverviewHighestTitle => 'En Yüksek Risk';

  @override
  String get riskOverviewHighestSubtitle => 'Bölge detayı için dokunun';

  @override
  String get riskOverviewLowestTitle => 'En Düşük Risk';

  @override
  String get riskOverviewLowestSubtitle => 'Şu an en güvenli bölge';

  @override
  String get riskOverviewAvgTitle => 'Türkiye Ortalaması';

  @override
  String get riskOverviewAvgSubtitle => 'Tüm bölgelerde, 100 üzerinden';

  @override
  String get riskOverviewTrendTitle => 'Trend';

  @override
  String get riskOverviewTrendImproving => 'İyileşiyor';

  @override
  String get riskOverviewTrendWorsening => 'Kötüleşiyor';

  @override
  String get riskOverviewTrendStable => 'Sabit';

  @override
  String get riskOverviewTrendNoData => 'Veri yok';

  @override
  String riskOverviewTrendSubtitle(String delta) {
    return 'Son güncellemeden bu yana $delta puan değişim';
  }

  @override
  String get riskOverviewTrendNoDataSubtitle => 'Henüz yeterli geçmiş veri yok';

  @override
  String get riskTurkeyAverage => 'Türkiye ortalaması';

  @override
  String get riskGeneralRisk => 'Genel Risk';

  @override
  String get riskOutOf100 => '100 üzerinden';

  @override
  String get riskWindIncreasesSpread => 'Yayılımı artırıyor';

  @override
  String get riskWindNormal => 'Normal seviye';

  @override
  String get riskHumidity => 'Nem';

  @override
  String get riskHumidityLow => 'Düşük nem';

  @override
  String get riskHumidityMedium => 'Orta nem';

  @override
  String get riskHumidityHigh => 'Yüksek nem';

  @override
  String get riskTempCritical => 'Kritik seviye';

  @override
  String get riskTempNormal => 'Normal';

  @override
  String get riskRegionalDistribution => 'Bölgesel Risk Dağılımı';

  @override
  String get riskRegionalDistributionSubtitle => 'Güncel bölge skorları';

  @override
  String get riskScore => 'Risk Skoru';

  @override
  String get riskRegionDetails => 'Bölge Detayları';

  @override
  String get riskRegionDetailsSubtitle => 'Gerçek hava verisi';

  @override
  String riskScoreOutOf100(int score) {
    return 'Risk skoru: $score/100';
  }

  @override
  String get riskEnvironmentalFactors => 'Çevresel Faktörler';

  @override
  String get riskDrynessIndex => 'Kuruluk göstergesi';

  @override
  String get riskDrynessVeryHigh => 'Çok yüksek';

  @override
  String get riskWindPressure => 'Rüzgar Baskısı';

  @override
  String get riskVegetationDensity => 'Bitki baskısı';

  @override
  String get riskVegetationMediumHigh => 'Orta - Yüksek';

  @override
  String get riskHumidityLevel => 'Nem Seviyesi';

  @override
  String riskNoteHighTemp(int temp) {
    return 'Yüksek sıcaklık ($temp°C)';
  }

  @override
  String riskNoteMildTemp(int temp) {
    return 'Ilık hava ($temp°C)';
  }

  @override
  String riskNoteCoolTemp(int temp) {
    return 'Serin hava ($temp°C)';
  }

  @override
  String riskNoteLowHumidity(int hum) {
    return 'Düşük nem (%$hum)';
  }

  @override
  String riskNoteMediumHumidity(int hum) {
    return 'Orta nem (%$hum)';
  }

  @override
  String riskNoteHighHumidity(int hum) {
    return 'Yüksek nem (%$hum)';
  }

  @override
  String riskNoteStrongWind(int wind) {
    return 'Güçlü rüzgâr ($wind km/h)';
  }

  @override
  String riskNoteMediumWind(int wind) {
    return 'Orta rüzgâr ($wind km/h)';
  }

  @override
  String get newsTitle => 'Haberler';

  @override
  String get newsLiveFeed => 'Haber Akışı';

  @override
  String get newsCenterTitle => 'Yangın Haber Merkezi';

  @override
  String get newsCenterSubtitle => 'Yangınla ilgili son gelişmeler.';

  @override
  String get newsFeatured => 'Öne Çıkan Gelişme';

  @override
  String get newsFeaturedSubtitle => 'Bugünün dikkat çeken başlığı';

  @override
  String get newsCategories => 'Kategoriler';

  @override
  String get newsCategoriesSubtitle => 'Akışı filtreleyin';

  @override
  String get newsCategoryRisk => 'Risk';

  @override
  String get newsCategoryOperation => 'Operasyon';

  @override
  String get newsCategorySafety => 'Güvenlik';

  @override
  String get newsCategoryUpdate => 'Güncelleme';

  @override
  String get newsContentCategoryEvacuation => 'Tahliye';

  @override
  String get newsContentCategoryResponse => 'Müdahale';

  @override
  String get newsContentCategoryWarning => 'Uyarı';

  @override
  String get newsContentCategoryEmergency => 'Acil';

  @override
  String get newsContentCategoryWeather => 'Hava Durumu';

  @override
  String get newsContentCategoryForest => 'Orman';

  @override
  String get newsContentCategoryNews => 'Haber';

  @override
  String get newsRiskCritical => 'KRİTİK';

  @override
  String get newsRiskActive => 'AKTİF';

  @override
  String get newsRiskMonitoring => 'İZLENİYOR';

  @override
  String get newsRiskInfo => 'BİLGİ';

  @override
  String get newsBreakingBadge => 'Son Dakika';

  @override
  String get newsEnglishBannerText =>
      'Herhangi bir haberi İngilizceye çevirmek için dokunun';

  @override
  String get newsTranslateCardButton => 'Çevir';

  @override
  String get newsContentFiltersTitle => 'Durum Filtreleri';

  @override
  String get newsContentFiltersSubtitle => 'Neler olduğuna göre filtreleyin';

  @override
  String get newsFilterMyRegion => 'Bölgem';

  @override
  String get newsLatest => 'Son Haberler';

  @override
  String newsRecordsFound(int count) {
    return '$count kayıt bulundu';
  }

  @override
  String get newsFetchFailed => 'Haberler yüklenemedi';

  @override
  String get newsNoneInCategory => 'Bu filtreyle eşleşen haber yok.';

  @override
  String get reportPanelLocationServiceOff =>
      'Konum servisi kapalı. Lütfen açın.';

  @override
  String get reportPanelLocationPermissionDenied => 'Konum izni verilmedi.';

  @override
  String reportPanelLocationError(String error) {
    return 'Konum alınamadı: $error';
  }

  @override
  String get reportPanelNeedLocationFirst => 'Lütfen önce konumunuzu alın.';

  @override
  String get reportPanelSmokeObserved => 'Yoğun duman gözlemlendi';

  @override
  String get reportPanelStrongWindPresent => 'Güçlü rüzgar mevcut';

  @override
  String get reportPanelNearSettlementNote => 'Yerleşim alanına yakın';

  @override
  String reportPanelRiskLevelLine(String level) {
    return 'Risk seviyesi: $level';
  }

  @override
  String reportPanelCityFireReport(String city) {
    return '$city yangın bildirimi';
  }

  @override
  String get reportPanelFireReport => 'Yangın bildirimi';

  @override
  String get reportPanelVerifiedTitle => 'Uydu Tespitiyle Eşleşti';

  @override
  String get reportPanelReceivedTitle => '⏳ Rapor Alındı';

  @override
  String reportPanelCityLabel(String city) {
    return 'Şehir: $city';
  }

  @override
  String get reportPanelSubmitFailed =>
      'Rapor gönderilemedi. İnternet bağlantınızı kontrol edin.';

  @override
  String get reportPanelOk => 'Tamam';

  @override
  String get reportPanelNewReport => 'Yeni Bildirim';

  @override
  String get reportPanelTitle => 'Yangın Raporla';

  @override
  String get reportPanelSubtitle =>
      'GPS ile konumunuzu alın ve yangını bildirin. Bildiriminiz yakındaki NASA uydu tespitleriyle karşılaştırılır.';

  @override
  String get reportPanelLocation => 'Konum';

  @override
  String get reportPanelLocationObtained => 'Konum alındı';

  @override
  String get reportPanelNoLocationYet => 'Henüz konum alınmadı';

  @override
  String get reportPanelGetGpsLocation => 'GPS ile Konum Al';

  @override
  String get reportPanelRefreshLocation => 'Konumu Yenile';

  @override
  String get reportPanelRiskLevel => 'Risk Seviyesi';

  @override
  String get reportPanelYourName => 'Adınız (isteğe bağlı)';

  @override
  String get reportPanelAnonymousHint => 'Anonim olarak gönderilecek';

  @override
  String get reportPanelExtraNote => 'Ek Not';

  @override
  String get reportPanelNoteHint =>
      'Alev yüksekliği, duman yoğunluğu, yol durumu...';

  @override
  String get reportPanelSmokeSwitch => 'Yoğun duman gözleniyor';

  @override
  String get reportPanelWindSwitch => 'Rüzgar güçlü görünüyor';

  @override
  String get reportPanelSettlementSwitch => 'Yerleşim alanına yakın';

  @override
  String get reportPanelSubmitting => 'Gönderiliyor...';

  @override
  String get reportPanelSubmit => 'Bildirimi Gönder';

  @override
  String get reportPanelAnonymousToggle => 'Anonim olarak gönder';

  @override
  String get reportPanelAnonymousToggleSubtitle =>
      'Adınız bildirimle birlikte kaydedilmez';

  @override
  String get reportPanelPhotosLabel => 'Fotoğraflar (isteğe bağlı)';

  @override
  String get reportPanelPhotosHint =>
      'Bildirimi doğrulamaya yardımcı olması için en fazla 3 fotoğraf ekleyin';

  @override
  String get reportPanelAddPhoto => 'Fotoğraf Ekle';

  @override
  String get reportPanelPhotoSourceCamera => 'Kamera';

  @override
  String get reportPanelPhotoSourceGallery => 'Galeri';

  @override
  String get reportPanelRemovePhoto => 'Fotoğrafı kaldır';

  @override
  String get reportPanelUploadingPhotos => 'Fotoğraflar yükleniyor…';

  @override
  String reportPanelPhotosUploaded(int count) {
    return '$count fotoğraf yüklendi';
  }

  @override
  String get reportPanelMapAdjustHint =>
      'Pin konumunu ayarlamak için haritaya dokunun';

  @override
  String get reportPanelSuccessVerifiedTitle => 'Uydu Tespitiyle Eşleşti';

  @override
  String get reportPanelSuccessReceivedTitle => 'Bildirim Alındı';

  @override
  String get reportPanelSuccessVerifiedBody =>
      'Bildirdiğiniz yerin 10 km yakınında son 24 saatte NASA uydu ısı tespiti var. Bu, yangını tek başına doğrulamaz.';

  @override
  String get reportPanelSuccessReceivedBody =>
      'Bildiriminiz kaydedildi. Uydular son 24 saatte yakınında tespit yapmadı; bu, yangın olmadığı anlamına gelmez.';

  @override
  String reportPanelReportIdLabel(String id) {
    return 'Bildirim No: #$id';
  }

  @override
  String reportPanelReportedAtLabel(String time) {
    return '$time tarihinde bildirildi';
  }

  @override
  String get reportPanelResponseTimeVerified =>
      'Bu bildirim acil durum ekiplerine iletilmez. Yangın görüyorsanız hemen 112\'yi arayın.';

  @override
  String get reportPanelResponseTimeReceived =>
      'Bu bildirim acil durum ekiplerine iletilmez. Yangın görüyorsanız hemen 112\'yi arayın.';

  @override
  String get reportPanelShare => 'Paylaş';

  @override
  String get reportPanelDone => 'Tamam';

  @override
  String reportPanelShareText(
    String city,
    String region,
    String id,
    String status,
  ) {
    return '$city, $region yakınında yangın bildirimi gönderildi (#$id). $status';
  }

  @override
  String get slowLoadingBannerLabel =>
      'Yavaş yükleniyor — önbellek verisi gösteriliyor';

  @override
  String get errorStateTitle => 'Bir şeyler ters gitti';

  @override
  String get errorStateGeneric => 'Veriler yüklenemedi. Lütfen tekrar deneyin.';

  @override
  String get emptyStateGenericTitle => 'Gösterilecek veri yok';

  @override
  String get emptyStateGenericSubtitle =>
      'Şu anda burada gösterilecek bir şey bulunmuyor.';

  @override
  String get notifPermTitle => 'Önemli uyarıları kaçırmayın';

  @override
  String get notifPermSubtitle =>
      'Bildirim izniyle yakınınızdaki uydu tespitlerini ve önemli değişiklikleri anında öğrenebilirsiniz.';

  @override
  String get notifPermNote =>
      'Bu izin zorunlu değil. İsterseniz şimdilik atlayıp uygulamayı yine kullanabilirsiniz.';

  @override
  String get notifPermEnable => 'Bildirimleri Etkinleştir';

  @override
  String get notifPermSkip => 'Şimdilik Geç';

  @override
  String get notifPermGranted => 'Bildirim izni verildi. Teşekkürler!';

  @override
  String get notifPermDenied =>
      'Bildirim izni verilmedi. Ayarlardan daha sonra açabilirsiniz.';

  @override
  String get locPermServiceOff =>
      'Konum servisi kapalı görünüyor. Yine de uygulamaya devam edebilirsiniz.';

  @override
  String get locPermDenied =>
      'Konum izni verilmedi. Şimdilik konumsuz devam edebilirsiniz.';

  @override
  String get locPermDeniedForever =>
      'Konum izni kalıcı olarak reddedilmiş. Ayarlardan açabilirsiniz.';

  @override
  String get locPermError =>
      'Konum izni alınırken bir sorun oluştu. Şimdilik geçebilirsiniz.';

  @override
  String get locPermTitle => 'Yakınınızdaki olayları gösterelim';

  @override
  String get locPermSubtitle =>
      'Konumunuzla yakınınızdaki uydu tespitlerini ve çevrenizdeki riski gösterebiliriz. Mesafeler telefonunuzda hesaplanır.';

  @override
  String get locPermNote =>
      'Bildirimler için otomatik taramayı başlatırsanız konumunuz yaklaşık 1 km\'ye yuvarlanarak sunucumuzda saklanır; bildirimleri kapattığınızda ya da Ayarlar → Konum verimi sil ile hemen silinir. Bu izin zorunlu değil, şimdilik atlayabilirsiniz.';

  @override
  String get locPermEnable => 'Konumu Etkinleştir';

  @override
  String get locPermSkip => 'Şimdilik Geç';

  @override
  String get locDisclosureTitle => 'Konumunuzu nasıl kullanıyoruz?';

  @override
  String get locDisclosureOnDevice =>
      'Yakınınızdaki uydu tespitlerine olan mesafe telefonunuzda hesaplanır.';

  @override
  String get locDisclosureNearestCity =>
      'Bulunduğunuz ili göstermek için konumunuz, riski hesaplamak için yaklaşık 10 km\'ye yuvarlanmış konumunuz sunucumuza gönderilir; bu sorgular saklanmaz.';

  @override
  String get locDisclosureStored =>
      'Bildirimler için otomatik taramayı başlatırsanız, bölgenizle ilgili uyarı gönderebilmek için konumunuz yaklaşık 1 km\'ye yuvarlanarak sunucumuzda saklanır. Tam konumunuz saklanmaz.';

  @override
  String get locDisclosureDelete =>
      'Bildirimleri kapattığınızda ya da Ayarlar → Konum verimi sil\'e dokunduğunuzda hemen silinir. Uygulamayı 90 gün açmazsanız kaydınız tamamen silinir.';

  @override
  String get locDisclosureOptional =>
      'Konum izni zorunlu değil; uygulamayı konumsuz da kullanabilir, izni istediğiniz zaman telefon ayarlarından kaldırabilirsiniz.';

  @override
  String get locDisclosureContinue => 'Devam et';

  @override
  String get locDisclosureNotNow => 'Şimdi değil';

  @override
  String get trackedPlacesTitle => 'Yerlerim';

  @override
  String get trackedPlacesSubtitle =>
      'Yakında ısı tespiti olunca ya da yangın riski yükselince bildirim alın';

  @override
  String get trackedPlacesEmpty =>
      'Henüz yer eklemediniz. Ev, yazlık ya da bağ evi gibi en fazla 5 yer ekleyebilirsiniz.';

  @override
  String get trackedPlacesAdd => 'Yer ekle';

  @override
  String get trackedPlacesFull => 'En fazla 5 yer ekleyebilirsiniz.';

  @override
  String trackedPlacesRadius(int km) {
    return '$km km yarıçap';
  }

  @override
  String trackedPlacesLastAlert(String date) {
    return 'Son uyarı: $date';
  }

  @override
  String get trackedPlacesNoAlertYet => 'Henüz uyarı yok';

  @override
  String get trackedPlacesNotifyTooltip => 'Bu yer için bildirimler';

  @override
  String trackedPlacesDeleteTitle(String name) {
    return '\"$name\" silinsin mi?';
  }

  @override
  String get trackedPlacesDeleteBody =>
      'Bu yer ve uyarı kayıtları sunucudan silinir.';

  @override
  String get trackedPlacesDelete => 'Sil';

  @override
  String get trackedPlacesUnavailable => 'Bu özellik yakında açılacak.';

  @override
  String get trackedPlacesLoadFailed =>
      'Yerler yüklenemedi. Son kaydedilen liste gösteriliyor.';

  @override
  String get trackedPlacesSourceMap => 'Haritadan seç';

  @override
  String get trackedPlacesSourceMyLocation => 'Konumumu ekle';

  @override
  String get trackedPlacesLocationFailed => 'Konum alınamadı.';

  @override
  String get trackedPlacesNameLabel => 'Yer adı';

  @override
  String get trackedPlacesNameHint => 'ör. Ev, Yazlık';

  @override
  String get trackedPlacesNameRequired => 'Bir ad girin.';

  @override
  String get trackedPlacesRadiusLabel => 'Yarıçap';

  @override
  String get trackedPlacesSave => 'Kaydet';

  @override
  String trackedPlacesSaved(String name) {
    return '\"$name\" Yerlerim\'e eklendi.';
  }

  @override
  String get trackedPlacesErrorOutside => 'Bu nokta Türkiye sınırları dışında.';

  @override
  String get trackedPlacesErrorNetwork =>
      'Kaydedilemedi. İnternet bağlantınızı kontrol edip tekrar deneyin.';

  @override
  String get trackedPlacesErrorGeneric => 'Bir sorun oluştu, tekrar deneyin.';

  @override
  String get trackedPlacesPickerTitle => 'Konumu seç';

  @override
  String get trackedPlacesPickerHint =>
      'Haritayı kaydırıp işaretçiyi yerin üzerine getirin ya da haritaya uzun basın.';

  @override
  String get trackedPlacesPickerConfirm => 'Bu konumu kullan';

  @override
  String get trackedPlacesApproxNote =>
      'Konum sunucuda yaklaşık 1 km hassasiyetle saklanır. Bildirimler doğrulanmış yangın bildirmez: uydu ısı tespitine ya da risk puanına dayanır.';

  @override
  String get trackedPlacesMigrateTitle =>
      'Kayıtlı yerlerinizi Yerlerim\'e taşımak ister misiniz?';

  @override
  String trackedPlacesMigrateBody(int count) {
    return '$count kayıtlı yeriniz var. Taşırsanız 10 km içindeki yeni uydu ısı tespitlerinde bildirim alırsınız.';
  }

  @override
  String get trackedPlacesMigrateAccept => 'Taşı';

  @override
  String trackedPlacesMigrateDone(int count) {
    return '$count yer eklendi.';
  }

  @override
  String get locDisclosureTracked =>
      'Yerlerim\'e eklediğiniz yerlerin adı, yaklaşık 1 km\'ye yuvarlanmış konumu ve yarıçapı sunucumuzda saklanır. Bir yeri listeden, hepsini Ayarlar → Konum verimi sil ile silebilirsiniz.';

  @override
  String get notifPlacesChannelName => 'Takip ettiğim yerler';

  @override
  String get notifPlacesChannelDescription =>
      'Yerlerim\'deki yerlerin yakınındaki uydu ısı tespitleri ve yangın riski';

  @override
  String get settingsDeleteLocation => 'Konum verimi sil';

  @override
  String get settingsDeleteLocationConfirmTitle => 'Konum veriniz silinsin mi?';

  @override
  String get settingsDeleteLocationConfirmBody =>
      'Sunucuda saklanan yaklaşık konumunuz ve takip ettiğiniz tüm yerler hemen silinir. Bildirimleriniz açık kalır; il veya bölge seçmediyseniz bundan sonra tüm bölgelerin risk uyarılarını alabilirsiniz. Otomatik taramayı yeniden başlatırsanız konumunuz tekrar kaydedilir.';

  @override
  String get settingsDeleteLocationConfirm => 'Sil';

  @override
  String get settingsDeleteLocationDone =>
      'Konum veriniz ve takip ettiğiniz yerler sunucudan silindi.';

  @override
  String get settingsDeleteLocationFailed =>
      'Konum veriniz silinemedi. İnternet bağlantınızı kontrol edip tekrar deneyin.';

  @override
  String get compassNorth => 'K';

  @override
  String get compassSouth => 'G';

  @override
  String get compassEast => 'D';

  @override
  String get compassWest => 'B';

  @override
  String riskReasonHighWithTemp(String temp) {
    return 'Uydular ${temp}K ısı tespit etti. Doğrulanmadı. Bölgeye yaklaşmayın.';
  }

  @override
  String get riskReasonHighNoTemp =>
      'Uydular güçlü bir tespit yaptı. Doğrulanmadı.';

  @override
  String riskReasonMediumWithTemp(String temp) {
    return 'Uydular ${temp}K ısı tespit etti. Nedeni doğrulanmadı.';
  }

  @override
  String get riskReasonMediumNoTemp =>
      'Uydular orta düzeyde bir tespit yaptı. Doğrulanmadı.';

  @override
  String riskReasonLowWithTemp(String temp) {
    return 'Uydular düşük bir ısı tespit etti (${temp}K). Nedeni doğrulanmadı.';
  }

  @override
  String get riskReasonLowNoTemp =>
      'Uydular zayıf bir tespit yaptı. Takip önerilir.';

  @override
  String get fireGeneratedDescHigh =>
      'Uydular güçlü bir ısı tespit etti. Doğrulanmadı.';

  @override
  String get fireGeneratedDescMedium =>
      'Orta seviye ısı artışı. Bölge izleme gerektirir.';

  @override
  String get fireGeneratedDescLow =>
      'Uydular zayıf bir tespit yaptı. Takip önerilir.';

  @override
  String get fireRecommendedActionHigh =>
      'Bölgeden uzak durun, resmi yönlendirmeleri takip edin ve tahliye hazırlığını yapın.';

  @override
  String get fireRecommendedActionMedium =>
      'Gelişmeleri takip edin, bölgeye gereksiz yaklaşmayın.';

  @override
  String get fireRecommendedActionLow =>
      'Şu an acil aksiyon gerekmiyor, bölgeyi takip edin.';

  @override
  String get fireStatusActive => 'Çok Güçlü Tespit';

  @override
  String get fireStatusLikelyActive => 'Güçlü Tespit';

  @override
  String get fireStatusMonitoring => 'İzleniyor';

  @override
  String get fireStatusHistorical => 'Artık görülmüyor';

  @override
  String fireEventRegionTitle(String city) {
    return '$city Bölgesi Uydu Tespiti';
  }

  @override
  String get fireEventLiveDetectionTitle => 'Güncel Uydu Tespiti';

  @override
  String get fireEventStatusActive => 'Aktif';

  @override
  String get fireEventStatusMonitoring => 'İzleniyor';

  @override
  String get fireEventStatusControlled => 'Düşük güvenilirlik';

  @override
  String get fireEventSpreadHigh => 'Yüksek — aktif izleme gerekli';

  @override
  String get fireEventSpreadMedium => 'Orta — dikkatli takip edin';

  @override
  String get fireEventSpreadLow => 'Düşük';

  @override
  String fireDetailAreaMeasured(int hectares) {
    return 'Uydunun gördüğü alan ~$hectares hektar (yangının kendisi değil)';
  }

  @override
  String get fireDetailWindLoading => 'Rüzgar verisi alınıyor...';

  @override
  String get fireDetailWindUnavailable => 'Rüzgar verisi alınamadı';

  @override
  String fireDetailWindValue(String speed, String direction) {
    return '$speed km/s $direction yönünde';
  }

  @override
  String get windDirectionN => 'Kuzey';

  @override
  String get windDirectionNE => 'Kuzeydoğu';

  @override
  String get windDirectionE => 'Doğu';

  @override
  String get windDirectionSE => 'Güneydoğu';

  @override
  String get windDirectionS => 'Güney';

  @override
  String get windDirectionSW => 'Güneybatı';

  @override
  String get windDirectionW => 'Batı';

  @override
  String get windDirectionNW => 'Kuzeybatı';

  @override
  String get fireDetailFireRadiativePower => 'Yangın Işıma Gücü (FRP)';

  @override
  String fireDetailFrpValue(String frp, String intensity) {
    return '$frp MW ($intensity)';
  }

  @override
  String get fireDetailFrpUnavailable => 'Mevcut değil';

  @override
  String get frpIntensityLow => 'Düşük yoğunluk';

  @override
  String get frpIntensityModerate => 'Orta yoğunluk';

  @override
  String get frpIntensityHigh => 'Yüksek yoğunluk';

  @override
  String get frpIntensityVeryHigh => 'Çok yüksek yoğunluk';

  @override
  String fireEventSatelliteLine(String satellite) {
    return 'Uydu: $satellite';
  }

  @override
  String fireEventCoordinateLine(String coordinate) {
    return 'Koordinat: $coordinate';
  }

  @override
  String fireEventDetectionLine(String datetime) {
    return 'Tespit: $datetime';
  }

  @override
  String fireDetailShareText(
    String title,
    String city,
    String district,
    String status,
    String risk,
    String description,
  ) {
    return 'Yangın Uyarısı\n\n$title\n$city / $district\n\nDurum: $status\nRisk: $risk\n\n$description\n\nFireWatch TR ile takip ediliyor.';
  }

  @override
  String get settingsRefreshInterval5Min => '5 dk';

  @override
  String get settingsRefreshInterval15Min => '15 dk';

  @override
  String get settingsRefreshInterval30Min => '30 dk';

  @override
  String get settingsRefreshInterval60Min => '60 dk';

  @override
  String get newsDetailTitle => 'Haber Detayı';

  @override
  String get newsDetailHighlightsTitle => 'Öne Çıkan Noktalar';

  @override
  String get newsDetailHighlightsSubtitle => 'Hızlı özet';

  @override
  String get newsDetailFullContentTitle => 'Detaylı İçerik';

  @override
  String get newsDetailFullContentSubtitle => 'Gelişmenin tam özeti';

  @override
  String get newsDetailRelatedRegionTitle => 'İlgili Bölge';

  @override
  String get newsDetailRelatedRegionSubtitle => 'Bağlantılı risk alanı';

  @override
  String get newsDetailRelatedRegionNote =>
      'Bu gelişme ilgili bölgesel risk ve operasyon akışına bağlı olabilir.';

  @override
  String newsWordCount(int count) {
    return '~$count kelime';
  }

  @override
  String get newsTranslate => 'Çevir';

  @override
  String get newsTranslating => 'Çevriliyor...';

  @override
  String get newsTranslated => 'Çevrildi';

  @override
  String get newsShowOriginal => 'Orijinali Göster';

  @override
  String get newsTranslationFailed => 'Çeviri başarısız oldu.';

  @override
  String get newsTranslatedCaption =>
      'Türkçeden çevrildi • Tam çeviri için dokunun';

  @override
  String get coachMarksGotIt => 'Anladım';

  @override
  String get coachMarksSkip => 'Öğreticiyi Atla';

  @override
  String get coachMarksNext => 'İleri';

  @override
  String coachMarksStepCount(int current, int total) {
    return '$current/$total';
  }

  @override
  String get coachMarkMapTitle => 'Harita ve Uydu Tespitleri';

  @override
  String get coachMarkMapDesc =>
      'Haritadaki işaretler NASA uydularının tespit ettiği ısı noktalarıdır; doğrulanmadı. Bir işarete dokunarak ayrıntıları görebilir, buradan yeni bir yangın da bildirebilirsiniz.';

  @override
  String get coachMarkRiskTitle => 'Risk Seviyeleri';

  @override
  String get coachMarkRiskDesc =>
      'Her uydu tespiti Yüksek, Orta veya Düşük risk seviyesiyle etiketlenir. Bu etiketler bölgedeki tehlike derecesini hızlıca anlamanızı sağlar.';

  @override
  String get coachMarkWatchlistTitle => 'Kaydedilenler';

  @override
  String get coachMarkWatchlistDesc =>
      'Takip etmek istediğiniz uydu tespitlerini kaydedin ve buradan hızlıca tekrar ulaşın.';

  @override
  String get coachMarkNotificationsTitle => 'Bildirimler';

  @override
  String get coachMarkNotificationsDesc =>
      'Yakınınızdaki uydu ısı tespitleri için bildirim alın ve otomatik taramayı buradan başlatın.';

  @override
  String get riskTabTurkeyOverview => 'Türkiye geneli';

  @override
  String get riskTabMyLocation => 'Konumum';

  @override
  String get riskMyLocationGettingLocation => 'Konumunuz alınıyor...';

  @override
  String get riskMyLocationPermissionDenied =>
      'Konum izni verilmedi. Bölge risk bilgisini görmek için izin verin.';

  @override
  String get riskMyLocationServiceOff => 'Konum servisi kapalı. Lütfen açın.';

  @override
  String get riskMyLocationError =>
      'Konumunuz alınamadı. Lütfen tekrar deneyin.';

  @override
  String get riskMyLocationRegionNotFound =>
      'Bölgeniz risk verisinde bulunamadı.';

  @override
  String get riskMyLocationEnableButton => 'Konumu Etkinleştir';

  @override
  String riskMyLocationYourRegion(String city, String region) {
    return 'Bölgeniz: $city ($region)';
  }

  @override
  String riskMyLocationRankLabel(int rank) {
    return 'Sıralama: $rank/7';
  }

  @override
  String riskMyLocationVsAverage(String diff) {
    return 'Türkiye ortalamasına göre: $diff';
  }

  @override
  String get riskMyLocationMetricsTitle => 'Bölgenin Verileri';

  @override
  String get riskChartTapHint => 'Detaylar için bir bölgeye dokunun';

  @override
  String get monitorStatusReady => 'Otomatik takip hazır.';

  @override
  String get monitorStatusAlreadyRunning => 'Otomatik tarama zaten çalışıyor.';

  @override
  String get monitorStatusStarted => 'Otomatik tarama başlatıldı...';

  @override
  String get monitorStatusStopped => 'Otomatik tarama durduruldu.';

  @override
  String get monitorStatusGettingLocation => 'Konum alınıyor...';

  @override
  String get monitorStatusLocationServiceOff =>
      'Konum servisi kapalı. Lütfen konumu açın.';

  @override
  String get monitorStatusLocationDenied => 'Konum izni verilmedi.';

  @override
  String get monitorStatusFetchingData => 'NASA FIRMS verisi çekiliyor...';

  @override
  String get monitorStatusNoActiveFires => 'Uydular şu an tespit bildirmedi.';

  @override
  String monitorStatusNoNearbyFires(int count) {
    return 'Uydular 50 km içinde tespit etmedi. ($count nokta tarandı)';
  }

  @override
  String monitorStatusNearbyFiresFound(int count) {
    return 'Uydular 50 km içinde $count tespit yaptı.';
  }

  @override
  String get monitorStatusTimeout =>
      'NASA API bağlantı zaman aşımı. İnternet bağlantınızı kontrol edin.';

  @override
  String get monitorStatusLocationFailed =>
      'Konum alınamadı. Lütfen tekrar deneyin.';

  @override
  String monitorStatusScanFailed(String error) {
    return 'Tarama başarısız: $error';
  }

  @override
  String get notifNearbyFireTitle => 'Uydular yakınınızda tespit yaptı';

  @override
  String notifNearbyFireBody(String distance, int count) {
    return '$distance içinde $count uydu tespiti var. Doğrulanmadı.';
  }

  @override
  String get notifTestBody => 'Test bildirimi hazır.';

  @override
  String get notifNewNotificationBody => 'Yeni bildirim';

  @override
  String get riskOutsideTurkeyBanner =>
      'Türkiye dışındasınız — konumunuz için bölgesel risk verisi mevcut değil.';

  @override
  String riskMyLocationPostgisDistance(String distance) {
    return '$distance km uzaklıkta';
  }

  @override
  String get riskComparisonTitle => 'Türkiye Ortalamasıyla Karşılaştırma';

  @override
  String get riskComparisonHigherRisk => 'Daha yüksek risk';

  @override
  String get riskComparisonLowerRisk => 'Daha düşük risk';

  @override
  String get riskComparisonSimilar => 'Türkiye ortalamasına yakın';

  @override
  String get riskInfoButtonTooltip => 'Risk skoru nasıl hesaplanır?';

  @override
  String get riskInfoTitle => 'Risk Skoru Nasıl Hesaplanır?';

  @override
  String get riskInfoFormulaTitle => 'Skor Formülü';

  @override
  String get riskInfoFormulaTemp => 'Sıcaklık (en fazla 30 puan)';

  @override
  String get riskInfoFormulaHumidity => 'Düşük Nem (en fazla 25 puan)';

  @override
  String get riskInfoFormulaWind => 'Rüzgar (en fazla 25 puan)';

  @override
  String get riskInfoFormulaFireCount =>
      'Son 24 saatteki uydu ısı olayı sayısı (en fazla 20 puan)';

  @override
  String get riskInfoSourcesTitle => 'Veri Kaynakları';

  @override
  String get riskInfoSourcesBody =>
      'NASA FIRMS uydu verisi ve Open-Meteo (yedek: MET Norway) hava durumu verisi kullanılarak hesaplanır. Hava verisi her bölge için tek bir temsilî noktadan alınır; haberler puana katılmaz.';

  @override
  String get riskInfoUpdateFrequencyTitle => 'Güncelleme Sıklığı';

  @override
  String get riskInfoUpdateFrequencyBody =>
      'Risk skorları her 3 saatte bir yeniden hesaplanır.';

  @override
  String get trustHomeInfo =>
      'Veriler NASA FIRMS uydu tespitlerinden alınır; sunucu yaklaşık 30 dakikada bir yeni veri çeker.';

  @override
  String get trustMapInfo =>
      'Haritadaki işaretler uyduların yaptığı tespitleri gösterir.';

  @override
  String get trustRiskInfo =>
      'Risk skorları yaklaşık 3 saatte bir hava durumu ve NASA uydu tespitlerinden hesaplanır.';

  @override
  String get trustNewsInfo =>
      'Haberler 9 Türk kaynağından yangınla ilgili içerik için filtrelenir.';

  @override
  String get trustAlertsInfo =>
      'Konumunuza 50 km içinde uydu ısı tespiti olduğunda bildirim gönderilir.';

  @override
  String get trustCardLabel => 'Veri Kaynağı Hakkında';

  @override
  String get trustAspectMeaningTitle => 'Bu ne anlama geliyor?';

  @override
  String get trustAspectSourceTitle => 'Bu nereden geliyor?';

  @override
  String get trustAspectInterpretTitle => 'Nasıl yorumlanır';

  @override
  String get trustAspectActionTitle => 'Ne yapmalıyım?';

  @override
  String get trustHomeMeaning =>
      'Bu ekrandaki sayılar uyduların son 24 saatte yaptığı tespitlerdir; doğrulanmadı. Bazıları tarımsal yakma, sanayi ısısı veya sıcak yüzey olabilir.';

  @override
  String get trustHomeSource =>
      'Veriler NASA FIRMS\'ten (Yangın Bilgi ve Kaynak Yönetim Sistemi) gelir; birkaç uydunun geçişlerini birleştirir. Sunucu yaklaşık 30 dakikada bir yeni veri çeker; uydu geçişleri ve NASA\'nın işleme süresi nedeniyle bir tespit birkaç saat gecikebilir.';

  @override
  String get trustHomeInterpret =>
      'Yalnızca uydunun çok emin olduğu ve çok yüksek ısı ölçtüğü tespitler Çok Güçlü Tespit olarak etiketlenir.';

  @override
  String get trustHomeAction =>
      'Ayrıntılar için tespite dokunun. Duman veya alev görürseniz önce 112\'yi arayın.';

  @override
  String get trustMapMeaning =>
      'Her işaret bir uydu tespitidir; doğrulanmadı. Kırmızı çok güçlü, turuncu güçlü, sarı orta, gri zayıf tespittir.';

  @override
  String get trustMapSource => 'Uydu verileri NASA FIRMS\'ten alınır.';

  @override
  String get trustMapInterpret =>
      'Kümeler yalnızca birbirine yakın birden fazla ısı tespiti olduğunu gösterir; yangının nedenini veya büyüklüğünü doğrulamaz.';

  @override
  String get trustMapAction =>
      'Ayrıntılar için işarete dokunun. Yangını kendiniz görürseniz önce 112\'yi arayın, sonra Raporla\'yı kullanın.';

  @override
  String get trustRiskMeaning =>
      'Risk puanı (0-100) sıcaklık, nem, rüzgâr ve bölgedeki son uydu tespitlerini birleştiren bir endekstir; yangın çıkıp çıkmayacağını söylemez, garanti vermez.';

  @override
  String get trustRiskSource =>
      'Hava durumu verileri canlı meteorolojik kaynaklardan alınır; yangın sayıları her bölge için son NASA FIRMS tespitlerini hesaba katar.';

  @override
  String get trustRiskInterpret =>
      'Bölgenizin puanını grafikte Türkiye ortalamasıyla karşılaştırın — ortalamanın önemli ölçüde üzerinde bir puan, izlenmesi gereken yükselmiş yerel koşullara işaret eder.';

  @override
  String get trustRiskAction =>
      'Bölgeniz Kritik veya Yüksek risk gösteriyorsa açık ateşten kaçının ve herhangi bir dumanı hemen bildirin. Kişiselleştirilmiş bir döküm için \"Konumum\" sekmesine geçin.';

  @override
  String get trustNewsMeaning =>
      'Başlıklar yalnızca orman yangını, afet ve acil durumla ilgili haberleri tutacak şekilde otomatik olarak filtrelenir — ilgisiz siyasi veya spor haberleri hariç tutulur.';

  @override
  String get trustNewsSource =>
      'Makaleler, 9 köklü Türk haber kuruluşunun herkese açık RSS beslemeleri aracılığıyla toplanır ve gün boyunca sürekli güncellenir.';

  @override
  String get trustNewsInterpret =>
      '\"Son Dakika\" rozeti, makalenin çok yakın zamanda yayınlandığı anlamına gelir — orman yangını durumları hızla değişebileceğinden yayın saatini her zaman kontrol edin.';

  @override
  String get trustNewsAction =>
      'İngilizce olmayan makaleleri okumak için Çevir düğmesini kullanın veya bir haberdeki \"İlgili Yangınlar\"a dokunarak doğrudan o konuma haritada gidin.';

  @override
  String get trustAlertsMeaning =>
      'Uyarılar, uydular 50 km içinde tespit yaptığında gönderilir. Bunlar otomatik tespitlerdir; doğrulanmadı.';

  @override
  String get trustAlertsSource =>
      'Arka plan izleme, NASA FIRMS verilerini belirli aralıklarla kontrol eder ve yeni tespitleri cihazınızın son bilinen konumuyla telefonunuzda karşılaştırır. Sunucudan gelen bölgesel uyarılar için, otomatik taramayı başlattığınızda konumunuz yaklaşık 1 km\'ye yuvarlanarak saklanır.';

  @override
  String get trustAlertsInterpret =>
      'Güven düzeyi, uydunun tespitten ne kadar emin olduğunu anlatır; yangın olduğunu doğrulamaz.';

  @override
  String get trustAlertsAction =>
      'Bildirim izni verin ve uygulamayı kullanırken Otomatik İzlemeyi başlatın. Çevrenizi manuel kontrol etmek için istediğiniz zaman \"Şimdi Tara\"yı kullanın.';

  @override
  String get newsReadFullArticle => 'Haberin Tamamını Oku';

  @override
  String smartIntensityIntense(String location) {
    return '$location yakınında uydular çok güçlü bir tespit yaptı.';
  }

  @override
  String smartIntensityHigh(String location) {
    return '$location yakınında uydular güçlü bir tespit yaptı.';
  }

  @override
  String smartIntensityModerate(String location) {
    return '$location yakınında uydular orta düzeyde bir tespit yaptı.';
  }

  @override
  String smartIntensityEarly(String location) {
    return '$location yakınında uydular zayıf bir tespit yaptı; nedeni doğrulanmadı.';
  }

  @override
  String smartIntensityAnomaly(String location) {
    return '$location yakınında uydular bir tespit yaptı.';
  }

  @override
  String get smartLocationHintForest => 'ormanlık alanı geniş bir ilde';

  @override
  String get smartLocationHintCoastal => 'güneybatı kıyı kuşağında';

  @override
  String get smartLocationHintUrban =>
      'kentleşmesi yoğun bir ilde; bina veya sanayi kaynaklı olabilir';

  @override
  String get smartLocationHintAgricultural =>
      'tarımın yoğun olduğu bir ilde; uydular anız yakımını da tespit eder';

  @override
  String get smartFrpHigh => 'Uydu bu noktada yüksek ısı ölçtü.';

  @override
  String smartPixelFootprint(int hectares) {
    return 'Uydu bu noktayı ~$hectares hektarlık bir alan olarak görür; ısının kaynağı bu alanın içindedir, gerçek boyutu bilinmiyor.';
  }

  @override
  String smartAreaLarge(int hectares) {
    return 'Uydunun tespit ettiği alan geniş (~$hectares hektar).';
  }

  @override
  String smartAreaMedium(int hectares) {
    return 'Uydunun tespit ettiği alan orta büyüklükte (~$hectares hektar).';
  }

  @override
  String get smartConfidenceHigh =>
      'NASA bu tespitten yüksek düzeyde emin; nedeni doğrulanmadı.';

  @override
  String get smartConfidenceMedium =>
      'NASA bu tespiti orta güvenle bildiriyor; doğrulanmadı.';

  @override
  String get smartConfidenceLow =>
      'Zayıf bir tespit; sanayi ısısı veya yansıma olabilir, doğrulanmadı.';

  @override
  String get smartSpreadDangerous =>
      'Bölgenin güncel risk skoru yüksek (düşük nem, güçlü rüzgar) — bu yangına özel bir ölçüm değil.';

  @override
  String get smartSpreadModerate =>
      'Bölgenin güncel risk skoru orta düzeyde — bu yangına özel bir ölçüm değil.';

  @override
  String get smartSpreadLow =>
      'Bölgenin güncel risk skoru düşük — bu yangına özel bir ölçüm değil.';

  @override
  String smartTimeJustNow(String satellite) {
    return 'Az önce $satellite tarafından tespit edildi.';
  }

  @override
  String smartTimeRecent(int hours, String satellite) {
    return '$hours saat önce $satellite tespit etti; güncel durumu doğrulanmadı.';
  }

  @override
  String smartTimeOlder(int hours) {
    return '$hours saat önce tespit edildi, mevcut durumu bilinmiyor.';
  }

  @override
  String smartTimeHistorical(int days) {
    return '$days gün önce yapılmış eski bir tespit; güncel durumu bilinmiyor.';
  }

  @override
  String get tooltipTempTitle => 'Sıcaklık';

  @override
  String get tooltipTempBody =>
      'Uydu tarafından ölçülen parlaklık sıcaklığıdır. Yüksek değer güçlü bir ısı kaynağıdır ancak tek başına yangını doğrulamaz.';

  @override
  String get tooltipConfidenceTitle => 'Güven Seviyesi Ne Anlama Gelir?';

  @override
  String get tooltipSatelliteTitle => 'Uydu Ne Anlama Gelir?';

  @override
  String get tooltipSatelliteViirsBody =>
      'VIIRS: NOAA-20 ve NOAA-21 uyduları, Türkiye üzerinden günde birkaç kez geçer. (Suomi NPP 2 Kasım 2026\'da veri vermeyi bıraktı.)';

  @override
  String get tooltipSatelliteModisBody =>
      'MODIS: Terra/Aqua uydusu, daha geniş bir kapsama alanı sağlar.';

  @override
  String get tooltipSatelliteMergedBody =>
      'Bu anomali aynı zaman ve konum aralığında birden fazla uydu cihazı tarafından tespit edildi. Tespiti güçlendirir ancak nedenini doğrulamaz.';

  @override
  String get fireCardMultiSourceBadge => 'Çoklu kaynak tespiti';

  @override
  String get reportPanelDuplicateLocationBlocked =>
      'Bu konumdan zaten rapor gönderildi. Lütfen yetkililer ulaşana kadar bekleyin.';

  @override
  String get reportPanelDailyLimitReached =>
      'Bugün için rapor gönderme limitine ulaştınız (günde en fazla 5). Lütfen yarın tekrar deneyin.';

  @override
  String fireDetailRelatedToCity(String city) {
    return '$city ile İlgili';
  }

  @override
  String get fireDetailRegionalNews => 'Bölgesel Haberler';

  @override
  String get coachMarkMapMarkersTitle => 'Uydu Tespit İşaretleri';

  @override
  String get coachMarkMapMarkersDesc =>
      'Haritadaki işaretler NASA uydularından gelen ısı tespitleridir; doğrulanmadı. Bir işarete dokunarak ayrıntıları görebilirsiniz.';

  @override
  String get coachMarkMapClustersTitle => 'Küme Sayıları';

  @override
  String get coachMarkMapClustersDesc =>
      'Birbirine yakın uydu tespitleri bir araya toplanır ve üzerinde sayı gösteren bir daire olarak görünür. Yakınlaştırdıkça kümeler ayrışır.';

  @override
  String get coachMarkMapReportTitle => 'Yangın Bildir';

  @override
  String get coachMarkMapReportDesc =>
      'Sağ alttaki butona dokunarak gördüğünüz bir yangını GPS konumunuzla birlikte bildirebilirsiniz.';

  @override
  String get coachMarkMapNearbyTitle => 'Yakınımdaki Uydu Tespitleri';

  @override
  String get coachMarkMapNearbyDesc =>
      'Bu bölüm, konumunuza en yakın uydu ısı tespitlerini mesafe sırasına göre listeler.';

  @override
  String get coachMarkNewsFeaturedTitle => 'Öne Çıkan Haber';

  @override
  String get coachMarkNewsFeaturedDesc =>
      'Günün en önemli gelişmesi burada öne çıkarılır.';

  @override
  String get coachMarkNewsCategoryTitle => 'Kategoriler';

  @override
  String get coachMarkNewsCategoryDesc =>
      'Haberleri Risk, Operasyon, Güvenlik veya Güncelleme kategorisine göre filtreleyebilirsiniz.';

  @override
  String get coachMarkNewsRegionTitle => 'Durum Filtreleri';

  @override
  String get coachMarkNewsRegionDesc =>
      'Önem derecesine göre filtreleyin — kritik, aktif, izleniyor, bilgi — ya da sadece kendi bölgenizi görün.';

  @override
  String get coachMarkNewsListTitle => 'Habere Dokun';

  @override
  String get coachMarkNewsListDesc =>
      'Bir habere dokunarak tam metnini okuyun; İngilizce moddaysanız başlık ve özeti tek dokunuşla çevirebilirsiniz.';

  @override
  String get coachMarkNotifPermissionTitle => 'Bildirim İzni';

  @override
  String get coachMarkNotifPermissionDesc =>
      'Yakınınızdaki uydu ısı tespitleri için bildirim alabilmek üzere izin verin.';

  @override
  String get coachMarkNotifScanTitle => 'Şimdi Tara';

  @override
  String get coachMarkNotifScanDesc =>
      'Konumunuzun 50 km çevresinde uydu ısı tespiti olup olmadığını kontrol edin.';

  @override
  String get coachMarkNotifMonitoringTitle => 'Otomatik Tarama';

  @override
  String get coachMarkNotifMonitoringDesc =>
      'Uygulama açıkken yakındaki uydu tespitlerini düzenli kontrol etmek için otomatik izlemeyi başlatın.';

  @override
  String get coachMarkNotifAlertsTitle => 'Uyarı Kartları';

  @override
  String get coachMarkNotifAlertsDesc =>
      'Yüksek riskli tespitler burada listelenir; bir karta dokunarak tam detaya ulaşabilirsiniz.';

  @override
  String get coachMarkRiskScoreTitle => 'Risk Skoru';

  @override
  String get coachMarkRiskScoreDesc =>
      '0-100 arası bu skor, sıcaklık, nem, rüzgar ve NASA uydu tespitlerinden hesaplanır. Nasıl hesaplandığını bilgi butonundan öğrenebilirsiniz.';

  @override
  String get coachMarkRiskChartTitle => 'Bölgesel Dağılım';

  @override
  String get coachMarkRiskChartDesc =>
      'Bir bölge çubuğuna dokunarak o bölgenin detaylı risk analizini görebilirsiniz.';

  @override
  String get coachMarkRiskMyLocationTabTitle => 'Konumum';

  @override
  String get coachMarkRiskMyLocationTabDesc =>
      'Bu sekmeye geçerek kendi bölgenizin riskini Türkiye ortalamasıyla karşılaştırın.';

  @override
  String get coachMarkRiskInfoTitle => 'Veri Kaynakları';

  @override
  String get coachMarkRiskInfoDesc =>
      'Bilgi butonu risk skorunun formülünü, veri kaynaklarını ve güncelleme sıklığını açıklar.';

  @override
  String get coachMarkWatchlistPurposeTitle => 'Kaydedilenler Ne İşe Yarar?';

  @override
  String get coachMarkWatchlistPurposeDesc =>
      'Takip etmek istediğiniz uydu tespitlerini burada bir arada tutabilirsiniz.';

  @override
  String get coachMarkWatchlistHowToAddTitle => 'Nasıl Eklenir?';

  @override
  String get coachMarkWatchlistHowToAddDesc =>
      'Bir tespitin detay ekranındaki yer imi butonuna dokunarak onu buraya kaydedebilirsiniz.';

  @override
  String get coachMarkWatchlistClearTitle => 'Temizle';

  @override
  String get coachMarkWatchlistClearDesc =>
      'Üst köşedeki Temizle butonuyla tüm kayıtlı noktaları tek seferde kaldırabilirsiniz.';

  @override
  String get detectionProbableFire => 'Çok Güçlü Tespit';

  @override
  String get detectionHighThermalAnomaly => 'Güçlü Tespit';

  @override
  String get detectionThermalDetection => 'Uydu Tespiti';

  @override
  String get detectionLowConfidence => 'Düşük Güvenilirlik';

  @override
  String get thermalAnomalyDisclaimer =>
      'NASA uyduları ısı tespit eder. Tespitler doğrulanmadı; sanayi gibi yangın dışı kaynaklar da tespit edilebilir.';

  @override
  String get detectionAboutTitle => 'Bu tespit nedir?';

  @override
  String get detectionAboutViirs =>
      'NASA VIIRS, Dünya yüzeyindeki kızılötesi ısıyı ölçer. Doğrulanmış yangınları değil, termal anomalileri belirler.';

  @override
  String detectionConfidenceExplanation(String level) {
    return 'Güvenilirlik: $level. Bu değer, uydu algoritmasının pikselde gerçek bir termal anomali bulunduğuna dair güvenidir; nedenini doğrulamaz.';
  }

  @override
  String detectionFrpExplanation(String frp) {
    return 'FRP: $frp MW. Yangın Işıma Gücü yayılan ısının hızını tahmin eder; yüksek değer daha güçlü bir ısı kaynağıdır ancak kaynak endüstriyel veya tarımsal olabilir.';
  }

  @override
  String get detectionLimitations =>
      'Bulut, duman, uydu çözünürlüğü ve yangın dışı ısı kaynakları eksik veya yanıltıcı tespitlere yol açabilir. Güvenlik kararlarında resmi acil durum bilgilerini kullanın.';

  @override
  String get mapLegendTitle => 'Harita Lejantı';

  @override
  String get legendProbableFire => 'Çok güçlü tespit';

  @override
  String get legendHighThermal => 'Güçlü tespit';

  @override
  String get legendLowConfidence => 'Düşük Güvenilirlik';

  @override
  String get mapMarkerDisclaimerBefore =>
      'Harita NASA uydularının yaptığı tespitleri gösterir.';

  @override
  String get mapMarkerDisclaimerAfter =>
      'işaretler en güçlü tespitlerdir; doğrulanmadı.';

  @override
  String get feedbackSend => 'Geri Bildirim Gönder';

  @override
  String get feedbackTitle => 'Geri Bildirim Gönder';

  @override
  String get feedbackRating => 'Puan';

  @override
  String get feedbackCategory => 'Kategori';

  @override
  String get feedbackBug => 'Hata Bildirimi';

  @override
  String get feedbackFeature => 'Özellik İsteği';

  @override
  String get feedbackGeneral => 'Genel Geri Bildirim';

  @override
  String get feedbackMessage => 'Mesaj';

  @override
  String get feedbackEmail => 'E-posta (isteğe bağlı)';

  @override
  String get feedbackSubmit => 'Gönder';

  @override
  String get feedbackSuccess => 'Teşekkürler! Geri bildiriminiz gönderildi.';

  @override
  String get feedbackError =>
      'Geri bildirim gönderilemedi. Lütfen tekrar deneyin.';

  @override
  String get feedbackMessageRequired => 'Lütfen bir mesaj yazın.';

  @override
  String get feedbackRatingRequired =>
      'Lütfen 1 ile 5 arasında bir puan seçin.';

  @override
  String get ratingPromptTitle => 'FireWatch TR\'yi beğendiniz mi?';

  @override
  String get ratingPromptMessage =>
      'Uygulamayı birkaç gündür kullanıyorsunuz. Görüşlerinizi paylaşmak ister misiniz?';

  @override
  String get ratingPromptLater => 'Daha sonra';

  @override
  String get feedbackReportBug => 'Hata Bildir';

  @override
  String get feedbackSendFeedback => 'Geri Bildirim';

  @override
  String feedbackBlockedMessage(int days) {
    return 'Geri bildiriminiz alındı. Yeni geri bildirim için $days gün bekleyin.';
  }

  @override
  String get bugReportTitle => 'Hata Bildir';

  @override
  String get bugReportIntro =>
      'Neyin yanlış gittiğini anlatın — doğrudan ekibe iletilir.';

  @override
  String get bugReportWhatHappened => 'Ne oldu?';

  @override
  String get bugReportWhatExpected => 'Bunun yerine ne bekliyordunuz?';

  @override
  String get bugReportDeviceInfo => 'Cihaz bilgisi (otomatik eklenir)';

  @override
  String get bugReportWhatHappenedRequired => 'Lütfen ne olduğunu açıklayın.';

  @override
  String get coachMarkWatchlistTapTitle => 'Detayı Gör';

  @override
  String get coachMarkWatchlistTapDesc =>
      'Kaydedilen bir tespite dokunarak güncel durumunu ve tam detaylarını görebilirsiniz.';

  @override
  String get notificationScopeTitle => 'Bildirim Kapsamı';

  @override
  String get notificationScopeSubtitle =>
      'Hangi yangınlar için uyarı almak istediğinizi seçin.';

  @override
  String get notificationScopeAll => 'Tüm Türkiye';

  @override
  String get notificationScopeAllDesc =>
      'Ülke genelindeki tüm yangın uyarılarını alın.';

  @override
  String get notificationScopeRegion => 'Sadece bölgem';

  @override
  String get notificationScopeRegionDesc =>
      'Yalnızca seçtiğiniz coğrafi bölgedeki yangınlar.';

  @override
  String get notificationScopeCity => 'Sadece ilim';

  @override
  String get notificationScopeCityDesc =>
      'Yalnızca seçtiğiniz ildeki yangınlar.';

  @override
  String get notificationScopeRegionLabel => 'Bölge';

  @override
  String get notificationScopeCityLabel => 'İl';

  @override
  String get notificationScopeSelectRegion => 'Bölge seç';

  @override
  String get notificationScopeSelectCity => 'İl seç';

  @override
  String notificationScopeDetected(String name) {
    return 'Konumunuzdan algılandı: $name';
  }

  @override
  String get notificationScopeDetecting => 'Konumunuz belirleniyor...';

  @override
  String get notificationScopeSaved => 'Bildirim kapsamı güncellendi.';

  @override
  String get notificationScopeSaveFailed =>
      'Kapsam kaydedilemedi. İnternet bağlantınızı kontrol edin.';

  @override
  String get notificationScopeCitiesUnavailable => 'İl listesi yüklenemedi.';

  @override
  String get notificationScopeNarrowWarning =>
      'Kapsamı daraltmak, seçtiğiniz alan dışındaki yangınlar için uyarı almayacağınız anlamına gelir.';

  @override
  String get incidentsSectionTitle => 'Uydu Olayları';

  @override
  String get incidentsSectionSubtitle => 'Uydu tespitleri olaylara gruplanmış';

  @override
  String get incidentStatusActive => 'Güncel tespit';

  @override
  String get incidentStatusAwaiting => 'Artık görülmüyor';

  @override
  String get incidentStatusLowConfidence => 'Düşük güvenilirlik';

  @override
  String incidentDetectedHoursAgo(String hours) {
    return 'Son $hours saat içinde tespit edildi';
  }

  @override
  String incidentNoDetectionFor(String hours) {
    return 'Isı tespit edildi, $hours saattir görülmüyor';
  }

  @override
  String incidentNoDetectionLowConfidence(String hours) {
    return 'Isı tespit edildi, $hours saattir görülmüyor (düşük güvenilirlik)';
  }

  @override
  String incidentDurationOngoing(String hours) {
    return 'En az $hours saattir tespit ediliyor';
  }

  @override
  String get incidentDurationShort => 'Tek geçişte tespit edildi';

  @override
  String incidentEvidence(int detections, int passes) {
    return '$detections tespit, $passes uydu geçişi';
  }

  @override
  String get incidentHeatLabel => 'Isı şiddeti';

  @override
  String get incidentHeatLow => 'Zayıf';

  @override
  String get incidentHeatModerate => 'Orta';

  @override
  String get incidentHeatHigh => 'Güçlü';

  @override
  String get incidentHeatVeryHigh => 'Çok güçlü';

  @override
  String get incidentSpreadTitle => 'Yayılma (tahmini)';

  @override
  String incidentSpreadLine(String direction, String meters) {
    return '$direction, saatte ~$meters metre';
  }

  @override
  String get incidentSpreadEstimateNote =>
      'Uydu tespit deseninin kaymasından hesaplanır; yangının gerçek ilerleyişi farklı olabilir.';

  @override
  String get incidentTrendWeakening => 'Isı şiddeti azalıyor';

  @override
  String get incidentTrendIntensifying => 'Isı şiddeti artıyor';

  @override
  String get incidentTrendStable => 'Isı şiddeti değişmiyor';

  @override
  String get incidentTrendNote =>
      'Uydunun ölçtüğü ısı yayımına göre. Söndürme çalışması olup olmadığı bu veriden anlaşılmaz.';

  @override
  String get incidentToggleShow => 'Uydu olayları';

  @override
  String get incidentToggleDetections => 'Doğrulanmamış uydu tespitleri';

  @override
  String get incidentLayerCaptionDetections =>
      'Uyduların tek tek yaptığı tespitler; doğrulanmadı.';

  @override
  String get incidentLayerCaptionEvents =>
      'Uyduların aynı noktada yaptığı tespitler tek bir olayda birleştirildi.';

  @override
  String get incidentFilterActive => 'Aktif';

  @override
  String get incidentFilterEnded => 'Artık görülmüyor';

  @override
  String get incidentFilterAll => 'Tümü';

  @override
  String get riskLayerToggle => 'FWI (Copernicus)';

  @override
  String get incidentToggleShowShort => 'Olaylar';

  @override
  String get incidentToggleDetectionsShort => 'Noktalar';

  @override
  String get mapLayersButton => 'Katmanlar';

  @override
  String get placesButton => 'Yerlerim';

  @override
  String get placesTitle => 'Kayıtlı Yerler';

  @override
  String get placesSubtitle =>
      'Harita bu yerlere yakınlaşır; isterseniz bildirim kapsamınız da bu yerlere daralır.';

  @override
  String get placesEmpty =>
      'Henüz kayıtlı yer yok. İl veya ilçe arayın, ya da haritaya iğne bırakın.';

  @override
  String get placesSearchHint => 'İl veya ilçe ara';

  @override
  String get placesDropPin => 'Haritaya iğne bırak';

  @override
  String get placesDropPinHint => 'Kaydetmek istediğiniz noktaya dokunun';

  @override
  String get placesPinNameTitle => 'Yere bir ad verin';

  @override
  String get placesPinDefaultName => 'Kayıtlı nokta';

  @override
  String get placesShowAllPlaces => 'Hepsini göster';

  @override
  String get placesResetView => 'Tüm Türkiye';

  @override
  String get placesRemove => 'Yeri sil';

  @override
  String get placesRiskUnknown => 'Risk alınamadı';

  @override
  String get placesRiskNoData => 'Veri yok';

  @override
  String placesRiskLine(String day) {
    return 'FWI tehlikesi · $day';
  }

  @override
  String placesActiveDetections(int count) {
    return '$count aktif tespit';
  }

  @override
  String get placesNoActiveDetections => 'Aktif tespit yok';

  @override
  String placesLastDetection(String hours) {
    return 'Son tespit ~$hours saat önce';
  }

  @override
  String get placesResolutionNote =>
      'FWI sınıfı, ECMWF\'nin küresel hava modelinden gelen bölgesel bir tahmindir; il ve ilçe ölçeğinde anlamlıdır, mahalle ölçeğinde ayrışmaz. Yakın iki yerin aynı sınıfı göstermesi verinin çözünürlüğüdür, hata değil.';

  @override
  String get notificationScopePlaces => 'Kayıtlı yerlerim';

  @override
  String get notificationScopePlacesDesc =>
      'Yalnızca harita ekranında kaydettiğiniz il, ilçe ve noktaların çevresindeki yangınlar.';

  @override
  String get notificationScopePlacesEmpty =>
      'Henüz kayıtlı yer yok. Harita ekranındaki Yerlerim panelinden ekleyebilirsiniz.';

  @override
  String notificationScopePlacesNote(int count) {
    return '$count kayıtlı yer izleniyor. Bu kapsam şimdilik bu cihazın kendi taramalarıyla uygulanır; sunucu bildirimleri son seçtiğiniz il/bölge kapsamını kullanmaya devam eder.';
  }

  @override
  String get notifPlacesFireTitle => 'Kayıtlı yerinizin yakınında uydu tespiti';

  @override
  String notifPlacesFireBody(int count) {
    return 'Kayıtlı yerlerinizin çevresinde $count uydu tespiti var. Harita ekranından kontrol edin.';
  }

  @override
  String get riskLegendTitle => 'Copernicus yangın tehlike indeksi (FWI)';

  @override
  String get riskLegendNote =>
      'Hava koşullarından hesaplanan bölgesel tehlike tahmini; uydu tespiti değildir.';

  @override
  String get riskLegendHide => 'Lejantı gizle';

  @override
  String get riskClassVeryLow => 'Çok düşük';

  @override
  String get riskClassLow => 'Düşük';

  @override
  String get riskClassModerate => 'Orta';

  @override
  String get riskClassHigh => 'Yüksek';

  @override
  String get riskClassVeryHigh => 'Çok yüksek';

  @override
  String get riskClassExtreme => 'Aşırı';

  @override
  String get riskOpacityLabel => 'Opaklık';

  @override
  String get riskDayToday => 'Bugün';

  @override
  String get riskDayTomorrow => 'Yarın';

  @override
  String get riskDayNotPublished =>
      'Bu günün tahmini henüz yayımlanmadı. Günlük model koşusu geldiğinde açılır.';

  @override
  String get riskAttribution =>
      '© European Union, Copernicus EFFIS · CC BY 4.0';

  @override
  String get homeLast24hTitle => 'Son 24 Saat';

  @override
  String get homeLast24hSubtitle => 'Uydu tespitlerinin özeti';

  @override
  String get homeLast24hActiveTitle => 'Tekrarlanan tespit';

  @override
  String homeLast24hActiveSubtitle(int hours) {
    return 'Son $hours saat içinde uydu tarafından görüldü';
  }

  @override
  String get homeLast24hEndedTitle => 'Artık görülmeyen';

  @override
  String get homeLast24hEndedSubtitle => 'Söndüğü anlamına gelmez.';

  @override
  String get homeLast24hLongestTitle => 'En uzun süren';

  @override
  String get homeLast24hLongestSubtitle =>
      'İlk tespitten bu yana, halen tespit ediliyor';

  @override
  String get homeLast24hStrongestTitle =>
      'En güçlü uydu tespiti — doğrulanmadı';

  @override
  String get homeLast24hStrongestSubtitle =>
      'Uyduların şu an gördüğü en güçlü tespit';

  @override
  String homeLast24hStrongestSubtitleWithDuration(String duration) {
    return 'En az $duration, halen tespit ediliyor';
  }

  @override
  String durationHoursShort(int hours) {
    return '$hours saat';
  }

  @override
  String durationDaysHours(int days, int hours) {
    return '$days gün $hours saat';
  }

  @override
  String get incidentsEmpty => 'Bu aralıkta gruplanmış uydu olayı yok.';

  @override
  String incidentsCount(int count) {
    return '$count olay';
  }

  @override
  String get incidentPanelTitle => 'Uydu tespiti';

  @override
  String get incidentOfficialTitle => 'Resmî durum';

  @override
  String get incidentSatelliteLimitNote =>
      'Uydu günde birkaç kez geçer ve bulut ya da duman altını göremez. Tespit olmaması yangının bittiği anlamına gelmez.';

  @override
  String get incidentFixedSourceHint =>
      'Bu konum iki gündür her uydu geçişinde ve değişmeyen güçte görünüyor — sabit bir ısı kaynağı olabilir.';

  @override
  String get incidentStatusPersistentHeatSource => 'Sabit ısı kaynağı';

  @override
  String incidentPersistentHeatSourceNote(int days) {
    return '$days gündür düşük ve değişmeyen güçte ısı yayıyor: demir-çelik tesisi, rafineri veya gaz bacası gibi sabit bir kaynak. Aktif yangın sayılmaz. Bu, herhangi bir yangının söndüğü anlamına gelmez.';
  }

  @override
  String get homeFixedHeatSourceChip => 'Sabit ısı kaynağı';

  @override
  String get incidentLegendTitle => 'Harita göstergesi';

  @override
  String get compassTowardsNorth => 'kuzeye doğru';

  @override
  String get compassTowardsNorthEast => 'kuzeydoğuya doğru';

  @override
  String get compassTowardsEast => 'doğuya doğru';

  @override
  String get compassTowardsSouthEast => 'güneydoğuya doğru';

  @override
  String get compassTowardsSouth => 'güneye doğru';

  @override
  String get compassTowardsSouthWest => 'güneybatıya doğru';

  @override
  String get compassTowardsWest => 'batıya doğru';

  @override
  String get compassTowardsNorthWest => 'kuzeybatıya doğru';

  @override
  String riskHeatPill(String place, int score, String level) {
    return '$place · $score/100 · $level';
  }

  @override
  String get riskHeatTurkeyWide => 'Türkiye geneli';

  @override
  String get riskHeatLevelVeryHigh => 'Çok yüksek';

  @override
  String get riskHeatUnavailable => 'Risk verisi şu an alınamıyor';

  @override
  String riskHeatMapSemantics(int score, String level) {
    return 'Türkiye yangın riski ısı haritası. Türkiye geneli risk skoru $score/100, $level.';
  }

  @override
  String get navRisk => 'Risk';

  @override
  String get riskAdviceCritical =>
      'Açık alanda ateş yakmayın. Şüpheli dumanı 112’ye bildirin; resmi uyarıları izleyin.';

  @override
  String get riskAdviceHigh =>
      'Açık alanda ateş yakmayın; kıvılcım çıkarabilecek işlerden kaçının.';

  @override
  String get riskAdviceMedium =>
      'Kuru bitki örtüsü yakınında dikkatli olun; yerel uyarıları izleyin.';

  @override
  String get riskAdviceLow =>
      'Risk düşük olsa da sıfır değildir. Ateşi ve izmaritleri doğaya bırakmayın.';

  @override
  String get riskScoreNotProbability =>
      'Bu puan, yangın çıkıp çıkmayacağını söylemez.';

  @override
  String get riskScoresAreIndices =>
      'Puanlar 0–100 arası bir endekstir; yangın çıkıp çıkmayacağını söylemez.';

  @override
  String riskNearbyFireCount(String count) {
    return 'Son günlerde yakında $count uydu tespiti.';
  }

  @override
  String get riskNearbyFireCountUnavailable =>
      'Yakındaki son yangın sayısı henüz paylaşılmıyor.';

  @override
  String riskPreviousScore(String score) {
    return 'Önceki puan: $score/100';
  }

  @override
  String riskCalculatedAt(String date) {
    return 'Hesaplama: $date';
  }

  @override
  String get riskSavedView => 'Kaydedilmiş görünüm';

  @override
  String get riskServerUnreachable =>
      'Sunucuya ulaşılamadı. Kaydedilmiş veriler gösteriliyor.';

  @override
  String riskServerUnreachableSavedAt(String date) {
    return 'Sunucuya ulaşılamadı. Son kayıt: $date';
  }

  @override
  String get riskRestorationCardTitle => 'Yangın kayıpları ve restorasyon';

  @override
  String get riskRestorationCardSubtitle =>
      'Aylık yanan alan verilerini zaman içinde takip edin';

  @override
  String get riskHistoryCardTitle => 'Geçmiş yangınlar';

  @override
  String get riskHistoryCardSubtitle =>
      'Geçmiş yangın alanları, tarihleri ve restorasyon güncellemeleri';

  @override
  String get riskDistrictMapCardTitle => 'İl / ilçe risk haritası';

  @override
  String get riskDistrictMapCardSubtitle =>
      'İlçe düzeyinde risk puanları ve sıralama';

  @override
  String get newsTabFires => 'Yangınlar';

  @override
  String get newsTabRecovery => 'Yenilenme';

  @override
  String get newsTabSolidarity => 'Dayanışma';

  @override
  String get newsTabEvents => 'Etkinlikler';

  @override
  String get newsShowingSaved => 'Kaydedilmiş haberler gösteriliyor.';

  @override
  String get newsNoneInTab => 'Bu başlıkta henüz içerik yok.';

  @override
  String get newsEventJoin => 'Katıl';

  @override
  String get newsDonate => 'Bağış yap';

  @override
  String get newsAddToCalendar => 'Takvime ekle';

  @override
  String get newsCalendarFailed => 'Takvim uygulaması açılamadı.';

  @override
  String get newsLinkFailed => 'Bağlantı açılamadı.';

  @override
  String get annualLayerToggle => 'Geçmiş yıllar';

  @override
  String annualLayerCaption(int year) {
    return 'İl rengi: $year OGM yanan alanı. Noktalar: mevcut tespitler. Uydu noktası yangın sayısı değildir.';
  }

  @override
  String get annualLayerLoadError =>
      'Geçmiş yıl dosyaları yüklenemedi. Tekrar denemek için katmanı kapatıp açın.';

  @override
  String get riskDrynessIndexDerived =>
      'Kuruluk göstergesi (sıcaklık, nem ve rüzgârdan türetilir)';

  @override
  String get riskVegetationDensityDerived =>
      'Bitki baskısı (sıcaklık ve rüzgârdan türetilir)';

  @override
  String get riskDrynessDerivation => 'Sıcaklık, nem ve rüzgârdan türetilir.';

  @override
  String annualPastYearChip(int year) {
    return '$year · Geçmiş yıl';
  }

  @override
  String get annualNoData => 'Veri yok';

  @override
  String get annualMetricOgmArea => 'OGM yanan alan';

  @override
  String get annualMetricOgmCount => 'OGM yangın sayısı';

  @override
  String get annualMetricSatellite => 'Uydu noktası';

  @override
  String get annualMetricEffisArea => 'EFFIS alan';

  @override
  String get annualMetricOgmAreaDesc =>
      'OGM’nin kaydettiği yanan orman alanı. İl renkleri her zaman bu değere göre belirlenir.';

  @override
  String get annualMetricOgmCountDesc =>
      'OGM’nin kaydettiği orman yangını sayısı.';

  @override
  String get annualMetricSatelliteDesc =>
      'Uydu noktası yangın sayısı değildir. Orman ve maki alanındaki uydu tespitlerini gösterir.';

  @override
  String get annualMetricEffisAreaDesc =>
      'EFFIS’in uydu görüntülerinden hesapladığı yanan alan. Küçük yangınların kapsamı OGM’den farklı olabilir.';

  @override
  String get annualMetricExplainTitle => 'Değerlerin açıklaması';

  @override
  String get annualMetricExplainHint =>
      'Seçim yalnızca açıklamayı değiştirir; il rengi her zaman OGM yanan alanını gösterir.';

  @override
  String get annualProvinceNote =>
      'Uydu noktası yangın sayısı değildir. İl dolguları yangının sınırını değil, il genelindeki yıllık toplamı gösterir.';

  @override
  String get annualLegendTitle => 'Geçmiş yıllar · OGM yanan alan';

  @override
  String annualLegendTickMax(String value) {
    return '≥ $value ha';
  }

  @override
  String get annualLegendNote =>
      'Logaritmik renk ölçeği · Koyu renk daha fazla yanan alanı gösterir. Verisi olmayan iller boyanmaz. Bu katman güncel yangın riski değildir.';

  @override
  String get districtRiskRankingTitle => 'Risk sıralaması';

  @override
  String get districtRiskScoresNotProbability =>
      'Puanlar yangın çıkıp çıkmayacağını söylemez.';

  @override
  String get districtRiskSampleBanner =>
      'ÖRNEK VERİ · Sınırlar şematiktir; gerçek ilçe sınırları ve güncel risk değildir.';

  @override
  String get districtRiskLoadFailed =>
      'İlçe risk verisi alınamadı. Yeniden denemek için dokunun.';

  @override
  String get districtRiskAllProvinces => 'Türkiye';

  @override
  String get districtRiskAllDistricts => 'Tüm ilçeler';

  @override
  String get districtRiskNoScore => 'Risk verisi yok';

  @override
  String get districtRiskOpenRanking => 'Risk sıralamasını aç';

  @override
  String get historyLoadFailed =>
      'Geçmiş yangın verileri alınamadı. Yeniden denemek için dokunun.';

  @override
  String get historySourceOpenFailed => 'Kaynak açılamadı.';

  @override
  String get historySampleRecord =>
      'ÖRNEK KAYIT — gerçek bir yangını temsil etmez.';

  @override
  String get historyAreaUnknown => 'Alan henüz bilinmiyor';

  @override
  String historyAreaPitches(String hectares, String pitches) {
    return '$hectares hektar — yaklaşık $pitches futbol sahası.';
  }

  @override
  String get historyPitchComparison =>
      'Karşılaştırma: 105 × 68 m saha = 0,714 hektar.';

  @override
  String get historyAreaSource => 'Alan verisinin kaynağı';

  @override
  String get historyRestorationTitle => 'Restorasyon';

  @override
  String get historyNoRestoration =>
      'Bu alan için kaynakla doğrulanmış restorasyon kaydı henüz yok. Bu, çalışma yapılmadığı anlamına gelmez.';

  @override
  String get historyComparisonSource => 'Karşılaştırmanın kaynağı';

  @override
  String get historyOpenAnnouncement => 'Resmi duyuruyu aç';

  @override
  String get historyCampaignsTitle => 'Değişim tek kişiyle başlar';

  @override
  String get historyNoCampaigns =>
      'Doğrulanmış bir kampanya veya gönüllü etkinliği henüz eklenmedi.';

  @override
  String get historyPeriodThisSummer => 'Bu yaz';

  @override
  String get historyPeriodSinceLastSummer => 'Geçen yazdan beri';

  @override
  String get historyPeriodLast3Years => 'Son 3 yıl';

  @override
  String get historyPeriodCustom => 'Özel aralık';

  @override
  String get historyNoRecords => 'Seçilen aralıkta kayıt yok.';

  @override
  String get historySampleBanner =>
      'ÖRNEK VERİ · Boyalı alanlar şematiktir; gerçek yangın sınırları değildir.';

  @override
  String get historySourceSample =>
      'Kaynak: örnek veri. Canlı kaynak: NASA FIRMS (VIIRS/MODIS).';

  @override
  String get historySourceLive =>
      'Kaynak: NASA FIRMS (VIIRS/MODIS) · uydu ısı tespitleri';

  @override
  String historyDetections(String count, String hours) {
    return '$count tespit · $hours saat';
  }

  @override
  String historyMaxFrp(String frp) {
    return 'En yüksek ışınım gücü (FRP): $frp MW';
  }

  @override
  String get historyFootprintNote =>
      'Haritadaki şekil, uydunun ısı tespit ettiği yerlerin izidir (her tespitin çevresinde 188 m); yanan alanın sınırı değildir. Yanan alan ölçülmediği için alan gösterilmez. Anız ve tarım yangınları da dahildir.';

  @override
  String get historyNearestDistrictNote =>
      'İlçe, olayın merkezine en yakın ilçe merkezine göre belirlendi; sınıra yakın olaylarda komşu ilçe olabilir.';

  @override
  String get historyOpenFirmsMap => 'NASA FIRMS haritasını aç';

  @override
  String get historyFirmsAttribution =>
      'We acknowledge the use of data and/or imagery from NASA\'s Fire Information for Resource Management System (FIRMS) (https://earthdata.nasa.gov/firms), part of NASA\'s Land, Atmosphere Near real-time Capability for Earth observations (LANCE) (https://earthdata.nasa.gov/lance) and NASA\'s Earth Science Data and Information System (ESDIS).';

  @override
  String get detectionNotConfirmedNotice =>
      'Bu bir uydu ısı tespitidir, doğrulanmış yangın değildir. Yangın ya da duman görürseniz hemen 112\'yi arayın.';

  @override
  String get riskFactorTempHintNone =>
      '25°C altındaki sıcaklık risk puanını artırmaz.';

  @override
  String riskFactorTempHint(int points, int max) {
    return 'Risk puanına +$points/$max ekler: sıcak hava bitkilerin daha hızlı nem kaybetmesine yol açar.';
  }

  @override
  String get riskFactorHumidityHintNone =>
      '%50 üzerindeki nem risk puanını artırmaz; nemli bitki örtüsü daha zor tutuşur.';

  @override
  String riskFactorHumidityHint(int points, int max) {
    return 'Risk puanına +$points/$max ekler: düşük nem yanıcı bitki örtüsünü kurutur.';
  }

  @override
  String get riskFactorWindHintNone =>
      '10 km/h altındaki rüzgâr risk puanını artırmaz.';

  @override
  String riskFactorWindHint(int points, int max) {
    return 'Risk puanına +$points/$max ekler: rüzgâr alevleri ve kıvılcımları taşıyabilir.';
  }

  @override
  String riskNoteLightWind(int wind) {
    return 'Hafif rüzgâr ($wind km/h)';
  }

  @override
  String get newsFeaturedSubtitleLatest => 'En güncel başlık';

  @override
  String get homeBriefRiskLoading => 'Bölgesel risk verisi yükleniyor.';

  @override
  String get homeBriefRiskUnavailable =>
      'Bölgesel risk verisi şu an alınamadı.';

  @override
  String homeBriefRiskHighest(String region, int score) {
    return 'En yüksek bölgesel risk $region bölgesinde: $score/100.';
  }

  @override
  String homeBriefNationwide(int count) {
    return '$count önemli uydu tespiti Türkiye genelinde izleniyor.';
  }

  @override
  String get homeBriefNoneNearby =>
      '100 km çevrenizde önemli bir tespit görünmüyor.';

  @override
  String homeBriefNearby(int count) {
    return '100 km çevrenizde $count tespit var; haritadan ayrıntıları kontrol edin.';
  }

  @override
  String get homeBriefTitle => 'Bugün ne bilmeliyim?';

  @override
  String get homeBriefSubtitle => 'Kısa durum özeti';

  @override
  String get homeBriefViewRisk => 'Riski incele';

  @override
  String get homeBriefOpenMap => 'Haritayı aç';

  @override
  String get dataSourcesBordersTitle => 'İl sınırları';

  @override
  String get dataSourcesBordersBody =>
      'Haritadaki \"Geçmiş yıllar\" katmanında çizilen 81 il sınırı ve sunucunun bir tespiti hangi ile atadığı aynı dosyadan gelir: geoBoundaries (gbOpen, TUR ADM1), OpenStreetMap verisinden türetilmiştir. Sınırlar sadeleştirilmiştir; il sınırına çok yakın bir nokta komşu ile düşebilir. Denizdeki ya da sınır dışındaki noktalar en yakın ile atanır.';

  @override
  String get dataSourcesBordersGeoBoundariesCredit =>
      'İl sınırları: geoBoundaries';

  @override
  String get annualLayerProvenance =>
      'Yıllık il toplamları kaynak veri setinde hesaplanmıştır (OGM orman yangını istatistikleri; NASA FIRMS VIIRS S-NPP ve ESA WorldCover 2021; EFFIS). Veri setinin kendi beyanına göre uydu noktası sayıları GADM 4.1 il sınırlarıyla hesaplanmıştır. Haritada çizilen il sınırları geoBoundaries / OpenStreetMap\'tir.';

  @override
  String get osmAttribution => '© OpenStreetMap katkıcıları, ODbL';

  @override
  String get odblLicenseLink => 'ODbL 1.0 lisansı';

  @override
  String mapDetectionConfidence(int score) {
    return 'Tespit güveni: $score/100';
  }

  @override
  String get mapDetectionConfidenceInfoTitle => 'Tespit güveni';

  @override
  String get mapDetectionConfidenceInfoBody =>
      'NASA\'nın güven düzeyi, tespitin gücü, 20 km içindeki tekrar eden tespitler ve tespitin ne kadar yeni olduğundan hesaplanır. Hava durumu bu puana katılmaz.';

  @override
  String get mapDetectionConfidenceInfoNotFire =>
      'Bu puan bir uydu tespitinin ne kadar belirgin olduğunu gösterir. Orada yangın olduğunu doğrulamaz.';

  @override
  String get mapStrongUnverifiedReason =>
      'Uydular tek geçişte güçlü bir tespit yaptı; doğrulanmadı.';

  @override
  String mapStrongUnverifiedBanner(int count) {
    return '$count güçlü, doğrulanmamış tespit — Noktalar\'da görün';
  }

  @override
  String get multiPassDetectionLabel => 'Çoklu geçiş tespiti';

  @override
  String get multiPassDetectionExplanation =>
      'Uydular aynı noktada en az iki ayrı geçişte güçlü tespit yaptı. Bu, yangın olduğunu doğrulamaz.';

  @override
  String homeMultiPassSubtitle(int weaker) {
    return 'En az 2 uydu geçişi; $weaker zayıf tespit daha Noktalar katmanında';
  }

  @override
  String homeMultiPassNote(int count, int weaker) {
    return '$count tekrarlanan tespit (en az 2 uydu geçişi); haritada $weaker tek geçişli ya da zayıf tespit daha var. Hiçbiri doğrulanmadı.';
  }

  @override
  String get incidentExtinguishedConflict =>
      'Resmî bilgi: söndürüldü — uydu hâlâ ısı görüyor';

  @override
  String get fireDetailLinkedNews => 'Bu yangınla ilişkilendirilen haberler';

  @override
  String get osmTileAttribution => '© OpenStreetMap katkıcıları';

  @override
  String get riskInfoFormulaHeatBonus =>
      'Sıcak ve kuru hava birlikteyse ek puan (en fazla 20 puan)';

  @override
  String myPlacesRiskLine(String level, int score) {
    return 'Yangın riski: $level ($score/100)';
  }

  @override
  String myPlacesDetections24h(int count) {
    return 'Son 24 saatte $count tespit';
  }

  @override
  String get myPlacesNoDetections => 'Son 24 saatte yakında tespit yok';

  @override
  String get myPlacesRiskNote =>
      'Risk, hava koşulları ve yakın uydu tespitlerinden hesaplanan bir puandır. Tespit olmaması yangın olmadığı anlamına gelmez.';

  @override
  String get trackedPlacesEditTitle => 'Yeri düzenle';

  @override
  String get trackedPlacesNotifyHeat =>
      'Yakında yeni ısı tespiti olunca bildir';

  @override
  String get trackedPlacesNotifyRisk => 'Yangın riski yükselince bildir';

  @override
  String get trackedPlacesNotifyRiskDesc =>
      'Yüksek veya Kritik\'e çıkınca, günde en fazla bir kez';

  @override
  String get placeSearchHint => 'İl, ilçe, mahalle ya da adres';

  @override
  String get placeSearchButton => 'Ara';

  @override
  String get placeSearchRemote => 'Mahalle veya adres olarak ara';

  @override
  String get placeSearchNoResults =>
      'Sonuç bulunamadı. Haritadan seçebilirsiniz.';

  @override
  String get placeSearchFailed =>
      'Arama şu an yapılamıyor. Haritadan seçebilirsiniz.';

  @override
  String get placeSearchTooShort => 'En az 3 harf yazın.';

  @override
  String get placeSearchPrivacy =>
      'İl ve ilçe aramaları telefonunuzda yapılır. Mahalle ve adres aramaları sunucumuz üzerinden OpenStreetMap\'e iletilir; yazdığınız metin saklanmaz.';

  @override
  String get placeSearchAttribution =>
      'Arama sonuçları © OpenStreetMap katkıcıları (Nominatim)';

  @override
  String get detectionNoneTitle =>
      'Son 24 saatte uydular Türkiye\'de orman ve doğal alanlarda güçlü bir ısı tespit etmedi.';

  @override
  String get detectionLimitNote =>
      'Uydular küçük veya bulut altındaki yangınları göremeyebilir.';

  @override
  String detectionLastUpdate(String time) {
    return 'Son güncelleme: $time';
  }

  @override
  String get detectionStaleTitle => 'Uydu verisi güncel değil.';

  @override
  String get detectionStaleBody =>
      'Bu yüzden şu an tespit olup olmadığını söyleyemiyoruz.';

  @override
  String get detectionUnavailableTitle => 'Uydu verisi alınamadı.';

  @override
  String get detectionUnavailableBody =>
      'Bu, tespit olmadığı anlamına gelmez. Bağlantınızı kontrol edip yeniden deneyin.';

  @override
  String get detectionCall112Line => 'Yangın görürseniz önce 112\'yi arayın.';

  @override
  String get detectionReportLine =>
      'Uygulamada görünmeyen bir yangın ya da bir hata fark ederseniz Raporla ile bize bildirin.';

  @override
  String get detectionReportButton => 'Raporla';

  @override
  String get detectionShowLast7Days => 'Son 7 günü göster';

  @override
  String get detectionOpenRisk => 'Risk katmanını aç';

  @override
  String detectionLatest(String when, String city) {
    return 'En son tespit: $when, $city';
  }

  @override
  String detectionLatestNoCity(String when) {
    return 'En son tespit: $when';
  }

  @override
  String detectionDaysAgo(int days) {
    return '$days gün önce';
  }

  @override
  String detectionHoursAgo(int hours) {
    return '$hours saat önce';
  }

  @override
  String get detectionJustNow => 'bir saatten kısa süre önce';

  @override
  String get riskColorsNotFire =>
      'Renkler yangın değil, yangın çıkma riskidir.';

  @override
  String get mapRiskLayer => 'Risk';

  @override
  String get mapRiskLegendTitle => 'Risk puanı (bölgelere göre)';

  @override
  String get mapRiskLegendLow => 'Düşük · 0–24';

  @override
  String get mapRiskLegendMedium => 'Orta · 25–49';

  @override
  String get mapRiskLegendHigh => 'Yüksek · 50–74';

  @override
  String get mapRiskLegendCritical => 'Kritik · 75–100';

  @override
  String get mapRiskUnavailable => 'Risk verisi alınamadı.';

  @override
  String mapRiskRegionTap(String region, int score, String level) {
    return '$region: $score/100, $level';
  }

  @override
  String get reportPanelNotEmergency =>
      'Bu bildirim acil servislere iletilmez; acil durumda 112\'yi arayın.';

  @override
  String get reportPanelTypeLabel => 'Bildirim türü';

  @override
  String get reportTypeFire => 'Yangın gözlemi';

  @override
  String get reportTypeMissingFire => 'Uygulamada görünmeyen yangın';

  @override
  String get reportTypeWrongInfo => 'Hatalı bilgi/uygulama hatası';

  @override
  String get reportPanelWrongInfoHint =>
      'Neyin hatalı olduğunu yazın: hangi ekran, ne gördünüz, ne olmalıydı?';

  @override
  String get reportPanelWrongInfoNeedText =>
      'Lütfen neyin hatalı olduğunu yazın.';

  @override
  String get reportPanelWrongInfoSent => 'Bildiriminiz alındı. Teşekkürler.';

  @override
  String get riskTabPlaces => 'Yerlerim';

  @override
  String get riskPointBack => 'Yerlerim\'e dön';

  @override
  String get riskPointAdviceTitle => 'Öneriler';

  @override
  String get riskPointWhyTitle => 'Neden bu seviye';

  @override
  String get riskPointNearbyTitle => 'Yakın tespitler';

  @override
  String riskPointNearby(int km, int count) {
    return '$km km içinde son 24 saatte $count uydu tespiti';
  }

  @override
  String riskPointNearbyNone(int km) {
    return '$km km içinde son 24 saatte uydu tespiti yok. Bu, yangın olmadığı anlamına gelmez.';
  }

  @override
  String get riskPointNearbyUnknown =>
      'Yakın uydu tespitleri şu an bilinmiyor; puan yalnızca hava koşullarından hesaplandı.';

  @override
  String riskPointCalculatedAt(String time) {
    return 'Hesaplanma: $time';
  }

  @override
  String get riskPointUnavailable =>
      'Risk şu an hesaplanamadı. Yeniden deneyin.';

  @override
  String get riskCopernicusTitle => 'Copernicus yangın tehlike indeksi';

  @override
  String get riskCopernicusNote =>
      'FireWatch risk puanından ayrı, hava modeline dayalı bir göstergedir; puana katılmaz.';

  @override
  String get riskCopernicusAttribution =>
      '© European Union, Copernicus EFFIS · CC BY 4.0';

  @override
  String get commonDetails => 'Detaylar';

  @override
  String incidentPeakPowerDetail(String mw) {
    return 'En yüksek ışıma gücü (FRP): $mw MW';
  }

  @override
  String get commonAllTechnical => 'Tüm teknik bilgiler';

  @override
  String dsStrong(String city) {
    return 'Uydular $city yakınında güçlü bir yangın izi tespit etti.';
  }

  @override
  String get dsStrongNoCity => 'Uydular güçlü bir yangın izi tespit etti.';

  @override
  String dsNormal(String city) {
    return 'Uydular $city yakınında bir yangın izi tespit etti.';
  }

  @override
  String get dsNormalNoCity => 'Uydular bir yangın izi tespit etti.';

  @override
  String get dsNotVerified => 'Henüz doğrulanmadı.';

  @override
  String get dsNewsVerified => 'Haberlerde doğrulandı.';

  @override
  String get dsFarmland => 'Tarım alanı olduğu için anız yakma da olabilir.';

  @override
  String get dsBuilt =>
      'Sanayi veya yerleşim alanı olduğu için sabit bir ısı kaynağı da olabilir.';

  @override
  String get dsSeenJustNow => 'Az önce görüldü.';

  @override
  String dsSeenHours(int hours) {
    return '$hours saat önce görüldü.';
  }

  @override
  String dsSeenDays(int days) {
    return '$days gün önce görüldü.';
  }

  @override
  String lastSeenHours(int hours) {
    return 'Son görülme: $hours saat önce';
  }

  @override
  String lastSeenDays(int days) {
    return 'Son görülme: $days gün önce';
  }

  @override
  String incidentSeenPasses(int passes) {
    return 'Uydular bu noktayı $passes ayrı geçişte gördü.';
  }

  @override
  String get incidentSeenOnce => 'Uydular bu noktayı bir kez gördü.';

  @override
  String get newsVerifiedLabel => 'Haberlerde doğrulandı';

  @override
  String get relatedNewsTitle => 'İlgili haberler';

  @override
  String get mapPointFarmland => 'Tarım alanında — anız yakma olabilir';

  @override
  String get mapPointBuilt =>
      'Sanayi veya yerleşim alanında — sabit ısı kaynağı olabilir';

  @override
  String detectionOtherLine(int count) {
    return 'Tarım ve sanayi alanlarında $count güçlü tespit var; bunlar Noktalar katmanında.';
  }

  @override
  String get fireDetailBrightness =>
      'Uydunun ölçtüğü yüzey parlaklık sıcaklığı';

  @override
  String get fireDetailBrightnessNote =>
      'Bu, hava sıcaklığı değildir. Uydunun yerden aldığı ısı ölçümüdür; yangının sıcaklığını göstermez.';

  @override
  String get homeTodayTitle => 'Konumunuzda bugün';

  @override
  String get homeNearbyNone => '25 km içinde uydular güçlü bir tespit yapmadı.';

  @override
  String homeNearbySome(int count) {
    return '25 km içinde uydular $count güçlü tespit yaptı.';
  }

  @override
  String homeWind(String speed) {
    return 'Rüzgâr: $speed km/s';
  }

  @override
  String get homeLocationNeeded =>
      'Konumunuzu açarsanız buradaki riski görürsünüz.';

  @override
  String get homeLocationOutside => 'Konumunuz Türkiye dışında görünüyor.';

  @override
  String get homeLocationEnable => 'Konumu aç';

  @override
  String get homeRiskUnavailable => 'Risk şu an hesaplanamadı.';

  @override
  String homeTurkeyLine(int natural, int other) {
    return 'Son 24 saat: orman ve doğal alanda $natural güçlü tespit, tarım ve sanayi alanında $other.';
  }

  @override
  String get homeSeeOnMap => 'Haritada gör';

  @override
  String get homeNewsTitle => 'Haberler';

  @override
  String get newsNewBadge => 'Yeni';

  @override
  String get coachMarksDisableAll => 'Tüm ipuçlarını kapat';

  @override
  String get settingsTipsTitle => 'İpuçları';

  @override
  String get settingsTipsSubtitle => 'Ekranlardaki kısa ipuçlarını göster';

  @override
  String get pageAboutLink => 'Bu sayfa hakkında';

  @override
  String get dataSourcesLandCoverTitle => 'Arazi örtüsü';

  @override
  String get dataSourcesLandCoverBody =>
      'Bir tespitin orman, tarım veya sanayi alanında olduğu ESA WorldCover 2021 haritasından, çevresindeki 750 metrelik alana bakılarak belirlenir. © ESA WorldCover project 2021 / Contains modified Copernicus Sentinel data (2021) processed by ESA WorldCover consortium. Lisans: CC BY 4.0.';

  @override
  String get homeOverviewNewsNoFresh => 'Yeni haber yok';

  @override
  String get navNature => 'Doğa';

  @override
  String natureSource(String name) {
    return 'Kaynak: $name';
  }

  @override
  String get natureTodayTask => 'Bugünün görevi';

  @override
  String get natureTaskSaved =>
      'Kaydedildi. Yarın yeni bir görev burada olacak.';

  @override
  String get natureYes => 'Yaptım';

  @override
  String get natureNo => 'Bugün değil';

  @override
  String get natureAnotherTask => 'Başka görev';

  @override
  String get natureShare => 'Paylaş';

  @override
  String get naturePickProvince => 'İlinizi seçin';

  @override
  String get natureProvince => 'İliniz';

  @override
  String get natureOpenInat => 'iNaturalist\'i aç';

  @override
  String natureProvinceStat(
    String province,
    int year,
    int hectares,
    int fires,
  ) {
    return 'OGM verisine göre $province: $year yılında $hectares hektar, $fires yangın.';
  }

  @override
  String natureShareRisk(String region, String level, int score) {
    return 'Bugün $region bölgesinde yangın riski: $level ($score/100). Yangın görürseniz önce 112’yi arayın. FireWatch TR';
  }

  @override
  String natureStreak(int days) {
    return '$days gün';
  }

  @override
  String get natureWeeklyChallenge => 'Haftanın hedefi';

  @override
  String get natureGoalDays => 'Bu hafta 4 gün görevinize bakın';

  @override
  String get natureGoalLesson => 'Bir ders bitirin';

  @override
  String get natureGoalShares => 'İki bilgi veya risk kartı paylaşın';

  @override
  String get natureFactTitle => 'Günün doğa bilgisi';

  @override
  String get natureLessons => 'Kısa dersler';

  @override
  String natureLessonLength(int cards) {
    return '$cards kart';
  }

  @override
  String get natureBadges => 'Rozetler';

  @override
  String get natureBadgeFirst => 'İlk adım';

  @override
  String get natureBadgeSeven => 'Yedi gün';

  @override
  String get natureBadgeThirty => 'Otuz gün';

  @override
  String get natureBadgeSeasons => 'Dört mevsim';

  @override
  String get natureBadgeCurious => 'Meraklı';

  @override
  String get natureBadgeAllLessons => 'Bilgi sahibi';

  @override
  String get natureBadgeSharer => 'Paylaşan';

  @override
  String get natureBadgeObserver => 'Gözlemci';

  @override
  String get natureOnDevice =>
      'İlerlemeniz yalnızca bu telefonda saklanır, sunucuya gönderilmez. Uygulamayı silerseniz kaybolur.';

  @override
  String get natureReminder => 'Günlük hatırlatma';

  @override
  String get natureReminderDesc => 'Günde en fazla bir kez';

  @override
  String get natureReminderText => 'Bugünün doğa görevi hazır.';

  @override
  String get natureShowStreak => 'Seriyi göster';

  @override
  String get natureDeleteTitle => 'Doğa verilerimi sil';

  @override
  String get natureDeleteBody =>
      'Görevleriniz, seriniz, dersleriniz ve rozetleriniz bu telefondan silinir. Bu işlem geri alınamaz.';

  @override
  String get natureDeleteConfirm => 'Sil';

  @override
  String get natureFinish => 'Bitir';
}
