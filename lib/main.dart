import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'router/app_router.dart';
import 'services/fire_monitoring_service.dart';
import 'services/notification_service.dart';
import 'services/settings_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase Initialize
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await NotificationService.instance.initialize();
  await FireMonitoringService.instance.initialize();

  runApp(const ProviderScope(child: FireWatchApp()));
}

class FireWatchApp extends ConsumerWidget {
  const FireWatchApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'FireWatch TR',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.darkModeEnabled ? ThemeMode.dark : ThemeMode.light,
      routerConfig: AppRouter.router,
    );
  }
}