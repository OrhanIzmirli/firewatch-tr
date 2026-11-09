import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Main screens speak plainly: satellites detected or did not, and nothing
/// is verified. Instrument terms live only behind "Detaylar" and on the
/// data sources screen.
void main() {
  Map<String, String> strings(String lang) {
    final raw = File('lib/l10n/app_$lang.arb').readAsStringSync().replaceFirst('﻿', '');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    return {
      for (final e in data.entries)
        if (!e.key.startsWith('@') && e.value is String) e.key: e.value as String,
    };
  }

  // Shown only behind "Detaylar", an info button or the sources screen.
  bool technicalAllowed(String key) =>
      key.startsWith('dataSources') ||
      key.startsWith('tooltip') ||
      key.startsWith('historySource') ||
      const {
        'detectionAboutViirs',
        'detectionConfidenceExplanation',
        'detectionFrpExplanation',
        'fireDetailFireRadiativePower',
        'fireDetailFrpValue',
        'incidentPeakPowerDetail',
        'historyMaxFrp',
        'annualLayerProvenance',
      }.contains(key);

  // Not about whether a fire exists.
  const unrelated = {'emergencyBagMeetingPointSubtitle'};

  List<String> offenders(Map<String, String> all, RegExp bad, {bool Function(String)? allow}) => [
        for (final e in all.entries)
          if (!(allow?.call(e.key) ?? false) && !unrelated.contains(e.key) && bad.hasMatch(e.value)) '${e.key}: ${e.value}',
      ];

  test('TR: no instrument terms outside Detaylar', () {
    final bad = RegExp(r'[Iı]s[ıI]\s+(iz|sinyal)|anomali|piksel|\bFRP\b|\bMW\b|termal|PostGIS|VIIRS|MODIS', caseSensitive: false);
    expect(offenders(strings('tr'), bad, allow: technicalAllowed), isEmpty);
  });

  test('EN: no instrument terms outside Details', () {
    final bad = RegExp(r'heat (signature|signal|trace)|anomal|pixel|\bFRP\b|\bMW\b|thermal|PostGIS|VIIRS|MODIS', caseSensitive: false);
    expect(offenders(strings('en'), bad, allow: technicalAllowed), isEmpty);
  });

  test('TR: no probability words and no flat "no fire"', () {
    final bad = RegExp(r'olası|muhtemel|ihtimal|yangın yok|yangın olabilir|yangın bulunmuyor', caseSensitive: false);
    expect(offenders(strings('tr'), bad), isEmpty);
  });

  test('EN: no probability words and no flat "no fire"', () {
    final bad = RegExp(r'probab|likely|likelihood|possible fire|possible thermal|^no fire|may be an active fire', caseSensitive: false);
    expect(offenders(strings('en'), bad), isEmpty);
  });

  test('the wording that replaces them is there', () {
    final tr = strings('tr');
    expect(tr['detectionNoneTitle'], "Son 24 saatte uydular Türkiye'de orman ve doğal alanlarda güçlü bir ısı tespit etmedi.");
    expect(tr['incidentToggleDetections'], 'Doğrulanmamış uydu tespitleri');
    expect(tr['homeMultiPassNote'], contains('doğrulanmadı'));
    expect(tr['commonDetails'], 'Detaylar');
    expect(strings('en')['commonDetails'], 'Details');
  });

  test('main screens print no MW; the number is behind Detaylar', () {
    final home = File('lib/features/home/home_screen.dart').readAsStringSync();
    expect(home, isNot(contains('homeLast24hStrongestPower')));
    final sheet = File('lib/features/map/widgets/incident_sheet.dart').readAsStringSync();
    expect(sheet, isNot(contains("} MW'")));
    expect(sheet.indexOf('incidentTechnicalDetails'), lessThan(sheet.indexOf('incidentPeakPowerDetail')));
    final detail = File('lib/features/fire_detail/fire_detail_screen.dart').readAsStringSync();
    final tile = detail.indexOf('fireTechnicalDetails');
    expect(tile, greaterThan(0));
    expect(detail.indexOf('l10n.fireDetailFireRadiativePower'), greaterThan(tile));
    expect(detail.indexOf('l10n.detectionFrpExplanation'), greaterThan(tile));
  });

  test('the report lists the changes', () {
    final report = File('SADE-DIL-RAPORU.md').readAsStringSync();
    expect(report, contains('| Anahtar | TR eski | TR yeni | EN eski | EN yeni |'));
    expect(report, contains('`detectionNoneTitle`'));
  });
}
