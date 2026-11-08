import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/app_localizations.dart';
import '../../models/detection_status.dart';

/// How far the satellite data can be trusted right now.
enum SystemFreshness { fresh, stale, unavailable }

/// Older than this, the app no longer says the system is working.
const Duration kSystemStaleAfter = Duration(hours: 2);

/// The one place that decides whether "the system is working" may be said.
///
/// No answer, or a failed request, is [SystemFreshness.unavailable]. Anything
/// that cannot prove recent data is [SystemFreshness.stale]: the backend calling
/// its pipeline stale, a missing timestamp, or an age over [kSystemStaleAfter].
/// The backend's own limit is looser (6 hours), so the age is checked here too.
/// Exactly two hours old is still fresh.
SystemFreshness systemFreshness(DetectionStatus? status, DateTime now) {
  if (status == null || status.kind == DetectionStatusKind.unavailable) {
    return SystemFreshness.unavailable;
  }
  final at = status.lastUpdateAt;
  if (status.kind == DetectionStatusKind.stale || at == null) return SystemFreshness.stale;
  return now.difference(at) > kSystemStaleAfter ? SystemFreshness.stale : SystemFreshness.fresh;
}

/// HH:MM, with the date in front when it was not today.
String _lastCheck(DateTime at, DateTime now) {
  String two(int n) => n.toString().padLeft(2, '0');
  final t = at.toLocal();
  final n = now.toLocal();
  final time = '${two(t.hour)}:${two(t.minute)}';
  final today = t.year == n.year && t.month == n.month && t.day == n.day;
  return today ? time : '${two(t.day)}.${two(t.month)} $time';
}

/// Green "system working", yellow "out of date" or red "could not be fetched",
/// with the time of the last check whenever there is one.
class SystemStatusLine extends StatelessWidget {
  final DetectionStatus? status;

  /// The clock to judge freshness against; the device clock when null.
  final DateTime? now;

  const SystemStatusLine({super.key, required this.status, this.now});

  /// Text colour with at least 4.5:1 contrast on the app's cards in that theme.
  static Color colorFor(SystemFreshness freshness, Brightness brightness) {
    final dark = brightness == Brightness.dark;
    return switch (freshness) {
      SystemFreshness.fresh => dark ? const Color(0xFF6FCF97) : const Color(0xFF1E7A45),
      SystemFreshness.stale => dark ? const Color(0xFFF2C14E) : const Color(0xFF8A5A00),
      SystemFreshness.unavailable => dark ? const Color(0xFFFF8A80) : const Color(0xFFB3261E),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final current = now ?? DateTime.now();
    final freshness = systemFreshness(status, current);
    final at = status?.lastUpdateAt;
    final String text = switch (freshness) {
      SystemFreshness.fresh => l10n.systemStatusFresh(_lastCheck(at!, current)),
      SystemFreshness.stale => at == null ? l10n.detectionStaleTitle : l10n.systemStatusStale(_lastCheck(at, current)),
      SystemFreshness.unavailable => l10n.detectionUnavailableTitle,
    };
    final color = colorFor(freshness, Theme.of(context).brightness);
    return Row(
      key: const Key('systemStatusLine'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          switch (freshness) {
            SystemFreshness.fresh => Icons.check_circle_rounded,
            SystemFreshness.stale => Icons.warning_amber_rounded,
            SystemFreshness.unavailable => Icons.error_outline_rounded,
          },
          size: 16,
          color: color,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: GoogleFonts.ibmPlexSans(fontSize: 13, height: 1.3, fontWeight: FontWeight.w700, color: color),
          ),
        ),
      ],
    );
  }
}
