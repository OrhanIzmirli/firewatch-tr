import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import '../../../models/annual_province_data.dart';
import '../../../models/geo_area.dart';

class AnnualProvinceLayer extends StatefulWidget {
  final AnnualProvinceData data;
  final int year;
  const AnnualProvinceLayer({
    super.key,
    required this.data,
    required this.year,
  });
  @override
  State<AnnualProvinceLayer> createState() => _AnnualProvinceLayerState();
}

class _AnnualProvinceLayerState extends State<AnnualProvinceLayer> {
  final LayerHitNotifier<String> _hit = ValueNotifier(null);
  String? _selected;
  @override
  void dispose() {
    _hit.dispose();
    super.dispose();
  }

  void _select() {
    final id = _hit.value?.hitValues.firstOrNull;
    final area = widget.data.areas.where((a) => a.id == id).firstOrNull;
    if (area == null) return;
    setState(() => _selected = id);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: const Color(0xFF111828),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => AnnualProvinceDetails(
        data: widget.data,
        area: area,
        year: widget.year,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: _select,
    child: PolygonLayer<String>(
      hitNotifier: _hit,
      polygons: [
        for (final area in widget.data.areas)
          for (final polygon in area.polygons)
            Polygon<String>(
              points: polygon.first,
              holePointsList: polygon.skip(1).toList(),
              hitValue: area.id,
              color: widget.data.color(area.id, widget.year),
              borderColor: area.id == _selected
                  ? const Color(0xFFF97316)
                  : const Color(0x590E0500),
              borderStrokeWidth: area.id == _selected ? 2 : 0.8,
            ),
      ],
    ),
  );
}

class AnnualProvinceDetails extends StatefulWidget {
  final AnnualProvinceData data;
  final GeoArea area;
  final int year;
  const AnnualProvinceDetails({
    super.key,
    required this.data,
    required this.area,
    required this.year,
  });
  @override
  State<AnnualProvinceDetails> createState() => _AnnualProvinceDetailsState();
}

class _AnnualProvinceDetailsState extends State<AnnualProvinceDetails> {
  int _metric = 0;
  static const keys = [
    'ogm_yanan_alan_ha',
    'ogm_yangin_sayisi',
    'uydu_orman_maki_noktasi',
    'effis_yanan_alan_ha',
  ];
  static const labels = [
    'OGM yanan alan',
    'OGM yangın sayısı',
    'Uydu noktası',
    'EFFIS alan',
  ];
  static const descriptions = [
    'OGM’nin kaydettiği yanan orman alanı. İl renkleri her zaman bu değere göre belirlenir.',
    'OGM’nin kaydettiği orman yangını sayısı.',
    'Uydu noktası yangın sayısı değildir. Orman ve maki alanındaki termal tespitleri gösterir.',
    'EFFIS’in uydu görüntülerinden hesapladığı yanan alan. Küçük yangınların kapsamı OGM’den farklı olabilir.',
  ];
  @override
  Widget build(BuildContext context) => SafeArea(
    child: SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.72,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Chip(
              label: Text('${widget.year} · Geçmiş yıl'),
              backgroundColor: const Color(0xFF422B25),
              labelStyle: const TextStyle(color: Color(0xFFF97316)),
            ),
          ),
          Text(
            widget.area.city,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) => Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(4, (i) {
                final value = widget.data.value(
                  widget.area.id,
                  widget.year,
                  keys[i],
                );
                final formatted = value == null
                    ? 'Veri yok'
                    : NumberFormat(
                        i == 0 || i == 3 ? '#,##0.##' : '#,##0',
                        'tr_TR',
                      ).format(value);
                return SizedBox(
                  width:
                      constraints.maxWidth >= 320 &&
                          MediaQuery.textScalerOf(context).scale(1) <= 1.3
                      ? (constraints.maxWidth - 10) / 2
                      : constraints.maxWidth,
                  child: Card(
                    color: const Color(0xFF121826),
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: const BorderSide(color: Color(0xFF222836)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            labels[i],
                            style: const TextStyle(color: Color(0xFF9CA3AF)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$formatted${value != null && (i == 0 || i == 3) ? ' ha' : ''}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                              color: i == 0
                                  ? const Color(0xFFF97316)
                                  : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 6,
            children: List.generate(
              4,
              (i) => ChoiceChip(
                label: Text(labels[i]),
                selected: _metric == i,
                onSelected: (_) => setState(() => _metric = i),
              ),
            ),
          ),
          Text(descriptions[_metric]),
          const SizedBox(height: 12),
          const Text(
            'Uydu noktası yangın sayısı değildir. İl dolguları yangının sınırını değil, il genelindeki yıllık toplamı gösterir.',
          ),
          const SizedBox(height: 16),
          Text(
            'Dosyada belirtilen kaynaklar: ${widget.data.source}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    ),
  );
}

class AnnualLegend extends StatelessWidget {
  const AnnualLegend({super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Geçmiş yıllar · OGM yanan alan',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Container(
          height: 18,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            gradient: const LinearGradient(colors: AnnualProvinceData.stops),
          ),
        ),
        const SizedBox(height: 8),
        const Text('0 · 10 · 100 · 1.000 · 10.000 ha'),
        const Text(
          'Logaritmik renk ölçeği · Koyu renk daha fazla yanan alanı gösterir. Verisi olmayan iller boyanmaz. Bu katman güncel yangın riski değildir.',
          style: TextStyle(fontSize: 12),
        ),
      ],
    ),
  );
}
