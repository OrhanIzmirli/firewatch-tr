import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/emergency_call.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/detection_status.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../../nature/fact_widgets.dart';
import '../../../shared/widgets/system_status_line.dart';

/// Whether the map shows [MapStatusCard] instead of the one-line status.
///
/// A problem with the data is always shown. Otherwise the card explains an
/// empty events layer, and only once the events have actually loaded, so it
/// cannot flash while they are on their way. A colour layer has its own note,
/// and the banner counting strong detections already explains the map.
bool shouldShowMapStatusCard({
  required DetectionStatus? status,
  required DateTime now,
  required bool eventsLayerOn,
  required bool eventsLoaded,
  required int visibleEvents,
  required int strongUnverified,
  required bool colorLayerOn,
  required bool dismissed,
}) {
  if (status == null || dismissed || colorLayerOn) return false;
  if (systemFreshness(status, now) != SystemFreshness.fresh) return true;
  return eventsLayerOn && eventsLoaded && visibleEvents == 0 && strongUnverified == 0;
}

/// What the map says when there is nothing to draw, or nothing to vouch for.
///
/// It leads with whether the system is working, and "not detected" is said
/// only about fresh data. It never says there is no fire, and 112 always comes
/// before Report.
class MapStatusCard extends StatelessWidget {
  final DetectionStatus? status;
  final VoidCallback onReport;

  /// Null hides the button: the points layer is already on.
  final VoidCallback? onShowPoints;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final Future<bool> Function()? dial;
  final DateTime? now;

  const MapStatusCard({
    super.key,
    required this.status,
    required this.onReport,
    this.onShowPoints,
    this.onRetry,
    this.onDismiss,
    this.dial,
    this.now,
  });

  Future<void> _call112(BuildContext context, AppLocalizations l10n) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final opened = await (dial ?? openDialer)();
    if (!opened) messenger?.showSnackBar(SnackBar(content: Text(l10n.detectionCall112Line)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final current = now ?? DateTime.now();
    final freshness = systemFreshness(status, current);
    final strong = status?.strongCount ?? 0;
    final other = status?.otherCount ?? 0;

    final String body = switch (freshness) {
      SystemFreshness.fresh => strong > 0 ? l10n.mapStatusStrongBody(strong) : l10n.mapStatusNoneBody,
      SystemFreshness.stale => l10n.detectionStaleBody,
      SystemFreshness.unavailable => l10n.detectionUnavailableBody,
    };

    // The count needs fresh data. With a data problem the button stays, since
    // the points come from another feed; on a quiet day with nothing on
    // farmland there is nothing to send the reader to.
    final countLine = freshness == SystemFreshness.fresh && other > 0 ? l10n.mapStatusOtherLine(other) : null;
    final offerPoints = onShowPoints != null && (freshness != SystemFreshness.fresh || other > 0 || strong > 0);

    final muted = theme.textTheme.bodySmall?.color;
    final title = theme.textTheme.titleLarge?.color;
    final small = GoogleFonts.ibmPlexSans(fontSize: 12.5, height: 1.4, color: muted);
    final solid = theme.brightness == Brightness.dark ? AppColors.surface : AppColors.white;
    final tone = SystemStatusLine.colorFor(freshness, theme.brightness);

    return GlassPanel(
      key: const Key('mapStatusCard'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      // Solid over the map; a problem also tints the whole card.
      color: freshness == SystemFreshness.fresh ? solid : Color.alphaBlend(tone.withValues(alpha: 0.16), solid),
      border: Border.all(color: tone.withValues(alpha: 0.7)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: SystemStatusLine(status: status, now: current)),
              if (onDismiss != null)
                InkWell(
                  key: const Key('mapStatusDismiss'),
                  onTap: onDismiss,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6, bottom: 6),
                    child: Icon(Icons.close_rounded, size: 18, color: muted),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            body,
            key: const Key('mapStatusBody'),
            style: GoogleFonts.ibmPlexSans(fontSize: 14.5, height: 1.35, fontWeight: FontWeight.w700, color: title),
          ),
          const Padding(padding: EdgeInsets.only(top: 6), child: FactLine(place: 'map')),
          if (freshness == SystemFreshness.unavailable && onRetry != null)
            TextButton.icon(
              key: const Key('mapStatusRetry'),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(l10n.commonRetry),
            ),
          if (offerPoints)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Expanded(child: Text(countLine ?? '', key: const Key('mapStatusOtherLine'), style: small)),
                  TextButton(
                    key: const Key('mapStatusShowPoints'),
                    onPressed: onShowPoints,
                    child: Text(l10n.mapStatusShowPoints),
                  ),
                ],
              ),
            ),
          const Divider(height: AppSpacing.xl),
          _ActionRow(
            text: l10n.detectionCall112Line,
            style: GoogleFonts.ibmPlexSans(fontSize: 13, height: 1.35, fontWeight: FontWeight.w700, color: title),
            button: FilledButton.icon(
              key: const Key('mapStatusCall112'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: AppColors.white),
              onPressed: () => _call112(context, l10n),
              icon: const Icon(Icons.call_rounded, size: 18),
              label: Text(l10n.emergencyCall112),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ActionRow(
            text: l10n.detectionReportLine,
            style: small,
            button: OutlinedButton(
              key: const Key('mapStatusReport'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.6)),
              ),
              onPressed: onReport,
              child: Text(l10n.detectionReportButton),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Widget button;

  const _ActionRow({required this.text, required this.style, required this.button});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(child: Text(text, style: style)),
          const SizedBox(width: AppSpacing.sm),
          button,
        ],
      );
}
