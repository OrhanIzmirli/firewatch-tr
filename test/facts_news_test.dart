import 'dart:convert';
import 'dart:io';

import 'package:firewatch_tr/features/nature/nature_facts.dart';
import 'package:firewatch_tr/features/nature/nature_notes.dart';
import 'package:firewatch_tr/features/news/news_feed.dart';
import 'package:firewatch_tr/features/news/widgets/news_visual.dart';
import 'package:firewatch_tr/models/news_item.dart';
import 'package:flutter_test/flutter_test.dart';

NatureFact fact(String id, [String season = 'all']) =>
    NatureFact(id: id, tr: id, en: id, category: 'x', season: season, sourceName: 's', sourceUrl: 'https://a/b');

final now = DateTime.utc(2026, 11, 8, 12);

NewsItem news(String id, int daysAgo, String? kind) => NewsItem.fromJson({
      'id': id,
      'title': 't$id',
      'source': 's',
      'source_url': 'u',
      'published_at': now.subtract(Duration(days: daysAgo)).toIso8601String(),
      'kind': kind,
    });

void main() {
  group('a fact in several places', () {
    final pool = [for (var i = 0; i < 20; i++) fact('f$i')];
    final day = DateTime(2026, 11, 8, 9);

    test('no two places show the same fact on one day', () {
      var state = const FactDeckState(seed: 3);
      final ids = <String>[];
      for (final slot in ['home', 'fidan', 'news-1', 'news-2', 'map', 'splash']) {
        final (f, next) = pickFact(pool, state, day, slot);
        ids.add(f.id);
        state = next;
      }
      expect(ids.toSet().length, ids.length);
    });

    test('one place keeps its fact all day', () {
      final (a, s) = pickFact(pool, const FactDeckState(seed: 3), day, 'home');
      final (b, s2) = pickFact(pool, s, DateTime(2026, 11, 8, 22), 'home');
      expect(b.id, a.id);
      expect(s2.shown.length, 1);
    });

    test('another fact replaces it and never returns one in use', () {
      var (a, s) = pickFact(pool, const FactDeckState(seed: 3), day, 'home');
      final (other, s2) = pickFact(pool, s, day, 'map');
      s = s2;
      final (b, s3) = pickFact(pool, s, day, 'home', replace: true);
      expect(b.id, isNot(a.id));
      expect(b.id, isNot(other.id));
      expect(s3.slots['home'], b.id);
    });

    test('a new day gives each place a new fact', () {
      final (a, s) = pickFact(pool, const FactDeckState(seed: 3), day, 'home');
      final (b, _) = pickFact(pool, s, DateTime(2026, 11, 9), 'home');
      expect(b.id, isNot(a.id));
    });

    test('when the pool runs out, today\'s facts still do not repeat', () {
      final small = [fact('a'), fact('b'), fact('c')];
      var state = const FactDeckState(seed: 1);
      final ids = <String>[];
      for (final slot in ['1', '2', '3']) {
        final (f, n) = pickFact(small, state, day, slot);
        ids.add(f.id);
        state = n;
      }
      expect(ids.toSet().length, 3);
      final (next, s2) = pickFact(small, state, DateTime(2026, 11, 9), '1');
      expect(small.map((f) => f.id), contains(next.id));
      expect(s2.shown, {next.id});
    });
  });

  test('the pool is 365 facts and at most 15 percent about satellites', () {
    final raw = jsonDecode(File('assets/data/nature_facts.json').readAsStringSync()) as List;
    poolBalance([for (final e in raw) NatureFact.fromJson(Map<String, dynamic>.from(e as Map))]);
  });

  group('nature notes', () {
    test('three a week, in the future, on the chosen days', () {
      final days = noteDays(DateTime(2026, 11, 9, 12));
      expect(days.first, DateTime(2026, 11, 11, 11), reason: 'Monday 11:00 has passed');
      expect(days.length, inInclusiveRange(8, 9));
      for (final d in days) {
        expect(const {DateTime.monday, DateTime.wednesday, DateTime.saturday}, contains(d.weekday));
      }
    });
  });

  group('news layout', () {
    test('featured is a forest fire from the last week', () {
      final v = arrangeNews([news('old', 9, 'fire'), news('new', 3, 'fire'), news('g', 1, 'recovery')], now);
      expect(v.featured!.id, 'new');
    });

    test('without one, the newest recovery or preparation story', () {
      final v = arrangeNews([news('old', 12, 'fire'), news('g', 20, 'recovery'), news('p', 10, 'preparation')], now);
      expect(v.featured!.id, 'p');
    });

    test('with neither, no featured card', () {
      expect(arrangeNews([news('old', 12, 'fire'), news('f', 8, 'field')], now).featured, isNull);
    });

    test('over 30 days goes to the archive and never the main list', () {
      final v = arrangeNews([news('a', 31, 'fire'), news('b', 30, 'fire'), news('c', 60, 'recovery')], now);
      expect(v.archive.map((n) => n.id), ['a', 'c']);
      expect(v.main.map((n) => n.id), ['b']);
      expect(v.featured, isNull);
    });

    test('a quiet week puts recovery and nature news first', () {
      final v = arrangeNews([news('f', 10, 'fire'), news('g', 20, 'nature'), news('h', 25, 'recovery')], now);
      expect(v.featured!.id, 'g');
      expect(v.main.map((n) => n.id), ['h', 'f']);
    });

    test('a busy week keeps date order', () {
      final v = arrangeNews([news('f1', 1, 'fire'), news('f2', 2, 'fire'), news('f3', 3, 'fire'), news('g', 2, 'recovery')], now);
      expect(v.main.map((n) => n.id).first, 'f2');
    });

    test('each subject has its own picture', () {
      expect(newsArtFor('x', 'field'), NewsArt.field);
      expect(newsArtFor('x', 'recovery'), NewsArt.recovery);
      expect(newsArtFor('x', 'preparation'), NewsArt.preparation);
      expect(newsArtFor('x', 'nature'), NewsArt.nature);
      expect(newsArtFor('x', 'fire'), NewsArt.fire);
      expect(newsArtFor('Gönüllüler destek verdi', null), NewsArt.solidarity);
    });
  });
}

/// The pool the owner asked for: 365 facts, mostly nature and prevention.
void poolBalance(List<NatureFact> pool) {
  expect(pool.length, greaterThanOrEqualTo(365));
  expect(pool.where((f) => f.category == 'satellites').length / pool.length, lessThanOrEqualTo(0.15));
}
