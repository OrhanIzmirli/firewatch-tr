import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../l10n/app_localizations.dart';
import '../../models/tracked_place.dart';
import '../../services/location_disclosure.dart';
import '../../services/tracked_places_api.dart';
import '../../services/tracked_places_provider.dart';
import '../../shared/widgets/carto_basemap.dart';
import 'place_picker_screen.dart';

enum _Source { map, myLocation }

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
  if (point == null) {
    final source = await showModalBottomSheet<_Source>(
      context: context,
      useSafeArea: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              key: const Key('trackedSourceMap'),
              leading: const Icon(Icons.map_outlined),
              title: Text(l10n.trackedPlacesSourceMap),
              onTap: () => Navigator.of(sheetContext).pop(_Source.map),
            ),
            ListTile(
              key: const Key('trackedSourceMyLocation'),
              leading: const Icon(Icons.my_location_rounded),
              title: Text(l10n.trackedPlacesSourceMyLocation),
              onTap: () => Navigator.of(sheetContext).pop(_Source.myLocation),
            ),
          ],
        ),
      ),
    );
    if (source == null || !context.mounted) return null;
    if (source == _Source.map) {
      point = await Navigator.of(context).push<LatLng>(
        MaterialPageRoute(builder: (_) => const PlacePickerScreen()),
      );
    } else {
      point = await _currentPoint(context);
      if (point == null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.trackedPlacesLocationFailed)));
      }
    }
  }
  if (point == null || !context.mounted) return null;

  final place = await showModalBottomSheet<TrackedPlace>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => AddTrackedPlaceForm(point: point!),
  );
  if (place != null && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.trackedPlacesSaved(place.name))));
  }
  return place;
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
    final p = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.low, timeLimit: Duration(seconds: 10)),
    );
    return LatLng(p.latitude, p.longitude);
  } catch (_) {
    return null;
  }
}

/// Name and radius for [point], with a preview of the circle.
class AddTrackedPlaceForm extends ConsumerStatefulWidget {
  final LatLng point;

  const AddTrackedPlaceForm({super.key, required this.point});

  @override
  ConsumerState<AddTrackedPlaceForm> createState() => _AddTrackedPlaceFormState();
}

class _AddTrackedPlaceFormState extends ConsumerState<AddTrackedPlaceForm> {
  final _name = TextEditingController();
  int _radiusKm = 10;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
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
    try {
      final place = await ref.read(trackedPlacesProvider.notifier).add(
            name: name,
            latitude: widget.point.latitude,
            longitude: widget.point.longitude,
            radiusKm: _radiusKm,
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
            Text(l10n.trackedPlacesAdd, style: Theme.of(context).textTheme.titleLarge),
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
                      urlTemplate: CartoBasemap.configured
                          ? CartoBasemap.url
                          : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.oguzh.firewatch.firewatch_tr',
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
            const SizedBox(height: AppSpacing.md),
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
          ],
        ),
      ),
    );
  }
}
