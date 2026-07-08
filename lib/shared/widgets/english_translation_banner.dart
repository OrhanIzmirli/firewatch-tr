import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../l10n/app_localizations.dart';

/// Dismissible hint shown once per app session, in English mode only, at
/// the top of the news list — points the user at the per-article
/// translate affordance.
class EnglishTranslationBanner extends StatelessWidget {
  final VoidCallback onDismiss;

  const EnglishTranslationBanner({super.key, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.24)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.newsEnglishBannerText,
              style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.info),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 32,
            height: 32,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: onDismiss,
              icon: Icon(Icons.close_rounded, size: 16, color: AppColors.info.withValues(alpha: 0.8)),
            ),
          ),
        ],
      ),
    );
  }
}
