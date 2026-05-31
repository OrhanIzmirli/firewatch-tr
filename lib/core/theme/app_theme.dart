import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

class AppTheme {
  static ThemeData get darkTheme {
    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primary,
        surface: AppColors.surface,
      ),
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        headlineLarge: GoogleFonts.inter(
          color: AppColors.white,
          fontWeight: FontWeight.w800,
        ),
        headlineMedium: GoogleFonts.inter(
          color: AppColors.white,
          fontWeight: FontWeight.w800,
        ),
        titleLarge: GoogleFonts.inter(
          color: AppColors.white,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: GoogleFonts.inter(
          color: AppColors.white,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: GoogleFonts.inter(
          color: AppColors.white,
        ),
        bodyMedium: GoogleFonts.inter(
          color: AppColors.white,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceAlt,
        foregroundColor: AppColors.white,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
      ),
      dividerColor: AppColors.white.withValues(alpha: 0.08),
      iconTheme: const IconThemeData(
        color: AppColors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white.withValues(alpha: 0.04),
        hintStyle: GoogleFonts.inter(
          color: AppColors.white.withValues(alpha: 0.5),
          fontSize: 14,
        ),
        prefixIconColor: AppColors.white.withValues(alpha: 0.7),
        suffixIconColor: AppColors.white.withValues(alpha: 0.7),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius),
          borderSide: BorderSide(
            color: AppColors.white.withValues(alpha: 0.08),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius),
          borderSide: BorderSide(
            color: AppColors.white.withValues(alpha: 0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius),
          borderSide: const BorderSide(
            color: AppColors.primary,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.18),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? AppColors.primary
                : AppColors.white.withValues(alpha: 0.72),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: isSelected
                ? AppColors.primary
                : AppColors.white.withValues(alpha: 0.72),
          );
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.white,
          side: BorderSide(
            color: AppColors.white.withValues(alpha: 0.14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surface,
        contentTextStyle: GoogleFonts.inter(
          color: AppColors.white,
          fontSize: 14,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.white.withValues(alpha: 0.9);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary.withValues(alpha: 0.35);
          }
          return AppColors.white.withValues(alpha: 0.18);
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
    );
  }

  static ThemeData get lightTheme {
    final base = ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        surface: Colors.white,
      ),
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        headlineLarge: GoogleFonts.inter(
          color: const Color(0xFF0F172A),
          fontWeight: FontWeight.w800,
        ),
        headlineMedium: GoogleFonts.inter(
          color: const Color(0xFF0F172A),
          fontWeight: FontWeight.w800,
        ),
        titleLarge: GoogleFonts.inter(
          color: const Color(0xFF0F172A),
          fontWeight: FontWeight.w800,
        ),
        titleMedium: GoogleFonts.inter(
          color: const Color(0xFF0F172A),
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: GoogleFonts.inter(
          color: const Color(0xFF0F172A),
        ),
        bodyMedium: GoogleFonts.inter(
          color: const Color(0xFF1E293B),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        centerTitle: true,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF0F172A),
        ),
      ),
      dividerColor: Colors.black.withValues(alpha: 0.06),
      iconTheme: const IconThemeData(
        color: Color(0xFF0F172A),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.03),
        hintStyle: GoogleFonts.inter(
          color: Colors.black.withValues(alpha: 0.45),
          fontSize: 14,
        ),
        prefixIconColor: Colors.black.withValues(alpha: 0.65),
        suffixIconColor: Colors.black.withValues(alpha: 0.65),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius),
          borderSide: BorderSide(
            color: Colors.black.withValues(alpha: 0.08),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius),
          borderSide: BorderSide(
            color: Colors.black.withValues(alpha: 0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius),
          borderSide: const BorderSide(
            color: AppColors.primary,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primary.withValues(alpha: 0.14),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? AppColors.primary
                : Colors.black.withValues(alpha: 0.72),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: isSelected
                ? AppColors.primary
                : Colors.black.withValues(alpha: 0.72),
          );
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF0F172A),
          side: BorderSide(
            color: Colors.black.withValues(alpha: 0.12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.white,
        contentTextStyle: GoogleFonts.inter(
          color: const Color(0xFF0F172A),
          fontSize: 14,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary.withValues(alpha: 0.35);
          }
          return Colors.black.withValues(alpha: 0.18);
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
    );
  }
}