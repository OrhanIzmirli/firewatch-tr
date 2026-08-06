import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/news_item.dart';
import '../constants/app_colors.dart';
import 'turkish_text.dart';

/// True when [phrase] (any number of words) appears in [foldedText] as a
/// whole-word/whole-phrase match — i.e. not as a substring of some longer,
/// unrelated word. [foldedText] must already be [foldTurkish]-folded;
/// [phrase] is folded here. Word-boundary matching is what keeps a bare
/// keyword like "sel" (flood) from lighting up inside "Selçuk" or a name
/// like "Abdullah" from tripping an unrelated "abd" check — the same class
/// of false positive the backend news filter hit and fixed earlier.
final Map<String, RegExp> _keywordPatternCache = {};

bool _containsKeyword(String foldedText, String phrase) {
  final pattern = _keywordPatternCache.putIfAbsent(
    phrase,
    () => RegExp(r'\b' + RegExp.escape(foldTurkish(phrase)) + r'\b'),
  );
  return pattern.hasMatch(foldedText);
}

// ── Fire-keyword highlighting (article titles) ───────────────────────────

const List<String> _fireKeywords = [
  'yangın', 'yangin', 'orman', 'alev', 'duman', 'tahliye',
  'sel', 'fırtına', 'hortum', 'afad', 'itfaiye',
];

final RegExp _fireKeywordPattern = RegExp(
  r'\b(' + _fireKeywords.map(foldTurkish).toSet().join('|') + r')\b',
);

/// Splits [text] into spans so fire-related keywords render in
/// [highlightStyle] and everything else in [baseStyle] — for use in a
/// RichText. Matching is whole-word and diacritic/case-insensitive; the
/// original text (with its real casing/diacritics) is always what's
/// displayed, only the matching is done against a folded copy.
List<TextSpan> highlightFireKeywords(String text, TextStyle baseStyle, TextStyle highlightStyle) {
  final folded = foldTurkish(text);
  final spans = <TextSpan>[];
  var lastEnd = 0;
  for (final match in _fireKeywordPattern.allMatches(folded)) {
    if (match.start > lastEnd) {
      spans.add(TextSpan(text: text.substring(lastEnd, match.start), style: baseStyle));
    }
    spans.add(TextSpan(text: text.substring(match.start, match.end), style: highlightStyle));
    lastEnd = match.end;
  }
  if (lastEnd < text.length) {
    spans.add(TextSpan(text: text.substring(lastEnd), style: baseStyle));
  }
  if (spans.isEmpty) {
    spans.add(TextSpan(text: text, style: baseStyle));
  }
  return spans;
}

// ── Risk badge (severity, derived from content) ───────────────────────────

enum NewsRiskLevel { critical, active, monitoring, info }

/// Classifies [fullText] (title + summary, typically) into a severity tier.
/// Checked most-severe-first, so an article mentioning both an evacuation
/// and routine monitoring language is still flagged critical.
NewsRiskLevel classifyNewsRiskLevel(String fullText) {
  final folded = foldTurkish(fullText);
  bool has(String phrase) => _containsKeyword(folded, phrase);

  if (has('tahliye') || has('acil') || has('can kaybı') || has('hayatını kaybetti') || has('ölü')) {
    return NewsRiskLevel.critical;
  }
  if (has('aktif yangın') || has('devam ediyor') || has('büyüyor') || has('kontrol altına alınamıyor')) {
    return NewsRiskLevel.active;
  }
  if (has('kontrol altında') || has('söndürme çalışması') || has('ekipler müdahale')) {
    return NewsRiskLevel.monitoring;
  }
  return NewsRiskLevel.info;
}

String newsRiskLevelLabel(AppLocalizations l10n, NewsRiskLevel level) {
  switch (level) {
    case NewsRiskLevel.critical: return l10n.newsRiskCritical;
    case NewsRiskLevel.active: return l10n.newsRiskActive;
    case NewsRiskLevel.monitoring: return l10n.newsRiskMonitoring;
    case NewsRiskLevel.info: return l10n.newsRiskInfo;
  }
}

Color newsRiskLevelColor(NewsRiskLevel level) {
  switch (level) {
    case NewsRiskLevel.critical: return AppColors.danger;
    case NewsRiskLevel.active: return AppColors.primary;
    case NewsRiskLevel.monitoring: return AppColors.warning;
    case NewsRiskLevel.info: return AppColors.info;
  }
}

// ── Content category (topical label, derived from content) ───────────────

enum NewsContentCategory { evacuation, response, warning, emergency, weather, forest, news }

/// Classifies [fullText] into a topical label. Checked in priority order —
/// an evacuation notice wins over a generic "risk" mention, for example.
NewsContentCategory classifyNewsCategory(String fullText) {
  final folded = foldTurkish(fullText);
  bool has(String phrase) => _containsKeyword(folded, phrase);

  if (has('tahliye') || has('evacuation')) {
    return NewsContentCategory.evacuation;
  }
  if (has('itfaiye') || has('söndürme')) return NewsContentCategory.response;
  if (has('uyarı') || has('risk')) return NewsContentCategory.warning;
  if (has('can kaybı') || has('ölü')) return NewsContentCategory.emergency;
  if (has('hava') || has('meteoroloji')) return NewsContentCategory.weather;
  if (has('orman')) return NewsContentCategory.forest;
  return NewsContentCategory.news;
}

String newsCategoryLabel(AppLocalizations l10n, NewsContentCategory category) {
  switch (category) {
    case NewsContentCategory.evacuation: return l10n.newsContentCategoryEvacuation;
    case NewsContentCategory.response: return l10n.newsContentCategoryResponse;
    case NewsContentCategory.warning: return l10n.newsContentCategoryWarning;
    case NewsContentCategory.emergency: return l10n.newsContentCategoryEmergency;
    case NewsContentCategory.weather: return l10n.newsContentCategoryWeather;
    case NewsContentCategory.forest: return l10n.newsContentCategoryForest;
    case NewsContentCategory.news: return l10n.newsContentCategoryNews;
  }
}

IconData newsCategoryIcon(NewsContentCategory category) {
  switch (category) {
    case NewsContentCategory.evacuation: return Icons.directions_run_rounded;
    case NewsContentCategory.response: return Icons.local_fire_department_rounded;
    case NewsContentCategory.warning: return Icons.warning_amber_rounded;
    case NewsContentCategory.emergency: return Icons.emergency_rounded;
    case NewsContentCategory.weather: return Icons.cloud_rounded;
    case NewsContentCategory.forest: return Icons.forest_rounded;
    case NewsContentCategory.news: return Icons.article_rounded;
  }
}

// ── Card meta (publish time / word count — replaces the old "X dk okuma") ─

/// Formats [publishedAt] (an ISO-ish timestamp string from the backend) as
/// a relative "N saat önce" / "N hours ago" string. Falls back to the raw
/// string when it can't be parsed.
String formatNewsTimeAgo(AppLocalizations l10n, String publishedAt) {
  final published = DateTime.tryParse(publishedAt);
  if (published == null) return publishedAt;
  final diff = DateTime.now().toUtc().difference(published.toUtc());
  if (diff.isNegative || diff.inMinutes < 1) return l10n.timeAgoJustNow;
  if (diff.inMinutes < 60) return l10n.timeAgoMinutes(diff.inMinutes);
  if (diff.inHours < 24) return l10n.timeAgoHours(diff.inHours);
  return l10n.timeAgoDays(diff.inDays);
}

final RegExp _whitespacePattern = RegExp(r'\s+');

/// Approximate word count of the article body (full paragraphs when
/// available, otherwise the summary) — null when there's no text to count.
int? newsWordCount(NewsItem item) {
  final text = item.paragraphs.isNotEmpty ? item.paragraphs.join(' ') : item.summary;
  final trimmed = text.trim();
  if (trimmed.isEmpty) return null;
  return trimmed.split(_whitespacePattern).length;
}
