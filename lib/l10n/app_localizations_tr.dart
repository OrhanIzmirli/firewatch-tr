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
  String get homeOutsideTurkeyLocation => 'Yurt dışı konumu';

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
  String homeOverviewUniqueCount(int count) {
    return '$count benzersiz yangın noktası tespit edildi';
  }

  @override
  String get homeTotalPoints => 'Toplam Nokta';

  @override
  String get homeHighRisk => 'Yüksek Risk';

  @override
  String get homeNominal => 'Normal';

  @override
  String get homeOverviewActiveFiresTitle => 'Aktif Yangın Noktaları';

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
  String get homeOverviewNearbyTitle => 'Yakın Yangın Uyarısı';

  @override
  String homeOverviewNearbyValueWithLocation(int count) {
    return '$count yangın 100km içinde';
  }

  @override
  String homeOverviewNearbyValueNationwide(int count) {
    return 'Türkiye genelinde $count yangın';
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
    return 'Son güncelleme: $timeAgo';
  }

  @override
  String get homeOverviewNewsNone => 'Henüz haber yok';

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
  String get mapConfidenceFilterActive =>
      'Yalnızca yüksek/nominal güvenli yangınlar gösteriliyor';

  @override
  String get mapConfidenceFilterClear => 'Temizle';

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
      '🌐 Herhangi bir haberi İngilizceye çevirmek için dokunun';

  @override
  String get newsTranslateCardButton => 'Çevir';

  @override
  String get newsContentFiltersTitle => 'Durum Filtreleri';

  @override
  String get newsContentFiltersSubtitle => 'Neler olduğuna göre filtrele';

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

  @override
  String get reportPanelAnonymousToggle => 'Anonim olarak gönder';

  @override
  String get reportPanelAnonymousToggleSubtitle =>
      'İsminiz yetkililerle paylaşılmayacak';

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
  String get reportPanelMapAdjustHint =>
      'Pin konumunu ayarlamak için haritaya dokunun';

  @override
  String get reportPanelSuccessVerifiedTitle => 'Bildirim Doğrulandı';

  @override
  String get reportPanelSuccessReceivedTitle => 'Bildirim Alındı';

  @override
  String get reportPanelSuccessVerifiedBody =>
      'Bildiriminiz NASA uydu verisiyle eşleşti ve doğrulandı olarak işaretlendi.';

  @override
  String get reportPanelSuccessReceivedBody =>
      'Bildiriminiz kaydedildi ve ekibimiz tarafından manuel incelemeyi bekliyor.';

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
      'Burası aktif bir yangın bölgesi — acil durum ekipleri zaten bilgilendirildi.';

  @override
  String get reportPanelResponseTimeReceived =>
      'Eğer bu aktif bir acil durumsa lütfen doğrudan 112\'yi de arayın.';

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
  String offlineBannerLabel(String time) {
    return 'Çevrimdışı mod • Son güncelleme: $time';
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
  String get notifPermTitle => 'Önemli uyarıları kaçırma';

  @override
  String get notifPermSubtitle =>
      'Bildirim izniyle yakınındaki yangın olaylarını ve kritik durum değişikliklerini anında öğrenebilirsin.';

  @override
  String get notifPermNote =>
      'Bu izin zorunlu değil. İstersen şimdilik atlayıp uygulamayı yine kullanabilirsin.';

  @override
  String get notifPermEnable => 'Bildirimleri Etkinleştir';

  @override
  String get notifPermSkip => 'Şimdilik Geç';

  @override
  String get notifPermGranted => 'Bildirim izni verildi. Teşekkürler!';

  @override
  String get notifPermDenied =>
      'Bildirim izni verilmedi. Ayarlardan daha sonra açabilirsin.';

  @override
  String get locPermServiceOff =>
      'Konum servisi kapalı görünüyor. Yine de uygulamaya devam edebilirsin.';

  @override
  String get locPermDenied =>
      'Konum izni verilmedi. Şimdilik konumsuz devam edebilirsin.';

  @override
  String get locPermDeniedForever =>
      'Konum izni kalıcı olarak reddedilmiş. Ayarlardan açabilirsin.';

  @override
  String get locPermError =>
      'Konum izni alınırken bir sorun oluştu. Şimdilik geçebilirsin.';

  @override
  String get locPermTitle => 'Yakınındaki olayları gösterelim';

  @override
  String get locPermSubtitle =>
      'Konum erişimiyle sana yakın yangın olaylarını, riskli bölgeleri ve daha ilgili bildirimleri gösterebiliriz.';

  @override
  String get locPermNote =>
      'Bu izin zorunlu değil. İstersen şimdilik atlayıp uygulamayı yine kullanabilirsin.';

  @override
  String get locPermEnable => 'Konumu Etkinleştir';

  @override
  String get locPermSkip => 'Şimdilik Geç';

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
    return 'Termal sensör ${temp}K ısı tespit etti. Aktif yangın ihtimali yüksek, bölgeye yaklaşma.';
  }

  @override
  String get riskReasonHighNoTemp =>
      'Yüksek güven seviyesinde termal anomali tespit edildi. Aktif yangın olabilir.';

  @override
  String riskReasonMediumWithTemp(String temp) {
    return 'Termal sensör ${temp}K ısı ölçtü. Anız yakma, tarım faaliyeti veya erken evre yangın olabilir.';
  }

  @override
  String get riskReasonMediumNoTemp =>
      'Orta düzey termal anomali. Bölge izleme altında tutulmalı.';

  @override
  String riskReasonLowWithTemp(String temp) {
    return 'Düşük ısı değeri (${temp}K). Sanayi, seracılık veya doğal ısı kaynağı olabilir.';
  }

  @override
  String get riskReasonLowNoTemp =>
      'Düşük seviye termal aktivite. Takip önerilir.';

  @override
  String get fireGeneratedDescHigh =>
      'Yüksek yoğunluklu termal aktivite. Aktif yangın olasılığı ciddi.';

  @override
  String get fireGeneratedDescMedium =>
      'Orta seviye ısı artışı. Bölge izleme gerektirir.';

  @override
  String get fireGeneratedDescLow =>
      'Düşük seviye termal aktivite. Takip önerilir.';

  @override
  String get fireRecommendedActionHigh =>
      'Bölgeden uzak dur, resmi yönlendirmeleri takip et ve tahliye hazırlığını yap.';

  @override
  String get fireRecommendedActionMedium =>
      'Gelişmeleri takip et, bölgeye gereksiz yaklaşma.';

  @override
  String get fireRecommendedActionLow =>
      'Şu an acil aksiyon gerekmiyor, bölgeyi takip et.';

  @override
  String get fireStatusActive => 'Aktif Yangın';

  @override
  String get fireStatusLikelyActive => 'Muhtemelen Aktif';

  @override
  String get fireStatusMonitoring => 'İzleniyor';

  @override
  String get fireStatusHistorical => 'Geçmiş Tespit';

  @override
  String fireEventRegionTitle(String city) {
    return '$city Bölgesi Termal Tespiti';
  }

  @override
  String get fireEventLiveDetectionTitle => 'Canlı Yangın Tespiti';

  @override
  String get fireEventStatusActive => 'Aktif';

  @override
  String get fireEventStatusMonitoring => 'İzleniyor';

  @override
  String get fireEventStatusControlled => 'Kontrol Altında';

  @override
  String get fireEventSpreadHigh => 'Yüksek — aktif izleme gerekli';

  @override
  String get fireEventSpreadMedium => 'Orta — dikkatli takip et';

  @override
  String get fireEventSpreadLow => 'Düşük';

  @override
  String fireDetailAreaMeasured(int hectares) {
    return '~$hectares hektar (NASA uydu ölçümü)';
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
  String get fireDetailFireRadiativePower => 'Ateş Gücü';

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
  String fireEventTempLine(String temp, String kelvin) {
    return 'Sıcaklık: $temp°C (Termal değer: ${kelvin}K)';
  }

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
    return '🔥 Yangın Uyarısı\n\n📍 $title\n📌 $city / $district\n\n🚨 Durum: $status\n⚠️ Risk: $risk\n\n📝 $description\n\nFireWatch TR ile takip ediliyor.';
  }

  @override
  String get notificationsDemoAlertTitle => 'Kritik Yangın Uyarısı';

  @override
  String notificationsDemoAlertBody(String region) {
    return '$region bölgesinde yüksek riskli termal aktivite tespit edildi.';
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
  String get coachMarkMapTitle => 'Harita ve Yangın Noktaları';

  @override
  String get coachMarkMapDesc =>
      'Haritadaki alevli işaretler NASA uydu verisiyle tespit edilen canlı yangın noktalarını gösterir. Bir işarete dokunarak detayları görebilir, buradan yeni bir yangın da bildirebilirsin.';

  @override
  String get coachMarkRiskTitle => 'Risk Seviyeleri';

  @override
  String get coachMarkRiskDesc =>
      'Her yangın noktası Yüksek, Orta veya Düşük risk seviyesiyle etiketlenir. Bu etiketler bölgedeki tehlike derecesini hızlıca anlamanı sağlar.';

  @override
  String get coachMarkWatchlistTitle => 'Kaydedilenler';

  @override
  String get coachMarkWatchlistDesc =>
      'Takip etmek istediğin yangın noktalarını kaydet ve buradan hızlıca tekrar ulaş.';

  @override
  String get coachMarkNotificationsTitle => 'Bildirimler';

  @override
  String get coachMarkNotificationsDesc =>
      'Yakınındaki yangınlar için anlık bildirim al ve otomatik taramayı buradan başlat.';

  @override
  String get riskTabTurkeyOverview => 'Türkiye Geneli';

  @override
  String get riskTabMyLocation => 'Konumum';

  @override
  String get riskMyLocationGettingLocation => 'Konumunuz alınıyor...';

  @override
  String get riskMyLocationPermissionDenied =>
      'Konum izni verilmedi. Bölge risk bilgisini görmek için izin ver.';

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
    return 'Bölgen: $city ($region)';
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
  String get riskChartTapHint => 'Detaylar için bir bölgeye dokun';

  @override
  String get monitorStatusReady => 'Monitoring servisi hazır.';

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
  String get monitorStatusNoActiveFires =>
      'Şu an aktif yangın verisi bulunamadı.';

  @override
  String monitorStatusNoNearbyFires(int count) {
    return '✅ 50 km içinde canlı yangın tespiti yok. ($count nokta tarandı)';
  }

  @override
  String monitorStatusNearbyFiresFound(int count) {
    return '⚠️ 50 km içinde $count yangın noktası bulundu!';
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
  String get notifNearbyFireTitle => 'Yakınında yangın tespiti var';

  @override
  String notifNearbyFireBody(String distance, int count) {
    return '$distance içinde $count yangın noktası bulundu.';
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
    return 'PostGIS • $distance km uzaklıkta';
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
      'NASA Yangın Sayısı (en fazla 20 puan)';

  @override
  String get riskInfoSourcesTitle => 'Veri Kaynakları';

  @override
  String get riskInfoSourcesBody =>
      'NASA FIRMS uydu verisi, Open-Meteo hava durumu verisi ve RSS haber akışları kullanılarak hesaplanır.';

  @override
  String get riskInfoUpdateFrequencyTitle => 'Güncelleme Sıklığı';

  @override
  String get riskInfoUpdateFrequencyBody =>
      'Risk skorları her 3 saatte bir yeniden hesaplanır.';

  @override
  String get trustHomeInfo =>
      'Veriler NASA FIRMS uydu görüntülerinden alınır, her 3 saatte bir güncellenir.';

  @override
  String get trustMapInfo =>
      'Yangın işaretleri VIIRS uydusu tarafından tespit edilen termal anomalileri gösterir.';

  @override
  String get trustRiskInfo =>
      'Risk skorları gerçek zamanlı hava durumu ve NASA yangın verisinden hesaplanır.';

  @override
  String get trustNewsInfo =>
      'Haberler 9 Türk kaynağından yangınla ilgili içerik için filtrelenir.';

  @override
  String get trustAlertsInfo =>
      'Konumunuza 50 km içinde yangın tespit edildiğinde bildirim gönderilir.';

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
      'Bu ekrandaki yangın sayıları, son 24 saatte tespit edilen aktif ısı anomalileridir; doğrulanmış orman yangını değildir — bazıları tarımsal yakma veya endüstriyel ısı kaynakları olabilir.';

  @override
  String get trustHomeSource =>
      'Veriler NASA FIRMS\'ten (Yangın Bilgi ve Kaynak Yönetim Sistemi) gelir; VIIRS ve MODIS uydu geçişlerini birleştirir ve her 3 saatte bir güncellenir.';

  @override
  String get trustHomeInterpret =>
      'Bir bölgedeki yüksek yangın sayısı her zaman yüksek tehlike anlamına gelmez — sonuca varmadan önce hava durumuna göre ayarlanmış risk puanları için Risk sekmesini kontrol edin.';

  @override
  String get trustHomeAction =>
      'Tam detayları görmek için herhangi bir yangın kartına dokunun veya güncellemeleri takip etmek için İzleme Listenize ekleyin. Aktif bir yangına yakınsanız gerçek zamanlı uyarılar için Bildirimler\'i kontrol edin.';

  @override
  String get trustMapMeaning =>
      'Her işaretçi tek bir uydu sıcak nokta tespitidir, mutlaka aktif bir yangın anlamına gelmez — yangın detaylarında gösterilen güven düzeyi tespitin ne kadar güvenilir olduğunu gösterir.';

  @override
  String get trustMapSource =>
      'Yangın verileri NASA FIRMS\'ten (VIIRS ve MODIS uyduları) alınır. EFFIS (Kopernik Acil Durum Yönetim Servisi) API\'si yeniden erişime açıldığında ikincil doğrulama kaynağı olarak eklenecektir.';

  @override
  String get trustMapInterpret =>
      'Kümelenmiş sayılar birbirine yakın birden fazla tespit olduğu anlamına gelir — tek tek noktaları görmek için yakınlaştırın. Sıkı kümeler genellikle daha büyük, devam eden bir yangına işaret eder.';

  @override
  String get trustMapAction =>
      'Haritada olmayan bir yangını yerinde mi gördünüz? Diğerlerini uyarmak için Rapor Et düğmesini kullanın. Mevcut konumunuza yakın olanları görmek için \"Yakındaki Yangınlar\"a dokunun.';

  @override
  String get trustRiskMeaning =>
      'Risk puanı (0-100), sıcaklık, nem, rüzgar hızı ve kuraklığı birleştirerek orman yangını olasılığını tahmin eder — bu bir tahmindir, garanti değildir.';

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
      'Uyarılar, uydu son bilinen konumunuzun 50 km içinde bir yangın tespit ettiğinde sizi bilgilendirir — bunlar otomatiktir ve doğrulanmış raporlara değil tespit verilerine dayanır.';

  @override
  String get trustAlertsSource =>
      'Arka plan izleme, NASA FIRMS verilerini belirli aralıklarla kontrol eder ve yeni tespitleri cihazınızın son bilinen konumuyla karşılaştırır.';

  @override
  String get trustAlertsInterpret =>
      '\"Yüksek güven\" uyarıları \"nominal\" olanlardan daha güvenilirdir — o uyarıyı tetikleyen belirli faktörler için her karttaki risk nedeni metnini kontrol edin.';

  @override
  String get trustAlertsAction =>
      'Uygulama kapalıyken bile uyarı almak için bildirim izni verin ve Otomatik İzlemeyi başlatın. Çevrenizi manuel olarak kontrol etmek için istediğiniz zaman \"Şimdi Tara\"yı kullanın.';

  @override
  String get newsReadFullArticle => 'Haberin Tamamını Oku';

  @override
  String smartIntensityIntense(String location) {
    return '$location yakınında yoğun ve şiddetli bir yangın tespit edildi.';
  }

  @override
  String smartIntensityHigh(String location) {
    return '$location yakınında yüksek yoğunluklu, aktif bir yangın tespit edildi.';
  }

  @override
  String smartIntensityModerate(String location) {
    return '$location yakınında orta düzeyde termal aktivite tespit edildi.';
  }

  @override
  String smartIntensityEarly(String location) {
    return '$location yakınında erken evre bir yangın veya için için yanan bitki örtüsü olabilir.';
  }

  @override
  String smartIntensityAnomaly(String location) {
    return '$location yakınında bir termal anomali tespit edildi.';
  }

  @override
  String get smartLocationHintForest => 'ormanlık, yüksek riskli bir bölgede';

  @override
  String get smartLocationHintCoastal => 'kıyı bölgesinde';

  @override
  String get smartLocationHintUrban =>
      'kentsel alanda; yapısal bir yangın veya endüstriyel ısı kaynağı olabilir';

  @override
  String get smartLocationHintAgricultural =>
      'tarım arazisinde; anız yakma ihtimali var';

  @override
  String get smartFrpHigh =>
      'Yüksek ısıl güç (FRP) değeri ciddi bir enerji yayılımına işaret ediyor.';

  @override
  String smartAreaLarge(int hectares) {
    return 'Tahmini yangın alanı geniş (~$hectares hektar).';
  }

  @override
  String smartAreaMedium(int hectares) {
    return 'Tahmini yangın alanı orta büyüklükte (~$hectares hektar).';
  }

  @override
  String get smartConfidenceHigh =>
      'NASA uydusu bu tespitten yüksek düzeyde emin.';

  @override
  String get smartConfidenceMedium =>
      'Muhtemelen bir yangın, doğrulama öneriliyor.';

  @override
  String get smartConfidenceLow =>
      'Olası bir termal anomali — endüstriyel ısı veya yansıma olabilir, doğrulama gerekiyor.';

  @override
  String get smartSpreadDangerous =>
      'Bölgedeki düşük nem ve güçlü rüzgar nedeniyle yayılma riski yüksek.';

  @override
  String get smartSpreadModerate => 'Bölgedeki yayılma riski orta düzeyde.';

  @override
  String get smartSpreadLow =>
      'Bölgedeki koşullar yayılma için pek uygun değil.';

  @override
  String smartTimeJustNow(String satellite) {
    return 'Az önce $satellite tarafından tespit edildi.';
  }

  @override
  String smartTimeRecent(int hours, String satellite) {
    return '$hours saat önce $satellite tarafından tespit edildi, hâlâ aktif olabilir.';
  }

  @override
  String smartTimeOlder(int hours) {
    return '$hours saat önce tespit edildi, mevcut durumu bilinmiyor.';
  }

  @override
  String smartTimeHistorical(int days) {
    return '$days gün önce yapılmış eski bir tespit; söndürülmüş olabilir.';
  }

  @override
  String get tooltipTempTitle => 'Sıcaklık';

  @override
  String get tooltipTempBody =>
      'Uydu yüzey sıcaklığı. Normal zemin: 25-35°C. 50°C+ ısı anomalisi. 100°C+ aktif yangın.';

  @override
  String get tooltipConfidenceTitle => 'Güven Seviyesi Ne Anlama Gelir?';

  @override
  String get tooltipSatelliteTitle => 'Uydu Ne Anlama Gelir?';

  @override
  String get tooltipSatelliteViirsBody =>
      'VIIRS: Suomi NPP uydusu, Türkiye üzerinden günde 1-2 kez geçer.';

  @override
  String get tooltipSatelliteModisBody =>
      'MODIS: Terra/Aqua uydusu, daha geniş bir kapsama alanı sağlar.';

  @override
  String get tooltipSatelliteMergedBody =>
      'Bu yangın, aynı zaman ve konum aralığında birden fazla uydu cihazı tarafından bağımsız olarak doğrulandı — tek bir tespitten daha güvenilirdir.';

  @override
  String get fireCardMultiSourceBadge => 'Çoklu kaynakla doğrulandı';

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
  String get coachMarkMapMarkersTitle => 'Yangın İşaretleri';

  @override
  String get coachMarkMapMarkersDesc =>
      'Haritadaki alev ikonları NASA uydusundan gelen canlı yangın tespitlerini gösterir. Bir işarete dokunarak detayları görebilirsin.';

  @override
  String get coachMarkMapClustersTitle => 'Küme Sayıları';

  @override
  String get coachMarkMapClustersDesc =>
      'Birbirine yakın yangın noktaları bir araya toplanır ve üzerinde sayı gösteren bir daire olarak görünür. Yakınlaştırdıkça kümeler ayrışır.';

  @override
  String get coachMarkMapReportTitle => 'Yangın Bildir';

  @override
  String get coachMarkMapReportDesc =>
      'Sağ alttaki butona dokunarak gördüğün bir yangını GPS konumunla birlikte bildirebilirsin.';

  @override
  String get coachMarkMapNearbyTitle => 'Yakınımdaki Yangınlar';

  @override
  String get coachMarkMapNearbyDesc =>
      'Bu bölüm, konumuna en yakın canlı yangın tespitlerini mesafe sırasına göre listeler.';

  @override
  String get coachMarkNewsFeaturedTitle => 'Öne Çıkan Haber';

  @override
  String get coachMarkNewsFeaturedDesc =>
      'Günün en önemli gelişmesi burada öne çıkarılır.';

  @override
  String get coachMarkNewsCategoryTitle => 'Kategoriler';

  @override
  String get coachMarkNewsCategoryDesc =>
      'Haberleri Risk, Operasyon, Güvenlik veya Güncelleme kategorisine göre filtreleyebilirsin.';

  @override
  String get coachMarkNewsRegionTitle => 'Durum Filtreleri';

  @override
  String get coachMarkNewsRegionDesc =>
      'Önem derecesine göre filtrele — kritik, aktif, izleniyor, bilgi — ya da sadece kendi bölgeni gör.';

  @override
  String get coachMarkNewsListTitle => 'Habere Dokun';

  @override
  String get coachMarkNewsListDesc =>
      'Bir habere dokunarak tam metnini oku; İngilizce moddaysan başlık ve özeti tek dokunuşla çevirebilirsin.';

  @override
  String get coachMarkNotifPermissionTitle => 'Bildirim İzni';

  @override
  String get coachMarkNotifPermissionDesc =>
      'Yakınındaki yangınlar için anlık bildirim alabilmek üzere izin ver.';

  @override
  String get coachMarkNotifScanTitle => 'Şimdi Tara';

  @override
  String get coachMarkNotifScanDesc =>
      'Konumunun 50 km çevresinde canlı yangın olup olmadığını anında kontrol et.';

  @override
  String get coachMarkNotifMonitoringTitle => 'Otomatik Tarama';

  @override
  String get coachMarkNotifMonitoringDesc =>
      'Otomatik taramayı başlatarak uygulama kapalıyken bile periyodik olarak yakın çevrende kontrol yapılmasını sağla.';

  @override
  String get coachMarkNotifAlertsTitle => 'Uyarı Kartları';

  @override
  String get coachMarkNotifAlertsDesc =>
      'Yüksek riskli tespitler burada listelenir; bir karta dokunarak tam detaya ulaşabilirsin.';

  @override
  String get coachMarkRiskScoreTitle => 'Risk Skoru';

  @override
  String get coachMarkRiskScoreDesc =>
      '0-100 arası bu skor, sıcaklık, nem, rüzgar ve NASA yangın verisinden hesaplanır. Nasıl hesaplandığını ℹ️ butonundan öğrenebilirsin.';

  @override
  String get coachMarkRiskChartTitle => 'Bölgesel Dağılım';

  @override
  String get coachMarkRiskChartDesc =>
      'Bir bölge çubuğuna dokunarak o bölgenin detaylı risk analizini görebilirsin.';

  @override
  String get coachMarkRiskMyLocationTabTitle => 'Konumum';

  @override
  String get coachMarkRiskMyLocationTabDesc =>
      'Bu sekmeye geçerek kendi bölgenin riskini Türkiye ortalamasıyla karşılaştır.';

  @override
  String get coachMarkRiskInfoTitle => 'Veri Kaynakları';

  @override
  String get coachMarkRiskInfoDesc =>
      'ℹ️ butonu risk skorunun formülünü, veri kaynaklarını ve güncelleme sıklığını açıklar.';

  @override
  String get coachMarkWatchlistPurposeTitle => 'Kaydedilenler Ne İşe Yarar?';

  @override
  String get coachMarkWatchlistPurposeDesc =>
      'Takip etmek istediğin yangın noktalarını burada bir arada tutabilirsin.';

  @override
  String get coachMarkWatchlistHowToAddTitle => 'Nasıl Eklenir?';

  @override
  String get coachMarkWatchlistHowToAddDesc =>
      'Bir yangının detay ekranındaki yer imi butonuna dokunarak onu buraya kaydedebilirsin.';

  @override
  String get coachMarkWatchlistClearTitle => 'Temizle';

  @override
  String get coachMarkWatchlistClearDesc =>
      'Üst köşedeki Temizle butonuyla tüm kayıtlı noktaları tek seferde kaldırabilirsin.';

  @override
  String get coachMarkWatchlistTapTitle => 'Detayı Gör';

  @override
  String get coachMarkWatchlistTapDesc =>
      'Kaydedilen bir yangına dokunarak güncel durumunu ve tam detaylarını görebilirsin.';
}
