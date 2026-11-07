import 'dart:io';

import 'package:firewatch_tr/core/utils/map_tiles.dart';
import 'package:firewatch_tr/shared/widgets/carto_basemap.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('fw_tiles_');
  });
  tearDown(() async {
    MapTiles.cacheDirForTest = null;
    if (await dir.exists()) await dir.delete(recursive: true);
  });

  const cartoUrl =
      'https://basemaps.cartocdn.com/rastertiles/dark_all/{z}/{x}/{y}.png?key=x';

  test('only OSM tiles get the disk cache; CARTO stores nothing at all', () {
    MapTiles.cacheDirForTest = dir;
    expect(MapTiles.providerFor(MapTiles.osmUrl), isA<DiskCachedTileProvider>());
    final carto = MapTiles.providerFor(cartoUrl);
    expect(carto, isA<NetworkTileProvider>());
    // flutter_map caches by default; for CARTO that must be switched off.
    expect(
      (carto as NetworkTileProvider).cachingProvider,
      isA<DisabledMapCachingProvider>(),
    );
    expect(CartoBasemap.url, isNot(MapTiles.osmUrl));
  });

  test('without a cache directory OSM falls back to the network provider', () {
    expect(MapTiles.providerFor(MapTiles.osmUrl), isA<NetworkTileProvider>());
  });

  group('OSM tile policy', () {
    test('User-Agent names the app: package and version', () {
      expect(
        MapTiles.buildUserAgent('1.2.0', '8'),
        'FireWatchTR/1.2.0+8 (com.oguzh.firewatch.firewatch_tr)',
      );
      expect(
        MapTiles.buildUserAgent(null, null),
        'FireWatchTR (com.oguzh.firewatch.firewatch_tr)',
      );
    });

    test('every provider sends that User-Agent, cached or not', () {
      MapTiles.userAgent = MapTiles.buildUserAgent('1.2.0', '8');
      for (final withDir in [true, false]) {
        MapTiles.cacheDirForTest = withDir ? dir : null;
        for (final url in [MapTiles.osmUrl, cartoUrl]) {
          expect(
            MapTiles.providerFor(url).headers['User-Agent'],
            'FireWatchTR/1.2.0+8 (com.oguzh.firewatch.firewatch_tr)',
            reason: '$url withDir=$withDir',
          );
        }
      }
    });

    test('a TileLayer does not overwrite it with flutter_map\'s default', () {
      MapTiles.userAgent = MapTiles.buildUserAgent('1.2.0', '8');
      final layer = TileLayer(
        urlTemplate: MapTiles.osmUrl,
        tileProvider: MapTiles.providerFor(MapTiles.osmUrl),
        userAgentPackageName: MapTiles.packageName,
      );
      expect(layer.tileProvider.headers['User-Agent'], startsWith('FireWatchTR/'));
    });

    test('cache lifetime meets the 7-day minimum', () {
      expect(DiskCachedTileProvider.maxAge.inDays, greaterThanOrEqualTo(7));
    });

    // No pre-fetching: nothing may widen flutter_map's default one-tile
    // pan buffer or download tiles outside a visible map.
    test('no bulk download anywhere in lib/', () {
      final src = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .map((f) => f.readAsStringSync())
          .join('\n');
      expect(src, isNot(contains('panBuffer')));
      expect(src, isNot(contains('keepBuffer')));
      expect(src, isNot(contains('downloadRegion')));
    });

    test('every map that can draw OSM tiles shows the OSM attribution', () {
      final files = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .where((f) => f.readAsStringSync().contains('MapTiles.osmUrl'));
      expect(files, isNotEmpty);
      for (final f in files) {
        expect(f.readAsStringSync(), contains('OsmAttribution('), reason: f.path);
      }
    });
  });

  test('tiles are stored per z/x/y under an osm_ prefix', () {
    final f = DiskCachedTileProvider.fileFor(dir, const TileCoordinates(5, 9, 7));
    expect(f.path.endsWith('osm_7_5_9.png'), isTrue);
  });

  test('a cached tile is served for 14 days, then refetched', () async {
    final f = File('${dir.path}/osm_1_1_1.png')..writeAsBytesSync([1, 2, 3]);
    final written = DateTime(2026, 11, 1);
    f.setLastModifiedSync(written);
    final fresh = await DiskCachedTileProvider.readFresh(
      f,
      now: written.add(const Duration(days: 14)),
    );
    expect(fresh, [1, 2, 3]);
    final stale = await DiskCachedTileProvider.readFresh(
      f,
      now: written.add(const Duration(days: 14, minutes: 1)),
    );
    expect(stale, isNull);
    expect(DiskCachedTileProvider.maxAge, const Duration(days: 14));
  });

  test('a missing tile reads as null', () async {
    expect(await DiskCachedTileProvider.readFresh(File('${dir.path}/none.png')), isNull);
  });

  test('prune keeps everything up to the limit', () async {
    for (var i = 0; i < 8; i++) {
      File('${dir.path}/t$i.png').writeAsBytesSync([i]);
    }
    expect(await MapTiles.prune(dir, limit: 8), 0);
    expect(dir.listSync().length, 8);
  });

  test('over the limit, the oldest quarter is deleted', () async {
    final base = DateTime(2026, 10, 1);
    for (var i = 0; i < 12; i++) {
      File('${dir.path}/t$i.png')
        ..writeAsBytesSync([i])
        ..setLastModifiedSync(base.add(Duration(hours: i)));
    }
    expect(await MapTiles.prune(dir, limit: 10), 3);
    final left = dir.listSync().map((e) => e.uri.pathSegments.last).toSet();
    expect(left.contains('t0.png') || left.contains('t1.png') || left.contains('t2.png'), isFalse);
    expect(left.length, 9);
    expect(MapTiles.maxTiles, 4000);
  });
}
