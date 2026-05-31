import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? radius;
  final Color? color;
  final Border? border;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding,
    this.radius,
    this.color,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final panelColor =
        color ??
            (isDark
                ? AppColors.surface.withValues(alpha: 0.88)
                : Colors.white.withValues(alpha: 0.92));

    final panelBorder =
        border ??
            Border.all(
              color: isDark
                  ? AppColors.white.withValues(alpha: 0.07)
                  : Colors.black.withValues(alpha: 0.06),
            );

    return Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(
          radius ?? AppSpacing.largeCardRadius,
        ),
        border: panelBorder,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.18)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.04 : 0.03),
            blurRadius: 20,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: child,
    );
  }
}