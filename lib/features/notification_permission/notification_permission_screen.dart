import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../l10n/app_localizations.dart';
import '../../services/notification_service.dart';

class NotificationPermissionScreen extends StatefulWidget {
  const NotificationPermissionScreen({super.key});

  @override
  State<NotificationPermissionScreen> createState() => _NotificationPermissionScreenState();
}

class _NotificationPermissionScreenState extends State<NotificationPermissionScreen> {
  bool _isLoading = false;
  String? _message;

  Future<void> _requestNotificationPermission() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final granted = await NotificationService.instance.requestPermission();
      if (!mounted) return;
      setState(() {
        _message = granted
            ? AppLocalizations.of(context)!.notifPermGranted
            : AppLocalizations.of(context)!.notifPermDenied;
        _isLoading = false;
      });
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      context.go('/app');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _message = AppLocalizations.of(context)!.notifPermDenied;
        _isLoading = false;
      });
    }
  }

  void _skipForNow() {
    context.go('/app');
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
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
              child: Container(color: Colors.black.withValues(alpha: 0.6)),
            ).animate().fadeIn(duration: 500.ms),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x66000000), Color(0x99000000), Color(0xCC000000)],
                ),
              ),
            ).animate().fadeIn(duration: 600.ms),
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
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.24)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.18),
                          blurRadius: 30,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.notifications_active_rounded,
                      size: 70,
                      color: AppColors.primary,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 120.ms)
                      .scale(begin: const Offset(0.85, 0.85), end: const Offset(1, 1), curve: Curves.easeOutBack)
                      .then()
                      .shimmer(duration: 1200.ms),

                  const SizedBox(height: 36),

                  Text(
                    l10n.notifPermTitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.white),
                  ).animate().fadeIn(duration: 360.ms, delay: 180.ms).slideY(begin: 0.12, end: 0),

                  const SizedBox(height: AppSpacing.md),

                  Text(
                    l10n.notifPermSubtitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 16, height: 1.5, color: AppColors.white.withValues(alpha: 0.82)),
                  ).animate().fadeIn(duration: 360.ms, delay: 250.ms).slideY(begin: 0.12, end: 0),

                  const SizedBox(height: AppSpacing.xxl),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.84),
                      borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline_rounded, color: AppColors.primary),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            l10n.notifPermNote,
                            style: GoogleFonts.inter(fontSize: 14, height: 1.45, color: AppColors.white.withValues(alpha: 0.78)),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 360.ms, delay: 330.ms).slideY(begin: 0.1, end: 0).scale(
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
                        borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.22)),
                      ),
                      child: Text(
                        _message!,
                        style: GoogleFonts.inter(fontSize: 14, height: 1.45, color: AppColors.white.withValues(alpha: 0.84)),
                      ),
                    ).animate().fadeIn(duration: 260.ms).slideY(begin: 0.08, end: 0),
                  ],

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _requestNotificationPermission,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.white),
                            )
                          : Text(
                              l10n.notifPermEnable,
                              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                    ),
                  ).animate(delay: 420.ms).fadeIn(duration: 300.ms).slideY(begin: 0.18, end: 0).scale(
                        begin: const Offset(0.97, 0.97),
                        end: const Offset(1, 1),
                      ),

                  const SizedBox(height: AppSpacing.md),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _skipForNow,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.white,
                        side: BorderSide(color: AppColors.white.withValues(alpha: 0.16)),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius)),
                      ),
                      child: Text(
                        l10n.notifPermSkip,
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ).animate(delay: 500.ms).fadeIn(duration: 300.ms).slideY(begin: 0.18, end: 0).scale(
                        begin: const Offset(0.97, 0.97),
                        end: const Offset(1, 1),
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
