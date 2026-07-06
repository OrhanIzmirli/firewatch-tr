import 'package:flutter/material.dart';
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

class BackgroundTaskService {
  BackgroundTaskService._();
  static final BackgroundTaskService instance = BackgroundTaskService._();

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
}
