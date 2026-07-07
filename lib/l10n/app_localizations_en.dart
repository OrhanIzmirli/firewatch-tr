// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'FireWatch TR';

  @override
  String get commonDetail => 'Details';

  @override
  String get commonRefresh => 'Refresh';

  @override
  String get commonViewOnMap => 'View on Map';

  @override
  String get commonOpenOnMap => 'Open on Map';

  @override
  String get commonShare => 'Share';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonTemperature => 'Temperature';

  @override
  String get commonSatellite => 'Satellite';

  @override
  String get commonCoordinate => 'Coordinate';

  @override
  String get commonWind => 'Wind';

  @override
  String get commonRisk => 'Risk';

  @override
  String get commonStatus => 'Status';

  @override
  String get commonAnonymous => 'Anonymous';

  @override
  String get commonAll => 'All';

  @override
  String get commonHigh => 'High';

  @override
  String get commonMedium => 'Medium';

  @override
  String get commonLow => 'Low';

  @override
  String get commonCritical => 'Critical';

  @override
  String get commonEmergency => 'Emergency';

  @override
  String get commonTryAgain => 'Try Again';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonDistance => 'Distance';

  @override
  String get commonDetection => 'Detection';

  @override
  String get regionEge => 'Aegean';

  @override
  String get regionAkdeniz => 'Mediterranean';

  @override
  String get regionMarmara => 'Marmara';

  @override
  String get regionKaradeniz => 'Black Sea';

  @override
  String get regionIcAnadolu => 'Central Anatolia';

  @override
  String get regionDoguAnadolu => 'Eastern Anatolia';

  @override
  String get regionGuneydoguAnadolu => 'Southeastern Anatolia';

  @override
  String get regionTurkiyeGeneli => 'Turkey (General)';

  @override
  String get timeAgoJustNow => 'Just now';

  @override
  String timeAgoMinutes(int minutes) {
    return '$minutes minutes ago';
  }

  @override
  String timeAgoHours(int hours) {
    return '$hours hours ago';
  }

  @override
  String timeAgoDays(int days) {
    return '$days days ago';
  }

  @override
  String get splashTagline => 'Track wildfires, stay safe';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingContinue => 'Continue';

  @override
  String get onboardingTitle1 => 'Track active events';

  @override
  String get onboardingDesc1 =>
      'Follow wildfire events across Turkey on a single screen and see status changes instantly.';

  @override
  String get onboardingTitle2 => 'See regions near you';

  @override
  String get onboardingDesc2 =>
      'Spot nearby events faster with map and region-focused screens.';

  @override
  String get onboardingTitle3 => 'Get safety guidance';

  @override
  String get onboardingDesc3 =>
      'Review risk levels, see recommended actions, and act quickly when needed.';

  @override
  String get homeLiveSummary => 'Live Status Summary';

  @override
  String get homeHeaderTitle => 'Turkey Wildfire Tracking';

  @override
  String get homeHeaderSubtitle =>
      'Track active events, see risk levels, and quickly reach the safety guide.';

  @override
  String get homeNasaLiveData => 'NASA FIRMS • Live Data';

  @override
  String get homeRiskAnalysis => 'Risk Analysis';

  @override
  String homeSaved(int count) {
    return 'Saved ($count)';
  }

  @override
  String get homeSafety => 'Safety';

  @override
  String get homeOverview => 'Overview';

  @override
  String get homeOverviewSubtitle => 'NASA FIRMS live data';

  @override
  String get homeTotalPoints => 'Total Points';

  @override
  String get homeHighRisk => 'High Risk';

  @override
  String get homeNominal => 'Nominal';

  @override
  String get homeLatestNews => 'Latest News';

  @override
  String get homeLatestNewsSubtitle => 'Featured developments';

  @override
  String homeBreakingCount(int count) {
    return '$count breaking';
  }

  @override
  String get homeNewsLoading => 'Loading news...';

  @override
  String get homeActiveThermalPoints => 'Active Thermal Points';

  @override
  String get homeActiveThermalSubtitle => 'NASA FIRMS • PostGIS city detection';

  @override
  String get homeMap => 'Map';

  @override
  String get homeFilterHighRisk => 'High Risk';

  @override
  String get homeFilterMediumRisk => 'Medium Risk';

  @override
  String get homeSearchHint => 'Search city or region...';

  @override
  String get homeNoActiveFires => 'No active fire points found.';

  @override
  String homeFireRegionTitle(String region) {
    return '$region Region';
  }

  @override
  String get homeEstimatedArea => 'Estimated Area';

  @override
  String get homeAreaOver100Ha => 'More than 100 hectares';

  @override
  String get homeArea10to100Ha => '10–100 hectares';

  @override
  String get homeAreaUnder10Ha => 'Less than 10 hectares';

  @override
  String get homeAreaInsufficientRes => 'Insufficient satellite resolution';

  @override
  String get mapFetchError => 'Could not fetch fire data.';

  @override
  String get mapTitle => 'Fire Map';

  @override
  String get mapLiveMap => 'Live Map';

  @override
  String get mapHeaderTitle => 'Turkey-wide Wildfire View';

  @override
  String get mapHeaderSubtitle =>
      'Show active thermal points on the map using NASA FIRMS data.';

  @override
  String get mapArea => 'Map Area';

  @override
  String get mapAreaSubtitle => 'NASA FIRMS live marker view';

  @override
  String get mapGoToMe => 'Go to Me';

  @override
  String get mapNearbyFires => 'Fires Near Me';

  @override
  String get mapNearbyFiresSubtitle =>
      'Live detections closest to your location';

  @override
  String get mapReport => 'Report';

  @override
  String mapKmAway(String distance) {
    return '$distance km away';
  }

  @override
  String get fireDetailTitle => 'Fire Details';

  @override
  String fireDetailLastUpdate(String time) {
    return 'Last update: $time';
  }

  @override
  String get fireDetailKeyMetrics => 'Key Metrics';

  @override
  String get fireDetailEventInfo => 'Event Information';

  @override
  String get fireDetailCity => 'City';

  @override
  String get fireDetailDistrict => 'District';

  @override
  String get fireDetailStarted => 'Started';

  @override
  String get fireDetailSpreadRisk => 'Spread Risk';

  @override
  String get fireDetailAffectedArea => 'Affected Area';

  @override
  String get fireDetailRecommendedActions => 'Recommended Actions';

  @override
  String get fireDetailAddedToWatchlist => 'Event added to your watchlist.';

  @override
  String get fireDetailRemovedFromWatchlist =>
      'Event removed from your watchlist.';

  @override
  String get fireDetailSaved => 'Saved';

  @override
  String get fireDetailSaveToWatchlist => 'Save to Watchlist';

  @override
  String get fireDetailRelatedNews => 'Related News';

  @override
  String get fireDetailNoNewsFound => 'No news found';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String notificationsNewAlerts(int count) {
    return '$count new alerts';
  }

  @override
  String get notificationsUpToDate => 'Up to date';

  @override
  String get notificationsFeedTitle => 'Event Notification Feed';

  @override
  String get notificationsFeedSubtitle =>
      'Track nearby events, status changes, and field updates in one feed.';

  @override
  String get notificationsTools => 'Notification Tools';

  @override
  String get notificationsToolsSubtitle =>
      'Grant permission, run a test, simulate a fire alert';

  @override
  String get notificationsPermissionGranted => 'Permission Granted';

  @override
  String get notificationsPermissionDenied => 'No Permission';

  @override
  String get notificationsMonitoringOn => 'Monitoring On';

  @override
  String get notificationsMonitoringOff => 'Monitoring Off';

  @override
  String get notificationsRequestPermission =>
      'Request Notification Permission';

  @override
  String get notificationsSendTest => 'Send Test Notification';

  @override
  String get notificationsSendDemoFire => 'Send Demo Fire Alert';

  @override
  String get notificationsScanNow => 'Scan Now';

  @override
  String get notificationsStartMonitoring => 'Start Auto Monitoring';

  @override
  String get notificationsStopMonitoring => 'Stop Auto Monitoring';

  @override
  String get notificationsNearbyLiveFires => 'Nearby Live Fires';

  @override
  String get notificationsNearbyLiveFiresSubtitle =>
      'Points within 50 km of your location';

  @override
  String notificationsDistanceAndTime(String distance, String timeAgo) {
    return '$distance km away • $timeAgo';
  }

  @override
  String notificationsRiskLabel(String level) {
    return 'Risk: $level';
  }

  @override
  String get notificationsRecentAlerts => 'Recent Alerts';

  @override
  String notificationsHighRiskCount(int count) {
    return '$count high-risk points';
  }

  @override
  String notificationsUnreadCount(int count) {
    return '$count unread';
  }

  @override
  String get notificationsNoHighRisk => 'No high-risk fire points right now.';

  @override
  String get notificationsHighRiskDetectionTitle =>
      'High-Risk Thermal Detection';

  @override
  String notificationsHighRiskDetectionBody(String region, String temp) {
    return '${temp}K heat detected in the $region region. High likelihood of an active fire.';
  }

  @override
  String get watchlistTitle => 'Saved';

  @override
  String get watchlistClear => 'Clear';

  @override
  String get watchlistNoRecords => 'No Records';

  @override
  String watchlistRecordCount(int count) {
    return '$count records';
  }

  @override
  String get watchlistHeading => 'Watchlist';

  @override
  String get watchlistHeadingSubtitle =>
      'You can keep track of the fire points you want to follow here.';

  @override
  String get watchlistEmptyTitle => 'No saved events yet';

  @override
  String get watchlistEmptySubtitle =>
      'You can add one using the Save button on the fire details screen.';

  @override
  String get watchlistSavedPoints => 'Saved Points';

  @override
  String watchlistSavedPointsSubtitle(int count) {
    return '$count fire points being tracked';
  }

  @override
  String watchlistSyncingTitle(int count) {
    return 'You have $count saved fire points.';
  }

  @override
  String get watchlistSyncingSubtitle =>
      'NASA data may be refreshing. Saved points can change with satellite updates.';

  @override
  String emergencyShareLocationText(String url, String lat, String lng) {
    return '🔥 Emergency - My Location:\n$url\n\nLat: $lat\nLng: $lng\n\nShared via FireWatch TR.';
  }

  @override
  String get emergencyShareLocationSubject => 'Emergency Location Share';

  @override
  String get emergencyShareFallbackText => '🔥 Emergency notice - FireWatch TR';

  @override
  String get emergencyTitle => 'Emergency';

  @override
  String get emergencyPrepCenter => 'Emergency Prep Center';

  @override
  String get emergencyQuickToolsTitle => 'Quick Response Tools';

  @override
  String get emergencyQuickToolsSubtitle =>
      'Gather quick access, basic preparation, and critical guidance in one screen for emergencies.';

  @override
  String get emergencyStayReady => 'Stay Ready';

  @override
  String get emergencyStayReadyNote =>
      'Planning evacuation and contact steps in advance saves time.';

  @override
  String get emergencyQuickActions => 'Quick Actions';

  @override
  String get emergencyQuickActionsSubtitle => 'Critical actions in one tap';

  @override
  String get emergencyCall112 => 'Call 112';

  @override
  String get emergencyCall112Subtitle => 'General emergency helpline';

  @override
  String get emergencyCall177 => 'Call 177 Forestry';

  @override
  String get emergencyCall177Subtitle => 'Fire reporting line';

  @override
  String get emergencyShareLocation => 'Share Location';

  @override
  String get emergencyShareLocationSubtitle => 'Let others know where you are';

  @override
  String get emergencyEvacuationPlan => 'Evacuation Plan';

  @override
  String get emergencyEvacuationPlanSubtitle => 'Review your exit steps';

  @override
  String get emergencyContactLines => 'Emergency Contact Lines';

  @override
  String get emergencyContactLinesSubtitle =>
      'Keep the essential numbers handy';

  @override
  String get emergencyCallCenter => 'Emergency Call Center';

  @override
  String get emergencyCallCenterSubtitle =>
      'Health, fire department, police, and general emergencies';

  @override
  String get emergencyForestLine => 'Forest Fire Line';

  @override
  String get emergencyForestLineSubtitle =>
      'Quick access for forest and wildfire reports';

  @override
  String get emergencyAfad => 'AFAD Emergency';

  @override
  String get emergencyAfadSubtitle => 'Disaster and emergency management';

  @override
  String get emergencyBag => 'Evacuation Bag';

  @override
  String get emergencyBagSubtitle => 'Keep it ready';

  @override
  String get emergencyBagDocs => 'ID and essential documents';

  @override
  String get emergencyBagDocsSubtitle =>
      'Keep your ID, important papers, and phone in one place.';

  @override
  String get emergencyBagSupplies => 'Water, medicine, and charging gear';

  @override
  String get emergencyBagSuppliesSubtitle =>
      'Essentials that matter most in a short-term evacuation.';

  @override
  String get emergencyBagMeetingPoint => 'Meeting point with family';

  @override
  String get emergencyBagMeetingPointSubtitle =>
      'Decide in advance in case you get separated.';

  @override
  String get emergencyCommNote => 'Communication Note';

  @override
  String get emergencyCommNoteSubtitle =>
      'A short action plan for a panic moment';

  @override
  String get emergencyStep1 => '1. Verify official warnings';

  @override
  String get emergencyStep2 => '2. Notify loved ones with a short message';

  @override
  String get emergencyStep3 =>
      '3. If needed, grab your essentials bag and head to a safe exit route';

  @override
  String get safetyGuideTitle => 'Safety Guide';

  @override
  String get safetyGuideEmergencyInfo => 'Emergency Information';

  @override
  String get safetyGuideCenterTitle => 'Fire Safety Center';

  @override
  String get safetyGuideCenterSubtitle =>
      'A guide screen prepared to help you quickly understand what to do during a fire, grasp evacuation logic, and follow the right steps.';

  @override
  String get safetyGuideQuickActions => 'Quick Actions';

  @override
  String get safetyGuideQuickActionsSubtitle =>
      'Critical behaviors at a glance';

  @override
  String get safetyGuideReadyEvacuate => 'Be Ready to Evacuate';

  @override
  String get safetyGuideReadyEvacuateSubtitle => 'Clarify your exit plan';

  @override
  String get safetyGuideTakeSmokeSeriously => 'Take Smoke Seriously';

  @override
  String get safetyGuideTakeSmokeSeriouslySubtitle =>
      'Move indoors, use a mask';

  @override
  String get safetyGuideFollowOfficials => 'Follow Official Announcements';

  @override
  String get safetyGuideFollowOfficialsSubtitle => 'Track official sources';

  @override
  String get safetyGuideDontDelay => 'Don\'t Delay';

  @override
  String get safetyGuideDontDelaySubtitle =>
      'Don\'t put off an evacuation call';

  @override
  String get safetyGuideChecklist => 'Emergency Checklist';

  @override
  String get safetyGuideChecklistSubtitle => 'Basic steps during a fire';

  @override
  String get safetyGuideChecklist1Title =>
      'Keep your ID, phone, and charger ready';

  @override
  String get safetyGuideChecklist1Desc =>
      'Gather essential items in one place.';

  @override
  String get safetyGuideChecklist2Title => 'Check doors and windows';

  @override
  String get safetyGuideChecklist2Desc =>
      'Review openings to reduce smoke ingress.';

  @override
  String get safetyGuideChecklist3Title =>
      'Set a meeting plan with family/loved ones';

  @override
  String get safetyGuideChecklist3Desc =>
      'Know in advance where to meet if you get separated.';

  @override
  String get safetyGuideChecklist4Title =>
      'Follow the official evacuation route';

  @override
  String get safetyGuideChecklist4Desc =>
      'Don\'t improvise a risky route on your own.';

  @override
  String get safetyGuideDetailedGuide => 'Detailed Guide';

  @override
  String get safetyGuideDetailedGuideSubtitle =>
      'Expandable info cards by scenario';

  @override
  String get safetyGuideAtHomeTitle => 'What to do if you\'re at home?';

  @override
  String get safetyGuideAtHome1 =>
      'Keep doors and windows closed if smoke is heavy.';

  @override
  String get safetyGuideAtHome2 =>
      'Check electricity, gas, and a quick exit route.';

  @override
  String get safetyGuideAtHome3 =>
      'If an evacuation call comes, don\'t waste time packing — focus on getting out.';

  @override
  String get safetyGuideAtHome4 =>
      'Move pets to a safe carrier quickly if possible.';

  @override
  String get safetyGuideInCarTitle => 'What to do if you\'re in a car?';

  @override
  String get safetyGuideInCar1 => 'Don\'t try to drive through heavy smoke.';

  @override
  String get safetyGuideInCar2 =>
      'Head to a safe open area or settlement if possible.';

  @override
  String get safetyGuideInCar3 =>
      'Don\'t leave the car near dry grass or under trees.';

  @override
  String get safetyGuideInCar4 =>
      'Follow official guidance, not navigation apps, if directed.';

  @override
  String get safetyGuideOutsideTitle => 'What to do if you\'re outside?';

  @override
  String get safetyGuideOutside1 =>
      'Watch the wind direction and stay ahead of the fire.';

  @override
  String get safetyGuideOutside2 =>
      'Move away from dense vegetation and narrow valleys.';

  @override
  String get safetyGuideOutside3 => 'If moving as a group, stay together.';

  @override
  String get safetyGuideOutside4 =>
      'In an emergency, head to open, bare, non-flammable ground.';

  @override
  String get safetyGuideEvacOrderTitle =>
      'What to do if an evacuation order arrives?';

  @override
  String get safetyGuideEvacOrder1 =>
      'Don\'t delay — avoid thinking \"I\'ll wait a bit longer.\"';

  @override
  String get safetyGuideEvacOrder2 =>
      'Take only the essentials and focus on getting out.';

  @override
  String get safetyGuideEvacOrder3 =>
      'Don\'t waste time calling everyone individually — use a plan set in advance.';

  @override
  String get safetyGuideEvacOrder4 =>
      'Follow officials\' announcements about the assembly point.';

  @override
  String get safetyGuideEmergencyNumbers => 'Emergency Numbers';

  @override
  String get safetyGuideEmergencyNumbersSubtitle =>
      'Note these down for quick access';

  @override
  String get safetyGuideCallCenterSubtitle => 'General emergency line';

  @override
  String get safetyGuideForestNotice => 'Forest Fire Report';

  @override
  String get safetyGuideForestNoticeSubtitle => 'Forest and fire line';

  @override
  String get safetyGuideAfadLocal => 'AFAD / Local Guidance';

  @override
  String get safetyGuideAfadLocalNumber => 'Follow local announcements';

  @override
  String get safetyGuideAfadLocalSubtitle =>
      'Regional announcements and guidance matter';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsPreferences => 'Preferences';

  @override
  String get settingsAppSettings => 'App Settings';

  @override
  String get settingsAppSettingsSubtitle =>
      'Customize notifications, location-based alerts, and app behavior here.';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsSubtitle => 'Manage alert preferences';

  @override
  String get settingsPushNotifications => 'Push Notifications';

  @override
  String get settingsPushNotificationsSubtitle =>
      'Get notified about new events and important changes';

  @override
  String get settingsNearbyAlerts => 'Nearby Event Alerts';

  @override
  String get settingsNearbyAlertsSubtitle =>
      'Prioritize showing events near your location';

  @override
  String get settingsAppBehavior => 'App Behavior';

  @override
  String get settingsAppBehaviorSubtitle => 'Appearance and refresh frequency';

  @override
  String get settingsDarkMode => 'Dark Theme';

  @override
  String get settingsDarkModeSubtitle => 'Keep the premium dark look active';

  @override
  String get settingsRefreshInterval => 'Data Refresh Interval';

  @override
  String get settingsRefreshIntervalSubtitle =>
      'Choose how often field data refreshes';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSubtitle => 'Choose the app language';

  @override
  String get settingsLanguageTurkish => 'Türkçe';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsAppInfo => 'App Information';

  @override
  String get settingsAppInfoSubtitle => 'Version and product summary';

  @override
  String get settingsInfoApp => 'App';

  @override
  String get settingsInfoVersion => 'Version';

  @override
  String get settingsInfoVersionValue => 'v1.0.0 demo';

  @override
  String get settingsInfoPlatform => 'Platform';

  @override
  String get settingsInfoPlatformValue => 'Flutter / Android';

  @override
  String get settingsInfoPurpose => 'Purpose';

  @override
  String get settingsInfoPurposeValue => 'Fire-focused disaster tracking';

  @override
  String get settingsFooterNote =>
      'Your preferences are stored on your device and applied automatically each time you open the app.';

  @override
  String get riskTitle => 'Risk Analysis';

  @override
  String get riskLiveView => 'Live Risk View';

  @override
  String get riskSummaryTitle => 'Turkey Wildfire Risk Summary';

  @override
  String get riskSummarySubtitle =>
      'Real-time risk analysis calculated from Open-Meteo weather data and NASA FIRMS satellite data.';

  @override
  String riskHighestRisk(String region, int score) {
    return 'Highest risk: $region ($score/100)';
  }

  @override
  String get riskDataLoading => 'Loading data...';

  @override
  String get riskKeyIndicators => 'Key Indicators';

  @override
  String get riskTurkeyAverage => 'Turkey average';

  @override
  String get riskGeneralRisk => 'Overall Risk';

  @override
  String get riskOutOf100 => 'out of 100';

  @override
  String get riskWindIncreasesSpread => 'Increasing spread';

  @override
  String get riskWindNormal => 'Normal level';

  @override
  String get riskHumidity => 'Humidity';

  @override
  String get riskHumidityLow => 'Low humidity';

  @override
  String get riskHumidityMedium => 'Medium humidity';

  @override
  String get riskHumidityHigh => 'High humidity';

  @override
  String get riskTempCritical => 'Critical level';

  @override
  String get riskTempNormal => 'Normal';

  @override
  String get riskRegionalDistribution => 'Regional Risk Distribution';

  @override
  String get riskRegionalDistributionSubtitle => 'Current regional scores';

  @override
  String get riskScore => 'Risk Score';

  @override
  String get riskRegionDetails => 'Region Details';

  @override
  String get riskRegionDetailsSubtitle => 'Real weather data';

  @override
  String riskScoreOutOf100(int score) {
    return 'Risk score: $score/100';
  }

  @override
  String get riskEnvironmentalFactors => 'Environmental Factors';

  @override
  String get riskDrynessIndex => 'Dryness Index';

  @override
  String get riskDrynessVeryHigh => 'Very high';

  @override
  String get riskWindPressure => 'Wind Pressure';

  @override
  String get riskVegetationDensity => 'Vegetation Density';

  @override
  String get riskVegetationMediumHigh => 'Medium - High';

  @override
  String get riskHumidityLevel => 'Humidity Level';

  @override
  String riskNoteHighTemp(int temp) {
    return 'High temperature ($temp°C)';
  }

  @override
  String riskNoteMildTemp(int temp) {
    return 'Mild weather ($temp°C)';
  }

  @override
  String riskNoteCoolTemp(int temp) {
    return 'Cool weather ($temp°C)';
  }

  @override
  String riskNoteLowHumidity(int hum) {
    return 'Low humidity ($hum%)';
  }

  @override
  String riskNoteMediumHumidity(int hum) {
    return 'Medium humidity ($hum%)';
  }

  @override
  String riskNoteHighHumidity(int hum) {
    return 'High humidity ($hum%)';
  }

  @override
  String riskNoteStrongWind(int wind) {
    return 'Strong wind (${wind}km/h)';
  }

  @override
  String riskNoteMediumWind(int wind) {
    return 'Moderate wind (${wind}km/h)';
  }

  @override
  String get newsTitle => 'News';

  @override
  String get newsLiveFeed => 'Live News Feed';

  @override
  String get newsCenterTitle => 'Wildfire News Center';

  @override
  String get newsCenterSubtitle =>
      'Track field updates, risk alerts, and safety-focused developments in one feed.';

  @override
  String get newsFeatured => 'Featured Story';

  @override
  String get newsFeaturedSubtitle => 'Today\'s most notable headline';

  @override
  String get newsCategories => 'Categories';

  @override
  String get newsCategoriesSubtitle => 'Filter the feed';

  @override
  String get newsCategoryRisk => 'Risk';

  @override
  String get newsCategoryOperation => 'Operation';

  @override
  String get newsCategorySafety => 'Safety';

  @override
  String get newsCategoryUpdate => 'Update';

  @override
  String get newsRegions => 'Regions';

  @override
  String get newsRegionsSubtitle => 'Filter by region';

  @override
  String get newsLatest => 'Latest News';

  @override
  String newsRecordsFound(int count) {
    return '$count records found';
  }

  @override
  String get newsFetchFailed => 'Failed to load news';

  @override
  String newsNoneInRegion(String region) {
    return 'No news in $region.';
  }

  @override
  String get newsNoneInCategory => 'No news in this category.';

  @override
  String get reportPanelLocationServiceOff =>
      'Location service is off. Please turn it on.';

  @override
  String get reportPanelLocationPermissionDenied =>
      'Location permission denied.';

  @override
  String reportPanelLocationError(String error) {
    return 'Couldn\'t get location: $error';
  }

  @override
  String get reportPanelNeedLocationFirst => 'Please get your location first.';

  @override
  String get reportPanelSmokeObserved => 'Heavy smoke observed';

  @override
  String get reportPanelStrongWindPresent => 'Strong wind present';

  @override
  String get reportPanelNearSettlementNote => 'Near a settlement';

  @override
  String reportPanelRiskLevelLine(String level) {
    return 'Risk level: $level';
  }

  @override
  String reportPanelCityFireReport(String city) {
    return '$city fire report';
  }

  @override
  String get reportPanelFireReport => 'Fire report';

  @override
  String get reportPanelVerifiedTitle => '✅ Report Verified';

  @override
  String get reportPanelReceivedTitle => '⏳ Report Received';

  @override
  String reportPanelCityLabel(String city) {
    return 'City: $city';
  }

  @override
  String get reportPanelSubmitFailed =>
      'Couldn\'t submit the report. Check your internet connection.';

  @override
  String get reportPanelOk => 'OK';

  @override
  String get reportPanelNewReport => 'New Report';

  @override
  String get reportPanelTitle => 'Report a Fire';

  @override
  String get reportPanelSubtitle =>
      'Get your GPS location and report the fire. It will be auto-verified against NASA data.';

  @override
  String get reportPanelLocation => 'Location';

  @override
  String get reportPanelLocationObtained => 'Location obtained';

  @override
  String get reportPanelNoLocationYet => 'No location yet';

  @override
  String get reportPanelGetGpsLocation => 'Get GPS Location';

  @override
  String get reportPanelRefreshLocation => 'Refresh Location';

  @override
  String get reportPanelRiskLevel => 'Risk Level';

  @override
  String get reportPanelYourName => 'Your name (optional)';

  @override
  String get reportPanelAnonymousHint => 'Will be submitted anonymously';

  @override
  String get reportPanelExtraNote => 'Additional Note';

  @override
  String get reportPanelNoteHint =>
      'Flame height, smoke density, road conditions...';

  @override
  String get reportPanelSmokeSwitch => 'Heavy smoke observed';

  @override
  String get reportPanelWindSwitch => 'Wind appears strong';

  @override
  String get reportPanelSettlementSwitch => 'Near a settlement';

  @override
  String get reportPanelSubmitting => 'Submitting...';

  @override
  String get reportPanelSubmit => 'Submit Report';

  @override
  String offlineBannerLabel(String time) {
    return 'Offline mode • Last updated: $time';
  }

  @override
  String get errorStateTitle => 'Something went wrong';

  @override
  String get errorStateGeneric => 'Couldn\'t load data. Please try again.';

  @override
  String get emptyStateGenericTitle => 'Nothing to show';

  @override
  String get emptyStateGenericSubtitle =>
      'There\'s nothing here to display right now.';

  @override
  String get notifPermTitle => 'Don\'t miss important alerts';

  @override
  String get notifPermSubtitle =>
      'With notification permission, you\'ll instantly learn about nearby wildfire events and critical status changes.';

  @override
  String get notifPermNote =>
      'This permission isn\'t required. You can skip it for now and still use the app.';

  @override
  String get notifPermEnable => 'Enable Notifications';

  @override
  String get notifPermSkip => 'Skip for Now';

  @override
  String get notifPermGranted => 'Notification permission granted. Thanks!';

  @override
  String get notifPermDenied =>
      'Notification permission denied. You can enable it later in Settings.';

  @override
  String get locPermServiceOff =>
      'Location service appears to be off. You can still continue using the app.';

  @override
  String get locPermDenied =>
      'Location permission denied. You can continue without location for now.';

  @override
  String get locPermDeniedForever =>
      'Location permission was permanently denied. You can enable it in Settings.';

  @override
  String get locPermError =>
      'Something went wrong getting location permission. You can skip for now.';

  @override
  String get locPermTitle => 'Let\'s show you nearby events';

  @override
  String get locPermSubtitle =>
      'With location access, we can show wildfire events, risky regions, and more relevant alerts near you.';

  @override
  String get locPermNote =>
      'This permission isn\'t required. You can skip it for now and still use the app.';

  @override
  String get locPermEnable => 'Enable Location';

  @override
  String get locPermSkip => 'Skip for Now';

  @override
  String get compassNorth => 'N';

  @override
  String get compassSouth => 'S';

  @override
  String get compassEast => 'E';

  @override
  String get compassWest => 'W';

  @override
  String riskReasonHighWithTemp(String temp) {
    return 'Thermal sensor detected ${temp}K heat. High likelihood of an active fire — stay away from the area.';
  }

  @override
  String get riskReasonHighNoTemp =>
      'A high-confidence thermal anomaly was detected. This may be an active fire.';

  @override
  String riskReasonMediumWithTemp(String temp) {
    return 'Thermal sensor measured ${temp}K heat. This could be stubble burning, farming activity, or an early-stage fire.';
  }

  @override
  String get riskReasonMediumNoTemp =>
      'A medium-level thermal anomaly. The area should be kept under observation.';

  @override
  String riskReasonLowWithTemp(String temp) {
    return 'Low heat value (${temp}K). Could be industrial activity, greenhouses, or a natural heat source.';
  }

  @override
  String get riskReasonLowNoTemp =>
      'Low-level thermal activity. Monitoring is recommended.';

  @override
  String get fireGeneratedDescHigh =>
      'High-intensity thermal activity. Strong likelihood of an active fire.';

  @override
  String get fireGeneratedDescMedium =>
      'Moderate heat increase. The area needs monitoring.';

  @override
  String get fireGeneratedDescLow =>
      'Low-level thermal activity. Monitoring is recommended.';

  @override
  String get fireRecommendedActionHigh =>
      'Stay away from the area, follow official guidance, and prepare for possible evacuation.';

  @override
  String get fireRecommendedActionMedium =>
      'Keep track of developments and avoid getting close to the area unnecessarily.';

  @override
  String get fireRecommendedActionLow =>
      'No urgent action needed right now — keep an eye on the area.';

  @override
  String fireEventRegionTitle(String city) {
    return '$city Region Thermal Detection';
  }

  @override
  String get fireEventLiveDetectionTitle => 'Live Fire Detection';

  @override
  String get fireEventStatusActive => 'Active';

  @override
  String get fireEventStatusMonitoring => 'Monitoring';

  @override
  String get fireEventStatusControlled => 'Under Control';

  @override
  String get fireEventSpreadHigh => 'High — active monitoring required';

  @override
  String get fireEventSpreadMedium => 'Medium — monitor carefully';

  @override
  String get fireEventSpreadLow => 'Low';

  @override
  String get fireEventWindStatus => 'Check the map for real wind data';

  @override
  String get fireEventAreaLarge => 'Large area (>100 hectares estimated)';

  @override
  String get fireEventAreaMedium => 'Medium area (10-100 hectares estimated)';

  @override
  String get fireEventAreaSmall => 'Small area (<10 hectares estimated)';

  @override
  String fireEventTempLine(String temp, String kelvin) {
    return 'Temperature: $temp°C (Thermal value: ${kelvin}K)';
  }

  @override
  String fireEventSatelliteLine(String satellite) {
    return 'Satellite: $satellite';
  }

  @override
  String fireEventCoordinateLine(String coordinate) {
    return 'Coordinate: $coordinate';
  }

  @override
  String fireEventDetectionLine(String datetime) {
    return 'Detected: $datetime';
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
    return '🔥 Fire Alert\n\n📍 $title\n📌 $city / $district\n\n🚨 Status: $status\n⚠️ Risk: $risk\n\n📝 $description\n\nTracked with FireWatch TR.';
  }

  @override
  String get notificationsDemoAlertTitle => 'Critical Fire Alert';

  @override
  String notificationsDemoAlertBody(String region) {
    return 'High-risk thermal activity detected in the $region region.';
  }

  @override
  String get settingsRefreshInterval5Min => '5 min';

  @override
  String get settingsRefreshInterval15Min => '15 min';

  @override
  String get settingsRefreshInterval30Min => '30 min';

  @override
  String get settingsRefreshInterval60Min => '60 min';

  @override
  String get newsDetailTitle => 'News Detail';

  @override
  String get newsDetailHighlightsTitle => 'Highlights';

  @override
  String get newsDetailHighlightsSubtitle => 'Quick summary';

  @override
  String get newsDetailFullContentTitle => 'Full Content';

  @override
  String get newsDetailFullContentSubtitle => 'Full story summary';

  @override
  String get newsDetailRelatedRegionTitle => 'Related Region';

  @override
  String get newsDetailRelatedRegionSubtitle => 'Linked risk area';

  @override
  String get newsDetailRelatedRegionNote =>
      'This development may be linked to the region\'s risk and operations flow.';

  @override
  String newsDetailReadMinutes(int minutes) {
    return '$minutes min read';
  }

  @override
  String get newsTranslate => 'Translate';

  @override
  String get newsTranslating => 'Translating...';

  @override
  String get newsTranslated => 'Translated';

  @override
  String get newsShowOriginal => 'Show Original';

  @override
  String get newsTranslationFailed => 'Translation failed.';

  @override
  String get coachMarksGotIt => 'Got it';

  @override
  String get coachMarksSkip => 'Skip tutorial';

  @override
  String get coachMarksNext => 'Next';

  @override
  String coachMarksStepCount(int current, int total) {
    return '$current/$total';
  }

  @override
  String get coachMarkMapTitle => 'Map & Fire Markers';

  @override
  String get coachMarkMapDesc =>
      'Flame markers on the map show live fire detections from NASA satellite data. Tap a marker to see details — you can also report a new fire from the map screen.';

  @override
  String get coachMarkRiskTitle => 'Risk Levels';

  @override
  String get coachMarkRiskDesc =>
      'Every fire point is labeled High, Medium, or Low risk. These tags help you quickly understand how dangerous an area is.';

  @override
  String get coachMarkWatchlistTitle => 'Watchlist';

  @override
  String get coachMarkWatchlistDesc =>
      'Save fire points you want to keep an eye on, and quickly find them again here.';

  @override
  String get coachMarkNotificationsTitle => 'Notifications';

  @override
  String get coachMarkNotificationsDesc =>
      'Get instant alerts for fires near you, and start automatic scanning from here.';

  @override
  String get riskTabTurkeyOverview => 'Turkey Overview';

  @override
  String get riskTabMyLocation => 'My Location';

  @override
  String get riskMyLocationGettingLocation => 'Getting your location...';

  @override
  String get riskMyLocationPermissionDenied =>
      'Location permission denied. Allow access to see your region\'s risk info.';

  @override
  String get riskMyLocationServiceOff =>
      'Location service is off. Please enable it.';

  @override
  String get riskMyLocationError =>
      'Couldn\'t get your location. Please try again.';

  @override
  String get riskMyLocationRegionNotFound =>
      'Your region wasn\'t found in the risk data.';

  @override
  String get riskMyLocationEnableButton => 'Enable Location';

  @override
  String riskMyLocationYourRegion(String city, String region) {
    return 'Your region: $city ($region)';
  }

  @override
  String riskMyLocationRankLabel(int rank) {
    return 'Rank: $rank/7';
  }

  @override
  String riskMyLocationVsAverage(String diff) {
    return 'Compared to Turkey average: $diff';
  }

  @override
  String get riskMyLocationMetricsTitle => 'Your Region\'s Data';

  @override
  String get riskChartTapHint => 'Tap a region for details';

  @override
  String get monitorStatusReady => 'Monitoring service ready.';

  @override
  String get monitorStatusAlreadyRunning =>
      'Automatic scanning is already running.';

  @override
  String get monitorStatusStarted => 'Automatic scanning started...';

  @override
  String get monitorStatusStopped => 'Automatic scanning stopped.';

  @override
  String get monitorStatusGettingLocation => 'Getting location...';

  @override
  String get monitorStatusLocationServiceOff =>
      'Location service is off. Please turn it on.';

  @override
  String get monitorStatusLocationDenied => 'Location permission denied.';

  @override
  String get monitorStatusFetchingData => 'Fetching NASA FIRMS data...';

  @override
  String get monitorStatusNoActiveFires =>
      'No active fire data found right now.';

  @override
  String monitorStatusNoNearbyFires(int count) {
    return '✅ No live fire detections within 50 km. ($count points scanned)';
  }

  @override
  String monitorStatusNearbyFiresFound(int count) {
    return '⚠️ $count fire points found within 50 km!';
  }

  @override
  String get monitorStatusTimeout =>
      'NASA API connection timed out. Check your internet connection.';

  @override
  String get monitorStatusLocationFailed =>
      'Couldn\'t get location. Please try again.';

  @override
  String monitorStatusScanFailed(String error) {
    return 'Scan failed: $error';
  }

  @override
  String get notifNearbyFireTitle => 'Fire detected nearby';

  @override
  String notifNearbyFireBody(String distance, int count) {
    return '$count fire points found within $distance.';
  }

  @override
  String get notifTestBody => 'Test notification ready.';

  @override
  String get notifNewNotificationBody => 'New notification';
}
