import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../../l10n/app_localizations.dart';

/// Shared helpers for displaying the raw region/level strings returned by
/// the /api/risk/summary backend endpoint. Used by any screen that shows
/// risk-region data (Risk screen, Home screen overview cards, ...).

Color colorForApiRiskLevel(String level) {
  switch (level) {
    case 'Critical':
    case 'High':
      return AppColors.danger;
    case 'Medium':
      return AppColors.warning;
    default:
      return AppColors.success;
  }
}

/// Colors a 0-100 risk score directly: red above 70, orange 40-70, green
/// below 40 — used by the regional distribution bar chart.
Color riskScoreColor(int score) {
  if (score > 70) return AppColors.danger;
  if (score >= 40) return AppColors.warning;
  return AppColors.success;
}

String displayRegionName(AppLocalizations l10n, String region) {
  switch (region) {
    case 'Ic Anadolu': return l10n.regionIcAnadolu;
    case 'Dogu Anadolu': return l10n.regionDoguAnadolu;
    case 'Guneydogu Anadolu': return l10n.regionGuneydoguAnadolu;
    case 'Ege': return l10n.regionEge;
    case 'Akdeniz': return l10n.regionAkdeniz;
    case 'Marmara': return l10n.regionMarmara;
    case 'Karadeniz': return l10n.regionKaradeniz;
    default: return region;
  }
}

String riskLevelLabel(AppLocalizations l10n, String level) {
  switch (level) {
    case 'Critical': return l10n.commonCritical;
    case 'High': return l10n.commonHigh;
    case 'Medium': return l10n.commonMedium;
    default: return l10n.commonLow;
  }
}
