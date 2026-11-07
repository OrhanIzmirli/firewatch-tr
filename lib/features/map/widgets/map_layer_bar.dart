import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../shared/widgets/glass_panel.dart';

/// The pill of layer toggles at the top of the map.
///
/// Four chips do not fit a 360 dp phone in Turkish ("RIGHT OVERFLOWED BY
/// 64 PIXELS", and "Geçmiş yıllar" cut in half), and larger text sizes make
/// it worse in any language. The row scrolls sideways instead of
/// overflowing; it still hugs its content when everything fits.
class MapLayerBar extends StatelessWidget {
  final List<Widget> children;

  const MapLayerBar({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(4),
      radius: AppSpacing.pillRadius,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }
}
