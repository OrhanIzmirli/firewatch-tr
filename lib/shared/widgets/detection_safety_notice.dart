import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/utils/emergency_call.dart';
import '../../l10n/app_localizations.dart';

/// The two things every map detail card must say, whatever it describes
/// (a single detection, a merged event): this is a satellite heat
/// detection, not a confirmed fire — and if you see fire, call 112.
///
/// One widget so the wording and the button can never drift apart between
/// cards. [onCall] is injectable for tests; by default it opens the dialer.
class DetectionSafetyNotice extends StatelessWidget {
  final Future<bool> Function()? onCall;

  const DetectionSafetyNotice({super.key, this.onCall});

  static const Key callButtonKey = Key('detection-safety-call-112');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.white : AppColors.lightText;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: isDark ? 0.14 : 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded, size: 20, color: AppColors.danger),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  l10n.detectionNotConfirmedNotice,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 13.5,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: callButtonKey,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () => onCall != null ? onCall!() : openDialer(),
              icon: const Icon(Icons.call_rounded),
              label: Text(
                l10n.emergencyCall112,
                style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
