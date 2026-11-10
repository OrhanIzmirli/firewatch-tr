import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../services/location_disclosure.dart';
import '../../services/notification_service.dart';

class NotificationPermissionScreen extends StatefulWidget {
  const NotificationPermissionScreen({super.key});

  @override
  State<NotificationPermissionScreen> createState() => _NotificationPermissionScreenState();
}

class _NotificationPermissionScreenState extends State<NotificationPermissionScreen> {
  bool _isLoading = false;
  String? _message;

  Future<void> _requestNotificationPermission() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final granted = await NotificationService.instance.requestPermission();
      if (!mounted) return;
      setState(() => _message = granted ? l10n.notifPermGranted : l10n.notifPermDenied);
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      context.go('/app');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _message = l10n.notifPermDenied;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: PermissionDisclosureView(
        title: l10n.notifPermTitle,
        paragraphs: [l10n.notifPermSubtitle, l10n.notifPermData, l10n.notifPermNote],
        message: _message,
        busy: _isLoading,
        onAccept: _requestNotificationPermission,
        onDecline: () => context.go('/app'),
      ),
    );
  }
}
