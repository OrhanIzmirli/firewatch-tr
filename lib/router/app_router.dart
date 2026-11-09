import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/config/feature_flags.dart';

import '../features/emergency/emergency_screen.dart';
import '../features/fire_detail/fire_deep_link_screen.dart';
import '../features/fire_detail/fire_detail_screen.dart';
import '../features/home/main_shell_screen.dart';
import '../features/language_selection/language_selection_screen.dart';
import '../features/location_permission/location_permission_screen.dart';
import '../features/news/news_detail_screen.dart';
import '../features/nature/fidan_screen.dart';
import '../features/notification_permission/notification_permission_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/risk/risk_screen.dart';
import '../features/history/history_screen.dart';
import '../features/restoration/restoration_screen.dart';
import '../features/risk/district_risk_screen.dart';
import '../features/safety/safety_guide_screen.dart';
import '../features/settings/data_sources_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/watchlist/watchlist_screen.dart';
import '../models/fire_event.dart';
import '../models/fire_incident.dart';
import '../models/news_item.dart';
import '../features/tracked_places/tracked_places_screen.dart';
import '../features/notifications/notifications_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/language-selection',
        builder: (context, state) => const LanguageSelectionScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/location-permission',
        builder: (context, state) => const LocationPermissionScreen(),
      ),
      GoRoute(
        path: '/notification-permission',
        builder: (context, state) => const NotificationPermissionScreen(),
      ),
      GoRoute(
        path: '/app',
        redirect: (context, state) {
          final query = state.uri.queryParameters;
          if (query['tab'] == 'settings') return '/settings';
          // Alerts used to be a tab; old links and notification taps land here.
          if (query['tab'] == 'alerts' || query['section'] == 'alerts') return '/alerts';
          if (query['tab'] == 'nature') return '/fidan';
          return null;
        },
        // NoTransitionPage: these routes only ever swap between the same
        // MainShellScreen at a different tab index (via context.go, never
        // push), so there's no "previous screen" to animate away from.
        // An animated MaterialPage transition would otherwise keep the
        // outgoing and incoming MainShellScreen briefly mounted together,
        // which is enough for their bottom-nav icons' static GlobalKeys
        // (CoachMarkKeys.mapNavIcon/alertsNavIcon) to collide.
        pageBuilder: (context, state) {
          // Notification taps without a fire id arrive as ?section=alerts.
          final tab = state.uri.queryParameters['tab'] ??
              state.uri.queryParameters['section'];
          int initialIndex = 0;
          switch (tab) {
            case 'map': initialIndex = 1; break;
            case 'risk': initialIndex = 2; break;
            case 'news': initialIndex = 3; break;
            default: initialIndex = 0;
          }
          return NoTransitionPage(child: MainShellScreen(initialIndex: initialIndex));
        },
      ),
      GoRoute(
        path: '/map',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return NoTransitionPage(
            child: MainShellScreen(
              initialIndex: 1,
              mapFocusLat: extra?['lat'] as double?,
              mapFocusLng: extra?['lng'] as double?,
              mapConfidenceFilter: extra?['confidenceFilter'] as bool? ?? false,
              // Only overrides the stored choice when the caller asks for a
              // specific slice; absent means "leave the user's filter alone".
              mapIncidentFilter: extra?['incidentFilter'] == null
                  ? null
                  : IncidentFilterX.fromStorage(
                      extra!['incidentFilter'] as String?,
                    ),
            ),
          );
        },
      ),
      GoRoute(
        path: '/fire-detail',
        builder: (context, state) {
          final fireEvent = state.extra as FireEvent;
          return FireDetailScreen(fireEvent: fireEvent);
        },
      ),
      GoRoute(
        path: '/fire/:id',
        builder: (context, state) => FireDeepLinkScreen(fireId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: '/news-detail',
        builder: (context, state) {
          final newsItem = state.extra as NewsItem;
          return NewsDetailScreen(newsItem: newsItem);
        },
      ),
      // Where the tracked-places summary push lands.
      GoRoute(
        path: '/tracked-places',
        builder: (context, state) => const TrackedPlacesScreen(),
      ),
      GoRoute(
        path: '/watchlist',
        builder: (context, state) => const WatchlistScreen(),
      ),
      GoRoute(
        path: '/risk',
        builder: (context, state) => RiskScreen(highlightRegion: state.extra as String?),
      ),
      // Sample-data and placeholder screens are debug-only until their
      // data source exists (see FeatureFlags); a stale deep link lands on
      // the risk tab instead.
      GoRoute(
        path: '/risk-map',
        redirect: (context, state) => FeatureFlags.districtRiskMap ? null : '/app?tab=risk',
        builder: (context, state) => const DistrictRiskScreen(),
      ),
      GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
      GoRoute(
        path: '/history',
        redirect: (context, state) => FeatureFlags.fireHistory ? null : '/app?tab=risk',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/restoration',
        redirect: (context, state) => FeatureFlags.restoration ? null : '/app?tab=risk',
        builder: (context, state) => const RestorationScreen(),
      ),
      GoRoute(
        path: '/data-sources',
        builder: (context, state) => const DataSourcesScreen(),
      ),
      GoRoute(
        path: '/safety-guide',
        builder: (context, state) => const SafetyGuideScreen(),
      ),
      GoRoute(path: '/fidan', builder: (context, state) => const FidanScreen()),
      GoRoute(
        path: '/alerts',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/emergency',
        builder: (context, state) => const EmergencyScreen(),
      ),
    ],
  );
}
