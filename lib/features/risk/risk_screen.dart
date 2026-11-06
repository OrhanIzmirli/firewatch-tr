import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/config/api_config.dart';
import '../../core/utils/risk_display.dart';
import '../../l10n/app_localizations.dart';
import '../../services/fire_api_service.dart';
import '../../services/offline_cache_service.dart';

class RiskScreen extends StatefulWidget {
  final String? highlightRegion;
  const RiskScreen({super.key, this.highlightRegion});
  @override
  State<RiskScreen> createState() => _RiskScreenState();
}
class _RiskScreenState extends State<RiskScreen> {
  final _dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 15), receiveTimeout: const Duration(seconds: 20)));
  List<Map<String, dynamic>> _regions = [];
  String? _selected;
  bool _loading = true, _cached = false;
  DateTime? _savedAt;
  String text(String tr, String en) => Localizations.localeOf(context).languageCode == 'tr' ? tr : en;
  @override
  void initState() { super.initState(); _selected = widget.highlightRegion; _load(); _locate(); }
  @override
  void dispose() { _dio.close(force: true); super.dispose(); }
  Future<void> _locate() async {
    if (widget.highlightRegion != null) return;
    try {
      final permission = await Geolocator.checkPermission();
      if (permission != LocationPermission.always && permission != LocationPermission.whileInUse) return;
      final position = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.low, timeLimit: Duration(seconds: 10)));
      final city = await FireApiService().getNearestCity(position.latitude, position.longitude);
      if (mounted && !city.outsideTurkey && _selected == null) setState(() => _selected = city.region);
    } catch (_) { /* Country view remains available without location. */ }
  }
  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final response = await _dio.get('${ApiConfig.apiBaseUrl}/risk/summary');
      final rows = (response.data['data'] as List).map((r) => Map<String, dynamic>.from(r as Map)).toList();
      await OfflineCacheService.instance.save('risk_summary', rows);
      if (mounted) setState(() { _regions = rows; _cached = false; _savedAt = DateTime.now(); });
    } catch (_) {
      final cache = await OfflineCacheService.instance.load('risk_summary');
      if (mounted) { setState(() {
        _cached = true;
        if (cache != null) { _regions = (cache.$1 as List).map((r) => Map<String, dynamic>.from(r as Map)).toList(); _savedAt = cache.$2; }
      }); }
    } finally { if (mounted) setState(() => _loading = false); }
  }
  String _date(Object? raw) {
    final date = DateTime.tryParse(raw?.toString() ?? '')?.toLocal();
    if (date == null) return text('Tarih belirtilmemiş', 'Date unavailable');
    return '${date.day.toString().padLeft(2,'0')}.${date.month.toString().padLeft(2,'0')}.${date.year} ${date.hour.toString().padLeft(2,'0')}:${date.minute.toString().padLeft(2,'0')}';
  }
  Widget _metric(Map<String, dynamic> r, String key, String label, String unit, String explanation) => ListTile(
    title: Text('$label: ${r[key] ?? text('Veri yok', 'Unavailable')}${r[key] == null ? '' : unit}'), subtitle: Text(explanation));
  Widget _region(Map<String, dynamic> r) {
    final l10n = AppLocalizations.of(context)!;
    final score = num.tryParse('${r['general_risk_score']}');
    final color = score == null ? Colors.grey : riskScoreColor(score);
    final humidity = num.tryParse('${r['humidity']}');
    return Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(displayRegionName(l10n, '${r['region']}'), style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 12),
      Text(score == null ? text('Risk bilinmiyor', 'Risk unavailable') : riskLevelLabel(l10n, riskLevelForScore(score)),
        style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: color, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      if (score != null) Text(riskAdvice(l10n, score), style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 12),
      Text(humidity == null ? text('Nem verisi henüz yok.', 'Humidity data unavailable.') : humidity <= 30
        ? text('Nem %$humidity — hava kuru; bitkiler nem kaybedebilir ve tutuşma kolaylaşabilir.', 'Humidity $humidity% — dry air can dry vegetation, making ignition easier.')
        : text('Nem %$humidity — nem tutuşmayı etkiler; tek başına güvenli koşul anlamına gelmez.', 'Humidity $humidity% affects ignition; it does not establish safe conditions on its own.')),
      if (r['nearby_fire_count'] != null) Text(text('Son günlerde yakında ${r['nearby_fire_count']} yangın tespiti.', '${r['nearby_fire_count']} recent nearby fire detections.'))
      else Text(text('Yakındaki son yangın sayısı henüz paylaşılmıyor.', 'Recent nearby detection count is not yet available.')),
      Text(text('Hesaplama: ', 'Calculated: ') + _date(r['date'])),
      ExpansionTile(title: Text(text('Detaylar', 'Details')), children: [
        ListTile(title: Text(text('Risk puanı: ${score ?? '—'}/100', 'Risk score: ${score ?? '—'}/100')), subtitle: Text(text('Bu bir olasılık yüzdesi değildir.', 'This is an index, not a probability.'))),
        _metric(r, 'temperature', text('Sıcaklık', 'Temperature'), ' °C', text('Sıcak hava bitkilerin daha hızlı nem kaybetmesine yol açabilir.', 'Heat can make vegetation lose moisture faster.')),
        _metric(r, 'humidity', text('Nem', 'Humidity'), ' %', text('Düşük nem, yanıcı bitki örtüsünü kurutabilir.', 'Low humidity can dry vegetation.')),
        _metric(r, 'wind_speed', text('Rüzgâr', 'Wind'), ' km/h', text('Rüzgâr alevleri ve kıvılcımları taşıyabilir.', 'Wind can carry flames and embers.')),
        _metric(r, 'dryness_index', text('Kuraklık indeksi', 'Dryness index'), '', text('Bitki örtüsünün kuruluğunu temsil eden teknik gösterge.', 'A technical indicator of vegetation dryness.')),
        _metric(r, 'vegetation_density', text('Bitki yoğunluğu', 'Vegetation density'), '', text('Yanabilecek bitki örtüsü miktarını temsil eder.', 'Represents the amount of vegetation that could burn.')),
        if (r['previous_risk_score'] != null) ListTile(title: Text(text('Önceki puan: ${r['previous_risk_score']}/100', 'Previous score: ${r['previous_risk_score']}/100'))),
      ]),
    ])));
  }
  @override
  Widget build(BuildContext context) {
    final selected = _regions.where((r) => r['region'] == _selected).firstOrNull;
    final sorted = [..._regions]..sort((a,b) => (num.tryParse('${b['general_risk_score']}') ?? -1).compareTo(num.tryParse('${a['general_risk_score']}') ?? -1));
    return Scaffold(appBar: AppBar(title: Text(text('Risk', 'Risk')), actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))]),
      body: RefreshIndicator(onRefresh: _load, child: ListView(padding: const EdgeInsets.all(16), children: [
        Text(_cached ? text('Kaydedilmiş risk görünümü', 'Saved risk overview') : text('Güncel risk görünümü', 'Latest risk overview'), style: Theme.of(context).textTheme.headlineSmall),
        OutlinedButton.icon(onPressed: () => context.push('/risk-map'), icon: const Icon(Icons.map_outlined), label: Text(text('İl / ilçe risk haritası', 'District risk map'))),
        if (_cached) Text(text('Sunucuya ulaşılamadı. Son kayıt: ', 'Server unavailable. Last saved: ') + _date(_savedAt?.toIso8601String())),
        if (_loading) const LinearProgressIndicator(),
        if (!_loading && _regions.isEmpty) ListTile(title: Text(text('Risk verisine ulaşılamadı.', 'Risk data unavailable.')), trailing: IconButton(onPressed: _load, icon: const Icon(Icons.refresh))),
        if (_regions.isNotEmpty) DropdownButton<String>(isExpanded: true, value: selected == null ? '' : _selected,
          items: [DropdownMenuItem(value: '', child: Text(text('Türkiye geneli', 'All Türkiye'))), ..._regions.map((r) => DropdownMenuItem(value: '${r['region']}', child: Text(displayRegionName(AppLocalizations.of(context)!, '${r['region']}'))))],
          onChanged: (value) => setState(() => _selected = value)),
        if (selected != null) _region(selected),
        if (selected == null) ...sorted.map((r) => _region(r)),
      ])));
  }
}
