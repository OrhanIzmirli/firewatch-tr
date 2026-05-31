import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../services/settings_provider.dart';
import '../../shared/widgets/glass_panel.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/status_chip.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
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
          'Ayarlar',
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const StatusChip(
                    label: 'Tercihler',
                    icon: Icons.tune_rounded,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Uygulama Ayarları',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Bildirimleri, konum tabanlı uyarıları ve uygulama davranışını buradan özelleştir.',
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
              title: 'Bildirimler',
              subtitle: 'Uyarı tercihlerini yönet',
              icon: Icons.notifications_active_rounded,
            )
                .animate(delay: 90.ms)
                .fadeIn(duration: 280.ms)
                .slideX(begin: -0.03, end: 0),

            const SizedBox(height: AppSpacing.md),

            GlassPanel(
              child: Column(
                children: [
                  _SettingsSwitchTile(
                    title: 'Push Bildirimleri',
                    subtitle:
                    'Yeni olaylar ve önemli değişiklikler için bildirim al',
                    value: settings.pushNotificationsEnabled,
                    onChanged: notifier.togglePushNotifications,
                    icon: Icons.notifications_rounded,
                  ),
                  Divider(
                    height: 24,
                    color: isDark
                        ? AppColors.white.withValues(alpha: 0.06)
                        : Colors.black.withValues(alpha: 0.05),
                  ),
                  _SettingsSwitchTile(
                    title: 'Yakındaki Olay Uyarıları',
                    subtitle:
                    'Konumuna yakın bölgelerde olay varsa öncelikli göster',
                    value: settings.nearbyAlertsEnabled,
                    onChanged: notifier.toggleNearbyAlerts,
                    icon: Icons.location_on_rounded,
                  ),
                ],
              ),
            )
                .animate(delay: 150.ms)
                .fadeIn(duration: 320.ms)
                .slideY(begin: 0.08, end: 0)
                .scale(
              begin: const Offset(0.98, 0.98),
              end: const Offset(1, 1),
            ),

            const SizedBox(height: AppSpacing.xxl),

            const SectionHeader(
              title: 'Uygulama Davranışı',
              subtitle: 'Görünüm ve yenileme sıklığı',
              icon: Icons.settings_suggest_rounded,
            )
                .animate(delay: 140.ms)
                .fadeIn(duration: 280.ms)
                .slideX(begin: -0.03, end: 0),

            const SizedBox(height: AppSpacing.md),

            GlassPanel(
              child: Column(
                children: [
                  _SettingsSwitchTile(
                    title: 'Koyu Tema',
                    subtitle: 'Premium koyu görünümü aktif tut',
                    value: settings.darkModeEnabled,
                    onChanged: notifier.toggleDarkMode,
                    icon: Icons.dark_mode_rounded,
                  ),
                  Divider(
                    height: 24,
                    color: isDark
                        ? AppColors.white.withValues(alpha: 0.06)
                        : Colors.black.withValues(alpha: 0.05),
                  ),
                  _RefreshIntervalTile(
                    value: settings.refreshInterval,
                    onChanged: (value) {
                      if (value == null) return;
                      notifier.setRefreshInterval(value);
                    },
                  ),
                ],
              ),
            )
                .animate(delay: 210.ms)
                .fadeIn(duration: 320.ms)
                .slideY(begin: 0.08, end: 0)
                .scale(
              begin: const Offset(0.98, 0.98),
              end: const Offset(1, 1),
            ),

            const SizedBox(height: AppSpacing.xxl),

            const SectionHeader(
              title: 'Uygulama Bilgisi',
              subtitle: 'Sürüm ve ürün özeti',
              icon: Icons.info_outline_rounded,
            )
                .animate(delay: 190.ms)
                .fadeIn(duration: 280.ms)
                .slideX(begin: -0.03, end: 0),

            const SizedBox(height: AppSpacing.md),

            GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _InfoLine(
                    label: 'Uygulama',
                    value: 'FireWatch TR',
                    delay: Duration(milliseconds: 80),
                  ),
                  SizedBox(height: AppSpacing.md),
                  _InfoLine(
                    label: 'Sürüm',
                    value: 'v1.0.0 demo',
                    delay: Duration(milliseconds: 140),
                  ),
                  SizedBox(height: AppSpacing.md),
                  _InfoLine(
                    label: 'Platform',
                    value: 'Flutter / Android',
                    delay: Duration(milliseconds: 200),
                  ),
                  SizedBox(height: AppSpacing.md),
                  _InfoLine(
                    label: 'Amaç',
                    value: 'Yangın odaklı disaster tracking',
                    delay: Duration(milliseconds: 260),
                  ),
                ],
              ),
            )
                .animate(delay: 260.ms)
                .fadeIn(duration: 320.ms)
                .slideY(begin: 0.08, end: 0)
                .scale(
              begin: const Offset(0.98, 0.98),
              end: const Offset(1, 1),
            ),

            const SizedBox(height: AppSpacing.xxl),

            GlassPanel(
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: AppColors.primary,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 260.ms)
                      .scale(
                    begin: const Offset(0.85, 0.85),
                    end: const Offset(1, 1),
                    curve: Curves.easeOutBack,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Bu ekran şu anda demo preference state kullanıyor. İstersek bir sonraki adımda SharedPreferences ile kalıcı hale getirebiliriz.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        height: 1.45,
                        color: secondaryTextColor,
                      ),
                    )
                        .animate(delay: 100.ms)
                        .fadeIn(duration: 260.ms)
                        .slideX(begin: 0.03, end: 0),
                  ),
                ],
              ),
            )
                .animate(delay: 320.ms)
                .fadeIn(duration: 320.ms)
                .slideY(begin: 0.08, end: 0)
                .scale(
              begin: const Offset(0.98, 0.98),
              end: const Offset(1, 1),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData icon;

  const _SettingsSwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = Theme.of(context).textTheme.titleMedium?.color ??
        (isDark ? AppColors.white : const Color(0xFF0F172A));
    final subtitleColor = isDark
        ? AppColors.white.withValues(alpha: 0.64)
        : Colors.black.withValues(alpha: 0.58);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        )
            .animate()
            .fadeIn(duration: 240.ms)
            .scale(
          begin: const Offset(0.85, 0.85),
          end: const Offset(1, 1),
          curve: Curves.easeOutBack,
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
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  height: 1.4,
                  color: subtitleColor,
                ),
              ),
            ],
          )
              .animate(delay: 60.ms)
              .fadeIn(duration: 240.ms)
              .slideX(begin: 0.03, end: 0),
        ),
        const SizedBox(width: AppSpacing.md),
        Switch(
          value: value,
          onChanged: onChanged,
        )
            .animate(delay: 100.ms)
            .fadeIn(duration: 220.ms)
            .scale(
          begin: const Offset(0.92, 0.92),
          end: const Offset(1, 1),
        ),
      ],
    );
  }
}

class _RefreshIntervalTile extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const _RefreshIntervalTile({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = Theme.of(context).textTheme.titleMedium?.color ??
        (isDark ? AppColors.white : const Color(0xFF0F172A));
    final subtitleColor = isDark
        ? AppColors.white.withValues(alpha: 0.64)
        : Colors.black.withValues(alpha: 0.58);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.sync_rounded,
            color: AppColors.primary,
            size: 20,
          ),
        )
            .animate()
            .fadeIn(duration: 260.ms)
            .scale(
          begin: const Offset(0.85, 0.85),
          end: const Offset(1, 1),
          curve: Curves.easeOutBack,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Veri Yenileme Aralığı',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Saha verilerinin ne sıklıkla yenileneceğini seç',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  height: 1.4,
                  color: subtitleColor,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                value: value,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(
                    value: '5 dk',
                    child: Text('5 dk'),
                  ),
                  DropdownMenuItem(
                    value: '15 dk',
                    child: Text('15 dk'),
                  ),
                  DropdownMenuItem(
                    value: '30 dk',
                    child: Text('30 dk'),
                  ),
                  DropdownMenuItem(
                    value: '60 dk',
                    child: Text('60 dk'),
                  ),
                ],
                onChanged: onChanged,
              )
                  .animate(delay: 120.ms)
                  .fadeIn(duration: 260.ms)
                  .slideY(begin: 0.12, end: 0),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoLine extends StatelessWidget {
  final String label;
  final String value;
  final Duration delay;

  const _InfoLine({
    required this.label,
    required this.value,
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark
        ? AppColors.white.withValues(alpha: 0.56)
        : Colors.black.withValues(alpha: 0.5);
    final valueColor = Theme.of(context).textTheme.bodyLarge?.color ??
        (isDark ? AppColors.white : const Color(0xFF0F172A));

    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: labelColor,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ),
      ],
    )
        .animate(delay: delay)
        .fadeIn(duration: 240.ms)
        .slideX(begin: 0.03, end: 0);
  }
}