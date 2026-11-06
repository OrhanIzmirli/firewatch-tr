import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firewatch_tr/models/geo_area.dart';
import 'package:firewatch_tr/models/news_item.dart';
import 'package:firewatch_tr/services/alert_inbox.dart';

void main() {
  test('GeoJSON preserves islands, holes and coordinate order', () {
    final area = GeoArea.fromJson({'id':'a','properties':{},'geometry':{
      'type':'MultiPolygon','coordinates':[
        [[[27,38],[28,38],[28,39],[27,38]], [[27.1,38.1],[27.2,38.1],[27.2,38.2],[27.1,38.1]]],
        [[[29,38],[30,38],[30,39],[29,38]]],
      ]}});
    expect(area.polygons.length, 2);
    expect(area.polygons.first.length, 2);
    expect(area.points.first.latitude, 38);
    expect(area.points.first.longitude, 27);
  });
  test('Empty polygon cannot enter the map', () {
    expect(() => GeoArea.fromJson({'id':'a','properties':{},'geometry':{'type':'Polygon','coordinates':[]}}), throwsFormatException);
  });
  test('News retains action metadata through offline cache', () {
    final news = NewsItem.fromJson({'id':'event','content_type':'events',
      'event_start':'2026-11-12T10:00:00+03:00','event_end':'2026-11-12T12:00:00+03:00',
      'event_city':'İzmir','image_url':'https://example.org/image.jpg',
      'official_source':true,'action_url':'https://example.org/event'});
    final cached = NewsItem.fromJson(news.toJson());
    expect(cached.eventCity, 'İzmir');
    expect(cached.officialSource, isTrue);
    expect(cached.contentType, 'events');
    expect(cached.actionUrl, news.actionUrl);
    expect(NewsItem.fromJson({'id':'old'}).contentType, 'fires');
  });
  test('Received alerts deduplicate and persist their read state', () async {
    SharedPreferences.setMockInitialValues({});
    final inbox = AlertInbox.instance;
    await inbox.add('Warning', 'Body', id:'push-1');
    await inbox.add('Warning', 'Body', id:'push-1');
    expect(inbox.entries.value.length, 1);
    expect(inbox.entries.value.first['read'], false);
    await inbox.markRead('push-1');
    expect(inbox.entries.value.first['read'], true);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('alert_inbox'), contains('"read":true'));
  });
}
