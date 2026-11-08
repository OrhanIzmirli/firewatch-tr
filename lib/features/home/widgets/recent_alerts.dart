import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../services/alert_inbox.dart';
import '../../../shared/widgets/app_sheet.dart';

class RecentAlerts extends StatefulWidget {
  const RecentAlerts({super.key});
  @override
  State<RecentAlerts> createState() => _RecentAlertsState();
}
class _RecentAlertsState extends State<RecentAlerts> {
  @override
  void initState() { super.initState(); AlertInbox.instance.initialize(); }
  Future<void> _open(Map<String,dynamic> entry) async {
    await AlertInbox.instance.markRead('${entry['id']}');
    if (!mounted) return;
    final payload = entry['payload']?.toString();
    if (payload != null && payload.startsWith('fire:') && payload.length > 5) {
      context.push('/fire/${Uri.encodeComponent(payload.substring(5))}');
    } else {
      showAppSheet(context, scrollable: false, builder: (context) => SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${entry['title']}', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 12), Text('${entry['body']}')]))));
    }
  }
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<List<Map<String,dynamic>>>(
    valueListenable: AlertInbox.instance.entries,
    builder: (context, entries, _) {
      final tr = Localizations.localeOf(context).languageCode == 'tr';
      final unread = entries.where((e) => e['read'] != true).length;
      return Card(child: ExpansionTile(
        initiallyExpanded: true,
        leading: Badge(isLabelVisible: unread > 0,
          label: Text('$unread'), child: const Icon(Icons.notifications_outlined)),
        title: Text(tr ? 'Son uyarılar' : 'Recent alerts'),
        subtitle: Text(tr ? '$unread okunmamış' : '$unread unread'),
        children: [
          if (entries.isEmpty) Padding(padding: const EdgeInsets.all(16), child: Text(tr
            ? 'Henüz alınmış uyarı yok. Bu, bölgede yangın olmadığı anlamına gelmez.'
            : 'No alerts received yet. This does not mean there are no fires in your area.')),
          ...entries.map((e) => ListTile(leading: Icon(e['read'] == true ? Icons.done : Icons.fiber_new),
            title: Text('${e['title']}'), subtitle: Text('${e['body']}', maxLines: 2, overflow: TextOverflow.ellipsis), onTap: () => _open(e))),
        ]));
    });
}
