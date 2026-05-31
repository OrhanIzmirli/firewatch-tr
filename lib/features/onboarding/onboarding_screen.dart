import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingItem> _items = const [
    _OnboardingItem(
      icon: Icons.local_fire_department_rounded,
      title: 'Aktif olayları takip et',
      description:
      'Türkiye genelindeki yangın olaylarını tek ekranda takip et ve durum değişikliklerini hızlıca gör.',
    ),
    _OnboardingItem(
      icon: Icons.map_rounded,
      title: 'Yakınındaki bölgeleri gör',
      description:
      'Harita ve bölge odaklı ekranlarla sana yakın olayları daha hızlı fark et.',
    ),
    _OnboardingItem(
      icon: Icons.shield_outlined,
      title: 'Güvenlik yönlendirmeleri al',
      description:
      'Risk seviyelerini incele, önerilen aksiyonları gör ve gerektiğinde hızlı hareket et.',
    ),
  ];

  bool get _isLastPage => _currentPage == _items.length - 1;

  Future<void> _finishOnboarding() async {
    final prefs = SharedPreferencesAsync();
    await prefs.setBool('hasSeenOnboarding', true);

    if (!mounted) return;
    context.go('/location-permission');
  }

  void _nextPage() {
    if (_isLastPage) {
      _finishOnboarding();
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 7,
                sigmaY: 7,
              ),
              child: Container(
                color: Colors.black.withValues(alpha: 0.58),
              ),
            ),
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
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Spacer(),
                      TextButton(
                        onPressed: _finishOnboarding,
                        child: Text(
                          'Geç',
                          style: GoogleFonts.inter(
                            color: AppColors.white.withValues(alpha: 0.82),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _items.length,
                      onPageChanged: (value) {
                        setState(() {
                          _currentPage = value;
                        });
                      },
                      itemBuilder: (context, index) {
                        final pageItem = _items[index];

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                color: AppColors.surface.withValues(alpha: 0.82),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.28),
                                ),
                              ),
                              child: Icon(
                                pageItem.icon,
                                size: 74,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 40),
                            Text(
                              pageItem.title,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                pageItem.description,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  height: 1.5,
                                  color:
                                  AppColors.white.withValues(alpha: 0.82),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _items.length,
                          (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 26 : 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primary
                              : AppColors.white.withValues(alpha: 0.22),
                          borderRadius:
                          BorderRadius.circular(AppSpacing.pillRadius),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _nextPage,
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
                      child: Text(
                        _isLastPage ? 'Devam Et' : 'Sonraki',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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

class _OnboardingItem {
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}