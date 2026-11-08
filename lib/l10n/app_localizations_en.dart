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
  String get navHome => 'Home';

  @override
  String get navMap => 'Map';

  @override
  String get navNews => 'News';

  @override
  String get navAlerts => 'Alerts';

  @override
  String get navSettings => 'Settings';

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
  String get commonSave => 'Save';

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
      'Follow satellite detections across Türkiye on a single screen and see changes quickly.';

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
  String get homeLiveSummary => 'Latest Status Summary';

  @override
  String get homeHeaderTitle => 'Satellite Detections in Türkiye';

  @override
  String get homeHeaderSubtitle =>
      'Track active events, see risk levels, and quickly reach the safety guide.';

  @override
  String get homeNasaLiveData => 'NASA FIRMS • Satellite Data';

  @override
  String get homeOutsideTurkeyLocation => 'Outside Turkey';

  @override
  String get homeLocationUnavailable => 'Location unavailable';

  @override
  String get homeLocationEmulatorTest => 'Emulator test location';

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
  String get homeOverviewSubtitle => 'NASA FIRMS satellite data';

  @override
  String homeOverviewUniqueCount(int count) {
    return 'Satellites made detections at $count separate locations';
  }

  @override
  String get homeTotalPoints => 'Total Points';

  @override
  String get homeHighRisk => 'High Risk';

  @override
  String get homeNominal => 'Nominal';

  @override
  String get homeOverviewActiveFiresTitle => 'Recent Satellite Detections';

  @override
  String get homeOverviewActiveFiresSubtitle => 'Detected in last 24 hours';

  @override
  String get homeOverviewHighestRiskTitle => 'Highest Risk Region';

  @override
  String homeOverviewHighestRiskValue(String region, int score) {
    return '$region - $score pts';
  }

  @override
  String get homeOverviewHighestRiskSubtitle =>
      'Highest risk in Turkey right now';

  @override
  String get homeOverviewNearbyTitle => 'Nearby Satellite Detections';

  @override
  String homeOverviewNearbyValueWithLocation(int count) {
    return '$count detections within 100km';
  }

  @override
  String homeOverviewNearbyValueNationwide(int count) {
    return '$count detections nationwide';
  }

  @override
  String get homeOverviewNearbySubtitleLocated => 'Based on your GPS location';

  @override
  String get homeOverviewNearbySubtitleFallback =>
      'Location unavailable — showing nationwide count';

  @override
  String get homeOverviewNewsTitle => 'News Update';

  @override
  String homeOverviewNewsValue(int count) {
    return '$count new articles';
  }

  @override
  String homeOverviewNewsSubtitleUpdated(String timeAgo) {
    return 'Latest: $timeAgo';
  }

  @override
  String get homeOverviewNewsNone => 'No news yet';

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
  String get homeActiveThermalPoints => 'Recent Satellite Detections';

  @override
  String get homeActiveThermalSubtitle => 'NASA satellite data';

  @override
  String get homeMap => 'Map';

  @override
  String get homeFilterHighRisk => 'High Risk';

  @override
  String get homeFilterMediumRisk => 'Medium Risk';

  @override
  String get homeSearchHint => 'Search city or region...';

  @override
  String get homeNoActiveFires =>
      'Satellites report no recent detections right now.';

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
  String get mapTitle => 'Satellite Detection Map';

  @override
  String get mapTitleEvents => 'Fire Map';

  @override
  String get mapTitleDetections => 'Satellite Detection Map';

  @override
  String get mapLiveMap => 'Latest Map';

  @override
  String get mapConfidenceFilterActive =>
      'Showing only high/nominal confidence detections';

  @override
  String get mapConfidenceFilterClear => 'Clear';

  @override
  String get mapHeaderTitle => 'Nationwide Fire View';

  @override
  String get mapHeaderSubtitle =>
      'NASA FIRMS satellite data. Events and raw detections.';

  @override
  String get mapArea => 'Map Area';

  @override
  String get mapAreaSubtitle => 'NASA FIRMS marker view';

  @override
  String get mapGoToMe => 'Go to Me';

  @override
  String get mapNearbyFires => 'Satellite Detections Near Me';

  @override
  String get mapNearbyFiresSubtitle =>
      'Latest detections closest to your location';

  @override
  String get mapReport => 'Report';

  @override
  String mapKmAway(String distance) {
    return '$distance km away';
  }

  @override
  String get fireDetailTitle => 'Detection Details';

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
      'Manage permission and automatic detection monitoring';

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
  String get notificationsScanNow => 'Scan Now';

  @override
  String get notificationsStartMonitoring => 'Start Auto Monitoring';

  @override
  String get notificationsStopMonitoring => 'Stop Auto Monitoring';

  @override
  String get notificationsBackgroundTitle => 'Background Monitoring';

  @override
  String get notificationsBackgroundSubtitle =>
      'Check satellite detections at intervals while the app is closed. Android can delay these checks, and satellite data can be hours late.';

  @override
  String get notificationsEnableBackground => 'Enable Background Monitoring';

  @override
  String get notificationsDisableBackground => 'Disable Background Monitoring';

  @override
  String get backgroundLocationDialogTitle => 'Background Location Permission';

  @override
  String get backgroundLocationDialogBody =>
      'FireWatch TR wants to access your location in the background so it can check for nearby fires and alert you even when the app is closed. These checks run on your phone; your location is not sent to the server during them. If you don\'t grant this, the app can only scan while it\'s open. On the system permission screen, choose \"Allow all the time\".';

  @override
  String get backgroundLocationDialogConfirm => 'Continue';

  @override
  String get backgroundLocationPermissionDenied =>
      'Background location permission was not granted. Background monitoring could not be enabled.';

  @override
  String get backgroundMonitoringEnabled => 'Background monitoring enabled.';

  @override
  String get backgroundMonitoringDisabled => 'Background monitoring disabled.';

  @override
  String get notificationsNearbyLiveFires => 'Nearby Satellite Detections';

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
  String get notificationsNoHighRisk =>
      'Satellites report no strong detections right now.';

  @override
  String get notificationsHighRiskDetectionTitle =>
      'Strong Satellite Detection';

  @override
  String notificationsHighRiskDetectionBody(String region, String temp) {
    return 'Satellites detected strong heat in the $region region (${temp}K). Not verified.';
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
      'You can keep track of the satellite detections you want to follow here.';

  @override
  String get watchlistEmptyTitle => 'No saved events yet';

  @override
  String get watchlistEmptySubtitle =>
      'You can add one using the Save button on the fire details screen.';

  @override
  String get watchlistSavedPoints => 'Saved Points';

  @override
  String watchlistSavedPointsSubtitle(int count) {
    return '$count satellite detections being tracked';
  }

  @override
  String watchlistSyncingTitle(int count) {
    return 'You have $count saved satellite detections.';
  }

  @override
  String get watchlistSyncingSubtitle =>
      'NASA data may be refreshing. Saved points can change with satellite updates.';

  @override
  String emergencyShareLocationText(String url, String lat, String lng) {
    return 'Emergency - My Location:\n$url\n\nLat: $lat\nLng: $lng\n\nShared via FireWatch TR.';
  }

  @override
  String get emergencyShareLocationSubject => 'Emergency Location Share';

  @override
  String get emergencyShareFallbackText => 'Emergency notice - FireWatch TR';

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
  String get dataSourcesTitle => 'Data sources';

  @override
  String get dataSourcesEntry => 'Data sources';

  @override
  String get dataSourcesEntrySubtitle =>
      'Where the numbers come from, and what they do not mean';

  @override
  String get dataSourcesSatelliteTitle => 'Satellite detections — measured';

  @override
  String get dataSourcesSatelliteBody =>
      'NASA FIRMS. VIIRS (NOAA-20, NOAA-21; Suomi-NPP stopped delivering data on 2 November 2026) and MODIS (Terra, Aqua), passing over several times a day. Each detection is one hot pixel: its position, radiative power (FRP, in megawatts), brightness temperature and NASA\'s own confidence tier are measured values. An event\'s panel lists which product contributed how many detections.';

  @override
  String get dataSourcesGroupingTitle => 'Events — computed';

  @override
  String get dataSourcesGroupingBody =>
      'Pixels of the same fire are clustered within 1.2 km across passes into a single event. Duration, pass count and peak power come from that grouping. Duration is capped by the two-day data window, which is why it is always written as \"at least\" — a source burning for a month still reports about a day.';

  @override
  String get dataSourcesDerivedTitle => 'Derived — not measured';

  @override
  String get dataSourcesDerivedBody =>
      'Spread direction and speed are computed from how the centre of the detection pattern shifted; the fire\'s real movement may differ. \"Detection pixel ~N hectares\" is the satellite\'s resolution, not the burnt area: the heat source is somewhere inside that pixel and its real size is unknown. That figure grows with the satellite\'s viewing angle, not with the fire.';

  @override
  String get dataSourcesNotKnownTitle => 'Not knowable';

  @override
  String get dataSourcesNotKnownBody =>
      'Whether a fire is out, contained or safe cannot be derived from satellite data. Satellites cannot see through cloud or smoke, so no detection means only that nothing was seen. This app makes no such claim — it appears only when an official source confirms it, shown with that source.';

  @override
  String get dataSourcesWeatherTitle => 'Regional risk — a separate source';

  @override
  String get dataSourcesWeatherBody =>
      'Risk scores are computed region-wide from weather data. They are not a measurement of any single fire and do not predict how one will behave. Weather comes from Open-Meteo (CC BY 4.0); when Open-Meteo does not answer, the Norwegian Meteorological Institute\'s MET Norway Locationforecast is used (NLOD 2.0 / CC BY 4.0). Temperature, humidity and wind mean the same from either source.';

  @override
  String get dataSourcesWeatherOpenMeteoCredit =>
      'Weather data by Open-Meteo.com';

  @override
  String get dataSourcesWeatherMetCredit => 'Data from MET Norway';

  @override
  String get dataSourcesPlacesTitle =>
      'Place data — province and district boundaries';

  @override
  String get dataSourcesPlacesBody =>
      'The province and district list in place selection, their centres and bounding boxes are bundled with the app; nothing is fetched from the network. Administrative boundary and place data © OpenStreetMap contributors, under the Open Database License (ODbL); names and province membership are matched against the official province/district list. This data serves map zooming and alert scope; it is not fire data. Address and neighbourhood searches use OpenStreetMap Nominatim; what you type is not stored, and results are cached for up to 7 days under an irreversible hash of the text.';

  @override
  String get dataSourcesFwiTitle =>
      'Copernicus fire danger index (FWI) — a separate source';

  @override
  String get dataSourcesFwiBody =>
      'The FWI (Copernicus) layer on the map shows Copernicus EFFIS\'s Fire Weather Index (FWI). FWI is a danger rating computed from temperature, humidity, wind and rain: it says how much the weather would feed a fire, not that a fire exists. The data comes from ECMWF\'s global weather model and provides a forecast of up to 10 days, today included (9 days ahead); the last day can stay empty until the day\'s model run is published. It is an entirely separate source from the satellite detections and is not a measurement of any fire. Data: © European Union, Copernicus EFFIS (CC BY 4.0). It is separate from the FireWatch risk score and does not feed into it.';

  @override
  String get settingsAppInfo => 'App Information';

  @override
  String get settingsAppInfoSubtitle => 'Version and product summary';

  @override
  String get settingsInfoApp => 'App';

  @override
  String get settingsInfoVersion => 'Version';

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
  String get settingsLegal => 'Legal';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsTermsOfService => 'Terms of Service';

  @override
  String get settingsLinkOpenFailed =>
      'Couldn\'t open the link. Please try again.';

  @override
  String get riskTitle => 'Risk Analysis';

  @override
  String get riskLiveView => 'Latest Risk View';

  @override
  String get riskSummaryTitle => 'Turkey Wildfire Risk Summary';

  @override
  String get riskSummarySubtitle =>
      'Calculated about every 3 hours from Open-Meteo / MET Norway weather and NASA FIRMS satellite detections. Each region\'s weather comes from one representative point.';

  @override
  String riskHighestRisk(String region, int score) {
    return 'Highest risk: $region ($score/100)';
  }

  @override
  String get riskDataLoading => 'Loading data...';

  @override
  String get riskKeyIndicators => 'Key Indicators';

  @override
  String get riskOverviewHighestTitle => 'Highest Risk';

  @override
  String get riskOverviewHighestSubtitle => 'Tap to see full region detail';

  @override
  String get riskOverviewLowestTitle => 'Lowest Risk';

  @override
  String get riskOverviewLowestSubtitle => 'Safest region right now';

  @override
  String get riskOverviewAvgTitle => 'Turkey Average';

  @override
  String get riskOverviewAvgSubtitle => 'Out of 100, across all regions';

  @override
  String get riskOverviewTrendTitle => 'Trend';

  @override
  String get riskOverviewTrendImproving => 'Improving';

  @override
  String get riskOverviewTrendWorsening => 'Worsening';

  @override
  String get riskOverviewTrendStable => 'Stable';

  @override
  String get riskOverviewTrendNoData => 'No data';

  @override
  String riskOverviewTrendSubtitle(String delta) {
    return '$delta pt change since last update';
  }

  @override
  String get riskOverviewTrendNoDataSubtitle => 'Not enough history yet';

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
  String get riskDrynessIndex => 'Dryness indicator';

  @override
  String get riskDrynessVeryHigh => 'Very high';

  @override
  String get riskWindPressure => 'Wind Pressure';

  @override
  String get riskVegetationDensity => 'Vegetation pressure';

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
    return 'Strong wind ($wind km/h)';
  }

  @override
  String riskNoteMediumWind(int wind) {
    return 'Moderate wind ($wind km/h)';
  }

  @override
  String get newsTitle => 'News';

  @override
  String get newsLiveFeed => 'News Feed';

  @override
  String get newsCenterTitle => 'Wildfire News Center';

  @override
  String get newsCenterSubtitle => 'The latest on fires.';

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
  String get newsContentCategoryEvacuation => 'Evacuation';

  @override
  String get newsContentCategoryResponse => 'Response';

  @override
  String get newsContentCategoryWarning => 'Warning';

  @override
  String get newsContentCategoryEmergency => 'Emergency';

  @override
  String get newsContentCategoryWeather => 'Weather';

  @override
  String get newsContentCategoryForest => 'Forest';

  @override
  String get newsContentCategoryNews => 'News';

  @override
  String get newsRiskCritical => 'CRITICAL';

  @override
  String get newsRiskActive => 'ACTIVE';

  @override
  String get newsRiskMonitoring => 'MONITORING';

  @override
  String get newsRiskInfo => 'INFO';

  @override
  String get newsBreakingBadge => 'Breaking';

  @override
  String get newsEnglishBannerText =>
      'Tap any article to translate it to English';

  @override
  String get newsTranslateCardButton => 'Translate';

  @override
  String get newsContentFiltersTitle => 'Status Filters';

  @override
  String get newsContentFiltersSubtitle => 'Filter by what\'s happening';

  @override
  String get newsFilterMyRegion => 'My Region';

  @override
  String get newsLatest => 'Latest News';

  @override
  String newsRecordsFound(int count) {
    return '$count records found';
  }

  @override
  String get newsFetchFailed => 'Failed to load news';

  @override
  String get newsNoneInCategory => 'No news matches this filter.';

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
  String get reportPanelVerifiedTitle => 'Matched a Satellite Detection';

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
      'Get your GPS location and report the fire. Your report is compared with nearby NASA satellite detections.';

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
  String get reportPanelAnonymousToggle => 'Submit anonymously';

  @override
  String get reportPanelAnonymousToggleSubtitle =>
      'Your name is not saved with the report';

  @override
  String get reportPanelPhotosLabel => 'Photos (optional)';

  @override
  String get reportPanelPhotosHint =>
      'Add up to 3 photos to help verify the report';

  @override
  String get reportPanelAddPhoto => 'Add Photo';

  @override
  String get reportPanelPhotoSourceCamera => 'Camera';

  @override
  String get reportPanelPhotoSourceGallery => 'Gallery';

  @override
  String get reportPanelRemovePhoto => 'Remove photo';

  @override
  String get reportPanelUploadingPhotos => 'Uploading photos…';

  @override
  String reportPanelPhotosUploaded(int count) {
    return '$count photos uploaded';
  }

  @override
  String get reportPanelMapAdjustHint =>
      'Tap the map to adjust the pin location';

  @override
  String get reportPanelSuccessVerifiedTitle => 'Matched a Satellite Detection';

  @override
  String get reportPanelSuccessReceivedTitle => 'Report Received';

  @override
  String get reportPanelSuccessVerifiedBody =>
      'NASA satellites detected heat within 10 km of this spot in the last 24 hours. That alone does not confirm a fire.';

  @override
  String get reportPanelSuccessReceivedBody =>
      'Your report was saved. Satellites made no detections nearby in the last 24 hours; that does not mean there is no fire.';

  @override
  String reportPanelReportIdLabel(String id) {
    return 'Report ID: #$id';
  }

  @override
  String reportPanelReportedAtLabel(String time) {
    return 'Reported at $time';
  }

  @override
  String get reportPanelResponseTimeVerified =>
      'This report is not forwarded to emergency services. If you can see a fire, call 112 now.';

  @override
  String get reportPanelResponseTimeReceived =>
      'This report is not forwarded to emergency services. If you can see a fire, call 112 now.';

  @override
  String get reportPanelShare => 'Share';

  @override
  String get reportPanelDone => 'Done';

  @override
  String reportPanelShareText(
    String city,
    String region,
    String id,
    String status,
  ) {
    return 'Fire report submitted near $city, $region (#$id). $status';
  }

  @override
  String get slowLoadingBannerLabel => 'Loading slowly — showing cached data';

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
      'With notification permission, you\'ll hear about nearby satellite detections and important changes right away.';

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
      'With your location we can show satellite detections and the risk around you. Distances are calculated on your phone.';

  @override
  String get locPermNote =>
      'If you start automatic monitoring for notifications, your location is stored on our server rounded to about 1 km; it is deleted immediately when you turn notifications off or use Settings → Delete my location data. This permission isn\'t required, you can skip it for now.';

  @override
  String get locPermEnable => 'Enable Location';

  @override
  String get locPermSkip => 'Skip for Now';

  @override
  String get locDisclosureTitle => 'How we use your location';

  @override
  String get locDisclosureOnDevice =>
      'Distance to nearby satellite detections is calculated on your phone.';

  @override
  String get locDisclosureNearestCity =>
      'To show which province you are in, your location is sent to our server, and to calculate risk, your location rounded to about 10 km; these lookups are not stored.';

  @override
  String get locDisclosureStored =>
      'If you start automatic monitoring for notifications, your location is stored on our server rounded to about 1 km so we can send alerts for your area. Your exact location is never stored.';

  @override
  String get locDisclosureDelete =>
      'It is deleted immediately when you turn notifications off or tap Settings → Delete my location data. If you don\'t open the app for 90 days, your record is deleted entirely.';

  @override
  String get locDisclosureOptional =>
      'Location permission is optional; you can use the app without it and revoke it at any time in your phone\'s settings.';

  @override
  String get locDisclosureContinue => 'Continue';

  @override
  String get locDisclosureNotNow => 'Not now';

  @override
  String get trackedPlacesTitle => 'My Places';

  @override
  String get trackedPlacesSubtitle =>
      'Get alerts for heat detected nearby or rising fire risk';

  @override
  String get trackedPlacesEmpty =>
      'No places yet. Add up to 5, such as your home, summer house or orchard.';

  @override
  String get trackedPlacesAdd => 'Add place';

  @override
  String get trackedPlacesFull => 'You can add up to 5 places.';

  @override
  String trackedPlacesRadius(int km) {
    return '$km km radius';
  }

  @override
  String trackedPlacesLastAlert(String date) {
    return 'Last alert: $date';
  }

  @override
  String get trackedPlacesNoAlertYet => 'No alerts yet';

  @override
  String get trackedPlacesNotifyTooltip => 'Alerts for this place';

  @override
  String trackedPlacesDeleteTitle(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get trackedPlacesDeleteBody =>
      'This place and its alert records are deleted from the server.';

  @override
  String get trackedPlacesDelete => 'Delete';

  @override
  String get trackedPlacesUnavailable => 'This feature is coming soon.';

  @override
  String get trackedPlacesLoadFailed =>
      'Couldn\'t load your places. Showing the last saved list.';

  @override
  String get trackedPlacesSourceMap => 'Pick on map';

  @override
  String get trackedPlacesSourceMyLocation => 'Use my location';

  @override
  String get trackedPlacesLocationFailed => 'Couldn\'t get your location.';

  @override
  String get trackedPlacesNameLabel => 'Place name';

  @override
  String get trackedPlacesNameHint => 'e.g. Home, Summer house';

  @override
  String get trackedPlacesNameRequired => 'Enter a name.';

  @override
  String get trackedPlacesRadiusLabel => 'Radius';

  @override
  String get trackedPlacesSave => 'Save';

  @override
  String trackedPlacesSaved(String name) {
    return '\"$name\" added to My Places.';
  }

  @override
  String get trackedPlacesErrorOutside => 'This point is outside Turkey.';

  @override
  String get trackedPlacesErrorNetwork =>
      'Couldn\'t save. Check your internet connection and try again.';

  @override
  String get trackedPlacesErrorGeneric => 'Something went wrong, try again.';

  @override
  String get trackedPlacesPickerTitle => 'Choose the location';

  @override
  String get trackedPlacesPickerHint =>
      'Move the map to put the marker on the place, or long-press the map.';

  @override
  String get trackedPlacesPickerConfirm => 'Use this location';

  @override
  String get trackedPlacesApproxNote =>
      'The location is stored on the server at about 1 km precision. Alerts do not report confirmed fires: they come from satellite heat detections or the risk score.';

  @override
  String get trackedPlacesMigrateTitle =>
      'Move your saved places to My Places?';

  @override
  String trackedPlacesMigrateBody(int count) {
    return 'You have $count saved places. Move them to get alerts for new satellite heat detections within 10 km.';
  }

  @override
  String get trackedPlacesMigrateAccept => 'Move';

  @override
  String trackedPlacesMigrateDone(int count) {
    return '$count places added.';
  }

  @override
  String get locDisclosureTracked =>
      'For places in My Places, the name, the location rounded to about 1 km and the radius are stored on our server. Delete one from the list, or all of them with Settings → Delete my location data.';

  @override
  String get notifPlacesChannelName => 'My places';

  @override
  String get notifPlacesChannelDescription =>
      'Satellite heat detections near your places and fire risk there';

  @override
  String get settingsDeleteLocation => 'Delete my location data';

  @override
  String get settingsDeleteLocationConfirmTitle => 'Delete your location data?';

  @override
  String get settingsDeleteLocationConfirmBody =>
      'Your approximate location and all your tracked places on our server are deleted immediately. Notifications stay on; if you haven\'t picked a province or region, you may receive risk alerts for all regions from now on. If you start automatic monitoring again, your location is stored again.';

  @override
  String get settingsDeleteLocationConfirm => 'Delete';

  @override
  String get settingsDeleteLocationDone =>
      'Your location and tracked places were deleted from the server.';

  @override
  String get settingsDeleteLocationFailed =>
      'Couldn\'t delete your location data. Check your internet connection and try again.';

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
    return 'Satellites detected ${temp}K heat. Not verified. Stay away from the area.';
  }

  @override
  String get riskReasonHighNoTemp =>
      'Satellites made a strong detection. Not verified.';

  @override
  String riskReasonMediumWithTemp(String temp) {
    return 'Satellites detected ${temp}K heat. Its cause is not verified.';
  }

  @override
  String get riskReasonMediumNoTemp =>
      'Satellites made a medium-strength detection. Not verified.';

  @override
  String riskReasonLowWithTemp(String temp) {
    return 'Satellites detected low heat (${temp}K). Its cause is not verified.';
  }

  @override
  String get riskReasonLowNoTemp =>
      'Satellites made a weak detection. Monitoring is recommended.';

  @override
  String get fireGeneratedDescHigh =>
      'Satellites detected strong heat. Not verified.';

  @override
  String get fireGeneratedDescMedium =>
      'Moderate heat increase. The area needs monitoring.';

  @override
  String get fireGeneratedDescLow =>
      'Satellites made a weak detection. Monitoring is recommended.';

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
  String get fireStatusActive => 'Very Strong Detection';

  @override
  String get fireStatusLikelyActive => 'Strong Detection';

  @override
  String get fireStatusMonitoring => 'Monitoring';

  @override
  String get fireStatusHistorical => 'No longer seen';

  @override
  String fireEventRegionTitle(String city) {
    return '$city Region Satellite Detection';
  }

  @override
  String get fireEventLiveDetectionTitle => 'Recent Satellite Detection';

  @override
  String get fireEventStatusActive => 'Active';

  @override
  String get fireEventStatusMonitoring => 'Monitoring';

  @override
  String get fireEventStatusControlled => 'Low confidence';

  @override
  String get fireEventSpreadHigh => 'High — active monitoring required';

  @override
  String get fireEventSpreadMedium => 'Medium — monitor carefully';

  @override
  String get fireEventSpreadLow => 'Low';

  @override
  String fireDetailAreaMeasured(int hectares) {
    return 'Area seen by the satellite ~$hectares hectares (not the fire itself)';
  }

  @override
  String get fireDetailWindLoading => 'Fetching wind data...';

  @override
  String get fireDetailWindUnavailable => 'Wind data unavailable';

  @override
  String fireDetailWindValue(String speed, String direction) {
    return '$speed km/h from the $direction';
  }

  @override
  String get windDirectionN => 'North';

  @override
  String get windDirectionNE => 'Northeast';

  @override
  String get windDirectionE => 'East';

  @override
  String get windDirectionSE => 'Southeast';

  @override
  String get windDirectionS => 'South';

  @override
  String get windDirectionSW => 'Southwest';

  @override
  String get windDirectionW => 'West';

  @override
  String get windDirectionNW => 'Northwest';

  @override
  String get fireDetailFireRadiativePower => 'Fire Radiative Power (FRP)';

  @override
  String fireDetailFrpValue(String frp, String intensity) {
    return '$frp MW ($intensity)';
  }

  @override
  String get fireDetailFrpUnavailable => 'Not available';

  @override
  String get frpIntensityLow => 'Low intensity';

  @override
  String get frpIntensityModerate => 'Moderate intensity';

  @override
  String get frpIntensityHigh => 'High intensity';

  @override
  String get frpIntensityVeryHigh => 'Very high intensity';

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
    return 'Fire Alert\n\n$title\n$city / $district\n\nStatus: $status\nRisk: $risk\n\n$description\n\nTracked with FireWatch TR.';
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
  String newsWordCount(int count) {
    return '~$count words';
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
  String get newsTranslatedCaption =>
      'Translated from Turkish • Tap for full translation';

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
  String get coachMarkMapTitle => 'Map and Satellite Detections';

  @override
  String get coachMarkMapDesc =>
      'Markers on the map are heat detections from NASA satellites; not every one is a fire. Tap a marker to see details — you can also report a new fire from the map screen.';

  @override
  String get coachMarkRiskTitle => 'Risk Levels';

  @override
  String get coachMarkRiskDesc =>
      'Every satellite detection is labeled High, Medium, or Low risk. These tags help you quickly understand how dangerous an area is.';

  @override
  String get coachMarkWatchlistTitle => 'Watchlist';

  @override
  String get coachMarkWatchlistDesc =>
      'Save satellite detections you want to keep an eye on, and quickly find them again here.';

  @override
  String get coachMarkNotificationsTitle => 'Notifications';

  @override
  String get coachMarkNotificationsDesc =>
      'Get alerts for satellite heat detections near you, and start automatic scanning from here.';

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
  String get monitorStatusReady => 'Automatic monitoring is ready.';

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
      'Satellites report no detections right now.';

  @override
  String monitorStatusNoNearbyFires(int count) {
    return 'Satellites detected nothing within 50 km. ($count points scanned)';
  }

  @override
  String monitorStatusNearbyFiresFound(int count) {
    return 'Satellites made $count detections within 50 km.';
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
  String get notifNearbyFireTitle => 'Satellites made a detection near you';

  @override
  String notifNearbyFireBody(String distance, int count) {
    return '$count satellite detections within $distance. Not verified.';
  }

  @override
  String get notifTestBody => 'Test notification ready.';

  @override
  String get notifNewNotificationBody => 'New notification';

  @override
  String get riskOutsideTurkeyBanner =>
      'You\'re outside Turkey — regional risk data isn\'t available for your location.';

  @override
  String riskMyLocationPostgisDistance(String distance) {
    return '$distance km away';
  }

  @override
  String get riskComparisonTitle => 'Comparison with Turkey Average';

  @override
  String get riskComparisonHigherRisk => 'Higher risk';

  @override
  String get riskComparisonLowerRisk => 'Lower risk';

  @override
  String get riskComparisonSimilar => 'Similar to Turkey average';

  @override
  String get riskInfoButtonTooltip => 'How is the risk score calculated?';

  @override
  String get riskInfoTitle => 'How Is the Risk Score Calculated?';

  @override
  String get riskInfoFormulaTitle => 'Score Formula';

  @override
  String get riskInfoFormulaTemp => 'Temperature (max 30 pts)';

  @override
  String get riskInfoFormulaHumidity => 'Low Humidity (max 25 pts)';

  @override
  String get riskInfoFormulaWind => 'Wind (max 25 pts)';

  @override
  String get riskInfoFormulaFireCount =>
      'Satellite heat events in the last 24 hours (max 20 pts)';

  @override
  String get riskInfoSourcesTitle => 'Data Sources';

  @override
  String get riskInfoSourcesBody =>
      'Calculated using NASA FIRMS satellite data and Open-Meteo weather data (MET Norway as fallback). Weather comes from one representative point per region; news does not affect the score.';

  @override
  String get riskInfoUpdateFrequencyTitle => 'Update Frequency';

  @override
  String get riskInfoUpdateFrequencyBody =>
      'Risk scores are recalculated every 3 hours.';

  @override
  String get trustHomeInfo =>
      'Data comes from NASA FIRMS satellite detections; the server fetches new data about every 30 minutes.';

  @override
  String get trustMapInfo => 'Markers show detections made by satellites.';

  @override
  String get trustRiskInfo =>
      'Risk scores are calculated about every 3 hours from weather and NASA satellite detections.';

  @override
  String get trustNewsInfo =>
      'News is filtered for wildfire-related content from 9 Turkish sources.';

  @override
  String get trustAlertsInfo =>
      'Notifications are sent when satellites detect heat within 50 km of your location.';

  @override
  String get trustCardLabel => 'About This Data';

  @override
  String get trustAspectMeaningTitle => 'What does this mean?';

  @override
  String get trustAspectSourceTitle => 'Where does this come from?';

  @override
  String get trustAspectInterpretTitle => 'How to interpret it';

  @override
  String get trustAspectActionTitle => 'What should I do?';

  @override
  String get trustHomeMeaning =>
      'Counts are detections made by satellites in the last 24 hours; they are not verified. Some may be agricultural burns, industrial heat or hot surfaces.';

  @override
  String get trustHomeSource =>
      'Data comes from NASA FIRMS (Fire Information for Resource Management System), combining passes of several satellites. The server fetches new data about every 30 minutes; satellite passes and NASA\'s processing time can delay a detection by a few hours.';

  @override
  String get trustHomeInterpret =>
      'Only detections the satellite is very sure of, with very high heat, are labelled Very Strong Detection.';

  @override
  String get trustHomeAction =>
      'Tap a detection for more. If you see smoke or flames, call 112 first.';

  @override
  String get trustMapMeaning =>
      'Each marker is a satellite detection; it is not verified. Red is very strong, orange strong, yellow medium, grey weak.';

  @override
  String get trustMapSource => 'Satellite data comes from NASA FIRMS.';

  @override
  String get trustMapInterpret =>
      'Clusters only mean multiple heat detections are close together. They do not by themselves confirm the cause or size of a fire.';

  @override
  String get trustMapAction =>
      'Tap a marker for more. If you see a fire yourself, call 112 first, then use Report.';

  @override
  String get trustRiskMeaning =>
      'The risk score (0-100) is an index combining temperature, humidity, wind and recent satellite detections in the region. It does not say whether a fire will start and is not a guarantee.';

  @override
  String get trustRiskSource =>
      'Weather data is pulled from live meteorological feeds; fire counts factor in recent NASA FIRMS detections for each region.';

  @override
  String get trustRiskInterpret =>
      'Compare your region\'s score to the Turkey average on the chart — a score significantly above average signals elevated local conditions worth monitoring.';

  @override
  String get trustRiskAction =>
      'If your region shows Critical or High risk, avoid open flames and report any smoke immediately. Switch to the \"My Location\" tab for a personalized breakdown.';

  @override
  String get trustNewsMeaning =>
      'Headlines are automatically filtered to keep only wildfire, disaster, and emergency-related coverage — unrelated political or sports stories are excluded.';

  @override
  String get trustNewsSource =>
      'Articles are aggregated from 9 established Turkish news outlets via their public RSS feeds, refreshed continuously throughout the day.';

  @override
  String get trustNewsInterpret =>
      'A \"Breaking\" badge means the article was published very recently — always check the publish time, as wildfire situations can change quickly.';

  @override
  String get trustNewsAction =>
      'Use the Translate button to read non-English articles, or tap \"Related Fires\" on a story to jump directly to that location on the map.';

  @override
  String get trustAlertsMeaning =>
      'Alerts are sent when satellites make a detection within 50 km. They are automated and not verified.';

  @override
  String get trustAlertsSource =>
      'Background monitoring checks NASA FIRMS data on a schedule and compares new detections against your device\'s last known location on your phone. For regional alerts from our server, your location is stored rounded to about 1 km when you start automatic monitoring.';

  @override
  String get trustAlertsInterpret =>
      'Confidence says how sure the satellite is of the detection. It does not verify a fire.';

  @override
  String get trustAlertsAction =>
      'Grant notification permission and start Auto Monitoring while using the app. Use \"Scan Now\" anytime to manually check your surroundings.';

  @override
  String get newsReadFullArticle => 'Read Full Article';

  @override
  String smartIntensityIntense(String location) {
    return 'Satellites made a very strong detection near $location.';
  }

  @override
  String smartIntensityHigh(String location) {
    return 'Satellites made a strong detection near $location.';
  }

  @override
  String smartIntensityModerate(String location) {
    return 'Satellites made a medium-strength detection near $location.';
  }

  @override
  String smartIntensityEarly(String location) {
    return 'Satellites made a weak detection near $location; its cause is not verified.';
  }

  @override
  String smartIntensityAnomaly(String location) {
    return 'Satellites made a detection near $location.';
  }

  @override
  String get smartLocationHintForest => 'in a province with extensive forest';

  @override
  String get smartLocationHintCoastal => 'in the south-western coastal belt';

  @override
  String get smartLocationHintUrban =>
      'in a heavily urbanised province; the source may be a building or industry';

  @override
  String get smartLocationHintAgricultural =>
      'in a heavily agricultural province; satellites also detect stubble burning';

  @override
  String get smartFrpHigh => 'The satellite measured high heat at this spot.';

  @override
  String smartPixelFootprint(int hectares) {
    return 'The satellite sees this spot as an area of ~$hectares hectares; the heat is somewhere inside it and its real size is unknown.';
  }

  @override
  String smartAreaLarge(int hectares) {
    return 'The area detected by the satellite is large (~$hectares hectares).';
  }

  @override
  String smartAreaMedium(int hectares) {
    return 'The area detected by the satellite is medium-sized (~$hectares hectares).';
  }

  @override
  String get smartConfidenceHigh =>
      'NASA is highly confident in this detection; its cause is not verified.';

  @override
  String get smartConfidenceMedium =>
      'NASA reports this detection with medium confidence; it is not verified.';

  @override
  String get smartConfidenceLow =>
      'A weak detection; it may be industrial heat or a reflection, and it is not verified.';

  @override
  String get smartSpreadDangerous =>
      'The region\'s current risk score is high (low humidity, strong wind) — not a measurement of this fire.';

  @override
  String get smartSpreadModerate =>
      'The region\'s current risk score is moderate — not a measurement of this fire.';

  @override
  String get smartSpreadLow =>
      'The region\'s current risk score is low — not a measurement of this fire.';

  @override
  String smartTimeJustNow(String satellite) {
    return 'Just detected by $satellite.';
  }

  @override
  String smartTimeRecent(int hours, String satellite) {
    return 'Detected $hours hours ago by $satellite; its current state is not verified.';
  }

  @override
  String smartTimeOlder(int hours) {
    return 'Detected $hours hours ago — current status unknown.';
  }

  @override
  String smartTimeHistorical(int days) {
    return 'An older detection from $days days ago; its current state is unknown.';
  }

  @override
  String get tooltipTempTitle => 'Temperature';

  @override
  String get tooltipTempBody =>
      'Satellite-measured brightness temperature. High values indicate a strong heat source but do not alone confirm a fire.';

  @override
  String get tooltipConfidenceTitle => 'What Does Confidence Mean?';

  @override
  String get tooltipSatelliteTitle => 'What Does Satellite Mean?';

  @override
  String get tooltipSatelliteViirsBody =>
      'VIIRS: the NOAA-20 and NOAA-21 satellites pass over Türkiye several times a day. (Suomi NPP stopped delivering data on 2 November 2026.)';

  @override
  String get tooltipSatelliteModisBody =>
      'MODIS: Terra/Aqua satellite, provides wider coverage.';

  @override
  String get tooltipSatelliteMergedBody =>
      'This anomaly was detected by multiple satellite instruments in the same time and location window. This strengthens the detection, but does not confirm its cause.';

  @override
  String get fireCardMultiSourceBadge => 'Multi-source detection';

  @override
  String get reportPanelDuplicateLocationBlocked =>
      'A report has already been sent from this location. Please wait for authorities to respond.';

  @override
  String get reportPanelDailyLimitReached =>
      'You\'ve reached today\'s report limit (max 5 per day). Please try again tomorrow.';

  @override
  String fireDetailRelatedToCity(String city) {
    return 'Related to $city';
  }

  @override
  String get fireDetailRegionalNews => 'Regional News';

  @override
  String get coachMarkMapMarkersTitle => 'Satellite Detection Markers';

  @override
  String get coachMarkMapMarkersDesc =>
      'Markers on the map are heat detections from NASA satellites; not every one is a fire. Tap one to see details.';

  @override
  String get coachMarkMapClustersTitle => 'Cluster Numbers';

  @override
  String get coachMarkMapClustersDesc =>
      'Fire points close to each other group into a circle showing a count. Zoom in to split them apart.';

  @override
  String get coachMarkMapReportTitle => 'Report a Fire';

  @override
  String get coachMarkMapReportDesc =>
      'Tap the button in the bottom right to report a fire you\'ve spotted, along with your GPS location.';

  @override
  String get coachMarkMapNearbyTitle => 'Satellite Detections Near Me';

  @override
  String get coachMarkMapNearbyDesc =>
      'This section lists the satellite heat detections closest to your location, sorted by distance.';

  @override
  String get coachMarkNewsFeaturedTitle => 'Featured Story';

  @override
  String get coachMarkNewsFeaturedDesc =>
      'Today\'s most important development is highlighted here.';

  @override
  String get coachMarkNewsCategoryTitle => 'Categories';

  @override
  String get coachMarkNewsCategoryDesc =>
      'Filter news by Risk, Operation, Safety, or Update category.';

  @override
  String get coachMarkNewsRegionTitle => 'Status Filters';

  @override
  String get coachMarkNewsRegionDesc =>
      'Filter by severity — critical, active, monitoring, info — or just your own region.';

  @override
  String get coachMarkNewsListTitle => 'Tap an Article';

  @override
  String get coachMarkNewsListDesc =>
      'Tap an article to read the full text — in English mode, you can translate the title and summary with one tap.';

  @override
  String get coachMarkNotifPermissionTitle => 'Notification Permission';

  @override
  String get coachMarkNotifPermissionDesc =>
      'Grant permission to get alerts about satellite heat detections near you.';

  @override
  String get coachMarkNotifScanTitle => 'Scan Now';

  @override
  String get coachMarkNotifScanDesc =>
      'Check whether satellites have detected heat within 50 km of your location.';

  @override
  String get coachMarkNotifMonitoringTitle => 'Auto Monitoring';

  @override
  String get coachMarkNotifMonitoringDesc =>
      'Start auto monitoring to periodically check nearby satellite detections while the app is open.';

  @override
  String get coachMarkNotifAlertsTitle => 'Alert Cards';

  @override
  String get coachMarkNotifAlertsDesc =>
      'High-risk detections are listed here — tap a card to see the full details.';

  @override
  String get coachMarkRiskScoreTitle => 'Risk Score';

  @override
  String get coachMarkRiskScoreDesc =>
      'This 0-100 score is calculated from temperature, humidity, wind, and NASA satellite detections. Tap the info button to see exactly how.';

  @override
  String get coachMarkRiskChartTitle => 'Regional Distribution';

  @override
  String get coachMarkRiskChartDesc =>
      'Tap a region\'s bar to see that region\'s detailed risk breakdown.';

  @override
  String get coachMarkRiskMyLocationTabTitle => 'My Location';

  @override
  String get coachMarkRiskMyLocationTabDesc =>
      'Switch to this tab to compare your own region\'s risk against the Turkey average.';

  @override
  String get coachMarkRiskInfoTitle => 'Data Sources';

  @override
  String get coachMarkRiskInfoDesc =>
      'The info button explains the risk score formula, data sources, and how often it updates.';

  @override
  String get coachMarkWatchlistPurposeTitle => 'What\'s the Watchlist For?';

  @override
  String get coachMarkWatchlistPurposeDesc =>
      'Keep the satellite detections you want to follow all in one place here.';

  @override
  String get coachMarkWatchlistHowToAddTitle => 'How to Add';

  @override
  String get coachMarkWatchlistHowToAddDesc =>
      'Tap the bookmark button on a detection\'s detail screen to save it here.';

  @override
  String get coachMarkWatchlistClearTitle => 'Clear';

  @override
  String get coachMarkWatchlistClearDesc =>
      'Use the Clear button in the top corner to remove all saved points at once.';

  @override
  String get detectionProbableFire => 'Very Strong Detection';

  @override
  String get detectionHighThermalAnomaly => 'Strong Detection';

  @override
  String get detectionThermalDetection => 'Satellite Detection';

  @override
  String get detectionLowConfidence => 'Low Confidence Detection';

  @override
  String get thermalAnomalyDisclaimer =>
      'NASA satellites detect heat. Detections are not verified; non-fire sources such as industry can be detected too.';

  @override
  String get detectionAboutTitle => 'What is this detection?';

  @override
  String get detectionAboutViirs =>
      'NASA VIIRS measures infrared heat at the Earth\'s surface. It identifies thermal anomalies, not confirmed fires.';

  @override
  String detectionConfidenceExplanation(String level) {
    return 'Confidence: $level. This is the satellite algorithm\'s confidence that the pixel contains a real thermal anomaly; it does not confirm its cause.';
  }

  @override
  String detectionFrpExplanation(String frp) {
    return 'FRP: $frp MW. Fire Radiative Power estimates the rate of radiant heat; higher values indicate a stronger heat source, which may still be industrial or agricultural.';
  }

  @override
  String get detectionLimitations =>
      'Cloud, smoke, satellite resolution and non-fire heat sources can cause missed or misleading detections. Use official emergency information and direct observation for safety decisions.';

  @override
  String get mapLegendTitle => 'Map Legend';

  @override
  String get legendProbableFire => 'Very strong detection';

  @override
  String get legendHighThermal => 'Strong detection';

  @override
  String get legendLowConfidence => 'Low Confidence';

  @override
  String get mapMarkerDisclaimerBefore =>
      'The map shows detections made by NASA satellites.';

  @override
  String get mapMarkerDisclaimerAfter =>
      'markers are the strongest detections; not verified.';

  @override
  String get feedbackSend => 'Send Feedback';

  @override
  String get feedbackTitle => 'Send Feedback';

  @override
  String get feedbackRating => 'Rating';

  @override
  String get feedbackCategory => 'Category';

  @override
  String get feedbackBug => 'Bug Report';

  @override
  String get feedbackFeature => 'Feature Request';

  @override
  String get feedbackGeneral => 'General Feedback';

  @override
  String get feedbackMessage => 'Message';

  @override
  String get feedbackEmail => 'Email (optional)';

  @override
  String get feedbackSubmit => 'Send';

  @override
  String get feedbackSuccess => 'Thank you! Your feedback was sent.';

  @override
  String get feedbackError => 'Feedback could not be sent. Please try again.';

  @override
  String get feedbackMessageRequired => 'Please enter a message.';

  @override
  String get feedbackRatingRequired => 'Please select a rating from 1 to 5.';

  @override
  String get ratingPromptTitle => 'Enjoying FireWatch TR?';

  @override
  String get ratingPromptMessage =>
      'You have been using the app for a few days. Would you like to share your feedback?';

  @override
  String get ratingPromptLater => 'Later';

  @override
  String get feedbackReportBug => 'Report a Bug';

  @override
  String get feedbackSendFeedback => 'Send Feedback';

  @override
  String feedbackBlockedMessage(int days) {
    return 'Your feedback was received. Please wait $days days before submitting again.';
  }

  @override
  String get bugReportTitle => 'Report a Bug';

  @override
  String get bugReportIntro =>
      'Tell us what went wrong — this goes straight to the team.';

  @override
  String get bugReportWhatHappened => 'What happened?';

  @override
  String get bugReportWhatExpected => 'What did you expect instead?';

  @override
  String get bugReportDeviceInfo => 'Device info (attached automatically)';

  @override
  String get bugReportWhatHappenedRequired => 'Please describe what happened.';

  @override
  String get coachMarkWatchlistTapTitle => 'View Details';

  @override
  String get coachMarkWatchlistTapDesc =>
      'Tap a saved detection to see its current status and full details.';

  @override
  String get notificationScopeTitle => 'Alert Scope';

  @override
  String get notificationScopeSubtitle =>
      'Choose which fires you want to be alerted about.';

  @override
  String get notificationScopeAll => 'All of Türkiye';

  @override
  String get notificationScopeAllDesc =>
      'Receive fire alerts from anywhere in the country.';

  @override
  String get notificationScopeRegion => 'My region only';

  @override
  String get notificationScopeRegionDesc =>
      'Only fires in the geographic region you pick.';

  @override
  String get notificationScopeCity => 'My province only';

  @override
  String get notificationScopeCityDesc =>
      'Only fires in the province you pick.';

  @override
  String get notificationScopeRegionLabel => 'Region';

  @override
  String get notificationScopeCityLabel => 'Province';

  @override
  String get notificationScopeSelectRegion => 'Select a region';

  @override
  String get notificationScopeSelectCity => 'Select a province';

  @override
  String notificationScopeDetected(String name) {
    return 'Detected from your location: $name';
  }

  @override
  String get notificationScopeDetecting => 'Detecting your location...';

  @override
  String get notificationScopeSaved => 'Alert scope updated.';

  @override
  String get notificationScopeSaveFailed =>
      'Could not save your scope. Check your connection.';

  @override
  String get notificationScopeCitiesUnavailable =>
      'Province list could not be loaded.';

  @override
  String get notificationScopeNarrowWarning =>
      'Narrowing the scope means you will not be alerted about fires outside the area you picked.';

  @override
  String get incidentsSectionTitle => 'Satellite Events';

  @override
  String get incidentsSectionSubtitle =>
      'Satellite detections grouped into events';

  @override
  String get incidentStatusActive => 'Recent detection';

  @override
  String get incidentStatusAwaiting => 'No longer seen';

  @override
  String get incidentStatusLowConfidence => 'Low confidence';

  @override
  String incidentDetectedHoursAgo(String hours) {
    return 'Detected within the last $hours hours';
  }

  @override
  String incidentNoDetectionFor(String hours) {
    return 'Heat detected, not seen for $hours hours';
  }

  @override
  String incidentNoDetectionLowConfidence(String hours) {
    return 'Heat detected, not seen for $hours hours (low confidence)';
  }

  @override
  String incidentDurationOngoing(String hours) {
    return 'Detected for at least $hours hours';
  }

  @override
  String get incidentDurationShort => 'Detected in a single pass';

  @override
  String incidentEvidence(int detections, int passes) {
    return '$detections detections, $passes satellite passes';
  }

  @override
  String get incidentHeatLabel => 'Heat intensity';

  @override
  String get incidentHeatLow => 'Weak';

  @override
  String get incidentHeatModerate => 'Medium';

  @override
  String get incidentHeatHigh => 'Strong';

  @override
  String get incidentHeatVeryHigh => 'Very strong';

  @override
  String get incidentSpreadTitle => 'Spread (estimated)';

  @override
  String incidentSpreadLine(String direction, String meters) {
    return '$direction, about $meters metres per hour';
  }

  @override
  String get incidentSpreadEstimateNote =>
      'Derived from how the detection pattern shifted; the fire\'s actual movement may differ.';

  @override
  String get incidentTrendWeakening => 'Heat intensity is decreasing';

  @override
  String get incidentTrendIntensifying => 'Heat intensity is increasing';

  @override
  String get incidentTrendStable => 'Heat intensity is not changing';

  @override
  String get incidentTrendNote =>
      'Based on the heat the satellite measures. Whether anyone is fighting the fire cannot be told from this data.';

  @override
  String get incidentToggleShow => 'Satellite events';

  @override
  String get incidentToggleDetections => 'Unverified satellite detections';

  @override
  String get incidentLayerCaptionDetections =>
      'Detections made one by one by satellites; not verified.';

  @override
  String get incidentLayerCaptionEvents =>
      'Detections at the same spot are merged into one event.';

  @override
  String get incidentFilterActive => 'Active';

  @override
  String get incidentFilterEnded => 'No longer seen';

  @override
  String get incidentFilterAll => 'All';

  @override
  String get riskLayerToggle => 'FWI (Copernicus)';

  @override
  String get incidentToggleShowShort => 'Events';

  @override
  String get incidentToggleDetectionsShort => 'Points';

  @override
  String get mapLayersButton => 'Layers';

  @override
  String get placesButton => 'My Places';

  @override
  String get placesTitle => 'Saved Places';

  @override
  String get placesSubtitle =>
      'The map zooms to these places; they can also narrow your alert scope.';

  @override
  String get placesEmpty =>
      'No saved places yet. Search for a province or district, or drop a pin on the map.';

  @override
  String get placesSearchHint => 'Search province or district';

  @override
  String get placesDropPin => 'Drop a pin on the map';

  @override
  String get placesDropPinHint => 'Tap the point you want to save';

  @override
  String get placesPinNameTitle => 'Name this place';

  @override
  String get placesPinDefaultName => 'Saved point';

  @override
  String get placesShowAllPlaces => 'Show all';

  @override
  String get placesResetView => 'All of Türkiye';

  @override
  String get placesRemove => 'Remove place';

  @override
  String get placesRiskUnknown => 'Risk unavailable';

  @override
  String get placesRiskNoData => 'No data';

  @override
  String placesRiskLine(String day) {
    return 'FWI danger · $day';
  }

  @override
  String placesActiveDetections(int count) {
    return '$count active detections';
  }

  @override
  String get placesNoActiveDetections => 'No active detections';

  @override
  String placesLastDetection(String hours) {
    return 'Last detection ~$hours h ago';
  }

  @override
  String get placesResolutionNote =>
      'The FWI class is a regional forecast from ECMWF\'s global weather model; it is meaningful at province and district scale and does not resolve at neighbourhood scale. Two nearby places showing the same class is the data\'s resolution, not an error.';

  @override
  String get notificationScopePlaces => 'My saved places';

  @override
  String get notificationScopePlacesDesc =>
      'Only fires around the provinces, districts and points you saved on the map screen.';

  @override
  String get notificationScopePlacesEmpty =>
      'No saved places yet. You can add some from My Places on the map screen.';

  @override
  String notificationScopePlacesNote(int count) {
    return '$count saved places are watched. For now this scope is enforced by this device\'s own scans; server notifications keep using the last region/province scope you chose.';
  }

  @override
  String get notifPlacesFireTitle =>
      'Satellite detection near your saved place';

  @override
  String notifPlacesFireBody(int count) {
    return 'There are $count satellite detections around your saved places. Check the map screen.';
  }

  @override
  String get riskLegendTitle => 'Copernicus fire danger index (FWI)';

  @override
  String get riskLegendNote =>
      'A regional danger forecast computed from weather; not a satellite detection.';

  @override
  String get riskLegendHide => 'Hide legend';

  @override
  String get riskClassVeryLow => 'Very low';

  @override
  String get riskClassLow => 'Low';

  @override
  String get riskClassModerate => 'Moderate';

  @override
  String get riskClassHigh => 'High';

  @override
  String get riskClassVeryHigh => 'Very high';

  @override
  String get riskClassExtreme => 'Extreme';

  @override
  String get riskOpacityLabel => 'Opacity';

  @override
  String get riskDayToday => 'Today';

  @override
  String get riskDayTomorrow => 'Tomorrow';

  @override
  String get riskDayNotPublished =>
      'This day\'s forecast has not been published yet. It opens once the daily model run arrives.';

  @override
  String get riskAttribution =>
      '© European Union, Copernicus EFFIS · CC BY 4.0';

  @override
  String get homeLast24hTitle => 'Last 24 Hours';

  @override
  String get homeLast24hSubtitle => 'Summary of satellite detections';

  @override
  String get homeLast24hActiveTitle => 'Repeated detections';

  @override
  String homeLast24hActiveSubtitle(int hours) {
    return 'Seen by a satellite within the last $hours hours';
  }

  @override
  String get homeLast24hEndedTitle => 'No longer seen';

  @override
  String get homeLast24hEndedSubtitle => 'Not a claim that they are out.';

  @override
  String get homeLast24hLongestTitle => 'Longest running';

  @override
  String get homeLast24hLongestSubtitle =>
      'Since first detection, still being detected';

  @override
  String get homeLast24hStrongestTitle =>
      'Strongest satellite detection — not verified';

  @override
  String get homeLast24hStrongestSubtitle =>
      'The strongest detection satellites see right now';

  @override
  String homeLast24hStrongestSubtitleWithDuration(String duration) {
    return 'At least $duration, still being detected';
  }

  @override
  String durationHoursShort(int hours) {
    return '$hours h';
  }

  @override
  String durationDaysHours(int days, int hours) {
    return '$days d $hours h';
  }

  @override
  String get incidentsEmpty => 'No grouped satellite events in this period.';

  @override
  String incidentsCount(int count) {
    return '$count events';
  }

  @override
  String get incidentPanelTitle => 'Satellite detection';

  @override
  String get incidentOfficialTitle => 'Official status';

  @override
  String get incidentSatelliteLimitNote =>
      'Satellites pass a few times a day and cannot see through cloud or smoke. No detection does not mean the fire is over.';

  @override
  String get incidentFixedSourceHint =>
      'This location has appeared on every satellite pass for two days at unchanging power — it may be a fixed heat source.';

  @override
  String get incidentStatusPersistentHeatSource => 'Fixed heat source';

  @override
  String incidentPersistentHeatSourceNote(int days) {
    return 'Radiating low, unchanging heat for $days days: a fixed source such as a steelworks, refinery or gas flare. Not counted as an active fire. This does not mean any fire is out.';
  }

  @override
  String get homeFixedHeatSourceChip => 'Fixed heat source';

  @override
  String get incidentLegendTitle => 'Map legend';

  @override
  String get compassTowardsNorth => 'towards the north';

  @override
  String get compassTowardsNorthEast => 'towards the north-east';

  @override
  String get compassTowardsEast => 'towards the east';

  @override
  String get compassTowardsSouthEast => 'towards the south-east';

  @override
  String get compassTowardsSouth => 'towards the south';

  @override
  String get compassTowardsSouthWest => 'towards the south-west';

  @override
  String get compassTowardsWest => 'towards the west';

  @override
  String get compassTowardsNorthWest => 'towards the north-west';

  @override
  String riskHeatPill(String place, int score, String level) {
    return '$place · $score/100 · $level';
  }

  @override
  String get riskHeatTurkeyWide => 'All of Türkiye';

  @override
  String get riskHeatLevelVeryHigh => 'Very high';

  @override
  String get riskHeatUnavailable => 'Risk data is unavailable right now';

  @override
  String riskHeatMapSemantics(int score, String level) {
    return 'Türkiye wildfire risk heat map. Nationwide risk score $score/100, $level.';
  }

  @override
  String get navRisk => 'Risk';

  @override
  String get riskAdviceCritical =>
      'Do not light outdoor fires. Report suspicious smoke to 112 and follow official alerts.';

  @override
  String get riskAdviceHigh =>
      'Do not light outdoor fires; avoid activities that create sparks.';

  @override
  String get riskAdviceMedium =>
      'Take care near dry vegetation and follow local alerts.';

  @override
  String get riskAdviceLow =>
      'Low risk is not zero risk. Never leave fire or cigarette ends outdoors.';

  @override
  String get riskScoreNotProbability =>
      'This score does not say whether a fire will start.';

  @override
  String get riskScoresAreIndices =>
      'Scores are a 0–100 index. They do not say whether a fire will start.';

  @override
  String riskNearbyFireCount(String count) {
    return '$count recent nearby satellite detections.';
  }

  @override
  String get riskNearbyFireCountUnavailable =>
      'Recent nearby detection count is not yet available.';

  @override
  String riskPreviousScore(String score) {
    return 'Previous score: $score/100';
  }

  @override
  String riskCalculatedAt(String date) {
    return 'Calculated: $date';
  }

  @override
  String get riskSavedView => 'Saved view';

  @override
  String get riskServerUnreachable => 'Server unavailable. Showing saved data.';

  @override
  String riskServerUnreachableSavedAt(String date) {
    return 'Server unavailable. Last saved: $date';
  }

  @override
  String get riskRestorationCardTitle => 'Fire loss & restoration';

  @override
  String get riskRestorationCardSubtitle =>
      'Follow monthly burned-area data over time';

  @override
  String get riskHistoryCardTitle => 'Past fires';

  @override
  String get riskHistoryCardSubtitle =>
      'Past fire areas, dates and restoration updates';

  @override
  String get riskDistrictMapCardTitle => 'Province / district risk map';

  @override
  String get riskDistrictMapCardSubtitle =>
      'District-level risk scores and ranking';

  @override
  String get newsTabFires => 'Fires';

  @override
  String get newsTabRecovery => 'Recovery';

  @override
  String get newsTabSolidarity => 'Solidarity';

  @override
  String get newsTabEvents => 'Events';

  @override
  String get newsShowingSaved => 'Showing saved articles.';

  @override
  String get newsNoneInTab => 'No content in this category yet.';

  @override
  String get newsEventJoin => 'Join';

  @override
  String get newsDonate => 'Donate';

  @override
  String get newsAddToCalendar => 'Add to calendar';

  @override
  String get newsCalendarFailed => 'Could not open a calendar app.';

  @override
  String get newsLinkFailed => 'Could not open link.';

  @override
  String get annualLayerToggle => 'Past years';

  @override
  String annualLayerCaption(int year) {
    return 'Province colour: $year OGM burned area. Dots: current detections. A satellite dot is not a fire count.';
  }

  @override
  String get annualLayerLoadError =>
      'Could not load past-year files. Turn the layer off and on to retry.';

  @override
  String get riskDrynessIndexDerived =>
      'Dryness indicator (derived from temperature, humidity and wind)';

  @override
  String get riskVegetationDensityDerived =>
      'Vegetation pressure (derived from temperature and wind)';

  @override
  String get riskDrynessDerivation =>
      'Derived from temperature, humidity and wind.';

  @override
  String annualPastYearChip(int year) {
    return '$year · Past year';
  }

  @override
  String get annualNoData => 'No data';

  @override
  String get annualMetricOgmArea => 'OGM burned area';

  @override
  String get annualMetricOgmCount => 'OGM fire count';

  @override
  String get annualMetricSatellite => 'Satellite points';

  @override
  String get annualMetricEffisArea => 'EFFIS area';

  @override
  String get annualMetricOgmAreaDesc =>
      'Forest area burned, as recorded by OGM. Province colours always follow this value.';

  @override
  String get annualMetricOgmCountDesc =>
      'Number of forest fires recorded by OGM.';

  @override
  String get annualMetricSatelliteDesc =>
      'Satellite points are not a fire count. They are satellite detections over forest and shrubland.';

  @override
  String get annualMetricEffisAreaDesc =>
      'Burned area mapped by EFFIS from satellite imagery. Coverage of small fires can differ from OGM.';

  @override
  String get annualMetricExplainTitle => 'What the values mean';

  @override
  String get annualMetricExplainHint =>
      'Choosing one only changes the explanation; the province colour always shows OGM burned area.';

  @override
  String get annualProvinceNote =>
      'A satellite point is not a fire count. Province fills show the yearly province total, not fire perimeters.';

  @override
  String get annualLegendTitle => 'Past years · OGM burned area';

  @override
  String annualLegendTickMax(String value) {
    return '≥ $value ha';
  }

  @override
  String get annualLegendNote =>
      'Logarithmic colour scale · Darker means more area burned. Provinces without data are not filled. This layer is not current fire risk.';

  @override
  String get districtRiskRankingTitle => 'Risk ranking';

  @override
  String get districtRiskScoresNotProbability =>
      'Scores do not say whether a fire will start.';

  @override
  String get districtRiskSampleBanner =>
      'SAMPLE DATA · Shapes are schematic; not real district boundaries or current risk.';

  @override
  String get districtRiskLoadFailed =>
      'Could not load district risk data. Tap to retry.';

  @override
  String get districtRiskAllProvinces => 'Türkiye';

  @override
  String get districtRiskAllDistricts => 'All districts';

  @override
  String get districtRiskNoScore => 'No risk data';

  @override
  String get districtRiskOpenRanking => 'Open risk ranking';

  @override
  String get historyLoadFailed => 'Could not load fire history. Tap to retry.';

  @override
  String get historySourceOpenFailed => 'Could not open source.';

  @override
  String get historySampleRecord =>
      'SAMPLE RECORD — does not represent a real fire.';

  @override
  String get historyAreaUnknown => 'Area unavailable';

  @override
  String historyAreaPitches(String hectares, String pitches) {
    return '$hectares hectares — about $pitches football pitches.';
  }

  @override
  String get historyPitchComparison =>
      'Comparison: a 105 × 68 m pitch = 0.714 hectares.';

  @override
  String get historyAreaSource => 'Burnt-area source';

  @override
  String get historyRestorationTitle => 'Restoration';

  @override
  String get historyNoRestoration =>
      'No sourced restoration record is available for this area yet. This does not mean no work has taken place.';

  @override
  String get historyComparisonSource => 'Comparison source';

  @override
  String get historyOpenAnnouncement => 'Open official announcement';

  @override
  String get historyCampaignsTitle => 'Change starts with one person';

  @override
  String get historyNoCampaigns =>
      'No verified campaign or volunteer event has been added yet.';

  @override
  String get historyPeriodThisSummer => 'This summer';

  @override
  String get historyPeriodSinceLastSummer => 'Since last summer';

  @override
  String get historyPeriodLast3Years => 'Last 3 years';

  @override
  String get historyPeriodCustom => 'Custom range';

  @override
  String get historyNoRecords => 'No records in the selected range.';

  @override
  String get historySampleBanner =>
      'SAMPLE DATA · Shaded areas are schematic; not real fire perimeters.';

  @override
  String get historySourceSample =>
      'Source: sample data. Live source: NASA FIRMS (VIIRS/MODIS).';

  @override
  String get historySourceLive =>
      'Source: NASA FIRMS (VIIRS/MODIS) · satellite heat detections';

  @override
  String historyDetections(String count, String hours) {
    return '$count detections · $hours h';
  }

  @override
  String historyMaxFrp(String frp) {
    return 'Peak radiative power (FRP): $frp MW';
  }

  @override
  String get historyFootprintNote =>
      'The shape on the map traces where the satellite detected heat (188 m around each detection); it is not the burned-area boundary. Burned area is not measured, so no area is shown. Agricultural burns are included.';

  @override
  String get historyNearestDistrictNote =>
      'The district is the one whose centre is nearest the fire; near a border it can be the neighbouring district.';

  @override
  String get historyOpenFirmsMap => 'Open the NASA FIRMS map';

  @override
  String get historyFirmsAttribution =>
      'We acknowledge the use of data and/or imagery from NASA\'s Fire Information for Resource Management System (FIRMS) (https://earthdata.nasa.gov/firms), part of NASA\'s Land, Atmosphere Near real-time Capability for Earth observations (LANCE) (https://earthdata.nasa.gov/lance) and NASA\'s Earth Science Data and Information System (ESDIS).';

  @override
  String get detectionNotConfirmedNotice =>
      'This is a satellite heat detection, not a confirmed fire. If you see fire or smoke, call 112 right away.';

  @override
  String get riskFactorTempHintNone =>
      'Below 25°C, temperature adds nothing to the risk score.';

  @override
  String riskFactorTempHint(int points, int max) {
    return 'Adds +$points/$max to the risk score: heat makes vegetation lose moisture faster.';
  }

  @override
  String get riskFactorHumidityHintNone =>
      'Above 50%, humidity adds nothing to the risk score; damp vegetation ignites less easily.';

  @override
  String riskFactorHumidityHint(int points, int max) {
    return 'Adds +$points/$max to the risk score: low humidity dries out flammable vegetation.';
  }

  @override
  String get riskFactorWindHintNone =>
      'Below 10 km/h, wind adds nothing to the risk score.';

  @override
  String riskFactorWindHint(int points, int max) {
    return 'Adds +$points/$max to the risk score: wind can carry flames and embers.';
  }

  @override
  String riskNoteLightWind(int wind) {
    return 'Light wind ($wind km/h)';
  }

  @override
  String get newsFeaturedSubtitleLatest => 'Latest headline';

  @override
  String get homeBriefRiskLoading => 'Regional risk data is loading.';

  @override
  String get homeBriefRiskUnavailable =>
      'Regional risk data is unavailable right now.';

  @override
  String homeBriefRiskHighest(String region, int score) {
    return 'The highest regional risk is in $region: $score/100.';
  }

  @override
  String homeBriefNationwide(int count) {
    return '$count notable satellite detections are being monitored nationwide.';
  }

  @override
  String get homeBriefNoneNearby =>
      'No notable detection is visible within 100 km.';

  @override
  String homeBriefNearby(int count) {
    return '$count detections are within 100 km; check the map for details.';
  }

  @override
  String get homeBriefTitle => 'What should I know today?';

  @override
  String get homeBriefSubtitle => 'Quick situation brief';

  @override
  String get homeBriefViewRisk => 'View risk';

  @override
  String get homeBriefOpenMap => 'Open map';

  @override
  String get dataSourcesBordersTitle => 'Province boundaries';

  @override
  String get dataSourcesBordersBody =>
      'The 81 province boundaries drawn in the map\'s \"Past years\" layer and the ones the server uses to assign a detection to a province come from the same file: geoBoundaries (gbOpen, TUR ADM1), derived from OpenStreetMap data. They are simplified; a point very close to a border may fall in the neighbouring province. Points at sea or outside the borders are assigned to the nearest province.';

  @override
  String get dataSourcesBordersGeoBoundariesCredit =>
      'Province boundaries: geoBoundaries';

  @override
  String get annualLayerProvenance =>
      'Yearly province totals were calculated in the source data set (OGM forest fire statistics; NASA FIRMS VIIRS S-NPP with ESA WorldCover 2021; EFFIS). By that data set\'s own statement, its satellite point counts were calculated with GADM 4.1 province boundaries. The province boundaries drawn on the map are geoBoundaries / OpenStreetMap.';

  @override
  String get osmAttribution => '© OpenStreetMap contributors, ODbL';

  @override
  String get odblLicenseLink => 'ODbL 1.0 licence';

  @override
  String mapDetectionConfidence(int score) {
    return 'Detection confidence: $score/100';
  }

  @override
  String get mapDetectionConfidenceInfoTitle => 'Detection confidence';

  @override
  String get mapDetectionConfidenceInfoBody =>
      'Computed from NASA\'s confidence level, the strength of the detection, repeated detections within 20 km and how recent it is. Weather is not part of this score.';

  @override
  String get mapDetectionConfidenceInfoNotFire =>
      'This score shows how distinct a satellite detection is. It does not verify a fire there.';

  @override
  String get mapStrongUnverifiedReason =>
      'Satellites made a strong detection on a single pass; not verified.';

  @override
  String mapStrongUnverifiedBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count strong unverified detections — view on Points',
      one: '1 strong unverified detection — view on Points',
    );
    return '$_temp0';
  }

  @override
  String get multiPassDetectionLabel => 'Multi-pass detection';

  @override
  String get multiPassDetectionExplanation =>
      'Satellites made strong detections at the same spot on at least two separate passes. This does not verify a fire.';

  @override
  String homeMultiPassSubtitle(int weaker) {
    return 'At least 2 satellite passes; $weaker more weak detections under Points';
  }

  @override
  String homeMultiPassNote(int count, int weaker) {
    return '$count repeated detections (at least 2 satellite passes); the map shows $weaker more single-pass or weak detections. None of these is verified.';
  }

  @override
  String get incidentExtinguishedConflict =>
      'Official: extinguished — satellite still sees heat';

  @override
  String get fireDetailLinkedNews => 'News linked to this fire';

  @override
  String get osmTileAttribution => '© OpenStreetMap contributors';

  @override
  String get riskInfoFormulaHeatBonus =>
      'Extra points when heat and dry air coincide (max 20 pts)';

  @override
  String myPlacesRiskLine(String level, int score) {
    return 'Fire risk: $level ($score/100)';
  }

  @override
  String myPlacesDetections24h(int count) {
    return '$count detections in the last 24 hours';
  }

  @override
  String get myPlacesNoDetections =>
      'No detections nearby in the last 24 hours';

  @override
  String get myPlacesRiskNote =>
      'Risk is a score from the weather and nearby satellite detections. No detection does not mean no fire.';

  @override
  String get trackedPlacesEditTitle => 'Edit place';

  @override
  String get trackedPlacesNotifyHeat => 'Notify me of new heat detected nearby';

  @override
  String get trackedPlacesNotifyRisk => 'Notify me when fire risk rises';

  @override
  String get trackedPlacesNotifyRiskDesc =>
      'When it reaches High or Critical, at most once a day';

  @override
  String get placeSearchHint => 'Province, district, neighbourhood or address';

  @override
  String get placeSearchButton => 'Search';

  @override
  String get placeSearchRemote => 'Search as a neighbourhood or address';

  @override
  String get placeSearchNoResults =>
      'Nothing found. You can pick it on the map.';

  @override
  String get placeSearchFailed =>
      'Search isn\'t available right now. You can pick it on the map.';

  @override
  String get placeSearchTooShort => 'Type at least 3 letters.';

  @override
  String get placeSearchPrivacy =>
      'Province and district searches stay on your phone. Neighbourhood and address searches go through our server to OpenStreetMap; what you type is not stored.';

  @override
  String get placeSearchAttribution =>
      'Search results © OpenStreetMap contributors (Nominatim)';

  @override
  String get detectionNoneTitle =>
      'In the last 24 hours, satellites detected no strong heat in forest and natural areas in Türkiye.';

  @override
  String get detectionLimitNote =>
      'Satellites may miss small fires or fires under cloud.';

  @override
  String detectionLastUpdate(String time) {
    return 'Last update: $time';
  }

  @override
  String get detectionStaleTitle => 'Satellite data is out of date.';

  @override
  String get detectionStaleBody =>
      'So we can\'t say whether there are detections right now.';

  @override
  String get detectionUnavailableTitle => 'Couldn\'t get satellite data.';

  @override
  String get detectionUnavailableBody =>
      'This doesn\'t mean there are no detections. Check your connection and try again.';

  @override
  String get detectionCall112Line => 'If you see a fire, call 112 first.';

  @override
  String get detectionReportLine =>
      'If you notice a fire that isn\'t in the app, or an error, tell us with Report.';

  @override
  String get detectionReportButton => 'Report';

  @override
  String get detectionShowLast7Days => 'Show last 7 days';

  @override
  String get detectionOpenRisk => 'Turn on risk layer';

  @override
  String detectionLatest(String when, String city) {
    return 'Latest detection: $when, $city';
  }

  @override
  String detectionLatestNoCity(String when) {
    return 'Latest detection: $when';
  }

  @override
  String detectionDaysAgo(int days) {
    return '$days days ago';
  }

  @override
  String detectionHoursAgo(int hours) {
    return '$hours hours ago';
  }

  @override
  String get detectionJustNow => 'less than an hour ago';

  @override
  String get riskColorsNotFire =>
      'The colours show the risk of a fire starting, not fires.';

  @override
  String get mapRiskLayer => 'Risk';

  @override
  String get mapRiskLegendTitle => 'Risk score (by region)';

  @override
  String get mapRiskLegendLow => 'Low · 0–24';

  @override
  String get mapRiskLegendMedium => 'Medium · 25–49';

  @override
  String get mapRiskLegendHigh => 'High · 50–74';

  @override
  String get mapRiskLegendCritical => 'Critical · 75–100';

  @override
  String get mapRiskUnavailable => 'Couldn\'t get risk data.';

  @override
  String mapRiskRegionTap(String region, int score, String level) {
    return '$region: $score/100, $level';
  }

  @override
  String get reportPanelNotEmergency =>
      'This report is not passed to emergency services; in an emergency, call 112.';

  @override
  String get reportPanelTypeLabel => 'Report type';

  @override
  String get reportTypeFire => 'Fire sighting';

  @override
  String get reportTypeMissingFire => 'Fire not shown in the app';

  @override
  String get reportTypeWrongInfo => 'Wrong information/app error';

  @override
  String get reportPanelWrongInfoHint =>
      'Tell us what is wrong: which screen, what you saw, what it should be.';

  @override
  String get reportPanelWrongInfoNeedText => 'Please describe what is wrong.';

  @override
  String get reportPanelWrongInfoSent => 'Report received. Thank you.';

  @override
  String get riskTabPlaces => 'My Places';

  @override
  String get riskPointBack => 'Back to My Places';

  @override
  String get riskPointAdviceTitle => 'Advice';

  @override
  String get riskPointWhyTitle => 'Why this level';

  @override
  String get riskPointNearbyTitle => 'Nearby detections';

  @override
  String riskPointNearby(int km, int count) {
    return '$count satellite detections within $km km in the last 24 hours';
  }

  @override
  String riskPointNearbyNone(int km) {
    return 'No satellite detections within $km km in the last 24 hours. This does not mean there is no fire.';
  }

  @override
  String get riskPointNearbyUnknown =>
      'Nearby satellite detections are unknown right now; the score uses the weather only.';

  @override
  String riskPointCalculatedAt(String time) {
    return 'Calculated: $time';
  }

  @override
  String get riskPointUnavailable =>
      'Risk can\'t be calculated right now. Try again.';

  @override
  String get riskCopernicusTitle => 'Copernicus fire danger index';

  @override
  String get riskCopernicusNote =>
      'Separate from the FireWatch risk score, based on a weather model; it does not feed into the score.';

  @override
  String get riskCopernicusAttribution =>
      '© European Union, Copernicus EFFIS · CC BY 4.0';

  @override
  String get commonDetails => 'Details';

  @override
  String incidentPeakPowerDetail(String mw) {
    return 'Peak radiative power (FRP): $mw MW';
  }

  @override
  String get commonAllTechnical => 'All technical information';

  @override
  String dsStrong(String city) {
    return 'Satellites detected a strong fire signature near $city.';
  }

  @override
  String get dsStrongNoCity => 'Satellites detected a strong fire signature.';

  @override
  String dsNormal(String city) {
    return 'Satellites detected a fire signature near $city.';
  }

  @override
  String get dsNormalNoCity => 'Satellites detected a fire signature.';

  @override
  String get dsNotVerified => 'Not verified yet.';

  @override
  String get dsNewsVerified => 'Confirmed in the news.';

  @override
  String get dsFarmland => 'It is farmland, so it may also be stubble burning.';

  @override
  String get dsBuilt =>
      'It is an industrial or built-up area, so it may also be a fixed heat source.';

  @override
  String get dsSeenJustNow => 'Seen just now.';

  @override
  String dsSeenHours(int hours) {
    return 'Seen $hours hours ago.';
  }

  @override
  String dsSeenDays(int days) {
    return 'Seen $days days ago.';
  }

  @override
  String lastSeenHours(int hours) {
    return 'Last seen: $hours hours ago';
  }

  @override
  String lastSeenDays(int days) {
    return 'Last seen: $days days ago';
  }

  @override
  String incidentSeenPasses(int passes) {
    return 'Satellites saw this spot on $passes separate passes.';
  }

  @override
  String get incidentSeenOnce => 'Satellites saw this spot once.';

  @override
  String get newsVerifiedLabel => 'Confirmed in the news';

  @override
  String get relatedNewsTitle => 'Related news';

  @override
  String get mapPointFarmland => 'On farmland — may be stubble burning';

  @override
  String get mapPointBuilt =>
      'In an industrial or built-up area — may be a fixed heat source';

  @override
  String detectionOtherLine(int count) {
    return 'There are $count strong detections on farmland and industrial areas; they are on the Points layer.';
  }

  @override
  String get fireDetailBrightness =>
      'Surface brightness temperature measured by the satellite';

  @override
  String get fireDetailBrightnessNote =>
      'This is not the air temperature. It is the heat the satellite reads from the ground and does not show how hot a fire is.';

  @override
  String get homeTodayTitle => 'At your location today';

  @override
  String get homeNearbyNone =>
      'Satellites made no strong detection within 25 km.';

  @override
  String homeNearbySome(int count) {
    return 'Satellites made $count strong detections within 25 km.';
  }

  @override
  String homeWind(String speed) {
    return 'Wind: $speed km/h';
  }

  @override
  String get homeLocationNeeded =>
      'Turn on your location to see the risk where you are.';

  @override
  String get homeLocationOutside =>
      'Your location appears to be outside Türkiye.';

  @override
  String get homeLocationEnable => 'Turn on location';

  @override
  String get homeRiskUnavailable => 'Risk can\'t be calculated right now.';

  @override
  String homeTurkeyLine(int natural, int other) {
    return 'Last 24 hours: $natural strong detections in forest and natural areas, $other on farmland and industry.';
  }

  @override
  String get homeSeeOnMap => 'See on map';

  @override
  String get homeNewsTitle => 'News';

  @override
  String get newsNewBadge => 'New';

  @override
  String get coachMarksDisableAll => 'Turn off all tips';

  @override
  String get settingsTipsTitle => 'Tips';

  @override
  String get settingsTipsSubtitle => 'Show short tips on screens';

  @override
  String get pageAboutLink => 'About this page';

  @override
  String get dataSourcesLandCoverTitle => 'Land cover';

  @override
  String get dataSourcesLandCoverBody =>
      'Whether a detection is on forest, farmland or industry comes from the ESA WorldCover 2021 map, looking at the 750 metres around it. © ESA WorldCover project 2021 / Contains modified Copernicus Sentinel data (2021) processed by ESA WorldCover consortium. Licence: CC BY 4.0.';

  @override
  String get homeOverviewNewsNoFresh => 'No new articles';

  @override
  String get navNature => 'Nature';

  @override
  String natureSource(String name) {
    return 'Source: $name';
  }

  @override
  String get natureTodayTask => 'Today\'s task';

  @override
  String get natureTaskSaved => 'Saved. A new task will be here tomorrow.';

  @override
  String get natureYes => 'Done';

  @override
  String get natureNo => 'Not today';

  @override
  String get natureAnotherTask => 'Another task';

  @override
  String get natureShare => 'Share';

  @override
  String get naturePickProvince => 'Choose your province';

  @override
  String get natureProvince => 'Your province';

  @override
  String get natureOpenInat => 'Open iNaturalist';

  @override
  String natureProvinceStat(
    String province,
    int year,
    int hectares,
    int fires,
  ) {
    return 'OGM data for $province: $hectares hectares and $fires fires in $year.';
  }

  @override
  String natureShareRisk(String region, String level, int score) {
    return 'Fire risk in $region today: $level ($score/100). If you see a fire, call 112 first. FireWatch TR';
  }

  @override
  String natureStreak(int days) {
    return '$days days';
  }

  @override
  String get natureWeeklyChallenge => 'This week\'s goal';

  @override
  String get natureGoalDays => 'Look at your task on 4 days this week';

  @override
  String get natureGoalLesson => 'Finish a lesson';

  @override
  String get natureGoalShares => 'Share two facts or risk cards';

  @override
  String get natureFactTitle => 'Today\'s nature fact';

  @override
  String get natureLessons => 'Short lessons';

  @override
  String natureLessonLength(int cards) {
    return '$cards cards';
  }

  @override
  String get natureBadges => 'Badges';

  @override
  String get natureBadgeFirst => 'First step';

  @override
  String get natureBadgeSeven => 'Seven days';

  @override
  String get natureBadgeThirty => 'Thirty days';

  @override
  String get natureBadgeSeasons => 'Four seasons';

  @override
  String get natureBadgeCurious => 'Curious';

  @override
  String get natureBadgeAllLessons => 'Well informed';

  @override
  String get natureBadgeSharer => 'Sharer';

  @override
  String get natureBadgeObserver => 'Observer';

  @override
  String get natureOnDevice =>
      'Your progress is stored only on this phone and is not sent to any server. It is lost if you delete the app.';

  @override
  String get natureReminder => 'Daily reminder';

  @override
  String get natureReminderDesc => 'At most once a day';

  @override
  String get natureReminderText => 'Today\'s nature task is ready.';

  @override
  String get natureShowStreak => 'Show streak';

  @override
  String get natureDeleteTitle => 'Delete my Nature data';

  @override
  String get natureDeleteBody =>
      'Your tasks, streak, lessons and badges will be deleted from this phone. This cannot be undone.';

  @override
  String get natureDeleteConfirm => 'Delete';

  @override
  String get natureFinish => 'Finish';
}
