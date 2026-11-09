import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:firewatch_tr/core/utils/image_metadata.dart';
import 'package:firewatch_tr/services/alert_preference.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _secret = 'GPSLatitude37.123456';

Uint8List _seg(int marker, List<int> payload) =>
    Uint8List.fromList([0xff, marker, (payload.length + 2) >> 8, (payload.length + 2) & 255, ...payload]);

List<int> _exif(int orientation, {bool little = false}) {
  List<int> u16(int v) => little ? [v & 255, v >> 8] : [v >> 8, v & 255];
  List<int> u32(int v) => little ? [v, 0, 0, 0] : [0, 0, 0, v];
  return [
    ...latin1.encode('Exif\u0000\u0000'),
    ...latin1.encode(little ? 'II' : 'MM'),
    ...u16(42), ...u32(8), ...u16(1), ...u16(0x0112), ...u16(3), ...u32(1), ...u16(orientation), 0, 0, 0, 0, 0, 0,
    ...latin1.encode(_secret),
  ];
}

const _scan = [0x11, 0xff, 0x00, 0x22, 0xff, 0xd0, 0x33];

Uint8List _jpeg([List<List<int>> middle = const []]) => Uint8List.fromList([
      0xff, 0xd8,
      ..._seg(0xe0, latin1.encode('JFIF\u0000\u0001\u0001')),
      for (final m in middle) ...m,
      ..._seg(0xdb, List.filled(65, 7)),
      ..._seg(0xc0, List.filled(9, 8)),
      ..._seg(0xda, List.filled(8, 9)),
      ..._scan,
      0xff, 0xd9,
    ]);

bool _has(Uint8List data, String text) => latin1.decode(data).contains(text);

Uint8List _pngChunk(String type, List<int> data) =>
    Uint8List.fromList([0, 0, 0, data.length, ...latin1.encode(type), ...data, 0, 0, 0, 0]);

const _pngSignature = [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a];

Uint8List _webChunk(String type, List<int> data) =>
    Uint8List.fromList([...latin1.encode(type), data.length, 0, 0, 0, ...data, if (data.length.isOdd) 0]);

Uint8List _riff(List<Uint8List> chunks) {
  final body = [...latin1.encode('WEBP'), for (final c in chunks) ...c];
  return Uint8List.fromList([...latin1.encode('RIFF'), body.length, 0, 0, 0, ...body]);
}

void main() {
  group('photo metadata', () {
    test('JPEG loses GPS and keeps the image data byte for byte', () {
      final out = stripImageMetadata(_jpeg([_seg(0xe1, _exif(1))]))!;
      expect(_has(out, _secret), isFalse);
      expect(_has(out, 'Exif'), isFalse);
      expect(out, _jpeg());
    });

    for (final little in [false, true]) {
      test('a rotated JPEG keeps only its orientation (${little ? 'II' : 'MM'})', () {
        final out = stripImageMetadata(_jpeg([_seg(0xe1, _exif(6, little: little))]))!;
        expect(_has(out, _secret), isFalse);
        expect(_has(out, 'Exif'), isTrue);
        expect(out.length, _jpeg().length + 36);
        expect(stripImageMetadata(out), out, reason: 'cleaning twice changes nothing');
      });
    }

    test('XMP, comments, IPTC and MPF go; colour profile stays', () {
      final out = stripImageMetadata(_jpeg([
        _seg(0xe1, latin1.encode('http://ns.adobe.com/xap/1.0/\u0000$_secret')),
        _seg(0xfe, latin1.encode(_secret)),
        _seg(0xed, latin1.encode('Photoshop 3.0\u0000$_secret')),
        _seg(0xe2, latin1.encode('MPF\u0000$_secret')),
        _seg(0xe2, latin1.encode('ICC_PROFILE\u0000abc')),
      ]))!;
      expect(_has(out, _secret), isFalse);
      expect(_has(out, 'ICC_PROFILE'), isTrue);
    });

    test('bytes after the end of the image go', () {
      final out = stripImageMetadata(Uint8List.fromList([..._jpeg(), ..._jpeg([_seg(0xe1, _exif(1))])]))!;
      expect(out, _jpeg());
    });

    test('PNG loses text and EXIF chunks', () {
      final clean = Uint8List.fromList([
        ..._pngSignature, ..._pngChunk('IHDR', List.filled(13, 0)), ..._pngChunk('IDAT', [1, 2]), ..._pngChunk('IEND', []),
      ]);
      final dirty = Uint8List.fromList([
        ..._pngSignature, ..._pngChunk('IHDR', List.filled(13, 0)),
        ..._pngChunk('eXIf', latin1.encode(_secret)), ..._pngChunk('tEXt', latin1.encode(_secret)),
        ..._pngChunk('IDAT', [1, 2]), ..._pngChunk('IEND', []),
        ...latin1.encode(_secret),
      ]);
      expect(stripImageMetadata(dirty), clean);
    });

    test('WebP loses EXIF and XMP; the flags and the size follow', () {
      final out = stripImageMetadata(_riff([
        _webChunk('VP8X', [0x1c, ...List.filled(9, 0)]),
        _webChunk('VP8 ', List.filled(7, 4)),
        _webChunk('EXIF', latin1.encode(_secret)),
        _webChunk('XMP ', latin1.encode(_secret)),
      ]))!;
      expect(_has(out, _secret), isFalse);
      expect(out[20], 0x10);
      expect(ByteData.sublistView(out).getUint32(4, Endian.little), out.length - 8);
    });

    test('what it cannot clean comes back null, never as the original', () {
      expect(stripImageMetadata(Uint8List.fromList([0xff, 0xd8, 0xff, 0xe1, 0xff, 0xff, 1])), isNull);
      expect(stripImageMetadata(Uint8List.fromList([0xff, 0xd8, 0xff, 0x41, 0, 2, 0, 0, 5])), isNull);
      expect(stripImageMetadata(Uint8List.fromList(latin1.encode('not an image at all'))), isNull);
    });

    test('the report sends only cleaned bytes', () {
      final panel = File('lib/shared/widgets/report_fire_panel.dart').readAsStringSync();
      expect(panel, contains('stripImageMetadata(await photo.readAsBytes())'));
      expect(panel, isNot(contains('base64Encode(await photo.readAsBytes())')));
    });
  });

  group('alert preference', () {
    Future<SharedPreferences> prefs(Map<String, Object> values) async {
      SharedPreferences.setMockInitialValues(values);
      return SharedPreferences.getInstance();
    }

    test('on by default, off when either older setting was turned off', () async {
      expect(alertsWanted(await prefs({})), isTrue);
      expect(alertsWanted(await prefs({'settings_push_notifications': false})), isFalse);
      expect(alertsWanted(await prefs({'notifications_enabled': false})), isFalse);
    });

    test('the latest choice wins over the older settings', () async {
      expect(alertsWanted(await prefs({kAlertsWantedKey: true, 'notifications_enabled': false})), isTrue);
      expect(alertsWanted(await prefs({kAlertsWantedKey: false, 'settings_push_notifications': true})), isFalse);
    });

    test('opening the app never asks for alerts once synced', () {
      expect(startupActiveFlag(wanted: true, synced: true), isNull);
      expect(startupActiveFlag(wanted: false, synced: true), isFalse);
      expect(startupActiveFlag(wanted: false, synced: false), isFalse);
      expect(startupActiveFlag(wanted: true, synced: false), isTrue);
    });

    test('no background path turns alerts back on', () {
      final source = File('lib/services/notification_service.dart').readAsStringSync();
      expect(source, contains('isActive: startupActiveFlag('));
      expect(source, contains('subscribeToNotifications(newToken, isActive: alertsWanted('));
      expect(source, isNot(contains('setNotificationActive(\n      token,\n      true,')));
      expect(source, isNot(contains("prefs.getBool('settings_push_notifications')")));
    });
  });
}
