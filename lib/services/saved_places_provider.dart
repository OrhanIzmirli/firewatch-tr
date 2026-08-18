import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/saved_place.dart';

/// The user's saved places, persisted as a JSON list in SharedPreferences.
///
/// This is the single store both the map (zoom + analysis) and the alert
/// scope (AlertScope.places) read — the key is also read directly by
/// FireMonitoringService, which runs outside the widget tree.
class SavedPlacesNotifier extends StateNotifier<List<SavedPlace>> {
  SavedPlacesNotifier() : super(const []) {
    _load();
  }

  /// Also read by FireMonitoringService; keep the two in sync.
  static const String prefsKey = 'saved_places';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = decode(prefs.getString(prefsKey));
  }

  static List<SavedPlace> decode(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .cast<Map<String, dynamic>>()
          .map(SavedPlace.fromJson)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      prefsKey,
      jsonEncode(state.map((p) => p.toJson()).toList()),
    );
  }

  bool isSaved(String id) => state.any((p) => p.id == id);

  Future<void> add(SavedPlace place) async {
    if (isSaved(place.id)) return;
    state = [...state, place];
    await _persist();
  }

  Future<void> remove(String id) async {
    state = state.where((p) => p.id != id).toList();
    await _persist();
  }
}

final savedPlacesProvider =
    StateNotifierProvider<SavedPlacesNotifier, List<SavedPlace>>(
  (ref) => SavedPlacesNotifier(),
);
