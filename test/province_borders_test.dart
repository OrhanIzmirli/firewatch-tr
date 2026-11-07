// The province boundary file: geoBoundaries gbOpen TUR ADM1 (OSM, ODbL),
// shared byte-for-byte with the backend (database/seed/
// turkey_province_borders.geojson, same SHA-256 pinned in its tests).
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:firewatch_tr/l10n/app_localizations_tr.dart';

/// Change only together with the backend copy and its test.
const provinceBordersSha256 = 'd51cf911a4cf6582142b3c81eb2594e828b08c600d63054a317c1281d283002a';

/// turkey_cities.id → name, as in the backend database after migration 015.
const _names = <String>[
  'Adana', 'Adıyaman', 'Afyonkarahisar', 'Ağrı', 'Amasya', 'Ankara', 'Antalya', 'Artvin', 'Aydın', 'Balıkesir',
  'Bilecik', 'Bingöl', 'Bitlis', 'Bolu', 'Burdur', 'Bursa', 'Çanakkale', 'Çankırı', 'Çorum', 'Denizli',
  'Diyarbakır', 'Edirne', 'Elazığ', 'Erzincan', 'Erzurum', 'Eskişehir', 'Gaziantep', 'Giresun', 'Gümüşhane', 'Hakkari',
  'Hatay', 'Isparta', 'Mersin', 'İstanbul', 'İzmir', 'Kars', 'Kastamonu', 'Kayseri', 'Kırklareli', 'Kırşehir',
  'Kocaeli', 'Konya', 'Kütahya', 'Malatya', 'Manisa', 'Kahramanmaraş', 'Mardin', 'Muğla', 'Muş', 'Nevşehir',
  'Niğde', 'Ordu', 'Rize', 'Sakarya', 'Samsun', 'Siirt', 'Sinop', 'Sivas', 'Tekirdağ', 'Tokat',
  'Trabzon', 'Tunceli', 'Şanlıurfa', 'Uşak', 'Van', 'Yozgat', 'Zonguldak', 'Aksaray', 'Bayburt', 'Karaman',
  'Kırıkkale', 'Batman', 'Şırnak', 'Bartın', 'Ardahan', 'Iğdır', 'Yalova', 'Karabük', 'Kilis', 'Osmaniye',
  'Düzce',
];

void main() {
  final file = File('assets/data/il_sinirlari.geojson');
  final doc = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final features = (doc['features'] as List).cast<Map<String, dynamic>>();

  test('81 provinces, plates 01–81 once each, names as in the database', () {
    expect(features, hasLength(81));
    final plates = [for (final f in features) f['properties']['plaka'] as String];
    expect(plates, [for (var i = 1; i <= 81; i++) i.toString().padLeft(2, '0')]);
    for (final f in features) {
      final plate = int.parse(f['properties']['plaka'] as String);
      expect(f['properties']['il'], _names[plate - 1], reason: 'plate $plate');
    }
    expect(features[32]['properties']['il'], 'Mersin');
  });

  test('the source is geoBoundaries/OSM, credited, and not GADM', () {
    expect(doc['attribution'], contains('geoBoundaries'));
    expect(doc['attribution'], contains('OpenStreetMap'));
    expect(doc['attribution'], contains('ODbL'));
    expect(file.readAsStringSync(), isNot(contains('GADM')));
    final tr = AppLocalizationsTr();
    expect(tr.dataSourcesBordersBody, contains('geoBoundaries'));
    expect(tr.annualLayerBorderCredit, contains('OpenStreetMap'));
  });

  test('the file is the one pinned for the backend', () {
    expect(sha256.convert(file.readAsBytesSync()).toString(), provinceBordersSha256);
  });
}
