import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/utils/map_tiles.dart';
import '../../shared/widgets/osm_attribution.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/carto_basemap.dart';

/// Full-screen map for choosing a tracked place: the point under the fixed
/// centre marker is the choice; a long-press jumps the marker there.
/// Returns the chosen [LatLng], or null when cancelled.
class PlacePickerScreen extends StatefulWidget {
  final LatLng? initialCenter;

  const PlacePickerScreen({super.key, this.initialCenter});

  @override
  State<PlacePickerScreen> createState() => _PlacePickerScreenState();
}

class _PlacePickerScreenState extends State<PlacePickerScreen> {
  final MapController _controller = MapController();
  late LatLng _center = widget.initialCenter ?? const LatLng(39.0, 35.0);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.trackedPlacesPickerTitle)),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _controller,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: widget.initialCenter != null ? 11 : 5.6,
              minZoom: 4,
              maxZoom: 16,
              onPositionChanged: (camera, _) => _center = camera.center,
              onLongPress: (_, point) {
                _controller.move(point, _controller.camera.zoom < 10 ? 11 : _controller.camera.zoom);
                setState(() => _center = point);
              },
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
            ],
          ),
          // The marker's tip sits on the map centre.
          const IgnorePointer(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: Icon(Icons.location_on_rounded, size: 44, color: AppColors.primary),
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.md,
            child: Material(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(l10n.trackedPlacesPickerHint),
              ),
            ),
          ),
          Positioned(
            right: 4,
            bottom: 4,
            child: OsmAttribution(
              extra: [if (CartoBasemap.configured) '© CARTO'],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(AppSpacing.lg),
        child: FilledButton.icon(
          key: const Key('placePickerConfirm'),
          onPressed: () => Navigator.of(context).pop(_center),
          icon: const Icon(Icons.check_rounded),
          label: Text(l10n.trackedPlacesPickerConfirm),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }
}
