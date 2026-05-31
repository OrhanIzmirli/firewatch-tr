import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

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
          _message =
          'Konum servisi kapalı görünüyor. Yine de uygulamaya devam edebilirsin.';
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
          _message =
          'Konum izni verilmedi. Şimdilik konumsuz devam edebilirsin.';
          _isLoading = false;
        });
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _message =
          'Konum izni kalıcı olarak reddedilmiş. Ayarlardan açabilirsin.';
          _isLoading = false;
        });
        return;
      }

      context.go('/app');
    } catch (e) {
      setState(() {
        _message =
        'Konum izni alınırken bir sorun oluştu. Şimdilik geçebilirsin.';
        _isLoading = false;
      });
    }
  }

  void _skipForNow() {
    context.go('/app');
  }

  @override
  Widget build(BuildContext context) {
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
                    'Yakınındaki olayları gösterelim',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
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
                    'Konum erişimiyle sana yakın yangın olaylarını, riskli bölgeleri ve daha ilgili bildirimleri gösterebiliriz.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
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
                            'Bu izin zorunlu değil. İstersen şimdilik atlayıp uygulamayı yine kullanabilirsin.',
                            style: GoogleFonts.inter(
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
                        style: GoogleFonts.inter(
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
                        'Konumu Etkinleştir',
                        style: GoogleFonts.inter(
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
                        'Şimdilik Geç',
                        style: GoogleFonts.inter(
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