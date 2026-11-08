import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_spacing.dart';
import '../../l10n/app_localizations.dart';
import '../risk/widgets/tracked_places_section.dart';

/// Stand-alone "Takip ettiğim yerler" list: where the "N new detections
/// near your places" summary push lands. Reached with go(), so there is no
/// page underneath; the back button returns to the risk tab, where the same
/// list lives under "My location".
class TrackedPlacesScreen extends StatelessWidget {
  const TrackedPlacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    void back() => context.go('/app');
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) back();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.trackedPlacesTitle),
          leading: BackButton(onPressed: back),
        ),
        body: const SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: TrackedPlacesSection(),
        ),
      ),
    );
  }
}
