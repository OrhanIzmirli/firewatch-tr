import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_localizations.dart';

/// Resolves the app's current [AppLocalizations] from the persisted locale
/// setting, for code paths with no BuildContext (background services,
/// system notifications). Must stay in sync with the SharedPreferences key
/// used by LocaleNotifier.
Future<AppLocalizations> currentAppLocalizations() async {
  final prefs = await SharedPreferences.getInstance();
  final code = prefs.getString('settings_locale') ?? 'tr';
  return lookupAppLocalizations(Locale(code));
}
