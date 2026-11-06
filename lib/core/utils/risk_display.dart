import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../../l10n/app_localizations.dart';

/// Shared helpers for displaying the raw region/level strings returned by
/// the /api/risk/summary backend endpoint. Used by any screen that shows
/// risk-region data (Risk screen, Home screen overview cards, ...).

/// Display bands retain the published app's 25/50/75 cutoffs.
/// These scores are indices, never probabilities.
String riskLevelForScore(num score) => score >= 75 ? 'Critical' : score >= 50 ? 'High' : score >= 25 ? 'Medium' : 'Low';
Color colorForApiRiskLevel(String level) => switch (level) {
  'Critical' => AppColors.danger,
  'High' => AppColors.primary,
  'Medium' => const Color(0xFFFACC15),
  _ => AppColors.success,
};
Color riskScoreColor(num score) => colorForApiRiskLevel(riskLevelForScore(score));
String riskAdvice(AppLocalizations l10n, num score) {
  final tr = l10n.localeName.startsWith('tr');
  return switch (riskLevelForScore(score)) {
    'Critical' => tr ? 'Açık alanda ateş yakmayın. Şüpheli dumanı 112’ye bildirin; resmi uyarıları izleyin.' : 'Do not light outdoor fires. Report suspicious smoke to 112 and follow official alerts.',
    'High' => tr ? 'Açık alanda ateş yakmayın; kıvılcım çıkarabilecek işlerden kaçının.' : 'Do not light outdoor fires; avoid activities that create sparks.',
    'Medium' => tr ? 'Kuru bitki örtüsü yakınında dikkatli olun; yerel uyarıları izleyin.' : 'Take care near dry vegetation and follow local alerts.',
    _ => tr ? 'Risk düşük olsa da sıfır değildir. Ateşi ve izmaritleri doğaya bırakmayın.' : 'Low risk is not zero risk. Never leave fire or cigarette ends outdoors.',
  };
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
    case 'Critical': return l10n.localeName.startsWith('tr') ? 'Çok yüksek' : 'Very high';
    case 'High': return l10n.commonHigh;
    case 'Medium': return l10n.commonMedium;
    default: return l10n.commonLow;
  }
}
