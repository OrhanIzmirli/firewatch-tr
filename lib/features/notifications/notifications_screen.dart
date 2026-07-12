import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../l10n/app_localizations.dart';
import '../../models/fire_point.dart';
import '../../services/background_task_service.dart';
import '../../services/fire_api_service.dart';
import '../../services/fire_mapper.dart';
import '../../services/fire_monitoring_service.dart';
import '../../services/notification_service.dart';
import '../../services/offline_cache_service.dart';
import '../../shared/coach_mark_keys.dart';
import '../../shared/widgets/coach_mark_overlay.dart';
import '../../shared/widgets/glass_panel.dart';
import '../../shared/widgets/offline_banner.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/skeleton_loader.dart';
import '../../shared/widgets/status_chip.dart';
import '../../shared/widgets/trust_info_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const _cacheKey = 'notifications_fires';

  bool _isBusy = false;
  bool _permissionGranted = false;
  bool _fireLoading = true;
  bool _isOffline = false;
  DateTime? _cachedAt;

  List<FirePoint> _highRiskFires = [];
  List<FirePoint> _allFires = [];

  final FireApiService _fireApiService = FireApiService();
  FireMonitoringService get _monitor => FireMonitoringService.instance;

  @override
  void initState() {
    super.initState();
    _loadFires().then((_) => _maybeShowNotifCoachMarks());
  }

  void _maybeShowNotifCoachMarks() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      await maybeShowScreenCoachMarks(
        context,
        prefsKey: 'hasSeenNotificationsTour',
        steps: [
          CoachMarkStep(
            targetKey: CoachMarkKeys.notifPermissionButton,
            title: l10n.coachMarkNotifPermissionTitle,
            description: l10n.coachMarkNotifPermissionDesc,
          ),
          CoachMarkStep(
            targetKey: CoachMarkKeys.notifScanButton,
            title: l10n.coachMarkNotifScanTitle,
            description: l10n.coachMarkNotifScanDesc,
          ),
          CoachMarkStep(
            targetKey: CoachMarkKeys.notifMonitoringButton,
            title: l10n.coachMarkNotifMonitoringTitle,
            description: l10n.coachMarkNotifMonitoringDesc,
          ),
          CoachMarkStep(
            targetKey: CoachMarkKeys.notifAlertCards,
            title: l10n.coachMarkNotifAlertsTitle,
            description: l10n.coachMarkNotifAlertsDesc,
          ),
        ],
      );
    });
  }

  Future<void> _loadFires() async {
    if (mounted) setState(() => _fireLoading = true);
    try {
      final fires = await _fireApiService.fetchTurkeyFiresWithCities();
      await OfflineCacheService.instance.save(_cacheKey, fires.map((p) => p.toJson()).toList());
      if (mounted) setState(() {
        _allFires = fires;
        _highRiskFires = fires
            .where((p) => p.confidence.toLowerCase() == 'high' || p.confidence.toLowerCase() == 'h')
            .take(10)
            .toList();
        _fireLoading = false;
        _isOffline = false;
      });
    } catch (_) {
      final cached = await OfflineCacheService.instance.load(_cacheKey);
      if (mounted) {
        setState(() {
          if (cached != null) {
            final (data, savedAt) = cached;
            final fires = (data as List).map((e) => FirePoint.fromJson(e as Map<String, dynamic>)).toList();
            _allFires = fires;
            _highRiskFires = fires
                .where((p) => p.confidence.toLowerCase() == 'high' || p.confidence.toLowerCase() == 'h')
                .take(10)
                .toList();
            _cachedAt = savedAt;
            _isOffline = true;
          }
          _fireLoading = false;
        });
      }
    }
  }

  String _timeAgo(BuildContext context, String acqDate, String acqTime) {
    final l10n = AppLocalizations.of(context)!;
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
      if (diff.inMinutes < 60) return l10n.timeAgoMinutes(diff.inMinutes);
      if (diff.inHours < 24) return l10n.timeAgoHours(diff.inHours);
      return l10n.timeAgoDays(diff.inDays);
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

  Future<void> _checkNearbyFireRisk() async {
    setState(() => _isBusy = true);
    await _monitor.checkNow(triggerNotification: true);
    if (!mounted) return;
    setState(() => _isBusy = false);
  }

  static const _notificationsEnabledKey = 'notifications_enabled';

  /// Single entry point for "Otomatik Taramayı Başlat": requests foreground
  /// location, then (with the required rationale dialog first) background
  /// location, registers the WorkManager periodic task if background was
  /// granted, starts the foreground scan loop regardless, and tells the
  /// backend this device wants alerts — with a fresh position so
  /// region-targeted server pushes have somewhere to match against.
  Future<void> _startAutoMonitoring() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isBusy = true);

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      setState(() => _isBusy = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.monitorStatusLocationDenied)));
      return;
    }
    if (!mounted) return;

    final wantsBackground = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.backgroundLocationDialogTitle),
        content: Text(l10n.backgroundLocationDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.backgroundLocationDialogConfirm),
          ),
        ],
      ),
    );

    var backgroundGranted = false;
    if (wantsBackground == true) {
      final backgroundStatus = await Permission.locationAlways.request();
      backgroundGranted = backgroundStatus.isGranted;
    }

    if (backgroundGranted) {
      await BackgroundTaskService.instance.initialize();
      await BackgroundTaskService.instance.setEnabled(true);
    }

    await _monitor.startMonitoring();

    Position? position;
    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      // Best-effort — subscription still proceeds without a location; the
      // device just won't be eligible for region-targeted server alerts.
    }
    await NotificationService.instance.updateSubscription(
      active: true,
      latitude: position?.latitude,
      longitude: position?.longitude,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, true);

    if (!mounted) return;
    setState(() => _isBusy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          backgroundGranted
              ? l10n.backgroundMonitoringEnabled
              : l10n.monitorStatusStarted,
        ),
      ),
    );
  }

  Future<void> _stopAutoMonitoring() async {
    setState(() => _isBusy = true);

    await _monitor.stopMonitoring();
    await BackgroundTaskService.instance.stop();
    await BackgroundTaskService.instance.setEnabled(false);
    await NotificationService.instance.updateSubscription(active: false);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, false);

    if (!mounted) return;
    setState(() => _isBusy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final titleColor = theme.textTheme.titleLarge?.color ??
        (isDark ? AppColors.white : const Color(0xFF0F172A));
    final secondaryTextColor = isDark
        ? AppColors.white.withValues(alpha: 0.74)
        : Colors.black.withValues(alpha: 0.64);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationsTitle, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
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
                  return RefreshIndicator(
                    onRefresh: _loadFires,
                    color: AppColors.primary,
                    child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_isOffline && _cachedAt != null) OfflineBanner(lastUpdated: _cachedAt!),
                        // ── Header ───────────────────────────────
                        GlassPanel(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              StatusChip(
                                label: _highRiskFires.isNotEmpty
                                    ? l10n.notificationsNewAlerts(_highRiskFires.length)
                                    : l10n.notificationsUpToDate,
                                icon: Icons.notifications_active_rounded,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Text(l10n.notificationsFeedTitle,
                                  style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: titleColor)),
                              const SizedBox(height: AppSpacing.sm),
                              Text(l10n.notificationsFeedSubtitle,
                                  style: GoogleFonts.inter(fontSize: 15, height: 1.45, color: secondaryTextColor)),
                            ],
                          ),
                        ).animate().fadeIn(duration: 450.ms).slideY(begin: 0.06, end: 0),

                        const SizedBox(height: AppSpacing.md),
                        TrustInfoCardGroup(
                          meaning: l10n.trustAlertsMeaning,
                          source: l10n.trustAlertsSource,
                          interpret: l10n.trustAlertsInterpret,
                          action: l10n.trustAlertsAction,
                        ),

                        const SizedBox(height: AppSpacing.xxl),

                        // ── Bildirim Araçları ─────────────────────
                        SectionHeader(
                          title: l10n.notificationsTools,
                          subtitle: l10n.notificationsToolsSubtitle,
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
                                    label: _permissionGranted ? l10n.notificationsPermissionGranted : l10n.notificationsPermissionDenied,
                                    icon: _permissionGranted ? Icons.check_circle_rounded : Icons.block_rounded,
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  StatusChip(
                                    label: isRunning ? l10n.notificationsMonitoringOn : l10n.notificationsMonitoringOff,
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
                                  key: CoachMarkKeys.notifPermissionButton,
                                  onPressed: _isBusy ? null : _requestNotificationPermission,
                                  icon: const Icon(Icons.notifications_active_rounded),
                                  label: Text(l10n.notificationsRequestPermission),
                                ),
                              ),
                              if (kDebugMode) ...[
                              const SizedBox(height: AppSpacing.md),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: _isBusy ? null : _sendTestNotification,
                                  icon: const Icon(Icons.bolt_rounded),
                                  label: Text(l10n.notificationsSendTest),
                                ),
                              ),
                              ],
                              const SizedBox(height: AppSpacing.md),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  key: CoachMarkKeys.notifScanButton,
                                  onPressed: _isBusy ? null : _checkNearbyFireRisk,
                                  icon: const Icon(Icons.near_me_rounded),
                                  label: Text(l10n.notificationsScanNow),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  key: CoachMarkKeys.notifMonitoringButton,
                                  onPressed: _isBusy || isRunning ? null : _startAutoMonitoring,
                                  icon: const Icon(Icons.play_arrow_rounded),
                                  label: Text(l10n.notificationsStartMonitoring),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: _isBusy || !isRunning ? null : _stopAutoMonitoring,
                                  icon: const Icon(Icons.stop_circle_rounded),
                                  label: Text(l10n.notificationsStopMonitoring),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 320.ms, delay: 90.ms).slideY(begin: 0.08, end: 0),

                        // ── Yakındaki Canlı Yangınlar ─────────────
                        if (nearbyMatches.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.xxl),
                          SectionHeader(
                            title: l10n.notificationsNearbyLiveFires,
                            subtitle: l10n.notificationsNearbyLiveFiresSubtitle,
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
                                          Text(fire.regionDisplayName(l10n),
                                              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: titleColor)),
                                          const SizedBox(height: 4),
                                          Text(l10n.notificationsDistanceAndTime(fire.distanceKm?.toStringAsFixed(1) ?? '-', _timeAgo(context, fire.acquisitionDate, fire.acquisitionTime)),
                                              style: GoogleFonts.inter(fontSize: 12, color: secondaryTextColor)),
                                          const SizedBox(height: 6),
                                          Text(fire.riskReasonText(l10n),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.inter(fontSize: 12, color: secondaryTextColor)),
                                          const SizedBox(height: 4),
                                          Wrap(
                                            spacing: AppSpacing.xs,
                                            runSpacing: AppSpacing.xs,
                                            crossAxisAlignment: WrapCrossAlignment.center,
                                            children: [
                                              Text(l10n.notificationsRiskLabel(fire.riskLevelLabel(l10n)),
                                                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w700)),
                                              StatusChip(
                                                label: '${fireStatusEmoji(fire.smartStatus)} ${fireStatusLabel(l10n, fire.smartStatus)}',
                                                color: fireStatusColor(fire.smartStatus),
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              ),
                                            ],
                                          ),
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
                          key: CoachMarkKeys.notifAlertCards,
                          title: l10n.notificationsRecentAlerts,
                          subtitle: _fireLoading ? l10n.commonLoading : l10n.notificationsHighRiskCount(_highRiskFires.length),
                          icon: Icons.bolt_rounded,
                          trailing: _highRiskFires.isNotEmpty
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
                                  ),
                                  child: Text(
                                    l10n.notificationsUnreadCount(_highRiskFires.length),
                                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: AppSpacing.md),

                        if (_fireLoading)
                          const SkeletonListLoader(count: 3)
                        else if (_highRiskFires.isEmpty)
                          GlassPanel(
                            child: Text(l10n.notificationsNoHighRisk,
                                style: GoogleFonts.inter(fontSize: 14, color: secondaryTextColor)),
                          )
                        else
                          ..._highRiskFires.asMap().entries.map((entry) {
                            final index = entry.key;
                            final fire = entry.value;
                            final timeAgo = _timeAgo(context, fire.acquisitionDate, fire.acquisitionTime);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.md),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => context.push('/fire-detail', extra: convertPointToFireEvent(fire, l10n)),
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
                                                      fire.detectionTitle(l10n),
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
                                                fire.riskReasonText(l10n),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.inter(fontSize: 13, height: 1.42, color: secondaryTextColor),
                                              ),
                                              const SizedBox(height: AppSpacing.md),
                                              Wrap(
                                                spacing: AppSpacing.sm,
                                                runSpacing: AppSpacing.xs,
                                                crossAxisAlignment: WrapCrossAlignment.center,
                                                children: [
                                                  StatusChip(label: fire.detectionTitle(l10n), icon: Icons.satellite_alt_rounded, color: fire.detectionColor),
                                                  StatusChip(
                                                    label: '${fireStatusEmoji(fire.smartStatus)} ${fireStatusLabel(l10n, fire.smartStatus)}',
                                                    color: fireStatusColor(fire.smartStatus),
                                                  ),
                                                  Text(
                                                    '$timeAgo • ${fire.mergedSatelliteLabel}',
                                                    style: GoogleFonts.inter(fontSize: 12,
                                                        color: isDark
                                                            ? AppColors.white.withValues(alpha: 0.5)
                                                            : Colors.black.withValues(alpha: 0.45)),
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
