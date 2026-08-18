import 'package:flutter_test/flutter_test.dart';

import 'package:firewatch_tr/models/saved_place.dart';
import 'package:firewatch_tr/services/fwi_point_service.dart';
import 'package:firewatch_tr/services/saved_places_provider.dart';
import 'package:firewatch_tr/services/turkey_places_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SavedPlace', () {
    test('pin gets a ~10 km viewing window around itself', () {
      final pin = SavedPlace.pin(id: 'p', name: 'x', lat: 38.0, lng: 29.0);
      expect(pin.contains(38.0, 29.0), isTrue);
      expect(pin.contains(38.04, 29.04, padDeg: 0), isTrue);
      expect(pin.contains(38.2, 29.0, padDeg: 0), isFalse);
    });

    test('containment pads by default so borderline fires still count', () {
      final pin = SavedPlace.pin(id: 'p', name: 'x', lat: 38.0, lng: 29.0);
      // 0.05 window + 0.05 pad = 0.1 from centre.
      expect(pin.contains(38.09, 29.0), isTrue);
      expect(pin.contains(38.11, 29.0), isFalse);
    });

    test('json round-trip preserves everything', () {
      final pin = SavedPlace.pin(id: 'p1', name: 'Ev', lat: 37.5, lng: 30.1);
      final back = SavedPlace.fromJson(pin.toJson());
      expect(back.id, 'p1');
      expect(back.name, 'Ev');
      expect(back.kind, SavedPlaceKind.pin);
      expect(back.west, pin.west);
      expect(back.north, pin.north);
    });
  });

  group('SavedPlacesNotifier.decode', () {
    test('bad or empty input decodes to an empty list, never throws', () {
      expect(SavedPlacesNotifier.decode(null), isEmpty);
      expect(SavedPlacesNotifier.decode(''), isEmpty);
      expect(SavedPlacesNotifier.decode('not json'), isEmpty);
    });
  });

  group('FwiPointService.nearestClass', () {
    test('exact palette colours map to their own class', () {
      expect(FwiPointService.nearestClass(0x9C, 0xFF, 0xC0), 0);
      expect(FwiPointService.nearestClass(0xD9, 0x70, 0x10), 3);
      expect(FwiPointService.nearestClass(0x3A, 0x00, 0x15), 5);
    });

    test('a resampled off-palette pixel snaps to the nearest class', () {
      // Slightly darkened "high" orange still reads as high.
      expect(FwiPointService.nearestClass(0xD0, 0x68, 0x0C), 3);
      // A blend halfway toward very-high is closest to one of the two,
      // never a made-up seventh class.
      final blended = FwiPointService.nearestClass(0xC3, 0x3B, 0x0F);
      expect(blended == 3 || blended == 4, isTrue);
    });
  });

  group('TurkeyPlacesService', () {
    test('bundled list covers all provinces and finds folded queries',
        () async {
      final usak = await TurkeyPlacesService.instance.search('usak');
      expect(usak, isNotEmpty);
      expect(usak.first.name, 'Uşak');
      expect(usak.first.kind, SavedPlaceKind.province);

      final kas = await TurkeyPlacesService.instance.search('Kaş');
      expect(
        kas.any(
          (p) => p.name == 'Kaş' && p.subtitle == 'Antalya',
        ),
        isTrue,
      );

      // Denizli's box must contain Denizli's centre — the map zoom and the
      // FWI sample both depend on box/centre agreeing.
      final denizli =
          (await TurkeyPlacesService.instance.search('Denizli')).first;
      expect(denizli.contains(denizli.lat, denizli.lng, padDeg: 0), isTrue);
    });
  });
}
