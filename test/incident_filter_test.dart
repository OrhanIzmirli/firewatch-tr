import 'package:flutter_test/flutter_test.dart';
import 'package:firewatch_tr/models/fire_incident.dart';

FireIncident incident({
  required int id,
  required String state,
  int overpasses = 1,
  double? frp,
  String? tier = 'nominal',
  double durationHours = 1,
}) {
  return FireIncident(
    id: id,
    latitude: 39,
    longitude: 35,
    satelliteState: state,
    hoursSinceLastDetection: state == 'detected_recently' ? 2 : 30,
    durationHours: durationHours,
    detectionCount: 1,
    overpassCount: overpasses,
    spreadConfidence: 'insufficient',
    maxFrpMw: frp,
    peakConfidenceTier: tier,
  );
}

void main() {
  group('IncidentSignificance', () {
    test('the bar is exactly two passes, 8 MW and not the lowest tier', () {
      expect(IncidentSignificance.minOverpasses, 2);
      expect(IncidentSignificance.minFrpMw, 8);
      expect(IncidentSignificance.excludedConfidenceTier, 'low');
    });

    test('needs all three of passes, power and confidence', () {
      expect(
        incident(id: 1, state: 'x', overpasses: 2, frp: 8, tier: 'nominal')
            .isSignificant,
        isTrue,
      );
      // One overpass cannot separate a fire from a hot roof.
      expect(
        incident(id: 2, state: 'x', overpasses: 1, frp: 900, tier: 'high')
            .isSignificant,
        isFalse,
      );
      // Below the power floor, whatever the pass count.
      expect(
        incident(id: 3, state: 'x', overpasses: 9, frp: 7.99, tier: 'high')
            .isSignificant,
        isFalse,
      );
      // The live event the floor was lowered for: nine passes, 9.17 MW.
      // At a 10 MW bar the best-observed fire in the data was excluded.
      expect(
        incident(id: 6, state: 'x', overpasses: 9, frp: 9.17, tier: 'nominal')
            .isSignificant,
        isTrue,
      );
      // FIRMS' own lowest tier is excluded outright.
      expect(
        incident(id: 4, state: 'x', overpasses: 5, frp: 50, tier: 'low')
            .isSignificant,
        isFalse,
      );
      // A null FRP is not a pass.
      expect(
        incident(id: 5, state: 'x', overpasses: 5, frp: null, tier: 'high')
            .isSignificant,
        isFalse,
      );
    });
  });

  group('IncidentFilter', () {
    final activeThin = incident(
      id: 10,
      state: 'detected_recently',
      overpasses: 1,
      frp: 6.7,
    );
    final activeStrong = incident(
      id: 11,
      state: 'detected_recently',
      overpasses: 5,
      frp: 50.5,
      tier: 'high',
    );
    final endedThin = incident(
      id: 12,
      state: 'no_recent_detection',
      overpasses: 1,
      frp: 3,
    );
    final endedStrong = incident(
      id: 13,
      state: 'no_recent_detection',
      overpasses: 4,
      frp: 108.9,
      tier: 'high',
    );

    test('active keeps thin evidence — it is happening now', () {
      expect(IncidentFilter.active.matches(activeThin), isTrue);
      expect(IncidentFilter.active.matches(activeStrong), isTrue);
      expect(IncidentFilter.active.matches(endedStrong), isFalse);
    });

    test('no-longer-seen applies the evidence bar', () {
      expect(IncidentFilter.ended.matches(endedStrong), isTrue);
      expect(IncidentFilter.ended.matches(endedThin), isFalse);
      expect(IncidentFilter.ended.matches(activeStrong), isFalse);
    });

    test('all is the union, not everything', () {
      expect(IncidentFilter.all.matches(activeThin), isTrue);
      expect(IncidentFilter.all.matches(endedStrong), isTrue);
      // The one that must not reappear: no longer detected and never had
      // more than a single weak pixel behind it.
      expect(IncidentFilter.all.matches(endedThin), isFalse);
    });
  });

  group('PersistentSourceHint', () {
    // It flags; it never filters. These cases only control whether an extra
    // line of context appears, never whether the event is on the map.
    test('flags long-lived, weak, every-pass events', () {
      final flare = incident(
        id: 20,
        state: 'detected_recently',
        overpasses: 10,
        frp: 4.35,
        durationHours: 34.5,
      );
      expect(flare.looksLikeFixedSource, isTrue);
    });

    test('does not flag a powerful long-lived fire', () {
      final bigFire = incident(
        id: 21,
        state: 'detected_recently',
        overpasses: 5,
        frp: 50.55,
        tier: 'high',
        durationHours: 21.1,
      );
      expect(bigFire.looksLikeFixedSource, isFalse);
    });

    test('does not flag a short event however weak', () {
      final fresh = incident(
        id: 22,
        state: 'detected_recently',
        overpasses: 1,
        frp: 2,
        durationHours: 0,
      );
      expect(fresh.looksLikeFixedSource, isFalse);
    });

    test('does not flag a long event with big gaps between passes', () {
      // Two passes across 34 hours is a fire that cloud kept hiding, not
      // something visible on every overpass.
      final gappy = incident(
        id: 23,
        state: 'no_recent_detection',
        overpasses: 2,
        frp: 5,
        durationHours: 34.5,
      );
      expect(gappy.looksLikeFixedSource, isFalse);
    });
  });

  group('IncidentSource labels', () {
    // FIRMS ships platform codes, not names. Every code observed in the live
    // feed must map to something a reader recognises, or the panel shows
    // "VIIRS · N20" and the transparency work achieves nothing.
    test('maps every platform code seen in the live feed', () {
      const seen = {
        'N': 'Suomi-NPP',
        'N20': 'NOAA-20',
        'N21': 'NOAA-21',
        'Terra': 'Terra',
        'Aqua': 'Aqua',
      };
      seen.forEach((code, name) {
        final s = IncidentSource(product: 'VIIRS_SNPP_NRT', satellite: code, count: 1);
        expect(s.platform, name, reason: 'platform code $code');
      });
    });

    test('names the instrument from the product, and survives an unknown one', () {
      expect(
        const IncidentSource(product: 'MODIS_NRT', satellite: 'Terra', count: 3).label,
        'MODIS · Terra',
      );
      expect(
        const IncidentSource(product: 'VIIRS_NOAA21_NRT', satellite: 'N21', count: 2).label,
        'VIIRS · NOAA-21',
      );
      // An unrecognised code must not crash or print "null".
      const unknown =
          IncidentSource(product: 'VIIRS_SNPP_NRT', satellite: null, count: 1);
      expect(unknown.label, 'VIIRS');
    });
  });
}
