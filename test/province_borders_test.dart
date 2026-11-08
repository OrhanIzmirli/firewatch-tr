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
    // ODbL attribution: "© OpenStreetMap contributors, ODbL" + licence link.
    expect(tr.osmAttribution, '© OpenStreetMap katkıcıları, ODbL');
    // The legend no longer passes the data file's "il sınırları GADM 4.1"
    // off as the drawn borders.
    expect(tr.annualLayerProvenance, contains('geoBoundaries / OpenStreetMap'));
    expect(tr.annualLayerProvenance, contains('uydu noktası sayıları GADM 4.1'));
    // The credit sits behind the "Sources" link of both places that show the
    // layer; the map itself always carries the OSM attribution.
    expect(File('lib/features/map/widgets/map_sources.dart').readAsStringSync(), contains('ProvinceBordersCredit('));
    for (final f in ['lib/features/map/widgets/map_layers_panel.dart', 'lib/features/map/widgets/annual_province_layer.dart']) {
      final src = File(f).readAsStringSync();
      expect(src, contains('MapSourcesLink('), reason: f);
      expect(src, isNot(contains('annualLayerSources')), reason: f);
    }
    expect(File('lib/features/map/map_screen.dart').readAsStringSync(), contains('OsmAttribution('));
    final credit = File('lib/shared/widgets/province_borders_credit.dart').readAsStringSync();
    expect(credit, contains('https://www.openstreetmap.org/copyright'));
    expect(credit, contains('https://opendatacommons.org/licenses/odbl/'));
    expect(File('lib/features/settings/data_sources_screen.dart').readAsStringSync(), contains('odblLicenseUrl'));
  });

  test('the file is the one pinned for the backend', () {
    expect(sha256.convert(file.readAsBytesSync()).toString(), provinceBordersSha256);
  });
}
