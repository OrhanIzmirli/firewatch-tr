import 'package:flutter/material.dart';

/// The instrument palette: warm-axis neutrals instead of blue-leaning slate,
/// one loud accent, semantics deliberately duller than the accent so orange
/// stays the only thing that shouts.
class AppColors {
  // Neutrals — warm axis, three raised steps above the background.
  static const Color background = Color(0xFF0B0A09);
  static const Color surface = Color(0xFF16130F);
  static const Color surfaceRaised = Color(0xFF221D17);
  static const Color border = Color(0xFF2A241C);
  static const Color surfaceAlt = Color(0xFF1C1108);

  // Accent.
  static const Color primary = Color(0xFFFF5A1F);

  // Text.
  static const Color textPrimary = Color(0xFFF2EEE9);
  static const Color textMuted = Color(0xFF9A9089);
  static const Color textFaint = Color(0xFF6B635C);

  // Semantics — duller than the accent on purpose.
  static const Color danger = Color(0xFFD4453D);
  static const Color warning = Color(0xFFC98A22);
  static const Color success = Color(0xFF3F9E63);
  static const Color info = Color(0xFF4A7FA8);

  static const Color white = Colors.white;

  /// The official Copernicus EFFIS Fire Weather Index class colours, exactly
  /// as the WMS raster paints them — any legend drawn from these can never
  /// drift from the heat-map layer. Order: very low → extreme.
  static const Color fwiVeryLow = Color(0xFF9CFFC0);
  static const Color fwiLow = Color(0xFFCDE24E);
  static const Color fwiModerate = Color(0xFFE6AC00);
  static const Color fwiHigh = Color(0xFFD97010);
  static const Color fwiVeryHigh = Color(0xFFAD060E);
  static const Color fwiExtreme = Color(0xFF3A0015);

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
