import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/saved_place.dart';
import '../../../models/tracked_place.dart';
import '../../../services/location_disclosure.dart';
import '../../../services/saved_places_provider.dart';
import '../../../services/tracked_places_api.dart';
import '../../../services/tracked_places_provider.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../../../shared/widgets/section_header.dart';
import '../../tracked_places/add_tracked_place_flow.dart';

/// "Takip ettiğim yerler" on the risk screen's "My location" tab.
class TrackedPlacesSection extends ConsumerStatefulWidget {
  const TrackedPlacesSection({super.key});

  @override
  ConsumerState<TrackedPlacesSection> createState() => _TrackedPlacesSectionState();
}

class _TrackedPlacesSectionState extends ConsumerState<TrackedPlacesSection> {
  /// Set once the 1.1 → 1.2 pin offer has been answered either way.
  static const pinOfferKey = 'tracked_pins_offer_v1_done';
  static const pinRadiusKm = 10;

  bool _pinOfferDone = true;
  bool _converting = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(trackedPlacesProvider.notifier).load());
    SharedPreferences.getInstance().then((prefs) {
      if (mounted) setState(() => _pinOfferDone = prefs.getBool(pinOfferKey) ?? false);
    });
  }

  Future<void> _closePinOffer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(pinOfferKey, true);
    if (mounted) setState(() => _pinOfferDone = true);
  }

  Future<void> _convertPins(List<SavedPlace> pins) async {
    final l10n = AppLocalizations.of(context)!;
    final accepted = await LocationDisclosure.ensureAccepted(context, force: true);
    if (!accepted || !mounted) return;
    setState(() => _converting = true);
    final notifier = ref.read(trackedPlacesProvider.notifier);
    var added = 0;
    TrackedPlacesError? failure;
    for (final pin in pins) {
      if (ref.read(trackedPlacesProvider).isFull) break;
      try {
        final name = pin.name.trim().isEmpty ? l10n.trackedPlacesTitle : pin.name.trim();
        await notifier.add(
          name: name.length > TrackedPlace.nameMaxLength ? name.substring(0, TrackedPlace.nameMaxLength) : name,
          latitude: pin.lat,
          longitude: pin.lng,
          radiusKm: pinRadiusKm,
        );
        added++;
      } on TrackedPlacesException catch (e) {
        // A pin outside Turkey is skipped; anything else stops the run.
        if (e.error != TrackedPlacesError.outsideTurkey) {
          failure = e.error;
          break;
        }
      }
    }
    if (!mounted) return;
    setState(() => _converting = false);
    if (failure == null) await _closePinOffer();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(failure == null ? l10n.trackedPlacesMigrateDone(added) : trackedPlacesErrorText(l10n, failure)),
    ));
  }

  Future<void> _confirmDelete(TrackedPlace place) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.trackedPlacesDeleteTitle(place.name)),
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
    final removed = await ref.read(trackedPlacesProvider.notifier).remove(place);
    if (!removed && mounted) {
      final error = ref.read(trackedPlacesProvider).lastError ?? TrackedPlacesError.unknown;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(trackedPlacesErrorText(l10n, error))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(trackedPlacesProvider);
    final pins = ref.watch(savedPlacesProvider).where((p) => p.kind == SavedPlaceKind.pin).toList();
    final muted = Theme.of(context).textTheme.bodySmall?.color;
    final showPinOffer = !_pinOfferDone && pins.isNotEmpty && state.loaded && !state.unavailable && !state.isFull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: l10n.trackedPlacesTitle,
          subtitle: l10n.trackedPlacesSubtitle,
          icon: const Icon(Icons.place_rounded),
          trailing: state.loading
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : Text('${state.places.length}/${TrackedPlace.maxPlaces}',
                  style: GoogleFonts.ibmPlexSans(fontSize: 13, color: muted)),
        ),
        const SizedBox(height: AppSpacing.md),
        if (state.unavailable)
          _Note(text: l10n.trackedPlacesUnavailable)
        else ...[
          if (state.lastError != null && state.lastError != TrackedPlacesError.unavailable && state.places.isNotEmpty)
            _Note(text: l10n.trackedPlacesLoadFailed),
          if (showPinOffer)
            GlassPanel(
              key: const Key('trackedPinOffer'),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.trackedPlacesMigrateTitle,
                      style: GoogleFonts.ibmPlexSans(fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(l10n.trackedPlacesMigrateBody(pins.length), style: GoogleFonts.ibmPlexSans(fontSize: 13, height: 1.4)),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: _converting ? null : _closePinOffer, child: Text(l10n.locDisclosureNotNow)),
                      const SizedBox(width: AppSpacing.sm),
                      FilledButton(
                        key: const Key('trackedPinOfferAccept'),
                        onPressed: _converting ? null : () => _convertPins(pins),
                        child: Text(l10n.trackedPlacesMigrateAccept),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          if (showPinOffer) const SizedBox(height: AppSpacing.md),
          if (state.places.isEmpty && state.loaded)
            _Note(text: l10n.trackedPlacesEmpty),
          for (final place in state.places) ...[
            _TrackedPlaceCard(
              place: place,
              onToggle: (v) async {
                final ok = await ref.read(trackedPlacesProvider.notifier).setNotify(place, v);
                if (!ok && context.mounted) {
                  final error = ref.read(trackedPlacesProvider).lastError ?? TrackedPlacesError.unknown;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(trackedPlacesErrorText(l10n, error))));
                }
              },
              onDelete: () => _confirmDelete(place),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            key: const Key('trackedPlaceAdd'),
            onPressed: state.isFull ? null : () => showAddTrackedPlaceFlow(context),
            icon: const Icon(Icons.add_location_alt_outlined),
            label: Text(state.isFull ? l10n.trackedPlacesFull : l10n.trackedPlacesAdd),
          ),
        ],
      ],
    );
  }
}

class _Note extends StatelessWidget {
  final String text;
  const _Note({required this.text});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Text(text, style: GoogleFonts.ibmPlexSans(fontSize: 13, height: 1.45, color: Theme.of(context).textTheme.bodySmall?.color)),
      );
}

class _TrackedPlaceCard extends StatelessWidget {
  final TrackedPlace place;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  const _TrackedPlaceCard({required this.place, required this.onToggle, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final lastAlert = place.lastAlertAt == null
        ? l10n.trackedPlacesNoAlertYet
        : l10n.trackedPlacesLastAlert(DateFormat.MMMd(locale).add_Hm().format(place.lastAlertAt!.toLocal()));
    final muted = Theme.of(context).textTheme.bodySmall?.color;
    return GlassPanel(
      key: Key('trackedPlace-${place.id}'),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        children: [
          const Icon(Icons.place_rounded, color: AppColors.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(place.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.ibmPlexSans(fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('${l10n.trackedPlacesRadius(place.radiusKm)} · $lastAlert',
                    style: GoogleFonts.ibmPlexSans(fontSize: 12.5, color: muted)),
              ],
            ),
          ),
          Tooltip(
            message: l10n.trackedPlacesNotifyTooltip,
            child: Switch(value: place.notifyHeat, onChanged: onToggle),
          ),
          IconButton(
            tooltip: l10n.trackedPlacesDelete,
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
