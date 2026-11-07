import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/l10n_lookup.dart';
import '../models/tracked_place.dart';
import 'tracked_places_api.dart';

class TrackedPlacesState {
  final List<TrackedPlace> places;
  final bool loading;
  final bool loaded;

  /// The server doesn't offer the feature yet (503).
  final bool unavailable;
  final TrackedPlacesError? lastError;

  const TrackedPlacesState({
    this.places = const [],
    this.loading = false,
    this.loaded = false,
    this.unavailable = false,
    this.lastError,
  });

  bool get isFull => places.length >= TrackedPlace.maxPlaces;

  TrackedPlacesState copyWith({
    List<TrackedPlace>? places,
    bool? loading,
    bool? loaded,
    bool? unavailable,
    TrackedPlacesError? lastError,
    bool clearError = false,
  }) =>
      TrackedPlacesState(
        places: places ?? this.places,
        loading: loading ?? this.loading,
        loaded: loaded ?? this.loaded,
        unavailable: unavailable ?? this.unavailable,
        lastError: clearError ? null : (lastError ?? this.lastError),
      );
}

/// Tracked places as the server has them. A copy is cached locally only so
/// the list shows instantly and offline; the server is the source of truth,
/// and the cache is cleared with "Delete my location data".
class TrackedPlacesNotifier extends StateNotifier<TrackedPlacesState> {
  TrackedPlacesNotifier(this._api) : super(const TrackedPlacesState());

  static const cacheKey = 'tracked_places_cache_v1';

  final TrackedPlacesApi _api;

  static List<TrackedPlace> decodeCache(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      return (jsonDecode(raw) as List)
          .cast<Map<String, dynamic>>()
          .map(TrackedPlace.fromJson)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> _writeCache(List<TrackedPlace> places) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(cacheKey, jsonEncode(places.map((p) => p.toJson()).toList()));
  }

  Future<void> load() async {
    if (state.loading) return;
    if (!state.loaded) {
      final prefs = await SharedPreferences.getInstance();
      final cached = decodeCache(prefs.getString(cacheKey));
      if (!mounted) return;
      state = state.copyWith(places: cached);
    }
    // Nothing on the server yet and nothing cached: don't create an
    // identity just to learn the list is empty.
    if (state.places.isEmpty && !await _hasServerIdentity()) {
      if (mounted) state = state.copyWith(loaded: true);
      return;
    }
    state = state.copyWith(loading: true, clearError: true);
    try {
      final places = await _api.list();
      await _writeCache(places);
      if (!mounted) return;
      state = state.copyWith(places: places, loading: false, loaded: true, unavailable: false);
    } on TrackedPlacesException catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        loading: false,
        loaded: true,
        unavailable: e.error == TrackedPlacesError.unavailable,
        lastError: e.error,
      );
    }
  }

  Future<bool> _hasServerIdentity() => _api.hasIdentity();

  /// Adds a place. Throws [TrackedPlacesException] so the form can say why.
  Future<TrackedPlace> add({
    required String name,
    required double latitude,
    required double longitude,
    required int radiusKm,
  }) async {
    if (state.isFull) throw const TrackedPlacesException(TrackedPlacesError.placeLimit);
    final place = await _api.add(name: name, latitude: latitude, longitude: longitude, radiusKm: radiusKm);
    final places = [...state.places, place];
    await _writeCache(places);
    if (mounted) state = state.copyWith(places: places, unavailable: false, clearError: true);
    return place;
  }

  Future<bool> setNotify(TrackedPlace place, bool value) async {
    final before = state.places;
    state = state.copyWith(
      places: [for (final p in before) p.id == place.id ? p.copyWith(notifyHeat: value) : p],
    );
    try {
      final updated = await _api.setNotify(place.id, value);
      final places = [for (final p in state.places) p.id == place.id ? updated : p];
      await _writeCache(places);
      if (mounted) state = state.copyWith(places: places);
      return true;
    } on TrackedPlacesException catch (e) {
      if (mounted) state = state.copyWith(places: before, lastError: e.error);
      return false;
    }
  }

  Future<bool> remove(TrackedPlace place) async {
    try {
      await _api.remove(place.id);
    } on TrackedPlacesException catch (e) {
      if (mounted) state = state.copyWith(lastError: e.error);
      return false;
    }
    final places = state.places.where((p) => p.id != place.id).toList();
    await _writeCache(places);
    if (mounted) state = state.copyWith(places: places);
    return true;
  }

  /// Server copy, local cache and identity all go.
  Future<bool> deleteAll() async {
    final ok = await _api.deleteAll();
    if (ok) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(cacheKey);
      if (mounted) state = state.copyWith(places: const [], clearError: true);
    }
    return ok;
  }
}

Future<String?> _currentFcmToken() async {
  try {
    return await FirebaseMessaging.instance.getToken();
  } catch (e) {
    if (kDebugMode) debugPrint('FCM token unavailable: $e');
    return null;
  }
}

Future<String> _currentLocale() async => (await currentAppLocalizations()).localeName;

final trackedPlacesApiProvider = Provider<TrackedPlacesApi>(
  (ref) => TrackedPlacesApi(fcmToken: _currentFcmToken, locale: _currentLocale),
);

final trackedPlacesProvider =
    StateNotifierProvider<TrackedPlacesNotifier, TrackedPlacesState>(
  (ref) => TrackedPlacesNotifier(ref.watch(trackedPlacesApiProvider)),
);
