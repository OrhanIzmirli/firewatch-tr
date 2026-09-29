import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../l10n/app_localizations.dart';

/// Four-step scale for the summary card. The cut points are the backend's
/// own (riskCalculatorJob.calculateRiskLevel: 25 / 50 / 75), so the card
/// never disagrees with the level the API returns for the same score.
enum RiskTier { low, medium, high, veryHigh }

RiskTier riskTierForScore(num score) {
  if (score >= 75) return RiskTier.veryHigh;
  if (score >= 50) return RiskTier.high;
  if (score >= 25) return RiskTier.medium;
  return RiskTier.low;
}

/// Uses the API's `risk_level` when it is one we know, else the score.
RiskTier riskTierFor({String? apiLevel, required num score}) {
  switch (apiLevel) {
    case 'Critical':
      return RiskTier.veryHigh;
    case 'High':
      return RiskTier.high;
    case 'Medium':
      return RiskTier.medium;
    case 'Low':
      return RiskTier.low;
    default:
      return riskTierForScore(score);
  }
}

Color riskTierColor(RiskTier tier) {
  switch (tier) {
    case RiskTier.low:
      return AppColors.success;
    case RiskTier.medium:
      return AppColors.fwiModerate; // yellow
    case RiskTier.high:
      return AppColors.fwiHigh; // orange
    case RiskTier.veryHigh:
      return AppColors.danger; // red
  }
}

enum RiskFactor { hotAndDry, dry, heat, wind, calm }

/// The factor that added the most points to the score, using the same
/// buckets as the backend formula (riskCalculatorJob.calculateRisk). Fire
/// count also adds points there but is not in /risk/summary, so it cannot
/// be named here.
///
/// Ties go to dryness, then heat, then wind. A low tier always reads as
/// "calm": naming a factor that added 5 points would overstate it.
RiskFactor dominantRiskFactor({
  required double temperature,
  required double humidity,
  required double windSpeed,
  required RiskTier tier,
}) {
  if (tier == RiskTier.low) return RiskFactor.calm;

  final heat = temperature >= 40
      ? 30
      : temperature >= 35
          ? 22
          : temperature >= 30
              ? 14
              : temperature >= 25
                  ? 7
                  : 0;
  final dry = humidity <= 20
      ? 25
      : humidity <= 30
          ? 20
          : humidity <= 40
              ? 13
              : humidity <= 50
                  ? 6
                  : 0;
  final wind = windSpeed >= 50
      ? 25
      : windSpeed >= 35
          ? 18
          : windSpeed >= 20
              ? 11
              : windSpeed >= 10
                  ? 5
                  : 0;
  // The backend's heat-index bonus: only temperature and humidity together.
  final bonus = (temperature > 40 && humidity < 20)
      ? 20
      : (temperature > 35 && humidity < 30)
          ? 10
          : 0;

  if (bonus > 0 && heat + dry + bonus >= wind) return RiskFactor.hotAndDry;
  final best = [dry, heat, wind].reduce((a, b) => a >= b ? a : b);
  if (best == 0) return RiskFactor.calm;
  if (dry == best) return RiskFactor.dry;
  if (heat == best) return RiskFactor.heat;
  return RiskFactor.wind;
}

/// Turkish locative for a proper noun: "Ege'de", "Marmara'da",
/// "İç Anadolu'da". Vowel harmony picks e/a from the last vowel; a final
/// voiceless consonant (f s t k ç ş h p) hardens d to t.
String turkishLocative(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return trimmed;
  const backVowels = 'aıouAIOU';
  const frontVowels = 'eiöüEİÖÜ';
  var vowel = 'e';
  for (var i = trimmed.length - 1; i >= 0; i--) {
    final c = trimmed[i];
    if (backVowels.contains(c)) {
      vowel = 'a';
      break;
    }
    if (frontVowels.contains(c)) {
      vowel = 'e';
      break;
    }
  }
  final last = trimmed[trimmed.length - 1].toLowerCase();
  final consonant = 'fstkçşhp'.contains(last) ? 't' : 'd';
  return "$trimmed'$consonant$vowel";
}

/// What the card shows. Built by the screen from state it already holds.
class RiskSummaryData {
  /// Display name, e.g. "Ege" or "Türkiye geneli".
  final String placeName;

  /// The place as it sits in the sentence ("Ege'de", "Türkiye genelinde").
  final String placeInSentence;

  /// Why this place: "Konumuna göre · İzmir", "Seçili bölge", ...
  final String sourceLabel;
  final int score;
  final RiskTier tier;
  final double temperature;
  final double humidity;
  final double windSpeed;

  const RiskSummaryData({
    required this.placeName,
    required this.placeInSentence,
    required this.sourceLabel,
    required this.score,
    required this.tier,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
  });
}

class RiskSummaryCard extends StatelessWidget {
  /// Null when there is no risk data (API error and nothing cached).
  final RiskSummaryData? data;

  const RiskSummaryCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final minHeight = MediaQuery.sizeOf(context).height * 0.25;
    final d = data;

    final accent = d == null ? AppColors.textMuted : riskTierColor(d.tier);
    final titleColor = isDark ? AppColors.white : AppColors.lightText;
    final bodyColor = isDark
        ? AppColors.white.withValues(alpha: 0.82)
        : AppColors.lightText.withValues(alpha: 0.82);
    final surface = isDark ? AppColors.surface : AppColors.lightSurface;

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: DecoratedBox(
        decoration: BoxDecoration(
          // A soft tint of the tier colour over the normal surface keeps
          // body text at full contrast in both themes.
          color: Color.alphaBlend(
            accent.withValues(alpha: isDark ? 0.20 : 0.14),
            surface,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius + 8),
          border: Border.all(color: accent.withValues(alpha: 0.55), width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: d == null
              ? _Unavailable(titleColor: titleColor, bodyColor: bodyColor)
              : _Filled(
                  data: d,
                  l10n: l10n,
                  accent: accent,
                  titleColor: titleColor,
                  bodyColor: bodyColor,
                ),
        ),
      ),
    );
  }
}

class _Filled extends StatelessWidget {
  final RiskSummaryData data;
  final AppLocalizations l10n;
  final Color accent;
  final Color titleColor;
  final Color bodyColor;

  const _Filled({
    required this.data,
    required this.l10n,
    required this.accent,
    required this.titleColor,
    required this.bodyColor,
  });

  String _levelWord(RiskTier tier) {
    switch (tier) {
      case RiskTier.low:
        return l10n.riskHeroLevelLow;
      case RiskTier.medium:
        return l10n.riskHeroLevelMedium;
      case RiskTier.high:
        return l10n.riskHeroLevelHigh;
      case RiskTier.veryHigh:
        return l10n.riskHeroLevelVeryHigh;
    }
  }

  String _reason() {
    final t = data.temperature.round();
    final h = data.humidity.round();
    final w = data.windSpeed.round();
    switch (dominantRiskFactor(
      temperature: data.temperature,
      humidity: data.humidity,
      windSpeed: data.windSpeed,
      tier: data.tier,
    )) {
      case RiskFactor.hotAndDry:
        return l10n.riskHeroReasonHotDry(t, h);
      case RiskFactor.dry:
        return l10n.riskHeroReasonDry(h);
      case RiskFactor.heat:
        return l10n.riskHeroReasonHeat(t);
      case RiskFactor.wind:
        return l10n.riskHeroReasonWind(w);
      case RiskFactor.calm:
        return l10n.riskHeroReasonCalm(t, h, w);
    }
  }

  @override
  Widget build(BuildContext context) {
    final level = _levelWord(data.tier);
    final badgeText = level.isEmpty
        ? level
        : level[0].toUpperCase() + level.substring(1);
    // Yellow needs dark text; green, orange and red take white.
    final onAccent =
        ThemeData.estimateBrightnessForColor(accent) == Brightness.light
            ? AppColors.lightText
            : AppColors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(Icons.local_fire_department_rounded, size: 18, color: accent),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                l10n.riskHeroEyebrow.toUpperCase(),
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: bodyColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          data.placeName,
          style: GoogleFonts.ibmPlexSans(
            fontSize: 32,
            height: 1.1,
            fontWeight: FontWeight.w800,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          data.sourceLabel,
          style: GoogleFonts.ibmPlexSans(fontSize: 13, color: bodyColor),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
              ),
              child: Text(
                badgeText,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: onAccent,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              l10n.riskScoreOutOf100(data.score),
              style: GoogleFonts.ibmPlexSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: titleColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          l10n.riskHeroSentence(data.placeInSentence, level, _reason()),
          style: GoogleFonts.ibmPlexSans(
            fontSize: 16,
            height: 1.45,
            fontWeight: FontWeight.w500,
            color: titleColor,
          ),
        ),
      ],
    );
  }
}

class _Unavailable extends StatelessWidget {
  final Color titleColor;
  final Color bodyColor;

  const _Unavailable({required this.titleColor, required this.bodyColor});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.cloud_off_rounded, size: 36, color: bodyColor),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.riskHeroUnavailableTitle,
          style: GoogleFonts.ibmPlexSans(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.riskHeroUnavailableBody,
          style: GoogleFonts.ibmPlexSans(fontSize: 14, height: 1.4, color: bodyColor),
        ),
      ],
    );
  }
}
