import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../services/location_disclosure.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() => _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {
  bool _isLoading = false;
  String? _message;

  Future<void> _accept() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isLoading = true;
      _message = null;
    });

    void stop(String message) {
      if (!mounted) return;
      setState(() {
        _message = message;
        _isLoading = false;
      });
    }

    try {
      await LocationDisclosure.markAccepted();

      if (!await Geolocator.isLocationServiceEnabled()) {
        stop(l10n.locPermServiceOff);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await LocationDisclosure.requestSystemPermission();
      }
      if (!mounted) return;

      if (permission == LocationPermission.denied) {
        stop(l10n.locPermDenied);
      } else if (permission == LocationPermission.deniedForever) {
        stop(l10n.locPermDeniedForever);
      } else {
        context.go('/notification-permission');
      }
    } catch (e) {
      stop(l10n.locPermError);
    }
  }

  void _decline() {
    LocationDisclosure.declineForSession();
    context.go('/notification-permission');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: PermissionDisclosureView(
        title: l10n.locDisclosureTitle,
        paragraphs: locationDisclosureParagraphs(l10n),
        message: _message,
        busy: _isLoading,
        onAccept: _accept,
        onDecline: _decline,
      ),
    );
  }
}
