import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/config/api_config.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../l10n/app_localizations.dart';

/// The explanation shown before the app first asks for location: what the
/// location is used for, that an approximate (~1 km) copy is kept on the
/// server when notifications are on, and how to delete it.
///
/// Every call site that would trigger the system location prompt goes
/// through [LocationDisclosure.requestPermission], so the explanation always
/// comes first. "Start automatic monitoring" also calls [ensureAccepted]
/// directly, because that flow stores the location on the server even when
/// the permission was granted long ago.
///
/// The text must match the hosted privacy policy (backend routes/legal.ts)
/// and the rules the backend enforces (utils/locationPrivacy.ts).
class LocationDisclosure {
  LocationDisclosure._();

  /// Bump the suffix when the disclosed practice changes, so everyone sees
  /// the new text once. v2 (1.2.0) adds tracked places.
  static const prefsKey = 'location_disclosure_v2_accepted';

  /// "Not now" holds for the rest of this app session, so screens that look
  /// up the location on their own (home, news) don't ask again and again.
  static bool _declinedThisSession = false;
  static Future<bool>? _inFlight;

  @visibleForTesting
  static void resetForTest() {
    _declinedThisSession = false;
    _inFlight = null;
  }

  static Future<bool> isAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(prefsKey) ?? false;
  }

  /// Records acceptance without showing the sheet — for the onboarding
  /// location screen, which shows the same explanation full-screen.
  static Future<void> markAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefsKey, true);
  }

  /// Shows the explanation once. Returns true when the user has accepted it
  /// (now or before), false when they chose "Not now".
  static Future<bool> ensureAccepted(BuildContext context, {bool force = false}) async {
    if (await isAccepted()) return true;
    if (_declinedThisSession && !force) return false;
    if (!context.mounted) return false;

    // Two screens may ask at the same moment (home and news both load the
    // position on start); they share one sheet.
    final pending = _inFlight;
    if (pending != null) return pending;

    final completer = Completer<bool>();
    _inFlight = completer.future;
    try {
      final accepted = await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            isDismissible: true,
            builder: (_) => const LocationDisclosureSheet(),
          ) ??
          false;
      if (accepted) {
        await markAccepted();
      } else {
        _declinedThisSession = true;
      }
      completer.complete(accepted);
      return accepted;
    } catch (_) {
      completer.complete(false);
      return false;
    } finally {
      _inFlight = null;
    }
  }

  /// Drop-in replacement for `Geolocator.requestPermission()`: shows the
  /// explanation first, and only then the system prompt. When the user
  /// chooses "Not now", the system prompt is not shown and the current
  /// (denied) permission is returned.
  static Future<LocationPermission> requestPermission(BuildContext context) async {
    final current = await Geolocator.checkPermission();
    if (current != LocationPermission.denied) return current;
    if (!context.mounted) return current;
    final accepted = await ensureAccepted(context);
    if (!accepted) return current;
    return Geolocator.requestPermission();
  }
}

class LocationDisclosureSheet extends StatelessWidget {
  const LocationDisclosureSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final bodyColor = theme.textTheme.bodyMedium?.color;
    final points = <(IconData, String)>[
      (Icons.phone_android_rounded, l10n.locDisclosureOnDevice),
      (Icons.location_city_rounded, l10n.locDisclosureNearestCity),
      (Icons.notifications_active_outlined, l10n.locDisclosureStored),
      (Icons.place_outlined, l10n.locDisclosureTracked),
      (Icons.delete_outline_rounded, l10n.locDisclosureDelete),
      (Icons.toggle_off_outlined, l10n.locDisclosureOptional),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_rounded, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  l10n.locDisclosureTitle,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          for (final (icon, text) in points)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 20, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      text,
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 14,
                        height: 1.45,
                        color: bodyColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => launchUrl(
                Uri.parse('${ApiConfig.backendBaseUrl}/privacy'),
                mode: LaunchMode.externalApplication,
              ),
              icon: const Icon(Icons.privacy_tip_outlined, size: 18),
              label: Text(l10n.settingsPrivacyPolicy),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          FilledButton(
            key: const Key('locDisclosureContinue'),
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(l10n.locDisclosureContinue),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            key: const Key('locDisclosureNotNow'),
            onPressed: () => Navigator.of(context).pop(false),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(l10n.locDisclosureNotNow),
          ),
        ],
      ),
    );
  }
}
