import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../shared/widgets/language_badge.dart';
import '../../services/locale_provider.dart';

/// Shown once, before onboarding, on first launch only. Intentionally
/// avoids AppLocalizations — the user hasn't picked a language yet, so
/// every label here is bilingual/self-explanatory (flag + native name).
class LanguageSelectionScreen extends ConsumerStatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  ConsumerState<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends ConsumerState<LanguageSelectionScreen> {
  bool _busy = false;

  Future<void> _selectLanguage(String code) async {
    if (_busy) return;
    setState(() => _busy = true);

    await ref.read(localeProvider.notifier).setLocale(Locale(code));
    final prefs = SharedPreferencesAsync();
    await prefs.setBool('hasSelectedLanguage', true);

    if (!mounted) return;
    context.go('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/forest-fire.jpg', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
              child: Container(color: Colors.black.withValues(alpha: 0.6)),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.scrimLight, AppColors.scrimMedium, AppColors.scrimHeavy],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Dil seçin',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.ibmPlexSans(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Choose your language',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.ibmPlexSans(fontSize: 16, color: AppColors.white.withValues(alpha: 0.78)),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  _LanguageCard(
                    code: 'TR',
                    label: 'Türkçe',
                    enabled: !_busy,
                    onTap: () => _selectLanguage('tr'),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _LanguageCard(
                    code: 'EN',
                    label: 'English',
                    enabled: !_busy,
                    onTap: () => _selectLanguage('en'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final String code;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.code,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface.withValues(alpha: 0.85),
      borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius),
        onTap: enabled ? onTap : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: AppSpacing.xl),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.28)),
          ),
          child: Row(
            children: [
              LanguageBadge(code: code, size: 40),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.ibmPlexSans(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.white),
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
