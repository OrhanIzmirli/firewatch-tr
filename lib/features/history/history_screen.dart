import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/config/feature_flags.dart';
import '../../l10n/app_localizations.dart';
import '../../models/geo_area.dart';
import '../../shared/widgets/area_map.dart';
import 'history_sample_data.dart';

/// Past fire areas with their sourced restoration updates. Runs on two
/// sample records while FIRE_HISTORY_URL is unset — and is then reachable in
/// debug builds only (see FeatureFlags.fireHistory).
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}
class _HistoryScreenState extends State<HistoryScreen> {
  static const endpoint = FeatureFlags.fireHistoryUrl;
  final _dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 15), receiveTimeout: const Duration(seconds: 20)));
  List<GeoArea> _areas = [];
  GeoArea? _selected;
  bool _loading = true;
  bool _loadFailed = false;
  int _period = 0;
  late DateTimeRange _range;
  @override
  void initState() { super.initState(); _range = _preset(0); _load(); }
  @override
  void dispose() { _dio.close(force: true); super.dispose(); }
  DateTimeRange _preset(int index) {
    final now = DateTime.now();
    return switch(index) {
      0 => DateTimeRange(start: DateTime(now.year,6,1), end: DateTime(now.year,9,30)),
      1 => DateTimeRange(start: DateTime(now.year-1,6,1), end: now),
      _ => DateTimeRange(start: DateTime(now.year-3,now.month,now.day), end: now),
    };
  }
  Future<void> _periodChanged(int index) async {
    final range = index == 3 ? await showDateRangePicker(context: context, firstDate: DateTime(2000), lastDate: DateTime.now(), initialDateRange: _range.end.isAfter(DateTime.now()) ? null : _range) : _preset(index);
    if (range != null && mounted) { setState(() { _range = range; _period = index; _selected = null; }); await _load(); }
  }
  int _generation = 0;
  Future<void> _load() async {
    final generation = ++_generation;
    setState(() { _loading = true; _loadFailed = false; });
    try {
      final data = endpoint.isEmpty ? historySampleData : (await _dio.get(endpoint, queryParameters: {'from': _range.start.toIso8601String(), 'to': _range.end.toIso8601String()})).data;
      final areas = GeoArea.collection(data);
      if (mounted && generation == _generation) setState(() { _areas = areas; _selected = null; });
    } catch (_) { if (mounted && generation == _generation) setState(() { _areas = []; _loadFailed = true; }); }
    finally { if (mounted && generation == _generation) setState(() => _loading = false); }
  }
  bool _inRange(GeoArea area) {
    final start = DateTime.tryParse('${area.properties['date_start']}');
    final end = DateTime.tryParse('${area.properties['date_end']}');
    return start != null && end != null && start.isBefore(DateTime(_range.end.year,_range.end.month,_range.end.day).add(const Duration(days:1))) && !end.isBefore(_range.start);
  }
  bool _link(Object? value) { final uri = Uri.tryParse('$value'); return uri?.scheme == 'https' && uri!.host.isNotEmpty; }
  Future<void> _open(String url) async {
    var opened = false;
    try { if (_link(url)) opened = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication); } catch (_) {}
    if (!opened && mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.historySourceOpenFailed)));
  }
  String _date(DateTime date) => '${date.day}.${date.month}.${date.year}';
  void _detail(GeoArea area) {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _selected = area);
    final p = area.properties;
    final hectares = num.tryParse('${p['area_ha']}');
    final updates = ((p['restoration_updates'] as List?) ?? []).whereType<Map>().where((u) => _link(u['source_url'])).toList();
    final campaigns = ((p['campaigns'] as List?) ?? []).whereType<Map>().where((c) => c['official_source'] == true && _link(c['url'])).toList();
    showModalBottomSheet(context: context, isScrollControlled: true, showDragHandle: true, builder: (context) => SafeArea(child: SizedBox(height: MediaQuery.sizeOf(context).height * 0.75,
      child: ListView(padding: const EdgeInsets.all(20), children: [
        if (endpoint.isEmpty) Text(l10n.historySampleRecord),
        Text('${area.city} / ${area.district}', style: Theme.of(context).textTheme.headlineSmall),
        Text('${p['date_start']} – ${p['date_end']}'),
        const SizedBox(height: 16),
        Text(hectares == null ? l10n.historyAreaUnknown : l10n.historyAreaPitches(hectares.toStringAsFixed(0), '${(hectares / 0.714).round()}'), style: Theme.of(context).textTheme.titleLarge),
        Text(l10n.historyPitchComparison),
        if (_link(p['source_url'])) TextButton(onPressed: () => _open('${p['source_url']}'), child: Text(l10n.historyAreaSource)),
        const Divider(height: 32),
        Text(l10n.historyRestorationTitle, style: Theme.of(context).textTheme.titleLarge),
        if (updates.isEmpty) Text(l10n.historyNoRestoration),
        ...updates.map((u) {
          final restored = num.tryParse('${u['restored_ha']}');
          final progress = hectares != null && hectares > 0 && restored != null && restored >= 0 ? (restored/hectares).clamp(0,1).toDouble() : null;
          return Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${u['date']} · ${u['institution']}'), Text('${u['work']}'),
            if (progress != null) ...[LinearProgressIndicator(value: progress), Text('${(progress*100).round()}% · $restored ha')],
            if (u['cost_amount'] != null && u['cost_currency'] != null) Text('${u['cost_amount']} ${u['cost_currency']}'),
            if (u['cost_comparison'] != null && _link(u['comparison_source_url'])) ...[
              Text('${u['cost_comparison']}'), TextButton(onPressed: () => _open('${u['comparison_source_url']}'), child: Text(l10n.historyComparisonSource))],
            TextButton(onPressed: () => _open('${u['source_url']}'), child: Text(l10n.historyOpenAnnouncement)),
          ])));
        }),
        const Divider(height: 32),
        Text(l10n.historyCampaignsTitle, style: Theme.of(context).textTheme.titleLarge),
        if (campaigns.isEmpty) Text(l10n.historyNoCampaigns),
        ...campaigns.map((c) => ListTile(title: Text('${c['title']}'), trailing: const Icon(Icons.open_in_new), onTap: () => _open('${c['url']}'))),
      ]))));
  }
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final visible = _areas.where(_inRange).toList();
    final periods = [l10n.historyPeriodThisSummer, l10n.historyPeriodSinceLastSummer, l10n.historyPeriodLast3Years, l10n.historyPeriodCustom];
    return Scaffold(appBar: AppBar(title: Text(l10n.riskHistoryCardTitle), actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))]),
      body: Column(children: [
        if (endpoint.isEmpty) Material(color: const Color(0xFF78350F), child: Padding(padding: const EdgeInsets.all(12), child: Text(l10n.historySampleBanner))),
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: List.generate(periods.length,(i) => Padding(padding: const EdgeInsets.symmetric(horizontal:4), child: ChoiceChip(label: Text(periods[i]), selected: _period == i, onSelected: (_) => _periodChanged(i)))))),
        Text('${_date(_range.start)} – ${_date(_range.end)}'),
        if (_loading) const LinearProgressIndicator(),
        if (_loadFailed) TextButton(onPressed: _load, child: Text(l10n.historyLoadFailed)),
        if (!_loading && visible.isEmpty && !_loadFailed) Text(l10n.historyNoRecords),
        Expanded(child: AreaMap(areas: visible, selected: _selected, color: (_) => const Color(0xFFF97316), onSelected: _detail)),
        Text(endpoint.isEmpty ? l10n.historySourceSample : l10n.historySourceLive, style: Theme.of(context).textTheme.bodySmall),
        SafeArea(top: false, child: SizedBox(height: 110, child: ListView(children: visible.map((a) => ListTile(title: Text('${a.city} / ${a.district}'), subtitle: Text('${a.properties['area_ha']} ha · ${a.properties['date_start']}'), trailing: const Icon(Icons.chevron_right), onTap: () => _detail(a))).toList()))),
      ]));
  }
}
