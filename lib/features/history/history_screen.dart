import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/geo_area.dart';
import '../../shared/widgets/area_map.dart';
import 'history_sample_data.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}
class _HistoryScreenState extends State<HistoryScreen> {
  static const endpoint = String.fromEnvironment('FIRE_HISTORY_URL');
  final _dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 15), receiveTimeout: const Duration(seconds: 20)));
  List<GeoArea> _areas = [];
  GeoArea? _selected;
  bool _loading = true;
  String? _error;
  int _period = 0;
  late DateTimeRange _range;
  String text(String tr, String en) => Localizations.localeOf(context).languageCode == 'tr' ? tr : en;
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
    setState(() { _loading = true; _error = null; });
    try {
      final data = endpoint.isEmpty ? historySampleData : (await _dio.get(endpoint, queryParameters: {'from': _range.start.toIso8601String(), 'to': _range.end.toIso8601String()})).data;
      final areas = GeoArea.collection(data);
      if (mounted && generation == _generation) setState(() { _areas = areas; _selected = null; });
    } catch (_) { if (mounted && generation == _generation) setState(() { _areas = []; _error = text('Geçmiş yangın verileri alınamadı.', 'Could not load fire history.'); }); }
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
    if (!opened && mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text('Kaynak açılamadı.', 'Could not open source.'))));
  }
  String _date(DateTime date) => '${date.day}.${date.month}.${date.year}';
  void _detail(GeoArea area) {
    setState(() => _selected = area);
    final p = area.properties;
    final hectares = num.tryParse('${p['area_ha']}');
    final updates = ((p['restoration_updates'] as List?) ?? []).whereType<Map>().where((u) => _link(u['source_url'])).toList();
    final campaigns = ((p['campaigns'] as List?) ?? []).whereType<Map>().where((c) => c['official_source'] == true && _link(c['url'])).toList();
    showModalBottomSheet(context: context, isScrollControlled: true, showDragHandle: true, builder: (context) => SafeArea(child: SizedBox(height: MediaQuery.sizeOf(context).height * 0.75,
      child: ListView(padding: const EdgeInsets.all(20), children: [
        if (endpoint.isEmpty) Text(text('ÖRNEK KAYIT — gerçek bir yangını temsil etmez.', 'SAMPLE RECORD — does not represent a real fire.')),
        Text('${area.city} / ${area.district}', style: Theme.of(context).textTheme.headlineSmall),
        Text('${p['date_start']} – ${p['date_end']}'),
        const SizedBox(height: 16),
        Text(hectares == null ? text('Alan henüz bilinmiyor', 'Area unavailable') : text('${hectares.toStringAsFixed(0)} hektar — yaklaşık ${(hectares / 0.714).round()} futbol sahası.', '${hectares.toStringAsFixed(0)} hectares — about ${(hectares / 0.714).round()} football pitches.'), style: Theme.of(context).textTheme.titleLarge),
        Text(text('Karşılaştırma: 105 × 68 m saha = 0,714 hektar.', 'Comparison: a 105 × 68 m pitch = 0.714 hectares.')),
        if (_link(p['source_url'])) TextButton(onPressed: () => _open('${p['source_url']}'), child: Text(text('Alan verisinin kaynağı', 'Burnt-area source'))),
        const Divider(height: 32),
        Text(text('Restorasyon', 'Restoration'), style: Theme.of(context).textTheme.titleLarge),
        if (updates.isEmpty) Text(text('Bu alan için kaynakla doğrulanmış restorasyon kaydı henüz yok. Bu, çalışma yapılmadığı anlamına gelmez.', 'No sourced restoration record is available for this area yet. This does not mean no work has taken place.')),
        ...updates.map((u) {
          final restored = num.tryParse('${u['restored_ha']}');
          final progress = hectares != null && hectares > 0 && restored != null && restored >= 0 ? (restored/hectares).clamp(0,1).toDouble() : null;
          return Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${u['date']} · ${u['institution']}'), Text('${u['work']}'),
            if (progress != null) ...[LinearProgressIndicator(value: progress), Text('${(progress*100).round()}% · $restored ha')],
            if (u['cost_amount'] != null && u['cost_currency'] != null) Text('${u['cost_amount']} ${u['cost_currency']}'),
            if (u['cost_comparison'] != null && _link(u['comparison_source_url'])) ...[
              Text('${u['cost_comparison']}'), TextButton(onPressed: () => _open('${u['comparison_source_url']}'), child: Text(text('Karşılaştırmanın kaynağı','Comparison source')))],
            TextButton(onPressed: () => _open('${u['source_url']}'), child: Text(text('Resmi duyuruyu aç','Open official announcement'))),
          ])));
        }),
        const Divider(height: 32),
        Text(text('Değişim tek kişiyle başlar', 'Change starts with one person'), style: Theme.of(context).textTheme.titleLarge),
        if (campaigns.isEmpty) Text(text('Doğrulanmış bir kampanya veya gönüllü etkinliği henüz eklenmedi.', 'No verified campaign or volunteer event has been added yet.')),
        ...campaigns.map((c) => ListTile(title: Text('${c['title']}'), trailing: const Icon(Icons.open_in_new), onTap: () => _open('${c['url']}'))),
      ]))));
  }
  @override
  Widget build(BuildContext context) {
    final visible = _areas.where(_inRange).toList();
    return Scaffold(appBar: AppBar(title: Text(text('Geçmiş yangınlar','Fire history')), actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))]),
      body: Column(children: [
        if (endpoint.isEmpty) const Material(color: Color(0xFF78350F), child: Padding(padding: EdgeInsets.all(12), child: Text('ÖRNEK VERİ · Boyalı alanlar şematiktir; gerçek yangın sınırları değildir.'))),
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: List.generate(4,(i) => Padding(padding: const EdgeInsets.symmetric(horizontal:4), child: ChoiceChip(label: Text([text('Bu yaz','This summer'),text('Geçen yazdan beri','Since last summer'),text('Son 3 yıl','Last 3 years'),text('Özel aralık','Custom range')][i]), selected: _period == i, onSelected: (_) => _periodChanged(i)))))),
        Text('${_date(_range.start)} – ${_date(_range.end)}'),
        if (_loading) const LinearProgressIndicator(),
        if (_error != null) TextButton(onPressed: _load, child: Text(_error!)),
        if (!_loading && visible.isEmpty && _error == null) Text(text('Seçilen aralıkta kayıt yok.', 'No records in the selected range.')),
        Expanded(child: AreaMap(areas: visible, selected: _selected, color: (_) => const Color(0xFFF97316), onSelected: _detail)),
        Text(endpoint.isEmpty ? text('Kaynak: örnek veri. Canlı bağlantı hedefi: EFFIS / Copernicus.', 'Source: sample data. Planned live source: EFFIS / Copernicus.') : 'Kaynak: EFFIS / Copernicus · CC BY 4.0', style: Theme.of(context).textTheme.bodySmall),
        SafeArea(top: false, child: SizedBox(height: 110, child: ListView(children: visible.map((a) => ListTile(title: Text('${a.city} / ${a.district}'), subtitle: Text('${a.properties['area_ha']} ha · ${a.properties['date_start']}'), trailing: const Icon(Icons.chevron_right), onTap: () => _detail(a))).toList()))),
      ]));
  }
}
