import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../models/geo_area.dart';
import '../../core/utils/risk_display.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/area_map.dart';
import 'risk_sample_data.dart';

class DistrictRiskScreen extends StatefulWidget {
  const DistrictRiskScreen({super.key});
  @override
  State<DistrictRiskScreen> createState() => _DistrictRiskScreenState();
}
class _DistrictRiskScreenState extends State<DistrictRiskScreen> {
  static const endpoint = String.fromEnvironment('DISTRICT_RISK_URL');
  List<GeoArea> _areas = [];
  GeoArea? _selected;
  String? _city, _error;
  bool _loading = true;
  final _dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 15), receiveTimeout: const Duration(seconds: 20)));
  @override
  void initState() { super.initState(); _load(); }
  @override
  void dispose() { _dio.close(force: true); super.dispose(); }
  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = endpoint.isEmpty ? riskSampleData : (await _dio.get(endpoint)).data;
      final areas = GeoArea.collection(data);
      if (mounted) setState(() { _areas = areas; _selected = null; _city = null; });
    } catch (_) { if (mounted) setState(() => _error = 'İlçe risk verisi alınamadı.'); }
    finally { if (mounted) setState(() => _loading = false); }
  }
  void _select(GeoArea area) => setState(() { _selected = area; _city = area.city; });
  void _list() {
    final sorted = [..._areas]..sort((a,b) => (b.score ?? -1).compareTo(a.score ?? -1));
    showModalBottomSheet(context: context, showDragHandle: true, builder: (context) => SafeArea(child: ListView(children: [
      const ListTile(title: Text('Risk sıralaması'), subtitle: Text('Puanlar olasılık yüzdesi değildir.')),
      ...sorted.map((a) => ListTile(leading: Icon(Icons.circle, color: a.score == null ? Colors.grey : riskScoreColor(a.score!)),
        title: Text('${a.city} / ${a.district}'), subtitle: Text('${a.score ?? '—'}/100'), onTap: () { Navigator.pop(context); _select(a); })),
    ])));
  }
  @override
  Widget build(BuildContext context) {
    final cities = _areas.map((a) => a.city).toSet().toList()..sort();
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(appBar: AppBar(title: const Text('İl / ilçe risk haritası'), actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))]),
      body: Column(children: [
        if (endpoint.isEmpty) const Material(color: Color(0xFF78350F), child: Padding(padding: EdgeInsets.all(12), child: Text('ÖRNEK VERİ · Sınırlar şematiktir; gerçek ilçe sınırları ve güncel risk değildir.'))),
        if (_loading) const LinearProgressIndicator(),
        if (_error != null) TextButton(onPressed: _load, child: Text('$_error Yeniden dene')),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [
          Expanded(child: DropdownButton<String>(isExpanded: true, value: _city ?? '', items: [const DropdownMenuItem(value: '', child: Text('Türkiye')), ...cities.map((c) => DropdownMenuItem(value: c, child: Text(c)))], onChanged: (v) => setState(() { _city = v == '' ? null : v; _selected = null; }))),
          const SizedBox(width: 12),
          Expanded(child: DropdownButton<String>(isExpanded: true, value: _selected?.id ?? '', items: [const DropdownMenuItem(value: '', child: Text('Tüm ilçeler')), ..._areas.where((a) => a.city == _city).map((a) => DropdownMenuItem(value: a.id, child: Text(a.district)))], onChanged: (v) { if (v == '') { setState(() => _selected = null); } else { _select(_areas.firstWhere((a) => a.id == v)); } })),
        ])),
        Wrap(spacing: 12, children: [for(final score in [0,25,50,75]) Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.circle, size: 12, color: riskScoreColor(score)), const SizedBox(width: 4), Text(riskLevelLabel(l10n, riskLevelForScore(score)))])]),
        Expanded(child: AreaMap(areas: _areas, selected: _selected, focusAreas: _city == null ? null : _areas.where((a) => a.city == _city).toList(),
          color: (a) => a.score == null ? Colors.grey : riskScoreColor(a.score!), onSelected: _select)),
        if (_selected != null) ListTile(title: Text('${_selected!.city} / ${_selected!.district} · ${_selected!.score ?? '—'}/100'), subtitle: Text(_selected!.score == null ? 'Risk verisi yok' : riskAdvice(l10n, _selected!.score!))),
        SafeArea(top: false, child: TextButton.icon(onPressed: _list, icon: const Icon(Icons.format_list_numbered), label: const Text('Risk sıralamasını aç'))),
      ]));
  }
}
