import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

const String _retiredTask = 'backgroundFireCheckTask';
const String _retiredFlag = 'background_monitoring_enabled';

/// A task an older version scheduled may still fire once before it is
/// cancelled. It does nothing, and reads no location.
@pragma('vm:entry-point')
void retiredBackgroundDispatcher() {
  Workmanager().executeTask((task, inputData) async => true);
}

/// Background checks were removed in 1.2.0+10. Android keeps a scheduled task
/// across app updates, so the one older versions registered is cancelled here.
Future<void> cancelRetiredBackgroundTask() async {
  final prefs = await SharedPreferences.getInstance();
  if (!(prefs.getBool(_retiredFlag) ?? false)) return;
  await Workmanager().initialize(retiredBackgroundDispatcher);
  await Workmanager().cancelByUniqueName(_retiredTask);
  await prefs.remove(_retiredFlag);
}
