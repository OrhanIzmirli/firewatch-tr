import '../../models/news_item.dart';

/// How the news screen is laid out from the raw list.
class NewsFeedView {
  final NewsItem? featured;
  final List<NewsItem> main;
  final List<NewsItem> archive;
  const NewsFeedView({required this.featured, required this.main, required this.archive});
}

const newsFeaturedDays = 7;
const newsArchiveAfterDays = 30;

/// Below this many forest-fire stories in a week, it is a quiet season and
/// recovery, preparation and nature news go first.
const quietWeekFires = 3;

bool isGreenNews(NewsItem n) => n.kind == 'recovery' || n.kind == 'preparation' || n.kind == 'nature';

/// Featured is a forest fire from the last week, otherwise the newest
/// recovery or preparation story, otherwise nothing. Anything older than
/// [newsArchiveAfterDays] leaves the main list.
NewsFeedView arrangeNews(List<NewsItem> items, DateTime now) {
  Duration age(NewsItem n) => now.toUtc().difference((DateTime.tryParse(n.publishedAt) ?? DateTime.fromMillisecondsSinceEpoch(0)).toUtc());
  final byDate = [...items]..sort((a, b) => age(a).compareTo(age(b)));
  final archive = byDate.where((n) => age(n).inDays > newsArchiveAfterDays).toList();
  final current = byDate.where((n) => age(n).inDays <= newsArchiveAfterDays).toList();

  final firesThisWeek = current.where((n) => n.kind == 'fire' && age(n).inDays <= newsFeaturedDays).toList();
  final greens = current.where(isGreenNews).toList();
  final featured = firesThisWeek.isNotEmpty ? firesThisWeek.first : (greens.isNotEmpty ? greens.first : null);

  var main = current.where((n) => !identical(n, featured)).toList();
  if (firesThisWeek.length < quietWeekFires) {
    main = [...main.where(isGreenNews), ...main.where((n) => !isGreenNews(n))];
  }
  return NewsFeedView(featured: featured, main: main, archive: archive);
}
