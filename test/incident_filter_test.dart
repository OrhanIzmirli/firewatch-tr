import 'package:flutter_test/flutter_test.dart';
import 'package:firewatch_tr/models/fire_incident.dart';

FireIncident incident({
  required int id,
  required String state,
  int overpasses = 1,
  double? frp,
  String? tier = 'nominal',
}) {
  return FireIncident(
    id: id,
    latitude: 39,
    longitude: 35,
    satelliteState: state,
    hoursSinceLastDetection: state == 'detected_recently' ? 2 : 30,
    durationHours: 1,
    detectionCount: 1,
    overpassCount: overpasses,
    spreadConfidence: 'insufficient',
    maxFrpMw: frp,
    peakConfidenceTier: tier,
  );
}

void main() {
  group('IncidentSignificance', () {
    test('needs all three of passes, power and confidence', () {
      expect(
        incident(id: 1, state: 'x', overpasses: 2, frp: 10, tier: 'nominal')
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
        incident(id: 3, state: 'x', overpasses: 9, frp: 9.99, tier: 'high')
            .isSignificant,
        isFalse,
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
}
