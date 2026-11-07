import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/l10n_lookup.dart';
import '../models/alert_scope.dart';
import '../router/app_router.dart';
import 'render_api_service.dart';
import 'tracked_places_api.dart';
import 'tracked_places_provider.dart';
import 'alert_inbox.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final RenderApiService _renderApi = RenderApiService();

  /// Tracked-place heat alerts (backend placeAlertJob). Its own channel so
  /// users can silence them in system settings without losing fire alerts.
  static const placesChannelId = 'firewatch_places';

  static const AndroidNotificationChannel _alertsChannel =
      AndroidNotificationChannel(
    'firewatch_alerts',
    'Fire Alerts',
    description: 'Wildfire warnings and critical alerts',
    importance: Importance.max,
  );

  Future<void> initialize() async {
    await AlertInbox.instance.initialize();
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

    // Tracked places: the server deletes an install it hasn't seen for 90
    // days (privacy policy: "if you don't open the app for 90 days"), so
    // every start counts as "seen" — and keeps the token and language
    // current. A no-op for installs that never added a place.
    final localeName = (await currentAppLocalizations()).localeName;
    await TrackedPlacesApi().updateDevice(
      fcmToken: token != null && token.isNotEmpty ? token : null,
      locale: localeName,
    );

    // A rotated token must reach both device tables, or alerts silently
    // stop: fcm_tokens (region alerts) and place_devices (tracked places).
    _fcm.onTokenRefresh.listen((newToken) async {
      if (newToken.isEmpty) return;
      await _renderApi.subscribeToNotifications(newToken);
      await TrackedPlacesApi().updateDevice(fcmToken: newToken);
    });

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
          payload: payloadForData(message.data),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Background message opened: ${message.notification?.title}');
      }
      final payload = payloadForData(message.data);
      AlertInbox.instance.add(message.notification?.title ?? 'FireWatch TR', message.notification?.body ?? '', payload: payload == 'alerts_tab' ? null : payload, id: message.messageId);
      // Fetched fresh and used synchronously within this callback (no
      // await in between) — the analyzer flags it only because the
      // enclosing _setupFirebaseMessaging is itself async, not because
      // this context is actually stale.
      final context = rootNavigatorKey.currentContext;
      if (context != null) {
        // ignore: use_build_context_synchronously
        openPayload(GoRouter.of(context), payload);
      }
    });

    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      final payload = payloadForData(initialMessage.data);
      await AlertInbox.instance.add(initialMessage.notification?.title ?? 'FireWatch TR', initialMessage.notification?.body ?? '', payload: payload == 'alerts_tab' ? null : payload, id: initialMessage.messageId);
      {
        Future.delayed(const Duration(seconds: 1), () {
          // Fetched fresh here (not captured before the delay) since the
          // root navigator's context can only be resolved at the moment
          // it's actually used.
          final context = rootNavigatorKey.currentContext;
          if (context != null) {
            // ignore: use_build_context_synchronously
            openPayload(GoRouter.of(context), payload);
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

    openPayload(GoRouter.of(context), payload);
  }

  /// Local-notification payload for an FCM data map:
  /// `place:<lat>,<lng>` for a tracked-place heat alert (opens the map
  /// there), `places` for the "N new detections" summary (opens the
  /// tracked-places list), `fire:<id>` for a fire, otherwise the alerts tab.
  static String payloadForData(Map<String, dynamic> data) {
    if (data['type'] == 'place_heat_summary') return 'places';
    if (data['type'] == 'place_heat') {
      final lat = double.tryParse('${data['lat']}');
      final lng = double.tryParse('${data['lng']}');
      if (lat != null && lng != null) return 'place:$lat,$lng';
      return 'alerts_tab';
    }
    if (data['fire_id'] != null) return 'fire:${data['fire_id']}';
    return 'alerts_tab';
  }

  static void openPayload(GoRouter router, String? payload) {
    if (payload == null || payload.isEmpty || payload == 'alerts_tab') {
      router.go('/app?section=alerts');
      return;
    }
    if (payload.startsWith('fire:')) {
      router.go('/fire/${payload.substring(5)}');
      return;
    }
    if (payload == 'places') {
      router.go('/tracked-places');
      return;
    }
    if (payload.startsWith('place:')) {
      final parts = payload.substring(6).split(',');
      final lat = parts.length == 2 ? double.tryParse(parts[0]) : null;
      final lng = parts.length == 2 ? double.tryParse(parts[1]) : null;
      if (lat != null && lng != null) {
        router.go('/map', extra: {'lat': lat, 'lng': lng});
        return;
      }
    }
    router.go('/app?section=alerts');
  }

  Future<void> _createAndroidChannel() async {
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_alertsChannel);
    final l10n = await currentAppLocalizations();
    await androidPlugin?.createNotificationChannel(AndroidNotificationChannel(
      placesChannelId,
      l10n.notifPlacesChannelName,
      description: l10n.notifPlacesChannelDescription,
      importance: Importance.high,
    ));
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

  /// Settings → "Delete my location data": erases the approximate location
  /// the backend keeps for this device (notifications stay on) and every
  /// tracked place with its anonymous identity. Without an FCM token the
  /// device was never registered for alerts, so there is no location to
  /// erase there.
  Future<bool> deleteServerLocation({TrackedPlacesNotifier? trackedPlaces}) async {
    String? token;
    try {
      token = await _fcm.getToken();
    } catch (_) {
      token = null;
    }
    final locationOk = token == null || token.isEmpty ? true : await _renderApi.deleteStoredLocation(token);
    final placesOk = trackedPlaces != null ? await trackedPlaces.deleteAll() : await TrackedPlacesApi().deleteAll();
    return locationOk && placesOk;
  }

  /// The scope the backend holds for this device, read without changing it
  /// (see RenderApiService.readServerScope). Null when unknown.
  Future<ServerScope?> readServerScope() async {
    final token = await _fcm.getToken();
    if (token == null || token.isEmpty) return null;
    final prefs = await SharedPreferences.getInstance();
    final pushEnabled = prefs.getBool('settings_push_notifications') ?? true;
    return _renderApi.readServerScope(token, isActive: pushEnabled);
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
    await AlertInbox.instance.add(l10n.notifNearbyFireTitle, l10n.notifNearbyFireBody(distanceLabel, count));
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
    await AlertInbox.instance.add(title, body, payload: 'fire:$fireId');
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
    await AlertInbox.instance.add(title, body, payload: payload);
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
