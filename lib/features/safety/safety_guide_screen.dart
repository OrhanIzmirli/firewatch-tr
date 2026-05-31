import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../shared/widgets/glass_panel.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/status_chip.dart';

class SafetyGuideScreen extends StatelessWidget {
  const SafetyGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final titleColor = theme.textTheme.titleLarge?.color ??
        (isDark ? AppColors.white : const Color(0xFF0F172A));
    final secondaryTextColor = isDark
        ? AppColors.white.withValues(alpha: 0.74)
        : Colors.black.withValues(alpha: 0.66);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Güvenlik Rehberi',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassPanel(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const StatusChip(
                    label: 'Acil Durum Bilgisi',
                    icon: Icons.shield_outlined,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Yangın Güvenlik Merkezi',
                    style: GoogleFonts.inter(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Yangın sırasında ne yapacağını hızlıca görmek, tahliye mantığını anlamak ve doğru adımları takip etmek için hazırlanmış rehber ekranı.',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      height: 1.45,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 450.ms)
                .scale(
              begin: const Offset(0.97, 0.97),
              end: const Offset(1, 1),
              curve: Curves.easeOutCubic,
            )
                .slideY(begin: 0.06, end: 0),

            const SizedBox(height: AppSpacing.xxl),

            const SectionHeader(
              title: 'Hızlı Aksiyonlar',
              subtitle: 'İlk bakışta kritik davranışlar',
              icon: Icons.flash_on_rounded,
            )
                .animate(delay: 80.ms)
                .fadeIn(duration: 280.ms)
                .slideX(begin: -0.03, end: 0),

            const SizedBox(height: AppSpacing.md),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 1.08,
              children: const [
                _QuickActionCard(
                  title: 'Tahliyeye Hazır Ol',
                  subtitle: 'Çıkış planını netleştir',
                  icon: Icons.directions_run_rounded,
                  accent: AppColors.primary,
                  delay: Duration(milliseconds: 140),
                ),
                _QuickActionCard(
                  title: 'Dumanı Ciddiye Al',
                  subtitle: 'Kapalı alana geç, maske kullan',
                  icon: Icons.masks_rounded,
                  accent: AppColors.warning,
                  delay: Duration(milliseconds: 220),
                ),
                _QuickActionCard(
                  title: 'Yetkili Duyuruları İzle',
                  subtitle: 'Resmi kaynakları takip et',
                  icon: Icons.campaign_rounded,
                  accent: AppColors.primary,
                  delay: Duration(milliseconds: 300),
                ),
                _QuickActionCard(
                  title: 'Geç Kalma',
                  subtitle: 'Tahliye çağrısını bekletme',
                  icon: Icons.warning_amber_rounded,
                  accent: AppColors.danger,
                  delay: Duration(milliseconds: 380),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xxxl),

            const SectionHeader(
              title: 'Acil Kontrol Listesi',
              subtitle: 'Yangın anında temel adımlar',
              icon: Icons.checklist_rounded,
            )
                .animate(delay: 130.ms)
                .fadeIn(duration: 280.ms)
                .slideX(begin: -0.03, end: 0),

            const SizedBox(height: AppSpacing.md),

            const _ChecklistTile(
              title: 'Kimlik, telefon ve şarj aletini hazır tut',
              description: 'Zorunlu temel eşyaları tek yerde topla.',
              delay: Duration(milliseconds: 180),
            ),
            const SizedBox(height: AppSpacing.sm),
            const _ChecklistTile(
              title: 'Kapı ve pencere durumunu kontrol et',
              description: 'Duman girişini azaltmak için açık alanları gözden geçir.',
              delay: Duration(milliseconds: 250),
            ),
            const SizedBox(height: AppSpacing.sm),
            const _ChecklistTile(
              title: 'Aile / yakınlarınla buluşma planı belirle',
              description: 'Ayrı düşerseniz nerede buluşacağınızı önceden bil.',
              delay: Duration(milliseconds: 320),
            ),
            const SizedBox(height: AppSpacing.sm),
            const _ChecklistTile(
              title: 'Resmi tahliye rotasını takip et',
              description: 'Kendi başına riskli güzergah uydurma.',
              delay: Duration(milliseconds: 390),
            ),

            const SizedBox(height: AppSpacing.xxxl),

            const SectionHeader(
              title: 'Detaylı Rehber',
              subtitle: 'Senaryoya göre açılır bilgi kartları',
              icon: Icons.menu_book_rounded,
            )
                .animate(delay: 180.ms)
                .fadeIn(duration: 280.ms)
                .slideX(begin: -0.03, end: 0),

            const SizedBox(height: AppSpacing.md),

            const _GuideAccordion(
              title: 'Evdeysen ne yapmalısın?',
              icon: Icons.home_rounded,
              points: [
                'Duman yoğunluğu varsa kapı ve pencereleri kapalı tut.',
                'Elektrik, gaz ve hızlı çıkış güzergahını kontrol et.',
                'Tahliye çağrısı varsa eşyaları toplamaya çalışma, çıkışa odaklan.',
                'Evcil hayvanları mümkünse hızlıca güvenli taşıma düzenine al.',
              ],
              delay: Duration(milliseconds: 230),
            ),
            const SizedBox(height: AppSpacing.md),
            const _GuideAccordion(
              title: 'Araçtayken ne yapmalısın?',
              icon: Icons.directions_car_filled_rounded,
              points: [
                'Yoğun duman içinden geçmeye çalışma.',
                'Mümkünse güvenli açık alana veya yerleşim merkezine yönel.',
                'Aracı kuru otların ve ağaç altlarının yanında bırakma.',
                'Resmi yönlendirme varsa navigasyondan değil, duyurudan ilerle.',
              ],
              delay: Duration(milliseconds: 300),
            ),
            const SizedBox(height: AppSpacing.md),
            const _GuideAccordion(
              title: 'Dışarıdaysan ne yapmalısın?',
              icon: Icons.terrain_rounded,
              points: [
                'Rüzgar yönünü gözlemle ve yangının önüne geçme.',
                'Yüksek bitki örtüsünden ve dar vadilerden uzaklaş.',
                'Topluluk halinde hareket ediyorsan dağılmadan ilerle.',
                'Acil durumda açık, çıplak ve yanıcı olmayan alana çık.',
              ],
              delay: Duration(milliseconds: 370),
            ),
            const SizedBox(height: AppSpacing.md),
            const _GuideAccordion(
              title: 'Tahliye emri geldiyse ne yapmalısın?',
              icon: Icons.gpp_good_rounded,
              points: [
                'Emri geciktirme, “biraz daha bekleyeyim” deme.',
                'Sadece temel eşyaları al ve çıkışa odaklan.',
                'Yakınlarını tek tek arayıp vakit kaybetme, önceden plan kullan.',
                'Yetkililerin toplama alanı duyurusunu takip et.',
              ],
              delay: Duration(milliseconds: 440),
            ),

            const SizedBox(height: AppSpacing.xxxl),

            const SectionHeader(
              title: 'Acil Numaralar',
              subtitle: 'Hızlı erişim için not düş',
              icon: Icons.phone_in_talk_rounded,
            )
                .animate(delay: 230.ms)
                .fadeIn(duration: 280.ms)
                .slideX(begin: -0.03, end: 0),

            const SizedBox(height: AppSpacing.md),

            const _EmergencyNumberCard(
              title: 'Acil Çağrı Merkezi',
              number: '112',
              subtitle: 'Genel acil durum hattı',
              delay: Duration(milliseconds: 280),
            ),
            const SizedBox(height: AppSpacing.md),
            const _EmergencyNumberCard(
              title: 'Orman Yangını Bildirimi',
              number: '177',
              subtitle: 'Yangın ve orman hattı',
              delay: Duration(milliseconds: 350),
            ),
            const SizedBox(height: AppSpacing.md),
            const _EmergencyNumberCard(
              title: 'AFAD / Yerel Yönlendirme',
              number: 'Yerel duyuruları takip et',
              subtitle: 'Bölgesel anons ve yönlendirme önemli',
              delay: Duration(milliseconds: 420),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final Duration delay;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = Theme.of(context).textTheme.titleMedium?.color ??
        (isDark ? AppColors.white : const Color(0xFF0F172A));
    final subtitleColor = isDark
        ? AppColors.white.withValues(alpha: 0.62)
        : Colors.black.withValues(alpha: 0.56);

    return GlassPanel(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: accent,
              size: 22,
            ),
          ),
          const Spacer(),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: titleColor,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 12,
              height: 1.35,
              color: subtitleColor,
            ),
          ),
        ],
      ),
    )
        .animate(delay: delay)
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.14, end: 0)
        .scale(
      begin: const Offset(0.96, 0.96),
      end: const Offset(1, 1),
    );
  }
}

class _ChecklistTile extends StatelessWidget {
  final String title;
  final String description;
  final Duration delay;

  const _ChecklistTile({
    required this.title,
    required this.description,
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = Theme.of(context).textTheme.titleMedium?.color ??
        (isDark ? AppColors.white : const Color(0xFF0F172A));
    final descriptionColor = isDark
        ? AppColors.white.withValues(alpha: 0.66)
        : Colors.black.withValues(alpha: 0.58);

    return GlassPanel(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    height: 1.4,
                    color: descriptionColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate(delay: delay)
        .fadeIn(duration: 260.ms)
        .slideX(begin: 0.03, end: 0)
        .scale(
      begin: const Offset(0.98, 0.98),
      end: const Offset(1, 1),
    );
  }
}

class _GuideAccordion extends StatefulWidget {
  final String title;
  final IconData icon;
  final List<String> points;
  final Duration delay;

  const _GuideAccordion({
    required this.title,
    required this.icon,
    required this.points,
    this.delay = Duration.zero,
  });

  @override
  State<_GuideAccordion> createState() => _GuideAccordionState();
}

class _GuideAccordionState extends State<_GuideAccordion> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = Theme.of(context).textTheme.titleMedium?.color ??
        (isDark ? AppColors.white : const Color(0xFF0F172A));
    final pointColor = isDark
        ? AppColors.white.withValues(alpha: 0.72)
        : Colors.black.withValues(alpha: 0.64);
    final arrowColor = isDark
        ? AppColors.white.withValues(alpha: 0.7)
        : Colors.black.withValues(alpha: 0.5);

    return GlassPanel(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.icon,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    widget.title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                  ),
                ),
                AnimatedRotation(
                  duration: const Duration(milliseconds: 220),
                  turns: _expanded ? 0.5 : 0,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: arrowColor,
                  ),
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.lg),
              child: Column(
                children: widget.points
                    .map(
                      (point) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Icon(
                            Icons.circle,
                            size: 8,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            point,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              height: 1.45,
                              color: pointColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    )
        .animate(delay: widget.delay)
        .fadeIn(duration: 280.ms)
        .slideY(begin: 0.1, end: 0)
        .scale(
      begin: const Offset(0.98, 0.98),
      end: const Offset(1, 1),
    );
  }
}

class _EmergencyNumberCard extends StatelessWidget {
  final String title;
  final String number;
  final String subtitle;
  final Duration delay;

  const _EmergencyNumberCard({
    required this.title,
    required this.number,
    required this.subtitle,
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = Theme.of(context).textTheme.titleMedium?.color ??
        (isDark ? AppColors.white : const Color(0xFF0F172A));
    final subtitleColor = isDark
        ? AppColors.white.withValues(alpha: 0.64)
        : Colors.black.withValues(alpha: 0.56);

    return GlassPanel(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.phone_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Flexible(
            child: Text(
              number,
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    )
        .animate(delay: delay)
        .fadeIn(duration: 280.ms)
        .slideX(begin: 0.03, end: 0)
        .scale(
      begin: const Offset(0.98, 0.98),
      end: const Offset(1, 1),
    );
  }
}