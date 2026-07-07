import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
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

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, st) {
    debugPrint('Firebase.initializeApp failed: $e\n$st');
  }

  // Fire-and-forget: enriches fire descriptions once loaded, but must not
  // block the splash screen on a network call.
  RiskDataCache.instance.warmUp();

  if (!kIsWeb) {
    try {
      await NotificationService.instance.initialize();
    } catch (e, st) {
      debugPrint('NotificationService.initialize failed: $e\n$st');
    }
    try {
      await FireMonitoringService.instance.initialize();
    } catch (e, st) {
      debugPrint('FireMonitoringService.initialize failed: $e\n$st');
    }
    if (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS) {
      try {
        await BackgroundTaskService.instance.initialize();
      } catch (e, st) {
        debugPrint('BackgroundTaskService.initialize failed: $e\n$st');
      }
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