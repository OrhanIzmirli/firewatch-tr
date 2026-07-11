import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import 'core/theme/app_theme.dart';
import 'core/config/api_config.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'router/app_router.dart';
import 'services/background_task_service.dart';
import 'services/fire_monitoring_service.dart';
import 'services/locale_provider.dart';
import 'services/notification_service.dart';
import 'services/risk_data_cache.dart';
import 'services/settings_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kReleaseMode && !ApiConfig.backendBaseUrl.startsWith('https://')) {
    throw StateError('Release builds require an HTTPS backend URL.');
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, st) {
    if (kDebugMode) debugPrint('Firebase.initializeApp failed: $e\n$st');
  }

  // Fire-and-forget: enriches fire descriptions once loaded, but must not
  // block the splash screen on a network call.
  RiskDataCache.instance.warmUp();

  if (!kIsWeb) {
    try {
      await NotificationService.instance.initialize();
    } catch (e, st) {
      if (kDebugMode) debugPrint('NotificationService.initialize failed: $e\n$st');
    }
    try {
      await FireMonitoringService.instance.initialize();
    } catch (e, st) {
      if (kDebugMode) debugPrint('FireMonitoringService.initialize failed: $e\n$st');
    }
    try {
      // Re-arm background monitoring silently on relaunch, but only if the
      // user previously opted in AND the OS permission is still granted —
      // never request it here. If the user revoked it via system settings,
      // clear the stale flag instead of leaving it dangling.
      final backgroundTask = BackgroundTaskService.instance;
      if (await backgroundTask.isEnabled()) {
        final status = await Permission.locationAlways.status;
        if (status.isGranted) {
          await backgroundTask.initialize();
        } else {
          await backgroundTask.setEnabled(false);
        }
      }
    } catch (e, st) {
      if (kDebugMode) debugPrint('BackgroundTaskService re-arm failed: $e\n$st');
    }
  }

  runApp(const ProviderScope(child: FireWatchApp()));
}

class FireWatchApp extends ConsumerWidget {
  const FireWatchApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'FireWatch TR',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.darkModeEnabled ? ThemeMode.dark : ThemeMode.light,
      routerConfig: AppRouter.router,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
