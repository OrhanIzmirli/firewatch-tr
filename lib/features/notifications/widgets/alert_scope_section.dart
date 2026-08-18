import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/alert_scope.dart';
import '../../../services/alert_scope_provider.dart';
import '../../../services/saved_places_provider.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../../../shared/widgets/section_header.dart';

/// Lets the user narrow which fires they are alerted about: the whole country,
/// one geographic region, or one province. The region/province are suggested
/// from the device's own position but never applied without an explicit tap.
class AlertScopeSection extends ConsumerStatefulWidget {
  const AlertScopeSection({super.key});

  @override
  ConsumerState<AlertScopeSection> createState() => _AlertScopeSectionState();
}

class _AlertScopeSectionState extends ConsumerState<AlertScopeSection> {
  bool _saving = false;

  Future<void> _apply(
    AlertScope scope, {
    String? regionKey,
    int? cityId,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(alertScopeProvider.notifier);

    setState(() => _saving = true);
    await notifier.setScope(scope, regionKey: regionKey, cityId: cityId);
    final synced = await notifier.syncToBackend();
    if (!mounted) return;
    setState(() => _saving = false);

    // An incomplete selection (region chosen but no region picked yet) isn't a
    // failure worth shouting about — it just isn't ready to send.
    final state = ref.read(alertScopeProvider);
    final incomplete =
        (state.scope == AlertScope.region && state.regionKey == null) ||
            (state.scope == AlertScope.city && state.cityId == null);
    if (incomplete) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          synced ? l10n.notificationScopeSaved : l10n.notificationScopeSaveFailed,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(alertScopeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = Theme.of(context).textTheme.titleMedium?.color ??
        (isDark ? AppColors.white : AppColors.lightText);
    final subtitleColor = isDark
        ? AppColors.white.withValues(alpha: 0.64)
        : Colors.black.withValues(alpha: 0.58);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: l10n.notificationScopeTitle,
          subtitle: l10n.notificationScopeSubtitle,
          icon: const Icon(Icons.travel_explore_rounded),
        ),
        const SizedBox(height: AppSpacing.md),
        GlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ScopeOptionTile(
                icon: Icons.public_rounded,
                title: l10n.notificationScopeAll,
                subtitle: l10n.notificationScopeAllDesc,
                selected: state.scope == AlertScope.all,
                enabled: !_saving,
                onTap: () => _apply(AlertScope.all),
              ),
              _divider(isDark),
              _ScopeOptionTile(
                icon: Icons.map_rounded,
                title: l10n.notificationScopeRegion,
                subtitle: l10n.notificationScopeRegionDesc,
                selected: state.scope == AlertScope.region,
                enabled: !_saving,
                onTap: () => _apply(AlertScope.region),
              ),
              if (state.scope == AlertScope.region) ...[
                const SizedBox(height: AppSpacing.md),
                _Picker<String>(
                  label: l10n.notificationScopeRegionLabel,
                  hint: l10n.notificationScopeSelectRegion,
                  value: state.regionKey,
                  items: [
                    for (final key in kRegionKeys)
                      DropdownMenuItem(
                        value: key,
                        child: Text(regionKeyLabel(l10n, key)),
                      ),
                  ],
                  onChanged: _saving
                      ? null
                      : (value) {
                          if (value == null) return;
                          _apply(AlertScope.region, regionKey: value);
                        },
                ),
              ],
              _divider(isDark),
              _ScopeOptionTile(
                icon: Icons.location_city_rounded,
                title: l10n.notificationScopeCity,
                subtitle: l10n.notificationScopeCityDesc,
                selected: state.scope == AlertScope.city,
                enabled: !_saving,
                onTap: () => _apply(AlertScope.city),
              ),
              if (state.scope == AlertScope.city) ...[
                const SizedBox(height: AppSpacing.md),
                if (state.citiesFailed)
                  Text(
                    l10n.notificationScopeCitiesUnavailable,
                    style: GoogleFonts.ibmPlexSans(fontSize: 13, color: AppColors.warning),
                  )
                else
                  _Picker<int>(
                    label: l10n.notificationScopeCityLabel,
                    hint: l10n.notificationScopeSelectCity,
                    value: state.selectedCity?.id,
                    items: [
                      for (final city in state.cities)
                        DropdownMenuItem(value: city.id, child: Text(city.name)),
                    ],
                    onChanged: _saving
                        ? null
                        : (value) {
                            if (value == null) return;
                            _apply(AlertScope.city, cityId: value);
                          },
                  ),
              ],
              _divider(isDark),
              _ScopeOptionTile(
                icon: Icons.bookmark_rounded,
                title: l10n.notificationScopePlaces,
                subtitle: l10n.notificationScopePlacesDesc,
                selected: state.scope == AlertScope.places,
                enabled: !_saving,
                onTap: () => _apply(AlertScope.places),
              ),
              if (state.scope == AlertScope.places) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  // Honest about the mechanics: this scope runs on the
                  // device's own scans until the backend learns 'places'.
                  ref.watch(savedPlacesProvider).isEmpty
                      ? l10n.notificationScopePlacesEmpty
                      : l10n.notificationScopePlacesNote(
                          ref.watch(savedPlacesProvider).length,
                        ),
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 12.5,
                    height: 1.45,
                    color: subtitleColor,
                  ),
                ),
              ],
              if (state.scope != AlertScope.all) ...[
                const SizedBox(height: AppSpacing.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        size: 16, color: AppColors.warning),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        l10n.notificationScopeNarrowWarning,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 12.5,
                          height: 1.45,
                          color: subtitleColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              Text(
                state.isDetectingLocation
                    ? l10n.notificationScopeDetecting
                    : _suggestionLine(l10n, state),
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 12.5,
                  color: subtitleColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 300.ms)
            .slideY(begin: 0.06, end: 0),
        if (_saving)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Text(
              '…',
              style: GoogleFonts.ibmPlexSans(fontSize: 12, color: titleColor),
            ),
          ),
      ],
    );
  }

  String _suggestionLine(AppLocalizations l10n, AlertScopeState state) {
    final city = state.suggestedCity;
    final region = state.suggestedRegionKey;
    if (city != null) return l10n.notificationScopeDetected(city.name);
    if (region != null) {
      return l10n.notificationScopeDetected(regionKeyLabel(l10n, region));
    }
    return '';
  }

  Widget _divider(bool isDark) => Divider(
        height: 24,
        color: isDark
            ? AppColors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.05),
      );
}

class _ScopeOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _ScopeOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = Theme.of(context).textTheme.titleMedium?.color ??
        (isDark ? AppColors.white : AppColors.lightText);
    final subtitleColor = isDark
        ? AppColors.white.withValues(alpha: 0.64)
        : Colors.black.withValues(alpha: 0.58);

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(
                  alpha: selected ? 0.20 : 0.12,
                ),
                borderRadius: BorderRadius.circular(AppSpacing.controlRadius),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 13,
                      height: 1.4,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? AppColors.primary : subtitleColor,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _Picker<T> extends StatelessWidget {
  final String label;
  final String hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;

  const _Picker({
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtitleColor = isDark
        ? AppColors.white.withValues(alpha: 0.64)
        : Colors.black.withValues(alpha: 0.58);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.ibmPlexSans(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: subtitleColor,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          initialValue: value,
          isExpanded: true,
          hint: Text(hint),
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
