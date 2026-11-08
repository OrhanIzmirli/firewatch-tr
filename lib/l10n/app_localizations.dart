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
  /// **'Yangınları takip edin, güvende kalın'**
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
  /// **'Aktif olayları takip edin'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In tr, this message translates to:
  /// **'Türkiye genelindeki uydu tespitlerini tek ekranda takip edin ve durum değişikliklerini hızlıca görün.'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In tr, this message translates to:
  /// **'Yakınınızdaki bölgeleri görün'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In tr, this message translates to:
  /// **'Harita ve bölge odaklı ekranlarla size yakın olayları daha hızlı fark edin.'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In tr, this message translates to:
  /// **'Güvenlik yönlendirmeleri alın'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In tr, this message translates to:
  /// **'Risk seviyelerini inceleyin, önerilen aksiyonları görün ve gerektiğinde hızlı hareket edin.'**
  String get onboardingDesc3;

  /// No description provided for @homeLiveSummary.
  ///
  /// In tr, this message translates to:
  /// **'Güncel Durum Özeti'**
  String get homeLiveSummary;

  /// No description provided for @homeHeaderTitle.
  ///
  /// In tr, this message translates to:
  /// **'Türkiye Uydu Tespitleri'**
  String get homeHeaderTitle;

  /// No description provided for @homeHeaderSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Aktif olayları takip edin, risk seviyelerini görün ve güvenlik rehberine hızlıca ulaşın.'**
  String get homeHeaderSubtitle;

  /// No description provided for @homeNasaLiveData.
  ///
  /// In tr, this message translates to:
  /// **'NASA FIRMS • Uydu Verisi'**
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
  /// **'NASA FIRMS uydu verisi'**
  String get homeOverviewSubtitle;

  /// No description provided for @homeOverviewUniqueCount.
  ///
  /// In tr, this message translates to:
  /// **'Uydular {count} ayrı konumda tespit yaptı'**
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
  /// **'Güncel Uydu Tespitleri'**
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
  /// **'Yakındaki Uydu Tespitleri'**
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
  /// **'Son haber: {timeAgo}'**
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
  /// **'{count} son dakika'**
  String homeBreakingCount(int count);

  /// No description provided for @homeNewsLoading.
  ///
  /// In tr, this message translates to:
  /// **'Haber yükleniyor...'**
  String get homeNewsLoading;

  /// No description provided for @homeActiveThermalPoints.
  ///
  /// In tr, this message translates to:
  /// **'Güncel Uydu Tespitleri'**
  String get homeActiveThermalPoints;

  /// No description provided for @homeActiveThermalSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'NASA uydu verisi'**
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
  /// **'Uydular şu an güncel bir tespit bildirmedi.'**
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
  /// **'Uydu Tespit Haritası'**
  String get mapTitle;

  /// No description provided for @mapTitleEvents.
  ///
  /// In tr, this message translates to:
  /// **'Yangın Haritası'**
  String get mapTitleEvents;

  /// No description provided for @mapTitleDetections.
  ///
  /// In tr, this message translates to:
  /// **'Uydu Tespit Haritası'**
  String get mapTitleDetections;

  /// No description provided for @mapLiveMap.
  ///
  /// In tr, this message translates to:
  /// **'Güncel Harita'**
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
  /// **'NASA FIRMS işaret görünümü'**
  String get mapAreaSubtitle;

  /// No description provided for @mapGoToMe.
  ///
  /// In tr, this message translates to:
  /// **'Bana Git'**
  String get mapGoToMe;

  /// No description provided for @mapNearbyFires.
  ///
  /// In tr, this message translates to:
  /// **'Yakınımdaki Uydu Tespitleri'**
  String get mapNearbyFires;

  /// No description provided for @mapNearbyFiresSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Konumunuza en yakın güncel tespitler'**
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
  /// **'Yakındaki olaylar, durum değişimleri ve saha güncellemelerini tek akışta takip edin.'**
  String get notificationsFeedSubtitle;

  /// No description provided for @notificationsTools.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim Araçları'**
  String get notificationsTools;

  /// No description provided for @notificationsToolsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'İzinleri ve otomatik uydu tespiti takibini yönetin'**
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
  /// **'Uygulama kapalıyken yaklaşık 15 dakikada bir uydu tespitlerini kontrol edin (Android bunu geciktirebilir)'**
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
  /// **'FireWatch TR, uygulama kapalıyken de yakınınızdaki yangınları kontrol edip sizi uyarabilmek için konumunuza arka planda erişim istiyor. Bu kontroller telefonunuzda yapılır; bu sırada konumunuz sunucuya gönderilmez. Bu izni vermezseniz uygulama sadece açıkken tarama yapabilir. Sistem izin ekranında \"Her zaman izin ver\" seçeneğini seçmeniz gerekir.'**
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
  /// **'Yakındaki Uydu Tespitleri'**
  String get notificationsNearbyLiveFires;

  /// No description provided for @notificationsNearbyLiveFiresSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Konumunuza 50 km içinde bulunan noktalar'**
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
  /// **'Uydular şu an güçlü bir tespit bildirmedi.'**
  String get notificationsNoHighRisk;

  /// No description provided for @notificationsHighRiskDetectionTitle.
  ///
  /// In tr, this message translates to:
  /// **'Güçlü Uydu Tespiti'**
  String get notificationsHighRiskDetectionTitle;

  /// No description provided for @notificationsHighRiskDetectionBody.
  ///
  /// In tr, this message translates to:
  /// **'Uydular {region} bölgesinde güçlü bir ısı tespit etti ({temp}K). Doğrulanmadı.'**
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
  /// **'Takip etmek istediğiniz uydu tespitlerini burada saklayabilirsiniz.'**
  String get watchlistHeadingSubtitle;

  /// No description provided for @watchlistEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Henüz kaydedilmiş olay yok'**
  String get watchlistEmptyTitle;

  /// No description provided for @watchlistEmptySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Tespit detay ekranındaki Kaydet butonunu kullanarak ekleyebilirsiniz.'**
  String get watchlistEmptySubtitle;

  /// No description provided for @watchlistSavedPoints.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedilen Noktalar'**
  String get watchlistSavedPoints;

  /// No description provided for @watchlistSavedPointsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'{count} uydu tespiti takipte'**
  String watchlistSavedPointsSubtitle(int count);

  /// No description provided for @watchlistSyncingTitle.
  ///
  /// In tr, this message translates to:
  /// **'{count} kaydedilmiş uydu tespiti var.'**
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
  /// **'Acil durum anında hızlı erişim, temel hazırlık ve kritik yönlendirmeleri tek ekranda toplayın.'**
  String get emergencyQuickToolsSubtitle;

  /// No description provided for @emergencyStayReady.
  ///
  /// In tr, this message translates to:
  /// **'Hazır Kalın'**
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
  /// **'Yakınlarınıza yer bildirin'**
  String get emergencyShareLocationSubtitle;

  /// No description provided for @emergencyEvacuationPlan.
  ///
  /// In tr, this message translates to:
  /// **'Tahliye Planı'**
  String get emergencyEvacuationPlan;

  /// No description provided for @emergencyEvacuationPlanSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış adımlarını gözden geçirin'**
  String get emergencyEvacuationPlanSubtitle;

  /// No description provided for @emergencyContactLines.
  ///
  /// In tr, this message translates to:
  /// **'Acil İletişim Hatları'**
  String get emergencyContactLines;

  /// No description provided for @emergencyContactLinesSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Temel numaraları hazır tutun'**
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
  /// **'Kimlik, önemli evrak ve telefonunuzu tek yerde tutun.'**
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
  /// **'Ayrı düşme ihtimaline karşı önceden karar verin.'**
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
  /// **'1. Resmi uyarıları doğrulayın'**
  String get emergencyStep1;

  /// No description provided for @emergencyStep2.
  ///
  /// In tr, this message translates to:
  /// **'2. Yakınlarınızı kısa mesajla haberdar edin'**
  String get emergencyStep2;

  /// No description provided for @emergencyStep3.
  ///
  /// In tr, this message translates to:
  /// **'3. Gerekliyse temel çantanızı alın ve güvenli çıkış rotasına yönelin'**
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
  /// **'Yangın sırasında ne yapacağınızı hızlıca görmek, tahliye mantığını anlamak ve doğru adımları takip etmek için hazırlanmış rehber ekranı.'**
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
  /// **'Tahliyeye Hazır Olun'**
  String get safetyGuideReadyEvacuate;

  /// No description provided for @safetyGuideReadyEvacuateSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış planını netleştirin'**
  String get safetyGuideReadyEvacuateSubtitle;

  /// No description provided for @safetyGuideTakeSmokeSeriously.
  ///
  /// In tr, this message translates to:
  /// **'Dumanı Ciddiye Alın'**
  String get safetyGuideTakeSmokeSeriously;

  /// No description provided for @safetyGuideTakeSmokeSeriouslySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Kapalı alana geçin, maske kullanın'**
  String get safetyGuideTakeSmokeSeriouslySubtitle;

  /// No description provided for @safetyGuideFollowOfficials.
  ///
  /// In tr, this message translates to:
  /// **'Yetkili Duyuruları İzleyin'**
  String get safetyGuideFollowOfficials;

  /// No description provided for @safetyGuideFollowOfficialsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Resmi kaynakları takip edin'**
  String get safetyGuideFollowOfficialsSubtitle;

  /// No description provided for @safetyGuideDontDelay.
  ///
  /// In tr, this message translates to:
  /// **'Geç Kalmayın'**
  String get safetyGuideDontDelay;

  /// No description provided for @safetyGuideDontDelaySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Tahliye çağrısını bekletmeyin'**
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
  /// **'Kimlik, telefon ve şarj aletini hazır tutun'**
  String get safetyGuideChecklist1Title;

  /// No description provided for @safetyGuideChecklist1Desc.
  ///
  /// In tr, this message translates to:
  /// **'Zorunlu temel eşyaları tek yerde toplayın.'**
  String get safetyGuideChecklist1Desc;

  /// No description provided for @safetyGuideChecklist2Title.
  ///
  /// In tr, this message translates to:
  /// **'Kapı ve pencere durumunu kontrol edin'**
  String get safetyGuideChecklist2Title;

  /// No description provided for @safetyGuideChecklist2Desc.
  ///
  /// In tr, this message translates to:
  /// **'Duman girişini azaltmak için açık alanları gözden geçirin.'**
  String get safetyGuideChecklist2Desc;

  /// No description provided for @safetyGuideChecklist3Title.
  ///
  /// In tr, this message translates to:
  /// **'Aile / yakınlarınızla buluşma planı belirleyin'**
  String get safetyGuideChecklist3Title;

  /// No description provided for @safetyGuideChecklist3Desc.
  ///
  /// In tr, this message translates to:
  /// **'Ayrı düşerseniz nerede buluşacağınızı önceden bilin.'**
  String get safetyGuideChecklist3Desc;

  /// No description provided for @safetyGuideChecklist4Title.
  ///
  /// In tr, this message translates to:
  /// **'Resmi tahliye rotasını takip edin'**
  String get safetyGuideChecklist4Title;

  /// No description provided for @safetyGuideChecklist4Desc.
  ///
  /// In tr, this message translates to:
  /// **'Kendi başınıza riskli güzergah uydurmayın.'**
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
  /// **'Evdeyseniz ne yapmalısınız?'**
  String get safetyGuideAtHomeTitle;

  /// No description provided for @safetyGuideAtHome1.
  ///
  /// In tr, this message translates to:
  /// **'Duman yoğunluğu varsa kapı ve pencereleri kapalı tutun.'**
  String get safetyGuideAtHome1;

  /// No description provided for @safetyGuideAtHome2.
  ///
  /// In tr, this message translates to:
  /// **'Elektrik, gaz ve hızlı çıkış güzergahını kontrol edin.'**
  String get safetyGuideAtHome2;

  /// No description provided for @safetyGuideAtHome3.
  ///
  /// In tr, this message translates to:
  /// **'Tahliye çağrısı varsa eşyaları toplamaya çalışmayın, çıkışa odaklanın.'**
  String get safetyGuideAtHome3;

  /// No description provided for @safetyGuideAtHome4.
  ///
  /// In tr, this message translates to:
  /// **'Evcil hayvanları mümkünse hızlıca güvenli taşıma düzenine alın.'**
  String get safetyGuideAtHome4;

  /// No description provided for @safetyGuideInCarTitle.
  ///
  /// In tr, this message translates to:
  /// **'Araçtayken ne yapmalısınız?'**
  String get safetyGuideInCarTitle;

  /// No description provided for @safetyGuideInCar1.
  ///
  /// In tr, this message translates to:
  /// **'Yoğun duman içinden geçmeye çalışmayın.'**
  String get safetyGuideInCar1;

  /// No description provided for @safetyGuideInCar2.
  ///
  /// In tr, this message translates to:
  /// **'Mümkünse güvenli açık alana veya yerleşim merkezine yönelin.'**
  String get safetyGuideInCar2;

  /// No description provided for @safetyGuideInCar3.
  ///
  /// In tr, this message translates to:
  /// **'Aracı kuru otların ve ağaç altlarının yanında bırakmayın.'**
  String get safetyGuideInCar3;

  /// No description provided for @safetyGuideInCar4.
  ///
  /// In tr, this message translates to:
  /// **'Resmi yönlendirme varsa navigasyondan değil, duyurudan ilerleyin.'**
  String get safetyGuideInCar4;

  /// No description provided for @safetyGuideOutsideTitle.
  ///
  /// In tr, this message translates to:
  /// **'Dışarıdaysanız ne yapmalısınız?'**
  String get safetyGuideOutsideTitle;

  /// No description provided for @safetyGuideOutside1.
  ///
  /// In tr, this message translates to:
  /// **'Rüzgar yönünü gözlemleyin ve yangının önüne geçmeyin.'**
  String get safetyGuideOutside1;

  /// No description provided for @safetyGuideOutside2.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek bitki örtüsünden ve dar vadilerden uzaklaşın.'**
  String get safetyGuideOutside2;

  /// No description provided for @safetyGuideOutside3.
  ///
  /// In tr, this message translates to:
  /// **'Topluluk halinde hareket ediyorsanız dağılmadan ilerleyin.'**
  String get safetyGuideOutside3;

  /// No description provided for @safetyGuideOutside4.
  ///
  /// In tr, this message translates to:
  /// **'Acil durumda açık, çıplak ve yanıcı olmayan alana çıkın.'**
  String get safetyGuideOutside4;

  /// No description provided for @safetyGuideEvacOrderTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tahliye emri geldiyse ne yapmalısınız?'**
  String get safetyGuideEvacOrderTitle;

  /// No description provided for @safetyGuideEvacOrder1.
  ///
  /// In tr, this message translates to:
  /// **'Emri geciktirmeyin, \"biraz daha bekleyeyim\" demeyin.'**
  String get safetyGuideEvacOrder1;

  /// No description provided for @safetyGuideEvacOrder2.
  ///
  /// In tr, this message translates to:
  /// **'Sadece temel eşyaları alın ve çıkışa odaklanın.'**
  String get safetyGuideEvacOrder2;

  /// No description provided for @safetyGuideEvacOrder3.
  ///
  /// In tr, this message translates to:
  /// **'Yakınlarınızı tek tek arayıp vakit kaybetmeyin, önceden plan kullanın.'**
  String get safetyGuideEvacOrder3;

  /// No description provided for @safetyGuideEvacOrder4.
  ///
  /// In tr, this message translates to:
  /// **'Yetkililerin toplama alanı duyurusunu takip edin.'**
  String get safetyGuideEvacOrder4;

  /// No description provided for @safetyGuideEmergencyNumbers.
  ///
  /// In tr, this message translates to:
  /// **'Acil Numaralar'**
  String get safetyGuideEmergencyNumbers;

  /// No description provided for @safetyGuideEmergencyNumbersSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Hızlı erişim için not düşün'**
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
  /// **'Yerel duyuruları takip edin'**
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
  /// **'Bildirimleri, konum tabanlı uyarıları ve uygulama davranışını buradan özelleştirin.'**
  String get settingsAppSettingsSubtitle;

  /// No description provided for @settingsNotifications.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get settingsNotifications;

  /// No description provided for @settingsNotificationsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Uyarı tercihlerini yönetin'**
  String get settingsNotificationsSubtitle;

  /// No description provided for @settingsPushNotifications.
  ///
  /// In tr, this message translates to:
  /// **'Push Bildirimleri'**
  String get settingsPushNotifications;

  /// No description provided for @settingsPushNotificationsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni olaylar ve önemli değişiklikler için bildirim alın'**
  String get settingsPushNotificationsSubtitle;

  /// No description provided for @settingsNearbyAlerts.
  ///
  /// In tr, this message translates to:
  /// **'Yakındaki Olay Uyarıları'**
  String get settingsNearbyAlerts;

  /// No description provided for @settingsNearbyAlertsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Konumunuza yakın bölgelerde olay varsa öncelikli gösterin'**
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
  /// **'Premium koyu görünümü aktif tutun'**
  String get settingsDarkModeSubtitle;

  /// No description provided for @settingsRefreshInterval.
  ///
  /// In tr, this message translates to:
  /// **'Veri Yenileme Aralığı'**
  String get settingsRefreshInterval;

  /// No description provided for @settingsRefreshIntervalSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Saha verilerinin ne sıklıkla yenileneceğini seçin'**
  String get settingsRefreshIntervalSubtitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama dilini seçin'**
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
  /// **'NASA FIRMS. VIIRS (NOAA-20, NOAA-21; Suomi-NPP 2 Kasım 2026\'da veri vermeyi bıraktı) ve MODIS (Terra, Aqua). Uydular gün içinde birkaç kez geçer. Her tespit bir sıcak pikseldir: konum, ışıma gücü (FRP, megawatt), parlaklık sıcaklığı ve NASA\'nın güvenilirlik derecesi ölçülen değerlerdir. Bir olayın panelinde hangi ürünün kaç tespit verdiğini görebilirsiniz.'**
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
  /// **'Yayılma yönü ve hızı, tespit deseninin merkezindeki kaymadan hesaplanır; yangının gerçek ilerleyişi farklı olabilir. \"Tespit pikseli ~N hektar\" uydunun çözünürlüğüdür, yanan alan değildir: ısı kaynağı o pikselin içindedir, gerçek boyutu bilinmiyor. Bu rakam uydunun bakış açısına göre büyür, yangına göre değil.'**
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
  /// **'Risk skorları hava durumu verisinden bölge genelinde hesaplanır. Tek bir yangına ait ölçüm değildir; o yangının nasıl davranacağını söylemez. Hava verisi Open-Meteo\'dan gelir (CC BY 4.0); Open-Meteo yanıt vermediğinde Norveç Meteoroloji Enstitüsü MET Norway\'in Locationforecast verisi kullanılır (NLOD 2.0 / CC BY 4.0). Sıcaklık, nem ve rüzgar iki kaynakta da aynı anlama gelir.'**
  String get dataSourcesWeatherBody;

  /// No description provided for @dataSourcesWeatherOpenMeteoCredit.
  ///
  /// In tr, this message translates to:
  /// **'Weather data by Open-Meteo.com'**
  String get dataSourcesWeatherOpenMeteoCredit;

  /// No description provided for @dataSourcesWeatherMetCredit.
  ///
  /// In tr, this message translates to:
  /// **'Data from MET Norway'**
  String get dataSourcesWeatherMetCredit;

  /// No description provided for @dataSourcesPlacesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yer verisi — il ve ilçe sınırları'**
  String get dataSourcesPlacesTitle;

  /// No description provided for @dataSourcesPlacesBody.
  ///
  /// In tr, this message translates to:
  /// **'Bölge seçimindeki il ve ilçe listesi, merkezleri ve sınır kutuları uygulamaya gömülüdür; ağdan çekilmez. İdari sınır ve yer verisi © OpenStreetMap katkıcıları, Açık Veri Tabanı Lisansı (ODbL) altındadır; adlar ve il üyeliği resmî il/ilçe listesiyle eşleştirilmiştir. Bu veri harita yakınlaştırma ve bildirim kapsamı içindir; yangın verisi değildir. Adres ve mahalle aramaları OpenStreetMap Nominatim ile yapılır; yazdığınız metin saklanmaz, sonuçlar metnin geri çevrilemez özetiyle en fazla 7 gün önbellekte tutulur.'**
  String get dataSourcesPlacesBody;

  /// No description provided for @dataSourcesFwiTitle.
  ///
  /// In tr, this message translates to:
  /// **'Copernicus yangın tehlike indeksi (FWI) — ayrı bir kaynak'**
  String get dataSourcesFwiTitle;

  /// No description provided for @dataSourcesFwiBody.
  ///
  /// In tr, this message translates to:
  /// **'Haritadaki FWI (Copernicus) katmanı Copernicus EFFIS\'in Yangın Hava Endeksi\'ni (FWI) gösterir. FWI sıcaklık, nem, rüzgar ve yağıştan hesaplanan bir tehlike göstergesidir: hava koşullarının bir yangını ne kadar besleyeceğini söyler, bir yangın olduğunu söylemez. Veri ECMWF\'nin küresel hava modelinden gelir ve bugün dahil 10 güne kadar (9 gün ileriye) tahmin sunar; günün model koşusu yayımlanana dek son gün boş kalabilir. Uydu tespitlerinden tamamen ayrı bir kaynaktır; herhangi bir yangına ait ölçüm değildir. Veri: © European Union, Copernicus EFFIS (CC BY 4.0). FireWatch risk puanından ayrıdır ve puana katılmaz.'**
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
  /// **'Yangın odaklı afet takibi'**
  String get settingsInfoPurposeValue;

  /// No description provided for @settingsFooterNote.
  ///
  /// In tr, this message translates to:
  /// **'Tercihleriniz cihazınızda saklanır ve uygulamayı her açtığınızda otomatik olarak uygulanır.'**
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
  /// **'Güncel Risk Görünümü'**
  String get riskLiveView;

  /// No description provided for @riskSummaryTitle.
  ///
  /// In tr, this message translates to:
  /// **'Türkiye Yangın Risk Özeti'**
  String get riskSummaryTitle;

  /// No description provided for @riskSummarySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Open-Meteo / MET Norway hava verisi ve NASA FIRMS uydu tespitleriyle yaklaşık 3 saatte bir hesaplanır. Her bölgenin havası tek bir temsilî noktadan alınır.'**
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
  /// **'Kuruluk göstergesi'**
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
  /// **'Bitki baskısı'**
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
  /// **'Güçlü rüzgâr ({wind} km/h)'**
  String riskNoteStrongWind(int wind);

  /// No description provided for @riskNoteMediumWind.
  ///
  /// In tr, this message translates to:
  /// **'Orta rüzgâr ({wind} km/h)'**
  String riskNoteMediumWind(int wind);

  /// No description provided for @newsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Haberler'**
  String get newsTitle;

  /// No description provided for @newsLiveFeed.
  ///
  /// In tr, this message translates to:
  /// **'Haber Akışı'**
  String get newsLiveFeed;

  /// No description provided for @newsCenterTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yangın Haber Merkezi'**
  String get newsCenterTitle;

  /// No description provided for @newsCenterSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Yangınla ilgili son gelişmeler.'**
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
  /// **'Akışı filtreleyin'**
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
  /// **'Neler olduğuna göre filtreleyin'**
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
  /// **'Uydu Tespitiyle Eşleşti'**
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
  /// **'GPS ile konumunuzu alın ve yangını bildirin. Bildiriminiz yakındaki NASA uydu tespitleriyle karşılaştırılır.'**
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
  /// **'Adınız bildirimle birlikte kaydedilmez'**
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
  /// **'Uydu Tespitiyle Eşleşti'**
  String get reportPanelSuccessVerifiedTitle;

  /// No description provided for @reportPanelSuccessReceivedTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim Alındı'**
  String get reportPanelSuccessReceivedTitle;

  /// No description provided for @reportPanelSuccessVerifiedBody.
  ///
  /// In tr, this message translates to:
  /// **'Bildirdiğiniz yerin 10 km yakınında son 24 saatte NASA uydu ısı tespiti var. Bu, yangını tek başına doğrulamaz.'**
  String get reportPanelSuccessVerifiedBody;

  /// No description provided for @reportPanelSuccessReceivedBody.
  ///
  /// In tr, this message translates to:
  /// **'Bildiriminiz kaydedildi. Uydular son 24 saatte yakınında tespit yapmadı; bu, yangın olmadığı anlamına gelmez.'**
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
  /// **'Bu bildirim acil durum ekiplerine iletilmez. Yangın görüyorsanız hemen 112\'yi arayın.'**
  String get reportPanelResponseTimeVerified;

  /// No description provided for @reportPanelResponseTimeReceived.
  ///
  /// In tr, this message translates to:
  /// **'Bu bildirim acil durum ekiplerine iletilmez. Yangın görüyorsanız hemen 112\'yi arayın.'**
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
  /// **'Önemli uyarıları kaçırmayın'**
  String get notifPermTitle;

  /// No description provided for @notifPermSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim izniyle yakınınızdaki uydu tespitlerini ve önemli değişiklikleri anında öğrenebilirsiniz.'**
  String get notifPermSubtitle;

  /// No description provided for @notifPermNote.
  ///
  /// In tr, this message translates to:
  /// **'Bu izin zorunlu değil. İsterseniz şimdilik atlayıp uygulamayı yine kullanabilirsiniz.'**
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
  /// **'Bildirim izni verilmedi. Ayarlardan daha sonra açabilirsiniz.'**
  String get notifPermDenied;

  /// No description provided for @locPermServiceOff.
  ///
  /// In tr, this message translates to:
  /// **'Konum servisi kapalı görünüyor. Yine de uygulamaya devam edebilirsiniz.'**
  String get locPermServiceOff;

  /// No description provided for @locPermDenied.
  ///
  /// In tr, this message translates to:
  /// **'Konum izni verilmedi. Şimdilik konumsuz devam edebilirsiniz.'**
  String get locPermDenied;

  /// No description provided for @locPermDeniedForever.
  ///
  /// In tr, this message translates to:
  /// **'Konum izni kalıcı olarak reddedilmiş. Ayarlardan açabilirsiniz.'**
  String get locPermDeniedForever;

  /// No description provided for @locPermError.
  ///
  /// In tr, this message translates to:
  /// **'Konum izni alınırken bir sorun oluştu. Şimdilik geçebilirsiniz.'**
  String get locPermError;

  /// No description provided for @locPermTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yakınınızdaki olayları gösterelim'**
  String get locPermTitle;

  /// No description provided for @locPermSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Konumunuzla yakınınızdaki uydu tespitlerini ve çevrenizdeki riski gösterebiliriz. Mesafeler telefonunuzda hesaplanır.'**
  String get locPermSubtitle;

  /// No description provided for @locPermNote.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler için otomatik taramayı başlatırsanız konumunuz yaklaşık 1 km\'ye yuvarlanarak sunucumuzda saklanır; bildirimleri kapattığınızda ya da Ayarlar → Konum verimi sil ile hemen silinir. Bu izin zorunlu değil, şimdilik atlayabilirsiniz.'**
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

  /// No description provided for @locDisclosureTitle.
  ///
  /// In tr, this message translates to:
  /// **'Konumunuzu nasıl kullanıyoruz?'**
  String get locDisclosureTitle;

  /// No description provided for @locDisclosureOnDevice.
  ///
  /// In tr, this message translates to:
  /// **'Yakınınızdaki uydu tespitlerine olan mesafe telefonunuzda hesaplanır.'**
  String get locDisclosureOnDevice;

  /// No description provided for @locDisclosureNearestCity.
  ///
  /// In tr, this message translates to:
  /// **'Bulunduğunuz ili göstermek için konumunuz, riski hesaplamak için yaklaşık 10 km\'ye yuvarlanmış konumunuz sunucumuza gönderilir; bu sorgular saklanmaz.'**
  String get locDisclosureNearestCity;

  /// No description provided for @locDisclosureStored.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler için otomatik taramayı başlatırsanız, bölgenizle ilgili uyarı gönderebilmek için konumunuz yaklaşık 1 km\'ye yuvarlanarak sunucumuzda saklanır. Tam konumunuz saklanmaz.'**
  String get locDisclosureStored;

  /// No description provided for @locDisclosureDelete.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimleri kapattığınızda ya da Ayarlar → Konum verimi sil\'e dokunduğunuzda hemen silinir. Uygulamayı 90 gün açmazsanız kaydınız tamamen silinir.'**
  String get locDisclosureDelete;

  /// No description provided for @locDisclosureOptional.
  ///
  /// In tr, this message translates to:
  /// **'Konum izni zorunlu değil; uygulamayı konumsuz da kullanabilir, izni istediğiniz zaman telefon ayarlarından kaldırabilirsiniz.'**
  String get locDisclosureOptional;

  /// No description provided for @locDisclosureContinue.
  ///
  /// In tr, this message translates to:
  /// **'Devam et'**
  String get locDisclosureContinue;

  /// No description provided for @locDisclosureNotNow.
  ///
  /// In tr, this message translates to:
  /// **'Şimdi değil'**
  String get locDisclosureNotNow;

  /// No description provided for @trackedPlacesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yerlerim'**
  String get trackedPlacesTitle;

  /// No description provided for @trackedPlacesSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Yakında ısı tespiti olunca ya da yangın riski yükselince bildirim alın'**
  String get trackedPlacesSubtitle;

  /// No description provided for @trackedPlacesEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Henüz yer eklemediniz. Ev, yazlık ya da bağ evi gibi en fazla 5 yer ekleyebilirsiniz.'**
  String get trackedPlacesEmpty;

  /// No description provided for @trackedPlacesAdd.
  ///
  /// In tr, this message translates to:
  /// **'Yer ekle'**
  String get trackedPlacesAdd;

  /// No description provided for @trackedPlacesFull.
  ///
  /// In tr, this message translates to:
  /// **'En fazla 5 yer ekleyebilirsiniz.'**
  String get trackedPlacesFull;

  /// No description provided for @trackedPlacesRadius.
  ///
  /// In tr, this message translates to:
  /// **'{km} km yarıçap'**
  String trackedPlacesRadius(int km);

  /// No description provided for @trackedPlacesLastAlert.
  ///
  /// In tr, this message translates to:
  /// **'Son uyarı: {date}'**
  String trackedPlacesLastAlert(String date);

  /// No description provided for @trackedPlacesNoAlertYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz uyarı yok'**
  String get trackedPlacesNoAlertYet;

  /// No description provided for @trackedPlacesNotifyTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Bu yer için bildirimler'**
  String get trackedPlacesNotifyTooltip;

  /// No description provided for @trackedPlacesDeleteTitle.
  ///
  /// In tr, this message translates to:
  /// **'\"{name}\" silinsin mi?'**
  String trackedPlacesDeleteTitle(String name);

  /// No description provided for @trackedPlacesDeleteBody.
  ///
  /// In tr, this message translates to:
  /// **'Bu yer ve uyarı kayıtları sunucudan silinir.'**
  String get trackedPlacesDeleteBody;

  /// No description provided for @trackedPlacesDelete.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get trackedPlacesDelete;

  /// No description provided for @trackedPlacesUnavailable.
  ///
  /// In tr, this message translates to:
  /// **'Bu özellik yakında açılacak.'**
  String get trackedPlacesUnavailable;

  /// No description provided for @trackedPlacesLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Yerler yüklenemedi. Son kaydedilen liste gösteriliyor.'**
  String get trackedPlacesLoadFailed;

  /// No description provided for @trackedPlacesSourceMap.
  ///
  /// In tr, this message translates to:
  /// **'Haritadan seç'**
  String get trackedPlacesSourceMap;

  /// No description provided for @trackedPlacesSourceMyLocation.
  ///
  /// In tr, this message translates to:
  /// **'Konumumu ekle'**
  String get trackedPlacesSourceMyLocation;

  /// No description provided for @trackedPlacesLocationFailed.
  ///
  /// In tr, this message translates to:
  /// **'Konum alınamadı.'**
  String get trackedPlacesLocationFailed;

  /// No description provided for @trackedPlacesNameLabel.
  ///
  /// In tr, this message translates to:
  /// **'Yer adı'**
  String get trackedPlacesNameLabel;

  /// No description provided for @trackedPlacesNameHint.
  ///
  /// In tr, this message translates to:
  /// **'ör. Ev, Yazlık'**
  String get trackedPlacesNameHint;

  /// No description provided for @trackedPlacesNameRequired.
  ///
  /// In tr, this message translates to:
  /// **'Bir ad girin.'**
  String get trackedPlacesNameRequired;

  /// No description provided for @trackedPlacesRadiusLabel.
  ///
  /// In tr, this message translates to:
  /// **'Yarıçap'**
  String get trackedPlacesRadiusLabel;

  /// No description provided for @trackedPlacesSave.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get trackedPlacesSave;

  /// No description provided for @trackedPlacesSaved.
  ///
  /// In tr, this message translates to:
  /// **'\"{name}\" Yerlerim\'e eklendi.'**
  String trackedPlacesSaved(String name);

  /// No description provided for @trackedPlacesErrorOutside.
  ///
  /// In tr, this message translates to:
  /// **'Bu nokta Türkiye sınırları dışında.'**
  String get trackedPlacesErrorOutside;

  /// No description provided for @trackedPlacesErrorNetwork.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedilemedi. İnternet bağlantınızı kontrol edip tekrar deneyin.'**
  String get trackedPlacesErrorNetwork;

  /// No description provided for @trackedPlacesErrorGeneric.
  ///
  /// In tr, this message translates to:
  /// **'Bir sorun oluştu, tekrar deneyin.'**
  String get trackedPlacesErrorGeneric;

  /// No description provided for @trackedPlacesPickerTitle.
  ///
  /// In tr, this message translates to:
  /// **'Konumu seç'**
  String get trackedPlacesPickerTitle;

  /// No description provided for @trackedPlacesPickerHint.
  ///
  /// In tr, this message translates to:
  /// **'Haritayı kaydırıp işaretçiyi yerin üzerine getirin ya da haritaya uzun basın.'**
  String get trackedPlacesPickerHint;

  /// No description provided for @trackedPlacesPickerConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Bu konumu kullan'**
  String get trackedPlacesPickerConfirm;

  /// No description provided for @trackedPlacesApproxNote.
  ///
  /// In tr, this message translates to:
  /// **'Konum sunucuda yaklaşık 1 km hassasiyetle saklanır. Bildirimler doğrulanmış yangın bildirmez: uydu ısı tespitine ya da risk puanına dayanır.'**
  String get trackedPlacesApproxNote;

  /// No description provided for @trackedPlacesMigrateTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kayıtlı yerlerinizi Yerlerim\'e taşımak ister misiniz?'**
  String get trackedPlacesMigrateTitle;

  /// No description provided for @trackedPlacesMigrateBody.
  ///
  /// In tr, this message translates to:
  /// **'{count} kayıtlı yeriniz var. Taşırsanız 10 km içindeki yeni uydu ısı tespitlerinde bildirim alırsınız.'**
  String trackedPlacesMigrateBody(int count);

  /// No description provided for @trackedPlacesMigrateAccept.
  ///
  /// In tr, this message translates to:
  /// **'Taşı'**
  String get trackedPlacesMigrateAccept;

  /// No description provided for @trackedPlacesMigrateDone.
  ///
  /// In tr, this message translates to:
  /// **'{count} yer eklendi.'**
  String trackedPlacesMigrateDone(int count);

  /// No description provided for @locDisclosureTracked.
  ///
  /// In tr, this message translates to:
  /// **'Yerlerim\'e eklediğiniz yerlerin adı, yaklaşık 1 km\'ye yuvarlanmış konumu ve yarıçapı sunucumuzda saklanır. Bir yeri listeden, hepsini Ayarlar → Konum verimi sil ile silebilirsiniz.'**
  String get locDisclosureTracked;

  /// No description provided for @notifPlacesChannelName.
  ///
  /// In tr, this message translates to:
  /// **'Takip ettiğim yerler'**
  String get notifPlacesChannelName;

  /// No description provided for @notifPlacesChannelDescription.
  ///
  /// In tr, this message translates to:
  /// **'Yerlerim\'deki yerlerin yakınındaki uydu ısı tespitleri ve yangın riski'**
  String get notifPlacesChannelDescription;

  /// No description provided for @settingsDeleteLocation.
  ///
  /// In tr, this message translates to:
  /// **'Konum verimi sil'**
  String get settingsDeleteLocation;

  /// No description provided for @settingsDeleteLocationConfirmTitle.
  ///
  /// In tr, this message translates to:
  /// **'Konum veriniz silinsin mi?'**
  String get settingsDeleteLocationConfirmTitle;

  /// No description provided for @settingsDeleteLocationConfirmBody.
  ///
  /// In tr, this message translates to:
  /// **'Sunucuda saklanan yaklaşık konumunuz ve takip ettiğiniz tüm yerler hemen silinir. Bildirimleriniz açık kalır; il veya bölge seçmediyseniz bundan sonra tüm bölgelerin risk uyarılarını alabilirsiniz. Otomatik taramayı yeniden başlatırsanız konumunuz tekrar kaydedilir.'**
  String get settingsDeleteLocationConfirmBody;

  /// No description provided for @settingsDeleteLocationConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get settingsDeleteLocationConfirm;

  /// No description provided for @settingsDeleteLocationDone.
  ///
  /// In tr, this message translates to:
  /// **'Konum veriniz ve takip ettiğiniz yerler sunucudan silindi.'**
  String get settingsDeleteLocationDone;

  /// No description provided for @settingsDeleteLocationFailed.
  ///
  /// In tr, this message translates to:
  /// **'Konum veriniz silinemedi. İnternet bağlantınızı kontrol edip tekrar deneyin.'**
  String get settingsDeleteLocationFailed;

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
  /// **'Uydular {temp}K ısı tespit etti. Doğrulanmadı. Bölgeye yaklaşmayın.'**
  String riskReasonHighWithTemp(String temp);

  /// No description provided for @riskReasonHighNoTemp.
  ///
  /// In tr, this message translates to:
  /// **'Uydular güçlü bir tespit yaptı. Doğrulanmadı.'**
  String get riskReasonHighNoTemp;

  /// No description provided for @riskReasonMediumWithTemp.
  ///
  /// In tr, this message translates to:
  /// **'Uydular {temp}K ısı tespit etti. Nedeni doğrulanmadı.'**
  String riskReasonMediumWithTemp(String temp);

  /// No description provided for @riskReasonMediumNoTemp.
  ///
  /// In tr, this message translates to:
  /// **'Uydular orta düzeyde bir tespit yaptı. Doğrulanmadı.'**
  String get riskReasonMediumNoTemp;

  /// No description provided for @riskReasonLowWithTemp.
  ///
  /// In tr, this message translates to:
  /// **'Uydular düşük bir ısı tespit etti ({temp}K). Nedeni doğrulanmadı.'**
  String riskReasonLowWithTemp(String temp);

  /// No description provided for @riskReasonLowNoTemp.
  ///
  /// In tr, this message translates to:
  /// **'Uydular zayıf bir tespit yaptı. Takip önerilir.'**
  String get riskReasonLowNoTemp;

  /// No description provided for @fireGeneratedDescHigh.
  ///
  /// In tr, this message translates to:
  /// **'Uydular güçlü bir ısı tespit etti. Doğrulanmadı.'**
  String get fireGeneratedDescHigh;

  /// No description provided for @fireGeneratedDescMedium.
  ///
  /// In tr, this message translates to:
  /// **'Orta seviye ısı artışı. Bölge izleme gerektirir.'**
  String get fireGeneratedDescMedium;

  /// No description provided for @fireGeneratedDescLow.
  ///
  /// In tr, this message translates to:
  /// **'Uydular zayıf bir tespit yaptı. Takip önerilir.'**
  String get fireGeneratedDescLow;

  /// No description provided for @fireRecommendedActionHigh.
  ///
  /// In tr, this message translates to:
  /// **'Bölgeden uzak durun, resmi yönlendirmeleri takip edin ve tahliye hazırlığını yapın.'**
  String get fireRecommendedActionHigh;

  /// No description provided for @fireRecommendedActionMedium.
  ///
  /// In tr, this message translates to:
  /// **'Gelişmeleri takip edin, bölgeye gereksiz yaklaşmayın.'**
  String get fireRecommendedActionMedium;

  /// No description provided for @fireRecommendedActionLow.
  ///
  /// In tr, this message translates to:
  /// **'Şu an acil aksiyon gerekmiyor, bölgeyi takip edin.'**
  String get fireRecommendedActionLow;

  /// No description provided for @fireStatusActive.
  ///
  /// In tr, this message translates to:
  /// **'Çok Güçlü Tespit'**
  String get fireStatusActive;

  /// No description provided for @fireStatusLikelyActive.
  ///
  /// In tr, this message translates to:
  /// **'Güçlü Tespit'**
  String get fireStatusLikelyActive;

  /// No description provided for @fireStatusMonitoring.
  ///
  /// In tr, this message translates to:
  /// **'İzleniyor'**
  String get fireStatusMonitoring;

  /// No description provided for @fireStatusHistorical.
  ///
  /// In tr, this message translates to:
  /// **'Artık görülmüyor'**
  String get fireStatusHistorical;

  /// No description provided for @fireEventRegionTitle.
  ///
  /// In tr, this message translates to:
  /// **'{city} Bölgesi Uydu Tespiti'**
  String fireEventRegionTitle(String city);

  /// No description provided for @fireEventLiveDetectionTitle.
  ///
  /// In tr, this message translates to:
  /// **'Güncel Uydu Tespiti'**
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
  /// **'Orta — dikkatli takip edin'**
  String get fireEventSpreadMedium;

  /// No description provided for @fireEventSpreadLow.
  ///
  /// In tr, this message translates to:
  /// **'Düşük'**
  String get fireEventSpreadLow;

  /// No description provided for @fireDetailAreaMeasured.
  ///
  /// In tr, this message translates to:
  /// **'Uydunun gördüğü alan ~{hectares} hektar (yangının kendisi değil)'**
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
  /// **'Türkçeden çevrildi • Tam çeviri için dokunun'**
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
  /// **'Harita ve Uydu Tespitleri'**
  String get coachMarkMapTitle;

  /// No description provided for @coachMarkMapDesc.
  ///
  /// In tr, this message translates to:
  /// **'Haritadaki işaretler NASA uydularının tespit ettiği ısı noktalarıdır; doğrulanmadı. Bir işarete dokunarak ayrıntıları görebilir, buradan yeni bir yangın da bildirebilirsiniz.'**
  String get coachMarkMapDesc;

  /// No description provided for @coachMarkRiskTitle.
  ///
  /// In tr, this message translates to:
  /// **'Risk Seviyeleri'**
  String get coachMarkRiskTitle;

  /// No description provided for @coachMarkRiskDesc.
  ///
  /// In tr, this message translates to:
  /// **'Her uydu tespiti Yüksek, Orta veya Düşük risk seviyesiyle etiketlenir. Bu etiketler bölgedeki tehlike derecesini hızlıca anlamanızı sağlar.'**
  String get coachMarkRiskDesc;

  /// No description provided for @coachMarkWatchlistTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedilenler'**
  String get coachMarkWatchlistTitle;

  /// No description provided for @coachMarkWatchlistDesc.
  ///
  /// In tr, this message translates to:
  /// **'Takip etmek istediğiniz uydu tespitlerini kaydedin ve buradan hızlıca tekrar ulaşın.'**
  String get coachMarkWatchlistDesc;

  /// No description provided for @coachMarkNotificationsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get coachMarkNotificationsTitle;

  /// No description provided for @coachMarkNotificationsDesc.
  ///
  /// In tr, this message translates to:
  /// **'Yakınınızdaki uydu ısı tespitleri için bildirim alın ve otomatik taramayı buradan başlatın.'**
  String get coachMarkNotificationsDesc;

  /// No description provided for @riskTabTurkeyOverview.
  ///
  /// In tr, this message translates to:
  /// **'Türkiye geneli'**
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
  /// **'Konum izni verilmedi. Bölge risk bilgisini görmek için izin verin.'**
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
  /// **'Bölgeniz: {city} ({region})'**
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
  /// **'Detaylar için bir bölgeye dokunun'**
  String get riskChartTapHint;

  /// No description provided for @monitorStatusReady.
  ///
  /// In tr, this message translates to:
  /// **'Otomatik takip hazır.'**
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
  /// **'Uydular şu an tespit bildirmedi.'**
  String get monitorStatusNoActiveFires;

  /// No description provided for @monitorStatusNoNearbyFires.
  ///
  /// In tr, this message translates to:
  /// **'Uydular 50 km içinde tespit etmedi. ({count} nokta tarandı)'**
  String monitorStatusNoNearbyFires(int count);

  /// No description provided for @monitorStatusNearbyFiresFound.
  ///
  /// In tr, this message translates to:
  /// **'Uydular 50 km içinde {count} tespit yaptı.'**
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
  /// **'Uydular yakınınızda tespit yaptı'**
  String get notifNearbyFireTitle;

  /// No description provided for @notifNearbyFireBody.
  ///
  /// In tr, this message translates to:
  /// **'{distance} içinde {count} uydu tespiti var. Doğrulanmadı.'**
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
  /// **'{distance} km uzaklıkta'**
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
  /// **'Son 24 saatteki uydu ısı olayı sayısı (en fazla 20 puan)'**
  String get riskInfoFormulaFireCount;

  /// No description provided for @riskInfoSourcesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Veri Kaynakları'**
  String get riskInfoSourcesTitle;

  /// No description provided for @riskInfoSourcesBody.
  ///
  /// In tr, this message translates to:
  /// **'NASA FIRMS uydu verisi ve Open-Meteo (yedek: MET Norway) hava durumu verisi kullanılarak hesaplanır. Hava verisi her bölge için tek bir temsilî noktadan alınır; haberler puana katılmaz.'**
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
  /// **'Veriler NASA FIRMS uydu tespitlerinden alınır; sunucu yaklaşık 30 dakikada bir yeni veri çeker.'**
  String get trustHomeInfo;

  /// No description provided for @trustMapInfo.
  ///
  /// In tr, this message translates to:
  /// **'Haritadaki işaretler uyduların yaptığı tespitleri gösterir.'**
  String get trustMapInfo;

  /// No description provided for @trustRiskInfo.
  ///
  /// In tr, this message translates to:
  /// **'Risk skorları yaklaşık 3 saatte bir hava durumu ve NASA uydu tespitlerinden hesaplanır.'**
  String get trustRiskInfo;

  /// No description provided for @trustNewsInfo.
  ///
  /// In tr, this message translates to:
  /// **'Haberler 9 Türk kaynağından yangınla ilgili içerik için filtrelenir.'**
  String get trustNewsInfo;

  /// No description provided for @trustAlertsInfo.
  ///
  /// In tr, this message translates to:
  /// **'Konumunuza 50 km içinde uydu ısı tespiti olduğunda bildirim gönderilir.'**
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
  /// **'Bu ekrandaki sayılar uyduların son 24 saatte yaptığı tespitlerdir; doğrulanmadı. Bazıları tarımsal yakma, sanayi ısısı veya sıcak yüzey olabilir.'**
  String get trustHomeMeaning;

  /// No description provided for @trustHomeSource.
  ///
  /// In tr, this message translates to:
  /// **'Veriler NASA FIRMS\'ten (Yangın Bilgi ve Kaynak Yönetim Sistemi) gelir; birkaç uydunun geçişlerini birleştirir. Sunucu yaklaşık 30 dakikada bir yeni veri çeker; uydu geçişleri ve NASA\'nın işleme süresi nedeniyle bir tespit birkaç saat gecikebilir.'**
  String get trustHomeSource;

  /// No description provided for @trustHomeInterpret.
  ///
  /// In tr, this message translates to:
  /// **'Yalnızca uydunun çok emin olduğu ve çok yüksek ısı ölçtüğü tespitler Çok Güçlü Tespit olarak etiketlenir.'**
  String get trustHomeInterpret;

  /// No description provided for @trustHomeAction.
  ///
  /// In tr, this message translates to:
  /// **'Ayrıntılar için tespite dokunun. Duman veya alev görürseniz önce 112\'yi arayın.'**
  String get trustHomeAction;

  /// No description provided for @trustMapMeaning.
  ///
  /// In tr, this message translates to:
  /// **'Her işaret bir uydu tespitidir; doğrulanmadı. Kırmızı çok güçlü, turuncu güçlü, sarı orta, gri zayıf tespittir.'**
  String get trustMapMeaning;

  /// No description provided for @trustMapSource.
  ///
  /// In tr, this message translates to:
  /// **'Uydu verileri NASA FIRMS\'ten alınır.'**
  String get trustMapSource;

  /// No description provided for @trustMapInterpret.
  ///
  /// In tr, this message translates to:
  /// **'Kümeler yalnızca birbirine yakın birden fazla ısı tespiti olduğunu gösterir; yangının nedenini veya büyüklüğünü doğrulamaz.'**
  String get trustMapInterpret;

  /// No description provided for @trustMapAction.
  ///
  /// In tr, this message translates to:
  /// **'Ayrıntılar için işarete dokunun. Yangını kendiniz görürseniz önce 112\'yi arayın, sonra Raporla\'yı kullanın.'**
  String get trustMapAction;

  /// No description provided for @trustRiskMeaning.
  ///
  /// In tr, this message translates to:
  /// **'Risk puanı (0-100) sıcaklık, nem, rüzgâr ve bölgedeki son uydu tespitlerini birleştiren bir endekstir; yangın çıkıp çıkmayacağını söylemez, garanti vermez.'**
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
  /// **'Uyarılar, uydular 50 km içinde tespit yaptığında gönderilir. Bunlar otomatik tespitlerdir; doğrulanmadı.'**
  String get trustAlertsMeaning;

  /// No description provided for @trustAlertsSource.
  ///
  /// In tr, this message translates to:
  /// **'Arka plan izleme, NASA FIRMS verilerini belirli aralıklarla kontrol eder ve yeni tespitleri cihazınızın son bilinen konumuyla telefonunuzda karşılaştırır. Sunucudan gelen bölgesel uyarılar için, otomatik taramayı başlattığınızda konumunuz yaklaşık 1 km\'ye yuvarlanarak saklanır.'**
  String get trustAlertsSource;

  /// No description provided for @trustAlertsInterpret.
  ///
  /// In tr, this message translates to:
  /// **'Güven düzeyi, uydunun tespitten ne kadar emin olduğunu anlatır; yangın olduğunu doğrulamaz.'**
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
  /// **'{location} yakınında uydular çok güçlü bir tespit yaptı.'**
  String smartIntensityIntense(String location);

  /// No description provided for @smartIntensityHigh.
  ///
  /// In tr, this message translates to:
  /// **'{location} yakınında uydular güçlü bir tespit yaptı.'**
  String smartIntensityHigh(String location);

  /// No description provided for @smartIntensityModerate.
  ///
  /// In tr, this message translates to:
  /// **'{location} yakınında uydular orta düzeyde bir tespit yaptı.'**
  String smartIntensityModerate(String location);

  /// No description provided for @smartIntensityEarly.
  ///
  /// In tr, this message translates to:
  /// **'{location} yakınında uydular zayıf bir tespit yaptı; nedeni doğrulanmadı.'**
  String smartIntensityEarly(String location);

  /// No description provided for @smartIntensityAnomaly.
  ///
  /// In tr, this message translates to:
  /// **'{location} yakınında uydular bir tespit yaptı.'**
  String smartIntensityAnomaly(String location);

  /// No description provided for @smartLocationHintForest.
  ///
  /// In tr, this message translates to:
  /// **'ormanlık alanı geniş bir ilde'**
  String get smartLocationHintForest;

  /// No description provided for @smartLocationHintCoastal.
  ///
  /// In tr, this message translates to:
  /// **'güneybatı kıyı kuşağında'**
  String get smartLocationHintCoastal;

  /// No description provided for @smartLocationHintUrban.
  ///
  /// In tr, this message translates to:
  /// **'kentleşmesi yoğun bir ilde; bina veya sanayi kaynaklı olabilir'**
  String get smartLocationHintUrban;

  /// No description provided for @smartLocationHintAgricultural.
  ///
  /// In tr, this message translates to:
  /// **'tarımın yoğun olduğu bir ilde; uydular anız yakımını da tespit eder'**
  String get smartLocationHintAgricultural;

  /// No description provided for @smartFrpHigh.
  ///
  /// In tr, this message translates to:
  /// **'Uydu bu noktada yüksek ısı ölçtü.'**
  String get smartFrpHigh;

  /// No description provided for @smartPixelFootprint.
  ///
  /// In tr, this message translates to:
  /// **'Uydu bu noktayı ~{hectares} hektarlık bir alan olarak görür; ısının kaynağı bu alanın içindedir, gerçek boyutu bilinmiyor.'**
  String smartPixelFootprint(int hectares);

  /// No description provided for @smartAreaLarge.
  ///
  /// In tr, this message translates to:
  /// **'Uydunun tespit ettiği alan geniş (~{hectares} hektar).'**
  String smartAreaLarge(int hectares);

  /// No description provided for @smartAreaMedium.
  ///
  /// In tr, this message translates to:
  /// **'Uydunun tespit ettiği alan orta büyüklükte (~{hectares} hektar).'**
  String smartAreaMedium(int hectares);

  /// No description provided for @smartConfidenceHigh.
  ///
  /// In tr, this message translates to:
  /// **'NASA bu tespitten yüksek düzeyde emin; nedeni doğrulanmadı.'**
  String get smartConfidenceHigh;

  /// No description provided for @smartConfidenceMedium.
  ///
  /// In tr, this message translates to:
  /// **'NASA bu tespiti orta güvenle bildiriyor; doğrulanmadı.'**
  String get smartConfidenceMedium;

  /// No description provided for @smartConfidenceLow.
  ///
  /// In tr, this message translates to:
  /// **'Zayıf bir tespit; sanayi ısısı veya yansıma olabilir, doğrulanmadı.'**
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
  /// **'{hours} saat önce {satellite} tespit etti; güncel durumu doğrulanmadı.'**
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
  /// **'VIIRS: NOAA-20 ve NOAA-21 uyduları, Türkiye üzerinden günde birkaç kez geçer. (Suomi NPP 2 Kasım 2026\'da veri vermeyi bıraktı.)'**
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
  /// **'Uydu Tespit İşaretleri'**
  String get coachMarkMapMarkersTitle;

  /// No description provided for @coachMarkMapMarkersDesc.
  ///
  /// In tr, this message translates to:
  /// **'Haritadaki işaretler NASA uydularından gelen ısı tespitleridir; doğrulanmadı. Bir işarete dokunarak ayrıntıları görebilirsiniz.'**
  String get coachMarkMapMarkersDesc;

  /// No description provided for @coachMarkMapClustersTitle.
  ///
  /// In tr, this message translates to:
  /// **'Küme Sayıları'**
  String get coachMarkMapClustersTitle;

  /// No description provided for @coachMarkMapClustersDesc.
  ///
  /// In tr, this message translates to:
  /// **'Birbirine yakın uydu tespitleri bir araya toplanır ve üzerinde sayı gösteren bir daire olarak görünür. Yakınlaştırdıkça kümeler ayrışır.'**
  String get coachMarkMapClustersDesc;

  /// No description provided for @coachMarkMapReportTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yangın Bildir'**
  String get coachMarkMapReportTitle;

  /// No description provided for @coachMarkMapReportDesc.
  ///
  /// In tr, this message translates to:
  /// **'Sağ alttaki butona dokunarak gördüğünüz bir yangını GPS konumunuzla birlikte bildirebilirsiniz.'**
  String get coachMarkMapReportDesc;

  /// No description provided for @coachMarkMapNearbyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yakınımdaki Uydu Tespitleri'**
  String get coachMarkMapNearbyTitle;

  /// No description provided for @coachMarkMapNearbyDesc.
  ///
  /// In tr, this message translates to:
  /// **'Bu bölüm, konumunuza en yakın uydu ısı tespitlerini mesafe sırasına göre listeler.'**
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
  /// **'Haberleri Risk, Operasyon, Güvenlik veya Güncelleme kategorisine göre filtreleyebilirsiniz.'**
  String get coachMarkNewsCategoryDesc;

  /// No description provided for @coachMarkNewsRegionTitle.
  ///
  /// In tr, this message translates to:
  /// **'Durum Filtreleri'**
  String get coachMarkNewsRegionTitle;

  /// No description provided for @coachMarkNewsRegionDesc.
  ///
  /// In tr, this message translates to:
  /// **'Önem derecesine göre filtreleyin — kritik, aktif, izleniyor, bilgi — ya da sadece kendi bölgenizi görün.'**
  String get coachMarkNewsRegionDesc;

  /// No description provided for @coachMarkNewsListTitle.
  ///
  /// In tr, this message translates to:
  /// **'Habere Dokun'**
  String get coachMarkNewsListTitle;

  /// No description provided for @coachMarkNewsListDesc.
  ///
  /// In tr, this message translates to:
  /// **'Bir habere dokunarak tam metnini okuyun; İngilizce moddaysanız başlık ve özeti tek dokunuşla çevirebilirsiniz.'**
  String get coachMarkNewsListDesc;

  /// No description provided for @coachMarkNotifPermissionTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim İzni'**
  String get coachMarkNotifPermissionTitle;

  /// No description provided for @coachMarkNotifPermissionDesc.
  ///
  /// In tr, this message translates to:
  /// **'Yakınınızdaki uydu ısı tespitleri için bildirim alabilmek üzere izin verin.'**
  String get coachMarkNotifPermissionDesc;

  /// No description provided for @coachMarkNotifScanTitle.
  ///
  /// In tr, this message translates to:
  /// **'Şimdi Tara'**
  String get coachMarkNotifScanTitle;

  /// No description provided for @coachMarkNotifScanDesc.
  ///
  /// In tr, this message translates to:
  /// **'Konumunuzun 50 km çevresinde uydu ısı tespiti olup olmadığını kontrol edin.'**
  String get coachMarkNotifScanDesc;

  /// No description provided for @coachMarkNotifMonitoringTitle.
  ///
  /// In tr, this message translates to:
  /// **'Otomatik Tarama'**
  String get coachMarkNotifMonitoringTitle;

  /// No description provided for @coachMarkNotifMonitoringDesc.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama açıkken yakındaki uydu tespitlerini düzenli kontrol etmek için otomatik izlemeyi başlatın.'**
  String get coachMarkNotifMonitoringDesc;

  /// No description provided for @coachMarkNotifAlertsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Uyarı Kartları'**
  String get coachMarkNotifAlertsTitle;

  /// No description provided for @coachMarkNotifAlertsDesc.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek riskli tespitler burada listelenir; bir karta dokunarak tam detaya ulaşabilirsiniz.'**
  String get coachMarkNotifAlertsDesc;

  /// No description provided for @coachMarkRiskScoreTitle.
  ///
  /// In tr, this message translates to:
  /// **'Risk Skoru'**
  String get coachMarkRiskScoreTitle;

  /// No description provided for @coachMarkRiskScoreDesc.
  ///
  /// In tr, this message translates to:
  /// **'0-100 arası bu skor, sıcaklık, nem, rüzgar ve NASA uydu tespitlerinden hesaplanır. Nasıl hesaplandığını bilgi butonundan öğrenebilirsiniz.'**
  String get coachMarkRiskScoreDesc;

  /// No description provided for @coachMarkRiskChartTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bölgesel Dağılım'**
  String get coachMarkRiskChartTitle;

  /// No description provided for @coachMarkRiskChartDesc.
  ///
  /// In tr, this message translates to:
  /// **'Bir bölge çubuğuna dokunarak o bölgenin detaylı risk analizini görebilirsiniz.'**
  String get coachMarkRiskChartDesc;

  /// No description provided for @coachMarkRiskMyLocationTabTitle.
  ///
  /// In tr, this message translates to:
  /// **'Konumum'**
  String get coachMarkRiskMyLocationTabTitle;

  /// No description provided for @coachMarkRiskMyLocationTabDesc.
  ///
  /// In tr, this message translates to:
  /// **'Bu sekmeye geçerek kendi bölgenizin riskini Türkiye ortalamasıyla karşılaştırın.'**
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
  /// **'Takip etmek istediğiniz uydu tespitlerini burada bir arada tutabilirsiniz.'**
  String get coachMarkWatchlistPurposeDesc;

  /// No description provided for @coachMarkWatchlistHowToAddTitle.
  ///
  /// In tr, this message translates to:
  /// **'Nasıl Eklenir?'**
  String get coachMarkWatchlistHowToAddTitle;

  /// No description provided for @coachMarkWatchlistHowToAddDesc.
  ///
  /// In tr, this message translates to:
  /// **'Bir tespitin detay ekranındaki yer imi butonuna dokunarak onu buraya kaydedebilirsiniz.'**
  String get coachMarkWatchlistHowToAddDesc;

  /// No description provided for @coachMarkWatchlistClearTitle.
  ///
  /// In tr, this message translates to:
  /// **'Temizle'**
  String get coachMarkWatchlistClearTitle;

  /// No description provided for @coachMarkWatchlistClearDesc.
  ///
  /// In tr, this message translates to:
  /// **'Üst köşedeki Temizle butonuyla tüm kayıtlı noktaları tek seferde kaldırabilirsiniz.'**
  String get coachMarkWatchlistClearDesc;

  /// No description provided for @detectionProbableFire.
  ///
  /// In tr, this message translates to:
  /// **'Çok Güçlü Tespit'**
  String get detectionProbableFire;

  /// No description provided for @detectionHighThermalAnomaly.
  ///
  /// In tr, this message translates to:
  /// **'Güçlü Tespit'**
  String get detectionHighThermalAnomaly;

  /// No description provided for @detectionThermalDetection.
  ///
  /// In tr, this message translates to:
  /// **'Uydu Tespiti'**
  String get detectionThermalDetection;

  /// No description provided for @detectionLowConfidence.
  ///
  /// In tr, this message translates to:
  /// **'Düşük Güvenilirlik'**
  String get detectionLowConfidence;

  /// No description provided for @thermalAnomalyDisclaimer.
  ///
  /// In tr, this message translates to:
  /// **'NASA uyduları ısı tespit eder. Tespitler doğrulanmadı; sanayi gibi yangın dışı kaynaklar da tespit edilebilir.'**
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
  /// **'Çok güçlü tespit'**
  String get legendProbableFire;

  /// No description provided for @legendHighThermal.
  ///
  /// In tr, this message translates to:
  /// **'Güçlü tespit'**
  String get legendHighThermal;

  /// No description provided for @legendLowConfidence.
  ///
  /// In tr, this message translates to:
  /// **'Düşük Güvenilirlik'**
  String get legendLowConfidence;

  /// No description provided for @mapMarkerDisclaimerBefore.
  ///
  /// In tr, this message translates to:
  /// **'Harita NASA uydularının yaptığı tespitleri gösterir.'**
  String get mapMarkerDisclaimerBefore;

  /// No description provided for @mapMarkerDisclaimerAfter.
  ///
  /// In tr, this message translates to:
  /// **'işaretler en güçlü tespitlerdir; doğrulanmadı.'**
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
  /// **'Neyin yanlış gittiğini anlatın — doğrudan ekibe iletilir.'**
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
  /// **'Kaydedilen bir tespite dokunarak güncel durumunu ve tam detaylarını görebilirsiniz.'**
  String get coachMarkWatchlistTapDesc;

  /// No description provided for @notificationScopeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim Kapsamı'**
  String get notificationScopeTitle;

  /// No description provided for @notificationScopeSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Hangi yangınlar için uyarı almak istediğinizi seçin.'**
  String get notificationScopeSubtitle;

  /// No description provided for @notificationScopeAll.
  ///
  /// In tr, this message translates to:
  /// **'Tüm Türkiye'**
  String get notificationScopeAll;

  /// No description provided for @notificationScopeAllDesc.
  ///
  /// In tr, this message translates to:
  /// **'Ülke genelindeki tüm yangın uyarılarını alın.'**
  String get notificationScopeAllDesc;

  /// No description provided for @notificationScopeRegion.
  ///
  /// In tr, this message translates to:
  /// **'Sadece bölgem'**
  String get notificationScopeRegion;

  /// No description provided for @notificationScopeRegionDesc.
  ///
  /// In tr, this message translates to:
  /// **'Yalnızca seçtiğiniz coğrafi bölgedeki yangınlar.'**
  String get notificationScopeRegionDesc;

  /// No description provided for @notificationScopeCity.
  ///
  /// In tr, this message translates to:
  /// **'Sadece ilim'**
  String get notificationScopeCity;

  /// No description provided for @notificationScopeCityDesc.
  ///
  /// In tr, this message translates to:
  /// **'Yalnızca seçtiğiniz ildeki yangınlar.'**
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
  /// **'Konumunuzdan algılandı: {name}'**
  String notificationScopeDetected(String name);

  /// No description provided for @notificationScopeDetecting.
  ///
  /// In tr, this message translates to:
  /// **'Konumunuz belirleniyor...'**
  String get notificationScopeDetecting;

  /// No description provided for @notificationScopeSaved.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim kapsamı güncellendi.'**
  String get notificationScopeSaved;

  /// No description provided for @notificationScopeSaveFailed.
  ///
  /// In tr, this message translates to:
  /// **'Kapsam kaydedilemedi. İnternet bağlantınızı kontrol edin.'**
  String get notificationScopeSaveFailed;

  /// No description provided for @notificationScopeCitiesUnavailable.
  ///
  /// In tr, this message translates to:
  /// **'İl listesi yüklenemedi.'**
  String get notificationScopeCitiesUnavailable;

  /// No description provided for @notificationScopeNarrowWarning.
  ///
  /// In tr, this message translates to:
  /// **'Kapsamı daraltmak, seçtiğiniz alan dışındaki yangınlar için uyarı almayacağınız anlamına gelir.'**
  String get notificationScopeNarrowWarning;

  /// No description provided for @incidentsSectionTitle.
  ///
  /// In tr, this message translates to:
  /// **'Uydu Olayları'**
  String get incidentsSectionTitle;

  /// No description provided for @incidentsSectionSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Uydu tespitleri olaylara gruplanmış'**
  String get incidentsSectionSubtitle;

  /// No description provided for @incidentStatusActive.
  ///
  /// In tr, this message translates to:
  /// **'Güncel tespit'**
  String get incidentStatusActive;

  /// No description provided for @incidentStatusAwaiting.
  ///
  /// In tr, this message translates to:
  /// **'Artık görülmüyor'**
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
  /// **'Isı tespit edildi, {hours} saattir görülmüyor'**
  String incidentNoDetectionFor(String hours);

  /// No description provided for @incidentNoDetectionLowConfidence.
  ///
  /// In tr, this message translates to:
  /// **'Isı tespit edildi, {hours} saattir görülmüyor (düşük güvenilirlik)'**
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
  /// **'Zayıf'**
  String get incidentHeatLow;

  /// No description provided for @incidentHeatModerate.
  ///
  /// In tr, this message translates to:
  /// **'Orta'**
  String get incidentHeatModerate;

  /// No description provided for @incidentHeatHigh.
  ///
  /// In tr, this message translates to:
  /// **'Güçlü'**
  String get incidentHeatHigh;

  /// No description provided for @incidentHeatVeryHigh.
  ///
  /// In tr, this message translates to:
  /// **'Çok güçlü'**
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
  /// **'Uydu olayları'**
  String get incidentToggleShow;

  /// No description provided for @incidentToggleDetections.
  ///
  /// In tr, this message translates to:
  /// **'Doğrulanmamış uydu tespitleri'**
  String get incidentToggleDetections;

  /// No description provided for @incidentLayerCaptionDetections.
  ///
  /// In tr, this message translates to:
  /// **'Uyduların tek tek yaptığı tespitler; doğrulanmadı.'**
  String get incidentLayerCaptionDetections;

  /// No description provided for @incidentLayerCaptionEvents.
  ///
  /// In tr, this message translates to:
  /// **'Uyduların aynı noktada yaptığı tespitler tek bir olayda birleştirildi.'**
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
  /// **'FWI (Copernicus)'**
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
  /// **'Harita bu yerlere yakınlaşır; isterseniz bildirim kapsamınız da bu yerlere daralır.'**
  String get placesSubtitle;

  /// No description provided for @placesEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Henüz kayıtlı yer yok. İl veya ilçe arayın, ya da haritaya iğne bırakın.'**
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
  /// **'Kaydetmek istediğiniz noktaya dokunun'**
  String get placesDropPinHint;

  /// No description provided for @placesPinNameTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yere bir ad verin'**
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
  /// **'FWI sınıfı, ECMWF\'nin küresel hava modelinden gelen bölgesel bir tahmindir; il ve ilçe ölçeğinde anlamlıdır, mahalle ölçeğinde ayrışmaz. Yakın iki yerin aynı sınıfı göstermesi verinin çözünürlüğüdür, hata değil.'**
  String get placesResolutionNote;

  /// No description provided for @notificationScopePlaces.
  ///
  /// In tr, this message translates to:
  /// **'Kayıtlı yerlerim'**
  String get notificationScopePlaces;

  /// No description provided for @notificationScopePlacesDesc.
  ///
  /// In tr, this message translates to:
  /// **'Yalnızca harita ekranında kaydettiğiniz il, ilçe ve noktaların çevresindeki yangınlar.'**
  String get notificationScopePlacesDesc;

  /// No description provided for @notificationScopePlacesEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Henüz kayıtlı yer yok. Harita ekranındaki Yerlerim panelinden ekleyebilirsiniz.'**
  String get notificationScopePlacesEmpty;

  /// No description provided for @notificationScopePlacesNote.
  ///
  /// In tr, this message translates to:
  /// **'{count} kayıtlı yer izleniyor. Bu kapsam şimdilik bu cihazın kendi taramalarıyla uygulanır; sunucu bildirimleri son seçtiğiniz il/bölge kapsamını kullanmaya devam eder.'**
  String notificationScopePlacesNote(int count);

  /// No description provided for @notifPlacesFireTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kayıtlı yerinizin yakınında uydu tespiti'**
  String get notifPlacesFireTitle;

  /// No description provided for @notifPlacesFireBody.
  ///
  /// In tr, this message translates to:
  /// **'Kayıtlı yerlerinizin çevresinde {count} uydu tespiti var. Harita ekranından kontrol edin.'**
  String notifPlacesFireBody(int count);

  /// No description provided for @riskLegendTitle.
  ///
  /// In tr, this message translates to:
  /// **'Copernicus yangın tehlike indeksi (FWI)'**
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

  /// No description provided for @riskDayNotPublished.
  ///
  /// In tr, this message translates to:
  /// **'Bu günün tahmini henüz yayımlanmadı. Günlük model koşusu geldiğinde açılır.'**
  String get riskDayNotPublished;

  /// No description provided for @riskAttribution.
  ///
  /// In tr, this message translates to:
  /// **'© European Union, Copernicus EFFIS · CC BY 4.0'**
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
  /// **'Tekrarlanan tespit'**
  String get homeLast24hActiveTitle;

  /// No description provided for @homeLast24hActiveSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Son {hours} saat içinde uydu tarafından görüldü'**
  String homeLast24hActiveSubtitle(int hours);

  /// No description provided for @homeLast24hEndedTitle.
  ///
  /// In tr, this message translates to:
  /// **'Artık görülmeyen'**
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
  /// **'En güçlü uydu tespiti — doğrulanmadı'**
  String get homeLast24hStrongestTitle;

  /// No description provided for @homeLast24hStrongestSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Uyduların şu an gördüğü en güçlü tespit'**
  String get homeLast24hStrongestSubtitle;

  /// No description provided for @homeLast24hStrongestSubtitleWithDuration.
  ///
  /// In tr, this message translates to:
  /// **'En az {duration}, halen tespit ediliyor'**
  String homeLast24hStrongestSubtitleWithDuration(String duration);

  /// No description provided for @durationHoursShort.
  ///
  /// In tr, this message translates to:
  /// **'{hours} saat'**
  String durationHoursShort(int hours);

  /// No description provided for @durationDaysHours.
  ///
  /// In tr, this message translates to:
  /// **'{days} gün {hours} saat'**
  String durationDaysHours(int days, int hours);

  /// No description provided for @incidentsEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Bu aralıkta gruplanmış uydu olayı yok.'**
  String get incidentsEmpty;

  /// No description provided for @incidentsCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} olay'**
  String incidentsCount(int count);

  /// No description provided for @incidentPanelTitle.
  ///
  /// In tr, this message translates to:
  /// **'Uydu tespiti'**
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

  /// No description provided for @incidentStatusPersistentHeatSource.
  ///
  /// In tr, this message translates to:
  /// **'Sabit ısı kaynağı'**
  String get incidentStatusPersistentHeatSource;

  /// No description provided for @incidentPersistentHeatSourceNote.
  ///
  /// In tr, this message translates to:
  /// **'{days} gündür düşük ve değişmeyen güçte ısı yayıyor: demir-çelik tesisi, rafineri veya gaz bacası gibi sabit bir kaynak. Aktif yangın sayılmaz. Bu, herhangi bir yangının söndüğü anlamına gelmez.'**
  String incidentPersistentHeatSourceNote(int days);

  /// No description provided for @homeFixedHeatSourceChip.
  ///
  /// In tr, this message translates to:
  /// **'Sabit ısı kaynağı'**
  String get homeFixedHeatSourceChip;

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

  /// No description provided for @riskHeatPill.
  ///
  /// In tr, this message translates to:
  /// **'{place} · {score}/100 · {level}'**
  String riskHeatPill(String place, int score, String level);

  /// No description provided for @riskHeatTurkeyWide.
  ///
  /// In tr, this message translates to:
  /// **'Türkiye geneli'**
  String get riskHeatTurkeyWide;

  /// No description provided for @riskHeatLevelVeryHigh.
  ///
  /// In tr, this message translates to:
  /// **'Çok yüksek'**
  String get riskHeatLevelVeryHigh;

  /// No description provided for @riskHeatUnavailable.
  ///
  /// In tr, this message translates to:
  /// **'Risk verisi şu an alınamıyor'**
  String get riskHeatUnavailable;

  /// No description provided for @riskHeatMapSemantics.
  ///
  /// In tr, this message translates to:
  /// **'Türkiye yangın riski ısı haritası. Türkiye geneli risk skoru {score}/100, {level}.'**
  String riskHeatMapSemantics(int score, String level);

  /// No description provided for @navRisk.
  ///
  /// In tr, this message translates to:
  /// **'Risk'**
  String get navRisk;

  /// No description provided for @riskAdviceCritical.
  ///
  /// In tr, this message translates to:
  /// **'Açık alanda ateş yakmayın. Şüpheli dumanı 112’ye bildirin; resmi uyarıları izleyin.'**
  String get riskAdviceCritical;

  /// No description provided for @riskAdviceHigh.
  ///
  /// In tr, this message translates to:
  /// **'Açık alanda ateş yakmayın; kıvılcım çıkarabilecek işlerden kaçının.'**
  String get riskAdviceHigh;

  /// No description provided for @riskAdviceMedium.
  ///
  /// In tr, this message translates to:
  /// **'Kuru bitki örtüsü yakınında dikkatli olun; yerel uyarıları izleyin.'**
  String get riskAdviceMedium;

  /// No description provided for @riskAdviceLow.
  ///
  /// In tr, this message translates to:
  /// **'Risk düşük olsa da sıfır değildir. Ateşi ve izmaritleri doğaya bırakmayın.'**
  String get riskAdviceLow;

  /// No description provided for @riskScoreNotProbability.
  ///
  /// In tr, this message translates to:
  /// **'Bu puan, yangın çıkıp çıkmayacağını söylemez.'**
  String get riskScoreNotProbability;

  /// No description provided for @riskScoresAreIndices.
  ///
  /// In tr, this message translates to:
  /// **'Puanlar 0–100 arası bir endekstir; yangın çıkıp çıkmayacağını söylemez.'**
  String get riskScoresAreIndices;

  /// No description provided for @riskNearbyFireCount.
  ///
  /// In tr, this message translates to:
  /// **'Son günlerde yakında {count} uydu tespiti.'**
  String riskNearbyFireCount(String count);

  /// No description provided for @riskNearbyFireCountUnavailable.
  ///
  /// In tr, this message translates to:
  /// **'Yakındaki son yangın sayısı henüz paylaşılmıyor.'**
  String get riskNearbyFireCountUnavailable;

  /// No description provided for @riskPreviousScore.
  ///
  /// In tr, this message translates to:
  /// **'Önceki puan: {score}/100'**
  String riskPreviousScore(String score);

  /// No description provided for @riskCalculatedAt.
  ///
  /// In tr, this message translates to:
  /// **'Hesaplama: {date}'**
  String riskCalculatedAt(String date);

  /// No description provided for @riskSavedView.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedilmiş görünüm'**
  String get riskSavedView;

  /// No description provided for @riskServerUnreachable.
  ///
  /// In tr, this message translates to:
  /// **'Sunucuya ulaşılamadı. Kaydedilmiş veriler gösteriliyor.'**
  String get riskServerUnreachable;

  /// No description provided for @riskServerUnreachableSavedAt.
  ///
  /// In tr, this message translates to:
  /// **'Sunucuya ulaşılamadı. Son kayıt: {date}'**
  String riskServerUnreachableSavedAt(String date);

  /// No description provided for @riskRestorationCardTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yangın kayıpları ve restorasyon'**
  String get riskRestorationCardTitle;

  /// No description provided for @riskRestorationCardSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Aylık yanan alan verilerini zaman içinde takip edin'**
  String get riskRestorationCardSubtitle;

  /// No description provided for @riskHistoryCardTitle.
  ///
  /// In tr, this message translates to:
  /// **'Geçmiş yangınlar'**
  String get riskHistoryCardTitle;

  /// No description provided for @riskHistoryCardSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Geçmiş yangın alanları, tarihleri ve restorasyon güncellemeleri'**
  String get riskHistoryCardSubtitle;

  /// No description provided for @riskDistrictMapCardTitle.
  ///
  /// In tr, this message translates to:
  /// **'İl / ilçe risk haritası'**
  String get riskDistrictMapCardTitle;

  /// No description provided for @riskDistrictMapCardSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'İlçe düzeyinde risk puanları ve sıralama'**
  String get riskDistrictMapCardSubtitle;

  /// No description provided for @newsTabFires.
  ///
  /// In tr, this message translates to:
  /// **'Yangınlar'**
  String get newsTabFires;

  /// No description provided for @newsTabRecovery.
  ///
  /// In tr, this message translates to:
  /// **'Yenilenme'**
  String get newsTabRecovery;

  /// No description provided for @newsTabSolidarity.
  ///
  /// In tr, this message translates to:
  /// **'Dayanışma'**
  String get newsTabSolidarity;

  /// No description provided for @newsTabEvents.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlikler'**
  String get newsTabEvents;

  /// No description provided for @newsShowingSaved.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedilmiş haberler gösteriliyor.'**
  String get newsShowingSaved;

  /// No description provided for @newsNoneInTab.
  ///
  /// In tr, this message translates to:
  /// **'Bu başlıkta henüz içerik yok.'**
  String get newsNoneInTab;

  /// No description provided for @newsEventJoin.
  ///
  /// In tr, this message translates to:
  /// **'Katıl'**
  String get newsEventJoin;

  /// No description provided for @newsDonate.
  ///
  /// In tr, this message translates to:
  /// **'Bağış yap'**
  String get newsDonate;

  /// No description provided for @newsAddToCalendar.
  ///
  /// In tr, this message translates to:
  /// **'Takvime ekle'**
  String get newsAddToCalendar;

  /// No description provided for @newsCalendarFailed.
  ///
  /// In tr, this message translates to:
  /// **'Takvim uygulaması açılamadı.'**
  String get newsCalendarFailed;

  /// No description provided for @newsLinkFailed.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı açılamadı.'**
  String get newsLinkFailed;

  /// No description provided for @annualLayerToggle.
  ///
  /// In tr, this message translates to:
  /// **'Geçmiş yıllar'**
  String get annualLayerToggle;

  /// No description provided for @annualLayerCaption.
  ///
  /// In tr, this message translates to:
  /// **'İl rengi: {year} OGM yanan alanı. Noktalar: mevcut tespitler. Uydu noktası yangın sayısı değildir.'**
  String annualLayerCaption(int year);

  /// No description provided for @annualLayerLoadError.
  ///
  /// In tr, this message translates to:
  /// **'Geçmiş yıl dosyaları yüklenemedi. Tekrar denemek için katmanı kapatıp açın.'**
  String get annualLayerLoadError;

  /// No description provided for @riskDrynessIndexDerived.
  ///
  /// In tr, this message translates to:
  /// **'Kuruluk göstergesi (sıcaklık, nem ve rüzgârdan türetilir)'**
  String get riskDrynessIndexDerived;

  /// No description provided for @riskVegetationDensityDerived.
  ///
  /// In tr, this message translates to:
  /// **'Bitki baskısı (sıcaklık ve rüzgârdan türetilir)'**
  String get riskVegetationDensityDerived;

  /// No description provided for @riskDrynessDerivation.
  ///
  /// In tr, this message translates to:
  /// **'Sıcaklık, nem ve rüzgârdan türetilir.'**
  String get riskDrynessDerivation;

  /// No description provided for @annualPastYearChip.
  ///
  /// In tr, this message translates to:
  /// **'{year} · Geçmiş yıl'**
  String annualPastYearChip(int year);

  /// No description provided for @annualNoData.
  ///
  /// In tr, this message translates to:
  /// **'Veri yok'**
  String get annualNoData;

  /// No description provided for @annualMetricOgmArea.
  ///
  /// In tr, this message translates to:
  /// **'OGM yanan alan'**
  String get annualMetricOgmArea;

  /// No description provided for @annualMetricOgmCount.
  ///
  /// In tr, this message translates to:
  /// **'OGM yangın sayısı'**
  String get annualMetricOgmCount;

  /// No description provided for @annualMetricSatellite.
  ///
  /// In tr, this message translates to:
  /// **'Uydu noktası'**
  String get annualMetricSatellite;

  /// No description provided for @annualMetricEffisArea.
  ///
  /// In tr, this message translates to:
  /// **'EFFIS alan'**
  String get annualMetricEffisArea;

  /// No description provided for @annualMetricOgmAreaDesc.
  ///
  /// In tr, this message translates to:
  /// **'OGM’nin kaydettiği yanan orman alanı. İl renkleri her zaman bu değere göre belirlenir.'**
  String get annualMetricOgmAreaDesc;

  /// No description provided for @annualMetricOgmCountDesc.
  ///
  /// In tr, this message translates to:
  /// **'OGM’nin kaydettiği orman yangını sayısı.'**
  String get annualMetricOgmCountDesc;

  /// No description provided for @annualMetricSatelliteDesc.
  ///
  /// In tr, this message translates to:
  /// **'Uydu noktası yangın sayısı değildir. Orman ve maki alanındaki uydu tespitlerini gösterir.'**
  String get annualMetricSatelliteDesc;

  /// No description provided for @annualMetricEffisAreaDesc.
  ///
  /// In tr, this message translates to:
  /// **'EFFIS’in uydu görüntülerinden hesapladığı yanan alan. Küçük yangınların kapsamı OGM’den farklı olabilir.'**
  String get annualMetricEffisAreaDesc;

  /// No description provided for @annualMetricExplainTitle.
  ///
  /// In tr, this message translates to:
  /// **'Değerlerin açıklaması'**
  String get annualMetricExplainTitle;

  /// No description provided for @annualMetricExplainHint.
  ///
  /// In tr, this message translates to:
  /// **'Seçim yalnızca açıklamayı değiştirir; il rengi her zaman OGM yanan alanını gösterir.'**
  String get annualMetricExplainHint;

  /// No description provided for @annualProvinceNote.
  ///
  /// In tr, this message translates to:
  /// **'Uydu noktası yangın sayısı değildir. İl dolguları yangının sınırını değil, il genelindeki yıllık toplamı gösterir.'**
  String get annualProvinceNote;

  /// No description provided for @annualLegendTitle.
  ///
  /// In tr, this message translates to:
  /// **'Geçmiş yıllar · OGM yanan alan'**
  String get annualLegendTitle;

  /// No description provided for @annualLegendTickMax.
  ///
  /// In tr, this message translates to:
  /// **'≥ {value} ha'**
  String annualLegendTickMax(String value);

  /// No description provided for @annualLegendNote.
  ///
  /// In tr, this message translates to:
  /// **'Logaritmik renk ölçeği · Koyu renk daha fazla yanan alanı gösterir. Verisi olmayan iller boyanmaz. Bu katman güncel yangın riski değildir.'**
  String get annualLegendNote;

  /// No description provided for @districtRiskRankingTitle.
  ///
  /// In tr, this message translates to:
  /// **'Risk sıralaması'**
  String get districtRiskRankingTitle;

  /// No description provided for @districtRiskScoresNotProbability.
  ///
  /// In tr, this message translates to:
  /// **'Puanlar yangın çıkıp çıkmayacağını söylemez.'**
  String get districtRiskScoresNotProbability;

  /// No description provided for @districtRiskSampleBanner.
  ///
  /// In tr, this message translates to:
  /// **'ÖRNEK VERİ · Sınırlar şematiktir; gerçek ilçe sınırları ve güncel risk değildir.'**
  String get districtRiskSampleBanner;

  /// No description provided for @districtRiskLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'İlçe risk verisi alınamadı. Yeniden denemek için dokunun.'**
  String get districtRiskLoadFailed;

  /// No description provided for @districtRiskAllProvinces.
  ///
  /// In tr, this message translates to:
  /// **'Türkiye'**
  String get districtRiskAllProvinces;

  /// No description provided for @districtRiskAllDistricts.
  ///
  /// In tr, this message translates to:
  /// **'Tüm ilçeler'**
  String get districtRiskAllDistricts;

  /// No description provided for @districtRiskNoScore.
  ///
  /// In tr, this message translates to:
  /// **'Risk verisi yok'**
  String get districtRiskNoScore;

  /// No description provided for @districtRiskOpenRanking.
  ///
  /// In tr, this message translates to:
  /// **'Risk sıralamasını aç'**
  String get districtRiskOpenRanking;

  /// No description provided for @historyLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Geçmiş yangın verileri alınamadı. Yeniden denemek için dokunun.'**
  String get historyLoadFailed;

  /// No description provided for @historySourceOpenFailed.
  ///
  /// In tr, this message translates to:
  /// **'Kaynak açılamadı.'**
  String get historySourceOpenFailed;

  /// No description provided for @historySampleRecord.
  ///
  /// In tr, this message translates to:
  /// **'ÖRNEK KAYIT — gerçek bir yangını temsil etmez.'**
  String get historySampleRecord;

  /// No description provided for @historyAreaUnknown.
  ///
  /// In tr, this message translates to:
  /// **'Alan henüz bilinmiyor'**
  String get historyAreaUnknown;

  /// No description provided for @historyAreaPitches.
  ///
  /// In tr, this message translates to:
  /// **'{hectares} hektar — yaklaşık {pitches} futbol sahası.'**
  String historyAreaPitches(String hectares, String pitches);

  /// No description provided for @historyPitchComparison.
  ///
  /// In tr, this message translates to:
  /// **'Karşılaştırma: 105 × 68 m saha = 0,714 hektar.'**
  String get historyPitchComparison;

  /// No description provided for @historyAreaSource.
  ///
  /// In tr, this message translates to:
  /// **'Alan verisinin kaynağı'**
  String get historyAreaSource;

  /// No description provided for @historyRestorationTitle.
  ///
  /// In tr, this message translates to:
  /// **'Restorasyon'**
  String get historyRestorationTitle;

  /// No description provided for @historyNoRestoration.
  ///
  /// In tr, this message translates to:
  /// **'Bu alan için kaynakla doğrulanmış restorasyon kaydı henüz yok. Bu, çalışma yapılmadığı anlamına gelmez.'**
  String get historyNoRestoration;

  /// No description provided for @historyComparisonSource.
  ///
  /// In tr, this message translates to:
  /// **'Karşılaştırmanın kaynağı'**
  String get historyComparisonSource;

  /// No description provided for @historyOpenAnnouncement.
  ///
  /// In tr, this message translates to:
  /// **'Resmi duyuruyu aç'**
  String get historyOpenAnnouncement;

  /// No description provided for @historyCampaignsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Değişim tek kişiyle başlar'**
  String get historyCampaignsTitle;

  /// No description provided for @historyNoCampaigns.
  ///
  /// In tr, this message translates to:
  /// **'Doğrulanmış bir kampanya veya gönüllü etkinliği henüz eklenmedi.'**
  String get historyNoCampaigns;

  /// No description provided for @historyPeriodThisSummer.
  ///
  /// In tr, this message translates to:
  /// **'Bu yaz'**
  String get historyPeriodThisSummer;

  /// No description provided for @historyPeriodSinceLastSummer.
  ///
  /// In tr, this message translates to:
  /// **'Geçen yazdan beri'**
  String get historyPeriodSinceLastSummer;

  /// No description provided for @historyPeriodLast3Years.
  ///
  /// In tr, this message translates to:
  /// **'Son 3 yıl'**
  String get historyPeriodLast3Years;

  /// No description provided for @historyPeriodCustom.
  ///
  /// In tr, this message translates to:
  /// **'Özel aralık'**
  String get historyPeriodCustom;

  /// No description provided for @historyNoRecords.
  ///
  /// In tr, this message translates to:
  /// **'Seçilen aralıkta kayıt yok.'**
  String get historyNoRecords;

  /// No description provided for @historySampleBanner.
  ///
  /// In tr, this message translates to:
  /// **'ÖRNEK VERİ · Boyalı alanlar şematiktir; gerçek yangın sınırları değildir.'**
  String get historySampleBanner;

  /// No description provided for @historySourceSample.
  ///
  /// In tr, this message translates to:
  /// **'Kaynak: örnek veri. Canlı kaynak: NASA FIRMS (VIIRS/MODIS).'**
  String get historySourceSample;

  /// No description provided for @historySourceLive.
  ///
  /// In tr, this message translates to:
  /// **'Kaynak: NASA FIRMS (VIIRS/MODIS) · uydu ısı tespitleri'**
  String get historySourceLive;

  /// No description provided for @historyDetections.
  ///
  /// In tr, this message translates to:
  /// **'{count} tespit · {hours} saat'**
  String historyDetections(String count, String hours);

  /// No description provided for @historyMaxFrp.
  ///
  /// In tr, this message translates to:
  /// **'En yüksek ışınım gücü (FRP): {frp} MW'**
  String historyMaxFrp(String frp);

  /// No description provided for @historyFootprintNote.
  ///
  /// In tr, this message translates to:
  /// **'Haritadaki şekil, uydunun ısı tespit ettiği yerlerin izidir (her tespitin çevresinde 188 m); yanan alanın sınırı değildir. Yanan alan ölçülmediği için alan gösterilmez. Anız ve tarım yangınları da dahildir.'**
  String get historyFootprintNote;

  /// No description provided for @historyNearestDistrictNote.
  ///
  /// In tr, this message translates to:
  /// **'İlçe, olayın merkezine en yakın ilçe merkezine göre belirlendi; sınıra yakın olaylarda komşu ilçe olabilir.'**
  String get historyNearestDistrictNote;

  /// No description provided for @historyOpenFirmsMap.
  ///
  /// In tr, this message translates to:
  /// **'NASA FIRMS haritasını aç'**
  String get historyOpenFirmsMap;

  /// No description provided for @historyFirmsAttribution.
  ///
  /// In tr, this message translates to:
  /// **'We acknowledge the use of data and/or imagery from NASA\'s Fire Information for Resource Management System (FIRMS) (https://earthdata.nasa.gov/firms), part of NASA\'s Land, Atmosphere Near real-time Capability for Earth observations (LANCE) (https://earthdata.nasa.gov/lance) and NASA\'s Earth Science Data and Information System (ESDIS).'**
  String get historyFirmsAttribution;

  /// No description provided for @detectionNotConfirmedNotice.
  ///
  /// In tr, this message translates to:
  /// **'Bu bir uydu ısı tespitidir, doğrulanmış yangın değildir. Yangın ya da duman görürseniz hemen 112\'yi arayın.'**
  String get detectionNotConfirmedNotice;

  /// No description provided for @riskFactorTempHintNone.
  ///
  /// In tr, this message translates to:
  /// **'25°C altındaki sıcaklık risk puanını artırmaz.'**
  String get riskFactorTempHintNone;

  /// No description provided for @riskFactorTempHint.
  ///
  /// In tr, this message translates to:
  /// **'Risk puanına +{points}/{max} ekler: sıcak hava bitkilerin daha hızlı nem kaybetmesine yol açar.'**
  String riskFactorTempHint(int points, int max);

  /// No description provided for @riskFactorHumidityHintNone.
  ///
  /// In tr, this message translates to:
  /// **'%50 üzerindeki nem risk puanını artırmaz; nemli bitki örtüsü daha zor tutuşur.'**
  String get riskFactorHumidityHintNone;

  /// No description provided for @riskFactorHumidityHint.
  ///
  /// In tr, this message translates to:
  /// **'Risk puanına +{points}/{max} ekler: düşük nem yanıcı bitki örtüsünü kurutur.'**
  String riskFactorHumidityHint(int points, int max);

  /// No description provided for @riskFactorWindHintNone.
  ///
  /// In tr, this message translates to:
  /// **'10 km/h altındaki rüzgâr risk puanını artırmaz.'**
  String get riskFactorWindHintNone;

  /// No description provided for @riskFactorWindHint.
  ///
  /// In tr, this message translates to:
  /// **'Risk puanına +{points}/{max} ekler: rüzgâr alevleri ve kıvılcımları taşıyabilir.'**
  String riskFactorWindHint(int points, int max);

  /// No description provided for @riskNoteLightWind.
  ///
  /// In tr, this message translates to:
  /// **'Hafif rüzgâr ({wind} km/h)'**
  String riskNoteLightWind(int wind);

  /// No description provided for @newsFeaturedSubtitleLatest.
  ///
  /// In tr, this message translates to:
  /// **'En güncel başlık'**
  String get newsFeaturedSubtitleLatest;

  /// No description provided for @homeBriefRiskLoading.
  ///
  /// In tr, this message translates to:
  /// **'Bölgesel risk verisi yükleniyor.'**
  String get homeBriefRiskLoading;

  /// No description provided for @homeBriefRiskUnavailable.
  ///
  /// In tr, this message translates to:
  /// **'Bölgesel risk verisi şu an alınamadı.'**
  String get homeBriefRiskUnavailable;

  /// No description provided for @homeBriefRiskHighest.
  ///
  /// In tr, this message translates to:
  /// **'En yüksek bölgesel risk {region} bölgesinde: {score}/100.'**
  String homeBriefRiskHighest(String region, int score);

  /// No description provided for @homeBriefNationwide.
  ///
  /// In tr, this message translates to:
  /// **'{count} önemli uydu tespiti Türkiye genelinde izleniyor.'**
  String homeBriefNationwide(int count);

  /// No description provided for @homeBriefNoneNearby.
  ///
  /// In tr, this message translates to:
  /// **'100 km çevrenizde önemli bir tespit görünmüyor.'**
  String get homeBriefNoneNearby;

  /// No description provided for @homeBriefNearby.
  ///
  /// In tr, this message translates to:
  /// **'100 km çevrenizde {count} tespit var; haritadan ayrıntıları kontrol edin.'**
  String homeBriefNearby(int count);

  /// No description provided for @homeBriefTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bugün ne bilmeliyim?'**
  String get homeBriefTitle;

  /// No description provided for @homeBriefSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Kısa durum özeti'**
  String get homeBriefSubtitle;

  /// No description provided for @homeBriefViewRisk.
  ///
  /// In tr, this message translates to:
  /// **'Riski incele'**
  String get homeBriefViewRisk;

  /// No description provided for @homeBriefOpenMap.
  ///
  /// In tr, this message translates to:
  /// **'Haritayı aç'**
  String get homeBriefOpenMap;

  /// No description provided for @dataSourcesBordersTitle.
  ///
  /// In tr, this message translates to:
  /// **'İl sınırları'**
  String get dataSourcesBordersTitle;

  /// No description provided for @dataSourcesBordersBody.
  ///
  /// In tr, this message translates to:
  /// **'Haritadaki \"Geçmiş yıllar\" katmanında çizilen 81 il sınırı ve sunucunun bir tespiti hangi ile atadığı aynı dosyadan gelir: geoBoundaries (gbOpen, TUR ADM1), OpenStreetMap verisinden türetilmiştir. Sınırlar sadeleştirilmiştir; il sınırına çok yakın bir nokta komşu ile düşebilir. Denizdeki ya da sınır dışındaki noktalar en yakın ile atanır.'**
  String get dataSourcesBordersBody;

  /// No description provided for @dataSourcesBordersGeoBoundariesCredit.
  ///
  /// In tr, this message translates to:
  /// **'İl sınırları: geoBoundaries'**
  String get dataSourcesBordersGeoBoundariesCredit;

  /// No description provided for @annualLayerProvenance.
  ///
  /// In tr, this message translates to:
  /// **'Yıllık il toplamları kaynak veri setinde hesaplanmıştır (OGM orman yangını istatistikleri; NASA FIRMS VIIRS S-NPP ve ESA WorldCover 2021; EFFIS). Veri setinin kendi beyanına göre uydu noktası sayıları GADM 4.1 il sınırlarıyla hesaplanmıştır. Haritada çizilen il sınırları geoBoundaries / OpenStreetMap\'tir.'**
  String get annualLayerProvenance;

  /// No description provided for @osmAttribution.
  ///
  /// In tr, this message translates to:
  /// **'© OpenStreetMap katkıcıları, ODbL'**
  String get osmAttribution;

  /// No description provided for @odblLicenseLink.
  ///
  /// In tr, this message translates to:
  /// **'ODbL 1.0 lisansı'**
  String get odblLicenseLink;

  /// No description provided for @mapDetectionConfidence.
  ///
  /// In tr, this message translates to:
  /// **'Tespit güveni: {score}/100'**
  String mapDetectionConfidence(int score);

  /// No description provided for @mapDetectionConfidenceInfoTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tespit güveni'**
  String get mapDetectionConfidenceInfoTitle;

  /// No description provided for @mapDetectionConfidenceInfoBody.
  ///
  /// In tr, this message translates to:
  /// **'NASA\'nın güven düzeyi, tespitin gücü, 20 km içindeki tekrar eden tespitler ve tespitin ne kadar yeni olduğundan hesaplanır. Hava durumu bu puana katılmaz.'**
  String get mapDetectionConfidenceInfoBody;

  /// No description provided for @mapDetectionConfidenceInfoNotFire.
  ///
  /// In tr, this message translates to:
  /// **'Bu puan bir uydu tespitinin ne kadar belirgin olduğunu gösterir. Orada yangın olduğunu doğrulamaz.'**
  String get mapDetectionConfidenceInfoNotFire;

  /// No description provided for @mapStrongUnverifiedReason.
  ///
  /// In tr, this message translates to:
  /// **'Uydular tek geçişte güçlü bir tespit yaptı; doğrulanmadı.'**
  String get mapStrongUnverifiedReason;

  /// No description provided for @mapStrongUnverifiedBanner.
  ///
  /// In tr, this message translates to:
  /// **'{count} güçlü, doğrulanmamış tespit — Noktalar\'da görün'**
  String mapStrongUnverifiedBanner(int count);

  /// No description provided for @multiPassDetectionLabel.
  ///
  /// In tr, this message translates to:
  /// **'Çoklu geçiş tespiti'**
  String get multiPassDetectionLabel;

  /// No description provided for @multiPassDetectionExplanation.
  ///
  /// In tr, this message translates to:
  /// **'Uydular aynı noktada en az iki ayrı geçişte güçlü tespit yaptı. Bu, yangın olduğunu doğrulamaz.'**
  String get multiPassDetectionExplanation;

  /// No description provided for @homeMultiPassSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'En az 2 uydu geçişi; {weaker} zayıf tespit daha Noktalar katmanında'**
  String homeMultiPassSubtitle(int weaker);

  /// No description provided for @homeMultiPassNote.
  ///
  /// In tr, this message translates to:
  /// **'{count} tekrarlanan tespit (en az 2 uydu geçişi); haritada {weaker} tek geçişli ya da zayıf tespit daha var. Hiçbiri doğrulanmadı.'**
  String homeMultiPassNote(int count, int weaker);

  /// No description provided for @incidentExtinguishedConflict.
  ///
  /// In tr, this message translates to:
  /// **'Resmî bilgi: söndürüldü — uydu hâlâ ısı görüyor'**
  String get incidentExtinguishedConflict;

  /// No description provided for @fireDetailLinkedNews.
  ///
  /// In tr, this message translates to:
  /// **'Bu yangınla ilişkilendirilen haberler'**
  String get fireDetailLinkedNews;

  /// No description provided for @osmTileAttribution.
  ///
  /// In tr, this message translates to:
  /// **'© OpenStreetMap katkıcıları'**
  String get osmTileAttribution;

  /// No description provided for @riskInfoFormulaHeatBonus.
  ///
  /// In tr, this message translates to:
  /// **'Sıcak ve kuru hava birlikteyse ek puan (en fazla 20 puan)'**
  String get riskInfoFormulaHeatBonus;

  /// No description provided for @myPlacesRiskLine.
  ///
  /// In tr, this message translates to:
  /// **'Yangın riski: {level} ({score}/100)'**
  String myPlacesRiskLine(String level, int score);

  /// No description provided for @myPlacesDetections24h.
  ///
  /// In tr, this message translates to:
  /// **'Son 24 saatte {count} tespit'**
  String myPlacesDetections24h(int count);

  /// No description provided for @myPlacesNoDetections.
  ///
  /// In tr, this message translates to:
  /// **'Son 24 saatte yakında tespit yok'**
  String get myPlacesNoDetections;

  /// No description provided for @myPlacesRiskNote.
  ///
  /// In tr, this message translates to:
  /// **'Risk, hava koşulları ve yakın uydu tespitlerinden hesaplanan bir puandır. Tespit olmaması yangın olmadığı anlamına gelmez.'**
  String get myPlacesRiskNote;

  /// No description provided for @trackedPlacesEditTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeri düzenle'**
  String get trackedPlacesEditTitle;

  /// No description provided for @trackedPlacesNotifyHeat.
  ///
  /// In tr, this message translates to:
  /// **'Yakında yeni ısı tespiti olunca bildir'**
  String get trackedPlacesNotifyHeat;

  /// No description provided for @trackedPlacesNotifyRisk.
  ///
  /// In tr, this message translates to:
  /// **'Yangın riski yükselince bildir'**
  String get trackedPlacesNotifyRisk;

  /// No description provided for @trackedPlacesNotifyRiskDesc.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek veya Kritik\'e çıkınca, günde en fazla bir kez'**
  String get trackedPlacesNotifyRiskDesc;

  /// No description provided for @placeSearchHint.
  ///
  /// In tr, this message translates to:
  /// **'İl, ilçe, mahalle ya da adres'**
  String get placeSearchHint;

  /// No description provided for @placeSearchButton.
  ///
  /// In tr, this message translates to:
  /// **'Ara'**
  String get placeSearchButton;

  /// No description provided for @placeSearchRemote.
  ///
  /// In tr, this message translates to:
  /// **'Mahalle veya adres olarak ara'**
  String get placeSearchRemote;

  /// No description provided for @placeSearchNoResults.
  ///
  /// In tr, this message translates to:
  /// **'Sonuç bulunamadı. Haritadan seçebilirsiniz.'**
  String get placeSearchNoResults;

  /// No description provided for @placeSearchFailed.
  ///
  /// In tr, this message translates to:
  /// **'Arama şu an yapılamıyor. Haritadan seçebilirsiniz.'**
  String get placeSearchFailed;

  /// No description provided for @placeSearchTooShort.
  ///
  /// In tr, this message translates to:
  /// **'En az 3 harf yazın.'**
  String get placeSearchTooShort;

  /// No description provided for @placeSearchPrivacy.
  ///
  /// In tr, this message translates to:
  /// **'İl ve ilçe aramaları telefonunuzda yapılır. Mahalle ve adres aramaları sunucumuz üzerinden OpenStreetMap\'e iletilir; yazdığınız metin saklanmaz.'**
  String get placeSearchPrivacy;

  /// No description provided for @placeSearchAttribution.
  ///
  /// In tr, this message translates to:
  /// **'Arama sonuçları © OpenStreetMap katkıcıları (Nominatim)'**
  String get placeSearchAttribution;

  /// No description provided for @detectionNoneTitle.
  ///
  /// In tr, this message translates to:
  /// **'Son 24 saatte uydular Türkiye\'de orman ve doğal alanlarda güçlü bir ısı tespit etmedi.'**
  String get detectionNoneTitle;

  /// No description provided for @detectionLimitNote.
  ///
  /// In tr, this message translates to:
  /// **'Uydular küçük veya bulut altındaki yangınları göremeyebilir.'**
  String get detectionLimitNote;

  /// No description provided for @detectionLastUpdate.
  ///
  /// In tr, this message translates to:
  /// **'Son güncelleme: {time}'**
  String detectionLastUpdate(String time);

  /// No description provided for @detectionStaleTitle.
  ///
  /// In tr, this message translates to:
  /// **'Uydu verisi güncel değil.'**
  String get detectionStaleTitle;

  /// No description provided for @detectionStaleBody.
  ///
  /// In tr, this message translates to:
  /// **'Bu yüzden şu an tespit olup olmadığını söyleyemiyoruz.'**
  String get detectionStaleBody;

  /// No description provided for @detectionUnavailableTitle.
  ///
  /// In tr, this message translates to:
  /// **'Uydu verisi alınamadı.'**
  String get detectionUnavailableTitle;

  /// No description provided for @detectionUnavailableBody.
  ///
  /// In tr, this message translates to:
  /// **'Bu, tespit olmadığı anlamına gelmez. Bağlantınızı kontrol edip yeniden deneyin.'**
  String get detectionUnavailableBody;

  /// No description provided for @detectionCall112Line.
  ///
  /// In tr, this message translates to:
  /// **'Yangın görürseniz önce 112\'yi arayın.'**
  String get detectionCall112Line;

  /// No description provided for @detectionReportLine.
  ///
  /// In tr, this message translates to:
  /// **'Uygulamada görünmeyen bir yangın ya da bir hata fark ederseniz Raporla ile bize bildirin.'**
  String get detectionReportLine;

  /// No description provided for @detectionReportButton.
  ///
  /// In tr, this message translates to:
  /// **'Raporla'**
  String get detectionReportButton;

  /// No description provided for @detectionShowLast7Days.
  ///
  /// In tr, this message translates to:
  /// **'Son 7 günü göster'**
  String get detectionShowLast7Days;

  /// No description provided for @detectionOpenRisk.
  ///
  /// In tr, this message translates to:
  /// **'Risk katmanını aç'**
  String get detectionOpenRisk;

  /// No description provided for @detectionLatest.
  ///
  /// In tr, this message translates to:
  /// **'En son tespit: {when}, {city}'**
  String detectionLatest(String when, String city);

  /// No description provided for @detectionLatestNoCity.
  ///
  /// In tr, this message translates to:
  /// **'En son tespit: {when}'**
  String detectionLatestNoCity(String when);

  /// No description provided for @detectionDaysAgo.
  ///
  /// In tr, this message translates to:
  /// **'{days} gün önce'**
  String detectionDaysAgo(int days);

  /// No description provided for @detectionHoursAgo.
  ///
  /// In tr, this message translates to:
  /// **'{hours} saat önce'**
  String detectionHoursAgo(int hours);

  /// No description provided for @detectionJustNow.
  ///
  /// In tr, this message translates to:
  /// **'bir saatten kısa süre önce'**
  String get detectionJustNow;

  /// No description provided for @riskColorsNotFire.
  ///
  /// In tr, this message translates to:
  /// **'Renkler yangın değil, yangın çıkma riskidir.'**
  String get riskColorsNotFire;

  /// No description provided for @mapRiskLayer.
  ///
  /// In tr, this message translates to:
  /// **'Risk'**
  String get mapRiskLayer;

  /// No description provided for @mapRiskLegendTitle.
  ///
  /// In tr, this message translates to:
  /// **'Risk puanı (bölgelere göre)'**
  String get mapRiskLegendTitle;

  /// No description provided for @mapRiskLegendLow.
  ///
  /// In tr, this message translates to:
  /// **'Düşük · 0–24'**
  String get mapRiskLegendLow;

  /// No description provided for @mapRiskLegendMedium.
  ///
  /// In tr, this message translates to:
  /// **'Orta · 25–49'**
  String get mapRiskLegendMedium;

  /// No description provided for @mapRiskLegendHigh.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek · 50–74'**
  String get mapRiskLegendHigh;

  /// No description provided for @mapRiskLegendCritical.
  ///
  /// In tr, this message translates to:
  /// **'Kritik · 75–100'**
  String get mapRiskLegendCritical;

  /// No description provided for @mapRiskUnavailable.
  ///
  /// In tr, this message translates to:
  /// **'Risk verisi alınamadı.'**
  String get mapRiskUnavailable;

  /// No description provided for @mapRiskRegionTap.
  ///
  /// In tr, this message translates to:
  /// **'{region}: {score}/100, {level}'**
  String mapRiskRegionTap(String region, int score, String level);

  /// No description provided for @reportPanelNotEmergency.
  ///
  /// In tr, this message translates to:
  /// **'Bu bildirim acil servislere iletilmez; acil durumda 112\'yi arayın.'**
  String get reportPanelNotEmergency;

  /// No description provided for @reportPanelTypeLabel.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim türü'**
  String get reportPanelTypeLabel;

  /// No description provided for @reportTypeFire.
  ///
  /// In tr, this message translates to:
  /// **'Yangın gözlemi'**
  String get reportTypeFire;

  /// No description provided for @reportTypeMissingFire.
  ///
  /// In tr, this message translates to:
  /// **'Uygulamada görünmeyen yangın'**
  String get reportTypeMissingFire;

  /// No description provided for @reportTypeWrongInfo.
  ///
  /// In tr, this message translates to:
  /// **'Hatalı bilgi/uygulama hatası'**
  String get reportTypeWrongInfo;

  /// No description provided for @reportPanelWrongInfoHint.
  ///
  /// In tr, this message translates to:
  /// **'Neyin hatalı olduğunu yazın: hangi ekran, ne gördünüz, ne olmalıydı?'**
  String get reportPanelWrongInfoHint;

  /// No description provided for @reportPanelWrongInfoNeedText.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen neyin hatalı olduğunu yazın.'**
  String get reportPanelWrongInfoNeedText;

  /// No description provided for @reportPanelWrongInfoSent.
  ///
  /// In tr, this message translates to:
  /// **'Bildiriminiz alındı. Teşekkürler.'**
  String get reportPanelWrongInfoSent;

  /// No description provided for @riskTabPlaces.
  ///
  /// In tr, this message translates to:
  /// **'Yerlerim'**
  String get riskTabPlaces;

  /// No description provided for @riskPointBack.
  ///
  /// In tr, this message translates to:
  /// **'Yerlerim\'e dön'**
  String get riskPointBack;

  /// No description provided for @riskPointAdviceTitle.
  ///
  /// In tr, this message translates to:
  /// **'Öneriler'**
  String get riskPointAdviceTitle;

  /// No description provided for @riskPointWhyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Neden bu seviye'**
  String get riskPointWhyTitle;

  /// No description provided for @riskPointNearbyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yakın tespitler'**
  String get riskPointNearbyTitle;

  /// No description provided for @riskPointNearby.
  ///
  /// In tr, this message translates to:
  /// **'{km} km içinde son 24 saatte {count} uydu tespiti'**
  String riskPointNearby(int km, int count);

  /// No description provided for @riskPointNearbyNone.
  ///
  /// In tr, this message translates to:
  /// **'{km} km içinde son 24 saatte uydu tespiti yok. Bu, yangın olmadığı anlamına gelmez.'**
  String riskPointNearbyNone(int km);

  /// No description provided for @riskPointNearbyUnknown.
  ///
  /// In tr, this message translates to:
  /// **'Yakın uydu tespitleri şu an bilinmiyor; puan yalnızca hava koşullarından hesaplandı.'**
  String get riskPointNearbyUnknown;

  /// No description provided for @riskPointCalculatedAt.
  ///
  /// In tr, this message translates to:
  /// **'Hesaplanma: {time}'**
  String riskPointCalculatedAt(String time);

  /// No description provided for @riskPointUnavailable.
  ///
  /// In tr, this message translates to:
  /// **'Risk şu an hesaplanamadı. Yeniden deneyin.'**
  String get riskPointUnavailable;

  /// No description provided for @riskCopernicusTitle.
  ///
  /// In tr, this message translates to:
  /// **'Copernicus yangın tehlike indeksi'**
  String get riskCopernicusTitle;

  /// No description provided for @riskCopernicusNote.
  ///
  /// In tr, this message translates to:
  /// **'FireWatch risk puanından ayrı, hava modeline dayalı bir göstergedir; puana katılmaz.'**
  String get riskCopernicusNote;

  /// No description provided for @riskCopernicusAttribution.
  ///
  /// In tr, this message translates to:
  /// **'© European Union, Copernicus EFFIS · CC BY 4.0'**
  String get riskCopernicusAttribution;

  /// No description provided for @commonDetails.
  ///
  /// In tr, this message translates to:
  /// **'Detaylar'**
  String get commonDetails;

  /// No description provided for @incidentPeakPowerDetail.
  ///
  /// In tr, this message translates to:
  /// **'En yüksek ışıma gücü (FRP): {mw} MW'**
  String incidentPeakPowerDetail(String mw);

  /// No description provided for @commonAllTechnical.
  ///
  /// In tr, this message translates to:
  /// **'Tüm teknik bilgiler'**
  String get commonAllTechnical;

  /// No description provided for @dsStrong.
  ///
  /// In tr, this message translates to:
  /// **'Uydular {city} yakınında güçlü bir yangın izi tespit etti.'**
  String dsStrong(String city);

  /// No description provided for @dsStrongNoCity.
  ///
  /// In tr, this message translates to:
  /// **'Uydular güçlü bir yangın izi tespit etti.'**
  String get dsStrongNoCity;

  /// No description provided for @dsNormal.
  ///
  /// In tr, this message translates to:
  /// **'Uydular {city} yakınında bir yangın izi tespit etti.'**
  String dsNormal(String city);

  /// No description provided for @dsNormalNoCity.
  ///
  /// In tr, this message translates to:
  /// **'Uydular bir yangın izi tespit etti.'**
  String get dsNormalNoCity;

  /// No description provided for @dsNotVerified.
  ///
  /// In tr, this message translates to:
  /// **'Henüz doğrulanmadı.'**
  String get dsNotVerified;

  /// No description provided for @dsNewsVerified.
  ///
  /// In tr, this message translates to:
  /// **'Haberlerde doğrulandı.'**
  String get dsNewsVerified;

  /// No description provided for @dsFarmland.
  ///
  /// In tr, this message translates to:
  /// **'Tarım alanı olduğu için anız yakma da olabilir.'**
  String get dsFarmland;

  /// No description provided for @dsBuilt.
  ///
  /// In tr, this message translates to:
  /// **'Sanayi veya yerleşim alanı olduğu için sabit bir ısı kaynağı da olabilir.'**
  String get dsBuilt;

  /// No description provided for @dsSeenJustNow.
  ///
  /// In tr, this message translates to:
  /// **'Az önce görüldü.'**
  String get dsSeenJustNow;

  /// No description provided for @dsSeenHours.
  ///
  /// In tr, this message translates to:
  /// **'{hours} saat önce görüldü.'**
  String dsSeenHours(int hours);

  /// No description provided for @dsSeenDays.
  ///
  /// In tr, this message translates to:
  /// **'{days} gün önce görüldü.'**
  String dsSeenDays(int days);

  /// No description provided for @lastSeenHours.
  ///
  /// In tr, this message translates to:
  /// **'Son görülme: {hours} saat önce'**
  String lastSeenHours(int hours);

  /// No description provided for @lastSeenDays.
  ///
  /// In tr, this message translates to:
  /// **'Son görülme: {days} gün önce'**
  String lastSeenDays(int days);

  /// No description provided for @incidentSeenPasses.
  ///
  /// In tr, this message translates to:
  /// **'Uydular bu noktayı {passes} ayrı geçişte gördü.'**
  String incidentSeenPasses(int passes);

  /// No description provided for @incidentSeenOnce.
  ///
  /// In tr, this message translates to:
  /// **'Uydular bu noktayı bir kez gördü.'**
  String get incidentSeenOnce;

  /// No description provided for @newsVerifiedLabel.
  ///
  /// In tr, this message translates to:
  /// **'Haberlerde doğrulandı'**
  String get newsVerifiedLabel;

  /// No description provided for @relatedNewsTitle.
  ///
  /// In tr, this message translates to:
  /// **'İlgili haberler'**
  String get relatedNewsTitle;

  /// No description provided for @mapPointFarmland.
  ///
  /// In tr, this message translates to:
  /// **'Tarım alanında — anız yakma olabilir'**
  String get mapPointFarmland;

  /// No description provided for @mapPointBuilt.
  ///
  /// In tr, this message translates to:
  /// **'Sanayi veya yerleşim alanında — sabit ısı kaynağı olabilir'**
  String get mapPointBuilt;

  /// No description provided for @detectionOtherLine.
  ///
  /// In tr, this message translates to:
  /// **'Tarım ve sanayi alanlarında {count} güçlü tespit var; bunlar Noktalar katmanında.'**
  String detectionOtherLine(int count);

  /// No description provided for @fireDetailBrightness.
  ///
  /// In tr, this message translates to:
  /// **'Uydunun ölçtüğü yüzey parlaklık sıcaklığı'**
  String get fireDetailBrightness;

  /// No description provided for @fireDetailBrightnessNote.
  ///
  /// In tr, this message translates to:
  /// **'Bu, hava sıcaklığı değildir. Uydunun yerden aldığı ısı ölçümüdür; yangının sıcaklığını göstermez.'**
  String get fireDetailBrightnessNote;

  /// No description provided for @homeTodayTitle.
  ///
  /// In tr, this message translates to:
  /// **'Konumunuzda bugün'**
  String get homeTodayTitle;

  /// No description provided for @homeNearbyNone.
  ///
  /// In tr, this message translates to:
  /// **'25 km içinde uydular güçlü bir tespit yapmadı.'**
  String get homeNearbyNone;

  /// No description provided for @homeNearbySome.
  ///
  /// In tr, this message translates to:
  /// **'25 km içinde uydular {count} güçlü tespit yaptı.'**
  String homeNearbySome(int count);

  /// No description provided for @homeWind.
  ///
  /// In tr, this message translates to:
  /// **'Rüzgâr: {speed} km/s'**
  String homeWind(String speed);

  /// No description provided for @homeLocationNeeded.
  ///
  /// In tr, this message translates to:
  /// **'Konumunuzu açarsanız buradaki riski görürsünüz.'**
  String get homeLocationNeeded;

  /// No description provided for @homeLocationOutside.
  ///
  /// In tr, this message translates to:
  /// **'Konumunuz Türkiye dışında görünüyor.'**
  String get homeLocationOutside;

  /// No description provided for @homeLocationEnable.
  ///
  /// In tr, this message translates to:
  /// **'Konumu aç'**
  String get homeLocationEnable;

  /// No description provided for @homeRiskUnavailable.
  ///
  /// In tr, this message translates to:
  /// **'Risk şu an hesaplanamadı.'**
  String get homeRiskUnavailable;

  /// No description provided for @homeTurkeyLine.
  ///
  /// In tr, this message translates to:
  /// **'Son 24 saat: orman ve doğal alanda {natural} güçlü tespit, tarım ve sanayi alanında {other}.'**
  String homeTurkeyLine(int natural, int other);

  /// No description provided for @homeSeeOnMap.
  ///
  /// In tr, this message translates to:
  /// **'Haritada gör'**
  String get homeSeeOnMap;

  /// No description provided for @homeNewsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Haberler'**
  String get homeNewsTitle;

  /// No description provided for @newsNewBadge.
  ///
  /// In tr, this message translates to:
  /// **'Yeni'**
  String get newsNewBadge;

  /// No description provided for @coachMarksDisableAll.
  ///
  /// In tr, this message translates to:
  /// **'Tüm ipuçlarını kapat'**
  String get coachMarksDisableAll;

  /// No description provided for @settingsTipsTitle.
  ///
  /// In tr, this message translates to:
  /// **'İpuçları'**
  String get settingsTipsTitle;

  /// No description provided for @settingsTipsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Ekranlardaki kısa ipuçlarını göster'**
  String get settingsTipsSubtitle;

  /// No description provided for @pageAboutLink.
  ///
  /// In tr, this message translates to:
  /// **'Bu sayfa hakkında'**
  String get pageAboutLink;

  /// No description provided for @dataSourcesLandCoverTitle.
  ///
  /// In tr, this message translates to:
  /// **'Arazi örtüsü'**
  String get dataSourcesLandCoverTitle;

  /// No description provided for @dataSourcesLandCoverBody.
  ///
  /// In tr, this message translates to:
  /// **'Bir tespitin orman, tarım veya sanayi alanında olduğu ESA WorldCover 2021 haritasından, çevresindeki 750 metrelik alana bakılarak belirlenir. © ESA WorldCover project 2021 / Contains modified Copernicus Sentinel data (2021) processed by ESA WorldCover consortium. Lisans: CC BY 4.0.'**
  String get dataSourcesLandCoverBody;

  /// No description provided for @homeOverviewNewsNoFresh.
  ///
  /// In tr, this message translates to:
  /// **'Yeni haber yok'**
  String get homeOverviewNewsNoFresh;
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
