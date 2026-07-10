import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/feedback_service.dart';

Future<void> showFeedbackSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _FeedbackSheet(),
    );

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
    setState(() => sending = true);
    try {
      await FeedbackService().submit(
        rating: rating,
        category: category,
        message: message.text,
        email: email.text,
      );
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
                DropdownMenuItem(value: 'bug', child: Text(l10n.feedbackBug)),
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
