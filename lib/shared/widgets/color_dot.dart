import 'package:flutter/material.dart';

/// A small filled circle used wherever the interface needs to say "this
/// colour means that".
///
/// It exists so colour can be shown without emoji. A coloured emoji is a
/// font glyph: it renders differently on every platform and font fallback,
/// it does not take the app's theme, it cannot be sized against the text it
/// sits next to, and a screen reader announces it as "large red circle"
/// rather than the thing it stands for. A widget is none of those.
class ColorDot extends StatelessWidget {
  final Color color;
  final double size;

  /// Softer ring around the fill so the dot survives both a pale card and a
  /// dark one without needing two colours.
  final bool ringed;

  const ColorDot({
    super.key,
    required this.color,
    this.size = 10,
    this.ringed = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: ringed
            ? Border.all(
                color: color.withValues(alpha: 0.35),
                width: size * 0.28,
              )
            : null,
      ),
    );
  }
}
