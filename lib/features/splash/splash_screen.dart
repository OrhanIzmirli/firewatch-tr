import 'package:flutter/material.dart';
import '../nature/fact_widgets.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startAppFlow();
  }

  Future<void> _startAppFlow() async {
    // A short brand beat, not a wait: it used to hold every start for
    // 1.8 s even though nothing below depends on it.
    // Long enough to read the one-line fact, still shorter than the old 1.8 s.
    await Future.delayed(const Duration(milliseconds: 1500));

    final prefs = SharedPreferencesAsync();
    final hasSelectedLanguage = await prefs.getBool('hasSelectedLanguage') ?? false;
    final hasSeenOnboarding = await prefs.getBool('hasSeenOnboarding') ?? false;

    if (!mounted) return;

    if (hasSeenOnboarding) {
      context.go('/app');
    } else if (!hasSelectedLanguage) {
      context.go('/language-selection');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/forest-fire.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // A plain scrim instead of a full-screen BackdropFilter blur: the
          // blur was recomputed on every frame of the spinner animation,
          // which is costly on low-end GPUs right at cold start.
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.68),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.scrimLight,
                    AppColors.scrimMedium,
                    AppColors.scrimHeavy,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius),
                      child: Image.asset(
                        'assets/icon/app_icon.png',
                        width: 96,
                        height: 96,
                        // Source is 512x512; decoding straight to display
                        // size (with headroom for high-DPI screens) avoids
                        // holding a full 512x512 bitmap in memory just to
                        // show a 96x96 icon.
                        cacheWidth: 192,
                        cacheHeight: 192,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.appName,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.splashTagline,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 15,
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const FactLine(place: 'splash', color: Colors.white, align: TextAlign.center),
                    const SizedBox(height: 24),
                    const SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.6,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}