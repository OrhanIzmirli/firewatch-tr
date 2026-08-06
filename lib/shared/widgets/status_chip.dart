import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import 'color_dot.dart';

class StatusChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final EdgeInsetsGeometry? padding;
  /// Optional explicit color, independent of the (localized, and therefore
  /// unreliable to pattern-match) [label] text. Prefer passing this for any
  /// chip that conveys severity/status, e.g. from a canonical risk tier.
  final Color? color;

  /// Shows a small colour dot before the label. Replaces the coloured emoji
  /// these chips used to be prefixed with: same signal, but it takes the
  /// chip's own colour and scales with the chip instead of being a font glyph
  /// that renders differently on every device.
  final bool showDot;

  const StatusChip({
    super.key,
    required this.label,
    this.icon,
    this.padding,
    this.color,
    this.showDot = false,
  });

  Color _colorForLabel() {
    if (color != null) return color!;
    switch (label.toLowerCase()) {
      case 'aktif':
        return AppColors.primary;
      case 'izleniyor':
        return AppColors.danger;
      case 'kontrol altında':
        return AppColors.success;
      case 'yüksek':
        return AppColors.danger;
      case 'orta':
        return AppColors.warning;
      case 'düşük':
        return AppColors.success;
      case 'breaking':
        return AppColors.primary;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final chipColor = _colorForLabel();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 7,
          ),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: isDark ? 0.14 : 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
        border: Border.all(
          color: chipColor.withValues(alpha: isDark ? 0.28 : 0.24),
        ),
        boxShadow: [
          BoxShadow(
            color: chipColor.withValues(alpha: isDark ? 0.08 : 0.05),
            blurRadius: 12,
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 15,
              color: chipColor,
            )
                .animate(onPlay: (controller) => controller.forward(from: 0))
                .fadeIn(duration: 220.ms)
                .scale(
              begin: const Offset(0.85, 0.85),
              end: const Offset(1, 1),
              curve: Curves.easeOutBack,
            ),
            const SizedBox(width: AppSpacing.sm),
          ] else if (showDot) ...[
            ColorDot(color: chipColor, size: 9),
            const SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                color: chipColor,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            )
                .animate(onPlay: (controller) => controller.forward(from: 0))
                .fadeIn(duration: 220.ms)
                .slideX(begin: 0.08, end: 0),
          ),
        ],
      ),
    );
  }
}