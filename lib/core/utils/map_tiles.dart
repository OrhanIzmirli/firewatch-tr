import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// OpenStreetMap tiles with a disk cache. Ported from 1.0.6.
///
/// Only OSM tiles are cached. OSM's tile usage policy asks apps to cache
/// and to honour a sensible lifetime; CARTO's terms for stored tiles are
/// not settled, so a CARTO URL always goes to the network
/// ([providerFor] returns null and flutter_map uses its default).
class MapTiles {
  MapTiles._();

  static const String osmUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// Beyond this many files (~150 MB worst case) the oldest quarter goes.
  static const int maxTiles = 4000;

  static Directory? _cacheDir;

  /// Called once from main() before the first map builds. Local disk only,
  /// no network. Without a cache directory the maps still work, uncached.
  static Future<void> init() async {
    if (kIsWeb) return;
    try {
      final base = await getApplicationCacheDirectory();
      final dir = Directory('${base.path}/map_tiles');
      await dir.create(recursive: true);
      _cacheDir = dir;
      unawaited(prune(dir));
    } catch (_) {}
  }

  /// Drops the oldest quarter once the cache holds more than [limit] tiles.
  /// Returns how many files were deleted.
  static Future<int> prune(Directory dir, {int limit = maxTiles}) async {
    try {
      final files = await dir.list().where((e) => e is File).cast<File>().toList();
      if (files.length <= limit) return 0;
      final stats = <(File, DateTime)>[
        for (final f in files) (f, (await f.stat()).modified),
      ]..sort((a, b) => a.$2.compareTo(b.$2));
      var deleted = 0;
      for (final (file, _) in stats.take(files.length ~/ 4)) {
        await file.delete();
        deleted++;
      }
      return deleted;
    } catch (_) {
      return 0;
    }
  }

  @visibleForTesting
  static set cacheDirForTest(Directory? dir) => _cacheDir = dir;

  /// The tile provider for [urlTemplate]: the disk cache for OSM, null
  /// (flutter_map's default network provider) for anything else.
  static TileProvider? providerFor(String urlTemplate) {
    final dir = _cacheDir;
    if (dir == null || urlTemplate != osmUrl) return null;
    return DiskCachedTileProvider(cacheDir: dir);
  }
}

/// Keeps every downloaded OSM tile on disk and serves it from there while
/// fresh; a stale or missing tile is re-downloaded, and when the network
/// fails a stale copy is still better than a grey square.
class DiskCachedTileProvider extends TileProvider {
  DiskCachedTileProvider({required this.cacheDir});

  final Directory cacheDir;

  static const Duration maxAge = Duration(days: 14);

  /// One client for every tile: connection reuse instead of a TCP+TLS
  /// handshake per tile.
  static final http.Client _client = http.Client();

  static File fileFor(Directory dir, TileCoordinates c) =>
      File('${dir.path}/osm_${c.z}_${c.x}_${c.y}.png');

  /// Cached bytes if the file exists and is younger than [maxAge].
  static Future<Uint8List?> readFresh(File file, {DateTime? now}) async {
    try {
      if (!await file.exists()) return null;
      final modified = (await file.stat()).modified;
      if ((now ?? DateTime.now()).difference(modified) > maxAge) return null;
      return await file.readAsBytes();
    } catch (_) {
      return null;
    }
  }

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    return _DiskCachedTileImage(
      url: getTileUrl(coordinates, options),
      file: fileFor(cacheDir, coordinates),
      headers: headers,
      client: _client,
    );
  }
}

class _DiskCachedTileImage extends ImageProvider<_DiskCachedTileImage> {
  const _DiskCachedTileImage({
    required this.url,
    required this.file,
    required this.headers,
    required this.client,
  });

  final String url;
  final File file;
  final Map<String, String> headers;
  final http.Client client;

  @override
  Future<_DiskCachedTileImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(
    _DiskCachedTileImage key,
    ImageDecoderCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(
      codec: _loadCodec(decode),
      scale: 1,
      debugLabel: url,
    );
  }

  Future<Codec> _loadCodec(ImageDecoderCallback decode) async {
    final cached = await DiskCachedTileProvider.readFresh(file);
    if (cached != null) {
      return decode(await ImmutableBuffer.fromUint8List(cached));
    }
    try {
      final response = await client
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        unawaited(_write(response.bodyBytes));
        return decode(await ImmutableBuffer.fromUint8List(response.bodyBytes));
      }
      throw HttpException('tile ${response.statusCode}', uri: Uri.parse(url));
    } catch (_) {
      if (await file.exists()) {
        return decode(
          await ImmutableBuffer.fromUint8List(await file.readAsBytes()),
        );
      }
      rethrow;
    }
  }

  Future<void> _write(Uint8List bytes) async {
    try {
      await file.writeAsBytes(bytes, flush: false);
    } catch (_) {}
  }

  @override
  bool operator ==(Object other) =>
      other is _DiskCachedTileImage && other.url == url;

  @override
  int get hashCode => url.hashCode;
}
