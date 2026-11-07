import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// A satellite pixel, a detection-confidence score or a risk index is never
/// a probability that a fire exists. Every user-facing string that mentions
/// probability/likelihood must be a denial ("… is not a probability"),
/// or not be about fire at all (listed below with the reason).
void main() {
  Map<String, String> strings(String lang) {
    final data = jsonDecode(File('lib/l10n/app_$lang.arb').readAsStringSync())
        as Map<String, dynamic>;
    return {
      for (final e in data.entries)
        if (!e.key.startsWith('@') && e.value is String) e.key: e.value as String,
    };
  }

  // Not about whether a fire exists.
  const unrelated = {
    'emergencyBagMeetingPointSubtitle', // "in case you get separated"
  };

  test('TR: no "olasılık / ihtimal / muhtemel" claim about a fire', () {
    final claim = RegExp(r'olasılı|ihtimal|muhtemel', caseSensitive: false);
    final offenders = <String>[];
    strings('tr').forEach((key, value) {
      if (unrelated.contains(key)) return;
      if (claim.hasMatch(value.toLowerCase()) && !value.contains('değil')) {
        offenders.add('$key: $value');
      }
    });
    expect(offenders, isEmpty);
  });

  test('EN: no "likely / likelihood / probable" claim about a fire', () {
    final claim = RegExp(r'likel|probab', caseSensitive: false);
    final offenders = <String>[];
    strings('en').forEach((key, value) {
      if (unrelated.contains(key)) return;
      final lower = value.toLowerCase();
      if (claim.hasMatch(lower) && !RegExp(r'\bnot\b').hasMatch(lower)) {
        offenders.add('$key: $value');
      }
    });
    expect(offenders, isEmpty);
  });
}
