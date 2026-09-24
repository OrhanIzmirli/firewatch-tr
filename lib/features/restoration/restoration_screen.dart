import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../shared/widgets/glass_panel.dart';
import '../../shared/widgets/status_chip.dart';

class RestorationScreen extends StatelessWidget {
  const RestorationScreen({super.key});

  String _t(BuildContext context, String tr, String en) =>
      Localizations.localeOf(context).languageCode == 'tr' ? tr : en;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark
        ? AppColors.white.withValues(alpha: 0.68)
        : Colors.black.withValues(alpha: 0.62);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _t(context, 'Kayıplar ve restorasyon', 'Losses & restoration'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          GlassPanel(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatusChip(
                  label: _t(context, 'TARİHSEL GÖRÜNÜM', 'HISTORICAL VIEW'),
                  icon: Icons.history_rounded,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  _t(
                    context,
                    'Yangından sonra ne oldu?',
                    'What happened after the fire?',
                  ),
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _t(
                    context,
                    'Yanan alan kayıplarını ve doğrulanmış restorasyon çalışmalarını zaman içinde tek yerde takip edin.',
                    'Track burned-area loss and verified restoration work over time in one place.',
                  ),
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 15,
                    height: 1.5,
                    color: muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _NoticeCard(
            icon: Icons.satellite_alt_rounded,
            title: _t(
              context,
              'Aylık uydu analizi',
              'Monthly satellite analysis',
            ),
            body: _t(
              context,
              "Yanan alan verileri, NASA'nın aylık uydu analizine dayanır. Yeni biten bir ayın verisi genellikle takip eden ayın ortasında sisteme eklenir.",
              'Burned-area data is based on NASA monthly satellite analysis. A completed month is usually added around the middle of the following month.',
            ),
            color: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.md),
          _DataFreshnessCard(isTurkish: Localizations.localeOf(context).languageCode == 'tr'),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            _t(context, 'Kayıp alan görünümü', 'Burned-area overview'),
            style: GoogleFonts.ibmPlexSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GlassPanel(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                Container(
                  height: 190,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(
                      AppSpacing.largeCardRadius,
                    ),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.22),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.map_outlined,
                          color: AppColors.primary,
                          size: 42,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          _t(
                            context,
                            'Harita verisi hazırlanıyor',
                            'Map data is being prepared',
                          ),
                          style: GoogleFonts.ibmPlexSans(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: _Metric(
                        label: _t(context, 'Toplam kayıp', 'Total loss'),
                        value: '— ha',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _Metric(
                        label: _t(context, 'İzlenen olay', 'Tracked events'),
                        value: '—',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          _NoticeCard(
            icon: Icons.park_outlined,
            title: _t(
              context,
              'Restorasyon verisi bekleniyor',
              'Restoration data pending',
            ),
            body: _t(
              context,
              'Ağaçlandırma başlangıç tarihleri yalnızca doğrulanmış resmi kayıtlar sağlandığında gösterilecek. Bu bölüm şu anda tasarım ön izlemesidir.',
              'Reforestation start dates will appear only after verified official records are available. This section is currently a design preview.',
            ),
            color: AppColors.success,
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            _t(context, 'Takip zaman çizelgesi', 'Tracking timeline'),
            style: GoogleFonts.ibmPlexSans(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.md),
          _RestorationTimeline(isTurkish: Localizations.localeOf(context).languageCode == 'tr'),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.lg),
    decoration: BoxDecoration(
      color: AppColors.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.ibmPlexMono(
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.ibmPlexSans(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
      ],
    ),
  );
}

class _NoticeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final Color color;
  const _NoticeCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => GlassPanel(
    padding: const EdgeInsets.all(AppSpacing.lg),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                body,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 13,
                  height: 1.45,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _DataFreshnessCard extends StatelessWidget {
  final bool isTurkish;
  const _DataFreshnessCard({required this.isTurkish});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
    decoration: BoxDecoration(
      color: AppColors.surfaceRaised,
      borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      children: [
        const Icon(Icons.schedule_rounded, size: 18, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            isTurkish
                ? 'Veri tarihi: İlk aylık veri aktarımı bekleniyor'
                : 'Data date: awaiting the first monthly data import',
            style: GoogleFonts.ibmPlexSans(fontSize: 12.5, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}

class _RestorationTimeline extends StatelessWidget {
  final bool isTurkish;
  const _RestorationTimeline({required this.isTurkish});

  @override
  Widget build(BuildContext context) {
    final steps = [
      (Icons.local_fire_department_outlined, isTurkish ? 'Yangın olayı' : 'Fire event', true),
      (Icons.satellite_alt_rounded, isTurkish ? 'Aylık uydu ölçümü' : 'Monthly satellite measure', false),
      (Icons.park_outlined, isTurkish ? 'Restorasyon başlangıcı' : 'Restoration start', false),
      (Icons.fact_check_outlined, isTurkish ? 'Son doğrulama' : 'Latest verification', false),
    ];

    return GlassPanel(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: (steps[i].$3 ? AppColors.primary : AppColors.textFaint)
                        .withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    steps[i].$1,
                    size: 19,
                    color: steps[i].$3 ? AppColors.primary : AppColors.textMuted,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(steps[i].$2,
                      style: GoogleFonts.ibmPlexSans(fontSize: 14, fontWeight: FontWeight.w700)),
                ),
                Text(
                  steps[i].$3
                      ? (isTurkish ? 'KAYITLI' : 'RECORDED')
                      : (isTurkish ? 'VERİ BEKLENİYOR' : 'PENDING DATA'),
                  style: GoogleFonts.ibmPlexMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: steps[i].$3 ? AppColors.primary : AppColors.textMuted,
                  ),
                ),
              ],
            ),
            if (i != steps.length - 1)
              Container(
                width: 1,
                height: 22,
                margin: const EdgeInsets.only(left: 18),
                color: AppColors.border,
              ),
          ],
        ],
      ),
    );
  }
}
