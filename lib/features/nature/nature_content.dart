/// Everything shown in the Nature tab that states a fact. Each fact carries
/// the page it came from, and every page below was opened and checked on
/// 8 November 2026. Add nothing here without doing the same.
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

class NatureFact {
  final Bi text;
  final NatureSource source;
  const NatureFact(this.text, this.source);
}

const List<NatureFact> natureFacts = [
  NatureFact(Bi('Bulut, yoğun duman veya ağaç örtüsü bir yangını uydudan tamamen gizleyebilir.', 'Cloud, heavy smoke or tree canopy can hide a fire from satellites completely.'), nasaFaq),
  NatureFact(Bi('Çok küçük veya düşük sıcaklıktaki yangınları uydular tespit edemeyebilir.', 'Satellites may not detect fires that are very small or cool.'), nasaFaq),
  NatureFact(Bi('Sıcak kül, FAO’nun yangın nedenleri listesinde yer alır.', 'Hot ashes are on the FAO list of causes of vegetation fires.'), faoFire),
  NatureFact(Bi('Sigara izmariti tamamen söndürülmeden atılmamalıdır.', 'Cigarette ends should not be thrown away before they are fully out.'), ogmMugla),
  NatureFact(Bi('Odun ve kozalak gibi malzemeleri evlerden uzakta istiflemek yangın önlemlerindendir.', 'Stacking wood and cones away from houses is one of the fire precautions.'), ogmMugla),
  NatureFact(Bi('Kastamonu’daki bir araştırmada yerdeki örtüyü yakan yangından sonra karaçam baskın tür olarak kaldı.', 'In a Kastamonu study, black pine stayed dominant after a surface fire.'), forestJournal),
  NatureFact(Bi('Aynı araştırmada ağaç tepelerine çıkan yangının alanında baskın bitki defne yapraklı laden oldu.', 'In the same study, a rockrose shrub (Cistus laurifolius) was dominant where the fire reached the treetops.'), forestJournal),
  NatureFact(Bi('Soma’da 2024’te yanan 701 hektar ormanda OGM üç yöntem açıkladı: doğal gençleştirme, yapay gençleştirme ve ağaçlandırma.', 'For the 701 hectares of forest burned in Soma in 2024, OGM announced three methods: natural regeneration, artificial regeneration and afforestation.'), ogmSoma),
  NatureFact(Bi('2016-2025 arasında en çok alanın yandığı yıl 2021 oldu: 139.503 hektar.', 'Between 2016 and 2025, the year with the most burned area was 2021: 139,503 hectares.'), ogmStats),
  NatureFact(Bi('2016-2025 arasında en çok yangın çıkan yıl 2024 oldu: 3.797 yangın.', 'Between 2016 and 2025, the year with the most fires was 2024: 3,797 fires.'), ogmStats),
  NatureFact(Bi('2016-2025 arasında en az alanın yandığı yıl 2018 oldu: 5.644 hektar.', 'Between 2016 and 2025, the year with the least burned area was 2018: 5,644 hectares.'), ogmStats),
];

class LessonCard {
  final Bi title;
  final Bi body;
  final List<NatureSource> sources;
  const LessonCard(this.title, this.body, this.sources);
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
    Bi('Yangın görürseniz', 'If you see a fire'),
    [
      LessonCard(Bi('Önce arayın', 'Call first'), Bi('Ateş veya duman görürseniz 112 acil çağrıyı arayın. 177 orman yangını hattını da arayabilirsiniz.', 'If you see fire or smoke, call 112 emergency. You can also call the 177 forest fire line.'), [ogmKonya]),
      LessonCard(Bi('Haritaya bakıp beklemeyin', 'Do not wait for the map'), Bi('Bulut, yoğun duman veya ağaç örtüsü yangını uydudan gizleyebilir. Haritada görünmemesi yangın olmadığı anlamına gelmez.', 'Cloud, heavy smoke or tree canopy can hide a fire from satellites. Not being on the map does not mean there is no fire.'), [nasaFaq]),
      LessonCard(Bi('Araçların yolunu kapatmayın', 'Keep the way clear'), Bi('Söndürme araçlarının köy içinden geçmesini engelleyecek şeylerden kaçının.', 'Avoid anything that would stop firefighting vehicles passing through the village.'), [ogmMugla]),
      LessonCard(Bi('Talimatlara uyun', 'Follow instructions'), Bi('Yangın evlere yaklaşırsa kapı ve pencereleri kapatın. Görevlilerin talimatlarına göre hareket edin.', 'If a fire comes near houses, close doors and windows. Act on the instructions of the officials.'), [ogmMugla]),
    ],
    [
      QuizQuestion(Bi('Ormanda duman gördünüz. Önce ne yaparsınız?', 'You see smoke in a forest. What do you do first?'), [Bi('112’yi ararım', 'I call 112'), Bi('Haritada var mı diye bakarım', 'I check whether it is on the map'), Bi('Yaklaşıp fotoğraf çekerim', 'I go closer to take a photo')], 0, Bi('Önce arayın. Uydular her yangını göremez.', 'Call first. Satellites cannot see every fire.'), ogmKonya),
      QuizQuestion(Bi('Haritada tespit görünmüyor. Bu ne demek?', 'The map shows no detection. What does that mean?'), [Bi('Orada yangın yoktur', 'There is no fire there'), Bi('Uydular orada bir şey tespit etmedi', 'Satellites detected nothing there'), Bi('Yangın söndürülmüştür', 'The fire has been put out')], 1, Bi('Uydular bir yangını bulut veya duman yüzünden göremeyebilir.', 'Satellites can miss a fire because of cloud or smoke.'), nasaFaq),
    ],
  ),
  NatureLesson(
    'how_fires_start',
    Bi('Yangınlar nasıl başlar?', 'How fires start'),
    [
      LessonCard(Bi('Küçük bir kor yeter', 'A small ember is enough'), Bi('FAO’nun yangın nedenleri listesinde sigara, sıcak kül ve havai fişek gibi kor taşıyan şeyler var.', 'The FAO list of causes includes glowing objects such as cigarettes, hot ashes and fireworks.'), [faoFire]),
      LessonCard(Bi('İzmarit', 'Cigarette ends'), Bi('Sigara izmaritini tamamen söndürmeden atmayın.', 'Do not throw a cigarette end away before it is fully out.'), [ogmMugla]),
      LessonCard(Bi('Evin çevresi', 'Around the house'), Bi('Odun, kozalak ve benzeri malzemeleri evlerden uzakta istifleyin.', 'Stack wood, cones and similar materials away from houses.'), [ogmMugla]),
    ],
    [
      QuizQuestion(Bi('Hangisi yangın nedenleri listesinde yer alır?', 'Which of these is on the list of causes?'), [Bi('Sıcak kül', 'Hot ashes'), Bi('Yağmur suyu', 'Rainwater'), Bi('Taş duvar', 'A stone wall')], 0, Bi('Sıcak kül, kor taşıyan nedenler arasındadır.', 'Hot ashes are among the glowing causes.'), faoFire),
    ],
  ),
  NatureLesson(
    'after_fire',
    Bi('Yanan orman nasıl yenilenir?', 'How a burned forest recovers'),
    [
      LessonCard(Bi('Yangının şiddeti sonucu değiştirir', 'Fire severity changes the outcome'), Bi('Kastamonu’daki bir araştırmada yerdeki örtüyü yakan yangından sonra karaçam baskın tür olarak kaldı.', 'In a Kastamonu study, black pine stayed dominant after a surface fire.'), [forestJournal]),
      LessonCard(Bi('Tepe yangınından sonra', 'After a crown fire'), Bi('Aynı araştırmada ağaç tepelerine çıkan yangının alanında baskın bitki defne yapraklı laden oldu.', 'In the same study, a rockrose shrub was dominant where the fire reached the treetops.'), [forestJournal]),
      LessonCard(Bi('Tek yöntem yok', 'There is no single method'), Bi('Soma’da 701 hektar orman için OGM şu planı açıkladı: 249 hektar doğal gençleştirme, 240 hektar yapay gençleştirme, 212 hektar ağaçlandırma.', 'For 701 hectares of forest in Soma, OGM announced: 249 hectares natural regeneration, 240 artificial regeneration, 212 afforestation.'), [ogmSoma]),
      LessonCard(Bi('Alan korunur', 'The area is protected'), Bi('OGM’ye göre Soma’daki saha, yeşil örtü yeniden oluşana kadar koruma altında tutulacak.', 'According to OGM, the Soma site will be protected until green cover forms again.'), [ogmSoma]),
    ],
    [
      QuizQuestion(Bi('Yanan bir alan için hangisi doğru?', 'Which is true of a burned area?'), [Bi('Yangının şiddetine göre sonuç değişebilir', 'The outcome can differ with fire severity'), Bi('Her alan aynı ormana döner', 'Every area returns to the same forest'), Bi('Yanan alana hiçbir şey yapılmaz', 'Nothing is ever done on a burned area')], 0, Bi('Yangının şiddeti sonrasında gelen bitkileri etkiler.', 'Fire severity affects which plants come back.'), forestJournal),
    ],
  ),
  NatureLesson(
    'turkey_numbers',
    Bi('Türkiye’de yangın sayıları', 'Fire numbers in Türkiye'),
    [
      LessonCard(Bi('En büyük yıl', 'The largest year'), Bi('2016-2025 arasında en çok alanın yandığı yıl 2021: 139.503 hektar.', 'Between 2016 and 2025, the year with the most burned area was 2021: 139,503 hectares.'), [ogmStats]),
      LessonCard(Bi('Yangın sayısı ve alan aynı şey değil', 'Number of fires is not burned area'), Bi('En çok yangın 2024’te çıktı (3.797), ama o yıl yanan alan 27.485 hektardı.', 'The most fires were in 2024 (3,797), but the burned area that year was 27,485 hectares.'), [ogmStats]),
      LessonCard(Bi('Yıllar çok değişir', 'Years differ widely'), Bi('En az alanın yandığı yıl 2018: 5.644 hektar. 2025’te 81.473 hektar yandı.', 'The least burned area was in 2018: 5,644 hectares. In 2025, 81,473 hectares burned.'), [ogmStats]),
    ],
    [
      QuizQuestion(Bi('En çok yangın çıkan yıl, en çok alanın yandığı yıl mıdır?', 'Is the year with the most fires also the year with the most burned area?'), [Bi('Her zaman evet', 'Always yes'), Bi('Hayır, 2016-2025 verisinde farklı yıllar', 'No, in the 2016-2025 data they are different years')], 1, Bi('En çok yangın 2024’te, en çok yanan alan 2021’de.', 'Most fires in 2024, most burned area in 2021.'), ogmStats),
    ],
  ),
];

enum NatureTaskKind { shareRisk, shareFact, burnedArea, citizenScience, doLesson, prevention }

class NatureTask {
  final String id;
  final NatureTaskKind kind;
  final Bi text;
  final NatureSource? source;
  final Set<int>? months;
  const NatureTask(this.id, this.kind, this.text, {this.source, this.months});
}

/// Data-linked first; a task saying only "be good" does not belong here.
/// None of them asks anyone to go near a fire, and reporting a fire or
/// calling 112 is never a task or a reward.
const List<NatureTask> natureTasks = [
  NatureTask('share_risk', NatureTaskKind.shareRisk, Bi('Bölgenizin bugünkü yangın riskini bir yakınınızla paylaştınız mı?', 'Did you share your region’s fire risk today with someone close?')),
  NatureTask('share_fact', NatureTaskKind.shareFact, Bi('Günün doğa bilgisini kaynağıyla birlikte paylaştınız mı?', 'Did you share today’s nature fact with its source?')),
  NatureTask('burned_area', NatureTaskKind.burnedArea, Bi('İlinizin yanan alan geçmişine haritadaki Geçmiş yıllar katmanından baktınız mı?', 'Did you check your province’s burned-area history on the map’s Past years layer?')),
  NatureTask('inat', NatureTaskKind.citizenScience, Bi('Gördüğünüz bir bitki veya hayvanı iNaturalist’e eklediniz mi? Gözlemler bilim insanlarının kullandığı açık veriye dönüşür.', 'Did you add a plant or animal you saw to iNaturalist? Observations become open data used by scientists.'), source: inaturalist),
  NatureTask('lesson', NatureTaskKind.doLesson, Bi('Bugün kısa bir ders bitirdiniz mi?', 'Did you finish a short lesson today?')),
  NatureTask('wood', NatureTaskKind.prevention, Bi('Evinizin çevresindeki odun ve kozalakları evden uzağa aldınız mı?', 'Did you move wood and cones away from your house?'), source: ogmMugla, months: {5, 6, 7, 8, 9, 10}),
  NatureTask('ash', NatureTaskKind.prevention, Bi('Soba veya şömine külünü tamamen soğuduğundan emin olduktan sonra mı attınız?', 'Did you make sure stove or fireplace ash was fully cold before throwing it away?'), source: faoFire, months: {11, 12, 1, 2, 3}),
];

enum WeeklyGoal { days, lesson, shares }
