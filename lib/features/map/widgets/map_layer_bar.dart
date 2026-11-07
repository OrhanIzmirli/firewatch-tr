import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../shared/widgets/glass_panel.dart';

/// The pill of layer toggles at the top of the map.
///
/// Four chips do not fit a 360 dp phone in Turkish ("RIGHT OVERFLOWED BY
/// 64 PIXELS", and "Geçmiş yıllar" cut in half), and larger text sizes make
/// it worse in any language. The row scrolls sideways instead of
/// overflowing and hugs its content when everything fits.
///
/// A cut-off chip alone does not say "there is more", so the edge that
/// hides content fades out: right while more is to the right, left once the
/// row has been scrolled. Nothing fades when everything fits.
class MapLayerBar extends StatefulWidget {
  final List<Widget> children;

  const MapLayerBar({super.key, required this.children});

  /// Width of the fade at a clipped edge.
  static const double fadeWidth = 28;

  @override
  State<MapLayerBar> createState() => MapLayerBarState();
}

class MapLayerBarState extends State<MapLayerBar> {
  final ScrollController _controller = ScrollController();
  bool _fadeStart = false;
  bool _fadeEnd = false;

  /// Which edges currently fade; exposed for tests.
  ({bool start, bool end}) get fades => (start: _fadeStart, end: _fadeEnd);

  @override
  void initState() {
    super.initState();
    _controller.addListener(_update);
    WidgetsBinding.instance.addPostFrameCallback((_) => _update());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _update() {
    if (!mounted || !_controller.hasClients) return;
    final p = _controller.position;
    final start = p.pixels > p.minScrollExtent + 0.5;
    final end = p.pixels < p.maxScrollExtent - 0.5;
    if (start != _fadeStart || end != _fadeEnd) {
      setState(() {
        _fadeStart = start;
        _fadeEnd = end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final row = NotificationListener<ScrollMetricsNotification>(
      // The extent changes when a label changes (language, text size).
      onNotification: (_) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _update());
        return false;
      },
      child: SingleChildScrollView(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        child: Row(mainAxisSize: MainAxisSize.min, children: widget.children),
      ),
    );

    return GlassPanel(
      padding: const EdgeInsets.all(4),
      radius: AppSpacing.pillRadius,
      // Always a ShaderMask (opaque when nothing is clipped): swapping it in
      // and out would rebuild the scroll view and reset the scroll.
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (bounds) {
          final w = bounds.width <= 0 ? 1.0 : bounds.width;
          final f = (MapLayerBar.fadeWidth / w).clamp(0.0, 0.5);
          return LinearGradient(
            colors: [
              _fadeStart ? Colors.transparent : Colors.black,
              Colors.black,
              Colors.black,
              _fadeEnd ? Colors.transparent : Colors.black,
            ],
            stops: [0, f, 1 - f, 1],
          ).createShader(bounds);
        },
        child: row,
      ),
    );
  }
}
