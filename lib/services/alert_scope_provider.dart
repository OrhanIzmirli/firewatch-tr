import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/alert_scope.dart';
import 'notification_service.dart';
import 'render_api_service.dart';

class AlertScopeState {
  final AlertScope scope;
  final String? regionKey;
  final int? cityId;

  /// Province list for the picker. Empty until loaded, or if the fetch failed.
  final List<TurkeyCity> cities;

  /// Region/city inferred from the device's own position, offered as the
  /// default when the user first narrows their scope. Never applied silently.
  final String? suggestedRegionKey;
  final TurkeyCity? suggestedCity;

  final bool isLoaded;
  final bool isDetectingLocation;
  final bool citiesFailed;

  const AlertScopeState({
    required this.scope,
    this.regionKey,
    this.cityId,
    this.cities = const [],
    this.suggestedRegionKey,
    this.suggestedCity,
    this.isLoaded = false,
    this.isDetectingLocation = false,
    this.citiesFailed = false,
  });

  static const AlertScopeState initial = AlertScopeState(scope: AlertScope.all);

  TurkeyCity? get selectedCity {
    if (cityId == null) return null;
    for (final city in cities) {
      if (city.id == cityId) return city;
    }
    return null;
  }

  AlertScopeState copyWith({
    AlertScope? scope,
    String? regionKey,
    int? cityId,
    List<TurkeyCity>? cities,
    String? suggestedRegionKey,
    TurkeyCity? suggestedCity,
    bool? isLoaded,
    bool? isDetectingLocation,
    bool? citiesFailed,
    bool clearRegion = false,
    bool clearCity = false,
  }) {
    return AlertScopeState(
      scope: scope ?? this.scope,
      regionKey: clearRegion ? null : (regionKey ?? this.regionKey),
      cityId: clearCity ? null : (cityId ?? this.cityId),
      cities: cities ?? this.cities,
      suggestedRegionKey: suggestedRegionKey ?? this.suggestedRegionKey,
      suggestedCity: suggestedCity ?? this.suggestedCity,
      isLoaded: isLoaded ?? this.isLoaded,
      isDetectingLocation: isDetectingLocation ?? this.isDetectingLocation,
      citiesFailed: citiesFailed ?? this.citiesFailed,
    );
  }
}

class AlertScopeNotifier extends StateNotifier<AlertScopeState> {
  AlertScopeNotifier() : super(AlertScopeState.initial) {
    _bootstrap();
  }

  static const _scopeKey = 'alert_scope';
  static const _regionKey = 'alert_scope_region';
  static const _cityIdKey = 'alert_scope_city_id';

  final RenderApiService _api = RenderApiService();

  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    state = state.copyWith(
      scope: AlertScopeWire.fromWire(prefs.getString(_scopeKey)),
      regionKey: prefs.getString(_regionKey),
      cityId: prefs.getInt(_cityIdKey),
      isLoaded: true,
    );

    // Both are best-effort and independent: a failed city fetch still leaves
    // region selection usable, and a denied location just means no suggestion.
    unawaited(_loadCities());
    unawaited(detectFromLocation());
  }

  Future<void> _loadCities() async {
    final cities = await _api.fetchCities();
    if (!mounted) return;
    state = state.copyWith(cities: cities, citiesFailed: cities.isEmpty);
  }

  /// Reads the device position and asks the backend which province and region
  /// it falls in. The answer is a suggestion only — it is never applied to the
  /// user's scope without an explicit tap.
  Future<void> detectFromLocation() async {
    state = state.copyWith(isDetectingLocation: true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 10),
        ),
      );
      if (!mounted) return;

      // The region is resolved by the backend from turkey_cities, never
      // locally: FirePoint's bounding boxes place Konya, Karaman, Nigde and
      // Aksaray in Akdeniz and Burdur in Ege, while the server alerts on the
      // province table's regions. A locally-derived key would subscribe the
      // device to a region the alerts for its own location never carry.
      final resolved = await _api.resolveLocation(
        position.latitude,
        position.longitude,
      );
      if (!mounted || resolved == null) return;
      state = state.copyWith(
        suggestedRegionKey: resolved.regionKey,
        suggestedCity: resolved.cityId == null
            ? null
            : TurkeyCity(
                id: resolved.cityId!,
                name: resolved.cityName ?? '',
                regionKey: resolved.regionKey,
              ),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Alert scope location detection failed: $e');
    } finally {
      if (mounted) state = state.copyWith(isDetectingLocation: false);
    }
  }

  Future<void> setScope(
    AlertScope scope, {
    String? regionKey,
    int? cityId,
  }) async {
    final resolvedRegion = scope == AlertScope.region
        ? (regionKey ?? state.regionKey ?? state.suggestedRegionKey)
        : null;
    final resolvedCity = scope == AlertScope.city
        ? (cityId ?? state.cityId ?? state.suggestedCity?.id)
        : null;

    state = state.copyWith(
      scope: scope,
      regionKey: resolvedRegion,
      cityId: resolvedCity,
      clearRegion: resolvedRegion == null,
      clearCity: resolvedCity == null,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_scopeKey, scope.wireValue);
    if (resolvedRegion == null) {
      await prefs.remove(_regionKey);
    } else {
      await prefs.setString(_regionKey, resolvedRegion);
    }
    if (resolvedCity == null) {
      await prefs.remove(_cityIdKey);
    } else {
      await prefs.setInt(_cityIdKey, resolvedCity);
    }
  }

  /// Pushes the current selection to the backend. Returns false when the call
  /// failed, so the UI can tell the user their choice is only local so far.
  ///
  /// Incomplete selections are not sent: 'region' with no region and 'city'
  /// with no city would be rejected by the API anyway.
  Future<bool> syncToBackend() async {
    if (state.scope == AlertScope.region && state.regionKey == null) return false;
    if (state.scope == AlertScope.city && state.cityId == null) return false;

    return NotificationService.instance.updateAlertScope(
      scope: state.scope,
      regionKey: state.regionKey,
      cityId: state.cityId,
    );
  }
}

final alertScopeProvider =
    StateNotifierProvider<AlertScopeNotifier, AlertScopeState>(
  (ref) => AlertScopeNotifier(),
);
