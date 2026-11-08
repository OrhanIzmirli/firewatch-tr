/// Lessons and tasks in the Fidan section. Written so a child can follow
/// them; each claim carries the page it came from, and every page below was
/// opened and checked on 8 November 2026. Add nothing without doing the same.
library;

class Bi {
  final String tr;
  final String en;
  const Bi(this.tr, this.en);

  String of(String languageCode) => languageCode == 'tr' ? tr : en;
}

class NatureSource {
  final String name;
  final String url;
  const NatureSource(this.name, this.url);
}

const ogmKonya = NatureSource(
  'OGM Konya, 17.05.2023',
  'https://www.ogm.gov.tr/konyaobm/haberler/orman-yanginlariyla-mucadele-hazirlik-egitimlerini-tamamladik',
);
const ogmMugla = NatureSource(
  'OGM Muğla, 25.04.2024',
  'https://www.ogm.gov.tr/muglaobm/haberler/koylerde-yangin-tedbirleri-film',
);
const ogmSoma = NatureSource(
  'OGM, 05.02.2025',
  'https://www.ogm.gov.tr/tr/haberler/yanan-alanlar-kullerinden-doguyor',
);
const nasaFaq = NatureSource('NASA FIRMS', 'https://www.earthdata.nasa.gov/data/tools/firms/faq');
const faoFire = NatureSource(
  'FAO',
  'https://www.fao.org/sustainable-forest-management/toolbox/modules/vegetation-fire-management/basic-knowledge/en/?type=111',
);
const forestJournal = NatureSource(
  'Ormancılık Araştırma Dergisi, 2025',
  'https://doi.org/10.17568/ogmoad.1727642',
);
const ogmStats = NatureSource(
  'OGM Ormancılık İstatistikleri',
  'https://www.ogm.gov.tr/tr/e-kutuphane/resmi-istatistikler',
);
const inaturalist = NatureSource('iNaturalist', 'https://www.inaturalist.org/');

class LessonCard {
  final String emoji;
  final Bi title;
  final Bi body;
  final List<NatureSource> sources;
  const LessonCard(this.emoji, this.title, this.body, this.sources);
}

class QuizQuestion {
  final Bi question;
  final List<Bi> options;
  final int correct;
  final Bi feedback;
  final NatureSource source;
  const QuizQuestion(this.question, this.options, this.correct, this.feedback, this.source);
}

class NatureLesson {
  final String id;
  final Bi title;
  final List<LessonCard> cards;
  final List<QuizQuestion> quiz;
  const NatureLesson(this.id, this.title, this.cards, this.quiz);
}

const List<NatureLesson> natureLessons = [
  NatureLesson(
    'see_fire',
    Bi('Yangın görürsen', 'If you see a fire'),
    [
      LessonCard('📞', Bi('Önce ara', 'Call first'), Bi('Ateş ya da duman görürsen hemen 112’yi ara. 177 orman yangını hattını da arayabilirsin.', 'If you see fire or smoke, call 112 right away. You can also call the 177 forest fire line.'), [ogmKonya]),
      LessonCard('☁️🛰️', Bi('Uydu her şeyi göremez', 'Satellites cannot see everything'), Bi('Bulut ya da kalın duman, yangını uydudan saklayabilir.', 'Clouds or thick smoke can hide a fire from satellites.'), [nasaFaq]),
      LessonCard('🚒', Bi('Yolu açık bırak', 'Keep the way clear'), Bi('Söndürme araçları köyden geçebilsin. Yollarını kapatma.', 'Firefighting vehicles must be able to pass through the village. Do not block their way.'), [ogmMugla]),
      LessonCard('🚪', Bi('Görevlileri dinle', 'Listen to the officials'), Bi('Yangın evlere yaklaşırsa kapı ve pencereleri kapat. Görevliler ne derse onu yap.', 'If a fire comes near houses, close doors and windows. Do what the officials say.'), [ogmMugla]),
    ],
    [
      QuizQuestion(Bi('Ormanda duman gördün. Önce ne yaparsın?', 'You see smoke in a forest. What do you do first?'), [Bi('112’yi ararım', 'I call 112'), Bi('Haritaya bakarım', 'I check the map'), Bi('Yaklaşıp fotoğraf çekerim', 'I go closer to take a photo')], 0, Bi('Önce ara. Uydular her yangını göremez.', 'Call first. Satellites cannot see every fire.'), ogmKonya),
      QuizQuestion(Bi('Haritada tespit yoksa, orada kesin yangın yok mu demektir?', 'If the map shows no detection, does that mean there is surely no fire?'), [Bi('Evet, kesin yoktur', 'Yes, surely none'), Bi('Hayır, uydu göremeyebilir', 'No, the satellite may not see it')], 1, Bi('Bulut ya da duman yangını saklayabilir.', 'Clouds or smoke can hide a fire.'), nasaFaq),
    ],
  ),
  NatureLesson(
    'how_fires_start',
    Bi('Yangınlar nasıl başlar?', 'How fires start'),
    [
      LessonCard('✨', Bi('Küçük bir kor yeter', 'A small ember is enough'), Bi('Sigara, sıcak kül ve havai fişek yangın çıkarabilir.', 'Cigarettes, hot ashes and fireworks can start a fire.'), [faoFire]),
      LessonCard('🚬', Bi('İzmarit', 'Cigarette ends'), Bi('Sigara izmariti iyice sönmeden atılmaz.', 'A cigarette end must not be thrown away before it is fully out.'), [ogmMugla]),
      LessonCard('🪵', Bi('Evin çevresi', 'Around the house'), Bi('Odun ve kozalakları evden uzakta biriktir.', 'Keep wood and cones away from the house.'), [ogmMugla]),
    ],
    [
      QuizQuestion(Bi('Hangisi yangın çıkarabilir?', 'Which of these can start a fire?'), [Bi('Sıcak kül', 'Hot ashes'), Bi('Yağmur suyu', 'Rainwater'), Bi('Taş duvar', 'A stone wall')], 0, Bi('Sıcak kül yangın çıkarabilir.', 'Hot ashes can start a fire.'), faoFire),
    ],
  ),
  NatureLesson(
    'after_fire',
    Bi('Yanan orman nasıl yenilenir?', 'How a burned forest recovers'),
    [
      LessonCard('🌲', Bi('Her yangın aynı değil', 'No two fires are the same'), Bi('Kastamonu’da yerdeki otları yakan bir yangından sonra en çok karaçam görüldü.', 'In Kastamonu, black pine was the most common tree after a fire that burned the ground.'), [forestJournal]),
      LessonCard('🌿', Bi('Tepeler yanınca', 'When the treetops burn'), Bi('Ağaç tepeleri de yanan yerde en çok laden adlı çalı görüldü.', 'Where the treetops burned too, a shrub called rockrose was the most common.'), [forestJournal]),
      LessonCard('🌱', Bi('Üç yol var', 'There are three ways'), Bi('Soma’da yanan orman için üç yol seçildi: Orman kendi yenilensin, insanlar yardım etsin, yeni ağaç dikilsin.', 'Three ways were chosen for the burned forest in Soma: let it renew itself, help it along, and plant new trees.'), [ogmSoma]),
      LessonCard('🛡️', Bi('Alan korunur', 'The area is protected'), Bi('Soma’daki alan yeniden yeşerene kadar korunacak.', 'The area in Soma will be protected until it is green again.'), [ogmSoma]),
    ],
    [
      QuizQuestion(Bi('Yanan bir orman için hangisi doğru?', 'Which is true of a burned forest?'), [Bi('Yangına göre sonuç değişebilir', 'The result can differ from fire to fire'), Bi('Hepsi aynı ormana döner', 'All return to the same forest'), Bi('Hiçbir şey yapılmaz', 'Nothing is ever done')], 0, Bi('Yangın ne kadar güçlüyse sonrası da ona göre değişir.', 'What comes after depends on how strong the fire was.'), forestJournal),
    ],
  ),
  NatureLesson(
    'turkey_numbers',
    Bi('Türkiye’de yangın sayıları', 'Fire numbers in Türkiye'),
    [
      LessonCard('🔥', Bi('En büyük yıl', 'The biggest year'), Bi('2016 ile 2025 arasında en çok orman 2021’de yandı.', 'Between 2016 and 2025, the most forest burned in 2021.'), [ogmStats]),
      LessonCard('🔢', Bi('Çok yangın, büyük yangın değil', 'Many fires are not big fires'), Bi('En çok yangın 2024’te çıktı. Ama en çok orman o yıl yanmadı.', 'The most fires started in 2024. But that was not the year the most forest burned.'), [ogmStats]),
      LessonCard('📉', Bi('Yıllar çok değişir', 'Years differ a lot'), Bi('En az alan 2018’de yandı. 2025’te bunun 14 katından fazlası yandı.', 'The least land burned in 2018. In 2025, more than 14 times that burned.'), [ogmStats]),
    ],
    [
      QuizQuestion(Bi('En çok yangın çıkan yıl, en çok orman yanan yıl mı?', 'Is the year with the most fires also the year the most forest burned?'), [Bi('Her zaman evet', 'Always yes'), Bi('Hayır, farklı yıllar', 'No, they are different years')], 1, Bi('En çok yangın 2024’te, en çok yanan alan 2021’de.', 'Most fires in 2024, most land burned in 2021.'), ogmStats),
    ],
  ),
];

enum NatureTaskKind { shareRisk, shareFact, burnedArea, citizenScience, doLesson, prevention }

class NatureTask {
  final String id;
  final NatureTaskKind kind;
  final Bi title;
  final Bi text;
  final NatureSource? source;
  final Set<int>? months;
  const NatureTask(this.id, this.kind, this.title, this.text, {this.source, this.months});
}

/// None of them asks anyone to go near a fire, and reporting a fire or
/// calling 112 is never a task or a reward.
const List<NatureTask> natureTasks = [
  NatureTask('share_risk', NatureTaskKind.shareRisk, Bi('📣 Riski bir yakınına söyle!', '📣 Tell someone about the risk!'), Bi('Bölgenin bugünkü yangın riskini bir yakınınla paylaş.', 'Share today’s fire risk for your region with someone close.')),
  NatureTask('share_fact', NatureTaskKind.shareFact, Bi('💡 Bir bilgi paylaş!', '💡 Share a fact!'), Bi('Bugünün bilgisini kaynağıyla birine gönder.', 'Send today’s fact and its source to someone.')),
  NatureTask('burned_area', NatureTaskKind.burnedArea, Bi('🗺️ İlinin geçmişine bak!', '🗺️ Look at your province’s past!'), Bi('Haritadaki Geçmiş yıllar katmanını aç.', 'Open the Past years layer on the map.')),
  NatureTask('inat', NatureTaskKind.citizenScience, Bi('🦋 Bir canlı fotoğrafla!', '🦋 Photograph a living thing!'), Bi('Gördüğün bir bitki ya da böceği bir büyüğünle iNaturalist’e ekle.', 'Add a plant or insect you saw to iNaturalist with an adult.'), source: inaturalist),
  NatureTask('lesson', NatureTaskKind.doLesson, Bi('📚 Bir ders bitir!', '📚 Finish a lesson!'), Bi('Kısa bir ders yap, yeni bir elma kazan.', 'Do a short lesson and win a new apple.')),
  NatureTask('wood', NatureTaskKind.prevention, Bi('🪵 Odunları evden uzağa al!', '🪵 Move the wood away from the house!'), Bi('Odun ve kozalakları evden uzakta biriktir.', 'Keep wood and cones away from the house.'), source: ogmMugla, months: {5, 6, 7, 8, 9, 10}),
  NatureTask('ash', NatureTaskKind.prevention, Bi('🔥 Külü soğumadan atma!', '🔥 Do not throw away hot ash!'), Bi('Sıcak kül yangın çıkarabilir. İyice soğumasını bekle, sonra at.', 'Hot ash can start a fire. Wait until it is fully cold, then throw it away.'), source: faoFire, months: {11, 12, 1, 2, 3}),
];
