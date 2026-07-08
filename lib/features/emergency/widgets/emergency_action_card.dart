import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/widgets/glass_panel.dart';

class EmergencyActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback? onTap;
  final Duration delay;

  const EmergencyActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    this.onTap,
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius),
          ),
          child: GlassPanel(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: accent,
                    size: 22,
                  ),
                ),
                const Spacer(),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    height: 1.4,
                    color: AppColors.white.withValues(alpha: 0.64),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: delay)
        .fadeIn(duration: 280.ms)
        .slideY(begin: 0.12, end: 0)
        .scale(
      begin: const Offset(0.97, 0.97),
      end: const Offset(1, 1),
    );
  }
}