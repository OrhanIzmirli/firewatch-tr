import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/fire_incident.dart';
import '../../../models/saved_place.dart';
import '../../../services/fwi_point_service.dart';
import '../../../services/saved_places_provider.dart';
import '../../../services/turkey_places_service.dart';
import '../../../shared/widgets/color_dot.dart';
import '../../../shared/widgets/glass_panel.dart';

/// "My places": pick provinces/districts from the bundled list or drop a pin,
/// zoom the map to any of them, and read a small per-place analysis — the
/// FWI danger class for the selected forecast day plus the active detections
/// inside the place's box.
///
/// The resolution caveat at the bottom is not decoration: the FWI value is
/// a regional forecast from ECMWF's global model, so villages a few
/// kilometres apart will — and should — show the same class.
class SavedPlacesSheet extends ConsumerStatefulWidget {
  /// WMS TIME value the analysis samples (YYYY-MM-DD).
  final String dateParam;

  /// Human label for that day ("Bugün", "Yarın", weekday).
  final String dayLabel;

  final List<FireIncident> incidents;
  final ValueChanged<SavedPlace> onFocusPlace;
  final ValueChanged<List<SavedPlace>> onShowAll;
  final VoidCallback onStartPinDrop;

  const SavedPlacesSheet({
    super.key,
    required this.dateParam,
    required this.dayLabel,
    required this.incidents,
    required this.onFocusPlace,
    required this.onShowAll,
    required this.onStartPinDrop,
  });

  static Future<void> show(
    BuildContext context, {
    required String dateParam,
    required String dayLabel,
    required List<FireIncident> incidents,
    required ValueChanged<SavedPlace> onFocusPlace,
    required ValueChanged<List<SavedPlace>> onShowAll,
    required VoidCallback onStartPinDrop,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => SavedPlacesSheet(
        dateParam: dateParam,
        dayLabel: dayLabel,
        incidents: incidents,
        onFocusPlace: onFocusPlace,
        onShowAll: onShowAll,
        onStartPinDrop: onStartPinDrop,
      ),
    );
  }

  @override
  ConsumerState<SavedPlacesSheet> createState() => _SavedPlacesSheetState();
}

class _SavedPlacesSheetState extends ConsumerState<SavedPlacesSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<SavedPlace> _results = const [];

  static const List<Color> _fwiColors = [
    AppColors.fwiVeryLow,
    AppColors.fwiLow,
    AppColors.fwiModerate,
    AppColors.fwiHigh,
    AppColors.fwiVeryHigh,
    AppColors.fwiExtreme,
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onQueryChanged(String query) async {
    final results = await TurkeyPlacesService.instance.search(query);
    if (!mounted || _searchController.text != query) return;
    setState(() => _results = results);
  }

  List<String> _classLabels(AppLocalizations l10n) => [
    l10n.riskClassVeryLow,
    l10n.riskClassLow,
    l10n.riskClassModerate,
    l10n.riskClassHigh,
    l10n.riskClassVeryHigh,
    l10n.riskClassExtreme,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = Theme.of(context).textTheme.titleMedium?.color ??
        (isDark ? AppColors.white : AppColors.lightText);
    final bodyColor = isDark
        ? AppColors.white.withValues(alpha: 0.72)
        : Colors.black.withValues(alpha: 0.66);
    final places = ref.watch(savedPlacesProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, controller) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surface : AppColors.lightSurface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSpacing.largeCardRadius),
          ),
        ),
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.xxl,
          ),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: bodyColor.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.placesTitle,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                  ),
                ),
                if (places.length > 1)
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onShowAll(places);
                    },
                    icon: const Icon(Icons.zoom_out_map_rounded, size: 16),
                    label: Text(l10n.placesShowAllPlaces),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              l10n.placesSubtitle,
              style: GoogleFonts.ibmPlexSans(
                fontSize: 12.5,
                height: 1.4,
                color: bodyColor,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _searchController,
              onChanged: _onQueryChanged,
              decoration: InputDecoration(
                hintText: l10n.placesSearchHint,
                prefixIcon: const Icon(Icons.search_rounded),
                isDense: true,
              ),
            ),
            if (_results.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              GlassPanel(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                radius: AppSpacing.cardRadius,
                child: Column(
                  children: [
                    for (final result in _results.take(8))
                      ListTile(
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        leading: Icon(
                          result.kind == SavedPlaceKind.province
                              ? Icons.location_city_rounded
                              : Icons.place_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        title: Text(
                          result.name,
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: titleColor,
                          ),
                        ),
                        subtitle: result.subtitle.isEmpty
                            ? null
                            : Text(
                                result.subtitle,
                                style: GoogleFonts.ibmPlexSans(
                                  fontSize: 12,
                                  color: bodyColor,
                                ),
                              ),
                        trailing: Icon(
                          ref
                                  .read(savedPlacesProvider.notifier)
                                  .isSaved(result.id)
                              ? Icons.check_rounded
                              : Icons.add_rounded,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        onTap: () async {
                          await ref
                              .read(savedPlacesProvider.notifier)
                              .add(result);
                          if (!mounted) return;
                          setState(() {
                            _searchController.clear();
                            _results = const [];
                          });
                        },
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onStartPinDrop();
                },
                icon: const Icon(Icons.push_pin_rounded, size: 16),
                label: Text(l10n.placesDropPin),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (places.isEmpty)
              Text(
                l10n.placesEmpty,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 13,
                  height: 1.45,
                  color: bodyColor,
                ),
              )
            else
              for (final place in places) ...[
                _PlaceCard(
                  place: place,
                  dateParam: widget.dateParam,
                  dayLabel: widget.dayLabel,
                  incidents: widget.incidents,
                  classLabels: _classLabels(l10n),
                  fwiColors: _fwiColors,
                  titleColor: titleColor,
                  bodyColor: bodyColor,
                  onTap: () {
                    Navigator.pop(context);
                    widget.onFocusPlace(place);
                  },
                  onRemove: () => ref
                      .read(savedPlacesProvider.notifier)
                      .remove(place.id),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.straighten_rounded, size: 16, color: bodyColor),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    l10n.placesResolutionNote,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 11.5,
                      height: 1.5,
                      color: bodyColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  final SavedPlace place;
  final String dateParam;
  final String dayLabel;
  final List<FireIncident> incidents;
  final List<String> classLabels;
  final List<Color> fwiColors;
  final Color titleColor;
  final Color bodyColor;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _PlaceCard({
    required this.place,
    required this.dateParam,
    required this.dayLabel,
    required this.incidents,
    required this.classLabels,
    required this.fwiColors,
    required this.titleColor,
    required this.bodyColor,
    required this.onTap,
    required this.onRemove,
  });

  IconData get _kindIcon {
    switch (place.kind) {
      case SavedPlaceKind.province:
        return Icons.location_city_rounded;
      case SavedPlaceKind.district:
        return Icons.place_rounded;
      case SavedPlaceKind.pin:
        return Icons.push_pin_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Detections are point measurements, so containment uses the raw box —
    // the pad is for alerting, not for counting.
    final inside = incidents
        .where((i) => place.contains(i.latitude, i.longitude, padDeg: 0))
        .toList();
    final active = inside
        .where((i) => i.status == IncidentStatus.activeDetection)
        .length;
    double? lastHours;
    for (final i in inside) {
      if (lastHours == null || i.hoursSinceLastDetection < lastHours) {
        lastHours = i.hoursSinceLastDetection;
      }
    }

    return GlassPanel(
      padding: const EdgeInsets.all(AppSpacing.lg),
      radius: AppSpacing.cardRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_kindIcon, size: 18, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    place.subtitle.isEmpty
                        ? place.name
                        : '${place.name} — ${place.subtitle}',
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: l10n.placesRemove,
                  visualDensity: VisualDensity.compact,
                  iconSize: 18,
                  onPressed: onRemove,
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: bodyColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            FutureBuilder<FwiPointSample?>(
              future: FwiPointService.instance.sample(
                lat: place.lat,
                lng: place.lng,
                date: dateParam,
              ),
              builder: (context, snapshot) {
                final Widget value;
                if (snapshot.connectionState != ConnectionState.done) {
                  value = SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: bodyColor,
                    ),
                  );
                } else if (snapshot.data == null) {
                  value = Text(
                    l10n.placesRiskUnknown,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 13,
                      color: bodyColor,
                    ),
                  );
                } else if (!snapshot.data!.hasData) {
                  value = Text(
                    l10n.placesRiskNoData,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: bodyColor,
                    ),
                  );
                } else {
                  final index = snapshot.data!.classIndex!;
                  value = Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ColorDot(color: fwiColors[index], size: 11),
                      const SizedBox(width: 6),
                      Text(
                        classLabels[index],
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                        ),
                      ),
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.placesRiskLine(dayLabel),
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 12.5,
                          color: bodyColor,
                        ),
                      ),
                    ),
                    value,
                  ],
                );
              },
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.local_fire_department_rounded,
                  size: 14,
                  color: active > 0 ? AppColors.danger : bodyColor,
                ),
                const SizedBox(width: 6),
                Text(
                  active > 0
                      ? l10n.placesActiveDetections(active)
                      : l10n.placesNoActiveDetections,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 12.5,
                    fontWeight: active > 0 ? FontWeight.w700 : FontWeight.w400,
                    color: active > 0 ? AppColors.danger : bodyColor,
                  ),
                ),
                if (lastHours != null) ...[
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    l10n.placesLastDetection(
                      lastHours < 10
                          ? lastHours.toStringAsFixed(1)
                          : lastHours.round().toString(),
                    ),
                    style: AppTheme.mono(size: 11.5, color: bodyColor),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
