import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/utils/emergency_call.dart';
import '../../l10n/app_localizations.dart';
import '../../services/app_update_gate.dart';

/// Shown only after the server said this version is no longer supported.
/// 112 and the emergency information stay reachable from here.
class ForceUpdateScreen extends StatelessWidget {
  const ForceUpdateScreen({super.key});

  Future<void> _update(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final failed = AppLocalizations.of(context)!.updateStoreFailed;
    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability == UpdateAvailability.updateAvailable && info.immediateUpdateAllowed) {
        await InAppUpdate.performImmediateUpdate();
        return;
      }
    } catch (_) {
      // Falls through to the store page.
    }
    var opened = false;
    try {
      opened = await launchUrl(Uri.parse(playStoreUrl), mode: LaunchMode.externalApplication);
    } catch (_) {}
    if (!opened) messenger.showSnackBar(SnackBar(content: Text(failed)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.system_update_rounded, size: 64, color: AppColors.primary),
                  const SizedBox(height: AppSpacing.lg),
                  Text(l10n.updateRequiredTitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.ibmPlexSans(fontSize: 24, fontWeight: FontWeight.w800)),
                  const SizedBox(height: AppSpacing.sm),
                  Text(l10n.updateRequiredBody,
                      textAlign: TextAlign.center, style: GoogleFonts.ibmPlexSans(fontSize: 15, height: 1.4)),
                  const SizedBox(height: AppSpacing.xl),
                  FilledButton.icon(
                    key: const Key('forceUpdateButton'),
                    onPressed: () => _update(context),
                    icon: const Icon(Icons.download_rounded),
                    label: Text(l10n.updateNow),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(l10n.detectionCall112Line,
                      textAlign: TextAlign.center, style: GoogleFonts.ibmPlexSans(fontSize: 14, height: 1.35)),
                  const SizedBox(height: AppSpacing.sm),
                  FilledButton.icon(
                    key: const Key('forceUpdate112'),
                    style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
                    onPressed: () => openDialer(),
                    icon: const Icon(Icons.call_rounded),
                    label: Text(l10n.emergencyCall112),
                  ),
                  TextButton(
                    key: const Key('forceUpdateEmergencyInfo'),
                    onPressed: () => context.push('/emergency'),
                    child: Text(l10n.emergencyTitle),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
