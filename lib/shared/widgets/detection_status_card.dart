import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/utils/emergency_call.dart';
import '../../l10n/app_localizations.dart';
import '../../models/detection_status.dart';
import 'glass_panel.dart';

String _clock(DateTime t, DateTime now) {
  String two(int n) => n.toString().padLeft(2, '0');
  final time = '${two(t.hour)}:${two(t.minute)}';
  final sameDay = t.year == now.year && t.month == now.month && t.day == now.day;
  return sameDay ? time : '${two(t.day)}.${two(t.month)} $time';
}

String? _latestLine(AppLocalizations l10n, DetectionStatus status, DateTime now) {
  final at = status.latestDetectionAt;
  if (at == null) return null;
  final age = now.difference(at);
  final when = age.inDays >= 1
      ? l10n.detectionDaysAgo(age.inDays)
      : age.inHours >= 1
          ? l10n.detectionHoursAgo(age.inHours)
          : l10n.detectionJustNow;
  final city = status.latestDetectionCity;
  return city == null ? l10n.detectionLatestNoCity(when) : l10n.detectionLatest(when, city);
}

/// One line that is always visible when the card is not: how new the data is.
class DetectionFreshnessLine extends StatelessWidget {
  final DetectionStatus status;
  final DateTime? now;

  const DetectionFreshnessLine({super.key, required this.status, this.now});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final at = status.lastUpdateAt;
    final current = now ?? DateTime.now();
    final problem = status.kind == DetectionStatusKind.stale || status.kind == DetectionStatusKind.unavailable;
    final String text = switch (status.kind) {
      DetectionStatusKind.unavailable => l10n.detectionUnavailableTitle,
      DetectionStatusKind.stale => at == null
          ? l10n.detectionStaleTitle
          : '${l10n.detectionStaleTitle} ${l10n.detectionLastUpdate(_clock(at, current))}',
      _ => at == null ? l10n.detectionStaleTitle : l10n.detectionLastUpdate(_clock(at, current)),
    };
    final color = problem ? AppColors.warning : Theme.of(context).textTheme.bodySmall?.color;
    return Row(
      key: const Key('detectionFreshness'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(problem ? Icons.warning_amber_rounded : Icons.schedule_rounded, size: 14, color: color),
        const SizedBox(width: 5),
        Flexible(
          child: Text(text,
              style: GoogleFonts.ibmPlexSans(
                  fontSize: 12, fontWeight: problem ? FontWeight.w700 : FontWeight.w500, color: color)),
        ),
      ],
    );
  }
}

/// The card shown when there is nothing to list, or nothing we can vouch for.
/// It never says there is no fire, and 112 always comes before Report.
class DetectionStatusCard extends StatelessWidget {
  final DetectionStatus status;
  final VoidCallback onReport;
  final VoidCallback? onShowLast7Days;
  final VoidCallback? onOpenRisk;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final Future<bool> Function()? dial;
  final DateTime? now;

  const DetectionStatusCard({
    super.key,
    required this.status,
    required this.onReport,
    this.onShowLast7Days,
    this.onOpenRisk,
    this.onRetry,
    this.onDismiss,
    this.dial,
    this.now,
  });

  Future<void> _call112(BuildContext context, AppLocalizations l10n) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final opened = await (dial ?? openDialer)();
    if (!opened) {
      messenger?.showSnackBar(SnackBar(content: Text(l10n.detectionCall112Line)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final title = theme.textTheme.titleLarge?.color;
    final muted = theme.textTheme.bodySmall?.color;
    final current = now ?? DateTime.now();
    final at = status.lastUpdateAt;
    final updated = at == null ? null : l10n.detectionLastUpdate(_clock(at, current));
    final latest = _latestLine(l10n, status, current);

    final String heading;
    final String body;
    switch (status.kind) {
      case DetectionStatusKind.unavailable:
        heading = l10n.detectionUnavailableTitle;
        body = l10n.detectionUnavailableBody;
      case DetectionStatusKind.stale:
        heading = l10n.detectionStaleTitle;
        body = [?updated, l10n.detectionStaleBody].join(' · ');
      case DetectionStatusKind.none:
      case DetectionStatusKind.strong:
        heading = l10n.detectionNoneTitle;
        body = [?updated, l10n.detectionLimitNote].join(' · ');
    }
    final small = GoogleFonts.ibmPlexSans(fontSize: 12.5, height: 1.4, color: muted);
    final problem = status.kind == DetectionStatusKind.stale || status.kind == DetectionStatusKind.unavailable;

    final buttonStyle = OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.6)),
    );

    return GlassPanel(
      key: const Key('detectionStatusCard'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      // Solid: over the map, translucent text is unreadable.
      color: theme.brightness == Brightness.dark ? AppColors.surface : AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(problem ? Icons.warning_amber_rounded : Icons.satellite_alt_rounded,
                  size: 20, color: problem ? AppColors.warning : AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(heading,
                    style: GoogleFonts.ibmPlexSans(fontSize: 14.5, height: 1.35, fontWeight: FontWeight.w700, color: title)),
              ),
              if (onDismiss != null)
                InkWell(
                  key: const Key('detectionDismiss'),
                  onTap: onDismiss,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6, bottom: 6),
                    child: Icon(Icons.close_rounded, size: 18, color: muted),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(body, style: small),
          if (latest != null) ...[
            const SizedBox(height: 4),
            Text(latest, key: const Key('detectionLatest'), style: small),
          ],
          if (status.kind == DetectionStatusKind.unavailable && onRetry != null)
            TextButton.icon(
              key: const Key('detectionRetry'),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(l10n.commonRetry),
            ),
          if (onShowLast7Days != null || onOpenRisk != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: 4,
              children: [
                if (onShowLast7Days != null)
                  OutlinedButton(
                    key: const Key('detectionLast7Days'),
                    style: buttonStyle,
                    onPressed: onShowLast7Days,
                    child: Text(l10n.detectionShowLast7Days),
                  ),
                if (onOpenRisk != null)
                  OutlinedButton.icon(
                    key: const Key('detectionOpenRisk'),
                    style: buttonStyle,
                    onPressed: onOpenRisk,
                    icon: const Icon(Icons.thermostat_rounded, size: 18),
                    label: Text(l10n.detectionOpenRisk),
                  ),
              ],
            ),
            if (onOpenRisk != null) ...[
              const SizedBox(height: 4),
              Text(l10n.riskColorsNotFire, style: small),
            ],
          ],
          const Divider(height: AppSpacing.xl),
          _ActionRow(
            text: l10n.detectionCall112Line,
            button: FilledButton.icon(
              key: const Key('detectionCall112'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: AppColors.white),
              onPressed: () => _call112(context, l10n),
              icon: const Icon(Icons.call_rounded, size: 18),
              label: Text(l10n.emergencyCall112),
            ),
            style: GoogleFonts.ibmPlexSans(fontSize: 13, height: 1.35, fontWeight: FontWeight.w700, color: title),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ActionRow(
            text: l10n.detectionReportLine,
            button: OutlinedButton(
              key: const Key('detectionReport'),
              style: buttonStyle,
              onPressed: onReport,
              child: Text(l10n.detectionReportButton),
            ),
            style: small,
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final String text;
  final Widget button;
  final TextStyle style;

  const _ActionRow({required this.text, required this.button, required this.style});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(child: Text(text, style: style)),
          const SizedBox(width: AppSpacing.sm),
          button,
        ],
      );
}
