import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:url_launcher/url_launcher.dart';

abstract final class CartoBasemap {
  static const apiKey = String.fromEnvironment('CARTO_API_KEY');
  static bool get configured => apiKey.isNotEmpty;
  static String get url => 'https://basemaps.cartocdn.com/rastertiles/dark_all/{z}/{x}/{y}.png?key=${Uri.encodeQueryComponent(apiKey)}';
}
class CartoTiles extends StatelessWidget {
  const CartoTiles({super.key});
  @override
  Widget build(BuildContext context) => CartoBasemap.configured
    ? TileLayer(urlTemplate: CartoBasemap.url, userAgentPackageName: 'com.oguzh.firewatch.firewatch_tr')
    : const SizedBox.shrink();
}
class MapAttribution extends StatelessWidget {
  const MapAttribution({super.key});
  @override
  Widget build(BuildContext context) => Material(color: const Color(0xEE111827), child: Wrap(children: [
    TextButton(onPressed: () => launchUrl(Uri.parse('https://www.openstreetmap.org/copyright')), child: const Text('© OpenStreetMap', style: TextStyle(fontSize: 10))),
    TextButton(onPressed: () => launchUrl(Uri.parse('https://carto.com/attribution/')), child: const Text('© CARTO', style: TextStyle(fontSize: 10))),
    if (!CartoBasemap.configured) const Padding(padding: EdgeInsets.all(8), child: Text('Alt harita henüz bağlı değil', style: TextStyle(fontSize: 10))),
  ]));
}
