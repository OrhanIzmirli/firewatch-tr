import '../../core/utils/news_content_analysis.dart';
import '../../core/utils/turkish_text.dart';
import '../../models/fire_event.dart';
import '../../models/news_item.dart';

/// How a related-news list was chosen, most specific first.
///
/// [linked] is ported from 1.0.6 but does not fire in this release: the
/// backend's `related_fire_ids` is empty on every item until confirmed
/// news-to-incident matches (incident_news_claims, still in shadow mode)
/// are written into it. The tier costs nothing while empty.
enum RelatedNewsTier { linked, region, city, generic }

/// Up to 3 related articles, preferring (1) articles the backend linked to
/// this fire, (2) articles whose region matches the fire's, (3) articles
/// naming the fire's city or region in the title, (4) the newest fire news.
/// Syndicated copies of one story are collapsed at every tier.
(List<NewsItem>, RelatedNewsTier) selectRelatedNews(
  List<NewsItem> allNews,
  FireEvent fire,
) {
  final linked = dedupeNewsByTitle(
    allNews.where((n) => n.relatedFireIds.contains(fire.id)).toList(),
  );
  if (linked.isNotEmpty) {
    return (linked.take(3).toList(), RelatedNewsTier.linked);
  }

  final fireRegionFold = foldTurkish(fire.regionNameTr);
  final cityFold = foldTurkish(fire.city);

  // An empty fold would match every article ('' is in every string), so an
  // unknown region or city must not count as a match.
  final regionMatches = fireRegionFold.isEmpty
      ? <NewsItem>[]
      : dedupeNewsByTitle(allNews
          .where((n) => foldTurkish(n.relatedRegion) == fireRegionFold)
          .toList());
  if (regionMatches.isNotEmpty) {
    return (regionMatches.take(3).toList(), RelatedNewsTier.region);
  }

  final titleMatches = dedupeNewsByTitle(allNews.where((n) {
    final titleFold = foldTurkish(n.title);
    return (cityFold.isNotEmpty && titleFold.contains(cityFold)) ||
        (fireRegionFold.isNotEmpty && titleFold.contains(fireRegionFold));
  }).toList());
  if (titleMatches.isNotEmpty) {
    return (titleMatches.take(3).toList(), RelatedNewsTier.city);
  }

  return (
    dedupeNewsByTitle(allNews.take(6).toList()).take(3).toList(),
    RelatedNewsTier.generic,
  );
}
