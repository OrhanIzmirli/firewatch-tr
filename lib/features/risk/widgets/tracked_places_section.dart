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
import '../../../core/utils/risk_display.dart';
import '../../../services/location_disclosure.dart';
import '../../../services/point_risk_service.dart';
import '../../../services/saved_places_provider.dart';
import '../../../services/tracked_places_api.dart';
import '../../../services/tracked_places_provider.dart';
import '../../../shared/widgets/color_dot.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../../../shared/widgets/section_header.dart';
import '../../tracked_places/add_tracked_place_flow.dart';

/// "Yerlerim": the one list of the user's places, on the home screen, the map
/// sheet and the screen a summary push opens. Each row shows the risk
/// level and nearby detections and has one notification switch.
class TrackedPlacesSection extends ConsumerStatefulWidget {
  /// Detections near a place, when the host screen has them.
  final int Function(TrackedPlace)? detectionCount;

  /// Tapping a row; opens the place's settings when null.
  final ValueChanged<TrackedPlace>? onPlaceTap;

  const TrackedPlacesSection({super.key, this.detectionCount, this.onPlaceTap});

  @override
  ConsumerState<TrackedPlacesSection> createState() => _TrackedPlacesSectionState();
}

class _TrackedPlacesSectionState extends ConsumerState<TrackedPlacesSection> {
  /// Set once the offer to move older saved places has been answered.
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

  Future<void> _convertSaved(List<SavedPlace> saved) async {
    final l10n = AppLocalizations.of(context)!;
    final accepted = await LocationDisclosure.ensureAccepted(context, force: true);
    if (!accepted || !mounted) return;
    setState(() => _converting = true);
    final notifier = ref.read(trackedPlacesProvider.notifier);
    var added = 0;
    TrackedPlacesError? failure;
    for (final place in saved) {
      if (ref.read(trackedPlacesProvider).isFull) break;
      try {
        final name = place.name.trim().isEmpty ? l10n.trackedPlacesTitle : place.name.trim();
        await notifier.add(
          name: name.length > TrackedPlace.nameMaxLength ? name.substring(0, TrackedPlace.nameMaxLength) : name,
          latitude: place.lat,
          longitude: place.lng,
          radiusKm: pinRadiusKm,
        );
        added++;
      } on TrackedPlacesException catch (e) {
        // A point outside Turkey is skipped; anything else stops the run.
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

  Future<void> _setNotifications(TrackedPlace place, bool on) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await ref.read(trackedPlacesProvider.notifier).edit(place, notifyHeat: on, notifyRisk: on);
    if (!ok && mounted) {
      final error = ref.read(trackedPlacesProvider).lastError ?? TrackedPlacesError.unknown;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(trackedPlacesErrorText(l10n, error))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(trackedPlacesProvider);
    final saved = ref.watch(savedPlacesProvider);
    final muted = Theme.of(context).textTheme.bodySmall?.color;
    final showOffer = !_pinOfferDone && saved.isNotEmpty && state.loaded && !state.unavailable && !state.isFull;

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
          if (showOffer) ...[
            GlassPanel(
              key: const Key('trackedPinOffer'),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.trackedPlacesMigrateTitle,
                      style: GoogleFonts.ibmPlexSans(fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(l10n.trackedPlacesMigrateBody(saved.length), style: GoogleFonts.ibmPlexSans(fontSize: 13, height: 1.45)),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: _converting ? null : _closePinOffer, child: Text(l10n.locDisclosureNotNow)),
                      const SizedBox(width: AppSpacing.sm),
                      FilledButton(
                        key: const Key('trackedPinOfferAccept'),
                        onPressed: _converting ? null : () => _convertSaved(saved),
                        child: Text(l10n.trackedPlacesMigrateAccept),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          if (state.places.isEmpty && state.loaded) _Note(text: l10n.trackedPlacesEmpty),
          for (final place in state.places) ...[
            _PlaceRow(
              place: place,
              detections: widget.detectionCount?.call(place),
              onTap: () => widget.onPlaceTap != null ? widget.onPlaceTap!(place) : showEditTrackedPlace(context, place),
              onEdit: () => showEditTrackedPlace(context, place),
              onToggle: (on) => _setNotifications(place, on),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (state.places.isNotEmpty) ...[
            Text(l10n.myPlacesRiskNote, style: GoogleFonts.ibmPlexSans(fontSize: 11.5, height: 1.4, color: muted)),
            const SizedBox(height: AppSpacing.sm),
          ],
          FilledButton.icon(
            key: const Key('trackedPlaceAdd'),
            onPressed: state.isFull ? null : () => showAddTrackedPlaceFlow(context),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
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
        child: Text(text,
            style: GoogleFonts.ibmPlexSans(fontSize: 13, height: 1.45, color: Theme.of(context).textTheme.bodySmall?.color)),
      );
}

class _PlaceRow extends StatelessWidget {
  final TrackedPlace place;
  final int? detections;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final ValueChanged<bool> onToggle;

  const _PlaceRow({
    required this.place,
    required this.detections,
    required this.onTap,
    required this.onEdit,
    required this.onToggle,
  });

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
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.xs, AppSpacing.md),
      child: InkWell(
        onTap: onTap,
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
                  _RiskLine(place: place),
                  if (detections != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      detections! > 0 ? l10n.myPlacesDetections24h(detections!) : l10n.myPlacesNoDetections,
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 12.5,
                        fontWeight: detections! > 0 ? FontWeight.w700 : FontWeight.w400,
                        color: detections! > 0 ? AppColors.danger : muted,
                      ),
                    ),
                  ],
                  const SizedBox(height: 2),
                  Text('${l10n.trackedPlacesRadius(place.radiusKm)} · $lastAlert',
                      style: GoogleFonts.ibmPlexSans(fontSize: 12, color: muted)),
                ],
              ),
            ),
            Tooltip(
              message: l10n.trackedPlacesNotifyTooltip,
              child: Switch(
                key: Key('trackedPlaceSwitch-${place.id}'),
                value: place.notifyHeat || place.notifyRisk,
                onChanged: onToggle,
              ),
            ),
            IconButton(
              key: Key('trackedPlaceEdit-${place.id}'),
              tooltip: l10n.trackedPlacesEditTitle,
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: onEdit,
            ),
          ],
        ),
      ),
    );
  }
}

/// The FireWatch risk score at the place: the same number as its analysis.
class _RiskLine extends StatefulWidget {
  final TrackedPlace place;
  const _RiskLine({required this.place});

  @override
  State<_RiskLine> createState() => _RiskLineState();
}

class _RiskLineState extends State<_RiskLine> {
  late Future<Map<String, dynamic>?> _risk = _load();

  Future<Map<String, dynamic>?> _load() => PointRiskService.instance
      .fetch(lat: widget.place.latitude, lng: widget.place.longitude)
      .then<Map<String, dynamic>?>((data) => data)
      .catchError((Object _) => null);

  @override
  void didUpdateWidget(_RiskLine old) {
    super.didUpdateWidget(old);
    if (old.place.latitude != widget.place.latitude || old.place.longitude != widget.place.longitude) {
      _risk = _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final style = GoogleFonts.ibmPlexSans(fontSize: 12.5, fontWeight: FontWeight.w600);
    return FutureBuilder<Map<String, dynamic>?>(
      future: _risk,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Text(l10n.commonLoading, style: style);
        }
        final score = snapshot.data?['general_risk_score'];
        if (score is! num) return Text(l10n.placesRiskUnknown, style: style);
        return Row(
          children: [
            ColorDot(color: riskScoreColor(score), size: 9),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                l10n.myPlacesRiskLine(riskLevelLabel(l10n, riskLevelForScore(score)), score.toInt()),
                style: style,
              ),
            ),
          ],
        );
      },
    );
  }
}
