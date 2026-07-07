import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../l10n/app_localizations.dart';

/// Small ℹ️ icon that shows a short explanatory dialog on tap. Used next to
/// technical readings (Kelvin temperature, confidence, satellite) that
/// aren't self-explanatory to a general audience.
class InfoIconButton extends StatelessWidget {
  final String title;
  final List<String> bodyLines;
  final double size;

  const InfoIconButton({
    super.key,
    required this.title,
    required this.bodyLines,
    this.size = 15,
  });

  void _show(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
        final titleColor = isDark ? AppColors.white : const Color(0xFF0F172A);
        final bodyColor = isDark ? AppColors.white.withValues(alpha: 0.78) : Colors.black.withValues(alpha: 0.68);

        return AlertDialog(
          title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: titleColor)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final line in bodyLines)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Text(line, style: GoogleFonts.inter(fontSize: 13, height: 1.45, color: bodyColor)),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.reportPanelOk),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _show(context),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(Icons.info_outline_rounded, size: size, color: AppColors.primary.withValues(alpha: 0.75)),
      ),
    );
  }
}
