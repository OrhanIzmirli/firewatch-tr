import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../l10n/app_localizations.dart';
import '../coach_mark_keys.dart';

class CoachMarkStep {
  final GlobalKey targetKey;
  final String title;
  final String description;

  const CoachMarkStep({
    required this.targetKey,
    required this.title,
    required this.description,
  });
}

const String _seenPrefsKey = 'hasSeenCoachMarks';

/// Shows the first-launch coach mark tour (Home tab + bottom nav) if it
/// hasn't been seen yet. Safe to call every time MainShellScreen mounts —
/// it's a no-op after the first successful (or skipped) run.
Future<void> maybeShowCoachMarks(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final steps = [
    CoachMarkStep(
      targetKey: CoachMarkKeys.mapNavIcon,
      title: l10n.coachMarkMapTitle,
      description: l10n.coachMarkMapDesc,
    ),
    CoachMarkStep(
      targetKey: CoachMarkKeys.riskButton,
      title: l10n.coachMarkRiskTitle,
      description: l10n.coachMarkRiskDesc,
    ),
    CoachMarkStep(
      targetKey: CoachMarkKeys.savedButton,
      title: l10n.coachMarkWatchlistTitle,
      description: l10n.coachMarkWatchlistDesc,
    ),
    CoachMarkStep(
      targetKey: CoachMarkKeys.alertsNavIcon,
      title: l10n.coachMarkNotificationsTitle,
      description: l10n.coachMarkNotificationsDesc,
    ),
  ];

  await maybeShowScreenCoachMarks(context, prefsKey: _seenPrefsKey, steps: steps);
}

/// Generic, reusable first-visit coach mark tour for any screen. Each
/// screen passes its own SharedPreferences key (so tours are tracked
/// independently) and its own steps (GlobalKeys must already be attached
/// to widgets in the current tree and laid out — call this after the
/// first frame, with a short delay if needed).
Future<void> maybeShowScreenCoachMarks(
  BuildContext context, {
  required String prefsKey,
  required List<CoachMarkStep> steps,
}) async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool(prefsKey) ?? false) return;
  if (!context.mounted) return;
  if (steps.isEmpty) return;

  final l10n = AppLocalizations.of(context)!;
  final overlay = Overlay.of(context, rootOverlay: true);
  late OverlayEntry entry;
  int index = 0;

  Future<void> finish() async {
    entry.remove();
    final donePrefs = await SharedPreferences.getInstance();
    await donePrefs.setBool(prefsKey, true);
  }

  void showStep() {
    entry.markNeedsBuild();
  }

  entry = OverlayEntry(
    builder: (overlayContext) {
      // Skip any step whose target isn't currently laid out (defensive —
      // all four should be mounted on the Home tab, but never crash if not).
      while (index < steps.length && steps[index].targetKey.currentContext == null) {
        index++;
      }
      if (index >= steps.length) {
        WidgetsBinding.instance.addPostFrameCallback((_) => finish());
        return const SizedBox.shrink();
      }

      final step = steps[index];
      final renderBox = step.targetKey.currentContext!.findRenderObject() as RenderBox;
      final targetSize = renderBox.size;
      final targetPosition = renderBox.localToGlobal(Offset.zero);
      final targetRect = (targetPosition & targetSize).inflate(8);
      final screenSize = MediaQuery.of(overlayContext).size;
      final isDark = Theme.of(overlayContext).brightness == Brightness.dark;

      final showCardBelow = targetRect.top < screenSize.height * 0.45;

      return Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () {}, // swallow taps outside the card
              child: CustomPaint(
                painter: _SpotlightPainter(rect: targetRect),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: showCardBelow ? targetRect.bottom + AppSpacing.md : null,
            bottom: showCardBelow ? null : screenSize.height - targetRect.top + AppSpacing.md,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surface : Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.coachMarksStepCount(index + 1, steps.length),
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      step.title,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      step.description,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        height: 1.45,
                        color: isDark ? AppColors.white.withValues(alpha: 0.78) : Colors.black.withValues(alpha: 0.68),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: finish,
                          child: Text(l10n.coachMarksSkip, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                        ),
                        FilledButton(
                          onPressed: () {
                            index++;
                            if (index >= steps.length) {
                              finish();
                            } else {
                              showStep();
                            }
                          },
                          child: Text(
                            index == steps.length - 1 ? l10n.coachMarksGotIt : l10n.coachMarksNext,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    },
  );

  overlay.insert(entry);
}

class _SpotlightPainter extends CustomPainter {
  final Rect rect;

  _SpotlightPainter({required this.rect});

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final holePath = Path()..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(16)));
    final combined = Path.combine(PathOperation.difference, overlayPath, holePath);

    canvas.drawPath(combined, Paint()..color = Colors.black.withValues(alpha: 0.68));
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(16)),
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) => oldDelegate.rect != rect;
}
