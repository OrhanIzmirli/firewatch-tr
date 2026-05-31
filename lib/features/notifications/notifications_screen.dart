import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../models/fire_point.dart';
import '../../services/fire_api_service.dart';
import '../../services/fire_mapper.dart';
import '../../services/fire_monitoring_service.dart';
import '../../services/notification_service.dart';
import '../../shared/widgets/glass_panel.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/status_chip.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isBusy = false;
  bool _permissionGranted = false;
  bool _fireLoading = true;

  List<FirePoint> _highRiskFires = [];
  List<FirePoint> _allFires = [];

  final FireApiService _fireApiService = FireApiService();
  FireMonitoringService get _monitor => FireMonitoringService.instance;

  @override
  void initState() {
    super.initState();
    _loadFires();
  }

  Future<void> _loadFires() async {
    try {
      final fires = await _fireApiService.fetchTurkeyFires();
      if (mounted) setState(() {
        _allFires = fires;
        _highRiskFires = fires
            .where((p) => p.confidence.toLowerCase() == 'high' || p.confidence.toLowerCase() == 'h')
            .take(10)
            .toList();
        _fireLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _fireLoading = false);
    }
  }

  String _timeAgo(String acqDate, String acqTime) {
    try {
      final timeStr = acqTime.padLeft(4, '0');
      final hour = int.parse(timeStr.substring(0, 2));
      final minute = int.parse(timeStr.substring(2, 4));
      final dateParts = acqDate.split('-');
      if (dateParts.length != 3) return acqDate;
      final dt = DateTime.utc(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
        hour, minute,
      );
      final diff = DateTime.now().toUtc().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce';
      if (diff.inHours < 24) return '${diff.inHours} saat önce';
      return '${diff.inDays} gün önce';
    } catch (_) {
      return '$acqDate $acqTime';
    }
  }

  Future<void> _requestNotificationPermission() async {
    setState(() => _isBusy = true);
    final granted = await NotificationService.instance.requestPermission();
    if (!mounted) return;
    setState(() { _permissionGranted = granted; _isBusy = false; });
  }

  Future<void> _sendTestNotification() async {
    setState(() => _isBusy = true);
    await NotificationService.instance.showTestNotification();
    if (!mounted) return;
    setState(() => _isBusy = false);
  }

  Future<void> _sendDemoFireNotification() async {
    setState(() => _isBusy = true);
    if (_highRiskFires.isNotEmpty) {
      final fire = _highRiskFires.first;
      await NotificationService.instance.showFireEventAlert(
        fireId: '${fire.latitude}_${fire.longitude}',
        title: 'Kritik Yangın Uyarısı',
        body: '${fire.regionName} bölgesinde yüksek riskli termal aktivite tespit edildi.',
      );
    } else {
      await NotificationService.instance.showTestNotification();
    }
    if (!mounted) return;
    setState(() => _isBusy = false);
  }

  Future<void> _checkNearbyFireRisk() async {
    setState(() => _isBusy = true);
    await _monitor.checkNow(triggerNotification: true);
    if (!mounted) return;
    setState(() => _isBusy = false);
  }

  Future<void> _startAutoMonitoring() async {
    setState(() => _isBusy = true);
    await _monitor.startMonitoring();
    if (!mounted) return;
    setState(() => _isBusy = false);
  }

  Future<void> _stopAutoMonitoring() async {
    setState(() => _isBusy = true);
    await _monitor.stopMonitoring();
    if (!mounted) return;
    setState(() => _isBusy = false);
  }

  Color _riskColor(String level) {
    switch (level) {
      case 'Yüksek': return AppColors.danger;
      case 'Orta': return AppColors.warning;
      default: return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final titleColor = theme.textTheme.titleLarge?.color ??
        (isDark ? AppColors.white : const Color(0xFF0F172A));
    final secondaryTextColor = isDark
        ? AppColors.white.withValues(alpha: 0.74)
        : Colors.black.withValues(alpha: 0.64);

    return Scaffold(
      appBar: AppBar(
        title: Text('Bildirimler', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _loadFires),
        ],
      ),
      body: ValueListenableBuilder<String>(
        valueListenable: _monitor.statusNotifier,
        builder: (context, statusText, _) {
          return ValueListenableBuilder<bool>(
            valueListenable: _monitor.isRunningNotifier,
            builder: (context, isRunning, _) {
              return ValueListenableBuilder<List<FirePoint>>(
                valueListenable: _monitor.nearbyMatchesNotifier,
                builder: (context, nearbyMatches, _) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Header ───────────────────────────────
                        GlassPanel(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              StatusChip(
                                label: _highRiskFires.isNotEmpty
                                    ? '${_highRiskFires.length} yeni uyarı'
                                    : 'Güncel',
                                icon: Icons.notifications_active_rounded,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Text('Olay Bildirim Akışı',
                                  style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: titleColor)),
                              const SizedBox(height: AppSpacing.sm),
                              Text('Yakındaki olaylar, durum değişimleri ve saha güncellemelerini tek akışta takip et.',
                                  style: GoogleFonts.inter(fontSize: 15, height: 1.45, color: secondaryTextColor)),
                            ],
                          ),
                        ).animate().fadeIn(duration: 450.ms).slideY(begin: 0.06, end: 0),

                        const SizedBox(height: AppSpacing.xxl),

                        // ── Bildirim Araçları ─────────────────────
                        const SectionHeader(
                          title: 'Bildirim Araçları',
                          subtitle: 'İzin ver, test et, yangın bildirimi simüle et',
                          icon: Icons.tune_rounded,
                        ),
                        const SizedBox(height: AppSpacing.md),

                        GlassPanel(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  StatusChip(
                                    label: _permissionGranted ? 'İzin Var' : 'İzin Yok',
                                    icon: _permissionGranted ? Icons.check_circle_rounded : Icons.block_rounded,
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  StatusChip(
                                    label: isRunning ? 'Takip Açık' : 'Takip Kapalı',
                                    icon: isRunning ? Icons.radar_rounded : Icons.pause_circle_outline_rounded,
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(statusText, style: GoogleFonts.inter(fontSize: 13, color: secondaryTextColor)),
                              const SizedBox(height: AppSpacing.lg),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: _isBusy ? null : _requestNotificationPermission,
                                  icon: const Icon(Icons.notifications_active_rounded),
                                  label: const Text('Bildirim İzni İste'),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: _isBusy ? null : _sendTestNotification,
                                  icon: const Icon(Icons.bolt_rounded),
                                  label: const Text('Test Bildirimi Gönder'),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: _isBusy ? null : _sendDemoFireNotification,
                                  icon: const Icon(Icons.local_fire_department_rounded),
                                  label: const Text('Demo Yangın Bildirimi Gönder'),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: _isBusy ? null : _checkNearbyFireRisk,
                                  icon: const Icon(Icons.near_me_rounded),
                                  label: const Text('Şimdi Tara'),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: _isBusy || isRunning ? null : _startAutoMonitoring,
                                  icon: const Icon(Icons.play_arrow_rounded),
                                  label: const Text('Otomatik Taramayı Başlat'),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: _isBusy || !isRunning ? null : _stopAutoMonitoring,
                                  icon: const Icon(Icons.stop_circle_rounded),
                                  label: const Text('Otomatik Taramayı Durdur'),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 320.ms, delay: 90.ms).slideY(begin: 0.08, end: 0),

                        // ── Yakındaki Canlı Yangınlar ─────────────
                        if (nearbyMatches.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.xxl),
                          const SectionHeader(
                            title: 'Yakındaki Canlı Yangınlar',
                            subtitle: 'Konumuna 50 km içinde bulunan noktalar',
                            icon: Icons.local_fire_department_rounded,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          ...nearbyMatches.asMap().entries.map((entry) {
                            final index = entry.key;
                            final fire = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.md),
                              child: GlassPanel(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 46, height: 46,
                                      decoration: BoxDecoration(
                                        color: AppColors.danger.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(Icons.local_fire_department_rounded, color: AppColors.danger),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(fire.regionName,
                                              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: titleColor)),
                                          const SizedBox(height: 4),
                                          Text('${fire.distanceKm?.toStringAsFixed(1) ?? '-'} km uzaklıkta • ${_timeAgo(fire.acquisitionDate, fire.acquisitionTime)}',
                                              style: GoogleFonts.inter(fontSize: 12, color: secondaryTextColor)),
                                          const SizedBox(height: 4),
                                          Text('Risk: ${fire.riskLevel}',
                                              style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w700)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ).animate().fadeIn(duration: 280.ms, delay: (120 + (index * 70)).ms).slideX(begin: 0.03, end: 0),
                            );
                          }),
                        ],

                        const SizedBox(height: AppSpacing.xxl),

                        // ── NASA FIRMS Yüksek Risk Uyarıları ─────
                        SectionHeader(
                          title: 'Son Uyarılar',
                          subtitle: _fireLoading ? 'Yükleniyor...' : '${_highRiskFires.length} yüksek riskli nokta',
                          icon: Icons.bolt_rounded,
                          trailing: _highRiskFires.isNotEmpty
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
                                  ),
                                  child: Text(
                                    '${_highRiskFires.length} okunmadı',
                                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: AppSpacing.md),

                        if (_fireLoading)
                          const Center(child: CircularProgressIndicator(color: AppColors.primary))
                        else if (_highRiskFires.isEmpty)
                          GlassPanel(
                            child: Text('Şu an yüksek riskli yangın noktası bulunmuyor.',
                                style: GoogleFonts.inter(fontSize: 14, color: secondaryTextColor)),
                          )
                        else
                          ..._highRiskFires.asMap().entries.map((entry) {
                            final index = entry.key;
                            final fire = entry.value;
                            final timeAgo = _timeAgo(fire.acquisitionDate, fire.acquisitionTime);
                            final bright = double.tryParse(fire.brightness) ?? 0;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.md),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => context.push('/fire-detail', extra: convertPointToFireEvent(fire)),
                                  borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius),
                                  child: GlassPanel(
                                    padding: const EdgeInsets.all(AppSpacing.lg),
                                    border: Border.all(
                                      color: AppColors.primary.withValues(alpha: 0.24),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 46, height: 46,
                                          decoration: BoxDecoration(
                                            color: AppColors.danger.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          child: const Icon(Icons.local_fire_department_rounded, color: AppColors.danger, size: 22),
                                        ),
                                        const SizedBox(width: AppSpacing.md),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      'Yüksek Riskli Termal Tespit',
                                                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800),
                                                    ),
                                                  ),
                                                  Container(
                                                    width: 10, height: 10,
                                                    margin: const EdgeInsets.only(top: 4),
                                                    decoration: const BoxDecoration(
                                                      color: AppColors.danger,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: AppSpacing.sm),
                                              Text(
                                                '${fire.regionName} bölgesinde ${bright.toStringAsFixed(0)}K ısı tespit edildi. Aktif yangın ihtimali yüksek.',
                                                style: GoogleFonts.inter(fontSize: 13, height: 1.42, color: secondaryTextColor),
                                              ),
                                              const SizedBox(height: AppSpacing.md),
                                              Row(
                                                children: [
                                                  const StatusChip(label: 'Yüksek', icon: Icons.warning_amber_rounded),
                                                  const SizedBox(width: AppSpacing.sm),
                                                  Expanded(
                                                    child: Text(
                                                      '$timeAgo • ${fire.satellite}',
                                                      textAlign: TextAlign.right,
                                                      style: GoogleFonts.inter(fontSize: 12,
                                                          color: isDark
                                                              ? AppColors.white.withValues(alpha: 0.5)
                                                              : Colors.black.withValues(alpha: 0.45)),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        Icon(Icons.arrow_forward_ios_rounded, size: 15,
                                            color: isDark
                                                ? AppColors.white.withValues(alpha: 0.42)
                                                : Colors.black.withValues(alpha: 0.32)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ).animate()
                                .fadeIn(duration: 300.ms, delay: (180 + (index * 60)).ms)
                                .slideX(begin: 0.03, end: 0)
                                .scale(begin: const Offset(0.98, 0.98), end: const Offset(1, 1));
                          }),

                        const SizedBox(height: 110),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}