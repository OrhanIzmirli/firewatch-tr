import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../l10n/app_localizations.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {
  bool _isLoading = false;
  String? _message;

  Future<void> _requestLocationPermission() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        setState(() {
          _message = AppLocalizations.of(context)!.locPermServiceOff;
          _isLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (!mounted) return;

      if (permission == LocationPermission.denied) {
        setState(() {
          _message = AppLocalizations.of(context)!.locPermDenied;
          _isLoading = false;
        });
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _message = AppLocalizations.of(context)!.locPermDeniedForever;
          _isLoading = false;
        });
        return;
      }

      context.go('/notification-permission');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _message = AppLocalizations.of(context)!.locPermError;
        _isLoading = false;
      });
    }
  }

  void _skipForNow() {
    context.go('/notification-permission');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/forest-fire.jpg',
              fit: BoxFit.cover,
            )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .scale(
              begin: const Offset(1, 1),
              end: const Offset(1.04, 1.04),
              duration: 14.seconds,
              curve: Curves.easeInOut,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 7,
                sigmaY: 7,
              ),
              child: Container(
                color: Colors.black.withValues(alpha: 0.6),
              ),
            )
                .animate()
                .fadeIn(duration: 500.ms),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x66000000),
                    Color(0x99000000),
                    Color(0xCC000000),
                  ],
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  const Spacer(),
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.84),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.18),
                          blurRadius: 30,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      size: 70,
                      color: AppColors.primary,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 120.ms)
                      .scale(
                    begin: const Offset(0.85, 0.85),
                    end: const Offset(1, 1),
                    curve: Curves.easeOutBack,
                  )
                      .then()
                      .shimmer(duration: 1200.ms),

                  const SizedBox(height: 36),

                  Text(
                    l10n.locPermTitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 360.ms, delay: 180.ms)
                      .slideY(begin: 0.12, end: 0),

                  const SizedBox(height: AppSpacing.md),

                  Text(
                    l10n.locPermSubtitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 16,
                      height: 1.5,
                      color: AppColors.white.withValues(alpha: 0.82),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 360.ms, delay: 250.ms)
                      .slideY(begin: 0.12, end: 0),

                  const SizedBox(height: AppSpacing.xxl),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.84),
                      borderRadius:
                      BorderRadius.circular(AppSpacing.largeCardRadius),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            l10n.locPermNote,
                            style: GoogleFonts.ibmPlexSans(
                              fontSize: 14,
                              height: 1.45,
                              color: AppColors.white.withValues(alpha: 0.78),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 360.ms, delay: 330.ms)
                      .slideY(begin: 0.1, end: 0)
                      .scale(
                    begin: const Offset(0.98, 0.98),
                    end: const Offset(1, 1),
                  ),

                  if (_message != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.84),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.largeCardRadius,
                        ),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.22),
                        ),
                      ),
                      child: Text(
                        _message!,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 14,
                          height: 1.45,
                          color: AppColors.white.withValues(alpha: 0.84),
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 260.ms)
                        .slideY(begin: 0.08, end: 0),
                  ],

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _requestLocationPermission,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.largeCardRadius,
                          ),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: AppColors.white,
                        ),
                      )
                          : Text(
                        l10n.locPermEnable,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                        .animate(delay: 420.ms)
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: 0.18, end: 0)
                        .scale(
                      begin: const Offset(0.97, 0.97),
                      end: const Offset(1, 1),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _skipForNow,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.white,
                        side: BorderSide(
                          color: AppColors.white.withValues(alpha: 0.16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.largeCardRadius,
                          ),
                        ),
                      ),
                      child: Text(
                        l10n.locPermSkip,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                        .animate(delay: 500.ms)
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: 0.18, end: 0)
                        .scale(
                      begin: const Offset(0.97, 0.97),
                      end: const Offset(1, 1),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}