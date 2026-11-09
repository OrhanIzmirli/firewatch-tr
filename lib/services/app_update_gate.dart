import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../core/config/api_config.dart';
import '../l10n/app_localizations.dart';

const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.oguzh.firewatch.firewatch_tr';

List<int>? _parts(String? version) {
  final core = version?.trim().split('+').first;
  if (core == null || !RegExp(r'^\d+(\.\d+){0,2}$').hasMatch(core)) return null;
  final p = core.split('.').map(int.parse).toList();
  while (p.length < 3) {
    p.add(0);
  }
  return p;
}

/// True only for two readable versions with [installed] below [minimum].
/// Anything unreadable never locks anyone out.
bool isUpdateRequired(String? installed, String? minimum) {
  final a = _parts(installed);
  final b = _parts(minimum);
  if (a == null || b == null) return false;
  for (var i = 0; i < 3; i++) {
    if (a[i] != b[i]) return a[i] < b[i];
  }
  return false;
}

/// Null on any failure. Short timeouts: this must not delay anything.
Future<String?> fetchMinSupportedVersion({Dio? dio}) async {
  try {
    final client = dio ??
        Dio(BaseOptions(
          baseUrl: ApiConfig.apiBaseUrl,
          connectTimeout: const Duration(seconds: 6),
          receiveTimeout: const Duration(seconds: 6),
        ));
    final response = await client.get('/app-config');
    final value = (response.data as Map)['data']?['min_supported_version'];
    return value is String ? value : null;
  } catch (e) {
    if (kDebugMode) debugPrint('App config: $e');
    return null;
  }
}

/// Decides at start-up whether this build may keep running. The router sends
/// everyone to the update screen only after the server clearly said so.
class AppUpdateGate extends ChangeNotifier {
  AppUpdateGate({
    Future<String?> Function()? minimumVersion,
    Future<String> Function()? installedVersion,
    Future<void> Function()? offerFlexible,
  })  : _minimumVersion = minimumVersion ?? fetchMinSupportedVersion,
        _installedVersion = installedVersion ?? (() async => (await PackageInfo.fromPlatform()).version),
        _offerFlexible = offerFlexible ?? _flexibleUpdate;

  static final AppUpdateGate instance = AppUpdateGate();
  static final GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey<ScaffoldMessengerState>();

  final Future<String?> Function() _minimumVersion;
  final Future<String> Function() _installedVersion;
  final Future<void> Function() _offerFlexible;

  bool _required = false;
  bool get updateRequired => _required;

  Future<void> check() async {
    try {
      if (isUpdateRequired(await _installedVersion(), await _minimumVersion())) {
        _required = true;
        notifyListeners();
        return;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Update gate: $e');
    }
    try {
      await _offerFlexible();
    } catch (e) {
      if (kDebugMode) debugPrint('Flexible update: $e');
    }
  }

  static Future<void> _flexibleUpdate() async {
    final info = await InAppUpdate.checkForUpdate();
    if (info.installStatus == InstallStatus.downloaded) {
      _showReady();
      return;
    }
    if (info.updateAvailability != UpdateAvailability.updateAvailable || !info.flexibleUpdateAllowed) return;
    if (await InAppUpdate.startFlexibleUpdate() == AppUpdateResult.success) _showReady();
  }

  static void _showReady() {
    final messenger = messengerKey.currentState;
    final context = messengerKey.currentContext;
    if (messenger == null || context == null) return;
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;
    messenger.showSnackBar(SnackBar(
      key: const Key('flexibleUpdateReady'),
      duration: const Duration(days: 1),
      showCloseIcon: true,
      content: Text(l10n.updateReady),
      action: SnackBarAction(label: l10n.updateRestart, onPressed: InAppUpdate.completeFlexibleUpdate),
    ));
  }
}
