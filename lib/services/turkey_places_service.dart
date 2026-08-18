import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/saved_place.dart';

/// The bundled list of Türkiye's 81 provinces and 973 districts, each with a
/// centre and an administrative bounding box.
///
/// Names and province membership come from the official list (turkiyeapi),
/// centres and boxes from OpenStreetMap admin boundaries (© OpenStreetMap
/// contributors, ODbL), merged offline into assets/data/turkey_places.json —
/// bundled so the picker never needs the network. Finer scales (village,
/// neighbourhood) are deliberately not embedded; those are served by the
/// drop-a-pin flow instead.
class TurkeyPlacesService {
  TurkeyPlacesService._();

  static final TurkeyPlacesService instance = TurkeyPlacesService._();

  List<SavedPlace>? _all;

  Future<List<SavedPlace>> _load() async {
    if (_all != null) return _all!;
    final raw = await rootBundle.loadString('assets/data/turkey_places.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final provinces = data['provinces'] as List;
    final out = <SavedPlace>[];
    for (final p in provinces.cast<Map<String, dynamic>>()) {
      final pName = p['n'] as String;
      final pBb = (p['bb'] as List).cast<num>();
      out.add(
        SavedPlace(
          id: 'province-${p['id']}',
          name: pName,
          subtitle: '',
          kind: SavedPlaceKind.province,
          lat: (p['lat'] as num).toDouble(),
          lng: (p['lng'] as num).toDouble(),
          west: pBb[0].toDouble(),
          south: pBb[1].toDouble(),
          east: pBb[2].toDouble(),
          north: pBb[3].toDouble(),
        ),
      );
      for (final d in (p['d'] as List).cast<Map<String, dynamic>>()) {
        final dBb = (d['bb'] as List).cast<num>();
        out.add(
          SavedPlace(
            id: 'district-${p['id']}-${d['n']}',
            name: d['n'] as String,
            subtitle: pName,
            kind: SavedPlaceKind.district,
            lat: (d['lat'] as num).toDouble(),
            lng: (d['lng'] as num).toDouble(),
            west: dBb[0].toDouble(),
            south: dBb[1].toDouble(),
            east: dBb[2].toDouble(),
            north: dBb[3].toDouble(),
          ),
        );
      }
    }
    _all = out;
    return out;
  }

  static String _fold(String s) => s
      .toLowerCase()
      .replaceAll('ı', 'i')
      .replaceAll('İ'.toLowerCase(), 'i')
      .replaceAll('ş', 's')
      .replaceAll('ç', 'c')
      .replaceAll('ğ', 'g')
      .replaceAll('ü', 'u')
      .replaceAll('ö', 'o')
      .replaceAll('â', 'a')
      .replaceAll('î', 'i');

  /// Prefix-then-substring search over provinces and districts, diacritics
  /// folded so "usak" finds Uşak. Provinces sort before districts, prefix
  /// matches before substring matches.
  Future<List<SavedPlace>> search(String query, {int limit = 20}) async {
    final q = _fold(query.trim());
    if (q.isEmpty) return const [];
    final all = await _load();
    int score(SavedPlace p) {
      final n = _fold(p.name);
      var s = 0;
      if (n.startsWith(q)) {
        s = 2;
      } else if (n.contains(q)) {
        s = 1;
      } else {
        return 0;
      }
      if (p.kind == SavedPlaceKind.province) s += 1;
      return s;
    }

    final hits = all.where((p) => score(p) > 0).toList()
      ..sort((a, b) {
        final byScore = score(b).compareTo(score(a));
        if (byScore != 0) return byScore;
        return a.name.compareTo(b.name);
      });
    return hits.take(limit).toList();
  }
}
