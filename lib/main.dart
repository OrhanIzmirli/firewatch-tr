import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/theme/app_theme.dart';
import 'core/config/api_config.dart';
import 'core/utils/map_tiles.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'router/app_router.dart';
import 'services/app_update_gate.dart';
import 'services/background_task_service.dart';
import 'services/foreground_location_sync.dart';
import 'services/fire_monitoring_service.dart';
import 'services/locale_provider.dart';
import 'services/notification_service.dart';
import 'services/review_prompt.dart';
import 'services/risk_data_cache.dart';
import 'services/settings_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // IBM Plex is bundled (assets/fonts); never fetch fonts at runtime — it
  // failed offline and leaked a request to Google on first launch.
  GoogleFonts.config.allowRuntimeFetching = false;
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

  // Resolves the tile-cache directory (local disk, no network) so the first
  // map already serves cached OSM tiles.
  await MapTiles.init();

  runApp(const ProviderScope(child: FireWatchApp()));

  // Deliberately started after runApp() rather than awaited before it —
  // these are all either network-dependent (notification permission
  // request + FCM token registration) or otherwise non-critical for the
  // first frame, so there's no reason to make the splash screen wait on
  // them. Firebase itself is already initialized by this point (awaited
  // above), which is all these services need to be safe to construct.
  if (!kIsWeb) {
    unawaited(_initializeBackgroundServices());
    _foregroundListener = AppLifecycleListener(onResume: () => unawaited(ForegroundLocationSync.instance.sync()));
    unawaited(ReviewPrompt.noteAppOpen());
    if (defaultTargetPlatform == TargetPlatform.android) unawaited(AppUpdateGate.instance.check());
  }
}

// Held so the listener stays registered for the life of the app.
// ignore: unused_element
AppLifecycleListener? _foregroundListener;

Future<void> _initializeBackgroundServices() async {
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
    await cancelRetiredBackgroundTask();
  } catch (e, st) {
    if (kDebugMode) debugPrint('Retired task cleanup failed: $e\n$st');
  }
  await ForegroundLocationSync.instance.sync();
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
      scaffoldMessengerKey: AppUpdateGate.messengerKey,
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
