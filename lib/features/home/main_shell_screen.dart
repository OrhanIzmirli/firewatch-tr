import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_theme.dart';
import '../../models/fire_incident.dart';
import '../../services/fire_monitoring_service.dart';
import '../../shared/coach_mark_keys.dart';
import '../../shared/widgets/coach_mark_overlay.dart';
import '../map/map_screen.dart';
import '../news/news_screen.dart';
import '../notifications/notifications_screen.dart';
import '../settings/settings_screen.dart';
import 'home_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/feedback_sheet.dart';

class MainShellScreen extends StatefulWidget {
  final int initialIndex;
  final double? mapFocusLat;
  final double? mapFocusLng;
  final bool mapConfidenceFilter;
  final IncidentFilter? mapIncidentFilter;

  const MainShellScreen({
    super.key,
    this.initialIndex = 0,
    this.mapFocusLat,
    this.mapFocusLng,
    this.mapConfidenceFilter = false,
    this.mapIncidentFilter,
  });

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, 4);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _maybePromptForRating(),
    );
    if (_currentIndex == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // Give the Home tab's first frame a moment to settle before measuring targets.
        await Future.delayed(const Duration(milliseconds: 400));
        if (!mounted) return;
        await maybeShowCoachMarks(context);
      });
    }
  }

  Future<void> _maybePromptForRating() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final raw = prefs.getString('first_launch_date');
    if (raw == null) {
      await prefs.setString('first_launch_date', now.toIso8601String());
      return;
    }
    if (prefs.getBool('rating_prompt_shown') == true) return;
    final first = DateTime.tryParse(raw);
    if (first == null || now.difference(first).inDays < 3 || !mounted) return;
    await prefs.setBool('rating_prompt_shown', true);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final open = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.ratingPromptTitle),
        content: Text(l10n.ratingPromptMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.ratingPromptLater),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.feedbackSend),
          ),
        ],
      ),
    );
    if (open == true && mounted) await showFeedbackSheet(context);
  }

  @override
  void didUpdateWidget(covariant MainShellScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      _currentIndex = widget.initialIndex.clamp(0, 4);
    }
  }

  List<Widget> get _screens => [
    const HomeScreen(),
    MapScreen(
      focusLat: widget.mapFocusLat,
      focusLng: widget.mapFocusLng,
      initialConfidenceFilter: widget.mapConfidenceFilter,
      initialIncidentFilter: widget.mapIncidentFilter,
    ),
    const NewsScreen(),
    const NotificationsScreen(),
    const SettingsScreen(),
  ];

  Widget _alertsIcon(bool selected, int unreadCount, {Key? key}) {
    final icon = Icon(
      selected ? Icons.notifications : Icons.notifications_none,
    );
    final child = unreadCount <= 0
        ? icon
        : Badge(
            // A live counter: tabular figures so the badge width is stable
            // while the count changes.
            label: Text(
              unreadCount > 9 ? '9+' : '$unreadCount',
              style: AppTheme.mono(size: 11, weight: FontWeight.w600),
            ),
            child: icon,
          );
    return key == null ? child : KeyedSubtree(key: key, child: child);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List>(
      valueListenable: FireMonitoringService.instance.nearbyMatchesNotifier,
      builder: (context, nearbyMatches, _) {
        final l10n = AppLocalizations.of(context)!;
        final destinations = [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: KeyedSubtree(
              key: CoachMarkKeys.mapNavIcon,
              child: const Icon(Icons.map_outlined),
            ),
            selectedIcon: const Icon(Icons.map),
            label: l10n.navMap,
          ),
          NavigationDestination(
            icon: const Icon(Icons.newspaper_outlined),
            selectedIcon: const Icon(Icons.newspaper),
            label: l10n.navNews,
          ),
          NavigationDestination(
            icon: _alertsIcon(
              false,
              nearbyMatches.length,
              key: CoachMarkKeys.alertsNavIcon,
            ),
            selectedIcon: _alertsIcon(true, nearbyMatches.length),
            label: l10n.navAlerts,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.navSettings,
          ),
        ];

        return Scaffold(
          body: _screens[_currentIndex],
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() => _currentIndex = index);
            },
            destinations: destinations,
          ),
        );
      },
    );
  }
}
