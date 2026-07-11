import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'fire_monitoring_service.dart';
import 'notification_service.dart';

const String backgroundFireCheckTask = 'backgroundFireCheckTask';

/// Runs in a separate background isolate — the Flutter engine bindings and
/// the notification plugin/channel are not set up there automatically, so
/// they're (re-)initialized here before reusing FireMonitoringService.
@pragma('vm:entry-point')
void backgroundTaskCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      await NotificationService.instance.initialize();
      await FireMonitoringService.instance.initialize();
      await FireMonitoringService.instance.checkNow(triggerNotification: true);
      return Future.value(true);
    } catch (_) {
      return Future.value(false);
    }
  });
}

/// Registers/cancels the periodic background fire check. Only ever called
/// after the user has explicitly opted in and granted
/// ACCESS_BACKGROUND_LOCATION — never at app startup unconditionally.
class BackgroundTaskService {
  BackgroundTaskService._();
  static final BackgroundTaskService instance = BackgroundTaskService._();

  static const String prefsKey = 'background_monitoring_enabled';

  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(prefsKey) ?? false;
  }

  Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefsKey, value);
  }

  Future<void> initialize() async {
    await Workmanager().initialize(backgroundTaskCallbackDispatcher);
    await Workmanager().registerPeriodicTask(
      backgroundFireCheckTask,
      backgroundFireCheckTask,
      frequency: const Duration(minutes: 15),
      existingWorkPolicy: ExistingWorkPolicy.keep,
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  Future<void> stop() async {
    await Workmanager().cancelByUniqueName(backgroundFireCheckTask);
  }
}
