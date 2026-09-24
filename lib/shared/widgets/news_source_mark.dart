import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';

class NewsSourceMark extends StatelessWidget {
  final String source;
  final String logoUrl;
  final double size;

  const NewsSourceMark({
    super.key,
    required this.source,
    this.logoUrl = '',
    this.size = 42,
  });

  Color get _brandColor {
    final value = source.toLowerCase();
    if (value.contains('orman') || value.contains('ogm')) {
      return const Color(0xFF3F9E63);
    }
    if (value.contains('meteoroloji') || value.contains('mgm')) {
      return const Color(0xFF4A7FA8);
    }
    if (value.contains('afad')) return const Color(0xFFD4453D);
    if (value.contains('nasa')) return const Color(0xFF315C91);
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final fallback = DecoratedBox(
      decoration: BoxDecoration(
        color: _brandColor.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(color: _brandColor.withValues(alpha: 0.35)),
      ),
      child: Center(
        child: Text(
          source.trim().isEmpty ? '?' : source.trim()[0].toUpperCase(),
          style: GoogleFonts.ibmPlexSans(
            color: _brandColor,
            fontSize: size * 0.42,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );

    return SizedBox.square(
      dimension: size,
      child: logoUrl.isEmpty
          ? fallback
          : ClipRRect(
              borderRadius: BorderRadius.circular(size * 0.28),
              child: Image.network(
                logoUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => fallback,
              ),
            ),
    );
  }
}
