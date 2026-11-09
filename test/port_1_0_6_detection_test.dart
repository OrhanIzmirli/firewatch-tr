import 'dart:convert';
import 'dart:io';

import 'package:firewatch_tr/core/config/feature_flags.dart';
import 'package:firewatch_tr/core/utils/detection_score.dart';
import 'package:firewatch_tr/models/fire_incident.dart';
import 'package:firewatch_tr/models/fire_point.dart';
import 'package:flutter_test/flutter_test.dart';

final _now = DateTime.utc(2026, 8, 10, 12, 0);

FirePoint _point({
  String confidence = 'h',
  double frp = 0,
  DateTime? at,
  double lat = 36.9,
  double lng = 30.7,
}) {
  final t = at ?? _now.subtract(const Duration(hours: 1));
  String two(int v) => v.toString().padLeft(2, '0');
  return FirePoint(
    latitude: lat,
    longitude: lng,
    brightness: '330',
    confidence: confidence,
    satellite: 'VIIRS',
    acquisitionDate: '${t.year}-${two(t.month)}-${two(t.day)}',
    acquisitionTime: '${two(t.hour)}${two(t.minute)}',
    frp: frp,
  );
}

FireIncident _incident({
  int id = 1,
  int overpasses = 2,
  double? frp = 10,
  String tier = 'high',
  String state = 'detected_recently',
  double lat = 36.9,
  double lng = 30.7,
  String? officialState,
  String? heatSourceClass,
}) =>
    FireIncident(
      id: id,
      latitude: lat,
      longitude: lng,
      satelliteState: state,
      hoursSinceLastDetection: 1,
      durationHours: 3,
      detectionCount: overpasses * 2,
      overpassCount: overpasses,
      spreadConfidence: 'insufficient',
      maxFrpMw: frp,
      peakConfidenceTier: tier,
      officialState: officialState,
      heatSourceClass: heatSourceClass,
      heatSourceKnown: heatSourceClass != null,
    );

void main() {
  group('detection confidence (Tespit güveni)', () {
    test('components add up as documented, weather is not one of them', () {
      // high 30 + FRP≥50 20 + 3 nearby 20 + ≤3 h 10 = 80 = raw max.
      final p = _point(frp: 60);
      expect(detectionConfidenceRaw(p, nearbyMultiPass: 3, now: _now), 80);
      expect(detectionConfidenceScore(p, nearbyMultiPass: 3, now: _now), 100);
      expect(kDetectionConfidenceRawMax, 80);
    });

    test('each component band', () {
      final old = _now.subtract(const Duration(hours: 30));
      // Tier only.
      expect(detectionConfidenceRaw(_point(at: old), now: _now), 30);
      expect(detectionConfidenceRaw(_point(confidence: 'n', at: old), now: _now), 18);
      expect(detectionConfidenceRaw(_point(confidence: 'l', at: old), now: _now), 5);
      // FRP bands on top of a nominal pixel.
      int frp(double mw) =>
          detectionConfidenceRaw(_point(confidence: 'n', frp: mw, at: old), now: _now) - 18;
      expect([frp(1), frp(2), frp(8), frp(20), frp(50)], [0, 5, 10, 15, 20]);
      // Nearby multi-pass detections.
      int near(int n) =>
          detectionConfidenceRaw(_point(at: old), nearbyMultiPass: n, now: _now) - 30;
      expect([near(0), near(1), near(2), near(3), near(9)], [0, 10, 15, 20, 20]);
      // Age.
      int age(int h) => detectionConfidenceRaw(
            _point(at: _now.subtract(Duration(hours: h))),
            now: _now,
          ) -
          30;
      expect([age(1), age(3), age(4), age(12), age(13), age(24), age(25)],
          [10, 10, 7, 7, 3, 3, 0]);
    });

    test('scaled to 0–100 and rounded', () {
      // nominal 18 + 7 (6 h) = 25 raw → 31.25 → 31.
      final p = _point(confidence: 'n', at: _now.subtract(const Duration(hours: 6)));
      expect(detectionConfidenceScore(p, now: _now), 31);
    });

    test('only multi-pass detections within 20 km count as nearby', () {
      final p = _point();
      final incidents = [
        _incident(id: 1), // same spot, multi-pass
        _incident(id: 2, lat: 37.0), // ~11 km, multi-pass
        _incident(id: 3, lat: 37.2), // ~33 km
        _incident(id: 4, overpasses: 1), // single pass
        _incident(id: 5, frp: 5), // below the FRP bar
        _incident(id: 6, tier: 'low'),
      ];
      expect(multiPassDetectionsNear(p, incidents), 2);
    });
  });

  group('strong unverified', () {
    test('fresh and FRP ≥ 15 MW, or fresh and score ≥ 65', () {
      final fresh = _point(confidence: 'l', frp: 15);
      expect(isStrongUnverifiedPoint(fresh, score: 10, now: _now), isTrue);
      final weak = _point(confidence: 'l', frp: 14);
      expect(isStrongUnverifiedPoint(weak, score: 64, now: _now), isFalse);
      expect(isStrongUnverifiedPoint(weak, score: 65, now: _now), isTrue);
    });

    test('older than 12 h is never an attention marker', () {
      final old = _point(frp: 90, at: _now.subtract(const Duration(hours: 13)));
      expect(isStrongUnverifiedPoint(old, score: 100, now: _now), isFalse);
    });

    test('incident: active, below the multi-pass bar, FRP ≥ 15', () {
      expect(_incident(overpasses: 1, frp: 20).isStrongUnverified, isTrue);
      expect(_incident(overpasses: 1, frp: 14).isStrongUnverified, isFalse);
      expect(_incident(overpasses: 3, frp: 20).isStrongUnverified, isFalse);
      expect(
        _incident(overpasses: 1, frp: 20, state: 'no_recent_detection')
            .isStrongUnverified,
        isFalse,
      );
      expect(
        _incident(overpasses: 1, frp: 20, heatSourceClass: 'persistent_heat_source')
            .isStrongUnverified,
        isFalse,
      );
    });
  });

  group('multi-pass detection and the events layer', () {
    test('criterion is IncidentSignificance: ≥2 passes, ≥8 MW, not low', () {
      expect(_incident().isMultiPassDetection, isTrue);
      expect(_incident(overpasses: 1).isMultiPassDetection, isFalse);
      expect(_incident(frp: 7.9).isMultiPassDetection, isFalse);
      expect(_incident(tier: 'low').isMultiPassDetection, isFalse);
    });

    test('events layer draws multi-pass only; single pixels go to Points', () {
      final single = _incident(overpasses: 1, frp: 30);
      final multi = _incident();
      final multiEnded = _incident(state: 'no_recent_detection');
      expect(IncidentFilter.active.matches(single), isFalse);
      expect(IncidentFilter.all.matches(single), isFalse);
      expect(IncidentFilter.active.matches(multi), isTrue);
      expect(IncidentFilter.ended.matches(multi), isFalse);
      expect(IncidentFilter.ended.matches(multiEnded), isTrue);
      expect(IncidentFilter.all.matches(multiEnded), isTrue);
    });

    test('a labelled fixed heat source is off the events layer; it stays on Points', () {
      final plant = _incident(
        overpasses: 1,
        frp: 3,
        heatSourceClass: 'persistent_heat_source',
      );
      expect(IncidentFilter.active.matches(plant), isFalse);
      expect(IncidentFilter.ended.matches(plant), isFalse);
      expect(IncidentFilter.all.matches(plant), isFalse);
    });
  });

  group('official status stays hidden (no reliable TR source)', () {
    test('flag is off in this build, debug included', () {
      expect(FeatureFlags.officialStatus, isFalse);
    });

    test('an official "extinguished" changes nothing while the flag is off', () {
      final out = _incident(overpasses: 1, frp: 3, officialState: 'extinguished');
      expect(out.hasOfficialStatus, isTrue);
      expect(out.hasShownOfficialStatus, isFalse);
      expect(out.isOfficiallyExtinguished, isFalse);
      expect(out.hasExtinguishedConflict, isFalse);
      // And it does not promote a single pixel onto the events layer.
      expect(out.belongsOnEventsLayer, isFalse);
    });
  });

  group('wording', () {
    Map<String, dynamic> arb(String lang) =>
        jsonDecode(File('lib/l10n/app_$lang.arb').readAsStringSync())
            as Map<String, dynamic>;

    const portKeys = [
      'mapDetectionConfidence',
      'mapDetectionConfidenceInfoTitle',
      'mapDetectionConfidenceInfoBody',
      'mapDetectionConfidenceInfoNotFire',
      'mapStrongUnverifiedReason',
      'mapStrongUnverifiedBanner',
      'multiPassDetectionLabel',
      'multiPassDetectionExplanation',
      'homeMultiPassSubtitle',
      'homeMultiPassNote',
      'homeLast24hActiveTitle',
    ];

    test('detection confidence is never called a probability or likelihood', () {
      for (final lang in ['tr', 'en']) {
        final strings = arb(lang);
        for (final key in portKeys) {
          final text = (strings[key] as String).toLowerCase();
          expect(text, isNot(contains('olasılı')), reason: '$lang $key');
          expect(text, isNot(contains('likelihood')), reason: '$lang $key');
          expect(text, isNot(contains('probab')), reason: '$lang $key');
        }
      }
      // And the old 1.0.6 names are gone from the code.
      final lib = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart') || f.path.endsWith('.arb'));
      for (final f in lib) {
        final src = f.readAsStringSync();
        expect(src, isNot(contains('fireLikelihood')), reason: f.path);
        expect(src, isNot(contains('mapLikelihoodScore')), reason: f.path);
        expect(src, isNot(contains('Yangın olasılığı')), reason: f.path);
      }
    });

    test('multi-pass wording never claims proof or verification', () {
      final tr = arb('tr');
      final en = arb('en');
      for (final key in portKeys) {
        final t = (tr[key] as String).toLowerCase();
        expect(t, isNot(contains('kanıtlanmış')), reason: key);
        expect(t, isNot(contains('kanıtlı')), reason: key);
        expect(t, isNot(contains('kesinleş')), reason: key);
        final e = (en[key] as String).toLowerCase();
        expect(e, isNot(contains('proven')), reason: key);
        expect(e, isNot(contains('confirmed')), reason: key);
      }
      expect(tr['homeMultiPassNote'], contains('doğrulanmadı'));
      expect(en['homeMultiPassNote'], contains('None of these is verified'));
      expect(tr['multiPassDetectionExplanation'], contains('doğrulamaz'));
    });
  });
}
