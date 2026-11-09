import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/tracked_place.dart';
import '../../../services/tracked_places_provider.dart';
import '../../risk/widgets/tracked_places_section.dart';
import '../../../shared/widgets/app_sheet.dart';

/// "Yerlerim" on the map: the same list as the home card. Tapping a place
/// zooms the map to it instead of opening its settings.
class MyPlacesSheet extends ConsumerWidget {
  final int Function(TrackedPlace) detectionCount;
  final ValueChanged<TrackedPlace> onFocusPlace;
  final ValueChanged<List<TrackedPlace>> onShowAll;

  const MyPlacesSheet({
    super.key,
    required this.detectionCount,
    required this.onFocusPlace,
    required this.onShowAll,
  });

  static Future<void> show(
    BuildContext context, {
    required int Function(TrackedPlace) detectionCount,
    required ValueChanged<TrackedPlace> onFocusPlace,
    required ValueChanged<List<TrackedPlace>> onShowAll,
  }) {
    return showAppSheet(
      context,
      bare: true,
      builder: (_) => MyPlacesSheet(
        detectionCount: detectionCount,
        onFocusPlace: onFocusPlace,
        onShowAll: onShowAll,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final places = ref.watch(trackedPlacesProvider).places;
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: kSheetMaxHeightFraction,
      expand: false,
      builder: (context, controller) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surface : AppColors.lightSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.largeCardRadius)),
        ),
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xxl),
          children: [
            const SheetHeader(),
            TrackedPlacesSection(
              detectionCount: detectionCount,
              onPlaceTap: (place) {
                Navigator.of(context).pop();
                onFocusPlace(place);
              },
            ),
            if (places.length > 1) ...[
              const SizedBox(height: AppSpacing.sm),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  onShowAll(places);
                },
                icon: const Icon(Icons.zoom_out_map_rounded),
                label: Text(l10n.placesShowAllPlaces),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
