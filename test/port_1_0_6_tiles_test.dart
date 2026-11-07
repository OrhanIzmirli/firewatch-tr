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

  test('only OSM tiles get the disk cache; CARTO goes to the network', () {
    MapTiles.cacheDirForTest = dir;
    expect(MapTiles.providerFor(MapTiles.osmUrl), isA<DiskCachedTileProvider>());
    expect(
      MapTiles.providerFor(
        'https://basemaps.cartocdn.com/rastertiles/dark_all/{z}/{x}/{y}.png?key=x',
      ),
      isNull,
    );
    expect(CartoBasemap.url, isNot(MapTiles.osmUrl));
  });

  test('without a cache directory every map falls back to the network', () {
    expect(MapTiles.providerFor(MapTiles.osmUrl), isNull);
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
