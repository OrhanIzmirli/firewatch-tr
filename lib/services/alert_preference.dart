import 'package:shared_preferences/shared_preferences.dart';

/// The user's latest on/off choice for server alerts, on either screen.
const String kAlertsWantedKey = 'server_alerts_wanted';

/// Set once this install has told the server its local choice.
const String kAlertsSyncedKey = 'server_alerts_synced_v1';

/// Before [kAlertsWantedKey] existed the choice lived in these two.
bool alertsWanted(SharedPreferences prefs) =>
    prefs.getBool(kAlertsWantedKey) ??
    ((prefs.getBool('settings_push_notifications') ?? true) && (prefs.getBool('notifications_enabled') ?? true));

/// What the start-up registration says about is_active. Null leaves the
/// server's value alone, which is the normal case: opening the app is not a
/// request to turn alerts on. "Off" is always repeated, and the first start
/// on this version tells the server what older versions overwrote.
bool? startupActiveFlag({required bool wanted, required bool synced}) => !wanted || !synced ? wanted : null;
