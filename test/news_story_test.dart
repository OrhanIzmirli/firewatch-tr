import 'package:firewatch_tr/features/news/news_story_screen.dart';
import 'package:firewatch_tr/features/news/widgets/news_visual.dart';
import 'package:firewatch_tr/l10n/app_localizations.dart';
import 'package:firewatch_tr/models/news_item.dart';
import 'package:firewatch_tr/services/news_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

NewsStory story(List<String> stages, List<(int, String?)> items) => NewsStory.fromJson({
      'id': 'Antalya-1',
      'province': 'Antalya',
      'count': items.length,
      'stages': stages,
      'items': [
        for (final (id, stage) in items)
          {'id': id, 'title': 'Haber $id', 'source': 'Bursa Haber', 'source_url': 'https://a/$id', 'published_at': '2026-09-0${id}T10:00:00Z', 'stage': stage, 'source_logo_url': ''},
      ],
    });

Widget app(Widget home) => MaterialApp(locale: const Locale('tr'), localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, home: home);

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('a timeline shows only the stages that were reported', (t) async {
    await t.pumpWidget(app(NewsStoryScreen(story: story(['started', 'controlled'], [(1, 'started'), (2, 'controlled'), (3, null)]))));
    await t.pump();
    expect(find.text('Yangının hikâyesi'), findsOneWidget);
    expect(find.byKey(const Key('newsStage-started')), findsOneWidget);
    expect(find.byKey(const Key('newsStage-controlled')), findsOneWidget);
    expect(find.byKey(const Key('newsStage-out')), findsNothing);
    expect(find.byKey(const Key('newsStage-restoration')), findsNothing);
    expect(find.text('Haber 3'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('one stage is a plain list, not a story', (t) async {
    await t.pumpWidget(app(NewsStoryScreen(story: story(['out'], [(1, 'out'), (2, 'out')]))));
    await t.pump();
    expect(find.text('Bu yangınla ilgili 2 haber'), findsOneWidget);
    expect(find.text('Yangının hikâyesi'), findsNothing);
    expect(find.text('Haber 2'), findsOneWidget);
  });

  test('no province means our own drawing, by subject', () {
    expect(newsArtFor('Yanan alanda ağaçlandırma'), NewsArt.recovery);
    expect(newsArtFor('Gönüllüler destek verdi'), NewsArt.solidarity);
    expect(newsArtFor('Yangın tatbikatı etkinliği'), NewsArt.event);
    expect(newsArtFor('Orman yangını'), NewsArt.fire);
  });

  test('the model carries the picture path and no photo is requested from a publisher', () {
    final item = NewsItem.fromJson({'id': 1, 'title': 't', 'source': 's', 'source_url': 'u', 'published_at': '', 'province': 'Muğla', 'thumb_path': '/api/news/thumb/x/2026-10-05'});
    expect(item.province, 'Muğla');
    expect(item.thumbPath, '/api/news/thumb/x/2026-10-05');
  });
}
