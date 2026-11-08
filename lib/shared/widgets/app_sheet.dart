import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

/// No window may cover more of the screen than this.
const double kSheetMaxHeightFraction = 0.85;

/// Tells [GlassPanel]s directly in a sheet not to draw a card on the sheet.
class FlatGlassScope extends InheritedWidget {
  const FlatGlassScope({super.key, required super.child});

  static bool of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<FlatGlassScope>() != null;

  @override
  bool updateShouldNotify(FlatGlassScope oldWidget) => false;
}

/// Grab handle and a visible close button: the top of every sheet.
class SheetHeader extends StatelessWidget {
  const SheetHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).textTheme.bodySmall?.color;
    return SizedBox(
      key: const Key('sheetHeader'),
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            key: const Key('sheetHandle'),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: color?.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              key: const Key('sheetClose'),
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
        ],
      ),
    );
  }
}

/// The one way to open a bottom sheet. At most [kSheetMaxHeightFraction] of
/// the screen; closes with its X, a swipe down, a tap outside and Back.
///
/// [scrollable] wraps [builder]'s content; pass false when it scrolls itself.
/// [bare] is for content that draws its own [SheetHeader] and sizes itself
/// with a [DraggableScrollableSheet] capped at [kSheetMaxHeightFraction].
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool scrollable = true,
  bool bare = false,
  bool flatGlass = false,
  Color? color,
}) {
  final maxHeight = MediaQuery.sizeOf(context).height * kSheetMaxHeightFraction;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: true,
    enableDrag: true,
    showDragHandle: false,
    backgroundColor: Colors.transparent,
    constraints: bare ? null : BoxConstraints(maxHeight: maxHeight),
    builder: (sheetContext) {
      if (bare) return builder(sheetContext);
      final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
      final content = Builder(builder: builder);
      final body = flatGlass ? FlatGlassScope(child: content) : content;
      return Material(
        key: const Key('appSheet'),
        color: color ?? (isDark ? AppColors.surface : AppColors.white),
        clipBehavior: Clip.antiAlias,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.largeCardRadius)),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SheetHeader(),
              Flexible(child: scrollable ? SingleChildScrollView(child: body) : body),
            ],
          ),
        ),
      );
    },
  );
}

/// A dialog title with a visible close button. Closing means "no".
class DialogTitleWithClose extends StatelessWidget {
  final Widget title;
  const DialogTitleWithClose({super.key, required this.title});

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: title),
          IconButton(
            key: const Key('dialogClose'),
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      );
}
