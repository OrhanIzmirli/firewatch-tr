import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF020617);
  static const Color surface = Color(0xFF111827);
  static const Color surfaceAlt = Color(0xFF1E0B00);

  static const Color primary = Color(0xFFF97316);
  static const Color danger = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  static const Color white = Colors.white;

  /// Maps a canonical (non-localized) risk tier — 'high' | 'medium' | 'low'
  /// — to its semantic color. Use this instead of matching localized label
  /// text, which varies by language.
  static Color forRiskTier(String tier) {
    switch (tier) {
      case 'high':
        return danger;
      case 'medium':
        return warning;
      default:
        return success;
    }
  }
}