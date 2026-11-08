import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../core/utils/map_tiles.dart';
import '../../shared/widgets/osm_attribution.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../l10n/app_localizations.dart';
import '../../models/tracked_place.dart';
import '../../services/location_disclosure.dart';
import '../../services/tracked_places_api.dart';
import '../../services/tracked_places_provider.dart';
import '../../shared/widgets/carto_basemap.dart';
import 'place_search_screen.dart';
import '../../services/device_position.dart';
import '../../shared/widgets/app_sheet.dart';

String trackedPlacesErrorText(AppLocalizations l10n, TrackedPlacesError error) {
  switch (error) {
    case TrackedPlacesError.placeLimit:
      return l10n.trackedPlacesFull;
    case TrackedPlacesError.outsideTurkey:
      return l10n.trackedPlacesErrorOutside;
    case TrackedPlacesError.unavailable:
      return l10n.trackedPlacesUnavailable;
    case TrackedPlacesError.network:
      return l10n.trackedPlacesErrorNetwork;
    case TrackedPlacesError.invalid:
    case TrackedPlacesError.unknown:
      return l10n.trackedPlacesErrorGeneric;
  }
}

/// The whole "add a place" flow: explanation (once; always before the first
/// place), where the point comes from (map or current location), then name
/// and radius. [initialPoint] skips the source step (map long-press).
Future<TrackedPlace?> showAddTrackedPlaceFlow(BuildContext context, {LatLng? initialPoint}) async {
  final l10n = AppLocalizations.of(context)!;
  final container = ProviderScope.containerOf(context);
  if (container.read(trackedPlacesProvider).isFull) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.trackedPlacesFull)));
    return null;
  }

  // Adding a place stores it on the server: the explanation comes first.
  final accepted = await LocationDisclosure.ensureAccepted(context, force: true);
  if (!accepted || !context.mounted) return null;

  var point = initialPoint;
  String? suggestedName;
  if (point == null) {
    final choice = await Navigator.of(context).push<Object>(
      MaterialPageRoute(builder: (_) => const PlaceSearchScreen()),
    );
    if (choice == null || !context.mounted) return null;
    if (choice is PlaceChoice) {
      point = choice.point;
      suggestedName = choice.suggestedName;
    } else {
      point = await _currentPoint(context);
      if (point == null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.trackedPlacesLocationFailed)));
      }
    }
  }
  if (point == null || !context.mounted) return null;

  final place = await showAppSheet<TrackedPlace>(
    context,
    scrollable: false,
    builder: (_) => AddTrackedPlaceForm(point: point!, initialName: suggestedName),
  );
  if (place != null && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.trackedPlacesSaved(place.name))));
  }
  return place;
}

/// The settings of a place: name, radius, both switches, delete.
Future<void> showEditTrackedPlace(BuildContext context, TrackedPlace place) {
  return showAppSheet<TrackedPlace>(
    context,
    scrollable: false,
    builder: (_) => AddTrackedPlaceForm(point: LatLng(place.latitude, place.longitude), existing: place),
  );
}

Future<LatLng?> _currentPoint(BuildContext context) async {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) return null;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      if (!context.mounted) return null;
      permission = await LocationDisclosure.requestPermission(context);
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      return null;
    }
    final p = await DevicePosition.current(accuracy: LocationAccuracy.low, timeLimit: const Duration(seconds: 10));
    return LatLng(p.latitude, p.longitude);
  } catch (_) {
    return null;
  }
}

/// Name and radius for [point], with a preview of the circle.
class AddTrackedPlaceForm extends ConsumerStatefulWidget {
  final LatLng point;
  final String? initialName;

  /// Editing this place instead of adding a new one.
  final TrackedPlace? existing;

  const AddTrackedPlaceForm({super.key, required this.point, this.initialName, this.existing});

  @override
  ConsumerState<AddTrackedPlaceForm> createState() => _AddTrackedPlaceFormState();
}

class _AddTrackedPlaceFormState extends ConsumerState<AddTrackedPlaceForm> {
  late final _name = TextEditingController(text: widget.existing?.name ?? _fit(widget.initialName));
  late int _radiusKm = widget.existing?.radiusKm ?? 10;
  late bool _notifyHeat = widget.existing?.notifyHeat ?? true;
  late bool _notifyRisk = widget.existing?.notifyRisk ?? true;
  bool _saving = false;
  String? _error;

  static String _fit(String? name) {
    if (name == null) return '';
    return name.length > TrackedPlace.nameMaxLength ? name.substring(0, TrackedPlace.nameMaxLength) : name;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context)!;
    final place = widget.existing!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: DialogTitleWithClose(title: Text(l10n.trackedPlacesDeleteTitle(place.name))),
        content: Text(l10n.trackedPlacesDeleteBody),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(l10n.commonCancel)),
          FilledButton(
            key: const Key('trackedPlaceDeleteConfirm'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.trackedPlacesDelete),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final notifier = ref.read(trackedPlacesProvider.notifier);
    final removed = await notifier.remove(place);
    if (!mounted) return;
    if (removed) {
      Navigator.of(context).pop();
    } else {
      setState(() => _error = trackedPlacesErrorText(l10n, ref.read(trackedPlacesProvider).lastError ?? TrackedPlacesError.unknown));
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = l10n.trackedPlacesNameRequired);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final notifier = ref.read(trackedPlacesProvider.notifier);
    final existing = widget.existing;
    if (existing != null) {
      final ok = await notifier.edit(
        existing,
        name: name == existing.name ? null : name,
        radiusKm: _radiusKm == existing.radiusKm ? null : _radiusKm,
        notifyHeat: _notifyHeat == existing.notifyHeat ? null : _notifyHeat,
        notifyRisk: _notifyRisk == existing.notifyRisk ? null : _notifyRisk,
      );
      if (!mounted) return;
      if (ok) {
        Navigator.of(context).pop();
      } else {
        setState(() {
          _saving = false;
          _error = trackedPlacesErrorText(l10n, ref.read(trackedPlacesProvider).lastError ?? TrackedPlacesError.unknown);
        });
      }
      return;
    }
    try {
      final place = await notifier.add(
        name: name,
        latitude: widget.point.latitude,
        longitude: widget.point.longitude,
        radiusKm: _radiusKm,
        notifyHeat: _notifyHeat,
        notifyRisk: _notifyRisk,
      );
      if (mounted) Navigator.of(context).pop(place);
    } on TrackedPlacesException catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = trackedPlacesErrorText(l10n, e.error);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final zoom = _radiusKm == 25 ? 8.4 : (_radiusKm == 10 ? 9.6 : 10.6);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.existing == null ? l10n.trackedPlacesAdd : l10n.trackedPlacesEditTitle, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              child: SizedBox(
                height: 160,
                child: FlutterMap(
                  key: ValueKey(_radiusKm),
                  options: MapOptions(
                    initialCenter: widget.point,
                    initialZoom: zoom,
                    interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: CartoBasemap.configured ? CartoBasemap.url : MapTiles.osmUrl,
                      // Disk-cached when it is OSM; CARTO always from the network.
                      tileProvider: MapTiles.providerFor(
                        CartoBasemap.configured ? CartoBasemap.url : MapTiles.osmUrl,
                      ),
                      userAgentPackageName: 'com.oguzh.firewatch.firewatch_tr',
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: OsmAttribution(
                        fontSize: 9,
                        extra: [if (CartoBasemap.configured) '© CARTO'],
                      ),
                    ),
                    CircleLayer(circles: [
                      CircleMarker(
                        point: widget.point,
                        radius: _radiusKm * 1000.0,
                        useRadiusInMeter: true,
                        color: AppColors.primary.withValues(alpha: 0.18),
                        borderColor: AppColors.primary,
                        borderStrokeWidth: 2,
                      ),
                    ]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              key: const Key('trackedPlaceName'),
              controller: _name,
              maxLength: TrackedPlace.nameMaxLength,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.trackedPlacesNameLabel,
                hintText: l10n.trackedPlacesNameHint,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(l10n.trackedPlacesRadiusLabel, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            SegmentedButton<int>(
              key: const Key('trackedPlaceRadius'),
              segments: [
                for (final km in TrackedPlace.radiiKm)
                  ButtonSegment(value: km, label: Text('$km km')),
              ],
              selected: {_radiusKm},
              onSelectionChanged: _saving ? null : (s) => setState(() => _radiusKm = s.first),
            ),
            const SizedBox(height: AppSpacing.sm),
            SwitchListTile(
              key: const Key('trackedNotifyHeat'),
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.trackedPlacesNotifyHeat),
              value: _notifyHeat,
              onChanged: _saving ? null : (v) => setState(() => _notifyHeat = v),
            ),
            SwitchListTile(
              key: const Key('trackedNotifyRisk'),
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.trackedPlacesNotifyRisk),
              subtitle: Text(l10n.trackedPlacesNotifyRiskDesc),
              value: _notifyRisk,
              onChanged: _saving ? null : (v) => setState(() => _notifyRisk = v),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(l10n.trackedPlacesApproxNote, style: Theme.of(context).textTheme.bodySmall),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              key: const Key('trackedPlaceSave'),
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _saving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.2))
                  : Text(l10n.trackedPlacesSave),
            ),
            if (widget.existing != null) ...[
              const SizedBox(height: AppSpacing.sm),
              TextButton.icon(
                key: const Key('trackedPlaceDelete'),
                onPressed: _saving ? null : _delete,
                icon: const Icon(Icons.delete_outline_rounded),
                label: Text(l10n.trackedPlacesDelete),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
