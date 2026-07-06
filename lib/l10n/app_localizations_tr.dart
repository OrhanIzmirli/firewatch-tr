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
  String get splashTagline => 'Yangınları takip et, güvende kal';

  @override
  String get onboardingSkip => 'Geç';

  @override
  String get onboardingNext => 'Sonraki';

  @override
  String get onboardingContinue => 'Devam Et';

  @override
  String get onboardingTitle1 => 'Aktif olayları takip et';

  @override
  String get onboardingDesc1 =>
      'Türkiye genelindeki yangın olaylarını tek ekranda takip et ve durum değişikliklerini hızlıca gör.';

  @override
  String get onboardingTitle2 => 'Yakınındaki bölgeleri gör';

  @override
  String get onboardingDesc2 =>
      'Harita ve bölge odaklı ekranlarla sana yakın olayları daha hızlı fark et.';

  @override
  String get onboardingTitle3 => 'Güvenlik yönlendirmeleri al';

  @override
  String get onboardingDesc3 =>
      'Risk seviyelerini incele, önerilen aksiyonları gör ve gerektiğinde hızlı hareket et.';

  @override
  String get homeLiveSummary => 'Canlı Durum Özeti';

  @override
  String get homeHeaderTitle => 'Türkiye Yangın Takibi';

  @override
  String get homeHeaderSubtitle =>
      'Aktif olayları takip et, risk seviyelerini gör ve güvenlik rehberine hızlıca ulaş.';

  @override
  String get homeNasaLiveData => 'NASA FIRMS • Canlı Veri';

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
  String get homeOverviewSubtitle => 'NASA FIRMS anlık verisi';

  @override
  String get homeTotalPoints => 'Toplam Nokta';

  @override
  String get homeHighRisk => 'Yüksek Risk';

  @override
  String get homeNominal => 'Normal';

  @override
  String get homeLatestNews => 'Son Haberler';

  @override
  String get homeLatestNewsSubtitle => 'Öne çıkan gelişmeler';

  @override
  String homeBreakingCount(int count) {
    return '$count sıcak';
  }

  @override
  String get homeNewsLoading => 'Haber yükleniyor...';

  @override
  String get homeActiveThermalPoints => 'Aktif Termal Noktalar';

  @override
  String get homeActiveThermalSubtitle => 'NASA FIRMS • PostGIS şehir tespiti';

  @override
  String get homeMap => 'Harita';

  @override
  String get homeFilterHighRisk => 'Yüksek Risk';

  @override
  String get homeFilterMediumRisk => 'Orta Risk';

  @override
  String get homeSearchHint => 'Şehir veya bölge ara...';

  @override
  String get homeNoActiveFires => 'Aktif yangın noktası bulunamadı.';

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
  String get mapTitle => 'Yangın Haritası';

  @override
  String get mapLiveMap => 'Canlı Harita';

  @override
  String get mapHeaderTitle => 'Türkiye Geneli Yangın Görünümü';

  @override
  String get mapHeaderSubtitle =>
      'NASA FIRMS verisiyle aktif termal noktaları harita üzerinde göster.';

  @override
  String get mapArea => 'Harita Alanı';

  @override
  String get mapAreaSubtitle => 'NASA FIRMS canlı marker görünümü';

  @override
  String get mapGoToMe => 'Bana Git';

  @override
  String get mapNearbyFires => 'Yakınımdaki Yangınlar';

  @override
  String get mapNearbyFiresSubtitle => 'Konumuna en yakın canlı tespitler';

  @override
  String get mapReport => 'Raporla';

  @override
  String mapKmAway(String distance) {
    return '$distance km uzaklıkta';
  }

  @override
  String get fireDetailTitle => 'Yangın Detayı';

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
      'Yakındaki olaylar, durum değişimleri ve saha güncellemelerini tek akışta takip et.';

  @override
  String get notificationsTools => 'Bildirim Araçları';

  @override
  String get notificationsToolsSubtitle =>
      'İzin ver, test et, yangın bildirimi simüle et';

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
  String get notificationsSendDemoFire => 'Demo Yangın Bildirimi Gönder';

  @override
  String get notificationsScanNow => 'Şimdi Tara';

  @override
  String get notificationsStartMonitoring => 'Otomatik Taramayı Başlat';

  @override
  String get notificationsStopMonitoring => 'Otomatik Taramayı Durdur';

  @override
  String get notificationsNearbyLiveFires => 'Yakındaki Canlı Yangınlar';

  @override
  String get notificationsNearbyLiveFiresSubtitle =>
      'Konumuna 50 km içinde bulunan noktalar';

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
      'Şu an yüksek riskli yangın noktası bulunmuyor.';

  @override
  String get notificationsHighRiskDetectionTitle =>
      'Yüksek Riskli Termal Tespit';

  @override
  String notificationsHighRiskDetectionBody(String region, String temp) {
    return '$region bölgesinde ${temp}K ısı tespit edildi. Aktif yangın ihtimali yüksek.';
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
      'Takip etmek istediğin yangın noktalarını burada saklayabilirsin.';

  @override
  String get watchlistEmptyTitle => 'Henüz kaydedilmiş olay yok';

  @override
  String get watchlistEmptySubtitle =>
      'Yangın detay ekranındaki Kaydet butonunu kullanarak ekleyebilirsin.';

  @override
  String get watchlistSavedPoints => 'Kaydedilen Noktalar';

  @override
  String watchlistSavedPointsSubtitle(int count) {
    return '$count yangın noktası takipte';
  }

  @override
  String watchlistSyncingTitle(int count) {
    return '$count kaydedilmiş yangın noktası var.';
  }

  @override
  String get watchlistSyncingSubtitle =>
      'NASA verisi yenileniyor olabilir. Kaydedilen noktalar uydu güncellemesinde değişebilir.';

  @override
  String emergencyShareLocationText(String url, String lat, String lng) {
    return '🔥 Acil Durum - Konumum:\n$url\n\nLat: $lat\nLng: $lng\n\nFireWatch TR ile paylaşıldı.';
  }

  @override
  String get emergencyShareLocationSubject => 'Acil Konum Paylaşımı';

  @override
  String get emergencyShareFallbackText =>
      '🔥 Acil Durum bildirimi - FireWatch TR';

  @override
  String get emergencyTitle => 'Acil Durum';

  @override
  String get emergencyPrepCenter => 'Acil Hazırlık Merkezi';

  @override
  String get emergencyQuickToolsTitle => 'Hızlı Müdahale Araçları';

  @override
  String get emergencyQuickToolsSubtitle =>
      'Acil durum anında hızlı erişim, temel hazırlık ve kritik yönlendirmeleri tek ekranda topla.';

  @override
  String get emergencyStayReady => 'Hazır Kal';

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
  String get emergencyShareLocationSubtitle => 'Yakınlarına yer bildir';

  @override
  String get emergencyEvacuationPlan => 'Tahliye Planı';

  @override
  String get emergencyEvacuationPlanSubtitle => 'Çıkış adımlarını gözden geçir';

  @override
  String get emergencyContactLines => 'Acil İletişim Hatları';

  @override
  String get emergencyContactLinesSubtitle => 'Temel numaraları hazır tut';

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
      'Kimlik, önemli evrak ve telefonunu tek yerde tut.';

  @override
  String get emergencyBagSupplies => 'Su, ilaç ve şarj ekipmanı';

  @override
  String get emergencyBagSuppliesSubtitle =>
      'Kısa süreli tahliyede kritik olacak temel ihtiyaçlar.';

  @override
  String get emergencyBagMeetingPoint => 'Yakınlarla buluşma noktası';

  @override
  String get emergencyBagMeetingPointSubtitle =>
      'Ayrı düşme ihtimaline karşı önceden karar ver.';

  @override
  String get emergencyCommNote => 'İletişim Notu';

  @override
  String get emergencyCommNoteSubtitle => 'Panik anında kısa hareket planı';

  @override
  String get emergencyStep1 => '1. Resmi uyarıları doğrula';

  @override
  String get emergencyStep2 => '2. Yakınlarını kısa mesajla haberdar et';

  @override
  String get emergencyStep3 =>
      '3. Gerekliyse temel çantanı al ve güvenli çıkış rotasına yönel';

  @override
  String get safetyGuideTitle => 'Güvenlik Rehberi';

  @override
  String get safetyGuideEmergencyInfo => 'Acil Durum Bilgisi';

  @override
  String get safetyGuideCenterTitle => 'Yangın Güvenlik Merkezi';

  @override
  String get safetyGuideCenterSubtitle =>
      'Yangın sırasında ne yapacağını hızlıca görmek, tahliye mantığını anlamak ve doğru adımları takip etmek için hazırlanmış rehber ekranı.';

  @override
  String get safetyGuideQuickActions => 'Hızlı Aksiyonlar';

  @override
  String get safetyGuideQuickActionsSubtitle =>
      'İlk bakışta kritik davranışlar';

  @override
  String get safetyGuideReadyEvacuate => 'Tahliyeye Hazır Ol';

  @override
  String get safetyGuideReadyEvacuateSubtitle => 'Çıkış planını netleştir';

  @override
  String get safetyGuideTakeSmokeSeriously => 'Dumanı Ciddiye Al';

  @override
  String get safetyGuideTakeSmokeSeriouslySubtitle =>
      'Kapalı alana geç, maske kullan';

  @override
  String get safetyGuideFollowOfficials => 'Yetkili Duyuruları İzle';

  @override
  String get safetyGuideFollowOfficialsSubtitle => 'Resmi kaynakları takip et';

  @override
  String get safetyGuideDontDelay => 'Geç Kalma';

  @override
  String get safetyGuideDontDelaySubtitle => 'Tahliye çağrısını bekletme';

  @override
  String get safetyGuideChecklist => 'Acil Kontrol Listesi';

  @override
  String get safetyGuideChecklistSubtitle => 'Yangın anında temel adımlar';

  @override
  String get safetyGuideChecklist1Title =>
      'Kimlik, telefon ve şarj aletini hazır tut';

  @override
  String get safetyGuideChecklist1Desc =>
      'Zorunlu temel eşyaları tek yerde topla.';

  @override
  String get safetyGuideChecklist2Title =>
      'Kapı ve pencere durumunu kontrol et';

  @override
  String get safetyGuideChecklist2Desc =>
      'Duman girişini azaltmak için açık alanları gözden geçir.';

  @override
  String get safetyGuideChecklist3Title =>
      'Aile / yakınlarınla buluşma planı belirle';

  @override
  String get safetyGuideChecklist3Desc =>
      'Ayrı düşerseniz nerede buluşacağınızı önceden bil.';

  @override
  String get safetyGuideChecklist4Title => 'Resmi tahliye rotasını takip et';

  @override
  String get safetyGuideChecklist4Desc =>
      'Kendi başına riskli güzergah uydurma.';

  @override
  String get safetyGuideDetailedGuide => 'Detaylı Rehber';

  @override
  String get safetyGuideDetailedGuideSubtitle =>
      'Senaryoya göre açılır bilgi kartları';

  @override
  String get safetyGuideAtHomeTitle => 'Evdeysen ne yapmalısın?';

  @override
  String get safetyGuideAtHome1 =>
      'Duman yoğunluğu varsa kapı ve pencereleri kapalı tut.';

  @override
  String get safetyGuideAtHome2 =>
      'Elektrik, gaz ve hızlı çıkış güzergahını kontrol et.';

  @override
  String get safetyGuideAtHome3 =>
      'Tahliye çağrısı varsa eşyaları toplamaya çalışma, çıkışa odaklan.';

  @override
  String get safetyGuideAtHome4 =>
      'Evcil hayvanları mümkünse hızlıca güvenli taşıma düzenine al.';

  @override
  String get safetyGuideInCarTitle => 'Araçtayken ne yapmalısın?';

  @override
  String get safetyGuideInCar1 => 'Yoğun duman içinden geçmeye çalışma.';

  @override
  String get safetyGuideInCar2 =>
      'Mümkünse güvenli açık alana veya yerleşim merkezine yönel.';

  @override
  String get safetyGuideInCar3 =>
      'Aracı kuru otların ve ağaç altlarının yanında bırakma.';

  @override
  String get safetyGuideInCar4 =>
      'Resmi yönlendirme varsa navigasyondan değil, duyurudan ilerle.';

  @override
  String get safetyGuideOutsideTitle => 'Dışarıdaysan ne yapmalısın?';

  @override
  String get safetyGuideOutside1 =>
      'Rüzgar yönünü gözlemle ve yangının önüne geçme.';

  @override
  String get safetyGuideOutside2 =>
      'Yüksek bitki örtüsünden ve dar vadilerden uzaklaş.';

  @override
  String get safetyGuideOutside3 =>
      'Topluluk halinde hareket ediyorsan dağılmadan ilerle.';

  @override
  String get safetyGuideOutside4 =>
      'Acil durumda açık, çıplak ve yanıcı olmayan alana çık.';

  @override
  String get safetyGuideEvacOrderTitle =>
      'Tahliye emri geldiyse ne yapmalısın?';

  @override
  String get safetyGuideEvacOrder1 =>
      'Emri geciktirme, \"biraz daha bekleyeyim\" deme.';

  @override
  String get safetyGuideEvacOrder2 =>
      'Sadece temel eşyaları al ve çıkışa odaklan.';

  @override
  String get safetyGuideEvacOrder3 =>
      'Yakınlarını tek tek arayıp vakit kaybetme, önceden plan kullan.';

  @override
  String get safetyGuideEvacOrder4 =>
      'Yetkililerin toplama alanı duyurusunu takip et.';

  @override
  String get safetyGuideEmergencyNumbers => 'Acil Numaralar';

  @override
  String get safetyGuideEmergencyNumbersSubtitle => 'Hızlı erişim için not düş';

  @override
  String get safetyGuideCallCenterSubtitle => 'Genel acil durum hattı';

  @override
  String get safetyGuideForestNotice => 'Orman Yangını Bildirimi';

  @override
  String get safetyGuideForestNoticeSubtitle => 'Yangın ve orman hattı';

  @override
  String get safetyGuideAfadLocal => 'AFAD / Yerel Yönlendirme';

  @override
  String get safetyGuideAfadLocalNumber => 'Yerel duyuruları takip et';

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
      'Bildirimleri, konum tabanlı uyarıları ve uygulama davranışını buradan özelleştir.';

  @override
  String get settingsNotifications => 'Bildirimler';

  @override
  String get settingsNotificationsSubtitle => 'Uyarı tercihlerini yönet';

  @override
  String get settingsPushNotifications => 'Push Bildirimleri';

  @override
  String get settingsPushNotificationsSubtitle =>
      'Yeni olaylar ve önemli değişiklikler için bildirim al';

  @override
  String get settingsNearbyAlerts => 'Yakındaki Olay Uyarıları';

  @override
  String get settingsNearbyAlertsSubtitle =>
      'Konumuna yakın bölgelerde olay varsa öncelikli göster';

  @override
  String get settingsAppBehavior => 'Uygulama Davranışı';

  @override
  String get settingsAppBehaviorSubtitle => 'Görünüm ve yenileme sıklığı';

  @override
  String get settingsDarkMode => 'Koyu Tema';

  @override
  String get settingsDarkModeSubtitle => 'Premium koyu görünümü aktif tut';

  @override
  String get settingsRefreshInterval => 'Veri Yenileme Aralığı';

  @override
  String get settingsRefreshIntervalSubtitle =>
      'Saha verilerinin ne sıklıkla yenileneceğini seç';

  @override
  String get settingsLanguage => 'Dil';

  @override
  String get settingsLanguageSubtitle => 'Uygulama dilini seç';

  @override
  String get settingsLanguageTurkish => 'Türkçe';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsAppInfo => 'Uygulama Bilgisi';

  @override
  String get settingsAppInfoSubtitle => 'Sürüm ve ürün özeti';

  @override
  String get settingsInfoApp => 'Uygulama';

  @override
  String get settingsInfoVersion => 'Sürüm';

  @override
  String get settingsInfoVersionValue => 'v1.0.0 demo';

  @override
  String get settingsInfoPlatform => 'Platform';

  @override
  String get settingsInfoPlatformValue => 'Flutter / Android';

  @override
  String get settingsInfoPurpose => 'Amaç';

  @override
  String get settingsInfoPurposeValue => 'Yangın odaklı disaster tracking';

  @override
  String get settingsFooterNote =>
      'Tercihlerin cihazında saklanır ve uygulamayı her açtığında otomatik olarak uygulanır.';

  @override
  String get riskTitle => 'Risk Analizi';

  @override
  String get riskLiveView => 'Canlı Risk Görünümü';

  @override
  String get riskSummaryTitle => 'Türkiye Yangın Risk Özeti';

  @override
  String get riskSummarySubtitle =>
      'Open-Meteo hava verisi + NASA FIRMS uydu verisiyle hesaplanmış gerçek zamanlı risk analizi.';

  @override
  String riskHighestRisk(String region, int score) {
    return 'En yüksek risk: $region ($score/100)';
  }

  @override
  String get riskDataLoading => 'Veri yükleniyor...';

  @override
  String get riskKeyIndicators => 'Ana Göstergeler';

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
  String get riskDrynessIndex => 'Kuruluk İndeksi';

  @override
  String get riskDrynessVeryHigh => 'Çok yüksek';

  @override
  String get riskWindPressure => 'Rüzgar Baskısı';

  @override
  String get riskVegetationDensity => 'Bitki Yoğunluğu';

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
    return 'Güçlü rüzgar (${wind}km/h)';
  }

  @override
  String riskNoteMediumWind(int wind) {
    return 'Orta rüzgar (${wind}km/h)';
  }

  @override
  String get newsTitle => 'Haberler';

  @override
  String get newsLiveFeed => 'Canlı Bilgi Akışı';

  @override
  String get newsCenterTitle => 'Yangın Haber Merkezi';

  @override
  String get newsCenterSubtitle =>
      'Saha güncellemeleri, risk uyarıları ve güvenlik odaklı gelişmeleri tek akışta takip et.';

  @override
  String get newsFeatured => 'Öne Çıkan Gelişme';

  @override
  String get newsFeaturedSubtitle => 'Bugünün dikkat çeken başlığı';

  @override
  String get newsCategories => 'Kategoriler';

  @override
  String get newsCategoriesSubtitle => 'Akışı filtrele';

  @override
  String get newsCategoryRisk => 'Risk';

  @override
  String get newsCategoryOperation => 'Operasyon';

  @override
  String get newsCategorySafety => 'Güvenlik';

  @override
  String get newsCategoryUpdate => 'Güncelleme';

  @override
  String get newsRegions => 'Bölgeler';

  @override
  String get newsRegionsSubtitle => 'Bölgeye göre filtrele';

  @override
  String get newsLatest => 'Son Haberler';

  @override
  String newsRecordsFound(int count) {
    return '$count kayıt bulundu';
  }

  @override
  String get newsFetchFailed => 'Haberler yüklenemedi';

  @override
  String newsNoneInRegion(String region) {
    return '$region bölgesinde haber yok.';
  }

  @override
  String get newsNoneInCategory => 'Bu kategoride haber yok.';

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
  String get reportPanelVerifiedTitle => '✅ Rapor Doğrulandı';

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
      'GPS ile konumunuzu alın ve yangını bildirin. NASA verisiyle otomatik doğrulanacak.';

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
}
