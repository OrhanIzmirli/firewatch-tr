import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

/// OpenStreetMap tiles with a disk cache. Ported from 1.0.6.
///
/// OSM tile usage policy (operations.osmfoundation.org/policies/tiles),
/// and how this app meets it:
///  * a User-Agent that identifies the app — [userAgent], package name and
///    version, sent on every tile request (OSM and CARTO alike);
///  * cache tiles locally, honouring HTTP expiry or at least 7 days — tiles
///    are kept for [DiskCachedTileProvider.maxAge] (14 days);
///  * no bulk downloading — tiles are fetched only when a map shows them
///    (flutter_map's default one-tile pan buffer); nothing is pre-fetched;
///  * visible attribution — OsmAttribution on every map that draws OSM.
///
/// Only OSM tiles are stored. CARTO's terms for stored tiles are not
/// settled, so a CARTO URL gets a network provider with flutter_map's own
/// built-in cache switched OFF (it is on by default).
class MapTiles {
  MapTiles._();

  static const String osmUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  static const String packageName = 'com.oguzh.firewatch.firewatch_tr';

  /// Beyond this many files (~150 MB worst case) the oldest quarter goes.
  static const int maxTiles = 4000;

  static Directory? _cacheDir;

  /// "FireWatchTR/1.2.0+8 (com.oguzh.firewatch.firewatch_tr)". Set from the
  /// installed build in [init]; the fallback still names the app.
  static String userAgent = buildUserAgent(null, null);

  static String buildUserAgent(String? version, String? buildNumber) {
    final v = (version ?? '').trim();
    final b = (buildNumber ?? '').trim();
    final ver = v.isEmpty ? '' : (b.isEmpty ? '/$v' : '/$v+$b');
    return 'FireWatchTR$ver ($packageName)';
  }

  /// Called once from main() before the first map builds. Local disk and
  /// platform only, no network. Without a cache directory the maps still
  /// work, uncached.
  static Future<void> init() async {
    if (kIsWeb) return;
    try {
      final info = await PackageInfo.fromPlatform();
      userAgent = buildUserAgent(info.version, info.buildNumber);
    } catch (_) {}
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

  static Map<String, String> get _headers => {'User-Agent': userAgent};

  /// Shared by every network provider. Maps rebuild often and get a new
  /// provider each time; passing a client in means a disposed provider
  /// never closes it, and no rebuild opens a fresh connection pool.
  static final http.Client _networkClient = RetryClient(http.Client());

  /// The tile provider for [urlTemplate], always sending [userAgent]:
  /// the disk cache for OSM; for anything else (CARTO) a plain network
  /// provider that stores nothing. Without a cache directory OSM falls back
  /// to flutter_map's network provider and its HTTP-header-based cache.
  static TileProvider providerFor(String urlTemplate) {
    final dir = _cacheDir;
    if (urlTemplate == osmUrl) {
      return dir == null
          ? NetworkTileProvider(headers: _headers, httpClient: _networkClient)
          : DiskCachedTileProvider(cacheDir: dir, headers: _headers);
    }
    return NetworkTileProvider(
      headers: _headers,
      httpClient: _networkClient,
      cachingProvider: const DisabledMapCachingProvider(),
    );
  }
}

/// Keeps every downloaded OSM tile on disk and serves it from there while
/// fresh; a stale or missing tile is re-downloaded, and when the network
/// fails a stale copy is still better than a grey square.
class DiskCachedTileProvider extends TileProvider {
  DiskCachedTileProvider({required this.cacheDir, super.headers});

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
