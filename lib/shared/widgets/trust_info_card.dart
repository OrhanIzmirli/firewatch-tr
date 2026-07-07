import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../l10n/app_localizations.dart';

/// Small collapsible transparency note — tap to expand/collapse. Used on
/// every main screen to briefly explain where its data comes from.
class TrustInfoCard extends StatefulWidget {
  final String text;

  const TrustInfoCard({super.key, required this.text});

  @override
  State<TrustInfoCard> createState() => _TrustInfoCardState();
}

class _TrustInfoCardState extends State<TrustInfoCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.white.withValues(alpha: 0.72) : Colors.black.withValues(alpha: 0.62);

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: isDark ? 0.08 : 0.06),
          borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.verified_outlined, size: 15, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.trustCardLabel,
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: textColor),
                ),
              ],
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              crossFadeState: _expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              firstChild: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  widget.text,
                  style: GoogleFonts.inter(fontSize: 12, height: 1.4, color: textColor),
                ),
              ),
              secondChild: const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
