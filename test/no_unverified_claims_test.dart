import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the claims found false in the November 2026 accuracy audit. Each
/// pattern is something the app has no way of knowing or doing.
void main() {
  Map<String, dynamic> arb(String lang) => jsonDecode(
        File('lib/l10n/app_$lang.arb').readAsStringSync().replaceFirst('﻿', ''),
      ) as Map<String, dynamic>;

  void expectNone(String lang, RegExp pattern, String why) {
    final hits = <String>[
      for (final e in arb(lang).entries)
        if (!e.key.startsWith('@') && e.value is String && pattern.hasMatch(e.value as String)) e.key,
    ];
    expect(hits, isEmpty, reason: why);
  }

  test('never says emergency services were told', () {
    expectNone('tr', RegExp(r'ekipleri (zaten )?bilgilendirildi', caseSensitive: false),
        'Reports are not forwarded to anyone.');
    expectNone('en', RegExp(r'emergency services have (already )?been notified', caseSensitive: false),
        'Reports are not forwarded to anyone.');
  });

  test('never calls a detection a live fire', () {
    expectNone('tr', RegExp(r'canlı yangın', caseSensitive: false), 'A detection is a hot pixel, not a fire.');
    expectNone('en', RegExp(r'live fire', caseSensitive: false), 'A detection is a hot pixel, not a fire.');
  });

  test('never calls the 3-hourly score real-time', () {
    expectNone('tr', RegExp(r'gerçek zamanlı', caseSensitive: false), 'Risk is recalculated about every 3 hours.');
    expectNone('en', RegExp(r'(?<!near )real-time', caseSensitive: false), 'Risk is recalculated about every 3 hours.');
  });

  test('news is not an input of the risk score', () {
    final tr = arb('tr')['riskInfoSourcesBody'] as String;
    expect(tr.toLowerCase(), isNot(contains('rss')));
    final en = arb('en')['riskInfoSourcesBody'] as String;
    expect(en.toLowerCase(), isNot(contains('rss')));
  });

  test('a province name never becomes a claim about the exact spot', () {
    expect(arb('tr')['smartLocationHintAgricultural'], isNot(startsWith('tarım arazisinde')));
    expect(arb('tr')['smartLocationHintUrban'], isNot(startsWith('kentsel alanda')));
    expect(arb('tr')['smartLocationHintForest'], isNot(contains('yüksek riskli')));
    expect(arb('en')['smartLocationHintForest'], isNot(contains('high-risk')));
  });
}
