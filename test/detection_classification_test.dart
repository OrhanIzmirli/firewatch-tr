import 'package:firewatch_tr/models/fire_point.dart';
import 'package:flutter_test/flutter_test.dart';

FirePoint point({String confidence = 'h', double frp = 31, String brightness = '351'}) => FirePoint(
  latitude: 39, longitude: 35, brightness: brightness, confidence: confidence,
  satellite: 'VIIRS', acquisitionDate: '2026-07-10', acquisitionTime: '1200', frp: frp,
);

void main() {
  test('only strong high-confidence detections are probable fires', () {
    expect(point().isProbableFire, isTrue);
    expect(point(frp: 30).isProbableFire, isFalse);
    expect(point(brightness: '350').isProbableFire, isFalse);
    expect(point(confidence: 'n').isProbableFire, isFalse);
  });
}
