import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appName.
  ///
  /// In tr, this message translates to:
  /// **'FireWatch TR'**
  String get appName;

  /// No description provided for @navHome.
  ///
  /// In tr, this message translates to:
  /// **'Ana Sayfa'**
  String get navHome;

  /// No description provided for @navMap.
  ///
  /// In tr, this message translates to:
  /// **'Harita'**
  String get navMap;

  /// No description provided for @navNews.
  ///
  /// In tr, this message translates to:
  /// **'Haberler'**
  String get navNews;

  /// No description provided for @navAlerts.
  ///
  /// In tr, this message translates to:
  /// **'Uyarılar'**
  String get navAlerts;

  /// No description provided for @navSettings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get navSettings;

  /// No description provided for @commonDetail.
  ///
  /// In tr, this message translates to:
  /// **'Detay'**
  String get commonDetail;

  /// No description provided for @commonRefresh.
  ///
  /// In tr, this message translates to:
  /// **'Yenile'**
  String get commonRefresh;

  /// No description provided for @commonViewOnMap.
  ///
  /// In tr, this message translates to:
  /// **'Haritada Gör'**
  String get commonViewOnMap;

  /// No description provided for @commonOpenOnMap.
  ///
  /// In tr, this message translates to:
  /// **'Haritada Aç'**
  String get commonOpenOnMap;

  /// No description provided for @commonShare.
  ///
  /// In tr, this message translates to:
  /// **'Paylaş'**
  String get commonShare;

  /// No description provided for @commonCancel.
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get commonSave;

  /// No description provided for @commonLoading.
  ///
  /// In tr, this message translates to:
  /// **'Yükleniyor...'**
  String get commonLoading;

  /// No description provided for @commonTemperature.
  ///
  /// In tr, this message translates to:
  /// **'Sıcaklık'**
  String get commonTemperature;

  /// No description provided for @commonSatellite.
  ///
  /// In tr, this message translates to:
  /// **'Uydu'**
  String get commonSatellite;

  /// No description provided for @commonCoordinate.
  ///
  /// In tr, this message translates to:
  /// **'Koordinat'**
  String get commonCoordinate;

  /// No description provided for @commonWind.
  ///
  /// In tr, this message translates to:
  /// **'Rüzgar'**
  String get commonWind;

  /// No description provided for @commonRisk.
  ///
  /// In tr, this message translates to:
  /// **'Risk'**
  String get commonRisk;

  /// No description provided for @commonStatus.
  ///
  /// In tr, this message translates to:
  /// **'Durum'**
  String get commonStatus;

  /// No description provided for @commonAnonymous.
  ///
  /// In tr, this message translates to:
  /// **'Anonim'**
  String get commonAnonymous;

  /// No description provided for @commonAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get commonAll;

  /// No description provided for @commonHigh.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek'**
  String get commonHigh;

  /// No description provided for @commonMedium.
  ///
  /// In tr, this message translates to:
  /// **'Orta'**
  String get commonMedium;

  /// No description provided for @commonLow.
  ///
  /// In tr, this message translates to:
  /// **'Düşük'**
  String get commonLow;

  /// No description provided for @commonCritical.
  ///
  /// In tr, this message translates to:
  /// **'Kritik'**
  String get commonCritical;

  /// No description provided for @commonEmergency.
  ///
  /// In tr, this message translates to:
  /// **'Acil Durum'**
  String get commonEmergency;

  /// No description provided for @commonTryAgain.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Dene'**
  String get commonTryAgain;

  /// No description provided for @commonRetry.
  ///
  /// In tr, this message translates to:
  /// **'Yenile'**
  String get commonRetry;

  /// No description provided for @commonDistance.
  ///
  /// In tr, this message translates to:
  /// **'Uzaklık'**
  String get commonDistance;

  /// No description provided for @commonDetection.
  ///
  /// In tr, this message translates to:
  /// **'Tespit'**
  String get commonDetection;

  /// No description provided for @regionEge.
  ///
  /// In tr, this message translates to:
  /// **'Ege'**
  String get regionEge;

  /// No description provided for @regionAkdeniz.
  ///
  /// In tr, this message translates to:
  /// **'Akdeniz'**
  String get regionAkdeniz;

  /// No description provided for @regionMarmara.
  ///
  /// In tr, this message translates to:
  /// **'Marmara'**
  String get regionMarmara;

  /// No description provided for @regionKaradeniz.
  ///
  /// In tr, this message translates to:
  /// **'Karadeniz'**
  String get regionKaradeniz;

  /// No description provided for @regionIcAnadolu.
  ///
  /// In tr, this message translates to:
  /// **'İç Anadolu'**
  String get regionIcAnadolu;

  /// No description provided for @regionDoguAnadolu.
  ///
  /// In tr, this message translates to:
  /// **'Doğu Anadolu'**
  String get regionDoguAnadolu;

  /// No description provided for @regionGuneydoguAnadolu.
  ///
  /// In tr, this message translates to:
  /// **'Güneydoğu Anadolu'**
  String get regionGuneydoguAnadolu;

  /// No description provided for @regionTurkiyeGeneli.
  ///
  /// In tr, this message translates to:
  /// **'Türkiye Geneli'**
  String get regionTurkiyeGeneli;

  /// No description provided for @timeAgoJustNow.
  ///
  /// In tr, this message translates to:
  /// **'Az önce'**
  String get timeAgoJustNow;

  /// No description provided for @timeAgoMinutes.
  ///
  /// In tr, this message translates to:
  /// **'{minutes} dakika önce'**
  String timeAgoMinutes(int minutes);

  /// No description provided for @timeAgoHours.
  ///
  /// In tr, this message translates to:
  /// **'{hours} saat önce'**
  String timeAgoHours(int hours);

  /// No description provided for @timeAgoDays.
  ///
  /// In tr, this message translates to:
  /// **'{days} gün önce'**
  String timeAgoDays(int days);

  /// No description provided for @splashTagline.
  ///
  /// In tr, this message translates to:
  /// **'Yangınları takip et, güvende kal'**
  String get splashTagline;

  /// No description provided for @onboardingSkip.
  ///
  /// In tr, this message translates to:
  /// **'Geç'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In tr, this message translates to:
  /// **'Sonraki'**
  String get onboardingNext;

  /// No description provided for @onboardingContinue.
  ///
  /// In tr, this message translates to:
  /// **'Devam Et'**
  String get onboardingContinue;

  /// No description provided for @onboardingTitle1.
  ///
  /// In tr, this message translates to:
  /// **'Aktif olayları takip et'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In tr, this message translates to:
  /// **'Türkiye genelindeki yangın olaylarını tek ekranda takip et ve durum değişikliklerini hızlıca gör.'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In tr, this message translates to:
  /// **'Yakınındaki bölgeleri gör'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In tr, this message translates to:
  /// **'Harita ve bölge odaklı ekranlarla sana yakın olayları daha hızlı fark et.'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In tr, this message translates to:
  /// **'Güvenlik yönlendirmeleri al'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In tr, this message translates to:
  /// **'Risk seviyelerini incele, önerilen aksiyonları gör ve gerektiğinde hızlı hareket et.'**
  String get onboardingDesc3;

  /// No description provided for @homeLiveSummary.
  ///
  /// In tr, this message translates to:
  /// **'Canlı Durum Özeti'**
  String get homeLiveSummary;

  /// No description provided for @homeHeaderTitle.
  ///
  /// In tr, this message translates to:
  /// **'Türkiye Termal Anomali Takibi'**
  String get homeHeaderTitle;

  /// No description provided for @homeHeaderSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Aktif olayları takip et, risk seviyelerini gör ve güvenlik rehberine hızlıca ulaş.'**
  String get homeHeaderSubtitle;

  /// No description provided for @homeNasaLiveData.
  ///
  /// In tr, this message translates to:
  /// **'NASA FIRMS • Canlı Veri'**
  String get homeNasaLiveData;

  /// No description provided for @homeOutsideTurkeyLocation.
  ///
  /// In tr, this message translates to:
  /// **'Yurt dışı konumu'**
  String get homeOutsideTurkeyLocation;

  /// No description provided for @homeLocationUnavailable.
  ///
  /// In tr, this message translates to:
  /// **'Konum alınamadı'**
  String get homeLocationUnavailable;

  /// No description provided for @homeLocationEmulatorTest.
  ///
  /// In tr, this message translates to:
  /// **'Emülatör konumu'**
  String get homeLocationEmulatorTest;

  /// No description provided for @homeRiskAnalysis.
  ///
  /// In tr, this message translates to:
  /// **'Risk Analizi'**
  String get homeRiskAnalysis;

  /// No description provided for @homeSaved.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedilenler ({count})'**
  String homeSaved(int count);

  /// No description provided for @homeSafety.
  ///
  /// In tr, this message translates to:
  /// **'Güvenlik'**
  String get homeSafety;

  /// No description provided for @homeOverview.
  ///
  /// In tr, this message translates to:
  /// **'Genel Bakış'**
  String get homeOverview;

  /// No description provided for @homeOverviewSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'NASA FIRMS anlık verisi'**
  String get homeOverviewSubtitle;

  /// No description provided for @homeOverviewUniqueCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} benzersiz termal anomali konumu tespit edildi'**
  String homeOverviewUniqueCount(int count);

  /// No description provided for @homeTotalPoints.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Nokta'**
  String get homeTotalPoints;

  /// No description provided for @homeHighRisk.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek Risk'**
  String get homeHighRisk;

  /// No description provided for @homeNominal.
  ///
  /// In tr, this message translates to:
  /// **'Normal'**
  String get homeNominal;

  /// No description provided for @homeOverviewActiveFiresTitle.
  ///
  /// In tr, this message translates to:
  /// **'Güncel Termal Anomaliler'**
  String get homeOverviewActiveFiresTitle;

  /// No description provided for @homeOverviewActiveFiresSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Son 24 saatte tespit edildi'**
  String get homeOverviewActiveFiresSubtitle;

  /// No description provided for @homeOverviewHighestRiskTitle.
  ///
  /// In tr, this message translates to:
  /// **'En Yüksek Riskli Bölge'**
  String get homeOverviewHighestRiskTitle;

  /// No description provided for @homeOverviewHighestRiskValue.
  ///
  /// In tr, this message translates to:
  /// **'{region} - {score} puan'**
  String homeOverviewHighestRiskValue(String region, int score);

  /// No description provided for @homeOverviewHighestRiskSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Şu an Türkiye\'deki en yüksek risk'**
  String get homeOverviewHighestRiskSubtitle;

  /// No description provided for @homeOverviewNearbyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yakındaki Termal Tespitler'**
  String get homeOverviewNearbyTitle;

  /// No description provided for @homeOverviewNearbyValueWithLocation.
  ///
  /// In tr, this message translates to:
  /// **'100 km içinde {count} tespit'**
  String homeOverviewNearbyValueWithLocation(int count);

  /// No description provided for @homeOverviewNearbyValueNationwide.
  ///
  /// In tr, this message translates to:
  /// **'Türkiye genelinde {count} tespit'**
  String homeOverviewNearbyValueNationwide(int count);

  /// No description provided for @homeOverviewNearbySubtitleLocated.
  ///
  /// In tr, this message translates to:
  /// **'GPS konumunuza göre'**
  String get homeOverviewNearbySubtitleLocated;

  /// No description provided for @homeOverviewNearbySubtitleFallback.
  ///
  /// In tr, this message translates to:
  /// **'Konum bulunamadı — ülke geneli gösteriliyor'**
  String get homeOverviewNearbySubtitleFallback;

  /// No description provided for @homeOverviewNewsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Haber Güncellemesi'**
  String get homeOverviewNewsTitle;

  /// No description provided for @homeOverviewNewsValue.
  ///
  /// In tr, this message translates to:
  /// **'{count} yeni haber'**
  String homeOverviewNewsValue(int count);

  /// No description provided for @homeOverviewNewsSubtitleUpdated.
  ///
  /// In tr, this message translates to:
  /// **'Son güncelleme: {timeAgo}'**
  String homeOverviewNewsSubtitleUpdated(String timeAgo);

  /// No description provided for @homeOverviewNewsNone.
  ///
  /// In tr, this message translates to:
  /// **'Henüz haber yok'**
  String get homeOverviewNewsNone;

  /// No description provided for @homeLatestNews.
  ///
  /// In tr, this message translates to:
  /// **'Son Haberler'**
  String get homeLatestNews;

  /// No description provided for @homeLatestNewsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Öne çıkan gelişmeler'**
  String get homeLatestNewsSubtitle;

  /// No description provided for @homeBreakingCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} sıcak'**
  String homeBreakingCount(int count);

  /// No description provided for @homeNewsLoading.
  ///
  /// In tr, this message translates to:
  /// **'Haber yükleniyor...'**
  String get homeNewsLoading;

  /// No description provided for @homeActiveThermalPoints.
  ///
  /// In tr, this message translates to:
  /// **'Aktif Termal Noktalar'**
  String get homeActiveThermalPoints;

  /// No description provided for @homeActiveThermalSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'NASA FIRMS • PostGIS şehir tespiti'**
  String get homeActiveThermalSubtitle;

  /// No description provided for @homeMap.
  ///
  /// In tr, this message translates to:
  /// **'Harita'**
  String get homeMap;

  /// No description provided for @homeFilterHighRisk.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek Risk'**
  String get homeFilterHighRisk;

  /// No description provided for @homeFilterMediumRisk.
  ///
  /// In tr, this message translates to:
  /// **'Orta Risk'**
  String get homeFilterMediumRisk;

  /// No description provided for @homeSearchHint.
  ///
  /// In tr, this message translates to:
  /// **'Şehir veya bölge ara...'**
  String get homeSearchHint;

  /// No description provided for @homeNoActiveFires.
  ///
  /// In tr, this message translates to:
  /// **'Güncel termal anomali bulunamadı.'**
  String get homeNoActiveFires;

  /// No description provided for @homeFireRegionTitle.
  ///
  /// In tr, this message translates to:
  /// **'{region} Bölgesi'**
  String homeFireRegionTitle(String region);

  /// No description provided for @homeEstimatedArea.
  ///
  /// In tr, this message translates to:
  /// **'Tahmini Alan'**
  String get homeEstimatedArea;

  /// No description provided for @homeAreaOver100Ha.
  ///
  /// In tr, this message translates to:
  /// **'100 hektardan fazla'**
  String get homeAreaOver100Ha;

  /// No description provided for @homeArea10to100Ha.
  ///
  /// In tr, this message translates to:
  /// **'10–100 hektar'**
  String get homeArea10to100Ha;

  /// No description provided for @homeAreaUnder10Ha.
  ///
  /// In tr, this message translates to:
  /// **'10 hektardan az'**
  String get homeAreaUnder10Ha;

  /// No description provided for @homeAreaInsufficientRes.
  ///
  /// In tr, this message translates to:
  /// **'Uydu çözünürlüğü yetersiz'**
  String get homeAreaInsufficientRes;

  /// No description provided for @mapFetchError.
  ///
  /// In tr, this message translates to:
  /// **'Yangın verileri alınamadı.'**
  String get mapFetchError;

  /// No description provided for @mapTitle.
  ///
  /// In tr, this message translates to:
  /// **'Termal Anomali Haritası'**
  String get mapTitle;

  /// No description provided for @mapTitleEvents.
  ///
  /// In tr, this message translates to:
  /// **'Yangın Haritası'**
  String get mapTitleEvents;

  /// No description provided for @mapTitleDetections.
  ///
  /// In tr, this message translates to:
  /// **'Termal Tespit Haritası'**
  String get mapTitleDetections;

  /// No description provided for @mapLiveMap.
  ///
  /// In tr, this message translates to:
  /// **'Canlı Harita'**
  String get mapLiveMap;

  /// No description provided for @mapConfidenceFilterActive.
  ///
  /// In tr, this message translates to:
  /// **'Yalnızca yüksek/nominal güvenilirlikli tespitler gösteriliyor'**
  String get mapConfidenceFilterActive;

  /// No description provided for @mapConfidenceFilterClear.
  ///
  /// In tr, this message translates to:
  /// **'Temizle'**
  String get mapConfidenceFilterClear;

  /// No description provided for @mapHeaderTitle.
  ///
  /// In tr, this message translates to:
  /// **'Türkiye Geneli Yangın Görünümü'**
  String get mapHeaderTitle;

  /// No description provided for @mapHeaderSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'NASA FIRMS uydu verisi. Olaylar ve ham tespitler.'**
  String get mapHeaderSubtitle;

  /// No description provided for @mapArea.
  ///
  /// In tr, this message translates to:
  /// **'Harita Alanı'**
  String get mapArea;

  /// No description provided for @mapAreaSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'NASA FIRMS canlı marker görünümü'**
  String get mapAreaSubtitle;

  /// No description provided for @mapGoToMe.
  ///
  /// In tr, this message translates to:
  /// **'Bana Git'**
  String get mapGoToMe;

  /// No description provided for @mapNearbyFires.
  ///
  /// In tr, this message translates to:
  /// **'Yakınımdaki Termal Tespitler'**
  String get mapNearbyFires;

  /// No description provided for @mapNearbyFiresSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Konumuna en yakın canlı tespitler'**
  String get mapNearbyFiresSubtitle;

  /// No description provided for @mapReport.
  ///
  /// In tr, this message translates to:
  /// **'Raporla'**
  String get mapReport;

  /// No description provided for @mapKmAway.
  ///
  /// In tr, this message translates to:
  /// **'{distance} km uzaklıkta'**
  String mapKmAway(String distance);

  /// No description provided for @fireDetailTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tespit Detayı'**
  String get fireDetailTitle;

  /// No description provided for @fireDetailLastUpdate.
  ///
  /// In tr, this message translates to:
  /// **'Son güncelleme: {time}'**
  String fireDetailLastUpdate(String time);

  /// No description provided for @fireDetailKeyMetrics.
  ///
  /// In tr, this message translates to:
  /// **'Temel Metrikler'**
  String get fireDetailKeyMetrics;

  /// No description provided for @fireDetailEventInfo.
  ///
  /// In tr, this message translates to:
  /// **'Olay Bilgileri'**
  String get fireDetailEventInfo;

  /// No description provided for @fireDetailCity.
  ///
  /// In tr, this message translates to:
  /// **'Şehir'**
  String get fireDetailCity;

  /// No description provided for @fireDetailDistrict.
  ///
  /// In tr, this message translates to:
  /// **'İlçe'**
  String get fireDetailDistrict;

  /// No description provided for @fireDetailStarted.
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç'**
  String get fireDetailStarted;

  /// No description provided for @fireDetailSpreadRisk.
  ///
  /// In tr, this message translates to:
  /// **'Yayılım Riski'**
  String get fireDetailSpreadRisk;

  /// No description provided for @fireDetailAffectedArea.
  ///
  /// In tr, this message translates to:
  /// **'Etkilenen Alan'**
  String get fireDetailAffectedArea;

  /// No description provided for @fireDetailRecommendedActions.
  ///
  /// In tr, this message translates to:
  /// **'Önerilen Aksiyonlar'**
  String get fireDetailRecommendedActions;

  /// No description provided for @fireDetailAddedToWatchlist.
  ///
  /// In tr, this message translates to:
  /// **'Olay watchlist listesine eklendi.'**
  String get fireDetailAddedToWatchlist;

  /// No description provided for @fireDetailRemovedFromWatchlist.
  ///
  /// In tr, this message translates to:
  /// **'Olay watchlist listesinden kaldırıldı.'**
  String get fireDetailRemovedFromWatchlist;

  /// No description provided for @fireDetailSaved.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedildi'**
  String get fireDetailSaved;

  /// No description provided for @fireDetailSaveToWatchlist.
  ///
  /// In tr, this message translates to:
  /// **'Watchlist\'e Kaydet'**
  String get fireDetailSaveToWatchlist;

  /// No description provided for @fireDetailRelatedNews.
  ///
  /// In tr, this message translates to:
  /// **'İlgili Haberler'**
  String get fireDetailRelatedNews;

  /// No description provided for @fireDetailNoNewsFound.
  ///
  /// In tr, this message translates to:
  /// **'Haber bulunamadı'**
  String get fireDetailNoNewsFound;

  /// No description provided for @notificationsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get notificationsTitle;

  /// No description provided for @notificationsNewAlerts.
  ///
  /// In tr, this message translates to:
  /// **'{count} yeni uyarı'**
  String notificationsNewAlerts(int count);

  /// No description provided for @notificationsUpToDate.
  ///
  /// In tr, this message translates to:
  /// **'Güncel'**
  String get notificationsUpToDate;

  /// No description provided for @notificationsFeedTitle.
  ///
  /// In tr, this message translates to:
  /// **'Olay Bildirim Akışı'**
  String get notificationsFeedTitle;

  /// No description provided for @notificationsFeedSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Yakındaki olaylar, durum değişimleri ve saha güncellemelerini tek akışta takip et.'**
  String get notificationsFeedSubtitle;

  /// No description provided for @notificationsTools.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim Araçları'**
  String get notificationsTools;

  /// No description provided for @notificationsToolsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'İzinleri ve otomatik termal anomali takibini yönet'**
  String get notificationsToolsSubtitle;

  /// No description provided for @notificationsPermissionGranted.
  ///
  /// In tr, this message translates to:
  /// **'İzin Var'**
  String get notificationsPermissionGranted;

  /// No description provided for @notificationsPermissionDenied.
  ///
  /// In tr, this message translates to:
  /// **'İzin Yok'**
  String get notificationsPermissionDenied;

  /// No description provided for @notificationsMonitoringOn.
  ///
  /// In tr, this message translates to:
  /// **'Takip Açık'**
  String get notificationsMonitoringOn;

  /// No description provided for @notificationsMonitoringOff.
  ///
  /// In tr, this message translates to:
  /// **'Takip Kapalı'**
  String get notificationsMonitoringOff;

  /// No description provided for @notificationsRequestPermission.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim İzni İste'**
  String get notificationsRequestPermission;

  /// No description provided for @notificationsSendTest.
  ///
  /// In tr, this message translates to:
  /// **'Test Bildirimi Gönder'**
  String get notificationsSendTest;

  /// No description provided for @notificationsScanNow.
  ///
  /// In tr, this message translates to:
  /// **'Şimdi Tara'**
  String get notificationsScanNow;

  /// No description provided for @notificationsStartMonitoring.
  ///
  /// In tr, this message translates to:
  /// **'Otomatik Taramayı Başlat'**
  String get notificationsStartMonitoring;

  /// No description provided for @notificationsStopMonitoring.
  ///
  /// In tr, this message translates to:
  /// **'Otomatik Taramayı Durdur'**
  String get notificationsStopMonitoring;

  /// No description provided for @notificationsBackgroundTitle.
  ///
  /// In tr, this message translates to:
  /// **'Arka Planda Takip'**
  String get notificationsBackgroundTitle;

  /// No description provided for @notificationsBackgroundSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama kapalıyken bile 15 dakikada bir yangın kontrolü yapılsın'**
  String get notificationsBackgroundSubtitle;

  /// No description provided for @notificationsEnableBackground.
  ///
  /// In tr, this message translates to:
  /// **'Arka Plan Takibini Aç'**
  String get notificationsEnableBackground;

  /// No description provided for @notificationsDisableBackground.
  ///
  /// In tr, this message translates to:
  /// **'Arka Plan Takibini Kapat'**
  String get notificationsDisableBackground;

  /// No description provided for @backgroundLocationDialogTitle.
  ///
  /// In tr, this message translates to:
  /// **'Arka Plan Konum İzni'**
  String get backgroundLocationDialogTitle;

  /// No description provided for @backgroundLocationDialogBody.
  ///
  /// In tr, this message translates to:
  /// **'FireWatch TR, uygulama kapalıyken de yakınındaki yangınları kontrol edip seni uyarabilmek için konumuna arka planda erişim istiyor. Bu izni vermezsen uygulama sadece açıkken tarama yapabilir. Sistem izin ekranında \"Her zaman izin ver\" seçeneğini seçmen gerekir.'**
  String get backgroundLocationDialogBody;

  /// No description provided for @backgroundLocationDialogConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Devam Et'**
  String get backgroundLocationDialogConfirm;

  /// No description provided for @backgroundLocationPermissionDenied.
  ///
  /// In tr, this message translates to:
  /// **'Arka plan konum izni verilmedi. Arka plan takibi açılamadı.'**
  String get backgroundLocationPermissionDenied;

  /// No description provided for @backgroundMonitoringEnabled.
  ///
  /// In tr, this message translates to:
  /// **'Arka plan takibi açıldı.'**
  String get backgroundMonitoringEnabled;

  /// No description provided for @backgroundMonitoringDisabled.
  ///
  /// In tr, this message translates to:
  /// **'Arka plan takibi kapatıldı.'**
  String get backgroundMonitoringDisabled;

  /// No description provided for @notificationsNearbyLiveFires.
  ///
  /// In tr, this message translates to:
  /// **'Yakındaki Termal Tespitler'**
  String get notificationsNearbyLiveFires;

  /// No description provided for @notificationsNearbyLiveFiresSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Konumuna 50 km içinde bulunan noktalar'**
  String get notificationsNearbyLiveFiresSubtitle;

  /// No description provided for @notificationsDistanceAndTime.
  ///
  /// In tr, this message translates to:
  /// **'{distance} km uzaklıkta • {timeAgo}'**
  String notificationsDistanceAndTime(String distance, String timeAgo);

  /// No description provided for @notificationsRiskLabel.
  ///
  /// In tr, this message translates to:
  /// **'Risk: {level}'**
  String notificationsRiskLabel(String level);

  /// No description provided for @notificationsRecentAlerts.
  ///
  /// In tr, this message translates to:
  /// **'Son Uyarılar'**
  String get notificationsRecentAlerts;

  /// No description provided for @notificationsHighRiskCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} yüksek riskli nokta'**
  String notificationsHighRiskCount(int count);

  /// No description provided for @notificationsUnreadCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} okunmadı'**
  String notificationsUnreadCount(int count);

  /// No description provided for @notificationsNoHighRisk.
  ///
  /// In tr, this message translates to:
  /// **'Şu an yüksek güvenilirlikli termal anomali bulunmuyor.'**
  String get notificationsNoHighRisk;

  /// No description provided for @notificationsHighRiskDetectionTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek Riskli Termal Tespit'**
  String get notificationsHighRiskDetectionTitle;

  /// No description provided for @notificationsHighRiskDetectionBody.
  ///
  /// In tr, this message translates to:
  /// **'{region} bölgesinde {temp}K ısı tespit edildi. Aktif yangın ihtimali yüksek.'**
  String notificationsHighRiskDetectionBody(String region, String temp);

  /// No description provided for @watchlistTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedilenler'**
  String get watchlistTitle;

  /// No description provided for @watchlistClear.
  ///
  /// In tr, this message translates to:
  /// **'Temizle'**
  String get watchlistClear;

  /// No description provided for @watchlistNoRecords.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Yok'**
  String get watchlistNoRecords;

  /// No description provided for @watchlistRecordCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} kayıt'**
  String watchlistRecordCount(int count);

  /// No description provided for @watchlistHeading.
  ///
  /// In tr, this message translates to:
  /// **'Watchlist'**
  String get watchlistHeading;

  /// No description provided for @watchlistHeadingSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Takip etmek istediğin yangın noktalarını burada saklayabilirsin.'**
  String get watchlistHeadingSubtitle;

  /// No description provided for @watchlistEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Henüz kaydedilmiş olay yok'**
  String get watchlistEmptyTitle;

  /// No description provided for @watchlistEmptySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Yangın detay ekranındaki Kaydet butonunu kullanarak ekleyebilirsin.'**
  String get watchlistEmptySubtitle;

  /// No description provided for @watchlistSavedPoints.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedilen Noktalar'**
  String get watchlistSavedPoints;

  /// No description provided for @watchlistSavedPointsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'{count} termal tespit takipte'**
  String watchlistSavedPointsSubtitle(int count);

  /// No description provided for @watchlistSyncingTitle.
  ///
  /// In tr, this message translates to:
  /// **'{count} kaydedilmiş yangın noktası var.'**
  String watchlistSyncingTitle(int count);

  /// No description provided for @watchlistSyncingSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'NASA verisi yenileniyor olabilir. Kaydedilen noktalar uydu güncellemesinde değişebilir.'**
  String get watchlistSyncingSubtitle;

  /// No description provided for @emergencyShareLocationText.
  ///
  /// In tr, this message translates to:
  /// **'Acil Durum - Konumum:\n{url}\n\nLat: {lat}\nLng: {lng}\n\nFireWatch TR ile paylaşıldı.'**
  String emergencyShareLocationText(String url, String lat, String lng);

  /// No description provided for @emergencyShareLocationSubject.
  ///
  /// In tr, this message translates to:
  /// **'Acil Konum Paylaşımı'**
  String get emergencyShareLocationSubject;

  /// No description provided for @emergencyShareFallbackText.
  ///
  /// In tr, this message translates to:
  /// **'Acil Durum bildirimi - FireWatch TR'**
  String get emergencyShareFallbackText;

  /// No description provided for @emergencyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Acil Durum'**
  String get emergencyTitle;

  /// No description provided for @emergencyPrepCenter.
  ///
  /// In tr, this message translates to:
  /// **'Acil Hazırlık Merkezi'**
  String get emergencyPrepCenter;

  /// No description provided for @emergencyQuickToolsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hızlı Müdahale Araçları'**
  String get emergencyQuickToolsTitle;

  /// No description provided for @emergencyQuickToolsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Acil durum anında hızlı erişim, temel hazırlık ve kritik yönlendirmeleri tek ekranda topla.'**
  String get emergencyQuickToolsSubtitle;

  /// No description provided for @emergencyStayReady.
  ///
  /// In tr, this message translates to:
  /// **'Hazır Kal'**
  String get emergencyStayReady;

  /// No description provided for @emergencyStayReadyNote.
  ///
  /// In tr, this message translates to:
  /// **'Tahliye ve iletişim adımlarını önceden planlamak zaman kazandırır.'**
  String get emergencyStayReadyNote;

  /// No description provided for @emergencyQuickActions.
  ///
  /// In tr, this message translates to:
  /// **'Hızlı Eylemler'**
  String get emergencyQuickActions;

  /// No description provided for @emergencyQuickActionsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Tek dokunuşta kritik aksiyonlar'**
  String get emergencyQuickActionsSubtitle;

  /// No description provided for @emergencyCall112.
  ///
  /// In tr, this message translates to:
  /// **'112 Ara'**
  String get emergencyCall112;

  /// No description provided for @emergencyCall112Subtitle.
  ///
  /// In tr, this message translates to:
  /// **'Genel acil yardım hattı'**
  String get emergencyCall112Subtitle;

  /// No description provided for @emergencyCall177.
  ///
  /// In tr, this message translates to:
  /// **'177 Orman'**
  String get emergencyCall177;

  /// No description provided for @emergencyCall177Subtitle.
  ///
  /// In tr, this message translates to:
  /// **'Yangın bildirimi hattı'**
  String get emergencyCall177Subtitle;

  /// No description provided for @emergencyShareLocation.
  ///
  /// In tr, this message translates to:
  /// **'Konum Paylaş'**
  String get emergencyShareLocation;

  /// No description provided for @emergencyShareLocationSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Yakınlarına yer bildir'**
  String get emergencyShareLocationSubtitle;

  /// No description provided for @emergencyEvacuationPlan.
  ///
  /// In tr, this message translates to:
  /// **'Tahliye Planı'**
  String get emergencyEvacuationPlan;

  /// No description provided for @emergencyEvacuationPlanSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış adımlarını gözden geçir'**
  String get emergencyEvacuationPlanSubtitle;

  /// No description provided for @emergencyContactLines.
  ///
  /// In tr, this message translates to:
  /// **'Acil İletişim Hatları'**
  String get emergencyContactLines;

  /// No description provided for @emergencyContactLinesSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Temel numaraları hazır tut'**
  String get emergencyContactLinesSubtitle;

  /// No description provided for @emergencyCallCenter.
  ///
  /// In tr, this message translates to:
  /// **'Acil Çağrı Merkezi'**
  String get emergencyCallCenter;

  /// No description provided for @emergencyCallCenterSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Sağlık, itfaiye, polis ve genel acil durum'**
  String get emergencyCallCenterSubtitle;

  /// No description provided for @emergencyForestLine.
  ///
  /// In tr, this message translates to:
  /// **'Orman Yangını Hattı'**
  String get emergencyForestLine;

  /// No description provided for @emergencyForestLineSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Orman ve yangın bildirimi için hızlı erişim'**
  String get emergencyForestLineSubtitle;

  /// No description provided for @emergencyAfad.
  ///
  /// In tr, this message translates to:
  /// **'AFAD Acil'**
  String get emergencyAfad;

  /// No description provided for @emergencyAfadSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Afet ve acil durum yönetimi'**
  String get emergencyAfadSubtitle;

  /// No description provided for @emergencyBag.
  ///
  /// In tr, this message translates to:
  /// **'Tahliye Çantası'**
  String get emergencyBag;

  /// No description provided for @emergencyBagSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Hazır bulunsun'**
  String get emergencyBagSubtitle;

  /// No description provided for @emergencyBagDocs.
  ///
  /// In tr, this message translates to:
  /// **'Kimlik ve temel belgeler'**
  String get emergencyBagDocs;

  /// No description provided for @emergencyBagDocsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Kimlik, önemli evrak ve telefonunu tek yerde tut.'**
  String get emergencyBagDocsSubtitle;

  /// No description provided for @emergencyBagSupplies.
  ///
  /// In tr, this message translates to:
  /// **'Su, ilaç ve şarj ekipmanı'**
  String get emergencyBagSupplies;

  /// No description provided for @emergencyBagSuppliesSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Kısa süreli tahliyede kritik olacak temel ihtiyaçlar.'**
  String get emergencyBagSuppliesSubtitle;

  /// No description provided for @emergencyBagMeetingPoint.
  ///
  /// In tr, this message translates to:
  /// **'Yakınlarla buluşma noktası'**
  String get emergencyBagMeetingPoint;

  /// No description provided for @emergencyBagMeetingPointSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Ayrı düşme ihtimaline karşı önceden karar ver.'**
  String get emergencyBagMeetingPointSubtitle;

  /// No description provided for @emergencyCommNote.
  ///
  /// In tr, this message translates to:
  /// **'İletişim Notu'**
  String get emergencyCommNote;

  /// No description provided for @emergencyCommNoteSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Panik anında kısa hareket planı'**
  String get emergencyCommNoteSubtitle;

  /// No description provided for @emergencyStep1.
  ///
  /// In tr, this message translates to:
  /// **'1. Resmi uyarıları doğrula'**
  String get emergencyStep1;

  /// No description provided for @emergencyStep2.
  ///
  /// In tr, this message translates to:
  /// **'2. Yakınlarını kısa mesajla haberdar et'**
  String get emergencyStep2;

  /// No description provided for @emergencyStep3.
  ///
  /// In tr, this message translates to:
  /// **'3. Gerekliyse temel çantanı al ve güvenli çıkış rotasına yönel'**
  String get emergencyStep3;

  /// No description provided for @safetyGuideTitle.
  ///
  /// In tr, this message translates to:
  /// **'Güvenlik Rehberi'**
  String get safetyGuideTitle;

  /// No description provided for @safetyGuideEmergencyInfo.
  ///
  /// In tr, this message translates to:
  /// **'Acil Durum Bilgisi'**
  String get safetyGuideEmergencyInfo;

  /// No description provided for @safetyGuideCenterTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yangın Güvenlik Merkezi'**
  String get safetyGuideCenterTitle;

  /// No description provided for @safetyGuideCenterSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Yangın sırasında ne yapacağını hızlıca görmek, tahliye mantığını anlamak ve doğru adımları takip etmek için hazırlanmış rehber ekranı.'**
  String get safetyGuideCenterSubtitle;

  /// No description provided for @safetyGuideQuickActions.
  ///
  /// In tr, this message translates to:
  /// **'Hızlı Aksiyonlar'**
  String get safetyGuideQuickActions;

  /// No description provided for @safetyGuideQuickActionsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'İlk bakışta kritik davranışlar'**
  String get safetyGuideQuickActionsSubtitle;

  /// No description provided for @safetyGuideReadyEvacuate.
  ///
  /// In tr, this message translates to:
  /// **'Tahliyeye Hazır Ol'**
  String get safetyGuideReadyEvacuate;

  /// No description provided for @safetyGuideReadyEvacuateSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış planını netleştir'**
  String get safetyGuideReadyEvacuateSubtitle;

  /// No description provided for @safetyGuideTakeSmokeSeriously.
  ///
  /// In tr, this message translates to:
  /// **'Dumanı Ciddiye Al'**
  String get safetyGuideTakeSmokeSeriously;

  /// No description provided for @safetyGuideTakeSmokeSeriouslySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Kapalı alana geç, maske kullan'**
  String get safetyGuideTakeSmokeSeriouslySubtitle;

  /// No description provided for @safetyGuideFollowOfficials.
  ///
  /// In tr, this message translates to:
  /// **'Yetkili Duyuruları İzle'**
  String get safetyGuideFollowOfficials;

  /// No description provided for @safetyGuideFollowOfficialsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Resmi kaynakları takip et'**
  String get safetyGuideFollowOfficialsSubtitle;

  /// No description provided for @safetyGuideDontDelay.
  ///
  /// In tr, this message translates to:
  /// **'Geç Kalma'**
  String get safetyGuideDontDelay;

  /// No description provided for @safetyGuideDontDelaySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Tahliye çağrısını bekletme'**
  String get safetyGuideDontDelaySubtitle;

  /// No description provided for @safetyGuideChecklist.
  ///
  /// In tr, this message translates to:
  /// **'Acil Kontrol Listesi'**
  String get safetyGuideChecklist;

  /// No description provided for @safetyGuideChecklistSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Yangın anında temel adımlar'**
  String get safetyGuideChecklistSubtitle;

  /// No description provided for @safetyGuideChecklist1Title.
  ///
  /// In tr, this message translates to:
  /// **'Kimlik, telefon ve şarj aletini hazır tut'**
  String get safetyGuideChecklist1Title;

  /// No description provided for @safetyGuideChecklist1Desc.
  ///
  /// In tr, this message translates to:
  /// **'Zorunlu temel eşyaları tek yerde topla.'**
  String get safetyGuideChecklist1Desc;

  /// No description provided for @safetyGuideChecklist2Title.
  ///
  /// In tr, this message translates to:
  /// **'Kapı ve pencere durumunu kontrol et'**
  String get safetyGuideChecklist2Title;

  /// No description provided for @safetyGuideChecklist2Desc.
  ///
  /// In tr, this message translates to:
  /// **'Duman girişini azaltmak için açık alanları gözden geçir.'**
  String get safetyGuideChecklist2Desc;

  /// No description provided for @safetyGuideChecklist3Title.
  ///
  /// In tr, this message translates to:
  /// **'Aile / yakınlarınla buluşma planı belirle'**
  String get safetyGuideChecklist3Title;

  /// No description provided for @safetyGuideChecklist3Desc.
  ///
  /// In tr, this message translates to:
  /// **'Ayrı düşerseniz nerede buluşacağınızı önceden bil.'**
  String get safetyGuideChecklist3Desc;

  /// No description provided for @safetyGuideChecklist4Title.
  ///
  /// In tr, this message translates to:
  /// **'Resmi tahliye rotasını takip et'**
  String get safetyGuideChecklist4Title;

  /// No description provided for @safetyGuideChecklist4Desc.
  ///
  /// In tr, this message translates to:
  /// **'Kendi başına riskli güzergah uydurma.'**
  String get safetyGuideChecklist4Desc;

  /// No description provided for @safetyGuideDetailedGuide.
  ///
  /// In tr, this message translates to:
  /// **'Detaylı Rehber'**
  String get safetyGuideDetailedGuide;

  /// No description provided for @safetyGuideDetailedGuideSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Senaryoya göre açılır bilgi kartları'**
  String get safetyGuideDetailedGuideSubtitle;

  /// No description provided for @safetyGuideAtHomeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Evdeysen ne yapmalısın?'**
  String get safetyGuideAtHomeTitle;

  /// No description provided for @safetyGuideAtHome1.
  ///
  /// In tr, this message translates to:
  /// **'Duman yoğunluğu varsa kapı ve pencereleri kapalı tut.'**
  String get safetyGuideAtHome1;

  /// No description provided for @safetyGuideAtHome2.
  ///
  /// In tr, this message translates to:
  /// **'Elektrik, gaz ve hızlı çıkış güzergahını kontrol et.'**
  String get safetyGuideAtHome2;

  /// No description provided for @safetyGuideAtHome3.
  ///
  /// In tr, this message translates to:
  /// **'Tahliye çağrısı varsa eşyaları toplamaya çalışma, çıkışa odaklan.'**
  String get safetyGuideAtHome3;

  /// No description provided for @safetyGuideAtHome4.
  ///
  /// In tr, this message translates to:
  /// **'Evcil hayvanları mümkünse hızlıca güvenli taşıma düzenine al.'**
  String get safetyGuideAtHome4;

  /// No description provided for @safetyGuideInCarTitle.
  ///
  /// In tr, this message translates to:
  /// **'Araçtayken ne yapmalısın?'**
  String get safetyGuideInCarTitle;

  /// No description provided for @safetyGuideInCar1.
  ///
  /// In tr, this message translates to:
  /// **'Yoğun duman içinden geçmeye çalışma.'**
  String get safetyGuideInCar1;

  /// No description provided for @safetyGuideInCar2.
  ///
  /// In tr, this message translates to:
  /// **'Mümkünse güvenli açık alana veya yerleşim merkezine yönel.'**
  String get safetyGuideInCar2;

  /// No description provided for @safetyGuideInCar3.
  ///
  /// In tr, this message translates to:
  /// **'Aracı kuru otların ve ağaç altlarının yanında bırakma.'**
  String get safetyGuideInCar3;

  /// No description provided for @safetyGuideInCar4.
  ///
  /// In tr, this message translates to:
  /// **'Resmi yönlendirme varsa navigasyondan değil, duyurudan ilerle.'**
  String get safetyGuideInCar4;

  /// No description provided for @safetyGuideOutsideTitle.
  ///
  /// In tr, this message translates to:
  /// **'Dışarıdaysan ne yapmalısın?'**
  String get safetyGuideOutsideTitle;

  /// No description provided for @safetyGuideOutside1.
  ///
  /// In tr, this message translates to:
  /// **'Rüzgar yönünü gözlemle ve yangının önüne geçme.'**
  String get safetyGuideOutside1;

  /// No description provided for @safetyGuideOutside2.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek bitki örtüsünden ve dar vadilerden uzaklaş.'**
  String get safetyGuideOutside2;

  /// No description provided for @safetyGuideOutside3.
  ///
  /// In tr, this message translates to:
  /// **'Topluluk halinde hareket ediyorsan dağılmadan ilerle.'**
  String get safetyGuideOutside3;

  /// No description provided for @safetyGuideOutside4.
  ///
  /// In tr, this message translates to:
  /// **'Acil durumda açık, çıplak ve yanıcı olmayan alana çık.'**
  String get safetyGuideOutside4;

  /// No description provided for @safetyGuideEvacOrderTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tahliye emri geldiyse ne yapmalısın?'**
  String get safetyGuideEvacOrderTitle;

  /// No description provided for @safetyGuideEvacOrder1.
  ///
  /// In tr, this message translates to:
  /// **'Emri geciktirme, \"biraz daha bekleyeyim\" deme.'**
  String get safetyGuideEvacOrder1;

  /// No description provided for @safetyGuideEvacOrder2.
  ///
  /// In tr, this message translates to:
  /// **'Sadece temel eşyaları al ve çıkışa odaklan.'**
  String get safetyGuideEvacOrder2;

  /// No description provided for @safetyGuideEvacOrder3.
  ///
  /// In tr, this message translates to:
  /// **'Yakınlarını tek tek arayıp vakit kaybetme, önceden plan kullan.'**
  String get safetyGuideEvacOrder3;

  /// No description provided for @safetyGuideEvacOrder4.
  ///
  /// In tr, this message translates to:
  /// **'Yetkililerin toplama alanı duyurusunu takip et.'**
  String get safetyGuideEvacOrder4;

  /// No description provided for @safetyGuideEmergencyNumbers.
  ///
  /// In tr, this message translates to:
  /// **'Acil Numaralar'**
  String get safetyGuideEmergencyNumbers;

  /// No description provided for @safetyGuideEmergencyNumbersSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Hızlı erişim için not düş'**
  String get safetyGuideEmergencyNumbersSubtitle;

  /// No description provided for @safetyGuideCallCenterSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Genel acil durum hattı'**
  String get safetyGuideCallCenterSubtitle;

  /// No description provided for @safetyGuideForestNotice.
  ///
  /// In tr, this message translates to:
  /// **'Orman Yangını Bildirimi'**
  String get safetyGuideForestNotice;

  /// No description provided for @safetyGuideForestNoticeSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Yangın ve orman hattı'**
  String get safetyGuideForestNoticeSubtitle;

  /// No description provided for @safetyGuideAfadLocal.
  ///
  /// In tr, this message translates to:
  /// **'AFAD / Yerel Yönlendirme'**
  String get safetyGuideAfadLocal;

  /// No description provided for @safetyGuideAfadLocalNumber.
  ///
  /// In tr, this message translates to:
  /// **'Yerel duyuruları takip et'**
  String get safetyGuideAfadLocalNumber;

  /// No description provided for @safetyGuideAfadLocalSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Bölgesel anons ve yönlendirme önemli'**
  String get safetyGuideAfadLocalSubtitle;

  /// No description provided for @settingsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settingsTitle;

  /// No description provided for @settingsPreferences.
  ///
  /// In tr, this message translates to:
  /// **'Tercihler'**
  String get settingsPreferences;

  /// No description provided for @settingsAppSettings.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama Ayarları'**
  String get settingsAppSettings;

  /// No description provided for @settingsAppSettingsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimleri, konum tabanlı uyarıları ve uygulama davranışını buradan özelleştir.'**
  String get settingsAppSettingsSubtitle;

  /// No description provided for @settingsNotifications.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get settingsNotifications;

  /// No description provided for @settingsNotificationsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Uyarı tercihlerini yönet'**
  String get settingsNotificationsSubtitle;

  /// No description provided for @settingsPushNotifications.
  ///
  /// In tr, this message translates to:
  /// **'Push Bildirimleri'**
  String get settingsPushNotifications;

  /// No description provided for @settingsPushNotificationsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni olaylar ve önemli değişiklikler için bildirim al'**
  String get settingsPushNotificationsSubtitle;

  /// No description provided for @settingsNearbyAlerts.
  ///
  /// In tr, this message translates to:
  /// **'Yakındaki Olay Uyarıları'**
  String get settingsNearbyAlerts;

  /// No description provided for @settingsNearbyAlertsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Konumuna yakın bölgelerde olay varsa öncelikli göster'**
  String get settingsNearbyAlertsSubtitle;

  /// No description provided for @settingsAppBehavior.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama Davranışı'**
  String get settingsAppBehavior;

  /// No description provided for @settingsAppBehaviorSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Görünüm ve yenileme sıklığı'**
  String get settingsAppBehaviorSubtitle;

  /// No description provided for @settingsDarkMode.
  ///
  /// In tr, this message translates to:
  /// **'Koyu Tema'**
  String get settingsDarkMode;

  /// No description provided for @settingsDarkModeSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Premium koyu görünümü aktif tut'**
  String get settingsDarkModeSubtitle;

  /// No description provided for @settingsRefreshInterval.
  ///
  /// In tr, this message translates to:
  /// **'Veri Yenileme Aralığı'**
  String get settingsRefreshInterval;

  /// No description provided for @settingsRefreshIntervalSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Saha verilerinin ne sıklıkla yenileneceğini seç'**
  String get settingsRefreshIntervalSubtitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama dilini seç'**
  String get settingsLanguageSubtitle;

  /// No description provided for @settingsLanguageTurkish.
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get settingsLanguageTurkish;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In tr, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @dataSourcesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Veri kaynakları'**
  String get dataSourcesTitle;

  /// No description provided for @dataSourcesEntry.
  ///
  /// In tr, this message translates to:
  /// **'Veri kaynakları'**
  String get dataSourcesEntry;

  /// No description provided for @dataSourcesEntrySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Rakamlar nereden geliyor, neyi ifade etmiyor'**
  String get dataSourcesEntrySubtitle;

  /// No description provided for @dataSourcesSatelliteTitle.
  ///
  /// In tr, this message translates to:
  /// **'Uydu tespitleri — ölçülen'**
  String get dataSourcesSatelliteTitle;

  /// No description provided for @dataSourcesSatelliteBody.
  ///
  /// In tr, this message translates to:
  /// **'NASA FIRMS. VIIRS (Suomi-NPP, NOAA-20, NOAA-21) ve MODIS (Terra, Aqua). Uydular gün içinde birkaç kez geçer. Her tespit bir sıcak pikseldir: konum, ışıma gücü (FRP, megawatt), parlaklık sıcaklığı ve NASA\'nın güvenilirlik derecesi ölçülen değerlerdir. Bir olayın panelinde hangi ürünün kaç tespit verdiğini görebilirsin.'**
  String get dataSourcesSatelliteBody;

  /// No description provided for @dataSourcesGroupingTitle.
  ///
  /// In tr, this message translates to:
  /// **'Olaylar — hesaplanan'**
  String get dataSourcesGroupingTitle;

  /// No description provided for @dataSourcesGroupingBody.
  ///
  /// In tr, this message translates to:
  /// **'Aynı yangının pikselleri geçişler boyunca 1,2 km yarıçapta kümelenip tek bir olaya dönüştürülür. Süre, geçiş sayısı ve tepe güç bu gruplamadan gelir. Süre iki günlük veri penceresiyle sınırlıdır; bu yüzden her yerde \"en az\" diye yazılır — bir aydır yanan bir kaynak da yaklaşık bir gün gösterir.'**
  String get dataSourcesGroupingBody;

  /// No description provided for @dataSourcesDerivedTitle.
  ///
  /// In tr, this message translates to:
  /// **'Türetilen — ölçüm değil'**
  String get dataSourcesDerivedTitle;

  /// No description provided for @dataSourcesDerivedBody.
  ///
  /// In tr, this message translates to:
  /// **'Yayılma yönü ve hızı, tespit deseninin merkezindeki kaymadan hesaplanır; yangının gerçek ilerleyişi farklı olabilir. \"Tespit pikseli ~N hektar\" uydunun çözünürlüğüdür, yanan alan değildir: yangın o pikselin içindedir, gerçek boyutu bilinmiyor. Bu rakam uydunun bakış açısına göre büyür, yangına göre değil.'**
  String get dataSourcesDerivedBody;

  /// No description provided for @dataSourcesNotKnownTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bilinmeyen'**
  String get dataSourcesNotKnownTitle;

  /// No description provided for @dataSourcesNotKnownBody.
  ///
  /// In tr, this message translates to:
  /// **'Bir yangının söndüğü, kontrol altına alındığı veya güvenli olduğu uydudan çıkarılamaz. Uydu bulut ve duman altını göremez; tespit olmaması yalnızca uydunun görmediği anlamına gelir. Bu uygulama böyle bir iddiada bulunmaz — yalnızca resmi bir kaynak doğrularsa, kaynağıyla birlikte gösterilir.'**
  String get dataSourcesNotKnownBody;

  /// No description provided for @dataSourcesWeatherTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bölgesel risk — ayrı bir kaynak'**
  String get dataSourcesWeatherTitle;

  /// No description provided for @dataSourcesWeatherBody.
  ///
  /// In tr, this message translates to:
  /// **'Risk skorları hava durumu verisinden bölge genelinde hesaplanır. Tek bir yangına ait ölçüm değildir; o yangının nasıl davranacağını söylemez.'**
  String get dataSourcesWeatherBody;

  /// No description provided for @dataSourcesFwiTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yangın tehlikesi haritası (FWI) — ayrı bir kaynak'**
  String get dataSourcesFwiTitle;

  /// No description provided for @dataSourcesFwiBody.
  ///
  /// In tr, this message translates to:
  /// **'Haritadaki risk katmanı Copernicus EFFIS\'in Yangın Hava Endeksi\'ni (FWI) gösterir. FWI sıcaklık, nem, rüzgar ve yağıştan hesaplanan bir tehlike göstergesidir: hava koşullarının bir yangını ne kadar besleyeceğini söyler, bir yangın olduğunu söylemez. Veri MeteoFrance\'ın ~10 km çözünürlüklü hava tahmini modelinden gelir ve bugün dahil 4 günlük (3 gün ileriye) tahmin sunar. Uydu tespitlerinden tamamen ayrı bir kaynaktır; herhangi bir yangına ait ölçüm değildir. Veri: © European Union, Copernicus EFFIS (CC BY 4.0).'**
  String get dataSourcesFwiBody;

  /// No description provided for @settingsAppInfo.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama Bilgisi'**
  String get settingsAppInfo;

  /// No description provided for @settingsAppInfoSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Sürüm ve ürün özeti'**
  String get settingsAppInfoSubtitle;

  /// No description provided for @settingsInfoApp.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama'**
  String get settingsInfoApp;

  /// No description provided for @settingsInfoVersion.
  ///
  /// In tr, this message translates to:
  /// **'Sürüm'**
  String get settingsInfoVersion;

  /// No description provided for @settingsInfoVersionValue.
  ///
  /// In tr, this message translates to:
  /// **'v1.0.0'**
  String get settingsInfoVersionValue;

  /// No description provided for @settingsInfoPlatform.
  ///
  /// In tr, this message translates to:
  /// **'Platform'**
  String get settingsInfoPlatform;

  /// No description provided for @settingsInfoPlatformValue.
  ///
  /// In tr, this message translates to:
  /// **'Flutter / Android'**
  String get settingsInfoPlatformValue;

  /// No description provided for @settingsInfoPurpose.
  ///
  /// In tr, this message translates to:
  /// **'Amaç'**
  String get settingsInfoPurpose;

  /// No description provided for @settingsInfoPurposeValue.
  ///
  /// In tr, this message translates to:
  /// **'Yangın odaklı disaster tracking'**
  String get settingsInfoPurposeValue;

  /// No description provided for @settingsFooterNote.
  ///
  /// In tr, this message translates to:
  /// **'Tercihlerin cihazında saklanır ve uygulamayı her açtığında otomatik olarak uygulanır.'**
  String get settingsFooterNote;

  /// No description provided for @settingsLegal.
  ///
  /// In tr, this message translates to:
  /// **'Yasal'**
  String get settingsLegal;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik Politikası'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsTermsOfService.
  ///
  /// In tr, this message translates to:
  /// **'Kullanım Koşulları'**
  String get settingsTermsOfService;

  /// No description provided for @settingsLinkOpenFailed.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı açılamadı. Lütfen tekrar deneyin.'**
  String get settingsLinkOpenFailed;

  /// No description provided for @riskTitle.
  ///
  /// In tr, this message translates to:
  /// **'Risk Analizi'**
  String get riskTitle;

  /// No description provided for @riskLiveView.
  ///
  /// In tr, this message translates to:
  /// **'Canlı Risk Görünümü'**
  String get riskLiveView;

  /// No description provided for @riskSummaryTitle.
  ///
  /// In tr, this message translates to:
  /// **'Türkiye Yangın Risk Özeti'**
  String get riskSummaryTitle;

  /// No description provided for @riskSummarySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Open-Meteo hava verisi + NASA FIRMS uydu verisiyle hesaplanmış gerçek zamanlı risk analizi.'**
  String get riskSummarySubtitle;

  /// No description provided for @riskHighestRisk.
  ///
  /// In tr, this message translates to:
  /// **'En yüksek risk: {region} ({score}/100)'**
  String riskHighestRisk(String region, int score);

  /// No description provided for @riskDataLoading.
  ///
  /// In tr, this message translates to:
  /// **'Veri yükleniyor...'**
  String get riskDataLoading;

  /// No description provided for @riskKeyIndicators.
  ///
  /// In tr, this message translates to:
  /// **'Ana Göstergeler'**
  String get riskKeyIndicators;

  /// No description provided for @riskOverviewHighestTitle.
  ///
  /// In tr, this message translates to:
  /// **'En Yüksek Risk'**
  String get riskOverviewHighestTitle;

  /// No description provided for @riskOverviewHighestSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Bölge detayı için dokunun'**
  String get riskOverviewHighestSubtitle;

  /// No description provided for @riskOverviewLowestTitle.
  ///
  /// In tr, this message translates to:
  /// **'En Düşük Risk'**
  String get riskOverviewLowestTitle;

  /// No description provided for @riskOverviewLowestSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Şu an en güvenli bölge'**
  String get riskOverviewLowestSubtitle;

  /// No description provided for @riskOverviewAvgTitle.
  ///
  /// In tr, this message translates to:
  /// **'Türkiye Ortalaması'**
  String get riskOverviewAvgTitle;

  /// No description provided for @riskOverviewAvgSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Tüm bölgelerde, 100 üzerinden'**
  String get riskOverviewAvgSubtitle;

  /// No description provided for @riskOverviewTrendTitle.
  ///
  /// In tr, this message translates to:
  /// **'Trend'**
  String get riskOverviewTrendTitle;

  /// No description provided for @riskOverviewTrendImproving.
  ///
  /// In tr, this message translates to:
  /// **'İyileşiyor'**
  String get riskOverviewTrendImproving;

  /// No description provided for @riskOverviewTrendWorsening.
  ///
  /// In tr, this message translates to:
  /// **'Kötüleşiyor'**
  String get riskOverviewTrendWorsening;

  /// No description provided for @riskOverviewTrendStable.
  ///
  /// In tr, this message translates to:
  /// **'Sabit'**
  String get riskOverviewTrendStable;

  /// No description provided for @riskOverviewTrendNoData.
  ///
  /// In tr, this message translates to:
  /// **'Veri yok'**
  String get riskOverviewTrendNoData;

  /// No description provided for @riskOverviewTrendSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Son güncellemeden bu yana {delta} puan değişim'**
  String riskOverviewTrendSubtitle(String delta);

  /// No description provided for @riskOverviewTrendNoDataSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Henüz yeterli geçmiş veri yok'**
  String get riskOverviewTrendNoDataSubtitle;

  /// No description provided for @riskTurkeyAverage.
  ///
  /// In tr, this message translates to:
  /// **'Türkiye ortalaması'**
  String get riskTurkeyAverage;

  /// No description provided for @riskGeneralRisk.
  ///
  /// In tr, this message translates to:
  /// **'Genel Risk'**
  String get riskGeneralRisk;

  /// No description provided for @riskOutOf100.
  ///
  /// In tr, this message translates to:
  /// **'100 üzerinden'**
  String get riskOutOf100;

  /// No description provided for @riskWindIncreasesSpread.
  ///
  /// In tr, this message translates to:
  /// **'Yayılımı artırıyor'**
  String get riskWindIncreasesSpread;

  /// No description provided for @riskWindNormal.
  ///
  /// In tr, this message translates to:
  /// **'Normal seviye'**
  String get riskWindNormal;

  /// No description provided for @riskHumidity.
  ///
  /// In tr, this message translates to:
  /// **'Nem'**
  String get riskHumidity;

  /// No description provided for @riskHumidityLow.
  ///
  /// In tr, this message translates to:
  /// **'Düşük nem'**
  String get riskHumidityLow;

  /// No description provided for @riskHumidityMedium.
  ///
  /// In tr, this message translates to:
  /// **'Orta nem'**
  String get riskHumidityMedium;

  /// No description provided for @riskHumidityHigh.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek nem'**
  String get riskHumidityHigh;

  /// No description provided for @riskTempCritical.
  ///
  /// In tr, this message translates to:
  /// **'Kritik seviye'**
  String get riskTempCritical;

  /// No description provided for @riskTempNormal.
  ///
  /// In tr, this message translates to:
  /// **'Normal'**
  String get riskTempNormal;

  /// No description provided for @riskRegionalDistribution.
  ///
  /// In tr, this message translates to:
  /// **'Bölgesel Risk Dağılımı'**
  String get riskRegionalDistribution;

  /// No description provided for @riskRegionalDistributionSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Güncel bölge skorları'**
  String get riskRegionalDistributionSubtitle;

  /// No description provided for @riskScore.
  ///
  /// In tr, this message translates to:
  /// **'Risk Skoru'**
  String get riskScore;

  /// No description provided for @riskRegionDetails.
  ///
  /// In tr, this message translates to:
  /// **'Bölge Detayları'**
  String get riskRegionDetails;

  /// No description provided for @riskRegionDetailsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Gerçek hava verisi'**
  String get riskRegionDetailsSubtitle;

  /// No description provided for @riskScoreOutOf100.
  ///
  /// In tr, this message translates to:
  /// **'Risk skoru: {score}/100'**
  String riskScoreOutOf100(int score);

  /// No description provided for @riskEnvironmentalFactors.
  ///
  /// In tr, this message translates to:
  /// **'Çevresel Faktörler'**
  String get riskEnvironmentalFactors;

  /// No description provided for @riskDrynessIndex.
  ///
  /// In tr, this message translates to:
  /// **'Kuruluk İndeksi'**
  String get riskDrynessIndex;

  /// No description provided for @riskDrynessVeryHigh.
  ///
  /// In tr, this message translates to:
  /// **'Çok yüksek'**
  String get riskDrynessVeryHigh;

  /// No description provided for @riskWindPressure.
  ///
  /// In tr, this message translates to:
  /// **'Rüzgar Baskısı'**
  String get riskWindPressure;

  /// No description provided for @riskVegetationDensity.
  ///
  /// In tr, this message translates to:
  /// **'Bitki Yoğunluğu'**
  String get riskVegetationDensity;

  /// No description provided for @riskVegetationMediumHigh.
  ///
  /// In tr, this message translates to:
  /// **'Orta - Yüksek'**
  String get riskVegetationMediumHigh;

  /// No description provided for @riskHumidityLevel.
  ///
  /// In tr, this message translates to:
  /// **'Nem Seviyesi'**
  String get riskHumidityLevel;

  /// No description provided for @riskNoteHighTemp.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek sıcaklık ({temp}°C)'**
  String riskNoteHighTemp(int temp);

  /// No description provided for @riskNoteMildTemp.
  ///
  /// In tr, this message translates to:
  /// **'Ilık hava ({temp}°C)'**
  String riskNoteMildTemp(int temp);

  /// No description provided for @riskNoteCoolTemp.
  ///
  /// In tr, this message translates to:
  /// **'Serin hava ({temp}°C)'**
  String riskNoteCoolTemp(int temp);

  /// No description provided for @riskNoteLowHumidity.
  ///
  /// In tr, this message translates to:
  /// **'Düşük nem (%{hum})'**
  String riskNoteLowHumidity(int hum);

  /// No description provided for @riskNoteMediumHumidity.
  ///
  /// In tr, this message translates to:
  /// **'Orta nem (%{hum})'**
  String riskNoteMediumHumidity(int hum);

  /// No description provided for @riskNoteHighHumidity.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek nem (%{hum})'**
  String riskNoteHighHumidity(int hum);

  /// No description provided for @riskNoteStrongWind.
  ///
  /// In tr, this message translates to:
  /// **'Güçlü rüzgar ({wind}km/h)'**
  String riskNoteStrongWind(int wind);

  /// No description provided for @riskNoteMediumWind.
  ///
  /// In tr, this message translates to:
  /// **'Orta rüzgar ({wind}km/h)'**
  String riskNoteMediumWind(int wind);

  /// No description provided for @newsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Haberler'**
  String get newsTitle;

  /// No description provided for @newsLiveFeed.
  ///
  /// In tr, this message translates to:
  /// **'Canlı Bilgi Akışı'**
  String get newsLiveFeed;

  /// No description provided for @newsCenterTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yangın Haber Merkezi'**
  String get newsCenterTitle;

  /// No description provided for @newsCenterSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Saha güncellemeleri, risk uyarıları ve güvenlik odaklı gelişmeleri tek akışta takip et.'**
  String get newsCenterSubtitle;

  /// No description provided for @newsFeatured.
  ///
  /// In tr, this message translates to:
  /// **'Öne Çıkan Gelişme'**
  String get newsFeatured;

  /// No description provided for @newsFeaturedSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Bugünün dikkat çeken başlığı'**
  String get newsFeaturedSubtitle;

  /// No description provided for @newsCategories.
  ///
  /// In tr, this message translates to:
  /// **'Kategoriler'**
  String get newsCategories;

  /// No description provided for @newsCategoriesSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Akışı filtrele'**
  String get newsCategoriesSubtitle;

  /// No description provided for @newsCategoryRisk.
  ///
  /// In tr, this message translates to:
  /// **'Risk'**
  String get newsCategoryRisk;

  /// No description provided for @newsCategoryOperation.
  ///
  /// In tr, this message translates to:
  /// **'Operasyon'**
  String get newsCategoryOperation;

  /// No description provided for @newsCategorySafety.
  ///
  /// In tr, this message translates to:
  /// **'Güvenlik'**
  String get newsCategorySafety;

  /// No description provided for @newsCategoryUpdate.
  ///
  /// In tr, this message translates to:
  /// **'Güncelleme'**
  String get newsCategoryUpdate;

  /// No description provided for @newsContentCategoryEvacuation.
  ///
  /// In tr, this message translates to:
  /// **'Tahliye'**
  String get newsContentCategoryEvacuation;

  /// No description provided for @newsContentCategoryResponse.
  ///
  /// In tr, this message translates to:
  /// **'Müdahale'**
  String get newsContentCategoryResponse;

  /// No description provided for @newsContentCategoryWarning.
  ///
  /// In tr, this message translates to:
  /// **'Uyarı'**
  String get newsContentCategoryWarning;

  /// No description provided for @newsContentCategoryEmergency.
  ///
  /// In tr, this message translates to:
  /// **'Acil'**
  String get newsContentCategoryEmergency;

  /// No description provided for @newsContentCategoryWeather.
  ///
  /// In tr, this message translates to:
  /// **'Hava Durumu'**
  String get newsContentCategoryWeather;

  /// No description provided for @newsContentCategoryForest.
  ///
  /// In tr, this message translates to:
  /// **'Orman'**
  String get newsContentCategoryForest;

  /// No description provided for @newsContentCategoryNews.
  ///
  /// In tr, this message translates to:
  /// **'Haber'**
  String get newsContentCategoryNews;

  /// No description provided for @newsRiskCritical.
  ///
  /// In tr, this message translates to:
  /// **'KRİTİK'**
  String get newsRiskCritical;

  /// No description provided for @newsRiskActive.
  ///
  /// In tr, this message translates to:
  /// **'AKTİF'**
  String get newsRiskActive;

  /// No description provided for @newsRiskMonitoring.
  ///
  /// In tr, this message translates to:
  /// **'İZLENİYOR'**
  String get newsRiskMonitoring;

  /// No description provided for @newsRiskInfo.
  ///
  /// In tr, this message translates to:
  /// **'BİLGİ'**
  String get newsRiskInfo;

  /// No description provided for @newsBreakingBadge.
  ///
  /// In tr, this message translates to:
  /// **'Son Dakika'**
  String get newsBreakingBadge;

  /// No description provided for @newsEnglishBannerText.
  ///
  /// In tr, this message translates to:
  /// **'Herhangi bir haberi İngilizceye çevirmek için dokunun'**
  String get newsEnglishBannerText;

  /// No description provided for @newsTranslateCardButton.
  ///
  /// In tr, this message translates to:
  /// **'Çevir'**
  String get newsTranslateCardButton;

  /// No description provided for @newsContentFiltersTitle.
  ///
  /// In tr, this message translates to:
  /// **'Durum Filtreleri'**
  String get newsContentFiltersTitle;

  /// No description provided for @newsContentFiltersSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Neler olduğuna göre filtrele'**
  String get newsContentFiltersSubtitle;

  /// No description provided for @newsFilterMyRegion.
  ///
  /// In tr, this message translates to:
  /// **'Bölgem'**
  String get newsFilterMyRegion;

  /// No description provided for @newsLatest.
  ///
  /// In tr, this message translates to:
  /// **'Son Haberler'**
  String get newsLatest;

  /// No description provided for @newsRecordsFound.
  ///
  /// In tr, this message translates to:
  /// **'{count} kayıt bulundu'**
  String newsRecordsFound(int count);

  /// No description provided for @newsFetchFailed.
  ///
  /// In tr, this message translates to:
  /// **'Haberler yüklenemedi'**
  String get newsFetchFailed;

  /// No description provided for @newsNoneInCategory.
  ///
  /// In tr, this message translates to:
  /// **'Bu filtreyle eşleşen haber yok.'**
  String get newsNoneInCategory;

  /// No description provided for @reportPanelLocationServiceOff.
  ///
  /// In tr, this message translates to:
  /// **'Konum servisi kapalı. Lütfen açın.'**
  String get reportPanelLocationServiceOff;

  /// No description provided for @reportPanelLocationPermissionDenied.
  ///
  /// In tr, this message translates to:
  /// **'Konum izni verilmedi.'**
  String get reportPanelLocationPermissionDenied;

  /// No description provided for @reportPanelLocationError.
  ///
  /// In tr, this message translates to:
  /// **'Konum alınamadı: {error}'**
  String reportPanelLocationError(String error);

  /// No description provided for @reportPanelNeedLocationFirst.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen önce konumunuzu alın.'**
  String get reportPanelNeedLocationFirst;

  /// No description provided for @reportPanelSmokeObserved.
  ///
  /// In tr, this message translates to:
  /// **'Yoğun duman gözlemlendi'**
  String get reportPanelSmokeObserved;

  /// No description provided for @reportPanelStrongWindPresent.
  ///
  /// In tr, this message translates to:
  /// **'Güçlü rüzgar mevcut'**
  String get reportPanelStrongWindPresent;

  /// No description provided for @reportPanelNearSettlementNote.
  ///
  /// In tr, this message translates to:
  /// **'Yerleşim alanına yakın'**
  String get reportPanelNearSettlementNote;

  /// No description provided for @reportPanelRiskLevelLine.
  ///
  /// In tr, this message translates to:
  /// **'Risk seviyesi: {level}'**
  String reportPanelRiskLevelLine(String level);

  /// No description provided for @reportPanelCityFireReport.
  ///
  /// In tr, this message translates to:
  /// **'{city} yangın bildirimi'**
  String reportPanelCityFireReport(String city);

  /// No description provided for @reportPanelFireReport.
  ///
  /// In tr, this message translates to:
  /// **'Yangın bildirimi'**
  String get reportPanelFireReport;

  /// No description provided for @reportPanelVerifiedTitle.
  ///
  /// In tr, this message translates to:
  /// **'Rapor Doğrulandı'**
  String get reportPanelVerifiedTitle;

  /// No description provided for @reportPanelReceivedTitle.
  ///
  /// In tr, this message translates to:
  /// **'⏳ Rapor Alındı'**
  String get reportPanelReceivedTitle;

  /// No description provided for @reportPanelCityLabel.
  ///
  /// In tr, this message translates to:
  /// **'Şehir: {city}'**
  String reportPanelCityLabel(String city);

  /// No description provided for @reportPanelSubmitFailed.
  ///
  /// In tr, this message translates to:
  /// **'Rapor gönderilemedi. İnternet bağlantınızı kontrol edin.'**
  String get reportPanelSubmitFailed;

  /// No description provided for @reportPanelOk.
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get reportPanelOk;

  /// No description provided for @reportPanelNewReport.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Bildirim'**
  String get reportPanelNewReport;

  /// No description provided for @reportPanelTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yangın Raporla'**
  String get reportPanelTitle;

  /// No description provided for @reportPanelSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'GPS ile konumunuzu alın ve yangını bildirin. NASA verisiyle otomatik doğrulanacak.'**
  String get reportPanelSubtitle;

  /// No description provided for @reportPanelLocation.
  ///
  /// In tr, this message translates to:
  /// **'Konum'**
  String get reportPanelLocation;

  /// No description provided for @reportPanelLocationObtained.
  ///
  /// In tr, this message translates to:
  /// **'Konum alındı'**
  String get reportPanelLocationObtained;

  /// No description provided for @reportPanelNoLocationYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz konum alınmadı'**
  String get reportPanelNoLocationYet;

  /// No description provided for @reportPanelGetGpsLocation.
  ///
  /// In tr, this message translates to:
  /// **'GPS ile Konum Al'**
  String get reportPanelGetGpsLocation;

  /// No description provided for @reportPanelRefreshLocation.
  ///
  /// In tr, this message translates to:
  /// **'Konumu Yenile'**
  String get reportPanelRefreshLocation;

  /// No description provided for @reportPanelRiskLevel.
  ///
  /// In tr, this message translates to:
  /// **'Risk Seviyesi'**
  String get reportPanelRiskLevel;

  /// No description provided for @reportPanelYourName.
  ///
  /// In tr, this message translates to:
  /// **'Adınız (isteğe bağlı)'**
  String get reportPanelYourName;

  /// No description provided for @reportPanelAnonymousHint.
  ///
  /// In tr, this message translates to:
  /// **'Anonim olarak gönderilecek'**
  String get reportPanelAnonymousHint;

  /// No description provided for @reportPanelExtraNote.
  ///
  /// In tr, this message translates to:
  /// **'Ek Not'**
  String get reportPanelExtraNote;

  /// No description provided for @reportPanelNoteHint.
  ///
  /// In tr, this message translates to:
  /// **'Alev yüksekliği, duman yoğunluğu, yol durumu...'**
  String get reportPanelNoteHint;

  /// No description provided for @reportPanelSmokeSwitch.
  ///
  /// In tr, this message translates to:
  /// **'Yoğun duman gözleniyor'**
  String get reportPanelSmokeSwitch;

  /// No description provided for @reportPanelWindSwitch.
  ///
  /// In tr, this message translates to:
  /// **'Rüzgar güçlü görünüyor'**
  String get reportPanelWindSwitch;

  /// No description provided for @reportPanelSettlementSwitch.
  ///
  /// In tr, this message translates to:
  /// **'Yerleşim alanına yakın'**
  String get reportPanelSettlementSwitch;

  /// No description provided for @reportPanelSubmitting.
  ///
  /// In tr, this message translates to:
  /// **'Gönderiliyor...'**
  String get reportPanelSubmitting;

  /// No description provided for @reportPanelSubmit.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimi Gönder'**
  String get reportPanelSubmit;

  /// No description provided for @reportPanelAnonymousToggle.
  ///
  /// In tr, this message translates to:
  /// **'Anonim olarak gönder'**
  String get reportPanelAnonymousToggle;

  /// No description provided for @reportPanelAnonymousToggleSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'İsminiz yetkililerle paylaşılmayacak'**
  String get reportPanelAnonymousToggleSubtitle;

  /// No description provided for @reportPanelPhotosLabel.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraflar (isteğe bağlı)'**
  String get reportPanelPhotosLabel;

  /// No description provided for @reportPanelPhotosHint.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimi doğrulamaya yardımcı olması için en fazla 3 fotoğraf ekleyin'**
  String get reportPanelPhotosHint;

  /// No description provided for @reportPanelAddPhoto.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf Ekle'**
  String get reportPanelAddPhoto;

  /// No description provided for @reportPanelPhotoSourceCamera.
  ///
  /// In tr, this message translates to:
  /// **'Kamera'**
  String get reportPanelPhotoSourceCamera;

  /// No description provided for @reportPanelPhotoSourceGallery.
  ///
  /// In tr, this message translates to:
  /// **'Galeri'**
  String get reportPanelPhotoSourceGallery;

  /// No description provided for @reportPanelRemovePhoto.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğrafı kaldır'**
  String get reportPanelRemovePhoto;

  /// No description provided for @reportPanelUploadingPhotos.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraflar yükleniyor…'**
  String get reportPanelUploadingPhotos;

  /// No description provided for @reportPanelPhotosUploaded.
  ///
  /// In tr, this message translates to:
  /// **'{count} fotoğraf yüklendi'**
  String reportPanelPhotosUploaded(int count);

  /// No description provided for @reportPanelMapAdjustHint.
  ///
  /// In tr, this message translates to:
  /// **'Pin konumunu ayarlamak için haritaya dokunun'**
  String get reportPanelMapAdjustHint;

  /// No description provided for @reportPanelSuccessVerifiedTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim Doğrulandı'**
  String get reportPanelSuccessVerifiedTitle;

  /// No description provided for @reportPanelSuccessReceivedTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim Alındı'**
  String get reportPanelSuccessReceivedTitle;

  /// No description provided for @reportPanelSuccessVerifiedBody.
  ///
  /// In tr, this message translates to:
  /// **'Bildiriminiz NASA uydu verisiyle eşleşti ve doğrulandı olarak işaretlendi.'**
  String get reportPanelSuccessVerifiedBody;

  /// No description provided for @reportPanelSuccessReceivedBody.
  ///
  /// In tr, this message translates to:
  /// **'Bildiriminiz kaydedildi ve ekibimiz tarafından manuel incelemeyi bekliyor.'**
  String get reportPanelSuccessReceivedBody;

  /// No description provided for @reportPanelReportIdLabel.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim No: #{id}'**
  String reportPanelReportIdLabel(String id);

  /// No description provided for @reportPanelReportedAtLabel.
  ///
  /// In tr, this message translates to:
  /// **'{time} tarihinde bildirildi'**
  String reportPanelReportedAtLabel(String time);

  /// No description provided for @reportPanelResponseTimeVerified.
  ///
  /// In tr, this message translates to:
  /// **'Burası aktif bir yangın bölgesi — acil durum ekipleri zaten bilgilendirildi.'**
  String get reportPanelResponseTimeVerified;

  /// No description provided for @reportPanelResponseTimeReceived.
  ///
  /// In tr, this message translates to:
  /// **'Eğer bu aktif bir acil durumsa lütfen doğrudan 112\'yi de arayın.'**
  String get reportPanelResponseTimeReceived;

  /// No description provided for @reportPanelShare.
  ///
  /// In tr, this message translates to:
  /// **'Paylaş'**
  String get reportPanelShare;

  /// No description provided for @reportPanelDone.
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get reportPanelDone;

  /// No description provided for @reportPanelShareText.
  ///
  /// In tr, this message translates to:
  /// **'{city}, {region} yakınında yangın bildirimi gönderildi (#{id}). {status}'**
  String reportPanelShareText(
    String city,
    String region,
    String id,
    String status,
  );

  /// No description provided for @slowLoadingBannerLabel.
  ///
  /// In tr, this message translates to:
  /// **'Yavaş yükleniyor — önbellek verisi gösteriliyor'**
  String get slowLoadingBannerLabel;

  /// No description provided for @errorStateTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bir şeyler ters gitti'**
  String get errorStateTitle;

  /// No description provided for @errorStateGeneric.
  ///
  /// In tr, this message translates to:
  /// **'Veriler yüklenemedi. Lütfen tekrar deneyin.'**
  String get errorStateGeneric;

  /// No description provided for @emptyStateGenericTitle.
  ///
  /// In tr, this message translates to:
  /// **'Gösterilecek veri yok'**
  String get emptyStateGenericTitle;

  /// No description provided for @emptyStateGenericSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Şu anda burada gösterilecek bir şey bulunmuyor.'**
  String get emptyStateGenericSubtitle;

  /// No description provided for @notifPermTitle.
  ///
  /// In tr, this message translates to:
  /// **'Önemli uyarıları kaçırma'**
  String get notifPermTitle;

  /// No description provided for @notifPermSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim izniyle yakınındaki yangın olaylarını ve kritik durum değişikliklerini anında öğrenebilirsin.'**
  String get notifPermSubtitle;

  /// No description provided for @notifPermNote.
  ///
  /// In tr, this message translates to:
  /// **'Bu izin zorunlu değil. İstersen şimdilik atlayıp uygulamayı yine kullanabilirsin.'**
  String get notifPermNote;

  /// No description provided for @notifPermEnable.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimleri Etkinleştir'**
  String get notifPermEnable;

  /// No description provided for @notifPermSkip.
  ///
  /// In tr, this message translates to:
  /// **'Şimdilik Geç'**
  String get notifPermSkip;

  /// No description provided for @notifPermGranted.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim izni verildi. Teşekkürler!'**
  String get notifPermGranted;

  /// No description provided for @notifPermDenied.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim izni verilmedi. Ayarlardan daha sonra açabilirsin.'**
  String get notifPermDenied;

  /// No description provided for @locPermServiceOff.
  ///
  /// In tr, this message translates to:
  /// **'Konum servisi kapalı görünüyor. Yine de uygulamaya devam edebilirsin.'**
  String get locPermServiceOff;

  /// No description provided for @locPermDenied.
  ///
  /// In tr, this message translates to:
  /// **'Konum izni verilmedi. Şimdilik konumsuz devam edebilirsin.'**
  String get locPermDenied;

  /// No description provided for @locPermDeniedForever.
  ///
  /// In tr, this message translates to:
  /// **'Konum izni kalıcı olarak reddedilmiş. Ayarlardan açabilirsin.'**
  String get locPermDeniedForever;

  /// No description provided for @locPermError.
  ///
  /// In tr, this message translates to:
  /// **'Konum izni alınırken bir sorun oluştu. Şimdilik geçebilirsin.'**
  String get locPermError;

  /// No description provided for @locPermTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yakınındaki olayları gösterelim'**
  String get locPermTitle;

  /// No description provided for @locPermSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Konum erişimiyle sana yakın yangın olaylarını, riskli bölgeleri ve daha ilgili bildirimleri gösterebiliriz.'**
  String get locPermSubtitle;

  /// No description provided for @locPermNote.
  ///
  /// In tr, this message translates to:
  /// **'Bu izin zorunlu değil. İstersen şimdilik atlayıp uygulamayı yine kullanabilirsin.'**
  String get locPermNote;

  /// No description provided for @locPermEnable.
  ///
  /// In tr, this message translates to:
  /// **'Konumu Etkinleştir'**
  String get locPermEnable;

  /// No description provided for @locPermSkip.
  ///
  /// In tr, this message translates to:
  /// **'Şimdilik Geç'**
  String get locPermSkip;

  /// No description provided for @compassNorth.
  ///
  /// In tr, this message translates to:
  /// **'K'**
  String get compassNorth;

  /// No description provided for @compassSouth.
  ///
  /// In tr, this message translates to:
  /// **'G'**
  String get compassSouth;

  /// No description provided for @compassEast.
  ///
  /// In tr, this message translates to:
  /// **'D'**
  String get compassEast;

  /// No description provided for @compassWest.
  ///
  /// In tr, this message translates to:
  /// **'B'**
  String get compassWest;

  /// No description provided for @riskReasonHighWithTemp.
  ///
  /// In tr, this message translates to:
  /// **'Termal sensör {temp}K ısı tespit etti. Aktif yangın ihtimali yüksek, bölgeye yaklaşma.'**
  String riskReasonHighWithTemp(String temp);

  /// No description provided for @riskReasonHighNoTemp.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek güven seviyesinde termal anomali tespit edildi. Aktif yangın olabilir.'**
  String get riskReasonHighNoTemp;

  /// No description provided for @riskReasonMediumWithTemp.
  ///
  /// In tr, this message translates to:
  /// **'Termal sensör {temp}K ısı ölçtü. Anız yakma, tarım faaliyeti veya erken evre yangın olabilir.'**
  String riskReasonMediumWithTemp(String temp);

  /// No description provided for @riskReasonMediumNoTemp.
  ///
  /// In tr, this message translates to:
  /// **'Orta düzey termal anomali. Bölge izleme altında tutulmalı.'**
  String get riskReasonMediumNoTemp;

  /// No description provided for @riskReasonLowWithTemp.
  ///
  /// In tr, this message translates to:
  /// **'Düşük ısı değeri ({temp}K). Sanayi, seracılık veya doğal ısı kaynağı olabilir.'**
  String riskReasonLowWithTemp(String temp);

  /// No description provided for @riskReasonLowNoTemp.
  ///
  /// In tr, this message translates to:
  /// **'Düşük seviye termal aktivite. Takip önerilir.'**
  String get riskReasonLowNoTemp;

  /// No description provided for @fireGeneratedDescHigh.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek yoğunluklu termal aktivite. Aktif yangın olasılığı ciddi.'**
  String get fireGeneratedDescHigh;

  /// No description provided for @fireGeneratedDescMedium.
  ///
  /// In tr, this message translates to:
  /// **'Orta seviye ısı artışı. Bölge izleme gerektirir.'**
  String get fireGeneratedDescMedium;

  /// No description provided for @fireGeneratedDescLow.
  ///
  /// In tr, this message translates to:
  /// **'Düşük seviye termal aktivite. Takip önerilir.'**
  String get fireGeneratedDescLow;

  /// No description provided for @fireRecommendedActionHigh.
  ///
  /// In tr, this message translates to:
  /// **'Bölgeden uzak dur, resmi yönlendirmeleri takip et ve tahliye hazırlığını yap.'**
  String get fireRecommendedActionHigh;

  /// No description provided for @fireRecommendedActionMedium.
  ///
  /// In tr, this message translates to:
  /// **'Gelişmeleri takip et, bölgeye gereksiz yaklaşma.'**
  String get fireRecommendedActionMedium;

  /// No description provided for @fireRecommendedActionLow.
  ///
  /// In tr, this message translates to:
  /// **'Şu an acil aksiyon gerekmiyor, bölgeyi takip et.'**
  String get fireRecommendedActionLow;

  /// No description provided for @fireStatusActive.
  ///
  /// In tr, this message translates to:
  /// **'Muhtemel Yangın'**
  String get fireStatusActive;

  /// No description provided for @fireStatusLikelyActive.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek Isı Anomalisi'**
  String get fireStatusLikelyActive;

  /// No description provided for @fireStatusMonitoring.
  ///
  /// In tr, this message translates to:
  /// **'İzleniyor'**
  String get fireStatusMonitoring;

  /// No description provided for @fireStatusHistorical.
  ///
  /// In tr, this message translates to:
  /// **'Geçmiş Tespit'**
  String get fireStatusHistorical;

  /// No description provided for @fireEventRegionTitle.
  ///
  /// In tr, this message translates to:
  /// **'{city} Bölgesi Termal Tespiti'**
  String fireEventRegionTitle(String city);

  /// No description provided for @fireEventLiveDetectionTitle.
  ///
  /// In tr, this message translates to:
  /// **'Canlı Termal Tespit'**
  String get fireEventLiveDetectionTitle;

  /// No description provided for @fireEventStatusActive.
  ///
  /// In tr, this message translates to:
  /// **'Aktif'**
  String get fireEventStatusActive;

  /// No description provided for @fireEventStatusMonitoring.
  ///
  /// In tr, this message translates to:
  /// **'İzleniyor'**
  String get fireEventStatusMonitoring;

  /// No description provided for @fireEventStatusControlled.
  ///
  /// In tr, this message translates to:
  /// **'Düşük güvenilirlik'**
  String get fireEventStatusControlled;

  /// No description provided for @fireEventSpreadHigh.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek — aktif izleme gerekli'**
  String get fireEventSpreadHigh;

  /// No description provided for @fireEventSpreadMedium.
  ///
  /// In tr, this message translates to:
  /// **'Orta — dikkatli takip et'**
  String get fireEventSpreadMedium;

  /// No description provided for @fireEventSpreadLow.
  ///
  /// In tr, this message translates to:
  /// **'Düşük'**
  String get fireEventSpreadLow;

  /// No description provided for @fireDetailAreaMeasured.
  ///
  /// In tr, this message translates to:
  /// **'Tespit pikseli ~{hectares} hektar (yangının kendisi değil)'**
  String fireDetailAreaMeasured(int hectares);

  /// No description provided for @fireDetailWindLoading.
  ///
  /// In tr, this message translates to:
  /// **'Rüzgar verisi alınıyor...'**
  String get fireDetailWindLoading;

  /// No description provided for @fireDetailWindUnavailable.
  ///
  /// In tr, this message translates to:
  /// **'Rüzgar verisi alınamadı'**
  String get fireDetailWindUnavailable;

  /// No description provided for @fireDetailWindValue.
  ///
  /// In tr, this message translates to:
  /// **'{speed} km/s {direction} yönünde'**
  String fireDetailWindValue(String speed, String direction);

  /// No description provided for @windDirectionN.
  ///
  /// In tr, this message translates to:
  /// **'Kuzey'**
  String get windDirectionN;

  /// No description provided for @windDirectionNE.
  ///
  /// In tr, this message translates to:
  /// **'Kuzeydoğu'**
  String get windDirectionNE;

  /// No description provided for @windDirectionE.
  ///
  /// In tr, this message translates to:
  /// **'Doğu'**
  String get windDirectionE;

  /// No description provided for @windDirectionSE.
  ///
  /// In tr, this message translates to:
  /// **'Güneydoğu'**
  String get windDirectionSE;

  /// No description provided for @windDirectionS.
  ///
  /// In tr, this message translates to:
  /// **'Güney'**
  String get windDirectionS;

  /// No description provided for @windDirectionSW.
  ///
  /// In tr, this message translates to:
  /// **'Güneybatı'**
  String get windDirectionSW;

  /// No description provided for @windDirectionW.
  ///
  /// In tr, this message translates to:
  /// **'Batı'**
  String get windDirectionW;

  /// No description provided for @windDirectionNW.
  ///
  /// In tr, this message translates to:
  /// **'Kuzeybatı'**
  String get windDirectionNW;

  /// No description provided for @fireDetailFireRadiativePower.
  ///
  /// In tr, this message translates to:
  /// **'Yangın Işıma Gücü (FRP)'**
  String get fireDetailFireRadiativePower;

  /// No description provided for @fireDetailFrpValue.
  ///
  /// In tr, this message translates to:
  /// **'{frp} MW ({intensity})'**
  String fireDetailFrpValue(String frp, String intensity);

  /// No description provided for @fireDetailFrpUnavailable.
  ///
  /// In tr, this message translates to:
  /// **'Mevcut değil'**
  String get fireDetailFrpUnavailable;

  /// No description provided for @frpIntensityLow.
  ///
  /// In tr, this message translates to:
  /// **'Düşük yoğunluk'**
  String get frpIntensityLow;

  /// No description provided for @frpIntensityModerate.
  ///
  /// In tr, this message translates to:
  /// **'Orta yoğunluk'**
  String get frpIntensityModerate;

  /// No description provided for @frpIntensityHigh.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek yoğunluk'**
  String get frpIntensityHigh;

  /// No description provided for @frpIntensityVeryHigh.
  ///
  /// In tr, this message translates to:
  /// **'Çok yüksek yoğunluk'**
  String get frpIntensityVeryHigh;

  /// No description provided for @fireEventTempLine.
  ///
  /// In tr, this message translates to:
  /// **'Sıcaklık: {temp}°C (Termal değer: {kelvin}K)'**
  String fireEventTempLine(String temp, String kelvin);

  /// No description provided for @fireEventSatelliteLine.
  ///
  /// In tr, this message translates to:
  /// **'Uydu: {satellite}'**
  String fireEventSatelliteLine(String satellite);

  /// No description provided for @fireEventCoordinateLine.
  ///
  /// In tr, this message translates to:
  /// **'Koordinat: {coordinate}'**
  String fireEventCoordinateLine(String coordinate);

  /// No description provided for @fireEventDetectionLine.
  ///
  /// In tr, this message translates to:
  /// **'Tespit: {datetime}'**
  String fireEventDetectionLine(String datetime);

  /// No description provided for @fireDetailShareText.
  ///
  /// In tr, this message translates to:
  /// **'Yangın Uyarısı\n\n{title}\n{city} / {district}\n\nDurum: {status}\nRisk: {risk}\n\n{description}\n\nFireWatch TR ile takip ediliyor.'**
  String fireDetailShareText(
    String title,
    String city,
    String district,
    String status,
    String risk,
    String description,
  );

  /// No description provided for @settingsRefreshInterval5Min.
  ///
  /// In tr, this message translates to:
  /// **'5 dk'**
  String get settingsRefreshInterval5Min;

  /// No description provided for @settingsRefreshInterval15Min.
  ///
  /// In tr, this message translates to:
  /// **'15 dk'**
  String get settingsRefreshInterval15Min;

  /// No description provided for @settingsRefreshInterval30Min.
  ///
  /// In tr, this message translates to:
  /// **'30 dk'**
  String get settingsRefreshInterval30Min;

  /// No description provided for @settingsRefreshInterval60Min.
  ///
  /// In tr, this message translates to:
  /// **'60 dk'**
  String get settingsRefreshInterval60Min;

  /// No description provided for @newsDetailTitle.
  ///
  /// In tr, this message translates to:
  /// **'Haber Detayı'**
  String get newsDetailTitle;

  /// No description provided for @newsDetailHighlightsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Öne Çıkan Noktalar'**
  String get newsDetailHighlightsTitle;

  /// No description provided for @newsDetailHighlightsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Hızlı özet'**
  String get newsDetailHighlightsSubtitle;

  /// No description provided for @newsDetailFullContentTitle.
  ///
  /// In tr, this message translates to:
  /// **'Detaylı İçerik'**
  String get newsDetailFullContentTitle;

  /// No description provided for @newsDetailFullContentSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Gelişmenin tam özeti'**
  String get newsDetailFullContentSubtitle;

  /// No description provided for @newsDetailRelatedRegionTitle.
  ///
  /// In tr, this message translates to:
  /// **'İlgili Bölge'**
  String get newsDetailRelatedRegionTitle;

  /// No description provided for @newsDetailRelatedRegionSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantılı risk alanı'**
  String get newsDetailRelatedRegionSubtitle;

  /// No description provided for @newsDetailRelatedRegionNote.
  ///
  /// In tr, this message translates to:
  /// **'Bu gelişme ilgili bölgesel risk ve operasyon akışına bağlı olabilir.'**
  String get newsDetailRelatedRegionNote;

  /// No description provided for @newsWordCount.
  ///
  /// In tr, this message translates to:
  /// **'~{count} kelime'**
  String newsWordCount(int count);

  /// No description provided for @newsTranslate.
  ///
  /// In tr, this message translates to:
  /// **'Çevir'**
  String get newsTranslate;

  /// No description provided for @newsTranslating.
  ///
  /// In tr, this message translates to:
  /// **'Çevriliyor...'**
  String get newsTranslating;

  /// No description provided for @newsTranslated.
  ///
  /// In tr, this message translates to:
  /// **'Çevrildi'**
  String get newsTranslated;

  /// No description provided for @newsShowOriginal.
  ///
  /// In tr, this message translates to:
  /// **'Orijinali Göster'**
  String get newsShowOriginal;

  /// No description provided for @newsTranslationFailed.
  ///
  /// In tr, this message translates to:
  /// **'Çeviri başarısız oldu.'**
  String get newsTranslationFailed;

  /// No description provided for @newsTranslatedCaption.
  ///
  /// In tr, this message translates to:
  /// **'Türkçeden çevrildi • Tam çeviri için dokun'**
  String get newsTranslatedCaption;

  /// No description provided for @coachMarksGotIt.
  ///
  /// In tr, this message translates to:
  /// **'Anladım'**
  String get coachMarksGotIt;

  /// No description provided for @coachMarksSkip.
  ///
  /// In tr, this message translates to:
  /// **'Öğreticiyi Atla'**
  String get coachMarksSkip;

  /// No description provided for @coachMarksNext.
  ///
  /// In tr, this message translates to:
  /// **'İleri'**
  String get coachMarksNext;

  /// No description provided for @coachMarksStepCount.
  ///
  /// In tr, this message translates to:
  /// **'{current}/{total}'**
  String coachMarksStepCount(int current, int total);

  /// No description provided for @coachMarkMapTitle.
  ///
  /// In tr, this message translates to:
  /// **'Harita ve Yangın Noktaları'**
  String get coachMarkMapTitle;

  /// No description provided for @coachMarkMapDesc.
  ///
  /// In tr, this message translates to:
  /// **'Haritadaki alevli işaretler NASA uydu verisiyle tespit edilen canlı yangın noktalarını gösterir. Bir işarete dokunarak detayları görebilir, buradan yeni bir yangın da bildirebilirsin.'**
  String get coachMarkMapDesc;

  /// No description provided for @coachMarkRiskTitle.
  ///
  /// In tr, this message translates to:
  /// **'Risk Seviyeleri'**
  String get coachMarkRiskTitle;

  /// No description provided for @coachMarkRiskDesc.
  ///
  /// In tr, this message translates to:
  /// **'Her yangın noktası Yüksek, Orta veya Düşük risk seviyesiyle etiketlenir. Bu etiketler bölgedeki tehlike derecesini hızlıca anlamanı sağlar.'**
  String get coachMarkRiskDesc;

  /// No description provided for @coachMarkWatchlistTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedilenler'**
  String get coachMarkWatchlistTitle;

  /// No description provided for @coachMarkWatchlistDesc.
  ///
  /// In tr, this message translates to:
  /// **'Takip etmek istediğin yangın noktalarını kaydet ve buradan hızlıca tekrar ulaş.'**
  String get coachMarkWatchlistDesc;

  /// No description provided for @coachMarkNotificationsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get coachMarkNotificationsTitle;

  /// No description provided for @coachMarkNotificationsDesc.
  ///
  /// In tr, this message translates to:
  /// **'Yakınındaki yangınlar için anlık bildirim al ve otomatik taramayı buradan başlat.'**
  String get coachMarkNotificationsDesc;

  /// No description provided for @riskTabTurkeyOverview.
  ///
  /// In tr, this message translates to:
  /// **'Türkiye Geneli'**
  String get riskTabTurkeyOverview;

  /// No description provided for @riskTabMyLocation.
  ///
  /// In tr, this message translates to:
  /// **'Konumum'**
  String get riskTabMyLocation;

  /// No description provided for @riskMyLocationGettingLocation.
  ///
  /// In tr, this message translates to:
  /// **'Konumunuz alınıyor...'**
  String get riskMyLocationGettingLocation;

  /// No description provided for @riskMyLocationPermissionDenied.
  ///
  /// In tr, this message translates to:
  /// **'Konum izni verilmedi. Bölge risk bilgisini görmek için izin ver.'**
  String get riskMyLocationPermissionDenied;

  /// No description provided for @riskMyLocationServiceOff.
  ///
  /// In tr, this message translates to:
  /// **'Konum servisi kapalı. Lütfen açın.'**
  String get riskMyLocationServiceOff;

  /// No description provided for @riskMyLocationError.
  ///
  /// In tr, this message translates to:
  /// **'Konumunuz alınamadı. Lütfen tekrar deneyin.'**
  String get riskMyLocationError;

  /// No description provided for @riskMyLocationRegionNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Bölgeniz risk verisinde bulunamadı.'**
  String get riskMyLocationRegionNotFound;

  /// No description provided for @riskMyLocationEnableButton.
  ///
  /// In tr, this message translates to:
  /// **'Konumu Etkinleştir'**
  String get riskMyLocationEnableButton;

  /// No description provided for @riskMyLocationYourRegion.
  ///
  /// In tr, this message translates to:
  /// **'Bölgen: {city} ({region})'**
  String riskMyLocationYourRegion(String city, String region);

  /// No description provided for @riskMyLocationRankLabel.
  ///
  /// In tr, this message translates to:
  /// **'Sıralama: {rank}/7'**
  String riskMyLocationRankLabel(int rank);

  /// No description provided for @riskMyLocationVsAverage.
  ///
  /// In tr, this message translates to:
  /// **'Türkiye ortalamasına göre: {diff}'**
  String riskMyLocationVsAverage(String diff);

  /// No description provided for @riskMyLocationMetricsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bölgenin Verileri'**
  String get riskMyLocationMetricsTitle;

  /// No description provided for @riskChartTapHint.
  ///
  /// In tr, this message translates to:
  /// **'Detaylar için bir bölgeye dokun'**
  String get riskChartTapHint;

  /// No description provided for @monitorStatusReady.
  ///
  /// In tr, this message translates to:
  /// **'Monitoring servisi hazır.'**
  String get monitorStatusReady;

  /// No description provided for @monitorStatusAlreadyRunning.
  ///
  /// In tr, this message translates to:
  /// **'Otomatik tarama zaten çalışıyor.'**
  String get monitorStatusAlreadyRunning;

  /// No description provided for @monitorStatusStarted.
  ///
  /// In tr, this message translates to:
  /// **'Otomatik tarama başlatıldı...'**
  String get monitorStatusStarted;

  /// No description provided for @monitorStatusStopped.
  ///
  /// In tr, this message translates to:
  /// **'Otomatik tarama durduruldu.'**
  String get monitorStatusStopped;

  /// No description provided for @monitorStatusGettingLocation.
  ///
  /// In tr, this message translates to:
  /// **'Konum alınıyor...'**
  String get monitorStatusGettingLocation;

  /// No description provided for @monitorStatusLocationServiceOff.
  ///
  /// In tr, this message translates to:
  /// **'Konum servisi kapalı. Lütfen konumu açın.'**
  String get monitorStatusLocationServiceOff;

  /// No description provided for @monitorStatusLocationDenied.
  ///
  /// In tr, this message translates to:
  /// **'Konum izni verilmedi.'**
  String get monitorStatusLocationDenied;

  /// No description provided for @monitorStatusFetchingData.
  ///
  /// In tr, this message translates to:
  /// **'NASA FIRMS verisi çekiliyor...'**
  String get monitorStatusFetchingData;

  /// No description provided for @monitorStatusNoActiveFires.
  ///
  /// In tr, this message translates to:
  /// **'Şu an termal anomali verisi bulunamadı.'**
  String get monitorStatusNoActiveFires;

  /// No description provided for @monitorStatusNoNearbyFires.
  ///
  /// In tr, this message translates to:
  /// **'50 km içinde termal tespit yok. ({count} nokta tarandı)'**
  String monitorStatusNoNearbyFires(int count);

  /// No description provided for @monitorStatusNearbyFiresFound.
  ///
  /// In tr, this message translates to:
  /// **'50 km içinde {count} termal tespit bulundu!'**
  String monitorStatusNearbyFiresFound(int count);

  /// No description provided for @monitorStatusTimeout.
  ///
  /// In tr, this message translates to:
  /// **'NASA API bağlantı zaman aşımı. İnternet bağlantınızı kontrol edin.'**
  String get monitorStatusTimeout;

  /// No description provided for @monitorStatusLocationFailed.
  ///
  /// In tr, this message translates to:
  /// **'Konum alınamadı. Lütfen tekrar deneyin.'**
  String get monitorStatusLocationFailed;

  /// No description provided for @monitorStatusScanFailed.
  ///
  /// In tr, this message translates to:
  /// **'Tarama başarısız: {error}'**
  String monitorStatusScanFailed(String error);

  /// No description provided for @notifNearbyFireTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yakınında termal anomali tespit edildi'**
  String get notifNearbyFireTitle;

  /// No description provided for @notifNearbyFireBody.
  ///
  /// In tr, this message translates to:
  /// **'{distance} içinde {count} termal tespit bulundu.'**
  String notifNearbyFireBody(String distance, int count);

  /// No description provided for @notifTestBody.
  ///
  /// In tr, this message translates to:
  /// **'Test bildirimi hazır.'**
  String get notifTestBody;

  /// No description provided for @notifNewNotificationBody.
  ///
  /// In tr, this message translates to:
  /// **'Yeni bildirim'**
  String get notifNewNotificationBody;

  /// No description provided for @riskOutsideTurkeyBanner.
  ///
  /// In tr, this message translates to:
  /// **'Türkiye dışındasınız — konumunuz için bölgesel risk verisi mevcut değil.'**
  String get riskOutsideTurkeyBanner;

  /// No description provided for @riskMyLocationPostgisDistance.
  ///
  /// In tr, this message translates to:
  /// **'PostGIS • {distance} km uzaklıkta'**
  String riskMyLocationPostgisDistance(String distance);

  /// No description provided for @riskComparisonTitle.
  ///
  /// In tr, this message translates to:
  /// **'Türkiye Ortalamasıyla Karşılaştırma'**
  String get riskComparisonTitle;

  /// No description provided for @riskComparisonHigherRisk.
  ///
  /// In tr, this message translates to:
  /// **'Daha yüksek risk'**
  String get riskComparisonHigherRisk;

  /// No description provided for @riskComparisonLowerRisk.
  ///
  /// In tr, this message translates to:
  /// **'Daha düşük risk'**
  String get riskComparisonLowerRisk;

  /// No description provided for @riskComparisonSimilar.
  ///
  /// In tr, this message translates to:
  /// **'Türkiye ortalamasına yakın'**
  String get riskComparisonSimilar;

  /// No description provided for @riskInfoButtonTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Risk skoru nasıl hesaplanır?'**
  String get riskInfoButtonTooltip;

  /// No description provided for @riskInfoTitle.
  ///
  /// In tr, this message translates to:
  /// **'Risk Skoru Nasıl Hesaplanır?'**
  String get riskInfoTitle;

  /// No description provided for @riskInfoFormulaTitle.
  ///
  /// In tr, this message translates to:
  /// **'Skor Formülü'**
  String get riskInfoFormulaTitle;

  /// No description provided for @riskInfoFormulaTemp.
  ///
  /// In tr, this message translates to:
  /// **'Sıcaklık (en fazla 30 puan)'**
  String get riskInfoFormulaTemp;

  /// No description provided for @riskInfoFormulaHumidity.
  ///
  /// In tr, this message translates to:
  /// **'Düşük Nem (en fazla 25 puan)'**
  String get riskInfoFormulaHumidity;

  /// No description provided for @riskInfoFormulaWind.
  ///
  /// In tr, this message translates to:
  /// **'Rüzgar (en fazla 25 puan)'**
  String get riskInfoFormulaWind;

  /// No description provided for @riskInfoFormulaFireCount.
  ///
  /// In tr, this message translates to:
  /// **'NASA Yangın Sayısı (en fazla 20 puan)'**
  String get riskInfoFormulaFireCount;

  /// No description provided for @riskInfoSourcesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Veri Kaynakları'**
  String get riskInfoSourcesTitle;

  /// No description provided for @riskInfoSourcesBody.
  ///
  /// In tr, this message translates to:
  /// **'NASA FIRMS uydu verisi, Open-Meteo hava durumu verisi ve RSS haber akışları kullanılarak hesaplanır.'**
  String get riskInfoSourcesBody;

  /// No description provided for @riskInfoUpdateFrequencyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Güncelleme Sıklığı'**
  String get riskInfoUpdateFrequencyTitle;

  /// No description provided for @riskInfoUpdateFrequencyBody.
  ///
  /// In tr, this message translates to:
  /// **'Risk skorları her 3 saatte bir yeniden hesaplanır.'**
  String get riskInfoUpdateFrequencyBody;

  /// No description provided for @trustHomeInfo.
  ///
  /// In tr, this message translates to:
  /// **'Veriler NASA FIRMS uydu görüntülerinden alınır, her 3 saatte bir güncellenir.'**
  String get trustHomeInfo;

  /// No description provided for @trustMapInfo.
  ///
  /// In tr, this message translates to:
  /// **'Yangın işaretleri VIIRS uydusu tarafından tespit edilen termal anomalileri gösterir.'**
  String get trustMapInfo;

  /// No description provided for @trustRiskInfo.
  ///
  /// In tr, this message translates to:
  /// **'Risk skorları gerçek zamanlı hava durumu ve NASA yangın verisinden hesaplanır.'**
  String get trustRiskInfo;

  /// No description provided for @trustNewsInfo.
  ///
  /// In tr, this message translates to:
  /// **'Haberler 9 Türk kaynağından yangınla ilgili içerik için filtrelenir.'**
  String get trustNewsInfo;

  /// No description provided for @trustAlertsInfo.
  ///
  /// In tr, this message translates to:
  /// **'Konumunuza 50 km içinde yangın tespit edildiğinde bildirim gönderilir.'**
  String get trustAlertsInfo;

  /// No description provided for @trustCardLabel.
  ///
  /// In tr, this message translates to:
  /// **'Veri Kaynağı Hakkında'**
  String get trustCardLabel;

  /// No description provided for @trustAspectMeaningTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu ne anlama geliyor?'**
  String get trustAspectMeaningTitle;

  /// No description provided for @trustAspectSourceTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu nereden geliyor?'**
  String get trustAspectSourceTitle;

  /// No description provided for @trustAspectInterpretTitle.
  ///
  /// In tr, this message translates to:
  /// **'Nasıl yorumlanır'**
  String get trustAspectInterpretTitle;

  /// No description provided for @trustAspectActionTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ne yapmalıyım?'**
  String get trustAspectActionTitle;

  /// No description provided for @trustHomeMeaning.
  ///
  /// In tr, this message translates to:
  /// **'Bu ekrandaki sayılar son 24 saatte uydudan tespit edilen termal anomalilerdir; doğrulanmış yangın değildir. Bazıları tarımsal yakma, endüstriyel ısı veya sıcak yüzey olabilir.'**
  String get trustHomeMeaning;

  /// No description provided for @trustHomeSource.
  ///
  /// In tr, this message translates to:
  /// **'Veriler NASA FIRMS\'ten (Yangın Bilgi ve Kaynak Yönetim Sistemi) gelir; VIIRS ve MODIS uydu geçişlerini birleştirir ve her 3 saatte bir güncellenir.'**
  String get trustHomeSource;

  /// No description provided for @trustHomeInterpret.
  ///
  /// In tr, this message translates to:
  /// **'Yalnızca yüksek güvenilirlik, 30 MW üzeri FRP ve 350 K üzeri parlaklık koşullarının tümünü sağlayan tespitler Muhtemel Yangın olarak etiketlenir.'**
  String get trustHomeInterpret;

  /// No description provided for @trustHomeAction.
  ///
  /// In tr, this message translates to:
  /// **'Güvenilirlik, FRP ve sınırlamaları görmek için tespite dokunun. Duman veya alev görürseniz resmi acil durum yönlendirmelerini izleyin.'**
  String get trustHomeAction;

  /// No description provided for @trustMapMeaning.
  ///
  /// In tr, this message translates to:
  /// **'Her işaretçi doğrulanmış yangın değil, uydu termal anomalisidir. Kırmızı Muhtemel Yangın; turuncu yüksek anomali; sarı nominal; gri düşük güvenilirliktir.'**
  String get trustMapMeaning;

  /// No description provided for @trustMapSource.
  ///
  /// In tr, this message translates to:
  /// **'Yangın verileri NASA FIRMS\'ten (VIIRS ve MODIS uyduları) alınır. EFFIS (Kopernik Acil Durum Yönetim Servisi) API\'si yeniden erişime açıldığında ikincil doğrulama kaynağı olarak eklenecektir.'**
  String get trustMapSource;

  /// No description provided for @trustMapInterpret.
  ///
  /// In tr, this message translates to:
  /// **'Kümeler yalnızca birbirine yakın birden fazla ısı tespiti olduğunu gösterir; yangının nedenini veya büyüklüğünü doğrulamaz.'**
  String get trustMapInterpret;

  /// No description provided for @trustMapAction.
  ///
  /// In tr, this message translates to:
  /// **'Güvenilirlik ve FRP için işaretçiye dokunun. Yangını doğrudan gözlemlerseniz Rapor Et\'i kullanın ve resmi talimatları izleyin.'**
  String get trustMapAction;

  /// No description provided for @trustRiskMeaning.
  ///
  /// In tr, this message translates to:
  /// **'Risk puanı (0-100), sıcaklık, nem, rüzgar hızı ve kuraklığı birleştirerek orman yangını olasılığını tahmin eder — bu bir tahmindir, garanti değildir.'**
  String get trustRiskMeaning;

  /// No description provided for @trustRiskSource.
  ///
  /// In tr, this message translates to:
  /// **'Hava durumu verileri canlı meteorolojik kaynaklardan alınır; yangın sayıları her bölge için son NASA FIRMS tespitlerini hesaba katar.'**
  String get trustRiskSource;

  /// No description provided for @trustRiskInterpret.
  ///
  /// In tr, this message translates to:
  /// **'Bölgenizin puanını grafikte Türkiye ortalamasıyla karşılaştırın — ortalamanın önemli ölçüde üzerinde bir puan, izlenmesi gereken yükselmiş yerel koşullara işaret eder.'**
  String get trustRiskInterpret;

  /// No description provided for @trustRiskAction.
  ///
  /// In tr, this message translates to:
  /// **'Bölgeniz Kritik veya Yüksek risk gösteriyorsa açık ateşten kaçının ve herhangi bir dumanı hemen bildirin. Kişiselleştirilmiş bir döküm için \"Konumum\" sekmesine geçin.'**
  String get trustRiskAction;

  /// No description provided for @trustNewsMeaning.
  ///
  /// In tr, this message translates to:
  /// **'Başlıklar yalnızca orman yangını, afet ve acil durumla ilgili haberleri tutacak şekilde otomatik olarak filtrelenir — ilgisiz siyasi veya spor haberleri hariç tutulur.'**
  String get trustNewsMeaning;

  /// No description provided for @trustNewsSource.
  ///
  /// In tr, this message translates to:
  /// **'Makaleler, 9 köklü Türk haber kuruluşunun herkese açık RSS beslemeleri aracılığıyla toplanır ve gün boyunca sürekli güncellenir.'**
  String get trustNewsSource;

  /// No description provided for @trustNewsInterpret.
  ///
  /// In tr, this message translates to:
  /// **'\"Son Dakika\" rozeti, makalenin çok yakın zamanda yayınlandığı anlamına gelir — orman yangını durumları hızla değişebileceğinden yayın saatini her zaman kontrol edin.'**
  String get trustNewsInterpret;

  /// No description provided for @trustNewsAction.
  ///
  /// In tr, this message translates to:
  /// **'İngilizce olmayan makaleleri okumak için Çevir düğmesini kullanın veya bir haberdeki \"İlgili Yangınlar\"a dokunarak doğrudan o konuma haritada gidin.'**
  String get trustNewsAction;

  /// No description provided for @trustAlertsMeaning.
  ///
  /// In tr, this message translates to:
  /// **'Uyarılar, uydu 50 km içinde termal anomali tespit ettiğinde bildirim gönderir. Bunlar otomatik tespitlerdir, doğrulanmış olay raporları değildir.'**
  String get trustAlertsMeaning;

  /// No description provided for @trustAlertsSource.
  ///
  /// In tr, this message translates to:
  /// **'Arka plan izleme, NASA FIRMS verilerini belirli aralıklarla kontrol eder ve yeni tespitleri cihazınızın son bilinen konumuyla karşılaştırır.'**
  String get trustAlertsSource;

  /// No description provided for @trustAlertsInterpret.
  ///
  /// In tr, this message translates to:
  /// **'Güvenilirlik ısı anomalisine duyulan güveni anlatır; yangın kesinliği değildir. FRP ve parlaklığı birlikte değerlendirin.'**
  String get trustAlertsInterpret;

  /// No description provided for @trustAlertsAction.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim izni verin ve uygulamayı kullanırken Otomatik İzlemeyi başlatın. Çevrenizi manuel kontrol etmek için istediğiniz zaman \"Şimdi Tara\"yı kullanın.'**
  String get trustAlertsAction;

  /// No description provided for @newsReadFullArticle.
  ///
  /// In tr, this message translates to:
  /// **'Haberin Tamamını Oku'**
  String get newsReadFullArticle;

  /// No description provided for @smartIntensityIntense.
  ///
  /// In tr, this message translates to:
  /// **'{location} yakınında yoğun bir termal anomali tespit edildi.'**
  String smartIntensityIntense(String location);

  /// No description provided for @smartIntensityHigh.
  ///
  /// In tr, this message translates to:
  /// **'{location} yakınında yüksek yoğunluklu bir termal anomali tespit edildi.'**
  String smartIntensityHigh(String location);

  /// No description provided for @smartIntensityModerate.
  ///
  /// In tr, this message translates to:
  /// **'{location} yakınında orta düzeyde termal aktivite tespit edildi.'**
  String smartIntensityModerate(String location);

  /// No description provided for @smartIntensityEarly.
  ///
  /// In tr, this message translates to:
  /// **'{location} yakınında erken evre bir yangın veya için için yanan bitki örtüsü olabilir.'**
  String smartIntensityEarly(String location);

  /// No description provided for @smartIntensityAnomaly.
  ///
  /// In tr, this message translates to:
  /// **'{location} yakınında bir termal anomali tespit edildi.'**
  String smartIntensityAnomaly(String location);

  /// No description provided for @smartLocationHintForest.
  ///
  /// In tr, this message translates to:
  /// **'ormanlık, yüksek riskli bir bölgede'**
  String get smartLocationHintForest;

  /// No description provided for @smartLocationHintCoastal.
  ///
  /// In tr, this message translates to:
  /// **'kıyı bölgesinde'**
  String get smartLocationHintCoastal;

  /// No description provided for @smartLocationHintUrban.
  ///
  /// In tr, this message translates to:
  /// **'kentsel alanda; yapısal bir yangın veya endüstriyel ısı kaynağı olabilir'**
  String get smartLocationHintUrban;

  /// No description provided for @smartLocationHintAgricultural.
  ///
  /// In tr, this message translates to:
  /// **'tarım arazisinde; anız yakma ihtimali var'**
  String get smartLocationHintAgricultural;

  /// No description provided for @smartFrpHigh.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek ısıl güç (FRP) değeri ciddi bir enerji yayılımına işaret ediyor.'**
  String get smartFrpHigh;

  /// No description provided for @smartPixelFootprint.
  ///
  /// In tr, this message translates to:
  /// **'Uydu pikseli ~{hectares} hektar; yangın bu alanın içinde, gerçek boyutu bilinmiyor.'**
  String smartPixelFootprint(int hectares);

  /// No description provided for @smartAreaLarge.
  ///
  /// In tr, this message translates to:
  /// **'Tahmini yangın alanı geniş (~{hectares} hektar).'**
  String smartAreaLarge(int hectares);

  /// No description provided for @smartAreaMedium.
  ///
  /// In tr, this message translates to:
  /// **'Tahmini yangın alanı orta büyüklükte (~{hectares} hektar).'**
  String smartAreaMedium(int hectares);

  /// No description provided for @smartConfidenceHigh.
  ///
  /// In tr, this message translates to:
  /// **'NASA uydusu bu tespitten yüksek düzeyde emin.'**
  String get smartConfidenceHigh;

  /// No description provided for @smartConfidenceMedium.
  ///
  /// In tr, this message translates to:
  /// **'NASA bu termal anomaliyi nominal güvenilirlikte bildiriyor; doğrulama önerilir.'**
  String get smartConfidenceMedium;

  /// No description provided for @smartConfidenceLow.
  ///
  /// In tr, this message translates to:
  /// **'Olası bir termal anomali — endüstriyel ısı veya yansıma olabilir, doğrulama gerekiyor.'**
  String get smartConfidenceLow;

  /// No description provided for @smartSpreadDangerous.
  ///
  /// In tr, this message translates to:
  /// **'Bölgenin güncel risk skoru yüksek (düşük nem, güçlü rüzgar) — bu yangına özel bir ölçüm değil.'**
  String get smartSpreadDangerous;

  /// No description provided for @smartSpreadModerate.
  ///
  /// In tr, this message translates to:
  /// **'Bölgenin güncel risk skoru orta düzeyde — bu yangına özel bir ölçüm değil.'**
  String get smartSpreadModerate;

  /// No description provided for @smartSpreadLow.
  ///
  /// In tr, this message translates to:
  /// **'Bölgenin güncel risk skoru düşük — bu yangına özel bir ölçüm değil.'**
  String get smartSpreadLow;

  /// No description provided for @smartTimeJustNow.
  ///
  /// In tr, this message translates to:
  /// **'Az önce {satellite} tarafından tespit edildi.'**
  String smartTimeJustNow(String satellite);

  /// No description provided for @smartTimeRecent.
  ///
  /// In tr, this message translates to:
  /// **'{hours} saat önce {satellite} tarafından tespit edildi, hâlâ aktif olabilir.'**
  String smartTimeRecent(int hours, String satellite);

  /// No description provided for @smartTimeOlder.
  ///
  /// In tr, this message translates to:
  /// **'{hours} saat önce tespit edildi, mevcut durumu bilinmiyor.'**
  String smartTimeOlder(int hours);

  /// No description provided for @smartTimeHistorical.
  ///
  /// In tr, this message translates to:
  /// **'{days} gün önce yapılmış eski bir tespit; güncel durumu bilinmiyor.'**
  String smartTimeHistorical(int days);

  /// No description provided for @tooltipTempTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sıcaklık'**
  String get tooltipTempTitle;

  /// No description provided for @tooltipTempBody.
  ///
  /// In tr, this message translates to:
  /// **'Uydu tarafından ölçülen parlaklık sıcaklığıdır. Yüksek değer güçlü bir ısı kaynağıdır ancak tek başına yangını doğrulamaz.'**
  String get tooltipTempBody;

  /// No description provided for @tooltipConfidenceTitle.
  ///
  /// In tr, this message translates to:
  /// **'Güven Seviyesi Ne Anlama Gelir?'**
  String get tooltipConfidenceTitle;

  /// No description provided for @tooltipSatelliteTitle.
  ///
  /// In tr, this message translates to:
  /// **'Uydu Ne Anlama Gelir?'**
  String get tooltipSatelliteTitle;

  /// No description provided for @tooltipSatelliteViirsBody.
  ///
  /// In tr, this message translates to:
  /// **'VIIRS: Suomi NPP uydusu, Türkiye üzerinden günde 1-2 kez geçer.'**
  String get tooltipSatelliteViirsBody;

  /// No description provided for @tooltipSatelliteModisBody.
  ///
  /// In tr, this message translates to:
  /// **'MODIS: Terra/Aqua uydusu, daha geniş bir kapsama alanı sağlar.'**
  String get tooltipSatelliteModisBody;

  /// No description provided for @tooltipSatelliteMergedBody.
  ///
  /// In tr, this message translates to:
  /// **'Bu anomali aynı zaman ve konum aralığında birden fazla uydu cihazı tarafından tespit edildi. Tespiti güçlendirir ancak nedenini doğrulamaz.'**
  String get tooltipSatelliteMergedBody;

  /// No description provided for @fireCardMultiSourceBadge.
  ///
  /// In tr, this message translates to:
  /// **'Çoklu kaynak tespiti'**
  String get fireCardMultiSourceBadge;

  /// No description provided for @reportPanelDuplicateLocationBlocked.
  ///
  /// In tr, this message translates to:
  /// **'Bu konumdan zaten rapor gönderildi. Lütfen yetkililer ulaşana kadar bekleyin.'**
  String get reportPanelDuplicateLocationBlocked;

  /// No description provided for @reportPanelDailyLimitReached.
  ///
  /// In tr, this message translates to:
  /// **'Bugün için rapor gönderme limitine ulaştınız (günde en fazla 5). Lütfen yarın tekrar deneyin.'**
  String get reportPanelDailyLimitReached;

  /// No description provided for @fireDetailRelatedToCity.
  ///
  /// In tr, this message translates to:
  /// **'{city} ile İlgili'**
  String fireDetailRelatedToCity(String city);

  /// No description provided for @fireDetailRegionalNews.
  ///
  /// In tr, this message translates to:
  /// **'Bölgesel Haberler'**
  String get fireDetailRegionalNews;

  /// No description provided for @coachMarkMapMarkersTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yangın İşaretleri'**
  String get coachMarkMapMarkersTitle;

  /// No description provided for @coachMarkMapMarkersDesc.
  ///
  /// In tr, this message translates to:
  /// **'Haritadaki alev ikonları NASA uydusundan gelen canlı yangın tespitlerini gösterir. Bir işarete dokunarak detayları görebilirsin.'**
  String get coachMarkMapMarkersDesc;

  /// No description provided for @coachMarkMapClustersTitle.
  ///
  /// In tr, this message translates to:
  /// **'Küme Sayıları'**
  String get coachMarkMapClustersTitle;

  /// No description provided for @coachMarkMapClustersDesc.
  ///
  /// In tr, this message translates to:
  /// **'Birbirine yakın yangın noktaları bir araya toplanır ve üzerinde sayı gösteren bir daire olarak görünür. Yakınlaştırdıkça kümeler ayrışır.'**
  String get coachMarkMapClustersDesc;

  /// No description provided for @coachMarkMapReportTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yangın Bildir'**
  String get coachMarkMapReportTitle;

  /// No description provided for @coachMarkMapReportDesc.
  ///
  /// In tr, this message translates to:
  /// **'Sağ alttaki butona dokunarak gördüğün bir yangını GPS konumunla birlikte bildirebilirsin.'**
  String get coachMarkMapReportDesc;

  /// No description provided for @coachMarkMapNearbyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yakınımdaki Yangınlar'**
  String get coachMarkMapNearbyTitle;

  /// No description provided for @coachMarkMapNearbyDesc.
  ///
  /// In tr, this message translates to:
  /// **'Bu bölüm, konumuna en yakın canlı yangın tespitlerini mesafe sırasına göre listeler.'**
  String get coachMarkMapNearbyDesc;

  /// No description provided for @coachMarkNewsFeaturedTitle.
  ///
  /// In tr, this message translates to:
  /// **'Öne Çıkan Haber'**
  String get coachMarkNewsFeaturedTitle;

  /// No description provided for @coachMarkNewsFeaturedDesc.
  ///
  /// In tr, this message translates to:
  /// **'Günün en önemli gelişmesi burada öne çıkarılır.'**
  String get coachMarkNewsFeaturedDesc;

  /// No description provided for @coachMarkNewsCategoryTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kategoriler'**
  String get coachMarkNewsCategoryTitle;

  /// No description provided for @coachMarkNewsCategoryDesc.
  ///
  /// In tr, this message translates to:
  /// **'Haberleri Risk, Operasyon, Güvenlik veya Güncelleme kategorisine göre filtreleyebilirsin.'**
  String get coachMarkNewsCategoryDesc;

  /// No description provided for @coachMarkNewsRegionTitle.
  ///
  /// In tr, this message translates to:
  /// **'Durum Filtreleri'**
  String get coachMarkNewsRegionTitle;

  /// No description provided for @coachMarkNewsRegionDesc.
  ///
  /// In tr, this message translates to:
  /// **'Önem derecesine göre filtrele — kritik, aktif, izleniyor, bilgi — ya da sadece kendi bölgeni gör.'**
  String get coachMarkNewsRegionDesc;

  /// No description provided for @coachMarkNewsListTitle.
  ///
  /// In tr, this message translates to:
  /// **'Habere Dokun'**
  String get coachMarkNewsListTitle;

  /// No description provided for @coachMarkNewsListDesc.
  ///
  /// In tr, this message translates to:
  /// **'Bir habere dokunarak tam metnini oku; İngilizce moddaysan başlık ve özeti tek dokunuşla çevirebilirsin.'**
  String get coachMarkNewsListDesc;

  /// No description provided for @coachMarkNotifPermissionTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim İzni'**
  String get coachMarkNotifPermissionTitle;

  /// No description provided for @coachMarkNotifPermissionDesc.
  ///
  /// In tr, this message translates to:
  /// **'Yakınındaki yangınlar için anlık bildirim alabilmek üzere izin ver.'**
  String get coachMarkNotifPermissionDesc;

  /// No description provided for @coachMarkNotifScanTitle.
  ///
  /// In tr, this message translates to:
  /// **'Şimdi Tara'**
  String get coachMarkNotifScanTitle;

  /// No description provided for @coachMarkNotifScanDesc.
  ///
  /// In tr, this message translates to:
  /// **'Konumunun 50 km çevresinde canlı yangın olup olmadığını anında kontrol et.'**
  String get coachMarkNotifScanDesc;

  /// No description provided for @coachMarkNotifMonitoringTitle.
  ///
  /// In tr, this message translates to:
  /// **'Otomatik Tarama'**
  String get coachMarkNotifMonitoringTitle;

  /// No description provided for @coachMarkNotifMonitoringDesc.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama açıkken yakındaki termal tespitleri düzenli kontrol etmek için otomatik izlemeyi başlat.'**
  String get coachMarkNotifMonitoringDesc;

  /// No description provided for @coachMarkNotifAlertsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Uyarı Kartları'**
  String get coachMarkNotifAlertsTitle;

  /// No description provided for @coachMarkNotifAlertsDesc.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek riskli tespitler burada listelenir; bir karta dokunarak tam detaya ulaşabilirsin.'**
  String get coachMarkNotifAlertsDesc;

  /// No description provided for @coachMarkRiskScoreTitle.
  ///
  /// In tr, this message translates to:
  /// **'Risk Skoru'**
  String get coachMarkRiskScoreTitle;

  /// No description provided for @coachMarkRiskScoreDesc.
  ///
  /// In tr, this message translates to:
  /// **'0-100 arası bu skor, sıcaklık, nem, rüzgar ve NASA yangın verisinden hesaplanır. Nasıl hesaplandığını bilgi butonundan öğrenebilirsin.'**
  String get coachMarkRiskScoreDesc;

  /// No description provided for @coachMarkRiskChartTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bölgesel Dağılım'**
  String get coachMarkRiskChartTitle;

  /// No description provided for @coachMarkRiskChartDesc.
  ///
  /// In tr, this message translates to:
  /// **'Bir bölge çubuğuna dokunarak o bölgenin detaylı risk analizini görebilirsin.'**
  String get coachMarkRiskChartDesc;

  /// No description provided for @coachMarkRiskMyLocationTabTitle.
  ///
  /// In tr, this message translates to:
  /// **'Konumum'**
  String get coachMarkRiskMyLocationTabTitle;

  /// No description provided for @coachMarkRiskMyLocationTabDesc.
  ///
  /// In tr, this message translates to:
  /// **'Bu sekmeye geçerek kendi bölgenin riskini Türkiye ortalamasıyla karşılaştır.'**
  String get coachMarkRiskMyLocationTabDesc;

  /// No description provided for @coachMarkRiskInfoTitle.
  ///
  /// In tr, this message translates to:
  /// **'Veri Kaynakları'**
  String get coachMarkRiskInfoTitle;

  /// No description provided for @coachMarkRiskInfoDesc.
  ///
  /// In tr, this message translates to:
  /// **'Bilgi butonu risk skorunun formülünü, veri kaynaklarını ve güncelleme sıklığını açıklar.'**
  String get coachMarkRiskInfoDesc;

  /// No description provided for @coachMarkWatchlistPurposeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedilenler Ne İşe Yarar?'**
  String get coachMarkWatchlistPurposeTitle;

  /// No description provided for @coachMarkWatchlistPurposeDesc.
  ///
  /// In tr, this message translates to:
  /// **'Takip etmek istediğin yangın noktalarını burada bir arada tutabilirsin.'**
  String get coachMarkWatchlistPurposeDesc;

  /// No description provided for @coachMarkWatchlistHowToAddTitle.
  ///
  /// In tr, this message translates to:
  /// **'Nasıl Eklenir?'**
  String get coachMarkWatchlistHowToAddTitle;

  /// No description provided for @coachMarkWatchlistHowToAddDesc.
  ///
  /// In tr, this message translates to:
  /// **'Bir yangının detay ekranındaki yer imi butonuna dokunarak onu buraya kaydedebilirsin.'**
  String get coachMarkWatchlistHowToAddDesc;

  /// No description provided for @coachMarkWatchlistClearTitle.
  ///
  /// In tr, this message translates to:
  /// **'Temizle'**
  String get coachMarkWatchlistClearTitle;

  /// No description provided for @coachMarkWatchlistClearDesc.
  ///
  /// In tr, this message translates to:
  /// **'Üst köşedeki Temizle butonuyla tüm kayıtlı noktaları tek seferde kaldırabilirsin.'**
  String get coachMarkWatchlistClearDesc;

  /// No description provided for @detectionProbableFire.
  ///
  /// In tr, this message translates to:
  /// **'Muhtemel Yangın'**
  String get detectionProbableFire;

  /// No description provided for @detectionHighThermalAnomaly.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek Isı Anomalisi'**
  String get detectionHighThermalAnomaly;

  /// No description provided for @detectionThermalDetection.
  ///
  /// In tr, this message translates to:
  /// **'Termal Tespit'**
  String get detectionThermalDetection;

  /// No description provided for @detectionLowConfidence.
  ///
  /// In tr, this message translates to:
  /// **'Düşük Güvenilirlik'**
  String get detectionLowConfidence;

  /// No description provided for @thermalAnomalyDisclaimer.
  ///
  /// In tr, this message translates to:
  /// **'NASA uydusu termal anomalileri tespit eder. Yüksek güvenilirlikli tespitler aktif yangın göstergesi olabilir ancak endüstriyel ısı kaynakları da tespit edilebilir.'**
  String get thermalAnomalyDisclaimer;

  /// No description provided for @detectionAboutTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu tespit nedir?'**
  String get detectionAboutTitle;

  /// No description provided for @detectionAboutViirs.
  ///
  /// In tr, this message translates to:
  /// **'NASA VIIRS, Dünya yüzeyindeki kızılötesi ısıyı ölçer. Doğrulanmış yangınları değil, termal anomalileri belirler.'**
  String get detectionAboutViirs;

  /// No description provided for @detectionConfidenceExplanation.
  ///
  /// In tr, this message translates to:
  /// **'Güvenilirlik: {level}. Bu değer, uydu algoritmasının pikselde gerçek bir termal anomali bulunduğuna dair güvenidir; nedenini doğrulamaz.'**
  String detectionConfidenceExplanation(String level);

  /// No description provided for @detectionFrpExplanation.
  ///
  /// In tr, this message translates to:
  /// **'FRP: {frp} MW. Yangın Işıma Gücü yayılan ısının hızını tahmin eder; yüksek değer daha güçlü bir ısı kaynağıdır ancak kaynak endüstriyel veya tarımsal olabilir.'**
  String detectionFrpExplanation(String frp);

  /// No description provided for @detectionLimitations.
  ///
  /// In tr, this message translates to:
  /// **'Bulut, duman, uydu çözünürlüğü ve yangın dışı ısı kaynakları eksik veya yanıltıcı tespitlere yol açabilir. Güvenlik kararlarında resmi acil durum bilgilerini kullanın.'**
  String get detectionLimitations;

  /// No description provided for @mapLegendTitle.
  ///
  /// In tr, this message translates to:
  /// **'Harita Lejantı'**
  String get mapLegendTitle;

  /// No description provided for @legendProbableFire.
  ///
  /// In tr, this message translates to:
  /// **'Muhtemel Yangın'**
  String get legendProbableFire;

  /// No description provided for @legendHighThermal.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek Isı Anomalisi'**
  String get legendHighThermal;

  /// No description provided for @legendLowConfidence.
  ///
  /// In tr, this message translates to:
  /// **'Düşük Güvenilirlik'**
  String get legendLowConfidence;

  /// No description provided for @mapMarkerDisclaimerBefore.
  ///
  /// In tr, this message translates to:
  /// **'Harita NASA uydu termal tespitlerini gösterir.'**
  String get mapMarkerDisclaimerBefore;

  /// No description provided for @mapMarkerDisclaimerAfter.
  ///
  /// In tr, this message translates to:
  /// **'işaretler aktif yangın olabilir.'**
  String get mapMarkerDisclaimerAfter;

  /// No description provided for @feedbackSend.
  ///
  /// In tr, this message translates to:
  /// **'Geri Bildirim Gönder'**
  String get feedbackSend;

  /// No description provided for @feedbackTitle.
  ///
  /// In tr, this message translates to:
  /// **'Geri Bildirim Gönder'**
  String get feedbackTitle;

  /// No description provided for @feedbackRating.
  ///
  /// In tr, this message translates to:
  /// **'Puan'**
  String get feedbackRating;

  /// No description provided for @feedbackCategory.
  ///
  /// In tr, this message translates to:
  /// **'Kategori'**
  String get feedbackCategory;

  /// No description provided for @feedbackBug.
  ///
  /// In tr, this message translates to:
  /// **'Hata Bildirimi'**
  String get feedbackBug;

  /// No description provided for @feedbackFeature.
  ///
  /// In tr, this message translates to:
  /// **'Özellik İsteği'**
  String get feedbackFeature;

  /// No description provided for @feedbackGeneral.
  ///
  /// In tr, this message translates to:
  /// **'Genel Geri Bildirim'**
  String get feedbackGeneral;

  /// No description provided for @feedbackMessage.
  ///
  /// In tr, this message translates to:
  /// **'Mesaj'**
  String get feedbackMessage;

  /// No description provided for @feedbackEmail.
  ///
  /// In tr, this message translates to:
  /// **'E-posta (isteğe bağlı)'**
  String get feedbackEmail;

  /// No description provided for @feedbackSubmit.
  ///
  /// In tr, this message translates to:
  /// **'Gönder'**
  String get feedbackSubmit;

  /// No description provided for @feedbackSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Teşekkürler! Geri bildiriminiz gönderildi.'**
  String get feedbackSuccess;

  /// No description provided for @feedbackError.
  ///
  /// In tr, this message translates to:
  /// **'Geri bildirim gönderilemedi. Lütfen tekrar deneyin.'**
  String get feedbackError;

  /// No description provided for @feedbackMessageRequired.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen bir mesaj yazın.'**
  String get feedbackMessageRequired;

  /// No description provided for @feedbackRatingRequired.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen 1 ile 5 arasında bir puan seçin.'**
  String get feedbackRatingRequired;

  /// No description provided for @ratingPromptTitle.
  ///
  /// In tr, this message translates to:
  /// **'FireWatch TR\'yi beğendiniz mi?'**
  String get ratingPromptTitle;

  /// No description provided for @ratingPromptMessage.
  ///
  /// In tr, this message translates to:
  /// **'Uygulamayı birkaç gündür kullanıyorsunuz. Görüşlerinizi paylaşmak ister misiniz?'**
  String get ratingPromptMessage;

  /// No description provided for @ratingPromptLater.
  ///
  /// In tr, this message translates to:
  /// **'Daha sonra'**
  String get ratingPromptLater;

  /// No description provided for @feedbackReportBug.
  ///
  /// In tr, this message translates to:
  /// **'Hata Bildir'**
  String get feedbackReportBug;

  /// No description provided for @feedbackSendFeedback.
  ///
  /// In tr, this message translates to:
  /// **'Geri Bildirim'**
  String get feedbackSendFeedback;

  /// No description provided for @feedbackBlockedMessage.
  ///
  /// In tr, this message translates to:
  /// **'Geri bildiriminiz alındı. Yeni geri bildirim için {days} gün bekleyin.'**
  String feedbackBlockedMessage(int days);

  /// No description provided for @bugReportTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hata Bildir'**
  String get bugReportTitle;

  /// No description provided for @bugReportIntro.
  ///
  /// In tr, this message translates to:
  /// **'Neyin yanlış gittiğini anlat — doğrudan ekibe iletilir.'**
  String get bugReportIntro;

  /// No description provided for @bugReportWhatHappened.
  ///
  /// In tr, this message translates to:
  /// **'Ne oldu?'**
  String get bugReportWhatHappened;

  /// No description provided for @bugReportWhatExpected.
  ///
  /// In tr, this message translates to:
  /// **'Bunun yerine ne bekliyordunuz?'**
  String get bugReportWhatExpected;

  /// No description provided for @bugReportDeviceInfo.
  ///
  /// In tr, this message translates to:
  /// **'Cihaz bilgisi (otomatik eklenir)'**
  String get bugReportDeviceInfo;

  /// No description provided for @bugReportWhatHappenedRequired.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen ne olduğunu açıklayın.'**
  String get bugReportWhatHappenedRequired;

  /// No description provided for @coachMarkWatchlistTapTitle.
  ///
  /// In tr, this message translates to:
  /// **'Detayı Gör'**
  String get coachMarkWatchlistTapTitle;

  /// No description provided for @coachMarkWatchlistTapDesc.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedilen bir yangına dokunarak güncel durumunu ve tam detaylarını görebilirsin.'**
  String get coachMarkWatchlistTapDesc;

  /// No description provided for @notificationScopeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim Kapsamı'**
  String get notificationScopeTitle;

  /// No description provided for @notificationScopeSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Hangi yangınlar için uyarı almak istediğini seç.'**
  String get notificationScopeSubtitle;

  /// No description provided for @notificationScopeAll.
  ///
  /// In tr, this message translates to:
  /// **'Tüm Türkiye'**
  String get notificationScopeAll;

  /// No description provided for @notificationScopeAllDesc.
  ///
  /// In tr, this message translates to:
  /// **'Ülke genelindeki tüm yangın uyarılarını al.'**
  String get notificationScopeAllDesc;

  /// No description provided for @notificationScopeRegion.
  ///
  /// In tr, this message translates to:
  /// **'Sadece bölgem'**
  String get notificationScopeRegion;

  /// No description provided for @notificationScopeRegionDesc.
  ///
  /// In tr, this message translates to:
  /// **'Yalnızca seçtiğin coğrafi bölgedeki yangınlar.'**
  String get notificationScopeRegionDesc;

  /// No description provided for @notificationScopeCity.
  ///
  /// In tr, this message translates to:
  /// **'Sadece ilim'**
  String get notificationScopeCity;

  /// No description provided for @notificationScopeCityDesc.
  ///
  /// In tr, this message translates to:
  /// **'Yalnızca seçtiğin ildeki yangınlar.'**
  String get notificationScopeCityDesc;

  /// No description provided for @notificationScopeRegionLabel.
  ///
  /// In tr, this message translates to:
  /// **'Bölge'**
  String get notificationScopeRegionLabel;

  /// No description provided for @notificationScopeCityLabel.
  ///
  /// In tr, this message translates to:
  /// **'İl'**
  String get notificationScopeCityLabel;

  /// No description provided for @notificationScopeSelectRegion.
  ///
  /// In tr, this message translates to:
  /// **'Bölge seç'**
  String get notificationScopeSelectRegion;

  /// No description provided for @notificationScopeSelectCity.
  ///
  /// In tr, this message translates to:
  /// **'İl seç'**
  String get notificationScopeSelectCity;

  /// No description provided for @notificationScopeDetected.
  ///
  /// In tr, this message translates to:
  /// **'Konumundan algılandı: {name}'**
  String notificationScopeDetected(String name);

  /// No description provided for @notificationScopeDetecting.
  ///
  /// In tr, this message translates to:
  /// **'Konumun belirleniyor...'**
  String get notificationScopeDetecting;

  /// No description provided for @notificationScopeSaved.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim kapsamı güncellendi.'**
  String get notificationScopeSaved;

  /// No description provided for @notificationScopeSaveFailed.
  ///
  /// In tr, this message translates to:
  /// **'Kapsam kaydedilemedi. İnternet bağlantını kontrol et.'**
  String get notificationScopeSaveFailed;

  /// No description provided for @notificationScopeCitiesUnavailable.
  ///
  /// In tr, this message translates to:
  /// **'İl listesi yüklenemedi.'**
  String get notificationScopeCitiesUnavailable;

  /// No description provided for @notificationScopeNarrowWarning.
  ///
  /// In tr, this message translates to:
  /// **'Kapsamı daraltmak, seçtiğin alan dışındaki yangınlar için uyarı almayacağın anlamına gelir.'**
  String get notificationScopeNarrowWarning;

  /// No description provided for @incidentsSectionTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yangın Olayları'**
  String get incidentsSectionTitle;

  /// No description provided for @incidentsSectionSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Uydu tespitleri olaylara gruplanmış'**
  String get incidentsSectionSubtitle;

  /// No description provided for @incidentStatusActive.
  ///
  /// In tr, this message translates to:
  /// **'Aktif tespit'**
  String get incidentStatusActive;

  /// No description provided for @incidentStatusAwaiting.
  ///
  /// In tr, this message translates to:
  /// **'Tespit bekleniyor'**
  String get incidentStatusAwaiting;

  /// No description provided for @incidentStatusLowConfidence.
  ///
  /// In tr, this message translates to:
  /// **'Düşük güvenilirlik'**
  String get incidentStatusLowConfidence;

  /// No description provided for @incidentDetectedHoursAgo.
  ///
  /// In tr, this message translates to:
  /// **'Son {hours} saat içinde tespit edildi'**
  String incidentDetectedHoursAgo(String hours);

  /// No description provided for @incidentNoDetectionFor.
  ///
  /// In tr, this message translates to:
  /// **'Yangın tespit edildi, {hours} saattir görülmüyor'**
  String incidentNoDetectionFor(String hours);

  /// No description provided for @incidentNoDetectionLowConfidence.
  ///
  /// In tr, this message translates to:
  /// **'Yangın tespit edildi, {hours} saattir görülmüyor (düşük güvenilirlik)'**
  String incidentNoDetectionLowConfidence(String hours);

  /// No description provided for @incidentDurationOngoing.
  ///
  /// In tr, this message translates to:
  /// **'En az {hours} saattir tespit ediliyor'**
  String incidentDurationOngoing(String hours);

  /// No description provided for @incidentDurationShort.
  ///
  /// In tr, this message translates to:
  /// **'Tek geçişte tespit edildi'**
  String get incidentDurationShort;

  /// No description provided for @incidentEvidence.
  ///
  /// In tr, this message translates to:
  /// **'{detections} tespit, {passes} uydu geçişi'**
  String incidentEvidence(int detections, int passes);

  /// No description provided for @incidentHeatLabel.
  ///
  /// In tr, this message translates to:
  /// **'Isı şiddeti'**
  String get incidentHeatLabel;

  /// No description provided for @incidentHeatLow.
  ///
  /// In tr, this message translates to:
  /// **'Düşük'**
  String get incidentHeatLow;

  /// No description provided for @incidentHeatModerate.
  ///
  /// In tr, this message translates to:
  /// **'Orta'**
  String get incidentHeatModerate;

  /// No description provided for @incidentHeatHigh.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek'**
  String get incidentHeatHigh;

  /// No description provided for @incidentHeatVeryHigh.
  ///
  /// In tr, this message translates to:
  /// **'Çok yüksek'**
  String get incidentHeatVeryHigh;

  /// No description provided for @incidentSpreadTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yayılma (tahmini)'**
  String get incidentSpreadTitle;

  /// No description provided for @incidentSpreadLine.
  ///
  /// In tr, this message translates to:
  /// **'{direction}, saatte ~{meters} metre'**
  String incidentSpreadLine(String direction, String meters);

  /// No description provided for @incidentSpreadEstimateNote.
  ///
  /// In tr, this message translates to:
  /// **'Uydu tespit deseninin kaymasından hesaplanır; yangının gerçek ilerleyişi farklı olabilir.'**
  String get incidentSpreadEstimateNote;

  /// No description provided for @incidentTrendWeakening.
  ///
  /// In tr, this message translates to:
  /// **'Isı şiddeti azalıyor'**
  String get incidentTrendWeakening;

  /// No description provided for @incidentTrendIntensifying.
  ///
  /// In tr, this message translates to:
  /// **'Isı şiddeti artıyor'**
  String get incidentTrendIntensifying;

  /// No description provided for @incidentTrendStable.
  ///
  /// In tr, this message translates to:
  /// **'Isı şiddeti değişmiyor'**
  String get incidentTrendStable;

  /// No description provided for @incidentTrendNote.
  ///
  /// In tr, this message translates to:
  /// **'Uydunun ölçtüğü ısı yayımına göre. Söndürme çalışması olup olmadığı bu veriden anlaşılmaz.'**
  String get incidentTrendNote;

  /// No description provided for @incidentToggleShow.
  ///
  /// In tr, this message translates to:
  /// **'Yangın olayları'**
  String get incidentToggleShow;

  /// No description provided for @incidentToggleDetections.
  ///
  /// In tr, this message translates to:
  /// **'Olası yangın noktaları'**
  String get incidentToggleDetections;

  /// No description provided for @incidentLayerCaptionDetections.
  ///
  /// In tr, this message translates to:
  /// **'Uydunun tek tek gördüğü sıcak noktalar; her biri yangın olmayabilir.'**
  String get incidentLayerCaptionDetections;

  /// No description provided for @incidentLayerCaptionEvents.
  ///
  /// In tr, this message translates to:
  /// **'Aynı yangına ait tespitler tek bir olayda birleştirildi.'**
  String get incidentLayerCaptionEvents;

  /// No description provided for @incidentFilterActive.
  ///
  /// In tr, this message translates to:
  /// **'Aktif'**
  String get incidentFilterActive;

  /// No description provided for @incidentFilterEnded.
  ///
  /// In tr, this message translates to:
  /// **'Artık görülmüyor'**
  String get incidentFilterEnded;

  /// No description provided for @incidentFilterAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get incidentFilterAll;

  /// No description provided for @riskLayerToggle.
  ///
  /// In tr, this message translates to:
  /// **'Risk (FWI)'**
  String get riskLayerToggle;

  /// No description provided for @incidentToggleShowShort.
  ///
  /// In tr, this message translates to:
  /// **'Olaylar'**
  String get incidentToggleShowShort;

  /// No description provided for @incidentToggleDetectionsShort.
  ///
  /// In tr, this message translates to:
  /// **'Noktalar'**
  String get incidentToggleDetectionsShort;

  /// No description provided for @mapLayersButton.
  ///
  /// In tr, this message translates to:
  /// **'Katmanlar'**
  String get mapLayersButton;

  /// No description provided for @placesButton.
  ///
  /// In tr, this message translates to:
  /// **'Yerlerim'**
  String get placesButton;

  /// No description provided for @placesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kayıtlı Yerler'**
  String get placesTitle;

  /// No description provided for @placesSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Harita bu yerlere yakınlaşır; istersen bildirim kapsamın da bu yerlere daralır.'**
  String get placesSubtitle;

  /// No description provided for @placesEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Henüz kayıtlı yer yok. İl veya ilçe ara, ya da haritaya iğne bırak.'**
  String get placesEmpty;

  /// No description provided for @placesSearchHint.
  ///
  /// In tr, this message translates to:
  /// **'İl veya ilçe ara'**
  String get placesSearchHint;

  /// No description provided for @placesDropPin.
  ///
  /// In tr, this message translates to:
  /// **'Haritaya iğne bırak'**
  String get placesDropPin;

  /// No description provided for @placesDropPinHint.
  ///
  /// In tr, this message translates to:
  /// **'Kaydetmek istediğin noktaya dokun'**
  String get placesDropPinHint;

  /// No description provided for @placesPinNameTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yere bir ad ver'**
  String get placesPinNameTitle;

  /// No description provided for @placesPinDefaultName.
  ///
  /// In tr, this message translates to:
  /// **'Kayıtlı nokta'**
  String get placesPinDefaultName;

  /// No description provided for @placesShowAllPlaces.
  ///
  /// In tr, this message translates to:
  /// **'Hepsini göster'**
  String get placesShowAllPlaces;

  /// No description provided for @placesResetView.
  ///
  /// In tr, this message translates to:
  /// **'Tüm Türkiye'**
  String get placesResetView;

  /// No description provided for @placesRemove.
  ///
  /// In tr, this message translates to:
  /// **'Yeri sil'**
  String get placesRemove;

  /// No description provided for @placesRiskUnknown.
  ///
  /// In tr, this message translates to:
  /// **'Risk alınamadı'**
  String get placesRiskUnknown;

  /// No description provided for @placesRiskNoData.
  ///
  /// In tr, this message translates to:
  /// **'Veri yok'**
  String get placesRiskNoData;

  /// No description provided for @placesRiskLine.
  ///
  /// In tr, this message translates to:
  /// **'FWI tehlikesi · {day}'**
  String placesRiskLine(String day);

  /// No description provided for @placesActiveDetections.
  ///
  /// In tr, this message translates to:
  /// **'{count} aktif tespit'**
  String placesActiveDetections(int count);

  /// No description provided for @placesNoActiveDetections.
  ///
  /// In tr, this message translates to:
  /// **'Aktif tespit yok'**
  String get placesNoActiveDetections;

  /// No description provided for @placesLastDetection.
  ///
  /// In tr, this message translates to:
  /// **'Son tespit ~{hours} saat önce'**
  String placesLastDetection(String hours);

  /// No description provided for @placesResolutionNote.
  ///
  /// In tr, this message translates to:
  /// **'FWI sınıfı ~10 km çözünürlüklü bölgesel bir tahmindir; il ve ilçe ölçeğinde anlamlıdır, mahalle ölçeğinde ayrışmaz. Yakın iki yerin aynı sınıfı göstermesi verinin çözünürlüğüdür, hata değil.'**
  String get placesResolutionNote;

  /// No description provided for @notificationScopePlaces.
  ///
  /// In tr, this message translates to:
  /// **'Kayıtlı yerlerim'**
  String get notificationScopePlaces;

  /// No description provided for @notificationScopePlacesDesc.
  ///
  /// In tr, this message translates to:
  /// **'Yalnızca harita ekranında kaydettiğin il, ilçe ve noktaların çevresindeki yangınlar.'**
  String get notificationScopePlacesDesc;

  /// No description provided for @notificationScopePlacesEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Henüz kayıtlı yer yok. Harita ekranındaki Yerlerim panelinden ekleyebilirsin.'**
  String get notificationScopePlacesEmpty;

  /// No description provided for @notificationScopePlacesNote.
  ///
  /// In tr, this message translates to:
  /// **'{count} kayıtlı yer izleniyor. Bu kapsam şimdilik bu cihazın kendi taramalarıyla uygulanır; sunucu bildirimleri son seçtiğin il/bölge kapsamını kullanmaya devam eder.'**
  String notificationScopePlacesNote(int count);

  /// No description provided for @notifPlacesFireTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kayıtlı yerinde yangın tespiti'**
  String get notifPlacesFireTitle;

  /// No description provided for @notifPlacesFireBody.
  ///
  /// In tr, this message translates to:
  /// **'Kayıtlı yerlerinin çevresinde {count} termal tespit var. Harita ekranından kontrol et.'**
  String notifPlacesFireBody(int count);

  /// No description provided for @riskLegendTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yangın tehlikesi (FWI)'**
  String get riskLegendTitle;

  /// No description provided for @riskLegendNote.
  ///
  /// In tr, this message translates to:
  /// **'Hava koşullarından hesaplanan bölgesel tehlike tahmini; uydu tespiti değildir.'**
  String get riskLegendNote;

  /// No description provided for @riskLegendHide.
  ///
  /// In tr, this message translates to:
  /// **'Lejantı gizle'**
  String get riskLegendHide;

  /// No description provided for @riskClassVeryLow.
  ///
  /// In tr, this message translates to:
  /// **'Çok düşük'**
  String get riskClassVeryLow;

  /// No description provided for @riskClassLow.
  ///
  /// In tr, this message translates to:
  /// **'Düşük'**
  String get riskClassLow;

  /// No description provided for @riskClassModerate.
  ///
  /// In tr, this message translates to:
  /// **'Orta'**
  String get riskClassModerate;

  /// No description provided for @riskClassHigh.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek'**
  String get riskClassHigh;

  /// No description provided for @riskClassVeryHigh.
  ///
  /// In tr, this message translates to:
  /// **'Çok yüksek'**
  String get riskClassVeryHigh;

  /// No description provided for @riskClassExtreme.
  ///
  /// In tr, this message translates to:
  /// **'Aşırı'**
  String get riskClassExtreme;

  /// No description provided for @riskOpacityLabel.
  ///
  /// In tr, this message translates to:
  /// **'Opaklık'**
  String get riskOpacityLabel;

  /// No description provided for @riskDayToday.
  ///
  /// In tr, this message translates to:
  /// **'Bugün'**
  String get riskDayToday;

  /// No description provided for @riskDayTomorrow.
  ///
  /// In tr, this message translates to:
  /// **'Yarın'**
  String get riskDayTomorrow;

  /// No description provided for @riskAttribution.
  ///
  /// In tr, this message translates to:
  /// **'© European Union, Copernicus EFFIS'**
  String get riskAttribution;

  /// No description provided for @homeLast24hTitle.
  ///
  /// In tr, this message translates to:
  /// **'Son 24 Saat'**
  String get homeLast24hTitle;

  /// No description provided for @homeLast24hSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Uydu tespitlerinin özeti'**
  String get homeLast24hSubtitle;

  /// No description provided for @homeLast24hActiveTitle.
  ///
  /// In tr, this message translates to:
  /// **'Aktif tespit'**
  String get homeLast24hActiveTitle;

  /// No description provided for @homeLast24hActiveSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Son {hours} saat içinde uydu tarafından görüldü'**
  String homeLast24hActiveSubtitle(int hours);

  /// No description provided for @homeLast24hActiveSubtitleLayered.
  ///
  /// In tr, this message translates to:
  /// **'{strong} tanesi güçlü kanıtlı; son {hours} saatte uyduyla görüldü'**
  String homeLast24hActiveSubtitleLayered(int strong, int hours);

  /// No description provided for @homeLast24hEndedTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tespiti sona eren'**
  String get homeLast24hEndedTitle;

  /// No description provided for @homeLast24hEndedSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Söndüğü anlamına gelmez.'**
  String get homeLast24hEndedSubtitle;

  /// No description provided for @homeLast24hLongestTitle.
  ///
  /// In tr, this message translates to:
  /// **'En uzun süren'**
  String get homeLast24hLongestTitle;

  /// No description provided for @homeLast24hLongestSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'İlk tespitten bu yana, halen tespit ediliyor'**
  String get homeLast24hLongestSubtitle;

  /// No description provided for @homeLast24hStrongestTitle.
  ///
  /// In tr, this message translates to:
  /// **'En şiddetli yangın'**
  String get homeLast24hStrongestTitle;

  /// No description provided for @homeLast24hStrongestPower.
  ///
  /// In tr, this message translates to:
  /// **'{mw} MW'**
  String homeLast24hStrongestPower(int mw);

  /// No description provided for @homeLast24hStrongestSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Şu an en yüksek ısı gücü, halen tespit ediliyor'**
  String get homeLast24hStrongestSubtitle;

  /// No description provided for @homeLast24hStrongestSubtitleWithDuration.
  ///
  /// In tr, this message translates to:
  /// **'En az {duration}, halen tespit ediliyor'**
  String homeLast24hStrongestSubtitleWithDuration(String duration);

  /// No description provided for @durationHoursShort.
  ///
  /// In tr, this message translates to:
  /// **'{hours} sa'**
  String durationHoursShort(int hours);

  /// No description provided for @durationDaysHours.
  ///
  /// In tr, this message translates to:
  /// **'{days} g {hours} sa'**
  String durationDaysHours(int days, int hours);

  /// No description provided for @incidentsEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Bu aralıkta gruplanmış yangın olayı yok.'**
  String get incidentsEmpty;

  /// No description provided for @incidentsCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} olay'**
  String incidentsCount(int count);

  /// No description provided for @incidentPanelTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yangın Olayı'**
  String get incidentPanelTitle;

  /// No description provided for @incidentOfficialTitle.
  ///
  /// In tr, this message translates to:
  /// **'Resmî durum'**
  String get incidentOfficialTitle;

  /// No description provided for @incidentSatelliteLimitNote.
  ///
  /// In tr, this message translates to:
  /// **'Uydu günde birkaç kez geçer ve bulut ya da duman altını göremez. Tespit olmaması yangının bittiği anlamına gelmez.'**
  String get incidentSatelliteLimitNote;

  /// No description provided for @incidentFixedSourceHint.
  ///
  /// In tr, this message translates to:
  /// **'Bu konum iki gündür her uydu geçişinde ve değişmeyen güçte görünüyor — sabit bir ısı kaynağı olabilir.'**
  String get incidentFixedSourceHint;

  /// No description provided for @incidentLegendTitle.
  ///
  /// In tr, this message translates to:
  /// **'Harita göstergesi'**
  String get incidentLegendTitle;

  /// No description provided for @compassTowardsNorth.
  ///
  /// In tr, this message translates to:
  /// **'kuzeye doğru'**
  String get compassTowardsNorth;

  /// No description provided for @compassTowardsNorthEast.
  ///
  /// In tr, this message translates to:
  /// **'kuzeydoğuya doğru'**
  String get compassTowardsNorthEast;

  /// No description provided for @compassTowardsEast.
  ///
  /// In tr, this message translates to:
  /// **'doğuya doğru'**
  String get compassTowardsEast;

  /// No description provided for @compassTowardsSouthEast.
  ///
  /// In tr, this message translates to:
  /// **'güneydoğuya doğru'**
  String get compassTowardsSouthEast;

  /// No description provided for @compassTowardsSouth.
  ///
  /// In tr, this message translates to:
  /// **'güneye doğru'**
  String get compassTowardsSouth;

  /// No description provided for @compassTowardsSouthWest.
  ///
  /// In tr, this message translates to:
  /// **'güneybatıya doğru'**
  String get compassTowardsSouthWest;

  /// No description provided for @compassTowardsWest.
  ///
  /// In tr, this message translates to:
  /// **'batıya doğru'**
  String get compassTowardsWest;

  /// No description provided for @compassTowardsNorthWest.
  ///
  /// In tr, this message translates to:
  /// **'kuzeybatıya doğru'**
  String get compassTowardsNorthWest;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
