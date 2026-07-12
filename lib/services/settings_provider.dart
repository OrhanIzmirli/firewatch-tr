import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'notification_service.dart';

class SettingsState {
  final bool pushNotificationsEnabled;
  final bool nearbyAlertsEnabled;
  final bool darkModeEnabled;
  final String refreshInterval;
  final bool isLoaded;

  const SettingsState({
    required this.pushNotificationsEnabled,
    required this.nearbyAlertsEnabled,
    required this.darkModeEnabled,
    required this.refreshInterval,
    required this.isLoaded,
  });

  SettingsState copyWith({
    bool? pushNotificationsEnabled,
    bool? nearbyAlertsEnabled,
    bool? darkModeEnabled,
    String? refreshInterval,
    bool? isLoaded,
  }) {
    return SettingsState(
      pushNotificationsEnabled:
      pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      nearbyAlertsEnabled:
      nearbyAlertsEnabled ?? this.nearbyAlertsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      refreshInterval: refreshInterval ?? this.refreshInterval,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }

  static const SettingsState initial = SettingsState(
    pushNotificationsEnabled: true,
    nearbyAlertsEnabled: true,
    darkModeEnabled: true,
    refreshInterval: '15 dk',
    isLoaded: false,
  );
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState.initial) {
    _loadSettings();
  }

  static const _pushNotificationsKey = 'settings_push_notifications';
  static const _nearbyAlertsKey = 'settings_nearby_alerts';
  static const _darkModeKey = 'settings_dark_mode';
  static const _refreshIntervalKey = 'settings_refresh_interval';

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    state = state.copyWith(
      pushNotificationsEnabled:
      prefs.getBool(_pushNotificationsKey) ?? true,
      nearbyAlertsEnabled:
      prefs.getBool(_nearbyAlertsKey) ?? true,
      darkModeEnabled:
      prefs.getBool(_darkModeKey) ?? true,
      refreshInterval:
      prefs.getString(_refreshIntervalKey) ?? '15 dk',
      isLoaded: true,
    );
  }

  Future<void> togglePushNotifications(bool value) async {
    state = state.copyWith(pushNotificationsEnabled: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pushNotificationsKey, value);
    // Best-effort: keep the backend's is_active flag in sync so automatic
    // region/critical alerts stop reaching this device the moment the user
    // opts out, without blocking the UI toggle on network round-trip.
    unawaited(NotificationService.instance.setPushEnabled(value));
  }

  Future<void> toggleNearbyAlerts(bool value) async {
    state = state.copyWith(nearbyAlertsEnabled: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_nearbyAlertsKey, value);
  }

  Future<void> toggleDarkMode(bool value) async {
    state = state.copyWith(darkModeEnabled: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }

  Future<void> setRefreshInterval(String value) async {
    state = state.copyWith(refreshInterval: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshIntervalKey, value);
  }
}

final settingsProvider =
StateNotifierProvider<SettingsNotifier, SettingsState>(
      (ref) => SettingsNotifier(),
);