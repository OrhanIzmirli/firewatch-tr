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

/// Google Play's prominent disclosure, shown right before the system location
/// prompt: what is collected, why, where it goes and how to delete it.
///
/// This class is the only place allowed to raise a location prompt, so the
/// explanation cannot be skipped (test/permission_disclosure_test.dart).
///
/// The text must match the hosted privacy policy (backend routes/legal.ts)
/// and the rules the backend enforces (utils/locationPrivacy.ts).
class LocationDisclosure {
  LocationDisclosure._();

  /// Bump the suffix when the disclosed practice changes, so everyone sees
  /// the new text once. v3 (1.2.0+10) is the rewrite Google Play asked for.
  static const prefsKey = 'location_disclosure_v3_accepted';

  /// Long enough to cover one flow, so an acceptance is not asked for twice
  /// in a row, and short enough that a later prompt gets its own explanation.
  static const _acceptanceCovers = Duration(minutes: 2);

  /// "No" holds for the rest of this app session, so screens that look up
  /// the location on their own (home, news) don't ask again and again.
  static bool _declinedThisSession = false;
  static DateTime? _acceptedAt;
  static Future<bool>? _inFlight;

  @visibleForTesting
  static void resetForTest() {
    _declinedThisSession = false;
    _acceptedAt = null;
    _inFlight = null;
  }

  static bool get _justAccepted {
    final at = _acceptedAt;
    return at != null && DateTime.now().difference(at) < _acceptanceCovers;
  }

  static Future<bool> isAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(prefsKey) ?? false;
  }

  /// Records acceptance of a disclosure the caller has just shown.
  static Future<void> markAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefsKey, true);
    _acceptedAt = DateTime.now();
  }

  /// The onboarding screen's "No, thanks".
  static void declineForSession() => _declinedThisSession = true;

  /// Shows the explanation unless it was accepted before. For flows that
  /// store the location on the server even when the permission already exists.
  static Future<bool> ensureAccepted(BuildContext context, {bool force = false}) async {
    if (await isAccepted()) return true;
    if (!context.mounted) return false;
    return _show(context, force: force);
  }

  static Future<bool> _show(BuildContext context, {required bool force}) async {
    if (_declinedThisSession && !force) return false;

    // Two screens may ask at the same moment (home and news both load the
    // position on start); they share one page.
    final pending = _inFlight;
    if (pending != null) return pending;

    final completer = Completer<bool>();
    _inFlight = completer.future;
    try {
      final accepted =
          await Navigator.of(
            context,
            rootNavigator: true,
          ).push<bool>(MaterialPageRoute(fullscreenDialog: true, builder: (_) => const LocationDisclosurePage())) ??
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

  /// Use instead of `Geolocator.requestPermission()`: the explanation comes
  /// first, every time the system prompt would appear, and the prompt only
  /// follows an acceptance. [force] is for a tap that asked for location.
  static Future<LocationPermission> requestPermission(BuildContext context, {bool force = false}) async {
    final current = await Geolocator.checkPermission();
    if (current != LocationPermission.denied) return current;
    if (!context.mounted) return current;
    if (!_justAccepted && !await _show(context, force: force)) return current;
    return requestSystemPermission();
  }

  /// The system prompt itself. Only after the user has accepted a disclosure.
  static Future<LocationPermission> requestSystemPermission() async {
    final result = await Geolocator.requestPermission();
    if (result == LocationPermission.denied) _declinedThisSession = true;
    return result;
  }

}

/// One disclosure, as plain page text: every paragraph at body size and full
/// contrast, with nothing tucked into a smaller box.
class PermissionDisclosureView extends StatelessWidget {
  const PermissionDisclosureView({
    super.key,
    required this.title,
    required this.paragraphs,
    required this.onAccept,
    required this.onDecline,
    this.message,
    this.busy = false,
  });

  static const double bodySize = 16;

  final String title;
  final List<String> paragraphs;
  final VoidCallback? onAccept;
  final VoidCallback onDecline;
  final String? message;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme.onSurface;
    final body = GoogleFonts.ibmPlexSans(fontSize: bodySize, height: 1.4, color: color);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.ibmPlexSans(fontSize: 22, fontWeight: FontWeight.w700, color: color),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      for (final text in paragraphs)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
                          child: Text(text, style: body),
                        ),
                      if (message != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Text(message!, style: body.copyWith(fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                key: const Key('disclosurePrivacyPolicy'),
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                onPressed: () =>
                    launchUrl(Uri.parse('${ApiConfig.backendBaseUrl}/privacy'), mode: LaunchMode.externalApplication),
                child: Text(
                  l10n.settingsPrivacyPolicy,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: bodySize,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            FilledButton(
              key: const Key('locDisclosureContinue'),
              onPressed: busy ? null : onAccept,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                l10n.disclosureAccept,
                style: GoogleFonts.ibmPlexSans(fontSize: bodySize, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton(
              key: const Key('locDisclosureNotNow'),
              onPressed: busy ? null : onDecline,
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              child: Text(
                l10n.disclosureDecline,
                style: GoogleFonts.ibmPlexSans(fontSize: bodySize, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<String> locationDisclosureParagraphs(AppLocalizations l10n) => [
  l10n.locDisclosureLead,
  l10n.locDisclosureForeground,
  l10n.locDisclosureServer,
  l10n.locDisclosureStored,
  l10n.locDisclosureShared,
  l10n.locDisclosureDelete,
  l10n.locDisclosureOptional,
];

class LocationDisclosurePage extends StatelessWidget {
  const LocationDisclosurePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: PermissionDisclosureView(
        title: l10n.locDisclosureTitle,
        paragraphs: locationDisclosureParagraphs(l10n),
        onAccept: () => Navigator.of(context).pop(true),
        onDecline: () => Navigator.of(context).pop(false),
      ),
    );
  }
}
