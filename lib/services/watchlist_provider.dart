import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WatchlistNotifier extends StateNotifier<Set<String>> {
  WatchlistNotifier() : super(<String>{}) {
    _loadWatchlist();
  }

  static const _watchlistKey = 'watchlist_ids';

  Future<void> _loadWatchlist() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIds = prefs.getStringList(_watchlistKey) ?? <String>[];
    state = savedIds.toSet();
  }

  Future<void> _persistWatchlist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_watchlistKey, state.toList());
  }

  bool isSaved(String fireEventId) {
    return state.contains(fireEventId);
  }

  Future<void> toggle(String fireEventId) async {
    if (state.contains(fireEventId)) {
      state = {...state}..remove(fireEventId);
    } else {
      state = {...state, fireEventId};
    }

    await _persistWatchlist();
  }

  Future<void> remove(String fireEventId) async {
    state = {...state}..remove(fireEventId);
    await _persistWatchlist();
  }

  Future<void> clear() async {
    state = <String>{};
    await _persistWatchlist();
  }
}

final watchlistProvider =
StateNotifierProvider<WatchlistNotifier, Set<String>>(
      (ref) => WatchlistNotifier(),
);