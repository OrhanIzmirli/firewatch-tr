import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/config/api_config.dart';
import '../models/place_search_result.dart';
import '../models/tracked_place.dart';
import 'place_identity.dart';

/// Why a tracked-places call failed, in terms the UI can act on.
enum TrackedPlacesError {
  /// The server does not serve /api/places yet (migration 014 not applied).
  unavailable,
  placeLimit,
  outsideTurkey,
  invalid,
  network,
  unknown,
}

class TrackedPlacesException implements Exception {
  final TrackedPlacesError error;
  const TrackedPlacesException(this.error);
  @override
  String toString() => 'TrackedPlacesException($error)';
}

/// Client for the backend's /api/places (firewatch-tr-backend
/// src/routes/places.ts). Registers this install lazily on first use and
/// again if the server has forgotten it (90 days unused, or deleted).
/// Coordinates are only ever sent in request bodies.
class TrackedPlacesApi {
  TrackedPlacesApi({Dio? dio, Future<String?> Function()? fcmToken, Future<String> Function()? locale})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: ApiConfig.apiBaseUrl,
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 20),
            )),
        _fcmToken = fcmToken ?? (() async => null),
        _locale = locale ?? (() async => 'tr');

  final Dio _dio;
  final Future<String?> Function() _fcmToken;
  final Future<String> Function() _locale;

  /// Whether this install has ever registered for tracked places.
  Future<bool> hasIdentity() => PlaceIdentity.isRegistered();

  Future<Options> _auth() async {
    final id = await PlaceIdentity.readOrCreate();
    return Options(headers: {'X-Install-Id': id.installId, 'X-Install-Secret': id.secret});
  }

  Future<void> register({bool retried = false}) async {
    final id = await PlaceIdentity.readOrCreate();
    final token = await _fcmToken();
    final locale = await _locale();
    try {
      await _dio.post('/places/devices', data: {
        'install_id': id.installId,
        'secret': id.secret,
        'locale': locale == 'en' ? 'en' : 'tr',
        'fcm_token': ?token,
      });
      await PlaceIdentity.markRegistered(true);
    } on DioException catch (e) {
      // install_id taken by another secret: start over with a new identity.
      if (e.response?.statusCode == 409 && !retried) {
        await PlaceIdentity.clear();
        return register(retried: true);
      }
      throw _map(e);
    }
  }

  /// Runs [call], registering first when needed, and once more on a 401
  /// (the server deleted this install after 90 days, or the user did).
  Future<T> _withDevice<T>(Future<T> Function(Options auth) call) async {
    if (!await PlaceIdentity.isRegistered()) await register();
    try {
      return await call(await _auth());
    } on TrackedPlacesException {
      rethrow;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await PlaceIdentity.markRegistered(false);
        await register();
        try {
          return await call(await _auth());
        } on DioException catch (e2) {
          throw _map(e2);
        }
      }
      throw _map(e);
    } on Object catch (e) {
      // A response that isn't the documented shape: report, don't crash.
      if (kDebugMode) debugPrint('places: unexpected response: $e');
      throw const TrackedPlacesException(TrackedPlacesError.unknown);
    }
  }

  Future<List<TrackedPlace>> list() => _withDevice((auth) async {
        final r = await _dio.get('/places', options: auth);
        final data = (r.data['data'] as List).cast<Map<String, dynamic>>();
        return data.map(TrackedPlace.fromJson).toList();
      });

  Future<TrackedPlace> add({
    required String name,
    required double latitude,
    required double longitude,
    required int radiusKm,
    bool notifyHeat = true,
    bool notifyRisk = true,
  }) =>
      _withDevice((auth) async {
        final r = await _dio.post('/places', options: auth, data: {
          'name': name,
          'latitude': latitude,
          'longitude': longitude,
          'radius_km': radiusKm,
          'notify_heat': notifyHeat,
          'notify_risk': notifyRisk,
        });
        return TrackedPlace.fromJson(r.data['data'] as Map<String, dynamic>);
      });

  /// Changes only the fields given. A place's position cannot change.
  Future<TrackedPlace> update(
    String id, {
    String? name,
    int? radiusKm,
    bool? notifyHeat,
    bool? notifyRisk,
  }) =>
      _withDevice((auth) async {
        final r = await _dio.patch('/places/$id', options: auth, data: {
          'name': ?name,
          'radius_km': ?radiusKm,
          'notify_heat': ?notifyHeat,
          'notify_risk': ?notifyRisk,
        });
        return TrackedPlace.fromJson(r.data['data'] as Map<String, dynamic>);
      });

  /// Neighbourhood or address search. The text goes in the body, never the
  /// URL. Needs no device identity: searching stores nothing about the user.
  Future<List<PlaceSearchResult>> search(String query) async {
    try {
      final r = await _dio.post('/places/search', data: {'q': query});
      return (r.data['data'] as List).cast<Map<String, dynamic>>().map(PlaceSearchResult.fromJson).toList();
    } on DioException catch (e) {
      throw _map(e);
    } on Object catch (e) {
      if (kDebugMode) debugPrint('places: unexpected search response: $e');
      throw const TrackedPlacesException(TrackedPlacesError.unknown);
    }
  }

  Future<void> remove(String id) => _withDevice((auth) async {
        await _dio.delete('/places/$id', options: auth);
      });

  /// FCM token refresh or language change. A no-op before registration —
  /// registering sends both anyway.
  ///
  /// Also what keeps the install "seen": the server deletes installs it
  /// hasn't heard from for 90 days, so the app calls this on every start.
  /// Never throws — it runs on app start and on language change.
  Future<void> updateDevice({String? fcmToken, String? locale}) async {
    try {
      if (!await PlaceIdentity.isRegistered()) return;
      await _dio.patch('/places/devices/me', options: await _auth(), data: {
        'fcm_token': ?fcmToken,
        'locale': ?locale,
      });
    } catch (e) {
      if (kDebugMode) debugPrint('places device update failed: $e');
    }
  }

  /// Deletes this install and every place on the server, then forgets the
  /// identity. True when nothing is left on the server.
  Future<bool> deleteAll() async {
    final id = await PlaceIdentity.read();
    if (id == null || !await PlaceIdentity.isRegistered()) {
      await PlaceIdentity.clear();
      return true;
    }
    try {
      await _dio.delete('/places/devices/me', options: await _auth());
      await PlaceIdentity.clear();
      return true;
    } on DioException catch (e) {
      // 401: the server has nothing for this identity any more.
      if (e.response?.statusCode == 401) {
        await PlaceIdentity.clear();
        return true;
      }
      // 503: the feature isn't live on the server, so nothing was stored.
      if (e.response?.statusCode == 503) return true;
      if (kDebugMode) debugPrint('places deleteAll failed: $e');
      return false;
    }
  }

  static TrackedPlacesException _map(DioException e) {
    final status = e.response?.statusCode;
    final body = e.response?.data;
    final code = body is Map ? body['code'] : null;
    if (status == 503 || code == 'places_unavailable') {
      return const TrackedPlacesException(TrackedPlacesError.unavailable);
    }
    if (code == 'place_limit') return const TrackedPlacesException(TrackedPlacesError.placeLimit);
    if (code == 'outside_turkey') return const TrackedPlacesException(TrackedPlacesError.outsideTurkey);
    if (status == 400) return const TrackedPlacesException(TrackedPlacesError.invalid);
    if (status == null) return const TrackedPlacesException(TrackedPlacesError.network);
    return const TrackedPlacesException(TrackedPlacesError.unknown);
  }
}
