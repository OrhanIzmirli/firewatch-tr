import 'package:flutter_test/flutter_test.dart';
import 'package:firewatch_tr/models/fire_point.dart';
import 'package:firewatch_tr/services/fire_api_service.dart';

FirePoint _point({
  required double lat,
  required double lng,
  String confidence = 'n',
  String brightness = '330',
  String satellite = 'VIIRS',
  String date = '2026-07-08',
  String time = '1200',
}) {
  return FirePoint(
    latitude: lat,
    longitude: lng,
    brightness: brightness,
    confidence: confidence,
    satellite: satellite,
    acquisitionDate: date,
    acquisitionTime: time,
  );
}

void main() {
  test('merges two points within 500m and 3 hours into one', () {
    final fires = [
      _point(lat: 39.0, lng: 35.0, satellite: 'VIIRS', confidence: 'n', time: '1200'),
      // ~100m away, 1 hour later
      _point(lat: 39.0009, lng: 35.0, satellite: 'MODIS', confidence: 'h', time: '1300'),
    ];

    final result = FireApiService.deduplicateFires(fires);

    expect(result.length, 1);
    expect(result.first.isMerged, isTrue);
    expect(result.first.mergedSatelliteLabel, 'MODIS + VIIRS');
  });

  test('keeps points further than 500m apart as separate fires', () {
    final fires = [
      _point(lat: 39.0, lng: 35.0),
      _point(lat: 39.05, lng: 35.0), // ~5.5km away
    ];

    final result = FireApiService.deduplicateFires(fires);

    expect(result.length, 2);
    expect(result.every((p) => !p.isMerged), isTrue);
  });

  test('keeps points more than 3 hours apart as separate fires even if co-located', () {
    final fires = [
      _point(lat: 39.0, lng: 35.0, time: '0000'),
      _point(lat: 39.0, lng: 35.0, time: '0500'), // 5 hours later
    ];

    final result = FireApiService.deduplicateFires(fires);

    expect(result.length, 2);
  });

  test('keeps the higher-confidence point when merging', () {
    final fires = [
      _point(lat: 39.0, lng: 35.0, confidence: 'n', brightness: '300'),
      _point(lat: 39.0001, lng: 35.0, confidence: 'h', brightness: '310'),
    ];

    final result = FireApiService.deduplicateFires(fires);

    expect(result.length, 1);
    expect(result.first.confidence, 'h');
  });

  test('understands MODIS numeric confidence when merging', () {
    final fires = [
      _point(lat: 39.0, lng: 35.0, confidence: '20', brightness: '390'),
      _point(lat: 39.0001, lng: 35.0, confidence: '90', brightness: '310'),
    ];

    final result = FireApiService.deduplicateFires(fires);

    expect(result, hasLength(1));
    expect(result.first.confidence, '90');
  });

  test('breaks ties by higher brightness when confidence is equal', () {
    final fires = [
      _point(lat: 39.0, lng: 35.0, confidence: 'n', brightness: '300'),
      _point(lat: 39.0001, lng: 35.0, confidence: 'n', brightness: '380'),
    ];

    final result = FireApiService.deduplicateFires(fires);

    expect(result.length, 1);
    expect(result.first.brightness, '380');
  });

  test('does not merge a satellite with itself twice', () {
    final fires = [
      _point(lat: 39.0, lng: 35.0, satellite: 'VIIRS'),
      _point(lat: 39.0001, lng: 35.0, satellite: 'VIIRS'),
    ];

    final result = FireApiService.deduplicateFires(fires);

    expect(result.length, 1);
    expect(result.first.isMerged, isFalse);
    expect(result.first.mergedSatelliteLabel, 'VIIRS');
  });

  test('three-way merge combines all satellite names', () {
    final fires = [
      _point(lat: 39.0, lng: 35.0, satellite: 'VIIRS', confidence: 'h', brightness: '400'),
      _point(lat: 39.0001, lng: 35.0, satellite: 'MODIS', confidence: 'n'),
      _point(lat: 39.0002, lng: 35.0, satellite: 'AVHRR', confidence: 'n'),
    ];

    final result = FireApiService.deduplicateFires(fires);

    expect(result.length, 1);
    expect(result.first.mergedSatelliteLabel, 'VIIRS + MODIS + AVHRR');
  });

  test('empty input returns empty output', () {
    expect(FireApiService.deduplicateFires([]), isEmpty);
  });
}
