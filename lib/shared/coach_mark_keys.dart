import 'package:flutter/widgets.dart';

/// Shared GlobalKeys so the first-launch coach mark tour (built and shown
/// from MainShellScreen) can find and highlight widgets that live inside
/// other screens (HomeScreen's buttons, the bottom nav icons).
class CoachMarkKeys {
  static final mapNavIcon = GlobalKey();
  static final alertsNavIcon = GlobalKey();
  static final riskButton = GlobalKey();
  static final savedButton = GlobalKey();

  // Map screen
  static final mapArea = GlobalKey();
  static final mapClusterHint = GlobalKey();
  static final mapReportFab = GlobalKey();
  static final mapNearbyFiresSection = GlobalKey();

  // News screen
  static final newsFeatured = GlobalKey();
  static final newsCategoryFilters = GlobalKey();
  static final newsRegionFilters = GlobalKey();
  static final newsList = GlobalKey();

  // Notifications screen
  static final notifPermissionButton = GlobalKey();
  static final notifScanButton = GlobalKey();
  static final notifMonitoringButton = GlobalKey();
  static final notifAlertCards = GlobalKey();

  // Risk screen
  static final riskScoreCard = GlobalKey();
  static final riskChart = GlobalKey();
  static final riskMyLocationTab = GlobalKey();
  static final riskInfoButton = GlobalKey();

  // Watchlist screen
  static final watchlistHeader = GlobalKey();
  static final watchlistEmptyState = GlobalKey();
  static final watchlistClearButton = GlobalKey();
  static final watchlistList = GlobalKey();
}
