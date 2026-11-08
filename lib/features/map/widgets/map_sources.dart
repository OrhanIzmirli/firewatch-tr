import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_sheet.dart';
import '../../../shared/widgets/province_borders_credit.dart';

enum MapSourcesTopic { risk, annual }

/// Data set names and licences live behind this link, so the layer panels
/// themselves can stay in plain language.
class MapSourcesLink extends StatelessWidget {
  final MapSourcesTopic topic;

  const MapSourcesLink({super.key, required this.topic});

  @override
  Widget build(BuildContext context) => TextButton(
        key: const Key('mapSourcesLink'),
        style: TextButton.styleFrom(padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
        onPressed: () => showAppSheet<void>(context, builder: (_) => _MapSources(topic: topic)),
        child: Text(AppLocalizations.of(context)!.mapSourcesLink),
      );
}

class _MapSources extends StatelessWidget {
  final MapSourcesTopic topic;

  const _MapSources({required this.topic});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.color ?? theme.colorScheme.onSurface;
    return Padding(
      key: const Key('mapSources'),
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.mapSourcesLink, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          if (topic == MapSourcesTopic.risk) ...[
            Text(l10n.riskInfoSourcesBody, style: theme.textTheme.bodySmall),
            const SizedBox(height: AppSpacing.sm),
          ],
          ProvinceBordersCredit(color: muted, fontSize: 12),
        ],
      ),
    );
  }
}
