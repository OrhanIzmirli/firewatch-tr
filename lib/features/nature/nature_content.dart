/// Lessons and tasks in the Fidan section. Written so a child can follow
/// them; each claim carries the page it came from, and every page below was
/// opened and checked on 8 November 2026. Add nothing without doing the same.
library;

import 'tree.dart' show LessonArt;

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

const ogmHarvest = NatureSource('OGM, Hasat mevsimi uyarısı', 'https://www.ogm.gov.tr/tr/haberler/hasat-mevsiminde-orman-yangini-alarmi');
const ogmHuman = NatureSource('OGM', 'https://www.ogm.gov.tr/tr/haberler/orman-yanginlarina-karsi-bilinclendirme-seferberligi-milyonlara-ulasti');
const ogmBursa = NatureSource('OGM Bursa, 2026 komisyon kararları', 'https://www.ogm.gov.tr/bursaobm/duyurular/2026-yili-bursa-ili-orman-yanginlarini-onleme-ve-mucadele-komisyon-kararlari');
const ogmKizilcam = NatureSource('OGM, Kızılçam', 'https://www.ogm.gov.tr/tr/yararli-bilgiler/haftanin-agaci/kizilcam');
const ogmKaracam = NatureSource('OGM, Karaçam', 'https://www.ogm.gov.tr/tr/yararli-bilgiler/haftanin-agaci/karacam');
const ogmTitrek = NatureSource('OGM, Titrek kavak', 'https://www.ogm.gov.tr/tr/yararli-bilgiler/haftanin-agaci/titrek-kavak');
const ogmPlantingDay = NatureSource('OGM Amasya', 'https://www.ogm.gov.tr/amasyaobm/haberler/11-kasim-milli-agaclandirma-gunu');
const ogmConstitution = NatureSource('OGM', 'https://www.ogm.gov.tr/tr/haberler/yanan-alanlarimizda-11-kasim-milli-agaclandirma-gunu%E2%80%99nde-fidanlarimiz-toprakla-bulusuyor');
const smokeySafety = NatureSource('Smokey Bear (USDA)', 'https://smokeybear.com/campfire-safety');
const smokeyRules = NatureSource('Smokey Bear (USDA)', 'https://smokeybear.com/campfire-rules');
const smokeyGrill = NatureSource('Smokey Bear (USDA)', 'https://smokeybear.com/outdoor-grilling-safety');
const nasaFirmsFaq = NatureSource('NASA FIRMS', 'https://www.earthdata.nasa.gov/faq/firms-faq');
const nasaFirms = NatureSource('NASA FIRMS', 'https://www.earthdata.nasa.gov/data/tools/firms');
const nasaYellowstone = NatureSource('NASA Earth Observatory', 'https://science.nasa.gov/earth/earth-observatory/world-of-change/burn-recovery-in-yellowstone/');
const npsAztec = NatureSource('US National Park Service, Aztec Ruins', 'https://www.nps.gov/azru/learn/nature/dendrochronology.htm');
const npsBehavior = NatureSource('US National Park Service', 'https://www.nps.gov/articles/wildland-fire-behavior.htm');
const npsGlacier = NatureSource('NPS, Glacier', 'https://www.nps.gov/glac/learn/nature/fire-ecology.htm');
const npsYellowstone = NatureSource('NPS, Yellowstone', 'https://www.nps.gov/yell/learn/nature/ecological-consequences-of-fire.htm');
const npsSkyIsland = NatureSource('US National Park Service', 'https://www.nps.gov/articles/sky-island-fire-ecology.htm');
const npsLeaves = NatureSource('US National Park Service', 'https://www.nps.gov/articles/why-do-leaves-change-in-the-fall.htm');
const npsBatBenefits = NatureSource('US National Park Service', 'https://www.nps.gov/subjects/bats/benefits-of-bats.htm');
const npsBats = NatureSource('US National Park Service', 'https://www.nps.gov/grba/learn/nature/bats.htm');
const npsPollinators = NatureSource('US National Park Service', 'https://www.nps.gov/subjects/pollinators/index.htm');
const npsBears = NatureSource('US National Park Service', 'https://www.nps.gov/subjects/bears/brown-bears.htm');
const npsHoneybees = NatureSource('US National Park Service', 'https://www.nps.gov/foma/learn/nature/honeybees.htm');
const noaaRings = NatureSource('NOAA', 'https://oceanservice.noaa.gov/education/dyw-tree-detective.html');
const noaaBlaze = NatureSource('NOAA NSSL', 'https://www.nssl.noaa.gov/education/students/wxfriendscards/txt/blaze.html');
const noaaSpread = NatureSource('NOAA NESDIS', 'https://www.nesdis.noaa.gov/about/k-12-education/dust-ash-fire-smoke/how-do-wildfires-spread');
const nistEmbers = NatureSource('NIST', 'https://www.nist.gov/el/fire-research-division-73300/wildland-urban-interface-fire-73305/hazard-mitigation-methodology-4');
const arborAnatomy = NatureSource('Arbor Day Foundation', 'https://www.arborday.org/tree-guide/anatomy-tree');
const rhsPlants = NatureSource('Royal Horticultural Society', 'https://www.rhs.org.uk/advice/understanding-plants/how-plants-grow');
const ucRoots = NatureSource('University of California IPM', 'https://ipm.ucanr.edu/home-and-landscape/provide-for-roots/');
const woodlandLife = NatureSource('Woodland Trust', 'https://www.woodlandtrust.org.uk/blog/2019/06/tree-lifecycle/');
const woodlandOak = NatureSource('Woodland Trust', 'https://www.woodlandtrust.org.uk/trees-woods-and-wildlife/british-trees/a-z-of-british-trees/english-oak/');
const woodlandSquirrel = NatureSource('Woodland Trust', 'https://www.woodlandtrust.org.uk/trees-woods-and-wildlife/animals/mammals/red-squirrel/');
const woodlandJay = NatureSource('Woodland Trust', 'https://www.woodlandtrust.org.uk/trees-woods-and-wildlife/animals/birds/jay/');
const woodlandHedgehog = NatureSource('Woodland Trust', 'https://www.woodlandtrust.org.uk/trees-woods-and-wildlife/animals/mammals/hedgehog/');
const forestryOak = NatureSource('Forestry England', 'https://www.forestryengland.uk/tree-species/english-oak');
const forestryAsh = NatureSource('Forestry England', 'https://www.forestryengland.uk/tree-species/ash');
const forestryBirch = NatureSource('Forestry England', 'https://www.forestryengland.uk/tree-species/silver-birch');
const forestryBeech = NatureSource('Forestry England', 'https://www.forestryengland.uk/tree-species/beech');
const faoWater = NatureSource('FAO', 'https://www.fao.org/sustainable-forest-management-toolbox/modules/forest-and-water/en');
const faoSoil = NatureSource('FAO', 'https://www.fao.org/soils-portal/soil-biodiversity/facts-and-figures/en/');
const faoRedPine = NatureSource('FAO', 'https://www.fao.org/4/e8705e/E8705E07.htm');
const usdaWater = NatureSource('USDA Forest Service', 'https://research.fs.usda.gov/srs/articles/forests-faucets-where-does-your-drinking-water-come');
const usdaSoil = NatureSource('USDA', 'https://www.ars.usda.gov/plains-area/sidney-mt/northern-plains-agricultural-research-laboratory/nparl-docs/just-for-kids/soils-organisms/');
const pennLeaves = NatureSource('Penn State Extension', 'https://extension.psu.edu/the-science-behind-autumn-leaf-color');
const ptesDormouse = NatureSource('PTES', 'https://ptes.org/campaigns/dormice/about-hazel-dormice/');
const nhmHoney = NatureSource('Natural History Museum', 'https://www.nhm.ac.uk/discover/what-is-honey.html');
const nhmStag = NatureSource('Natural History Museum', 'https://www.nhm.ac.uk/discover/stag-beetles.html');
const askBees = NatureSource('Ask A Biologist', 'https://askabiologist.asu.edu/honey-bee-communication');
const birdlifeStork = NatureSource('BirdLife International', 'https://www.birdlife.org/news/2024/03/13/migratory-bird-of-the-month-white-stork/');
const rspbSwift = NatureSource('RSPB', 'https://www.rspb.org.uk/birds-and-wildlife/swift');
const audubonOwl = NatureSource('Audubon', 'https://www.audubon.org/news/how-do-barn-owls-fly-so-silently');
const zooWolf = NatureSource('Smithsonian’s National Zoo', 'https://nationalzoo.si.edu/animals/gray-wolf');
const readyWildfires = NatureSource('Ready.gov', 'https://www.ready.gov/wildfires');
const readyKit = NatureSource('Ready.gov', 'https://www.ready.gov/kit');
const readyPlan = NatureSource('Ready.gov', 'https://www.ready.gov/plan');
const readyQuake = NatureSource('Ready.gov', 'https://www.ready.gov/earthquakes');
const readyFloods = NatureSource('Ready.gov', 'https://www.ready.gov/floods');
const cdcSmoke = NatureSource('US CDC', 'https://www.cdc.gov/wildfires/about/index.html');

class LessonCard {
  final LessonArt art;
  final Bi title;
  final Bi body;
  final List<NatureSource> sources;
  const LessonCard(this.art, this.title, this.body, this.sources);
}

/// What every kind of question shares: one sentence of explanation and the
/// page, or pages, it came from.
sealed class LessonQuestion {
  final Bi feedback;
  final NatureSource source;
  final List<NatureSource> also;
  const LessonQuestion(this.feedback, this.source, {this.also = const []});

  List<NatureSource> get sources => [source, ...also];
}

/// Three or four choices, one of them right.
class QuizQuestion extends LessonQuestion {
  final Bi question;
  final List<Bi> options;
  final int correct;
  const QuizQuestion(this.question, this.options, this.correct, super.feedback, super.source, {super.also});
}

/// A picture and a sentence that is either true or false.
class TrueFalseQuestion extends LessonQuestion {
  final LessonArt art;
  final Bi statement;
  final bool isTrue;
  const TrueFalseQuestion(this.art, this.statement, this.isTrue, super.feedback, super.source, {super.also});
}

/// Put the steps in order. [steps] is written in the right order; the screen
/// mixes them up.
class OrderQuestion extends LessonQuestion {
  final Bi prompt;
  final List<Bi> steps;
  const OrderQuestion(this.prompt, this.steps, super.feedback, super.source, {super.also});
}

/// Join each left item to its right item. [pairs] are written matched.
class MatchQuestion extends LessonQuestion {
  final Bi prompt;
  final List<(Bi, Bi)> pairs;
  const MatchQuestion(this.prompt, this.pairs, super.feedback, super.source, {super.also});
}

class NatureLesson {
  final String id;
  final Bi title;
  final List<LessonCard> cards;
  final List<LessonQuestion> quiz;
  const NatureLesson(this.id, this.title, this.cards, this.quiz);
}

class NatureSection {
  final String id;
  final Bi title;
  final LessonArt art;
  final int color;
  final List<NatureLesson> lessons;
  const NatureSection(this.id, this.title, this.art, this.color, this.lessons);
}

/// A stable number for a piece of text; String.hashCode is not promised to
/// stay the same between runs.
int textSeed(String text) => text.codeUnits.fold(17, (h, c) => (h * 31 + c) & 0x7fffffff);

/// The numbers 0 to n-1 mixed up, the same way every time for a seed, and
/// never already in order, so a question cannot start out solved.
List<int> scrambled(int n, int seed) {
  final out = List<int>.generate(n, (i) => i);
  var r = seed & 0x7fffffff;
  for (var i = n - 1; i > 0; i--) {
    r = (r * 1103515245 + 12345) & 0x7fffffff;
    final j = (r >> 8) % (i + 1);
    final t = out[i];
    out[i] = out[j];
    out[j] = t;
  }
  if (n > 1 && isInOrder(out)) out.add(out.removeAt(0));
  return out;
}

bool isInOrder(List<int> arrangement) {
  for (var i = 0; i < arrangement.length; i++) {
    if (arrangement[i] != i) return false;
  }
  return true;
}

/// The list with one item moved so that it ends up at [to].
List<T> movedItem<T>(List<T> items, int from, int to) {
  final out = [...items];
  out.insert(to, out.removeAt(from));
  return out;
}

/// In which order the choices of a question are shown, so that the right
/// answer does not always sit in the same place.
List<int> optionOrder(QuizQuestion q) => scrambled(q.options.length, textSeed(q.question.tr));

/// Right-hand items of a matching question, as shown.
List<int> matchOrder(MatchQuestion q) => scrambled(q.pairs.length, textSeed(q.prompt.tr));

/// Steps of an ordering question, as first shown.
List<int> stepOrder(OrderQuestion q) => scrambled(q.steps.length, textSeed(q.prompt.tr));

const _fireLessons = [
  NatureLesson(
    'see_fire',
    Bi('Yangın görürsen', 'If you see a fire'),
    [
      LessonCard(LessonArt.phone, Bi('Önce ara', 'Call first'), Bi('Ateş ya da duman görürsen hemen 112’yi ara.', 'If you see fire or smoke, call 112 right away.'), [ogmKonya]),
      LessonCard(LessonArt.smoke, Bi('En küçük duman bile', 'Even the smallest smoke'), Bi('Ormanda gördüğün en küçük duman bile haber vermeye değer.', 'Even the smallest smoke you see in a forest is worth reporting.'), [ogmHarvest]),
      LessonCard(LessonArt.truck, Bi('Yolu açık bırak', 'Keep the way clear'), Bi('Söndürme araçları köyden geçebilsin. Yollarını kapatma.', 'Firefighting vehicles must be able to pass through the village. Do not block their way.'), [ogmMugla]),
      LessonCard(LessonArt.house, Bi('Görevlileri dinle', 'Listen to the officials'), Bi('Yangın evlere yaklaşırsa kapı ve pencereleri kapat. Görevliler ne derse onu yap.', 'If a fire comes near houses, close doors and windows. Do what the officials say.'), [ogmMugla]),
      LessonCard(LessonArt.ember, Bi('Yaklaşma', 'Do not go near'), Bi('Bursa’da gönüllüler bile izin almadan ateşe yakın yere giremez. Sen de yaklaşma, 112’yi ara.', 'In Bursa, even volunteers may not go near a fire without permission. Do not go near it either: call 112.'), [ogmBursa]),
    ],
    [
      QuizQuestion(Bi('Ormanda duman gördün. Önce ne yaparsın?', 'You see smoke in a forest. What do you do first?'), [Bi('112’yi ararım', 'I call 112'), Bi('Haritaya bakarım', 'I check the map'), Bi('Yaklaşıp fotoğraf çekerim', 'I go closer to take a photo')], 0, Bi('Duman görünce ilk iş 112’yi aramaktır.', 'When you see smoke, the first thing to do is call 112.'), ogmKonya),
      TrueFalseQuestion(LessonArt.smoke, Bi('En küçük duman bile 112’ye haber verilmeli.', 'Even the smallest smoke should be reported to 112.'), true, Bi('Orman Genel Müdürlüğü en küçük dumanın bile bildirilmesini istiyor.', 'The forest service asks people to report even the smallest smoke.'), ogmHarvest),
      OrderQuestion(Bi('Yangın gördün. Sırayla ne yaparsın?', 'You see a fire. What do you do, in order?'), [Bi('112’yi ararım', 'I call 112'), Bi('Nerede olduğumu söylerim', 'I say where I am'), Bi('Görevliler ne derse onu yaparım', 'I do what the officials say'), Bi('“Güvenli” denince eve dönerim', 'I go home once they say it is safe')], Bi('Her şeyden önce 112 aranır, eve dönmek için de görevlilerin sözü beklenir.', 'You call 112 before anything else, and you wait for the officials before going home.'), ogmKonya, also: [readyWildfires, ogmMugla]),
      MatchQuestion(Bi('Hangi durumda ne yapılır?', 'What do you do in each case?'), [(Bi('Duman gördün', 'You see smoke'), Bi('112’yi ara', 'Call 112')), (Bi('Alevler evlere yaklaştı', 'Flames came near houses'), Bi('Kapı ve pencereleri kapat', 'Close doors and windows')), (Bi('Söndürme aracı geçecek', 'A fire engine must pass'), Bi('Yolu açık bırak', 'Keep the way clear'))], Bi('Duman görünce 112 aranır, alev yaklaşınca kapılar kapanır, yol da açık bırakılır.', 'You call 112 for smoke, close up when flames come near, and keep the road clear.'), ogmKonya, also: [ogmMugla]),
    ],
  ),
  NatureLesson(
    'how_fires_start',
    Bi('Yangınlar nasıl başlar?', 'How fires start'),
    [
      LessonCard(LessonArt.ember, Bi('Küçük bir kor yeter', 'A small ember is enough'), Bi('Sigara, sıcak kül ve havai fişek yangın çıkarabilir.', 'Cigarettes, hot ashes and fireworks can start a fire.'), [faoFire]),
      LessonCard(LessonArt.match, Bi('Çoğunu insanlar başlatır', 'People start most of them'), Bi('Türkiye’de orman yangınlarının çok büyük bölümü insan yüzünden çıkıyor. Dikkat edersek pek çoğunu önleyebiliriz!', 'Most forest fires in Türkiye are caused by people. If we are careful, we can prevent many of them!'), [ogmHuman]),
      LessonCard(LessonArt.house, Bi('Evin çevresi', 'Around the house'), Bi('Odun ve kozalakları evden uzakta biriktir.', 'Keep wood and cones away from the house.'), [ogmMugla]),
      LessonCard(LessonArt.wind, Bi('Tarladan ormana', 'From field to forest'), Bi('Tarlada başlayan bir yangın rüzgârla ormana sıçrayabilir.', 'A fire that starts in a field can jump into a forest with the wind.'), [ogmHarvest]),
    ],
    [
      QuizQuestion(Bi('Hangisi yangın çıkarabilir?', 'Which of these can start a fire?'), [Bi('Sıcak kül', 'Hot ashes'), Bi('Yağmur suyu', 'Rainwater'), Bi('Taş duvar', 'A stone wall')], 0, Bi('Sıcak kül yangın çıkarabilir.', 'Hot ashes can start a fire.'), faoFire),
      TrueFalseQuestion(LessonArt.ember, Bi('Sigara izmariti iyice sönmeden atılmamalı.', 'A cigarette end must not be thrown away before it is fully out.'), true, Bi('Sönmemiş bir izmarit yangın çıkarabilir, bu yüzden atılmaz.', 'A cigarette end that is still burning can start a fire, so it must not be thrown away.'), ogmMugla, also: [faoFire]),
    ],
  ),
  NatureLesson(
    'campfire',
    Bi('Piknikte ateş', 'Fire at a picnic'),
    [
      LessonCard(LessonArt.grill, Bi('Hâlâ sıcaksa bırakma', 'If it is hot, do not leave'), Bi('Ateşin yeri hâlâ sıcaksa orayı bırakıp gitmek olmaz.', 'If the fire’s place is still hot, it must not be left.'), [smokeySafety]),
      LessonCard(LessonArt.ember, Bi('Taşlar da ısınır', 'Stones get hot too'), Bi('Ateşin çevresindeki taşlar çabuk ısınır ve uzun süre sıcak kalır. Üstlerine oturma!', 'The stones around a fire heat up fast and stay hot for a long time. Do not sit on them!'), [smokeyRules]),
      LessonCard(LessonArt.grill, Bi('Mangal kömürü', 'Barbecue charcoal'), Bi('İçten içe yanan kömür yangın çıkarabilir. Tamamen soğumadan çöpe atılmaz.', 'Charcoal that is still smouldering can start a fire. It must not go in the bin until it is fully cold.'), [smokeyGrill]),
      LessonCard(LessonArt.house, Bi('Dışarıda ocak yakma', 'No outdoor cooking fires'), Bi('Yemek için bile dışarıda ocak ateşi yakma.', 'Do not light a cooking fire outdoors, even to make food.'), [ogmMugla]),
    ],
    [
      QuizQuestion(Bi('Mangal kömürü ne zaman çöpe atılır?', 'When can barbecue charcoal go in the bin?'), [Bi('Tamamen soğuyunca', 'When it is fully cold'), Bi('Hâlâ kızgınken', 'While it is still glowing'), Bi('İçinden duman çıkarken', 'While smoke is coming from it')], 0, Bi('Kömür tamamen soğumadan çöpe atılmaz.', 'Charcoal must be fully cold before it goes in the bin.'), smokeyGrill),
      TrueFalseQuestion(LessonArt.ember, Bi('Ateşin çevresindeki taşlara oturmak güvenlidir.', 'It is safe to sit on the stones around a fire.'), false, Bi('Bu taşlar çabuk ısınır ve uzun süre sıcak kalır.', 'Those stones heat up fast and stay hot for a long time.'), smokeyRules),
      OrderQuestion(Bi('Mangal bitti. Sırası nasıl?', 'The barbecue is over. What is the order?'), [Bi('Mangal biter', 'The barbecue ends'), Bi('Kömür tamamen soğur', 'The charcoal gets fully cold'), Bi('Soğuk kömür çöpe atılır', 'The cold charcoal goes in the bin')], Bi('Kömür önce tamamen soğur, sonra çöpe atılır.', 'Charcoal first gets fully cold, and only then goes in the bin.'), smokeyGrill),
    ],
  ),
  NatureLesson(
    'matches',
    Bi('Kibrit ve çakmak', 'Matches and lighters'),
    [
      LessonCard(LessonArt.match, Bi('Kibrit bulursan', 'If you find matches'), Bi('Kibrit ya da çakmak bulursan onlarla oynama. Bir büyüğüne nerede olduklarını söyle.', 'If you find matches or a lighter, do not play with them. Tell a grown-up where they are.'), [smokeyRules]),
      LessonCard(LessonArt.family, Bi('Küçüklere de anlat', 'Tell the little ones too'), Bi('Küçük çocukları yangın konusunda uyarmak gerekir.', 'Small children need to be warned about fires.'), [ogmMugla]),
      LessonCard(LessonArt.ember, Bi('Kül bile tehlikeli', 'Even ash is dangerous'), Bi('Küller de tehlikelidir. Sakın eline değdirme!', 'Ashes are dangerous too. Never touch them!'), [smokeySafety]),
    ],
    [
      QuizQuestion(Bi('Yerde bir çakmak buldun. Ne yaparsın?', 'You find a lighter on the ground. What do you do?'), [Bi('Bir büyüğüme söylerim', 'I tell a grown-up'), Bi('Yakıp denerim', 'I try lighting it'), Bi('Arkadaşıma atarım', 'I throw it to a friend')], 0, Bi('Çakmakla oynanmaz, bir büyüğüne nerede olduğunu söylersin.', 'Lighters are not toys, so you tell a grown-up where it is.'), smokeyRules),
      TrueFalseQuestion(LessonArt.match, Bi('Kibritle oynamak güvenlidir.', 'Playing with matches is safe.'), false, Bi('Kibrit ve çakmakla asla oynanmaz.', 'Matches and lighters are never for playing.'), smokeyRules),
    ],
  ),
  NatureLesson(
    'wind_fire',
    Bi('Yangın neden hızlanır?', 'Why fires speed up'),
    [
      LessonCard(LessonArt.wind, Bi('Rüzgâr ateşi iter', 'Wind pushes fire'), Bi('Rüzgâr yangına taze hava taşır ve onu yeni bitkilere doğru iter.', 'Wind brings a fire fresh air and pushes it toward new plants.'), [npsBehavior]),
      LessonCard(LessonArt.smoke, Bi('Yokuşu sever', 'It likes going uphill'), Bi('Yangın genelde yokuş yukarı daha hızlı ilerler.', 'A fire usually moves faster uphill.'), [npsBehavior]),
      LessonCard(LessonArt.ember, Bi('Uçan közler', 'Flying embers'), Bi('Közler kilometrelerce uçup yeni yangınlar başlatabilir.', 'Embers can fly for kilometres and start new fires.'), [nistEmbers]),
      LessonCard(LessonArt.wind, Bi('Sıcak ve kuru hava', 'Hot, dry weather'), Bi('Hava sıcak, kuru ve rüzgârlı olunca yangınlar daha kolay başlar ve yayılır.', 'When the weather is hot, dry and windy, fires start and spread more easily.'), [noaaBlaze]),
    ],
    [
      QuizQuestion(Bi('Yangın genelde nereye doğru daha hızlı ilerler?', 'Which way does a fire usually move faster?'), [Bi('Yokuş yukarı', 'Uphill'), Bi('Yokuş aşağı', 'Downhill'), Bi('Düz bir yolda', 'Along a flat road')], 0, Bi('Yangın genelde yokuş yukarı daha hızlı gider.', 'A fire usually goes faster uphill.'), npsBehavior),
      QuizQuestion(Bi('Yangınlar hangi havada daha kolay yayılır?', 'In which weather do fires spread more easily?'), [Bi('Sıcak, kuru ve rüzgârlı', 'Hot, dry and windy'), Bi('Serin ve yağmurlu', 'Cool and rainy'), Bi('Karlı ve sakin', 'Snowy and still')], 0, Bi('Sıcak, kuru ve rüzgârlı havada yangınlar kolay yayılır.', 'Fires spread easily in hot, dry and windy weather.'), noaaBlaze),
      TrueFalseQuestion(LessonArt.ember, Bi('Közler uçup uzaklarda yeni yangın başlatabilir.', 'Embers can fly away and start new fires far off.'), true, Bi('Közler kilometrelerce ileri gidebilir.', 'Embers can travel for kilometres.'), nistEmbers),
    ],
  ),
  NatureLesson(
    'satellites',
    Bi('Uydular neyi görür?', 'What satellites can see'),
    [
      LessonCard(LessonArt.satellite, Bi('Uydu her şeyi göremez', 'Satellites cannot see everything'), Bi('Bulut ya da kalın duman yangını uydudan saklayabilir.', 'Clouds or thick smoke can hide a fire from satellites.'), [nasaFirmsFaq]),
      LessonCard(LessonArt.smoke, Bi('Küçük yangınlar', 'Small fires'), Bi('Bazı yangınlar uydunun fark etmesi için fazla küçüktür.', 'Some fires are too small for a satellite to notice.'), [nasaFirmsFaq]),
      LessonCard(LessonArt.satellite, Bi('Sıcak nokta ne olabilir?', 'What can a hot spot be?'), Bi('Uydunun gördüğü sıcak nokta her zaman orman yangını değildir. Bazen yanardağ olabilir!', 'A hot spot a satellite sees is not always a forest fire. Sometimes it can be a volcano!'), [nasaFirmsFaq]),
      LessonCard(LessonArt.calendar, Bi('Harita biraz geriden gelir', 'The map runs a little behind'), Bi('Uydu bilgileri haritaya 3 saat içinde gelir. Gördüğün şey birkaç saat öncesi olabilir.', 'Satellite data reach the map within 3 hours. What you see may be a few hours old.'), [nasaFirms]),
    ],
    [
      QuizQuestion(Bi('Haritada yangın işareti yok. Bu ne demek?', 'The map shows no fire mark. What does that mean?'), [Bi('Uydu görmemiş olabilir', 'The satellite may not have seen it'), Bi('Orada kesin yangın yok', 'There is surely no fire there'), Bi('Yangın kesin bitti', 'The fire is surely over')], 0, Bi('Bulut ya da duman yangını uydudan saklayabilir.', 'Clouds or smoke can hide a fire from satellites.'), nasaFirmsFaq),
      TrueFalseQuestion(LessonArt.satellite, Bi('Uydunun gördüğü her sıcak nokta orman yangınıdır.', 'Every hot spot a satellite sees is a forest fire.'), false, Bi('Bazen yanardağ ya da gaz kuyusunun alevi olabilir.', 'Sometimes it is a volcano or the flame of a gas well.'), nasaFirmsFaq),
      QuizQuestion(Bi('Duman görüyorsun ama haritada yangın yok. Ne yaparsın?', 'You see smoke but the map shows no fire. What do you do?'), [Bi('112’yi ararım', 'I call 112'), Bi('Haritanın değişmesini beklerim', 'I wait for the map to change'), Bi('Yaklaşıp bakarım', 'I go closer to look')], 0, Bi('Haritayı bekleme, duman gördüysen hemen ara.', 'Do not wait for the map: if you see smoke, call right away.'), ogmKonya, also: [nasaFirmsFaq]),
    ],
  ),
  NatureLesson(
    'turkey_numbers',
    Bi('Çok yangın, büyük yangın değil', 'Many fires are not big fires'),
    [
      LessonCard(LessonArt.calendar, Bi('En büyük yıl', 'The biggest year'), Bi('2016 ile 2025 arasında en çok orman 2021’de yandı.', 'Between 2016 and 2025, the most forest burned in 2021.'), [ogmStats]),
      LessonCard(LessonArt.calendar, Bi('Bir bilmece gibi', 'Like a riddle'), Bi('En çok yangın 2024’te çıktı. Ama en çok orman o yıl yanmadı.', 'The most fires started in 2024. But that was not the year the most forest burned.'), [ogmStats]),
    ],
    [
      TrueFalseQuestion(LessonArt.calendar, Bi('En çok yangının çıktığı yılda en çok orman da yandı.', 'The year with the most fires was also the year the most forest burned.'), false, Bi('En çok yangın 2024’te, en çok yanan alan 2021’de.', 'Most fires in 2024, most land burned in 2021.'), ogmStats),
      QuizQuestion(Bi('2016 ile 2025 arasında en çok orman hangi yılda yandı?', 'Between 2016 and 2025, in which year did the most forest burn?'), [Bi('2021', '2021'), Bi('2018', '2018'), Bi('2024', '2024')], 0, Bi('En çok orman 2021’de yandı.', 'The most forest burned in 2021.'), ogmStats),
    ],
  ),
];

const _forestLessons = [
  NatureLesson(
    'tree_rings',
    Bi('Ağaç halkaları', 'Tree rings'),
    [
      LessonCard(LessonArt.rings, Bi('En yaşlısı ortada', 'The oldest is in the middle'), Bi('Bir ağacın en yaşlı halkaları ortadadır. Kabuğun hemen altındaki halka bu yıl oluşmuştur!', 'A tree’s oldest rings are in the middle. The ring just under the bark formed this year!'), [noaaRings]),
      LessonCard(LessonArt.rings, Bi('Halkalar havayı anlatır', 'Rings tell about the weather'), Bi('Geniş halka genelde o yıl şartların iyi olduğunu gösterir. Dar halka kuraklık ya da hastalık olabileceğini anlatır.', 'A wide ring usually means that year was good. A narrow ring may mean drought or illness.'), [noaaRings]),
      LessonCard(LessonArt.house, Bi('Kirişteki sır', 'The secret in the beam'), Bi('Eski bir kirişin en dış halkası, o ağacın hangi yıl kesildiğini söyler.', 'The outermost ring of an old beam tells which year its tree was cut.'), [npsAztec]),
    ],
    [
      QuizQuestion(Bi('Bir ağacın en yaşlı halkaları nerededir?', 'Where are a tree’s oldest rings?'), [Bi('Ortada', 'In the middle'), Bi('Kabuğun üstünde', 'On top of the bark'), Bi('Yapraklarda', 'In the leaves')], 0, Bi('En yaşlı halkalar ortada, en genç olan kabuğun hemen altındadır.', 'The oldest rings are in the middle and the youngest is just under the bark.'), noaaRings),
      TrueFalseQuestion(LessonArt.rings, Bi('Geniş bir halka genelde o yılın iyi geçtiğini gösterir.', 'A wide ring usually shows that the year went well.'), true, Bi('Şartlar iyiyse halka genelde geniş olur.', 'When conditions are good, the ring is usually wide.'), noaaRings),
    ],
  ),
  NatureLesson(
    'tree_body',
    Bi('Bir ağacın içi', 'Inside a tree'),
    [
      LessonCard(LessonArt.rings, Bi('Ortası dimdik', 'A strong middle'), Bi('Bir ağacın gövdesinin ortası aslında ölüdür. Ama o odun ağacı dimdik tutan bir direk gibidir!', 'The middle of a trunk is actually dead. But that wood is like a post holding the tree upright!'), [arborAnatomy]),
      LessonCard(LessonArt.leaf, Bi('İnce sihirli katman', 'A thin magic layer'), Bi('Ağaç, kabuğun hemen altındaki ince bir katmanla kalınlaşır. Bu katman her yıl yeni odun ve yeni kabuk yapar.', 'A tree gets thicker with a thin layer just under the bark. Each year it makes new wood and new bark.'), [arborAnatomy]),
      LessonCard(LessonArt.roots, Bi('Kökler yanlara gider', 'Roots go sideways'), Bi('Köklerin çoğu toprağın üstteki 60 santiminde durur.', 'Most roots stay in the top 60 centimetres of soil.'), [rhsPlants]),
      LessonCard(LessonArt.roots, Bi('Sandığından uzağa', 'Further than you think'), Bi('Yan kökler çoğu zaman dalların gölgesinden iki üç kat öteye uzanır!', 'Side roots often reach two or three times further than the shade of the branches!'), [ucRoots]),
    ],
    [
      QuizQuestion(Bi('Ağaç nasıl kalınlaşır?', 'How does a tree get thicker?'), [Bi('Kabuğun altındaki ince katmanla', 'With a thin layer under the bark'), Bi('Yapraklarını yiyerek', 'By eating its leaves'), Bi('Taşları eriterek', 'By melting stones')], 0, Bi('Kabuğun altındaki ince katman her yıl yeni odun yapar.', 'The thin layer under the bark makes new wood every year.'), arborAnatomy),
      TrueFalseQuestion(LessonArt.roots, Bi('Köklerin çoğu toprağın çok derinlerindedir.', 'Most roots are very deep in the soil.'), false, Bi('Köklerin çoğu toprağın üstteki 60 santimindedir.', 'Most roots are in the top 60 centimetres of soil.'), rhsPlants),
      MatchQuestion(Bi('Ağacın bölümlerini eşleştir.', 'Match the parts of the tree.'), [(Bi('Gövdenin ortası', 'The middle of the trunk'), Bi('Dimdik tutan direk', 'A post that holds it up')), (Bi('Kabuğun altı', 'Just under the bark'), Bi('Yeni odun yapar', 'Makes new wood')), (Bi('Yan kökler', 'Side roots'), Bi('Dalların gölgesinden öteye uzanır', 'Reach beyond the shade of the branches'))], Bi('Ağacın bu bölümlerinin her birinin farklı bir işi vardır.', 'Each of these parts of a tree does a different job.'), arborAnatomy, also: [ucRoots]),
    ],
  ),
  NatureLesson(
    'seed_life',
    Bi('Tohumdan ağaca', 'From seed to tree'),
    [
      LessonCard(LessonArt.seed, Bi('Önce kök', 'Root first'), Bi('Bir tohum uyanınca dışarı önce kök çıkar. Kök onu toprağa tutturur, filiz sonra gelir!', 'When a seed wakes, the root comes out first. It holds the seed in the soil, and the shoot comes later!'), [woodlandLife]),
      LessonCard(LessonArt.seed, Bi('Palamut bekler', 'The acorn waits'), Bi('Meşe palamutları sonbaharda yere düşer. Filiz vermek için ertesi ilkbaharı bekler!', 'Acorns fall in autumn. They wait for the next spring to sprout!'), [woodlandOak]),
      LessonCard(LessonArt.wind, Bi('Helikopter tohumlar', 'Helicopter seeds'), Bi('Dişbudak tohumlarının kanatları vardır. Düşerken pervane gibi dönerler!', 'Ash seeds have wings. They spin like propellers as they fall!'), [forestryAsh]),
      LessonCard(LessonArt.pine, Bi('Sabırlı meşe', 'The patient oak'), Bi('Meşe ağacı palamut vermeye genelde 40 yaşında başlar.', 'An oak usually starts making acorns at about 40 years old.'), [forestryOak]),
    ],
    [
      OrderQuestion(Bi('Bir tohumun yolculuğunu sırala.', 'Put a seed’s journey in order.'), [Bi('Tohum uyanır', 'The seed wakes up'), Bi('Önce kök çıkar', 'The root comes out first'), Bi('Sonra filiz gelir', 'Then the shoot comes')], Bi('Tohumdan önce kök çıkar, filiz sonra gelir.', 'The root comes out of the seed first, and the shoot comes later.'), woodlandLife),
      QuizQuestion(Bi('Meşe palamutu ne zaman filiz verir?', 'When does an acorn sprout?'), [Bi('Ertesi ilkbaharda', 'The next spring'), Bi('Yere düştüğü anda', 'The moment it falls'), Bi('Karın altında kışın', 'Under the snow in winter')], 0, Bi('Palamut filizlenmek için ertesi ilkbaharı bekler.', 'An acorn waits for the next spring to sprout.'), woodlandOak),
      TrueFalseQuestion(LessonArt.wind, Bi('Dişbudak tohumları düşerken pervane gibi döner.', 'Ash seeds spin like propellers as they fall.'), true, Bi('Bu yüzden onlara helikopter denir.', 'That is why they are called helicopters.'), forestryAsh),
    ],
  ),
  NatureLesson(
    'forest_water',
    Bi('Orman ve su', 'Forests and water'),
    [
      LessonCard(LessonArt.rain, Bi('Toprak sünger gibi', 'Soil is like a sponge'), Bi('Orman toprağı yağmur suyunu başka topraklardan daha uzun süre içinde tutar.', 'Forest soil holds rainwater longer than other soils.'), [faoWater]),
      LessonCard(LessonArt.rain, Bi('Musluğundaki su', 'The water in your tap'), Bi('Musluğundaki suyun yolu bir ormandan geçmiş olabilir!', 'The water in your tap may have passed through a forest!'), [faoWater]),
      LessonCard(LessonArt.leaf, Bi('Yapraklar yavaşlatır', 'Leaves slow it down'), Bi('Yaprak ve dallar yağmuru yere düşmeden yavaşlatır. Şiddetli yağmur toprağı kolayca sürükleyemez!', 'Leaves and branches slow rain down before it lands. Heavy rain cannot easily carry the soil away!'), [usdaWater]),
    ],
    [
      QuizQuestion(Bi('Orman toprağı yağmur suyuna ne yapar?', 'What does forest soil do with rainwater?'), [Bi('Sünger gibi tutar', 'Holds it like a sponge'), Bi('Taşa çevirir', 'Turns it into stone'), Bi('Buza çevirir', 'Turns it into ice')], 0, Bi('Orman toprağı suyu başka topraklardan daha uzun süre tutar.', 'Forest soil keeps water longer than other soils.'), faoWater),
      TrueFalseQuestion(LessonArt.rain, Bi('Yağmur suyu orman toprağından geçerken süzülür.', 'Rainwater is filtered as it passes through forest soil.'), true, Bi('Orman toprağı suyu kendiliğinden süzer.', 'Forest soil filters water by itself.'), usdaWater),
    ],
  ),
  NatureLesson(
    'leaf_colors',
    Bi('Yaprakların renkleri', 'Leaf colours'),
    [
      LessonCard(LessonArt.leaf, Bi('Saklı renkler', 'Hidden colours'), Bi('Sonbaharın sarı ve turuncu renkleri aslında yaprakta hep vardır. Yazın yeşil renk onları saklar!', 'Autumn’s yellow and orange are in the leaf all along. In summer, green hides them!'), [pennLeaves]),
      LessonCard(LessonArt.leaf, Bi('Kırmızı yeni gelir', 'Red comes new'), Bi('Kırmızı renklerin çoğu sonbaharda yeni üretilir!', 'Most reds are newly made in autumn!'), [pennLeaves]),
      LessonCard(LessonArt.pine, Bi('Son besin', 'The last food'), Bi('Ağaçlar yaprak dökmeden önce yapraklardaki son besinleri geri alır.', 'Before dropping its leaves, a tree takes back the last food in them.'), [npsLeaves]),
      LessonCard(LessonArt.pine, Bi('Serin ve loş', 'Cool and dim'), Bi('Kayın yaprakları o kadar sıktır ki altına çok az ışık ulaşır.', 'Beech leaves are so thick that very little light gets underneath.'), [forestryBeech]),
    ],
    [
      QuizQuestion(Bi('Sarı renk yazın nerededir?', 'Where is yellow in summer?'), [Bi('Yaprağın içinde saklıdır', 'Hidden inside the leaf'), Bi('Köklerde bekler', 'Waiting in the roots'), Bi('Bulutlardadır', 'In the clouds')], 0, Bi('Sarı hep yaprakta vardır, yazın yeşil onu saklar.', 'Yellow is always in the leaf, and green hides it in summer.'), pennLeaves),
      TrueFalseQuestion(LessonArt.leaf, Bi('Kırmızı renklerin çoğu sonbaharda yeni üretilir.', 'Most reds are newly made in autumn.'), true, Bi('Kırmızılar sarılardan farklı olarak sonbaharda üretilir.', 'Unlike yellows, reds are made in autumn.'), pennLeaves),
    ],
  ),
  NatureLesson(
    'turkey_trees',
    Bi('Türkiye’nin ağaçları', 'Trees of Türkiye'),
    [
      LessonCard(LessonArt.pine, Bi('Kalın kabuklu kızılçam', 'Thick-barked red pine'), Bi('Kızılçamın kabuğu çok kalındır. Yerdeki otları yakan yangınlardan az zarar görür.', 'Red pine has very thick bark. Fires burning along the ground hurt it only a little.'), [ogmKizilcam]),
      LessonCard(LessonArt.pine, Bi('İkişer ikişer', 'Two by two'), Bi('Karaçamın iğne yaprakları hep ikişer ikişer çıkar!', 'Black pine needles always grow two by two!'), [ogmKaracam]),
      LessonCard(LessonArt.wind, Bi('Titreyen yapraklar', 'Trembling leaves'), Bi('Titrek kavağın yaprak sapları yassıdır. Bu yüzden hafif rüzgârda bile titrer.', 'Aspen leaf stalks are flat. That is why they tremble even in a light breeze.'), [ogmTitrek]),
    ],
    [
      MatchQuestion(Bi('Ağaçları özellikleriyle eşleştir.', 'Match the trees to what is special about them.'), [(Bi('Kızılçam', 'Red pine'), Bi('Çok kalın kabuk', 'Very thick bark')), (Bi('Karaçam', 'Black pine'), Bi('İğneler ikişer ikişer', 'Needles two by two')), (Bi('Titrek kavak', 'Aspen'), Bi('Yapraklar titrer', 'Leaves that tremble'))], Bi('Bu ağaçların her biri farklı bir özelliğiyle tanınır.', 'Each of these trees is known for something different.'), ogmKizilcam, also: [ogmKaracam, ogmTitrek]),
      QuizQuestion(Bi('Titrek kavağın yaprakları neden titrer?', 'Why do aspen leaves tremble?'), [Bi('Yaprak sapları yassıdır', 'Their stalks are flat'), Bi('Soğuktan titrer', 'They shiver from cold'), Bi('Böcekler sallar', 'Insects shake them')], 0, Bi('Yassı saplar yaprağı hafif rüzgârda bile sallar.', 'Flat stalks let the leaf move even in a light breeze.'), ogmTitrek),
    ],
  ),
];

const _animalLessons = [
  NatureLesson(
    'seed_carriers',
    Bi('Tohum saklayanlar', 'Seed hiders'),
    [
      LessonCard(LessonArt.squirrel, Bi('Sincabın kileri', 'The squirrel’s larder'), Bi('Kızıl sincaplar sonbaharda tohum ve fındıkları toprağa gömer. Kışın bunları yer!', 'In autumn, red squirrels bury seeds and nuts. They eat them in winter!'), [woodlandSquirrel]),
      LessonCard(LessonArt.bird, Bi('Unutkan alakarga', 'The forgetful jay'), Bi('Alakargalar palamut saklar ama hepsini bulamaz. Unutulan palamutların bazısı meşe ağacı olur!', 'Jays hide acorns but cannot find them all. Some forgotten acorns become oak trees!'), [woodlandJay]),
      LessonCard(LessonArt.seed, Bi('Rüzgârla uçanlar', 'Flying on the wind'), Bi('Huş ağacının minicik kanatlı binlerce tohumu rüzgârla yeni yerlere ulaşır!', 'A birch’s thousands of tiny winged seeds reach new places on the wind!'), [forestryBirch]),
    ],
    [
      QuizQuestion(Bi('Alakarganın unuttuğu palamutlara ne olabilir?', 'What can happen to acorns a jay forgets?'), [Bi('Bazısı meşe ağacı olur', 'Some become oak trees'), Bi('Taşa dönüşür', 'They turn to stone'), Bi('Uçup gider', 'They fly away')], 0, Bi('Unutulan palamutların bazısı filizlenip meşe olur.', 'Some forgotten acorns sprout and become oaks.'), woodlandJay),
      TrueFalseQuestion(LessonArt.squirrel, Bi('Kızıl sincaplar sonbaharda tohumları toprağa gömer.', 'Red squirrels bury seeds in the ground in autumn.'), true, Bi('Kışın yiyecek azalınca sakladıklarını yerler.', 'They eat what they hid when food runs low in winter.'), woodlandSquirrel),
    ],
  ),
  NatureLesson(
    'winter_sleep',
    Bi('Kışı nasıl geçirirler?', 'How they spend the winter'),
    [
      LessonCard(LessonArt.hedgehog, Bi('Yapraktan yatak', 'A bed of leaves'), Bi('Kirpiler kışı düşmüş yapraklardan yaptıkları yuvada uyuyarak geçirir.', 'Hedgehogs sleep through winter in nests made of fallen leaves.'), [woodlandHedgehog]),
      LessonCard(LessonArt.bear, Bi('Kış uykusunda anne', 'A mother asleep'), Bi('Anne kahverengi ayı kış boyunca inde uyur. Yavruları süt emip büyür!', 'A mother brown bear sleeps in her den all winter. Her cubs drink milk and grow!'), [npsBears]),
      LessonCard(LessonArt.squirrel, Bi('Beş aylık uyku', 'Five months of sleep'), Bi('Fındık faresi kışın yerdeki yuvasında yaklaşık beş ay uyur!', 'A hazel dormouse sleeps for about five months in its nest on the ground!'), [ptesDormouse]),
    ],
    [
      MatchQuestion(Bi('Hayvanları kış yuvalarıyla eşleştir.', 'Match the animals to their winter homes.'), [(Bi('Kirpi', 'Hedgehog'), Bi('Yapraktan yuva', 'A nest of leaves')), (Bi('Anne ayı', 'Mother bear'), Bi('İn', 'A den')), (Bi('Fındık faresi', 'Dormouse'), Bi('Yerdeki yuva', 'A nest on the ground'))], Bi('Bu hayvanların her biri kışı kendi yuvasında geçirir.', 'Each of these animals spends the winter in its own home.'), woodlandHedgehog, also: [npsBears, ptesDormouse]),
      QuizQuestion(Bi('Kirpi kışı nerede geçirir?', 'Where does a hedgehog spend the winter?'), [Bi('Yapraktan yuvasında', 'In a nest of leaves'), Bi('Derenin içinde', 'Inside a stream'), Bi('Kuş yuvasında', 'In a bird’s nest')], 0, Bi('Kuru yapraklar kirpinin kış yatağıdır.', 'Dry leaves are a hedgehog’s winter bed.'), woodlandHedgehog),
    ],
  ),
  NatureLesson(
    'bees',
    Bi('Arılar ve çiçekler', 'Bees and flowers'),
    [
      LessonCard(LessonArt.bee, Bi('Dans eden arılar', 'Dancing bees'), Bi('Bal arıları dans ederek arkadaşlarına çiçeklerin yönünü ve uzaklığını anlatır!', 'Honeybees dance to tell their friends the direction and distance of flowers!'), [askBees]),
      LessonCard(LessonArt.bee, Bi('Tek kraliçe', 'One queen'), Bi('Kovanda yavru yapabilen tek dişi kraliçe arıdır.', 'The queen is the only female in the hive who can have young.'), [npsHoneybees]),
      LessonCard(LessonArt.leaf, Bi('Çiçeklerin yardımcıları', 'Helpers of flowers'), Bi('Çiçekli bitkilerin çoğu arılara, kelebeklere ve kuşlara ihtiyaç duyar.', 'Most flowering plants need bees, butterflies and birds.'), [npsPollinators]),
    ],
    [
      OrderQuestion(Bi('Bal nasıl oluşur? Sırala.', 'How is honey made? Put it in order.'), [Bi('Arı çiçek özünü getirir', 'A bee brings nectar'), Bi('Arılar kanatlarıyla yeller', 'Bees fan it with their wings'), Bi('Bal olur', 'It becomes honey')], Bi('Arılar çiçek özündeki suyu kanatlarıyla yelleyip azaltır ve bal olur.', 'Bees fan away the water in nectar with their wings, and it becomes honey.'), nhmHoney),
      QuizQuestion(Bi('Bal arıları çiçeklerin yerini nasıl anlatır?', 'How do honeybees tell where flowers are?'), [Bi('Dans ederek', 'By dancing'), Bi('Şarkı söyleyerek', 'By singing'), Bi('Işık yakarak', 'By lighting a lamp')], 0, Bi('Dansları çiçeklerin yönünü ve uzaklığını anlatır.', 'Their dance tells the direction and distance of flowers.'), askBees),
      TrueFalseQuestion(LessonArt.bee, Bi('Kovanda yavru yapabilen tek dişi kraliçe arıdır.', 'The queen is the only female in the hive who can have young.'), true, Bi('Kraliçe günde binlerce yumurta bırakabilir.', 'A queen can lay thousands of eggs a day.'), npsHoneybees),
    ],
  ),
  NatureLesson(
    'birds',
    Bi('Kuşların yolculuğu', 'Journeys of birds'),
    [
      LessonCard(LessonArt.bird, Bi('Süzülen leylekler', 'Gliding storks'), Bi('Leylekler sıcak havanın gücüyle süzülür. Denizin üstünde bu hava olmadığı için karadan dolaşırlar!', 'Storks glide on warm air. There is none over the sea, so they go around by land!'), [birdlifeStork]),
      LessonCard(LessonArt.bird, Bi('Hep havada', 'Always in the air'), Bi('Ebabiller uçarken yer, uyur ve yıkanır. Yere neredeyse hiç inmezler!', 'Swifts eat, sleep and bathe while flying. They almost never land!'), [rspbSwift]),
      LessonCard(LessonArt.bird, Bi('Sessiz baykuş', 'The silent owl'), Bi('Peçeli baykuşun tüylerinin kenarı tarak gibidir. Bu tüyler kanat sesini azaltır!', 'A barn owl’s feathers have comb-like edges. They make its wings quieter!'), [audubonOwl]),
    ],
    [
      MatchQuestion(Bi('Kuşları özellikleriyle eşleştir.', 'Match the birds to what they do.'), [(Bi('Leylek', 'Stork'), Bi('Sıcak havayla süzülür', 'Glides on warm air')), (Bi('Ebabil', 'Swift'), Bi('Neredeyse hep havadadır', 'Is almost always in the air')), (Bi('Peçeli baykuş', 'Barn owl'), Bi('Kanat sesi azdır', 'Has quiet wings'))], Bi('Bu kuşların her biri farklı bir şekilde uçar.', 'Each of these birds flies in a different way.'), birdlifeStork, also: [rspbSwift, audubonOwl]),
      QuizQuestion(Bi('Leylekler neden denizin üstünden uçmaz?', 'Why do storks avoid flying over the sea?'), [Bi('Süzülecek sıcak hava yoktur', 'There is no warm air to glide on'), Bi('Suyu sevmezler', 'They dislike water'), Bi('Balıklardan korkarlar', 'They fear fish')], 0, Bi('Leylekler süzülmek için sıcak havaya ihtiyaç duyar.', 'Storks need warm air to glide.'), birdlifeStork),
    ],
  ),
  NatureLesson(
    'soil_life',
    Bi('Toprağın altındaki dünya', 'The world under the soil'),
    [
      LessonCard(LessonArt.worm, Bi('Küçücük komşular', 'Tiny neighbours'), Bi('Orman toprağının tek bir metrekaresinde 1000’den fazla çeşit küçük hayvan yaşayabilir!', 'Over 1000 kinds of tiny animals can live in one square metre of forest soil!'), [faoSoil]),
      LessonCard(LessonArt.worm, Bi('Bir bardak toprak', 'A glass of soil'), Bi('Bir bardak toprakta Dünya’daki insan sayısı kadar bakteri olabilir!', 'A glass of soil can hold as many bacteria as there are people on Earth!'), [usdaSoil]),
      LessonCard(LessonArt.worm, Bi('Solucanların işi', 'What worms do'), Bi('Solucanlar alttaki toprağı yukarı taşır.', 'Worms carry soil from below up to the top.'), [usdaSoil]),
    ],
    [
      QuizQuestion(Bi('Solucanlar toprağa ne yapar?', 'What do worms do to soil?'), [Bi('Alttaki toprağı yukarı taşır', 'Carry soil from below to the top'), Bi('Toprağı taşa çevirir', 'Turn soil into stone'), Bi('Toprağı eritir', 'Melt the soil')], 0, Bi('Solucanlar toprağı alttan üste taşıyarak karıştırır.', 'Worms mix soil by carrying it from below to the top.'), usdaSoil),
      TrueFalseQuestion(LessonArt.worm, Bi('Bir bardak toprakta gözle göremediğin çok sayıda bakteri olabilir.', 'A glass of soil can hold huge numbers of bacteria you cannot see.'), true, Bi('Sayıları Dünya’daki insan sayısı kadar olabilir.', 'There can be as many as there are people on Earth.'), usdaSoil),
    ],
  ),
  NatureLesson(
    'night_animals',
    Bi('Gecenin canlıları', 'Animals of the night'),
    [
      LessonCard(LessonArt.bat, Bi('Böcek avcıları', 'Insect hunters'), Bi('Yarasalar bir gecede kendi ağırlıklarının yarısı kadar böcek yiyebilir!', 'Bats can eat half their own weight in insects in one night!'), [npsBatBenefits]),
      LessonCard(LessonArt.bat, Bi('Gerçekten uçanlar', 'True fliers'), Bi('Yavrularını sütle besleyen hayvanlar arasında gerçekten uçabilen tek grup yarasalardır!', 'Among animals that feed their young on milk, bats are the only group that can truly fly!'), [npsBats]),
      LessonCard(LessonArt.squirrel, Bi('Kurt ulur', 'Wolves howl'), Bi('Her kurdun uluması farklıdır. Diğer kurtlar bu sesi 10 kilometreden uzaktan duyabilir!', 'Every wolf’s howl is different. Other wolves can hear it from over 10 kilometres away!'), [zooWolf]),
    ],
    [
      QuizQuestion(Bi('Yavrularını sütle besleyen hayvanlardan hangisi gerçekten uçabilir?', 'Which animal that feeds its young on milk can truly fly?'), [Bi('Yarasa', 'Bat'), Bi('Sincap', 'Squirrel'), Bi('Kirpi', 'Hedgehog')], 0, Bi('Gerçekten uçabilen tek grup yarasalardır.', 'Bats are the only such group that can truly fly.'), npsBats),
      TrueFalseQuestion(LessonArt.squirrel, Bi('Kurt yavruları doğduğunda hem görür hem duyar.', 'Wolf pups can see and hear when they are born.'), false, Bi('Yavrular doğduğunda ne görür ne de duyar.', 'Pups can neither see nor hear when they are born.'), zooWolf),
    ],
  ),
];

const _recoveryLessons = [
  NatureLesson(
    'after_fire',
    Bi('Yanan orman nasıl yenilenir?', 'How a burned forest recovers'),
    [
      LessonCard(LessonArt.pine, Bi('Her yangın aynı değil', 'No two fires are the same'), Bi('Kastamonu’da yerdeki otları yakan bir yangından sonra en çok karaçam görüldü.', 'In Kastamonu, black pine was the most common tree after a fire that burned the ground.'), [forestJournal]),
      LessonCard(LessonArt.burned, Bi('Tepeler yanınca', 'When the treetops burn'), Bi('Ağaç tepeleri de yanan yerde en çok laden adlı çalı görüldü.', 'Where the treetops burned too, a shrub called rockrose was the most common.'), [forestJournal]),
      LessonCard(LessonArt.sprout, Bi('Üç yol var', 'There are three ways'), Bi('Soma’da yanan orman için üç yol seçildi: Orman kendi yenilensin, insanlar yardım etsin, yeni ağaç dikilsin.', 'Three ways were chosen for the burned forest in Soma: let it renew itself, help it along, and plant new trees.'), [ogmSoma]),
      LessonCard(LessonArt.house, Bi('Alan korunur', 'The area is protected'), Bi('Soma’daki alan yeniden yeşerene kadar korunacak.', 'The area in Soma will be protected until it is green again.'), [ogmSoma]),
    ],
    [
      QuizQuestion(Bi('Yanan bir orman için hangisi doğru?', 'Which is true of a burned forest?'), [Bi('Yangına göre sonuç değişebilir', 'The result can differ from fire to fire'), Bi('Hepsi aynı ormana döner', 'All return to the same forest'), Bi('Hiçbir şey yapılmaz', 'Nothing is ever done')], 0, Bi('Yangın ne kadar güçlüyse sonrası da ona göre değişir.', 'What comes after depends on how strong the fire was.'), forestJournal),
      TrueFalseQuestion(LessonArt.sprout, Bi('Soma’da yanan orman için üç yol seçildi.', 'Three ways were chosen for the burned forest in Soma.'), true, Bi('Orman kendi yenilensin, insanlar yardım etsin ve yeni ağaç dikilsin diye üç yol seçildi.', 'The three ways were to let it renew itself, help it along and plant new trees.'), ogmSoma),
    ],
  ),
  NatureLesson(
    'fire_seeds',
    Bi('Yangını bekleyen tohumlar', 'Seeds that wait for fire'),
    [
      LessonCard(LessonArt.cone, Bi('Mühürlü kozalak', 'A sealed cone'), Bi('Bazı çamların kozalakları reçineyle mühürlüdür. Sıcak mührü eritince tohumlar çıkar!', 'Some pine cones are sealed with resin. When heat melts the seal, the seeds come out!'), [npsYellowstone]),
      LessonCard(LessonArt.cone, Bi('Üç yıllık kozalak', 'A three-year cone'), Bi('Kızılçam kozalağının oluşması 3 yıl sürer.', 'A red pine cone takes 3 years to form.'), [faoRedPine]),
      LessonCard(LessonArt.sprout, Bi('Kendiliğinden fidan', 'Seedlings on their own'), Bi('Akdeniz kıyısında, alçak yerlerdeki yanmış alanlarda kızılçam fidanları çoğu zaman kendiliğinden bolca çıkar.', 'On low burned land along the Mediterranean, red pine seedlings often come up by themselves in large numbers.'), [faoRedPine]),
    ],
    [
      OrderQuestion(Bi('Kozalağın sırrını sırala.', 'Put the cone’s secret in order.'), [Bi('Yangının sıcağı gelir', 'The heat of a fire arrives'), Bi('Reçine erir', 'The resin melts'), Bi('Tohumlar çıkar', 'The seeds come out')], Bi('Sıcak reçineyi eritir, sonra tohumlar çıkar.', 'Heat melts the resin, and then the seeds come out.'), npsYellowstone),
      TrueFalseQuestion(LessonArt.cone, Bi('Kızılçam kozalağının oluşması 3 yıl sürer.', 'A red pine cone takes 3 years to form.'), true, Bi('Olgunlaştıktan sonra da birkaç yıl dalda kalır.', 'It stays on the branch for a few more years once ripe.'), faoRedPine),
    ],
  ),
  NatureLesson(
    'sprouts',
    Bi('Küllerin altından filizler', 'Shoots from under the ash'),
    [
      LessonCard(LessonArt.sprout, Bi('Kökler sağlam kalır', 'Roots stay safe'), Bi('Yangında otların üstü yansa da kökleri toprağın altında çoğu zaman sağlam kalır.', 'Even if the top of a grass burns, its roots often stay safe under the ground.'), [npsYellowstone]),
      LessonCard(LessonArt.burned, Bi('Meşe vazgeçmez', 'The oak does not give up'), Bi('Meşenin üstü yangında ölse bile kütüğünden ve köklerinden yeni filizler verebilir!', 'Even if the top of an oak dies in a fire, new shoots can grow from its stump and roots!'), [npsSkyIsland]),
      LessonCard(LessonArt.sprout, Bi('Ateş otu', 'Fireweed'), Bi('Yanmış yere renk getiren ilk bitkilerden biri, ateş otu denen çiçektir!', 'One of the first plants to bring colour back to burned land is a flower called fireweed!'), [npsGlacier]),
    ],
    [
      QuizQuestion(Bi('Meşenin üstü yangında ölürse ne olabilir?', 'What can happen if the top of an oak dies in a fire?'), [Bi('Kütüğünden filiz verebilir', 'It can sprout from its stump'), Bi('Taşa dönüşür', 'It turns to stone'), Bi('Kökleriyle yürür', 'It walks away on its roots')], 0, Bi('Meşe kütüğünden ve köklerinden yeniden filizlenebilir.', 'An oak can sprout again from its stump and roots.'), npsSkyIsland),
      TrueFalseQuestion(LessonArt.sprout, Bi('Otların kökleri yangında çoğu zaman sağlam kalır.', 'Grass roots often survive a fire.'), true, Bi('Kökler toprağın altında korunur.', 'The roots are protected under the ground.'), npsYellowstone),
    ],
  ),
  NatureLesson(
    'ash_soil',
    Bi('Kül ve toprak', 'Ash and soil'),
    [
      LessonCard(LessonArt.burned, Bi('Kül toprağa döner', 'Ash goes back to soil'), Bi('Yangın kütükleri ve kuru yaprakları küle çevirir. Bu kül besinleri yeniden toprağa verir!', 'Fire turns logs and dry leaves to ash. That ash gives food back to the soil!'), [npsGlacier]),
      LessonCard(LessonArt.bird, Bi('Ölü ağaç da yuvadır', 'A dead tree is a home too'), Bi('Ölü bir ağaç böcekleri besler, kuşlara ve yarasalara ev olur!', 'A dead tree feeds insects and gives a home to birds and bats!'), [woodlandLife]),
      LessonCard(LessonArt.worm, Bi('Odun yiyen yavrular', 'Young that eat wood'), Bi('Geyik böceğinin yavruları yıllarca çürüyen odunla beslenir!', 'Stag beetle larvae feed on rotting wood for years!'), [nhmStag]),
    ],
    [
      QuizQuestion(Bi('Yangından sonra kül toprağa ne verir?', 'What does ash give the soil after a fire?'), [Bi('Besin', 'Food'), Bi('Buz', 'Ice'), Bi('Cam', 'Glass')], 0, Bi('Kül, besinleri yeniden toprağa verir.', 'Ash gives food back to the soil.'), npsGlacier),
      TrueFalseQuestion(LessonArt.bird, Bi('Ölü ağaçlar kuşlara ve yarasalara ev olabilir.', 'Dead trees can be homes for birds and bats.'), true, Bi('Ölü ağacın kovukları onlara yuva olur.', 'The hollows of a dead tree give them nests.'), woodlandLife),
    ],
  ),
  NatureLesson(
    'slow_recovery',
    Bi('Orman yavaş iyileşir', 'A forest heals slowly'),
    [
      LessonCard(LessonArt.calendar, Bi('Uzaydan bile', 'Even from space'), Bi('ABD’deki Yellowstone’da 1988’de yanan yerler 2019’da bile uzaydan görülebiliyordu.', 'Land burned in 1988 at Yellowstone in the USA could still be seen from space in 2019.'), [nasaYellowstone]),
      LessonCard(LessonArt.sprout, Bi('Küllerin arasından', 'From among the ashes'), Bi('Yellowstone’da yangından sonra otlar ve kır çiçekleri çıktı. Zamanla minik çamlar büyümeye başladı!', 'After the fires at Yellowstone, grasses and wildflowers sprang up. Over time, tiny pines began to grow!'), [nasaYellowstone]),
      LessonCard(LessonArt.pine, Bi('İlk gelen ağaç', 'The first tree to arrive'), Bi('Huş ağacı boş arazilere ilk gelen ağaçlardan biridir!', 'Birch is one of the first trees to move onto empty land!'), [forestryBirch]),
    ],
    [
      OrderQuestion(Bi('Yellowstone’da orman nasıl geri geldi? Sırala.', 'How did the forest come back at Yellowstone? Put it in order.'), [Bi('Yangın geçer', 'The fire passes'), Bi('Otlar ve çiçekler çıkar', 'Grasses and flowers come up'), Bi('Minik çamlar büyür', 'Tiny pines grow')], Bi('Küllerin arasından önce otlar ve çiçekler, zamanla da minik çamlar çıktı.', 'First grasses and flowers came up from the ashes, and tiny pines followed over time.'), nasaYellowstone),
      QuizQuestion(Bi('Yellowstone’da 1988’de yanan yerler 2019’da nasıldı?', 'What was land burned in 1988 at Yellowstone like in 2019?'), [Bi('Uzaydan hâlâ görülebiliyordu', 'It could still be seen from space'), Bi('Hiç yanmamış gibiydi', 'It looked as if it had never burned'), Bi('Tamamen çöl olmuştu', 'It had become a desert')], 0, Bi('Orman çok yavaş iyileşir.', 'A forest heals very slowly.'), nasaYellowstone),
    ],
  ),
  NatureLesson(
    'planting',
    Bi('Yeni fidanlar', 'New saplings'),
    [
      LessonCard(LessonArt.calendar, Bi('Ağaç bayramı', 'A day for trees'), Bi('Türkiye’de her yıl 11 Kasım’da Milli Ağaçlandırma Günü kutlanıyor.', 'In Türkiye, National Tree Planting Day is held every year on 11 November.'), [ogmPlantingDay]),
      LessonCard(LessonArt.sprout, Bi('Yanan yer korunur', 'Burned land stays protected'), Bi('Türkiye’de yanan ormanların yeniden ağaçlandırılması Anayasa’da yazıyor. Yanan orman alanı başka işe kullanılamaz!', 'In Türkiye, replanting burned forests is written in the Constitution. Burned forest land cannot be used for anything else!'), [ogmConstitution]),
      LessonCard(LessonArt.sprout, Bi('Bazen dikilir', 'Sometimes trees are planted'), Bi('Soma’da seçilen yollardan biri yeni ağaç dikmekti.', 'In Soma, one of the chosen ways was to plant new trees.'), [ogmSoma]),
    ],
    [
      QuizQuestion(Bi('Milli Ağaçlandırma Günü ne zaman?', 'When is National Tree Planting Day?'), [Bi('11 Kasım', '11 November'), Bi('1 Ocak', '1 January'), Bi('29 Ekim', '29 October')], 0, Bi('Milli Ağaçlandırma Günü her yıl 11 Kasım’dadır.', 'National Tree Planting Day is every year on 11 November.'), ogmPlantingDay),
      TrueFalseQuestion(LessonArt.burned, Bi('Yanan orman alanı başka bir işe kullanılabilir.', 'Burned forest land can be used for something else.'), false, Bi('Yanan orman alanı yeniden ağaçlandırılır, başka işe kullanılamaz.', 'Burned forest land is replanted and cannot be used for anything else.'), ogmConstitution),
    ],
  ),
];

const _readyLessons = [
  NatureLesson(
    'go_bag',
    Bi('Acil durum çantası', 'The emergency bag'),
    [
      LessonCard(LessonArt.bag, Bi('Çantada ne olur?', 'What goes in the bag?'), Bi('Su, yiyecek, el feneri, ilk yardım malzemesi, yedek pil ve düdük.', 'Water, food, a torch, first aid things, spare batteries and a whistle.'), [readyKit]),
      LessonCard(LessonArt.bag, Bi('Düdük ne işe yarar?', 'What is the whistle for?'), Bi('Düdükle yardım çağırabilirsin.', 'You can call for help with a whistle.'), [readyKit]),
      LessonCard(LessonArt.house, Bi('Herkes bilsin', 'Everyone should know'), Bi('Çanta, evde herkesin bildiği bir yerde durmalı.', 'The bag should be in a spot at home that everyone knows.'), [readyKit]),
      LessonCard(LessonArt.phone, Bi('Şarj dolu', 'Fully charged'), Bi('Yangın olabilecek yerlerde telefonun hep şarjlı olsun.', 'Where fires can happen, keep your phone charged.'), [readyWildfires]),
    ],
    [
      QuizQuestion(Bi('Acil durum çantasına hangisi konur?', 'Which goes in an emergency bag?'), [Bi('Düdük ve el feneri', 'A whistle and a torch'), Bi('Oyuncak araba', 'A toy car'), Bi('Kum', 'Sand')], 0, Bi('Düdük ve el feneri çantada bulunmalı.', 'A whistle and a torch belong in the bag.'), readyKit),
      TrueFalseQuestion(LessonArt.bag, Bi('Düdük yardım çağırmak için çantaya konur.', 'A whistle goes in the bag to call for help.'), true, Bi('Düdük sesi yardım çağırmana yarar.', 'The sound of a whistle helps you call for help.'), readyKit),
    ],
  ),
  NatureLesson(
    'family_plan',
    Bi('Aile planı', 'A family plan'),
    [
      LessonCard(LessonArt.family, Bi('Buluşma yeri', 'A meeting place'), Bi('Ailen için kolay bulunan bir buluşma yeri seçin.', 'Choose a meeting place for your family that is easy to find.'), [readyPlan]),
      LessonCard(LessonArt.phone, Bi('Nasıl haberleşeceğiz?', 'How will we keep in touch?'), Bi('Ayrı düşerseniz birbirinize nasıl ulaşacağınızı konuşun.', 'Talk about how you will reach each other if you get separated.'), [readyPlan]),
      LessonCard(LessonArt.family, Bi('Birlikte dene', 'Try it together'), Bi('Planı ailenle birlikte deneyin.', 'Practise the plan with your family.'), [readyPlan]),
    ],
    [
      QuizQuestion(Bi('Aile planında ne olmalı?', 'What should a family plan have?'), [Bi('Kolay bulunan buluşma yeri', 'An easy-to-find meeting place'), Bi('En sevilen yemek', 'A favourite meal'), Bi('Yeni oyun listesi', 'A list of new games')], 0, Bi('Buluşma yeri, ayrı düşerseniz sizi bir araya getirir.', 'A meeting place brings you back together if you get separated.'), readyPlan),
      TrueFalseQuestion(LessonArt.family, Bi('Plan aileyle birlikte denenmelidir.', 'A plan should be practised with the family.'), true, Bi('Planı evdekilerle birlikte denemek gerekir.', 'A plan needs practising with the people you live with.'), readyPlan),
    ],
  ),
  NatureLesson(
    'evacuate',
    Bi('“Burayı boşaltın” denirse', 'If you are told to leave'),
    [
      LessonCard(LessonArt.exit, Bi('Hiç bekleme', 'Do not wait'), Bi('Yetkililer “Burayı boşaltın” derse hiç beklemeden çık.', 'If officials say to leave, go without waiting.'), [readyWildfires]),
      LessonCard(LessonArt.ember, Bi('Geçti sanma', 'Do not think it is over'), Bi('Alevler geçtikten saatler sonra bile közler yeni yangın çıkarabilir.', 'Even hours after the flames pass, embers can start a new fire.'), [nistEmbers]),
      LessonCard(LessonArt.house, Bi('Eve dönmek', 'Going home'), Bi('Yetkililer “Güvenli” demeden eve dönme.', 'Do not go home until officials say it is safe.'), [readyWildfires]),
    ],
    [
      QuizQuestion(Bi('Yetkililer “Burayı boşaltın” dedi. Ne yaparsın?', 'Officials say to leave. What do you do?'), [Bi('Hemen çıkarım', 'I leave right away'), Bi('Yangını görmeye giderim', 'I go to see the fire'), Bi('Evde saklanırım', 'I hide at home')], 0, Bi('Yetkililer boşaltın derse hiç beklenmez.', 'When officials say to leave, nobody waits.'), readyWildfires),
      TrueFalseQuestion(LessonArt.house, Bi('Alevler geçince hemen eve dönebilirsin.', 'You can go home as soon as the flames pass.'), false, Bi('Yetkililer “Güvenli” diyene kadar beklenir.', 'You wait until officials say it is safe.'), readyWildfires),
    ],
  ),
  NatureLesson(
    'smoke_health',
    Bi('Duman', 'Smoke'),
    [
      LessonCard(LessonArt.smoke, Bi('Duman herkesi etkiler', 'Smoke affects everyone'), Bi('Yangın dumanı gözlerini, boğazını ve ciğerlerini rahatsız eder. Herkesi hasta edebilir.', 'Wildfire smoke bothers your eyes, throat and lungs. It can make anyone sick.'), [cdcSmoke]),
      LessonCard(LessonArt.mask, Bi('N95 maske', 'An N95 mask'), Bi('N95 maske, dumanı solumaktan korunmana yardım eder.', 'An N95 mask helps protect you from breathing in smoke.'), [readyWildfires]),
    ],
    [
      QuizQuestion(Bi('Yangın dumanı neye zarar verir?', 'What does wildfire smoke harm?'), [Bi('Göz, boğaz ve ciğerlere', 'Eyes, throat and lungs'), Bi('Sadece bitkilere', 'Only plants'), Bi('Sadece arabalara', 'Only cars')], 0, Bi('Duman herkesi hasta edebilir.', 'Smoke can make anyone sick.'), cdcSmoke),
      TrueFalseQuestion(LessonArt.mask, Bi('N95 maske dumandan korunmaya yardım eder.', 'An N95 mask helps protect you from smoke.'), true, Bi('Evde varsa dumanlı havada kullanılabilir.', 'If you have one at home, it can be used when the air is smoky.'), readyWildfires),
    ],
  ),
  NatureLesson(
    'earthquake',
    Bi('Deprem', 'Earthquakes'),
    [
      LessonCard(LessonArt.quake, Bi('Çök', 'Drop'), Bi('Sarsıntı başlayınca olduğun yerde ellerinin ve dizlerinin üstüne çök.', 'When the shaking starts, drop onto your hands and knees where you are.'), [readyQuake]),
      LessonCard(LessonArt.quake, Bi('Kapan', 'Cover'), Bi('Bir kolunla başını ve enseni koru.', 'Cover your head and neck with one arm.'), [readyQuake]),
      LessonCard(LessonArt.quake, Bi('Tutun', 'Hold on'), Bi('Sarsıntı bitene kadar tutun.', 'Hold on until the shaking stops.'), [readyQuake]),
      LessonCard(LessonArt.house, Bi('Önceden hazırlan', 'Get ready beforehand'), Bi('Kitaplık ve televizyon gibi ağır eşyalar evde sabitlenmeli.', 'Heavy things at home, like bookcases and televisions, should be fastened down.'), [readyQuake]),
    ],
    [
      OrderQuestion(Bi('Deprem sırasında sıra nasıl?', 'What is the order during an earthquake?'), [Bi('Çök', 'Drop'), Bi('Kapan', 'Cover'), Bi('Tutun', 'Hold on')], Bi('Önce çök, sonra başını koru ve sarsıntı bitene kadar tutun.', 'First drop, then cover your head, and hold on until the shaking stops.'), readyQuake),
      QuizQuestion(Bi('Evdeyken deprem başladı. Ne yaparsın?', 'An earthquake starts while you are at home. What do you do?'), [Bi('Olduğum yerde çökerim', 'I drop where I am'), Bi('Kapının önüne koşarım', 'I run to the doorway'), Bi('Pencereye koşarım', 'I run to the window')], 0, Bi('İçerideyken olduğun yerde kal ve kapı önlerinden uzak dur.', 'Indoors, stay where you are and keep clear of doorways.'), readyQuake),
    ],
  ),
  NatureLesson(
    'flood',
    Bi('Sel', 'Floods'),
    [
      LessonCard(LessonArt.flood, Bi('Akan suya girme', 'Stay out of moving water'), Bi('Sel sularında yürüme, yüzme ve araba kullanma.', 'Do not walk, swim or drive through flood water.'), [readyFloods]),
      LessonCard(LessonArt.flood, Bi('Az su da güçlüdür', 'Even a little water is strong'), Bi('15 santim akan su bile seni düşürebilir!', 'Just 15 centimetres of moving water can knock you down!'), [readyFloods]),
      LessonCard(LessonArt.exit, Bi('Yukarı çık', 'Go up'), Bi('Sel olursa daha yüksek bir yere ya da üst kata çık.', 'In a flood, move to higher ground or a higher floor.'), [readyFloods]),
    ],
    [
      QuizQuestion(Bi('Yolu sel suyu kapladı. Ne yaparsın?', 'Flood water has covered the road. What do you do?'), [Bi('Geri dönerim', 'I turn back'), Bi('İçinden yürürüm', 'I walk through it'), Bi('Yüzerek geçerim', 'I swim across')], 0, Bi('Sel sularına girilmez, geri dönülür.', 'You stay out of flood water and turn back.'), readyFloods),
      TrueFalseQuestion(LessonArt.flood, Bi('15 santim akan su bile seni düşürebilir.', 'Just 15 centimetres of moving water can knock you down.'), true, Bi('Akan su göründüğünden güçlüdür.', 'Moving water is stronger than it looks.'), readyFloods),
    ],
  ),
];

/// Five sections, each ending in a flower on the tree. Lesson ids never
/// change: finished lessons and their apples are stored by id.
const List<NatureSection> natureSections = [
  NatureSection('fire_safety', Bi('Yangın güvenliği', 'Fire safety'), LessonArt.phone, 0xFFE5392F, _fireLessons),
  NatureSection('forest', Bi('Orman ve ağaçlar', 'Forests and trees'), LessonArt.pine, 0xFF3F9A1F, _forestLessons),
  NatureSection('wildlife', Bi('Ormanın hayvanları', 'Animals of the forest'), LessonArt.squirrel, 0xFFDFA031, _animalLessons),
  NatureSection('recovery', Bi('Yanan orman nasıl yenilenir', 'How a burned forest recovers'), LessonArt.sprout, 0xFF4AA8E8, _recoveryLessons),
  NatureSection('ready', Bi('Afetlere hazırlık', 'Getting ready for disasters'), LessonArt.bag, 0xFF8B5CF6, _readyLessons),
];

const List<NatureLesson> natureLessons = [
  ..._fireLessons,
  ..._forestLessons,
  ..._animalLessons,
  ..._recoveryLessons,
  ..._readyLessons,
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
