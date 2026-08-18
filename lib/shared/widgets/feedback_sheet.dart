import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';
import '../../l10n/app_localizations.dart';
import '../../services/feedback_rate_limiter.dart';
import '../../services/feedback_service.dart';

void _showBlocked(BuildContext context, AppLocalizations l10n, int days) {
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(l10n.feedbackBlockedMessage(days))));
}

/// General feedback: star rating + General/Feature category. Bug reports
/// have their own simplified entry point below — see [showBugReportSheet].
Future<void> showFeedbackSheet(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final blockedDays = await FeedbackRateLimiter.instance.feedbackBlockedDays(
    'general',
  );
  if (blockedDays != null) {
    if (context.mounted) _showBlocked(context, l10n, blockedDays);
    return;
  }
  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const _FeedbackSheet(),
  );
}

Future<void> showBugReportSheet(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final blockedDays = await FeedbackRateLimiter.instance.bugReportBlockedDays();
  if (blockedDays != null) {
    if (context.mounted) _showBlocked(context, l10n, blockedDays);
    return;
  }
  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const _BugReportSheet(),
  );
}

class _FeedbackSheet extends StatefulWidget {
  const _FeedbackSheet();
  @override
  State<_FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<_FeedbackSheet> {
  int rating = 0;
  String category = 'general';
  bool sending = false;
  final message = TextEditingController();
  final email = TextEditingController();

  @override
  void dispose() {
    message.dispose();
    email.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (rating < 1) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.feedbackRatingRequired)));
      return;
    }
    if (message.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.feedbackMessageRequired)));
      return;
    }
    // Re-check the actually-selected category — the entry-point check only
    // covered the default 'general' category, and the user may have
    // switched to 'feature' (a different cooldown) inside the form.
    final blockedDays = await FeedbackRateLimiter.instance.feedbackBlockedDays(
      category,
    );
    if (blockedDays != null) {
      if (mounted) _showBlocked(context, l10n, blockedDays);
      return;
    }
    setState(() => sending = true);
    try {
      await FeedbackService().submit(
        rating: rating,
        category: category,
        message: message.text,
        email: email.text,
      );
      await FeedbackRateLimiter.instance.recordFeedback(category);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.feedbackSuccess)));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.feedbackError)));
      }
    } finally {
      if (mounted) {
        setState(() => sending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.feedbackTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 18),
            Text(l10n.feedbackRating),
            Row(
              children: List.generate(
                5,
                (i) => IconButton(
                  onPressed: () => setState(() => rating = i + 1),
                  icon: Icon(
                    i < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                ),
              ),
            ),
            DropdownButtonFormField<String>(
              initialValue: category,
              decoration: InputDecoration(labelText: l10n.feedbackCategory),
              items: [
                DropdownMenuItem(
                  value: 'feature',
                  child: Text(l10n.feedbackFeature),
                ),
                DropdownMenuItem(
                  value: 'general',
                  child: Text(l10n.feedbackGeneral),
                ),
              ],
              onChanged: (v) => setState(() => category = v!),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: message,
              minLines: 3,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: l10n.feedbackMessage,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: l10n.feedbackEmail),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: sending ? null : submit,
              icon: sending
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              label: Text(l10n.feedbackSubmit),
            ),
          ],
        ),
      ),
    );
  }
}

class _BugReportSheet extends StatefulWidget {
  const _BugReportSheet();
  @override
  State<_BugReportSheet> createState() => _BugReportSheetState();
}

class _BugReportSheetState extends State<_BugReportSheet> {
  bool sending = false;
  final whatHappened = TextEditingController();
  final whatExpected = TextEditingController();

  @override
  void dispose() {
    whatHappened.dispose();
    whatExpected.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (whatHappened.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.bugReportWhatHappenedRequired)),
      );
      return;
    }
    final blockedDays = await FeedbackRateLimiter.instance
        .bugReportBlockedDays();
    if (blockedDays != null) {
      if (mounted) _showBlocked(context, l10n, blockedDays);
      return;
    }
    setState(() => sending = true);
    try {
      await FeedbackService().submitBugReport(
        whatHappened: whatHappened.text,
        whatExpected: whatExpected.text,
      );
      await FeedbackRateLimiter.instance.recordBugReport();
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.feedbackSuccess)));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.feedbackError)));
      }
    } finally {
      if (mounted) {
        setState(() => sending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final subtitleColor = isDark
        ? Colors.white.withValues(alpha: 0.64)
        : Colors.black.withValues(alpha: 0.58);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.bugReportTitle, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              l10n.bugReportIntro,
              style: TextStyle(fontSize: 13, color: subtitleColor),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: whatHappened,
              minLines: 2,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: l10n.bugReportWhatHappened,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: whatExpected,
              minLines: 2,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: l10n.bugReportWhatExpected,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: subtitleColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSpacing.controlRadius),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.smartphone_rounded,
                    size: 18,
                    color: subtitleColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${l10n.bugReportDeviceInfo}\n${FeedbackService().deviceInfoSummary()}',
                      style: TextStyle(fontSize: 12, color: subtitleColor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: sending ? null : submit,
              icon: sending
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              label: Text(l10n.feedbackSubmit),
            ),
          ],
        ),
      ),
    );
  }
}
