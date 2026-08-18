import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../l10n/app_localizations.dart';

/// Small collapsible transparency note — tap to expand/collapse. Used on
/// every main screen to briefly explain where its data comes from.
class TrustInfoCard extends StatefulWidget {
  final String text;
  final String? title;
  final IconData icon;

  const TrustInfoCard({super.key, required this.text, this.title, this.icon = Icons.verified_outlined});

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
                Icon(widget.icon, size: 15, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.title ?? l10n.trustCardLabel,
                    style: GoogleFonts.ibmPlexSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
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
                  style: GoogleFonts.ibmPlexSans(fontSize: 12, height: 1.4, color: textColor),
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

/// Stack of four collapsible [TrustInfoCard]s covering what the screen's
/// data means, where it comes from, how to interpret it, and what action
/// to take — the four dimensions every main screen must explain.
class TrustInfoCardGroup extends StatelessWidget {
  final String meaning;
  final String source;
  final String interpret;
  final String action;

  const TrustInfoCardGroup({
    super.key,
    required this.meaning,
    required this.source,
    required this.interpret,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TrustInfoCard(title: l10n.trustAspectMeaningTitle, icon: Icons.info_outline_rounded, text: meaning),
        const SizedBox(height: AppSpacing.sm),
        TrustInfoCard(title: l10n.trustAspectSourceTitle, icon: Icons.satellite_alt_rounded, text: source),
        const SizedBox(height: AppSpacing.sm),
        TrustInfoCard(title: l10n.trustAspectInterpretTitle, icon: Icons.insights_rounded, text: interpret),
        const SizedBox(height: AppSpacing.sm),
        TrustInfoCard(title: l10n.trustAspectActionTitle, icon: Icons.touch_app_rounded, text: action),
      ],
    );
  }
}
