import 'package:flutter/foundation.dart';
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
  final alreadySeen = prefs.getBool(prefsKey) ?? false;
  if (kDebugMode) debugPrint('[CoachMarks] "$prefsKey" alreadySeen=$alreadySeen');
  if (alreadySeen) return;
  if (!context.mounted) return;
  if (steps.isEmpty) return;

  // Mark as seen immediately, BEFORE the overlay is even inserted — not
  // after the user finishes/skips it. Screens in this app get fully
  // disposed and recreated on every tab switch (MainShellScreen swaps
  // widget types in a single slot rather than using an IndexedStack), so
  // initState — and therefore this function — reruns on every visit. If
  // the flag were only written on completion, a mid-tour tab switch would
  // abandon the overlay without ever persisting "seen", and the tour would
  // reappear on the next visit even though the user already saw it once.
  await prefs.setBool(prefsKey, true);
  if (!context.mounted) return;
  if (kDebugMode) debugPrint('[CoachMarks] "$prefsKey" marked as seen, showing tour now (${steps.length} steps)');

  final l10n = AppLocalizations.of(context)!;
  final overlay = Overlay.of(context, rootOverlay: true);
  late OverlayEntry entry;
  int index = 0;
  var closed = false;

  void finish() {
    if (closed) return;
    closed = true;
    entry.remove();
  }

  /// Advances [index] to [newIndex], skipping forward past any step whose
  /// target isn't currently laid out (so the tour can never get stuck on a
  /// missing element), then scrolls that target into view if it's inside a
  /// scrollable ancestor. Returns false when there's no valid step left —
  /// callers should close the tour in that case rather than show anything.
  Future<bool> prepareStep(int newIndex) async {
    index = newIndex;
    while (index < steps.length && steps[index].targetKey.currentContext == null) {
      index++;
    }
    if (index >= steps.length) return false;

    final targetContext = steps[index].targetKey.currentContext;
    if (targetContext != null) {
      try {
        await Scrollable.ensureVisible(
          targetContext,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          alignment: 0.5,
        );
      } catch (_) {
        // No scrollable ancestor, already visible, or the context died
        // mid-animation (screen navigated away) — any of these are fine,
        // the tour just proceeds with whatever position is available.
      }
    }
    return true;
  }

  Future<void> goToStep(int newIndex) async {
    if (closed) return;
    final ok = await prepareStep(newIndex);
    if (closed) return;
    if (!ok) {
      finish();
      return;
    }
    entry.markNeedsBuild();
  }

  final hasFirstStep = await prepareStep(0);
  if (!hasFirstStep) return;
  if (!context.mounted) return;

  entry = OverlayEntry(
    builder: (overlayContext) {
      // Defensive fallback only — goToStep()/prepareStep() already keep
      // index pointing at a valid, laid-out step. If we still land here
      // (e.g. the target was disposed between frames), close immediately
      // rather than ever crash or hang on a broken frame.
      if (index >= steps.length || steps[index].targetKey.currentContext == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => finish());
        return const SizedBox.shrink();
      }

      final step = steps[index];
      final isLastStep = index == steps.length - 1;
      final renderBox = step.targetKey.currentContext!.findRenderObject() as RenderBox;
      final targetSize = renderBox.size;
      final targetPosition = renderBox.localToGlobal(Offset.zero);
      final targetRect = (targetPosition & targetSize).inflate(8);
      final screenSize = MediaQuery.of(overlayContext).size;
      // System status bar / notch / home-indicator insets — the card must
      // never render behind these, or its buttons become untappable.
      final safePadding = MediaQuery.of(overlayContext).padding;
      final isDark = Theme.of(overlayContext).brightness == Brightness.dark;

      const cardMargin = AppSpacing.md;
      final safeTop = safePadding.top + cardMargin;
      final safeBottom = screenSize.height - safePadding.bottom - cardMargin;

      // Pick whichever side of the target actually has more room, rather
      // than just going by which half of the screen the target's center
      // falls in — a target taller than ~half the viewport (e.g. a chart,
      // after auto-scrolling it into view) can otherwise leave "the other
      // half" too cramped for the card, pushing it up past the safe area
      // and behind the status bar.
      final spaceAbove = (targetRect.top - safeTop - cardMargin).clamp(0.0, double.infinity);
      final spaceBelow = (safeBottom - targetRect.bottom - cardMargin).clamp(0.0, double.infinity);
      final showCardBelow = spaceBelow >= spaceAbove;
      final availableSpace = showCardBelow ? spaceBelow : spaceAbove;
      // Cap how tall the card can grow even when there's plenty of room, and
      // guarantee a usable minimum even when there's very little — in that
      // extreme case it may brush the safe edge, but that reads far better
      // than being unreadable.
      final cardHeight = availableSpace.clamp(120.0, screenSize.height * 0.42);

      double? top;
      double? bottom;
      if (showCardBelow) {
        final maxTop = safeBottom - cardHeight;
        top = (targetRect.bottom + cardMargin).clamp(safeTop, maxTop < safeTop ? safeTop : maxTop);
      } else {
        final maxBottom = screenSize.height - safeTop - cardHeight;
        bottom = (screenSize.height - targetRect.top + cardMargin)
            .clamp(cardMargin, maxBottom < cardMargin ? cardMargin : maxBottom);
      }

      return Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              // Tapping the dark scrim advances the tour — except on the
              // last step, where it closes it (there's nowhere left to
              // advance to).
              onTap: () {
                if (isLastStep) {
                  finish();
                } else {
                  goToStep(index + 1);
                }
              },
              child: CustomPaint(
                painter: _SpotlightPainter(rect: targetRect),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: top,
            bottom: bottom,
            child: SafeArea(
              child: Material(
                color: Colors.transparent,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: cardHeight),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surface : Colors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8)),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {}, // swallow taps on the card itself so it doesn't advance/dismiss
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  l10n.coachMarksStepCount(index + 1, steps.length),
                                  style: GoogleFonts.ibmPlexSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  step.title,
                                  style: GoogleFonts.ibmPlexSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? AppColors.white : AppColors.lightText,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  step.description,
                                  style: GoogleFonts.ibmPlexSans(
                                    fontSize: 14,
                                    height: 1.45,
                                    color: isDark ? AppColors.white.withValues(alpha: 0.78) : Colors.black.withValues(alpha: 0.68),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                height: 48,
                                child: TextButton(
                                  onPressed: finish,
                                  child: Text(l10n.coachMarksSkip, style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600)),
                                ),
                              ),
                              SizedBox(
                                height: 48,
                                child: FilledButton(
                                  onPressed: () => goToStep(index + 1),
                                  child: Text(isLastStep ? l10n.coachMarksGotIt : l10n.coachMarksNext),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
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
    final holePath = Path()..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(AppSpacing.largeCardRadius)));
    final combined = Path.combine(PathOperation.difference, overlayPath, holePath);

    canvas.drawPath(combined, Paint()..color = Colors.black.withValues(alpha: 0.68));
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(AppSpacing.largeCardRadius)),
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) => oldDelegate.rect != rect;
}
