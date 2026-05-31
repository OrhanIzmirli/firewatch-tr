import 'package:flutter/material.dart';

import '../map/map_screen.dart';
import '../news/news_screen.dart';
import '../notifications/notifications_screen.dart';
import '../settings/settings_screen.dart';
import 'home_screen.dart';

class MainShellScreen extends StatefulWidget {
  final int initialIndex;
  final double? mapFocusLat;
  final double? mapFocusLng;

  const MainShellScreen({
    super.key,
    this.initialIndex = 0,
    this.mapFocusLat,
    this.mapFocusLng,
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
    ),
    const NewsScreen(),
    const NotificationsScreen(),
    const SettingsScreen(),
  ];

  final List<NavigationDestination> _destinations = const [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.map_outlined),
      selectedIcon: Icon(Icons.map),
      label: 'Map',
    ),
    NavigationDestination(
      icon: Icon(Icons.newspaper_outlined),
      selectedIcon: Icon(Icons.newspaper),
      label: 'News',
    ),
    NavigationDestination(
      icon: Icon(Icons.notifications_none),
      selectedIcon: Icon(Icons.notifications),
      label: 'Alerts',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: _destinations,
      ),
    );
  }
}