import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../l10n/app_localizations.dart';
import '../../models/place_search_result.dart';
import '../../models/saved_place.dart';
import '../../services/tracked_places_api.dart';
import '../../services/tracked_places_provider.dart';
import '../../services/turkey_places_service.dart';
import 'place_picker_screen.dart';

/// Where a new place is, and the name the search suggests for it.
class PlaceChoice {
  final LatLng point;
  final String? suggestedName;
  const PlaceChoice(this.point, {this.suggestedName});
}

/// What the search screen can answer besides a place from the list.
enum PlaceSearchAction { useMyLocation }

/// Step one of adding a place: search, or pick on the map, or use the current
/// location. Pops a [PlaceChoice], or [PlaceSearchAction.useMyLocation].
///
/// Provinces and districts come from the bundled list and never leave the
/// phone. Only when that finds nothing, or the user asks, does the text go to
/// the backend's Nominatim proxy, and only when "Ara" is pressed: Nominatim's
/// usage policy forbids search-as-you-type.
class PlaceSearchScreen extends ConsumerStatefulWidget {
  const PlaceSearchScreen({super.key});

  @override
  ConsumerState<PlaceSearchScreen> createState() => _PlaceSearchScreenState();
}

class _PlaceSearchScreenState extends ConsumerState<PlaceSearchScreen> {
  static const minRemoteLength = 3;

  final _query = TextEditingController();
  List<SavedPlace> _local = const [];
  List<PlaceSearchResult> _remote = const [];
  bool _searching = false;
  bool _searched = false;
  bool _remoteAsked = false;
  String? _message;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final text = _query.text.trim();
    if (text.isEmpty || _searching) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _searching = true;
      _message = null;
      _remote = const [];
      _remoteAsked = false;
    });
    final local = await TurkeyPlacesService.instance.search(text, limit: 8);
    if (!mounted) return;
    setState(() {
      _local = local;
      _searched = true;
      _searching = false;
    });
    if (local.isEmpty) await _searchRemote();
  }

  Future<void> _searchRemote() async {
    final l10n = AppLocalizations.of(context)!;
    final text = _query.text.trim();
    if ([...text.runes].length < minRemoteLength) {
      setState(() {
        _remoteAsked = true;
        _message = l10n.placeSearchTooShort;
      });
      return;
    }
    setState(() {
      _searching = true;
      _remoteAsked = true;
      _message = null;
    });
    try {
      final results = await ref.read(trackedPlacesProvider.notifier).search(text);
      if (!mounted) return;
      setState(() {
        _remote = results;
        _searching = false;
        _message = results.isEmpty ? l10n.placeSearchNoResults : null;
      });
    } on TrackedPlacesException {
      if (!mounted) return;
      setState(() {
        _searching = false;
        _message = l10n.placeSearchFailed;
      });
    }
  }

  Future<void> _confirmOnMap(LatLng point, double zoom, String name, String label) async {
    final chosen = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (_) => PlacePickerScreen(initialCenter: point, initialZoom: zoom, label: label),
      ),
    );
    if (chosen != null && mounted) {
      Navigator.of(context).pop(PlaceChoice(chosen, suggestedName: name));
    }
  }

  Future<void> _pickOnMap() async {
    final chosen = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(builder: (_) => const PlacePickerScreen()),
    );
    if (chosen != null && mounted) Navigator.of(context).pop(PlaceChoice(chosen));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final muted = Theme.of(context).textTheme.bodySmall;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.trackedPlacesAdd)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('placeSearchField'),
                  controller: _query,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _search(),
                  decoration: InputDecoration(
                    hintText: l10n.placeSearchHint,
                    prefixIcon: const Icon(Icons.search_rounded),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              FilledButton(
                key: const Key('placeSearchButton'),
                onPressed: _searching ? null : _search,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                ),
                child: Text(l10n.placeSearchButton),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(l10n.placeSearchPrivacy, style: muted),
          if (_searching) ...[
            const SizedBox(height: AppSpacing.md),
            const LinearProgressIndicator(),
          ],
          if (_message != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(_message!, key: const Key('placeSearchMessage')),
          ],
          for (final place in _local)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.place_outlined),
              title: Text(place.name),
              subtitle: place.subtitle.isEmpty ? null : Text(place.subtitle),
              onTap: () => _confirmOnMap(
                place.center,
                place.kind == SavedPlaceKind.province ? 9 : 12,
                place.name,
                place.subtitle.isEmpty ? place.name : '${place.name}, ${place.subtitle}',
              ),
            ),
          if (_searched && _local.isNotEmpty && !_remoteAsked)
            TextButton.icon(
              key: const Key('placeSearchRemote'),
              onPressed: _searching ? null : _searchRemote,
              icon: const Icon(Icons.travel_explore_rounded),
              label: Text(l10n.placeSearchRemote),
            ),
          for (final result in _remote)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.location_on_outlined),
              title: Text(result.name),
              subtitle: Text(result.label),
              onTap: () => _confirmOnMap(LatLng(result.latitude, result.longitude), 15, result.name, result.label),
            ),
          if (_remote.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(l10n.placeSearchAttribution, key: const Key('placeSearchAttribution'), style: muted),
          ],
          const Divider(height: AppSpacing.xxl),
          ListTile(
            key: const Key('trackedSourceMap'),
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.map_outlined),
            title: Text(l10n.trackedPlacesSourceMap),
            onTap: _pickOnMap,
          ),
          ListTile(
            key: const Key('trackedSourceMyLocation'),
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.my_location_rounded),
            title: Text(l10n.trackedPlacesSourceMyLocation),
            onTap: () => Navigator.of(context).pop(PlaceSearchAction.useMyLocation),
          ),
        ],
      ),
    );
  }
}
