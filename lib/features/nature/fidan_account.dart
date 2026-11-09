import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'nature_progress.dart';

/// Where the signed-in user's progress lives.
abstract class NatureCloud {
  Future<Map<String, dynamic>?> read(String uid);
  Future<void> write(String uid, Map<String, dynamic> data);
  Future<void> delete(String uid);
}

class FirestoreNatureCloud implements NatureCloud {
  DocumentReference<Map<String, dynamic>> _doc(String uid) => FirebaseFirestore.instance.collection('users').doc(uid);
  @override
  Future<Map<String, dynamic>?> read(String uid) async => (await _doc(uid).get()).data();
  @override
  Future<void> write(String uid, Map<String, dynamic> data) => _doc(uid).set({...data, 'updatedAt': FieldValue.serverTimestamp()});
  @override
  Future<void> delete(String uid) => _doc(uid).delete();
}

/// Brings this phone and the cloud to the same progress.
Future<void> syncNatureProgress(NatureStore store, NatureCloud cloud, String uid) async {
  final remote = await cloud.read(uid);
  if (remote != null) await store.replace(mergeProgress(store.progress, remote));
  await cloud.write(uid, cloudJson(store.progress));
}

enum FidanAuthResult { ok, cancelled, unavailable }

/// The optional Google account. Without it the app works the same and
/// progress stays on the phone.
class FidanAccount extends ChangeNotifier {
  FidanAccount._();
  static final FidanAccount instance = FidanAccount._();

  final NatureCloud _cloud = FirestoreNatureCloud();
  Timer? _debounce;
  bool _started = false;
  bool _googleReady = false;

  bool get _firebaseReady {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  User? get user => _firebaseReady ? FirebaseAuth.instance.currentUser : null;

  Future<void> start() async {
    if (_started) return;
    _started = true;
    NatureStore.instance.onSaved = _queueWrite;
    final u = user;
    if (u == null) return;
    try {
      await syncNatureProgress(NatureStore.instance, _cloud, u.uid);
    } catch (e) {
      if (kDebugMode) debugPrint('Fidan sync: $e');
    }
  }

  void _queueWrite(NatureProgress p) {
    final u = user;
    if (u == null) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 2), () async {
      try {
        await _cloud.write(u.uid, cloudJson(NatureStore.instance.progress));
      } catch (e) {
        if (kDebugMode) debugPrint('Fidan sync: $e');
      }
    });
  }

  Future<OAuthCredential?> _googleCredential() async {
    if (!_googleReady) {
      await GoogleSignIn.instance.initialize();
      _googleReady = true;
    }
    final account = await GoogleSignIn.instance.authenticate();
    final token = account.authentication.idToken;
    return token == null ? null : GoogleAuthProvider.credential(idToken: token);
  }

  Future<FidanAuthResult> signIn() async {
    if (!_firebaseReady) return FidanAuthResult.unavailable;
    try {
      final credential = await _googleCredential();
      if (credential == null) return FidanAuthResult.unavailable;
      final result = await FirebaseAuth.instance.signInWithCredential(credential);
      await syncNatureProgress(NatureStore.instance, _cloud, result.user!.uid);
      notifyListeners();
      return FidanAuthResult.ok;
    } on GoogleSignInException catch (e) {
      return e.code == GoogleSignInExceptionCode.canceled ? FidanAuthResult.cancelled : FidanAuthResult.unavailable;
    } catch (e) {
      if (kDebugMode) debugPrint('Fidan sign-in: $e');
      return FidanAuthResult.unavailable;
    }
  }

  Future<void> signOut() async {
    _debounce?.cancel();
    await FirebaseAuth.instance.signOut();
    if (_googleReady) await GoogleSignIn.instance.signOut();
    notifyListeners();
  }

  /// Deletes the cloud document and the account, then this phone's progress.
  /// Google asks the person to confirm who they are first.
  Future<FidanAuthResult> deleteAccount() async {
    final u = user;
    if (u == null) return FidanAuthResult.unavailable;
    try {
      _debounce?.cancel();
      final credential = await _googleCredential();
      if (credential == null) return FidanAuthResult.unavailable;
      await u.reauthenticateWithCredential(credential);
      await _cloud.delete(u.uid);
      await u.delete();
      await GoogleSignIn.instance.signOut();
      await NatureStore.instance.deleteAll();
      notifyListeners();
      return FidanAuthResult.ok;
    } on GoogleSignInException catch (e) {
      return e.code == GoogleSignInExceptionCode.canceled ? FidanAuthResult.cancelled : FidanAuthResult.unavailable;
    } catch (e) {
      if (kDebugMode) debugPrint('Fidan delete: $e');
      return FidanAuthResult.unavailable;
    }
  }
}
