import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

import '../l10n/l10n_lookup.dart';
import '../router/app_router.dart';
import 'render_api_service.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final RenderApiService _renderApi = RenderApiService();

  static const AndroidNotificationChannel _alertsChannel =
      AndroidNotificationChannel(
    'firewatch_alerts',
    'Fire Alerts',
    description: 'Yangın uyarıları ve kritik bildirimler',
    importance: Importance.max,
  );

  Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _createAndroidChannel();
    await _setupFirebaseMessaging();
  }

  Future<void> _setupFirebaseMessaging() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (kDebugMode) {
      print('FCM Permission status: ${settings.authorizationStatus}');
    }

    final token = await _fcm.getToken();
    if (token != null && token.isNotEmpty) {
      if (kDebugMode) print('FCM Token: $token');
      await _renderApi.subscribeToNotifications(token);
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (kDebugMode) {
        print('Foreground message: ${message.notification?.title}');
      }
      final notification = message.notification;
      if (notification != null) {
        final l10n = await currentAppLocalizations();
        showManualAlert(
          title: notification.title ?? l10n.appName,
          body: notification.body ?? l10n.notifNewNotificationBody,
          payload: message.data['fire_id'] != null
              ? 'fire:${message.data['fire_id']}'
              : 'alerts_tab',
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Background message opened: ${message.notification?.title}');
      }
      final fireId = message.data['fire_id'];
      final context = rootNavigatorKey.currentContext;
      if (context != null && fireId != null) {
        GoRouter.of(context).go('/fire/$fireId');
      }
    });

    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      final fireId = initialMessage.data['fire_id'];
      final context = rootNavigatorKey.currentContext;
      if (context != null && fireId != null) {
        Future.delayed(const Duration(seconds: 1), () {
          GoRouter.of(context).go('/fire/$fireId');
        });
      }
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (kDebugMode) debugPrint('Notification payload: $payload');

    final context = rootNavigatorKey.currentContext;
    if (context == null) return;

    if (payload == null || payload.isEmpty) {
      GoRouter.of(context).go('/app?tab=alerts');
      return;
    }
    if (payload.startsWith('fire:')) {
      final fireId = payload.replaceFirst('fire:', '');
      GoRouter.of(context).go('/fire/$fireId');
      return;
    }
    GoRouter.of(context).go('/app?tab=alerts');
  }

  Future<void> _createAndroidChannel() async {
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_alertsChannel);
  }

  Future<bool> requestPermission() async {
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final granted = await androidPlugin?.requestNotificationsPermission();
    return granted ?? true;
  }

  Future<void> showTestNotification() async {
    final l10n = await currentAppLocalizations();
    await _plugin.show(
      1001,
      l10n.appName,
      l10n.notifTestBody,
      _notificationDetails(),
      payload: 'alerts_tab',
    );
  }

  Future<void> showNearbyFireAlert({
    required int count,
    required String distanceLabel,
  }) async {
    final l10n = await currentAppLocalizations();
    await _plugin.show(
      2001,
      l10n.notifNearbyFireTitle,
      l10n.notifNearbyFireBody(distanceLabel, count),
      _notificationDetails(),
      payload: 'alerts_tab',
    );
  }

  Future<void> showFireEventAlert({
    required String fireId,
    required String title,
    required String body,
  }) async {
    await _plugin.show(
      3001,
      title,
      body,
      _notificationDetails(),
      payload: 'fire:$fireId',
    );
  }

  Future<void> showManualAlert({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      _notificationDetails(),
      payload: payload ?? 'alerts_tab',
    );
  }

  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'firewatch_alerts',
        'Fire Alerts',
        channelDescription: 'Yangın uyarıları ve kritik bildirimler',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'firewatch_alert',
      ),
    );
  }
}