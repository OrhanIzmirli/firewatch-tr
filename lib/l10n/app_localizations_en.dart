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
  String get homeHeaderTitle => 'Turkey Thermal Anomaly Tracking';

  @override
  String get homeHeaderSubtitle =>
      'Track active events, see risk levels, and quickly reach the safety guide.';

  @override
  String get homeNasaLiveData => 'NASA FIRMS • Live Data';

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
  String get homeOverviewSubtitle => 'NASA FIRMS live data';

  @override
  String homeOverviewUniqueCount(int count) {
    return '$count unique thermal anomaly locations detected';
  }

  @override
  String get homeTotalPoints => 'Total Points';

  @override
  String get homeHighRisk => 'High Risk';

  @override
  String get homeNominal => 'Nominal';

  @override
  String get homeOverviewActiveFiresTitle => 'Recent Thermal Anomalies';

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
  String get homeOverviewNearbyTitle => 'Nearby Thermal Detections';

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
    return 'Last update: $timeAgo';
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
  String get homeNoActiveFires => 'No recent thermal anomalies found.';

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
  String get mapTitle => 'Thermal Anomaly Map';

  @override
  String get mapTitleEvents => 'Fire Map';

  @override
  String get mapTitleDetections => 'Thermal Detection Map';

  @override
  String get mapLiveMap => 'Live Map';

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
  String get mapAreaSubtitle => 'NASA FIRMS live marker view';

  @override
  String get mapGoToMe => 'Go to Me';

  @override
  String get mapNearbyFires => 'Thermal Detections Near Me';

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
      'Manage permission and automatic thermal-anomaly monitoring';

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
      'Check for fires every 15 minutes even when the app is closed';

  @override
  String get notificationsEnableBackground => 'Enable Background Monitoring';

  @override
  String get notificationsDisableBackground => 'Disable Background Monitoring';

  @override
  String get backgroundLocationDialogTitle => 'Background Location Permission';

  @override
  String get backgroundLocationDialogBody =>
      'FireWatch TR wants to access your location in the background so it can check for nearby fires and alert you even when the app is closed. If you don\'t grant this, the app can only scan while it\'s open. On the system permission screen, choose \"Allow all the time\".';

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
  String get notificationsNearbyLiveFires => 'Nearby Thermal Detections';

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
      'No high-confidence thermal anomalies right now.';

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
    return '$count thermal detections being tracked';
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
      'NASA FIRMS. VIIRS (Suomi-NPP, NOAA-20, NOAA-21) and MODIS (Terra, Aqua), passing over several times a day. Each detection is one hot pixel: its position, radiative power (FRP, in megawatts), brightness temperature and NASA\'s own confidence tier are measured values. An event\'s panel lists which product contributed how many detections.';

  @override
  String get dataSourcesGroupingTitle => 'Events — computed';

  @override
  String get dataSourcesGroupingBody =>
      'Pixels of the same fire are clustered within 1.2 km across passes into a single event. Duration, pass count and peak power come from that grouping. Duration is capped by the two-day data window, which is why it is always written as \"at least\" — a source burning for a month still reports about a day.';

  @override
  String get dataSourcesDerivedTitle => 'Derived — not measured';

  @override
  String get dataSourcesDerivedBody =>
      'Spread direction and speed are computed from how the centre of the detection pattern shifted; the fire\'s real movement may differ. \"Detection pixel ~N hectares\" is the satellite\'s resolution, not the burnt area: the fire is somewhere inside that pixel and its real size is unknown. That figure grows with the satellite\'s viewing angle, not with the fire.';

  @override
  String get dataSourcesNotKnownTitle => 'Not knowable';

  @override
  String get dataSourcesNotKnownBody =>
      'Whether a fire is out, contained or safe cannot be derived from satellite data. Satellites cannot see through cloud or smoke, so no detection means only that nothing was seen. This app makes no such claim — it appears only when an official source confirms it, shown with that source.';

  @override
  String get dataSourcesWeatherTitle => 'Regional risk — a separate source';

  @override
  String get dataSourcesWeatherBody =>
      'Risk scores are computed region-wide from weather data. They are not a measurement of any single fire and do not predict how one will behave.';

  @override
  String get settingsAppInfo => 'App Information';

  @override
  String get settingsAppInfoSubtitle => 'Version and product summary';

  @override
  String get settingsInfoApp => 'App';

  @override
  String get settingsInfoVersion => 'Version';

  @override
  String get settingsInfoVersionValue => 'v1.0.0';

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
  String get reportPanelVerifiedTitle => 'Report Verified';

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
  String get reportPanelAnonymousToggle => 'Submit anonymously';

  @override
  String get reportPanelAnonymousToggleSubtitle =>
      'Your name won\'t be shared with authorities';

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
  String get reportPanelSuccessVerifiedTitle => 'Report Verified';

  @override
  String get reportPanelSuccessReceivedTitle => 'Report Received';

  @override
  String get reportPanelSuccessVerifiedBody =>
      'Your report matched NASA satellite data and has been marked as verified.';

  @override
  String get reportPanelSuccessReceivedBody =>
      'Your report was recorded and is pending manual review by our team.';

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
      'This is an active fire zone — emergency services have already been notified.';

  @override
  String get reportPanelResponseTimeReceived =>
      'If this is an active emergency, please also call 112 directly.';

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
  String get fireStatusActive => 'Probable Fire';

  @override
  String get fireStatusLikelyActive => 'High Thermal Anomaly';

  @override
  String get fireStatusMonitoring => 'Monitoring';

  @override
  String get fireStatusHistorical => 'Historical Detection';

  @override
  String fireEventRegionTitle(String city) {
    return '$city Region Thermal Detection';
  }

  @override
  String get fireEventLiveDetectionTitle => 'Live Thermal Detection';

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
    return 'Detection pixel ~$hectares hectares (not the fire itself)';
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
      'No thermal anomaly data found right now.';

  @override
  String monitorStatusNoNearbyFires(int count) {
    return 'No thermal detections within 50 km. ($count points scanned)';
  }

  @override
  String monitorStatusNearbyFiresFound(int count) {
    return '$count thermal detections found within 50 km!';
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
  String get notifNearbyFireTitle => 'Thermal anomaly detected nearby';

  @override
  String notifNearbyFireBody(String distance, int count) {
    return '$count thermal detections found within $distance.';
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
    return 'PostGIS • $distance km away';
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
  String get riskInfoFormulaFireCount => 'NASA Fire Count (max 20 pts)';

  @override
  String get riskInfoSourcesTitle => 'Data Sources';

  @override
  String get riskInfoSourcesBody =>
      'Calculated using NASA FIRMS satellite data, Open-Meteo weather data, and RSS news feeds.';

  @override
  String get riskInfoUpdateFrequencyTitle => 'Update Frequency';

  @override
  String get riskInfoUpdateFrequencyBody =>
      'Risk scores are recalculated every 3 hours.';

  @override
  String get trustHomeInfo =>
      'Data sourced from NASA FIRMS satellite imagery, updated every 3 hours.';

  @override
  String get trustMapInfo =>
      'Fire markers show thermal anomalies detected by the VIIRS satellite.';

  @override
  String get trustRiskInfo =>
      'Risk scores are calculated from real-time weather and NASA fire data.';

  @override
  String get trustNewsInfo =>
      'News is filtered for wildfire-related content from 9 Turkish sources.';

  @override
  String get trustAlertsInfo =>
      'Notifications are sent when a fire is detected within 50km of your location.';

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
      'Counts are satellite thermal anomalies from the last 24 hours, not confirmed wildfires. Some may be agricultural burns, industrial heat, or hot surfaces.';

  @override
  String get trustHomeSource =>
      'Data comes from NASA FIRMS (Fire Information for Resource Management System), combining VIIRS and MODIS satellite passes, refreshed every 3 hours.';

  @override
  String get trustHomeInterpret =>
      'Only a high-confidence detection above 30 MW FRP and 350 K is labelled Probable Fire. All other points remain thermal anomalies.';

  @override
  String get trustHomeAction =>
      'Tap a detection for confidence, FRP, and limitations. If you see smoke or flames, follow official emergency guidance and report what you observe.';

  @override
  String get trustMapMeaning =>
      'Each marker is a satellite thermal anomaly, not a confirmed fire. Red means Probable Fire; orange high anomaly; yellow nominal; gray low confidence.';

  @override
  String get trustMapSource =>
      'Fire data sourced from NASA FIRMS (VIIRS & MODIS satellites). Secondary verification via EFFIS (Copernicus Emergency Management Service) will be added when their API is restored.';

  @override
  String get trustMapInterpret =>
      'Clusters only mean multiple heat detections are close together. They do not by themselves confirm the cause or size of a fire.';

  @override
  String get trustMapAction =>
      'Tap a marker to review confidence and FRP. If you personally observe a fire, use Report and follow official emergency instructions.';

  @override
  String get trustRiskMeaning =>
      'The risk score (0-100) estimates wildfire likelihood by combining temperature, humidity, wind speed, and dryness — it is a forecast, not a guarantee.';

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
      'Alerts notify you when a satellite detects a thermal anomaly within 50 km. They are automated, not verified incident reports.';

  @override
  String get trustAlertsSource =>
      'Background monitoring checks NASA FIRMS data on a schedule and compares new detections against your device\'s last known location.';

  @override
  String get trustAlertsInterpret =>
      'Confidence describes confidence in a heat anomaly, not certainty that it is a fire. Check FRP and brightness together.';

  @override
  String get trustAlertsAction =>
      'Grant notification permission and start Auto Monitoring while using the app. Use \"Scan Now\" anytime to manually check your surroundings.';

  @override
  String get newsReadFullArticle => 'Read Full Article';

  @override
  String smartIntensityIntense(String location) {
    return 'An intense thermal anomaly was detected near $location.';
  }

  @override
  String smartIntensityHigh(String location) {
    return 'A high-intensity thermal anomaly was detected near $location.';
  }

  @override
  String smartIntensityModerate(String location) {
    return 'Moderate thermal activity was detected near $location.';
  }

  @override
  String smartIntensityEarly(String location) {
    return 'This may be an early-stage fire or smoldering vegetation near $location.';
  }

  @override
  String smartIntensityAnomaly(String location) {
    return 'A thermal anomaly was detected near $location.';
  }

  @override
  String get smartLocationHintForest => 'a high-risk forest area';

  @override
  String get smartLocationHintCoastal => 'a coastal area';

  @override
  String get smartLocationHintUrban =>
      'an urban area — could be a structure fire or industrial heat source';

  @override
  String get smartLocationHintAgricultural =>
      'farmland — possible crop or stubble burning';

  @override
  String get smartFrpHigh =>
      'A high Fire Radiative Power (FRP) reading indicates significant energy release.';

  @override
  String smartPixelFootprint(int hectares) {
    return 'The satellite pixel is ~$hectares hectares; the fire is somewhere inside it and its real size is unknown.';
  }

  @override
  String smartAreaLarge(int hectares) {
    return 'Estimated fire area is large (~$hectares hectares).';
  }

  @override
  String smartAreaMedium(int hectares) {
    return 'Estimated fire area is medium-sized (~$hectares hectares).';
  }

  @override
  String get smartConfidenceHigh =>
      'NASA has high confidence this is a real thermal anomaly; its cause is not confirmed.';

  @override
  String get smartConfidenceMedium =>
      'NASA reports nominal confidence in this thermal anomaly; verification is recommended.';

  @override
  String get smartConfidenceLow =>
      'A possible thermal anomaly — could be industrial heat or reflection, verification needed.';

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
    return 'Detected $hours hours ago by $satellite — may still be active.';
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
      'VIIRS: Suomi NPP satellite, passes over Turkey 1-2 times a day.';

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
  String get coachMarkMapMarkersTitle => 'Fire Markers';

  @override
  String get coachMarkMapMarkersDesc =>
      'Flame icons on the map show live fire detections from NASA satellites. Tap one to see details.';

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
  String get coachMarkMapNearbyTitle => 'Fires Near Me';

  @override
  String get coachMarkMapNearbyDesc =>
      'This section lists the live fire detections closest to your location, sorted by distance.';

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
      'Grant permission to get instant alerts about fires near you.';

  @override
  String get coachMarkNotifScanTitle => 'Scan Now';

  @override
  String get coachMarkNotifScanDesc =>
      'Instantly check whether there are live fires within 50 km of your location.';

  @override
  String get coachMarkNotifMonitoringTitle => 'Auto Monitoring';

  @override
  String get coachMarkNotifMonitoringDesc =>
      'Start auto monitoring to periodically check nearby thermal detections while the app is open.';

  @override
  String get coachMarkNotifAlertsTitle => 'Alert Cards';

  @override
  String get coachMarkNotifAlertsDesc =>
      'High-risk detections are listed here — tap a card to see the full details.';

  @override
  String get coachMarkRiskScoreTitle => 'Risk Score';

  @override
  String get coachMarkRiskScoreDesc =>
      'This 0-100 score is calculated from temperature, humidity, wind, and NASA fire data. Tap the info button to see exactly how.';

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
      'Keep the fire points you want to follow all in one place here.';

  @override
  String get coachMarkWatchlistHowToAddTitle => 'How to Add';

  @override
  String get coachMarkWatchlistHowToAddDesc =>
      'Tap the bookmark button on a fire\'s detail screen to save it here.';

  @override
  String get coachMarkWatchlistClearTitle => 'Clear';

  @override
  String get coachMarkWatchlistClearDesc =>
      'Use the Clear button in the top corner to remove all saved points at once.';

  @override
  String get detectionProbableFire => 'Probable Fire';

  @override
  String get detectionHighThermalAnomaly => 'High Thermal Anomaly';

  @override
  String get detectionThermalDetection => 'Thermal Detection';

  @override
  String get detectionLowConfidence => 'Low Confidence Detection';

  @override
  String get thermalAnomalyDisclaimer =>
      'NASA satellite detects thermal anomalies. High-confidence detections may indicate active fires, but industrial heat sources can also be detected.';

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
  String get legendProbableFire => 'Probable Fire';

  @override
  String get legendHighThermal => 'High Thermal Anomaly';

  @override
  String get legendLowConfidence => 'Low Confidence';

  @override
  String get mapMarkerDisclaimerBefore =>
      'The map shows NASA satellite thermal detections.';

  @override
  String get mapMarkerDisclaimerAfter => 'markers may indicate an active fire.';

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
      'Tap a saved fire to see its current status and full details.';

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
  String get incidentsSectionTitle => 'Fire Events';

  @override
  String get incidentsSectionSubtitle =>
      'Satellite detections grouped into events';

  @override
  String get incidentStatusActive => 'Active detection';

  @override
  String get incidentStatusAwaiting => 'Awaiting detection';

  @override
  String get incidentStatusLowConfidence => 'Low confidence';

  @override
  String incidentDetectedHoursAgo(String hours) {
    return 'Detected within the last $hours hours';
  }

  @override
  String incidentNoDetectionFor(String hours) {
    return 'Fire detected, not seen for $hours hours';
  }

  @override
  String incidentNoDetectionLowConfidence(String hours) {
    return 'Fire detected, not seen for $hours hours (low confidence)';
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
  String get incidentHeatLow => 'Low';

  @override
  String get incidentHeatModerate => 'Moderate';

  @override
  String get incidentHeatHigh => 'High';

  @override
  String get incidentHeatVeryHigh => 'Very high';

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
  String get incidentToggleShow => 'Fire events';

  @override
  String get incidentToggleDetections => 'Possible fire points';

  @override
  String get incidentLayerCaptionDetections =>
      'Individual hot spots the satellite saw; not every one is a fire.';

  @override
  String get incidentLayerCaptionEvents =>
      'Detections of the same fire grouped into a single event.';

  @override
  String get incidentFilterActive => 'Active';

  @override
  String get incidentFilterEnded => 'No longer seen';

  @override
  String get incidentFilterAll => 'All';

  @override
  String get homeLast24hTitle => 'Last 24 Hours';

  @override
  String get homeLast24hSubtitle => 'Summary of satellite detections';

  @override
  String get homeLast24hActiveTitle => 'Active detection';

  @override
  String homeLast24hActiveSubtitle(int hours) {
    return 'Seen by a satellite within the last $hours hours';
  }

  @override
  String get homeLast24hEndedTitle => 'Detection ended';

  @override
  String get homeLast24hEndedSubtitle => 'Not a claim that they are out.';

  @override
  String get homeLast24hLongestTitle => 'Longest running';

  @override
  String get homeLast24hLongestSubtitle =>
      'Since first detection, still being detected';

  @override
  String get homeLast24hStrongestTitle => 'Most intense fire';

  @override
  String homeLast24hStrongestPower(int mw) {
    return '$mw MW';
  }

  @override
  String get homeLast24hStrongestSubtitle =>
      'Highest heat output right now, still being detected';

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
  String get incidentsEmpty => 'No grouped fire events in this range.';

  @override
  String incidentsCount(int count) {
    return '$count events';
  }

  @override
  String get incidentPanelTitle => 'Fire Event';

  @override
  String get incidentOfficialTitle => 'Official status';

  @override
  String get incidentSatelliteLimitNote =>
      'Satellites pass a few times a day and cannot see through cloud or smoke. No detection does not mean the fire is over.';

  @override
  String get incidentFixedSourceHint =>
      'This location has appeared on every satellite pass for two days at unchanging power — it may be a fixed heat source.';

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
}
