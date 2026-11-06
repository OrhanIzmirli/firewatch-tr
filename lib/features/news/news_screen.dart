import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import '../../models/news_item.dart';
import '../../services/news_service.dart';
import '../../services/fire_api_service.dart';
import '../../services/offline_cache_service.dart';
import 'widgets/news_card.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});
  @override
  State<NewsScreen> createState() => _NewsScreenState();
}
class _NewsScreenState extends State<NewsScreen> {
  static const types = ['fires','recovery','solidarity','events'];
  int _tab = 0, _generation = 0, _offset = 0;
  List<NewsItem> _items = [];
  bool _loading = true, _more = false, _cached = false;
  String? _city, _error;
  String text(String tr, String en) => Localizations.localeOf(context).languageCode == 'tr' ? tr : en;
  @override
  void initState() { super.initState(); _load(); _locate(); }
  Future<void> _locate() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission != LocationPermission.always && permission != LocationPermission.whileInUse) return;
      final position = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(timeLimit: Duration(seconds: 10)));
      final city = await FireApiService().getNearestCity(position.latitude, position.longitude);
      if (mounted && !city.outsideTurkey) setState(() => _city = city.city);
    } catch (_) {}
  }
  Future<void> _load({bool append = false}) async {
    final generation = ++_generation;
    final type = types[_tab];
    setState(() { _loading = true; _error = null; if (!append) { _items = []; _offset = 0; } });
    try {
      final items = await NewsService().fetchNewsFromRender(contentType: type == 'fires' ? null : type, offset: _offset);
      if (!mounted || generation != _generation) return;
      final relevant = items.where((n) => n.contentType == type).toList();
      setState(() { _items = append ? [..._items, ...relevant] : relevant; _offset += items.length; _more = items.length == 20; _cached = false; });
      await OfflineCacheService.instance.save('news_$type', _items.map((n) => n.toJson()).toList());
    } catch (_) {
      final cache = await OfflineCacheService.instance.load('news_$type');
      if (!mounted || generation != _generation) return;
      setState(() {
        _more = false;
        if (cache != null) { _items = (cache.$1 as List).map((n) => NewsItem.fromJson(Map<String,dynamic>.from(n))).toList(); _cached = true; }
        else { _error = text('Haberler alınamadı. Yeniden deneyin.', 'Could not load news. Try again.'); }
      });
    } finally { if (mounted && generation == _generation) setState(() => _loading = false); }
  }
  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    var opened = false;
    try { if (uri != null && uri.scheme == 'https' && uri.host.isNotEmpty) opened = await launchUrl(uri, mode: LaunchMode.externalApplication); } catch (_) {}
    if (!opened && mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text('Bağlantı açılamadı.', 'Could not open link.'))));
  }
  Future<void> _calendar(NewsItem item) async {
    final start = DateTime.tryParse(item.eventStart), end = DateTime.tryParse(item.eventEnd);
    if (start == null || end == null || !end.isAfter(start)) return;
    var success = false;
    try { success = await Add2Calendar.addEvent2Cal(Event(title: item.title, description: '${item.summary}\n${item.sourceUrl}', location: item.eventLocation, startDate: start, endDate: end)); } catch (_) {}
    if (!success && mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text('Takvim uygulaması açılamadı.', 'Could not open a calendar app.'))));
  }
  Widget _image(String url, {bool logo = false}) {
    final uri = Uri.tryParse(url);
    final fallback = ColoredBox(color: const Color(0xFF1E293B), child: Center(child: Icon(logo ? Icons.public : Icons.forest_outlined, size: logo ? 20 : 48)));
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) { return fallback; }
    return Image.network(url, fit: BoxFit.cover, errorBuilder: (_,e,s) => fallback);
  }
  @override
  Widget build(BuildContext context) {
    final items = [..._items];
    if (_tab == 3) { items.sort((a,b) {
      final nearby = (b.eventCity == _city ? 1 : 0).compareTo(a.eventCity == _city ? 1 : 0);
      return nearby != 0 ? nearby : a.eventStart.compareTo(b.eventStart);
    }); }
    return Scaffold(appBar: AppBar(title: Text(text('Haberler', 'News'))), body: Column(children: [
      SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: List.generate(4, (i) => Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: ChoiceChip(
        label: Text([text('Yangınlar','Fires'),text('Yenilenme','Recovery'),text('Dayanışma','Solidarity'),text('Etkinlikler','Events')][i]), selected: i == _tab,
        onSelected: (_) { if (_tab != i) { setState(() => _tab = i); _load(); } }))))),
      if (_loading) const LinearProgressIndicator(),
      Expanded(child: RefreshIndicator(onRefresh: _load, child: ListView(padding: const EdgeInsets.all(16), children: [
        if (_cached) Text(text('Kaydedilmiş haberler gösteriliyor.', 'Showing saved articles.')),
        if (_error != null) ListTile(title: Text(_error!), trailing: IconButton(onPressed: _load, icon: const Icon(Icons.refresh))),
        if (!_loading && items.isEmpty && _error == null) Padding(padding: const EdgeInsets.all(24), child: Text(text('Bu başlıkta henüz içerik yok.', 'No content in this category yet.'))),
        ...items.map((item) => Card(clipBehavior: Clip.antiAlias, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AspectRatio(aspectRatio: 16/9, child: _image(item.imageUrl)),
          ListTile(leading: SizedBox(width: 32, height: 32, child: _image(item.sourceLogoUrl, logo: true)), title: Text(item.source),
            trailing: const Icon(Icons.open_in_new, size: 18), onTap: () => _open(item.sourceUrl)),
          if (item.contentType == 'events') Padding(padding: const EdgeInsets.all(12), child: Text('${item.eventStart} · ${item.eventCity} · ${item.eventLocation}', style: Theme.of(context).textTheme.titleMedium)),
          NewsCard(item: item, onTap: () => context.push('/news-detail', extra: item)),
          if (item.officialSource && Uri.tryParse(item.sourceUrl)?.scheme == 'https') Padding(padding: const EdgeInsets.all(12), child: Wrap(spacing: 8, children: [
            if (item.actionUrl.isNotEmpty && ['events','solidarity'].contains(item.contentType)) FilledButton(onPressed: () => _open(item.actionUrl), child: Text(item.contentType == 'events' ? text('Katıl','Join') : text('Bağış yap','Donate'))),
            if (item.contentType == 'events' && DateTime.tryParse(item.eventStart) != null && DateTime.tryParse(item.eventEnd)?.isAfter(DateTime.parse(item.eventStart)) == true)
              OutlinedButton.icon(onPressed: () => _calendar(item), icon: const Icon(Icons.event_available), label: Text(text('Takvime ekle','Add to calendar'))),
          ])),
        ]))),
        if (_more) TextButton(onPressed: _loading ? null : () => _load(append: true), child: Text(text('Daha fazla göster','Load more'))),
      ]))),
    ]));
  }
}
