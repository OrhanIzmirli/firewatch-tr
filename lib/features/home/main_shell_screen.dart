import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/fire_incident.dart';
import '../../shared/coach_mark_keys.dart';
import '../../shared/widgets/coach_mark_overlay.dart';
import '../map/map_screen.dart';
import '../news/news_screen.dart';
import '../risk/risk_screen.dart';
import 'home_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/feedback_sheet.dart';
import '../../shared/widgets/app_sheet.dart';
import '../../shared/widgets/bottom_bar_fit.dart';
import '../nature/nature_screen.dart';

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
        title: DialogTitleWithClose(title: Text(l10n.ratingPromptTitle)),
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

  /// Tabs opened so far in this session; only these are built.
  final Set<int> _visitedTabs = {};

  List<Widget> get _screens => [
    const HomeScreen(),
    MapScreen(
      // Tabs now stay alive; a new focus (a notification tap, a "show on
      // map" link) must still land, so a different focus is a new map.
      key: ValueKey('map:${widget.mapFocusLat}:${widget.mapFocusLng}:${widget.mapConfidenceFilter}:${widget.mapIncidentFilter}'),
      focusLat: widget.mapFocusLat,
      focusLng: widget.mapFocusLng,
      initialConfidenceFilter: widget.mapConfidenceFilter,
      initialIncidentFilter: widget.mapIncidentFilter,
    ),
    const RiskScreen(),
    const NewsScreen(),
    const NatureScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
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
            icon: const Icon(Icons.shield_outlined),
            selectedIcon: const Icon(Icons.shield),
            label: l10n.navRisk,
          ),
          NavigationDestination(
            icon: const Icon(Icons.newspaper_outlined),
            selectedIcon: const Icon(Icons.newspaper),
            label: l10n.navNews,
          ),
          NavigationDestination(
            icon: const Icon(Icons.eco_outlined),
            selectedIcon: const Icon(Icons.eco),
            label: l10n.navNature,
          ),
        ];

        final screens = _screens;
        _visitedTabs.add(_currentIndex);
        return Scaffold(
          // Each tab is built the first time it is opened and then kept:
          // recreating it on every switch refetched everything (Home alone
          // made four API calls plus a location fix per visit).
          body: IndexedStack(
            index: _currentIndex,
            children: [
              for (final (i, screen) in screens.indexed)
                _visitedTabs.contains(i) ? screen : const SizedBox.shrink(),
            ],
          ),
          bottomNavigationBar: BottomBarFit(
            tabs: destinations.length,
            child: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() => _currentIndex = index);
              },
              destinations: destinations,
            ),
          ),
        );
      },
    );
  }
}
