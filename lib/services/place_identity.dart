import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The anonymous identity tracked places are stored under: a random UUID and
/// a 32-byte random secret, generated on first use and kept in secure
/// storage. The server only ever stores a hash of the secret. There is no
/// account; losing these (uninstall, clearing data) just means a fresh
/// identity, and the old one is deleted by the server after 90 days.
class PlaceIdentity {
  final String installId;
  final String secret;

  const PlaceIdentity(this.installId, this.secret);

  static const _idKey = 'places_install_id';
  static const _secretKey = 'places_install_secret';
  static const _registeredKey = 'places_registered';

  static FlutterSecureStorage storage = const FlutterSecureStorage();

  /// Existing identity, or null when none has been created yet.
  static Future<PlaceIdentity?> read() async {
    final id = await storage.read(key: _idKey);
    final secret = await storage.read(key: _secretKey);
    if (id == null || secret == null) return null;
    return PlaceIdentity(id, secret);
  }

  static Future<PlaceIdentity> readOrCreate() async {
    final existing = await read();
    if (existing != null) return existing;
    final created = PlaceIdentity(newUuidV4(), newSecret());
    await storage.write(key: _idKey, value: created.installId);
    await storage.write(key: _secretKey, value: created.secret);
    await storage.delete(key: _registeredKey);
    return created;
  }

  static Future<bool> isRegistered() async =>
      (await storage.read(key: _registeredKey)) == 'true';

  static Future<void> markRegistered(bool value) async {
    if (value) {
      await storage.write(key: _registeredKey, value: 'true');
    } else {
      await storage.delete(key: _registeredKey);
    }
  }

  /// Forgets the identity entirely ("Delete my location data").
  static Future<void> clear() async {
    await storage.delete(key: _idKey);
    await storage.delete(key: _secretKey);
    await storage.delete(key: _registeredKey);
  }

  static final Random _random = Random.secure();

  static String newSecret() {
    final bytes = List<int>.generate(32, (_) => _random.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  static String newUuidV4() {
    final b = List<int>.generate(16, (_) => _random.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    String hex(int from, int to) =>
        b.sublist(from, to).map((x) => x.toRadixString(16).padLeft(2, '0')).join();
    return '${hex(0, 4)}-${hex(4, 6)}-${hex(6, 8)}-${hex(8, 10)}-${hex(10, 16)}';
  }
}
