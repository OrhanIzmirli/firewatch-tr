import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

class FilterChipRow extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  const FilterChipRow({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((option) {
        final isSelected = option == selected;

        return GestureDetector(
          onTap: () => onSelected(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.16)
                  : (isDark
                  ? AppColors.white.withValues(alpha: 0.03)
                  : Colors.black.withValues(alpha: 0.03)),
              borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.4)
                    : (isDark
                    ? AppColors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.12)),
              ),
            ),
            child: Text(
              option,
              style: GoogleFonts.ibmPlexSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? AppColors.primary
                    : (isDark
                    ? AppColors.white.withValues(alpha: 0.78)
                    : Colors.black.withValues(alpha: 0.72)),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}