import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../../l10n/app_localizations.dart';

/// Shared helpers for displaying the raw region/level strings returned by
/// the /api/risk/summary backend endpoint. Used by any screen that shows
/// risk-region data (Risk screen, Home screen overview cards, ...).

/// The single source of the risk bands: 0-24 Low, 25-49 Medium, 50-74 High,
/// 75-100 Critical — the same cutoffs the backend uses for risk_level.
/// Lower bound inclusive. Scores are indices, never probabilities.
const double riskMediumFrom = 25;
const double riskHighFrom = 50;
const double riskCriticalFrom = 75;

String riskLevelForScore(num score) => score >= riskCriticalFrom
    ? 'Critical'
    : score >= riskHighFrom
        ? 'High'
        : score >= riskMediumFrom
            ? 'Medium'
            : 'Low';

Color colorForApiRiskLevel(String level) => switch (level) {
  'Critical' => AppColors.riskCritical,
  'High' => AppColors.riskHigh,
  'Medium' => AppColors.riskMedium,
  _ => AppColors.riskLow,
};

Color riskScoreColor(num score) => colorForApiRiskLevel(riskLevelForScore(score));

/// One short, actionable sentence per band.
String riskAdvice(AppLocalizations l10n, num score) =>
    switch (riskLevelForScore(score)) {
      'Critical' => l10n.riskAdviceCritical,
      'High' => l10n.riskAdviceHigh,
      'Medium' => l10n.riskAdviceMedium,
      _ => l10n.riskAdviceLow,
    };

String displayRegionName(AppLocalizations l10n, String region) {
  switch (region) {
    case 'Ic Anadolu' || 'İç Anadolu': return l10n.regionIcAnadolu;
    case 'Dogu Anadolu' || 'Doğu Anadolu': return l10n.regionDoguAnadolu;
    case 'Guneydogu Anadolu' || 'Güneydoğu Anadolu': return l10n.regionGuneydoguAnadolu;
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
