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
  final String? todayId;
  const FactDeckState({required this.seed, this.shown = const {}, this.day, this.todayId});

  Map<String, dynamic> toJson() => {'seed': seed, 'shown': shown.toList(), 'day': day, 'todayId': todayId};

  factory FactDeckState.fromJson(Map<String, dynamic> j) => FactDeckState(
        seed: (j['seed'] as num).toInt(),
        shown: ((j['shown'] as List?) ?? const []).map((e) => '$e').toSet(),
        day: j['day'] as String?,
        todayId: j['todayId'] as String?,
      );
}

/// The fact for [today]. The same all day, in an order of this phone's own,
/// and none comes back before the whole pool has been shown. Facts of
/// another season wait until nothing else is left; every third day prefers
/// one of this season.
(NatureFact, FactDeckState) nextFact(List<NatureFact> pool, FactDeckState state, DateTime today) {
  final key = dayKey(today);
  if (state.day == key) {
    for (final f in pool) {
      if (f.id == state.todayId) return (f, state);
    }
  }
  var seed = state.seed;
  var shown = state.shown;
  var unseen = pool.where((f) => !shown.contains(f.id)).toList();
  if (unseen.isEmpty) {
    seed += 1;
    shown = const {};
    unseen = [...pool];
  }
  unseen.sort((a, b) => a.id.compareTo(b.id));
  unseen.shuffle(Random(seed));
  final season = seasonOf(today).name;
  final fit = unseen.where((f) => f.season == 'all' || f.season == season).toList();
  final choices = fit.isEmpty ? unseen : fit;
  final seasonal = choices.where((f) => f.season == season).toList();
  final dayNumber = DateTime.utc(today.year, today.month, today.day).millisecondsSinceEpoch ~/ 86400000;
  final pick = dayNumber % 3 == 0 && seasonal.isNotEmpty ? seasonal.first : choices.first;
  return (pick, FactDeckState(seed: seed, shown: {...shown, pick.id}, day: key, todayId: pick.id));
}

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

  Future<NatureFact> today(DateTime now, {AssetBundle? bundle, bool refresh = true}) async {
    final prefs = await SharedPreferences.getInstance();
    final pool = await _pool(prefs, bundle ?? rootBundle);
    final raw = prefs.getString(_deckKey);
    var state = raw == null ? FactDeckState(seed: Random().nextInt(1 << 31)) : FactDeckState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    final (fact, next) = nextFact(pool, state, now);
    state = next;
    await prefs.setString(_deckKey, jsonEncode(state.toJson()));
    if (refresh) _refresh(prefs);
    return fact;
  }
}
