import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/news_item.dart';

/// The event line (date · city · place) and the action buttons shown under
/// a news card in the Events and Solidarity tabs.
///
/// "Join" / "Donate" only appear for items the backend marks as coming from
/// an official source with an https link, so the app never sends people to
/// an unverified donation page.
class NewsEventActions extends StatelessWidget {
  final NewsItem item;
  const NewsEventActions({super.key, required this.item});

  static bool _isHttps(String url) {
    final uri = Uri.tryParse(url);
    return uri != null && uri.scheme == 'https' && uri.host.isNotEmpty;
  }

  /// Whether this item has anything to show here; lets the caller skip the
  /// widget (and its spacing) entirely.
  static bool hasContent(NewsItem item) =>
      item.contentType == 'events' || _actionVisible(item);

  static bool _actionVisible(NewsItem item) =>
      item.officialSource &&
      _isHttps(item.sourceUrl) &&
      _isHttps(item.actionUrl) &&
      (item.contentType == 'events' || item.contentType == 'solidarity');

  (DateTime, DateTime)? get _eventRange {
    final start = DateTime.tryParse(item.eventStart);
    final end = DateTime.tryParse(item.eventEnd);
    if (start == null || end == null || !end.isAfter(start)) return null;
    return (start, end);
  }

  Future<void> _open(BuildContext context, String url) async {
    var opened = false;
    try {
      if (_isHttps(url)) {
        opened = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.newsLinkFailed)),
      );
    }
  }

  Future<void> _addToCalendar(BuildContext context, DateTime start, DateTime end) async {
    var success = false;
    try {
      success = await Add2Calendar.addEvent2Cal(Event(
        title: item.title,
        description: '${item.summary}\n${item.sourceUrl}',
        location: item.eventLocation,
        startDate: start,
        endDate: end,
      ));
    } catch (_) {}
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.newsCalendarFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final range = _eventRange;
    final isEvent = item.contentType == 'events';
    final when = range == null
        ? item.eventStart
        : DateFormat.yMMMd(l10n.localeName).add_Hm().format(range.$1.toLocal());
    final eventLine = [when, item.eventCity, item.eventLocation]
        .where((part) => part.trim().isNotEmpty)
        .join(' · ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.sm, AppSpacing.sm, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isEvent && eventLine.isNotEmpty)
            Row(
              children: [
                const Icon(Icons.event_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    eventLine,
                    style: GoogleFonts.ibmPlexSans(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              if (_actionVisible(item))
                FilledButton(
                  onPressed: () => _open(context, item.actionUrl),
                  child: Text(isEvent ? l10n.newsEventJoin : l10n.newsDonate),
                ),
              if (isEvent && range != null)
                OutlinedButton.icon(
                  onPressed: () => _addToCalendar(context, range.$1, range.$2),
                  icon: const Icon(Icons.event_available_rounded, size: 18),
                  label: Text(l10n.newsAddToCalendar),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
