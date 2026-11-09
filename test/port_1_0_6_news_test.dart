import 'package:firewatch_tr/core/utils/news_content_analysis.dart';
import 'package:firewatch_tr/features/fire_detail/related_news.dart';
import 'package:firewatch_tr/models/fire_event.dart';
import 'package:firewatch_tr/models/news_item.dart';
import 'package:flutter_test/flutter_test.dart';

NewsItem _news(
  String id,
  String title, {
  String region = '',
  List<String> fireIds = const [],
}) =>
    NewsItem(
      id: id,
      title: title,
      source: 'test',
      sourceUrl: '',
      publishedAt: '',
      summary: '',
      category: 'News',
      relatedRegion: region,
      readMinutes: 1,
      isBreaking: false,
      highlights: const [],
      paragraphs: const [],
      relatedFireIds: fireIds,
    );

FireEvent _fire({String id = 'f1', String city = 'Antalya', String region = 'Akdeniz'}) =>
    FireEvent(
      id: id,
      title: '',
      city: city,
      district: '',
      description: '',
      status: '',
      riskLevel: '',
      riskTier: '',
      regionNameTr: region,
      updatedAt: '',
      startedAt: '',
      affectedArea: '',
      spreadRisk: '',
      recommendedActions: const [],
      lat: 36.9,
      lng: 30.7,
    );

void main() {
  group('dedupeNewsByTitle', () {
    test('collapses the same story from two outlets (Turkish letters fold)', () {
      final items = [
        _news('1', "Antalya Manavgat'ta orman yangını: ekipler müdahale ediyor"),
        _news('2', 'Manavgatta orman yangini — ekipler mudahale ediyor (Antalya)'),
        _news('3', 'İzmir Karşıyaka sahilinde çöp konteyneri yandı'),
      ];
      expect(dedupeNewsByTitle(items).map((n) => n.id), ['1', '3']);
    });

    test('keeps different stories about the same place', () {
      final items = [
        _news('1', 'Muğla Marmaris yangınında tahliyeler sürüyor'),
        _news('2', 'Marmaris: yanan alanda ağaçlandırma çalışması başladı'),
      ];
      expect(dedupeNewsByTitle(items).length, 2);
    });

    test('keeps order and the first copy', () {
      final items = [
        _news('b', 'Bolu Mengen orman yangını kontrol altında'),
        _news('a', 'Bolu Mengen orman yangını kontrol altında'),
      ];
      expect(dedupeNewsByTitle(items).single.id, 'b');
    });

    test('titles with no long words are never collapsed', () {
      final items = [_news('1', 'Ah! Of'), _news('2', 'Ah! Of')];
      expect(dedupeNewsByTitle(items).length, 2);
    });
  });

  group('NewsItem.relatedFireIds', () {
    test('parsed from related_fire_ids, numbers or strings, nulls dropped', () {
      final item = NewsItem.fromJson({
        'id': 'n',
        'title': 't',
        'related_fire_ids': [12, '34', null],
      });
      expect(item.relatedFireIds, ['12', '34']);
      expect(NewsItem.fromJson(item.toJson()).relatedFireIds, ['12', '34']);
    });

    test('empty when the backend sends nothing (today: always)', () {
      expect(NewsItem.fromJson({'id': 'n', 'title': 't'}).relatedFireIds, isEmpty);
      expect(
        NewsItem.fromJson({'id': 'n', 'title': 't', 'related_fire_ids': []})
            .relatedFireIds,
        isEmpty,
      );
    });
  });

  group('selectRelatedNews', () {
    test('linked tier wins when the backend linked an article', () {
      final news = [
        _news('r', 'Akdeniz bölgesinde yangın', region: 'Akdeniz'),
        _news('l', 'Bu yangın hakkında', fireIds: ['f1']),
      ];
      final (picked, tier) = selectRelatedNews(news, _fire());
      expect(tier, RelatedNewsTier.linked);
      expect(picked.single.id, 'l');
    });

    test('without links (today) it falls through to region, then title', () {
      final byRegion = [_news('r', 'Yangın haberi', region: 'Akdeniz')];
      expect(selectRelatedNews(byRegion, _fire()).$2, RelatedNewsTier.region);
      final byTitle = [_news('t', "Antalya'da orman yangını")];
      expect(selectRelatedNews(byTitle, _fire()).$2, RelatedNewsTier.city);
    });

    test('an unknown region does not match every article', () {
      final news = [_news('x', 'Sakarya Pamukova yangını')];
      final (_, tier) = selectRelatedNews(news, _fire(city: '', region: ''));
      expect(tier, RelatedNewsTier.generic);
    });

    test('duplicates are collapsed within a tier', () {
      final news = [
        _news('1', 'Akdeniz orman yangını büyüyor ekipler bölgede', region: 'Akdeniz'),
        _news('2', 'Akdeniz orman yangını büyüyor, ekipler bölgede', region: 'Akdeniz'),
        _news('3', 'Akdeniz kıyısında ikinci yangın çıktı', region: 'Akdeniz'),
      ];
      final (picked, _) = selectRelatedNews(news, _fire());
      expect(picked.map((n) => n.id), ['1', '3']);
    });
  });
}
