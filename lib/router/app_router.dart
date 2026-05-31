import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/emergency/emergency_screen.dart';
import '../features/fire_detail/fire_detail_screen.dart';
import '../features/home/main_shell_screen.dart';
import '../features/location_permission/location_permission_screen.dart';
import '../features/news/news_detail_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/risk/risk_screen.dart';
import '../features/safety/safety_guide_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/watchlist/watchlist_screen.dart';
import '../models/fire_event.dart';
import '../models/news_item.dart';

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
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/location-permission',
        builder: (context, state) => const LocationPermissionScreen(),
      ),
      GoRoute(
        path: '/app',
        builder: (context, state) {
          final tab = state.uri.queryParameters['tab'];
          int initialIndex = 0;
          switch (tab) {
            case 'map': initialIndex = 1; break;
            case 'news': initialIndex = 2; break;
            case 'alerts': initialIndex = 3; break;
            case 'settings': initialIndex = 4; break;
            default: initialIndex = 0;
          }
          return MainShellScreen(initialIndex: initialIndex);
        },
      ),
      GoRoute(
        path: '/map',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return MainShellScreen(
            initialIndex: 1,
            mapFocusLat: extra?['lat'] as double?,
            mapFocusLng: extra?['lng'] as double?,
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
        builder: (context, state) => const MainShellScreen(initialIndex: 0),
      ),
      GoRoute(
        path: '/news-detail',
        builder: (context, state) {
          final newsItem = state.extra as NewsItem;
          return NewsDetailScreen(newsItem: newsItem);
        },
      ),
      GoRoute(
        path: '/watchlist',
        builder: (context, state) => const WatchlistScreen(),
      ),
      GoRoute(
        path: '/risk',
        builder: (context, state) => const RiskScreen(),
      ),
      GoRoute(
        path: '/safety-guide',
        builder: (context, state) => const SafetyGuideScreen(),
      ),
      GoRoute(
        path: '/emergency',
        builder: (context, state) => const EmergencyScreen(),
      ),
    ],
  );
}