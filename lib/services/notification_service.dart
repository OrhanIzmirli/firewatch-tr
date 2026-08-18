import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

import '../l10n/l10n_lookup.dart';
import '../models/alert_scope.dart';
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
    description: 'Wildfire warnings and critical alerts',
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
      // Fetched fresh and used synchronously within this callback (no
      // await in between) — the analyzer flags it only because the
      // enclosing _setupFirebaseMessaging is itself async, not because
      // this context is actually stale.
      final context = rootNavigatorKey.currentContext;
      if (context != null && fireId != null) {
        // ignore: use_build_context_synchronously
        GoRouter.of(context).go('/fire/$fireId');
      }
    });

    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      final fireId = initialMessage.data['fire_id'];
      if (fireId != null) {
        Future.delayed(const Duration(seconds: 1), () {
          // Fetched fresh here (not captured before the delay) since the
          // root navigator's context can only be resolved at the moment
          // it's actually used.
          final context = rootNavigatorKey.currentContext;
          if (context != null) {
            // ignore: use_build_context_synchronously
            GoRouter.of(context).go('/fire/$fireId');
          }
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

  /// Keeps the backend's fcm_tokens.is_active in sync with the user's Push
  /// Notifications setting — so automatic risk/critical alerts only ever
  /// reach devices that currently want them, not just ones that once did.
  /// Used by the plain Settings toggle, which has no location on hand —
  /// see [updateSubscription] for the full-registration path used when
  /// starting monitoring (which does have a fresh position).
  Future<void> setPushEnabled(bool enabled) async {
    await updateSubscription(active: enabled);
  }

  /// Full subscription update: when enabling, re-registers the token with
  /// the given location (so backend region-targeted alerts have somewhere
  /// to match against); when disabling, just flips is_active off without
  /// touching location.
  Future<void> updateSubscription({
    required bool active,
    double? latitude,
    double? longitude,
  }) async {
    final token = await _fcm.getToken();
    if (token == null || token.isEmpty) return;
    if (active) {
      await _renderApi.subscribeToNotifications(
        token,
        latitude: latitude,
        longitude: longitude,
      );
    } else {
      await _renderApi.setNotificationActive(token, false);
    }
  }

  /// Pushes the user's alert-scope choice to the backend so targeted fire
  /// alerts respect it. Uses PATCH (which only updates an existing row) and
  /// falls back to a full subscribe when the token isn't registered yet —
  /// e.g. the user picked a scope before ever enabling notifications.
  Future<bool> updateAlertScope({
    required AlertScope scope,
    String? regionKey,
    int? cityId,
  }) async {
    final token = await _fcm.getToken();
    if (token == null || token.isEmpty) return false;

    final patched = await _renderApi.setNotificationActive(
      token,
      true,
      alertScope: scope,
      regionKey: regionKey,
      cityId: cityId,
    );
    if (patched) return true;

    return _renderApi.subscribeToNotifications(
      token,
      alertScope: scope,
      regionKey: regionKey,
      cityId: cityId,
    );
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

  /// Local alert for detections inside the user's saved places — the
  /// device-side arm of AlertScope.places.
  Future<void> showSavedPlacesFireAlert({required int count}) async {
    final l10n = await currentAppLocalizations();
    await _plugin.show(
      2002,
      l10n.notifPlacesFireTitle,
      l10n.notifPlacesFireBody(count),
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
        channelDescription: 'Wildfire warnings and critical alerts',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'firewatch_alert',
      ),
    );
  }
}
