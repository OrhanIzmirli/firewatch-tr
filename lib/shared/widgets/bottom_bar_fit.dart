import 'package:flutter/material.dart';

/// Keeps every bottom bar label on one line. On narrow phones with large
/// text the longest label would wrap and spill out of its tab, so the text
/// scale is capped lower there. The bar's labels cannot be told not to wrap:
/// its Material resets any inherited text settings.
class BottomBarFit extends StatelessWidget {
  final int tabs;
  final Widget child;

  const BottomBarFit({super.key, required this.tabs, required this.child});

  @override
  Widget build(BuildContext context) {
    final tabWidth = MediaQuery.sizeOf(context).width / tabs;
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: tabWidth < 82 ? 1.1 : 1.3,
      child: child,
    );
  }
}
