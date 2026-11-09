import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../services/alert_inbox.dart';

/// The bell in every tab's top bar. The badge counts alerts not yet read,
/// the same list "Son uyarılar" shows; opening an alert clears it.
class AlertsBell extends StatefulWidget {
  const AlertsBell({super.key});

  @override
  State<AlertsBell> createState() => _AlertsBellState();
}

class _AlertsBellState extends State<AlertsBell> {
  @override
  void initState() {
    super.initState();
    AlertInbox.instance.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: AlertInbox.instance.entries,
      builder: (context, entries, _) {
        final unread = entries.where((e) => e['read'] != true).length;
        return IconButton(
          key: const Key('alertsBell'),
          tooltip: l10n.navAlerts,
          onPressed: () => context.push('/alerts'),
          icon: Badge(
            isLabelVisible: unread > 0,
            label: Text(unread > 9 ? '9+' : '$unread'),
            child: const Icon(Icons.notifications_none_rounded),
          ),
        );
      },
    );
  }
}
