import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/config/api_config.dart';
import 'nature_progress.dart';

class NatureFact {
  final String id;
  final String tr;
  final String en;
  final String category;
  final String season;
  final String sourceName;
  final String sourceUrl;
  const NatureFact({required this.id, required this.tr, required this.en, required this.category, required this.season, required this.sourceName, required this.sourceUrl});

  factory NatureFact.fromJson(Map<String, dynamic> j) => NatureFact(
        id: '${j['id']}',
        tr: '${j['tr']}',
        en: '${j['en']}',
        category: '${j['category']}',
        season: '${j['season']}',
        sourceName: '${j['source_name']}',
        sourceUrl: '${j['source_url']}',
      );

  String of(String languageCode) => languageCode == 'tr' ? tr : en;
}

/// What this phone has shown. Never leaves the phone.
class FactDeckState {
  final int seed;
  final Set<String> shown;
  final String? day;

  /// Which fact each place in the app is showing today.
  final Map<String, String> slots;
  const FactDeckState({required this.seed, this.shown = const {}, this.day, this.slots = const {}});

  Map<String, dynamic> toJson() => {'seed': seed, 'shown': shown.toList(), 'day': day, 'slots': slots};

  factory FactDeckState.fromJson(Map<String, dynamic> j) => FactDeckState(
        seed: (j['seed'] as num).toInt(),
        shown: ((j['shown'] as List?) ?? const []).map((e) => '$e').toSet(),
        day: j['day'] as String?,
        slots: ((j['slots'] as Map?) ?? const {}).map((k, v) => MapEntry('$k', '$v')),
      );
}

/// The fact for one place in the app today. A place keeps its fact all day,
/// two places never share one on the same day, and none comes back before
/// the whole pool has been shown. Facts of another season wait until nothing
/// else is left; every third day prefers one of this season.
(NatureFact, FactDeckState) pickFact(List<NatureFact> pool, FactDeckState state, DateTime today, String slot, {bool replace = false}) {
  final key = dayKey(today);
  final slots = state.day == key ? state.slots : const <String, String>{};
  if (!replace && slots[slot] != null) {
    for (final f in pool) {
      if (f.id == slots[slot]) return (f, state);
    }
  }
  var seed = state.seed;
  var shown = state.shown;
  final inUse = slots.values.toSet();
  var unseen = pool.where((f) => !shown.contains(f.id) && !inUse.contains(f.id)).toList();
  if (unseen.isEmpty) {
    seed += 1;
    shown = const {};
    unseen = pool.where((f) => !inUse.contains(f.id)).toList();
    if (unseen.isEmpty) unseen = [...pool];
  }
  unseen.sort((a, b) => a.id.compareTo(b.id));
  unseen.shuffle(Random(seed));
  final season = seasonOf(today).name;
  final fit = unseen.where((f) => f.season == 'all' || f.season == season).toList();
  final choices = fit.isEmpty ? unseen : fit;
  final seasonal = choices.where((f) => f.season == season).toList();
  final dayNumber = DateTime.utc(today.year, today.month, today.day).millisecondsSinceEpoch ~/ 86400000;
  final pick = dayNumber % 3 == 0 && seasonal.isNotEmpty ? seasonal.first : choices.first;
  return (pick, FactDeckState(seed: seed, shown: {...shown, pick.id}, day: key, slots: {...slots, slot: pick.id}));
}

/// The Fidan screen's fact.
(NatureFact, FactDeckState) nextFact(List<NatureFact> pool, FactDeckState state, DateTime today) => pickFact(pool, state, today, 'fidan');

/// The bundled list works offline from the first launch; the backend's list,
/// once fetched, is kept and replaces it, so facts can grow without an update.
class NatureFacts {
  NatureFacts._();
  static final NatureFacts instance = NatureFacts._();
  static const _cacheKey = 'nature_facts_cache';
  static const _deckKey = 'nature_facts_deck';

  List<NatureFact> _parse(String raw) =>
      (jsonDecode(raw) as List).map((e) => NatureFact.fromJson(Map<String, dynamic>.from(e as Map))).toList();

  Future<List<NatureFact>> _pool(SharedPreferences prefs, AssetBundle bundle) async {
    final cached = prefs.getString(_cacheKey);
    if (cached != null) {
      try {
        final list = _parse(cached);
        if (list.isNotEmpty) return list;
      } catch (_) {
        await prefs.remove(_cacheKey);
      }
    }
    return _parse(await bundle.loadString('assets/data/nature_facts.json'));
  }

  Future<void> _refresh(SharedPreferences prefs) async {
    try {
      final r = await Dio(BaseOptions(connectTimeout: const Duration(seconds: 30), receiveTimeout: const Duration(seconds: 30)))
          .get<Map<String, dynamic>>('${ApiConfig.apiBaseUrl}/nature/facts');
      final data = r.data?['data'];
      if (data is List && data.isNotEmpty) await prefs.setString(_cacheKey, jsonEncode(data));
    } catch (_) {
      // Keep what is already here.
    }
  }

  /// Reads and writes run one at a time: several places ask at startup and
  /// each must see what the previous one took.
  Future<void> _queue = Future.value();

  Future<R> _serial<R>(Future<R> Function() job) {
    final result = _queue.then((_) => job());
    _queue = result.then((_) {}, onError: (_) {});
    return result;
  }

  Future<(SharedPreferences, List<NatureFact>, FactDeckState)> _open(AssetBundle? bundle) async {
    final prefs = await SharedPreferences.getInstance();
    final pool = await _pool(prefs, bundle ?? rootBundle);
    final raw = prefs.getString(_deckKey);
    return (prefs, pool, raw == null ? FactDeckState(seed: Random().nextInt(1 << 31)) : FactDeckState.fromJson(jsonDecode(raw) as Map<String, dynamic>));
  }

  Future<NatureFact> forSlot(String slot, DateTime now, {AssetBundle? bundle, bool replace = false}) => _serial(() async {
        final (prefs, pool, state) = await _open(bundle);
        final (fact, next) = pickFact(pool, state, now, slot, replace: replace);
        await prefs.setString(_deckKey, jsonEncode(next.toJson()));
        if (!_refreshed) {
          _refreshed = true;
          _refresh(prefs);
        }
        return fact;
      });

  bool _refreshed = false;

  Future<NatureFact> another(String slot, DateTime now) => forSlot(slot, now, replace: true);

  Future<NatureFact> today(DateTime now, {AssetBundle? bundle, bool refresh = true}) {
    if (!refresh) _refreshed = true;
    return forSlot('fidan', now, bundle: bundle);
  }

  /// A fact set aside for a future day's notification; marked as shown now
  /// so the app does not also show it.
  Future<NatureFact> planned(String? existingId, DateTime day) => _serial(() async {
        final (prefs, pool, state) = await _open(null);
        if (existingId != null) {
          for (final f in pool) {
            if (f.id == existingId) return f;
          }
        }
        final (fact, next) = pickFact(pool, FactDeckState(seed: state.seed, shown: state.shown, day: 'plan', slots: const {}), day, 'plan');
        await prefs.setString(_deckKey, jsonEncode(FactDeckState(seed: next.seed, shown: next.shown, day: state.day, slots: state.slots).toJson()));
        return fact;
      });
}
