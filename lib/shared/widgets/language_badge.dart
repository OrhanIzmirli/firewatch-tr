import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';

/// The two-letter language code in a rounded tile, used in place of a flag
/// emoji in the language pickers.
///
/// Beyond the app's no-emoji rule, a flag is the wrong symbol for a language:
/// it names a country, and the glyph is missing or rendered as bare letters on
/// several platforms anyway. The code is what the app actually switches on.
class LanguageBadge extends StatelessWidget {
  final String code;
  final double size;

  const LanguageBadge({super.key, required this.code, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: Text(
        code.toUpperCase(),
        style: GoogleFonts.ibmPlexSans(
          fontSize: size * 0.42,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
