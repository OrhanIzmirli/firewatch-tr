import 'package:firewatch_tr/models/news_item.dart';
import 'package:flutter_test/flutter_test.dart';

NewsItem item({required bool breaking, required String publishedAt}) => NewsItem(
      id: '1',
      title: 't',
      source: 's',
      sourceUrl: 'https://example.com',
      publishedAt: publishedAt,
      summary: 's',
      category: 'c',
      relatedRegion: 'r',
      readMinutes: 1,
      isBreaking: breaking,
      highlights: const [],
      paragraphs: const [],
    );

void main() {
  final now = DateTime.utc(2026, 11, 8, 12);

  test('a recent breaking story shows the badge', () {
    expect(item(breaking: true, publishedAt: '2026-11-08T07:00:00.000Z').isBreakingNow(now: now), isTrue);
  });

  test('an old story loses the badge (live item 3108, 9 September)', () {
    expect(item(breaking: true, publishedAt: '2026-09-09T10:00:00.000Z').isBreakingNow(now: now), isFalse);
  });

  test('a story that was never breaking stays unbadged', () {
    expect(item(breaking: false, publishedAt: '2026-11-08T11:00:00.000Z').isBreakingNow(now: now), isFalse);
  });

  test('an unparseable date is not treated as recent', () {
    expect(item(breaking: true, publishedAt: 'unknown').isBreakingNow(now: now), isFalse);
  });
}
