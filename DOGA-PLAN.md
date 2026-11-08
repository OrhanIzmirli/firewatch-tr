# FireWatch TR 1.3.0: "Doğa" sekmesi planı

Tarih: 8 Kasım 2026. Durum: yalnız plan. Bu belge için kod yazılmadı, başka dosya değişmedi, git, flutter veya build çalıştırılmadı.

Amaç: kullanıcıların yangın sezonu dışında da uygulamaya dönmesi. Duolingo'nun iyi yanları (kısa görev, seri, küçük dersler) alınıyor; suçlu hissettirme ve zorlayıcı bildirim gibi yanları alınmıyor.

## 0. Önce bilinmesi gereken beş bulgu

1. **Backend'de `content_type` hiç yok.** Klondaki `src` ve `database` klasörlerinde `content_type`, `action_url` veya `event_start` geçmiyor. `newsController.getAllNews` yalnız `category`, `limit`, `offset` okuyor. `FeatureFlags.newsContentTabs` üstündeki not hâlâ doğru. Ayrıntı: bölüm 3.3.
2. **Etkinlik kaynağı yok.** `newsScraperJob.ts` içindeki `RSS_SOURCES` yalnız basın kuruluşlarını içeriyor; OGM, TEMA, WWF-Türkiye veya belediye yok. OGM'nin çalışan bir RSS beslemesi var, ama yapılandırılmış etkinlik tarihi vermiyor. Otomatik etkinlik üretimi uydurma riski taşır; bu yüzden etkinlikler elle onaylanacak.
3. **Hiçbir kaynakta yeniden kullanım izni bulamadım.** OGM ve TEMA'da kullanım koşulları sayfası bulamadım, WWF-Türkiye sitesi otomatik erişimi 403 ile reddetti. Bölüm 3.1'deki tabloya bakın. Yazılı izin gelene kadar yalnız başlık, kendi cümlemizle kısa özet ve kaynağa bağlantı önerilir.
4. **AFAD sayfalarını açamadım.** `afad.gov.tr` denediğim tüm adreslerde HTTP 500 döndü. Örnek ders kartlarında AFAD kaynağı yok. Yangın anı dersi ağırlıklı olarak OGM ile WWF-Türkiye ve AKUT metinlerine dayanıyor; yayından önce OGM veya AFAD'dan teyit gerekiyor.
5. **Altıncı sekme sorunu.** `MainShellScreen` beş hedefli `NavigationBar` kullanıyor. Altıncı hedef dar ekranda sıkışır. Karar sahibine soru olarak bölüm 8.1'de.

## 1. Günlük doğa görevleri

### 1.1 İşleyiş

- Her gün havuzdan **bir** görev gösterilir. İsteyen "Başka görev" ile bir kez değiştirebilir.
- Yanıt **Evet / Hayır** ile verilir. "Hayır" cezasızdır ve o günü işaretlenmiş sayar. Böylece kullanıcıya seri uğruna "evet" deme baskısı yapılmaz.
- Görev cihazın tarihine göre seçilir. Konum kullanılmaz.
- İlk girişte iki isteğe bağlı soru sorulur: "Soba veya şömine kullanıyor musunuz?" ve "Kuş yemliğiniz var mı?". Yanıtlar cihazda kalır, yalnız uygun görevleri seçmek için kullanılır.
- Hiçbir görev ormana girmeyi, yangına yaklaşmayı veya riskli bir yere çıkmayı istemez.
- Yangın ihbarı ve 112 araması asla görev, puan veya rozet konusu olmaz. Aksi hâlde sahte ihbarı teşvik eder.

### 1.2 Mevsim havuzları

| Havuz | Dönem (öneri) | Konular |
|---|---|---|
| Yaz | 1 Haziran - 30 Eylül | Yangın önleme, evin çevresi, acil durum hazırlığı |
| Kış | 1 Aralık - 28/29 Şubat | Kuşlar, geri dönüşüm, enerji, soba ve kül güvenliği |
| Geçiş | Mart-Mayıs, Ekim-Kasım | İki havuzun karışımı |

Tarihler karar konusudur (bölüm 8.3). İlk sürüm için hedef: yaz 20, kış 20, geçiş 10 görev.

### 1.3 Seri (streak)

- Seri, üst üste işaretlenen gün sayısıdır.
- Her hafta **iki gün kendiliğinden affedilir**. Kullanıcıdan bir şey istenmez, satın alma yoktur.
- Seri biterse mesaj gösterilmez. Sadece yeni sayı başlar, "en uzun seri" kaydı silinmez.
- Ayarlardan seri tamamen gizlenebilir. O zaman yalnız "bu hafta X gün" görünür.

### 1.4 Haftalık özet

Pazartesi Doğa sekmesi açıldığında gösterilen yerel bir karttır, bildirim değildir. İçerik: işaretlenen gün, "evet" denen görev sayısı, biten ders. Karşılaştırma, sıralama veya "geçen haftadan kötü" dili yoktur.

### 1.5 Örnek 10 görev

Görev metinlerinde olgusal bir iddia varsa kaynağı yanında. Hepsi "siz" diliyle.

| # | Mevsim | Görev metni | Kaynak / not |
|---|---|---|---|
| 1 | Yaz | Telefonunuza 112 ve 177 numaralarını kaydettiniz mi? | [OGM Konya, 17.05.2023](https://www.ogm.gov.tr/konyaobm/haberler/orman-yanginlariyla-mucadele-hazirlik-egitimlerini-tamamladik) |
| 2 | Yaz | Evinizin çevresindeki odun ve kozalak gibi kolay tutuşan malzemeleri evden uzağa aldınız mı? | [OGM Muğla, 25.04.2024](https://www.ogm.gov.tr/muglaobm/haberler/koylerde-yangin-tedbirleri-film) |
| 3 | Yaz | Bugün bir yakınınıza, sigara izmaritinin tamamen söndürülmeden atılmaması gerektiğini hatırlattınız mı? | OGM Muğla (aynı sayfa) |
| 4 | Yaz | Acil durum çantanızı kontrol ettiniz mi? (ilaç, fener, su, maske, önemli evraklar) | [WWF-Türkiye sunucusundaki el ilanı](https://wwftr.awsassets.panda.org/downloads/yang-nan-ndayap-lacaklarafi-.pdf) |
| 5 | Yaz | Bahçe atıklarınızı orman veya yol kenarına bırakmak yerine çöpe ya da toplama noktasına götürdünüz mü? | OGM Muğla (aynı sayfa) |
| 6 | Kış | Kuşlar için dışarıya temiz su koydunuz mu? | [RSPB](https://www.rspb.org.uk/whats-happening/news/three-ways-you-can-help-birds-in-a-cold-snap). Türkiye kaynağı bulamadım; yayından önce yerel bir kaynak aranmalı. |
| 7 | Kış | Kuş yemliğinizdeki eski yemi temizlediniz mi? | RSPB (aynı sayfa). Yemliği olmayanlara gösterilmez. |
| 8 | Kış | Soba veya şömine külünü tamamen söndüğünden emin olduktan sonra mı attınız? | [FAO, yangın nedenleri tablosu: "hot ashes"](https://www.fao.org/sustainable-forest-management/toolbox/modules/vegetation-fire-management/basic-knowledge/en/?type=111). Yalnız soba kullandığını seçenlere gösterilir. |
| 9 | Kış | Bugün bir ambalajı geri dönüşüm kutusuna attınız mı? | Olgusal iddia yok |
| 10 | Kış | Çıkarken boş odaların ışığını kapattınız mı? | Olgusal iddia yok |

## 2. Öğretici kart setleri

### 2.1 Kurallar

- Bir ders: 3-5 kart ve 1-2 soruluk mini test. Yaklaşık iki dakika.
- Kart başına **en az bir kaynak**; kaynak adı, tarihi ve bağlantısı kartta görünür.
- Dil: "siz", kısa cümle, teknik terim yok ("meşcere", "ısı anomalisi" gibi sözcükler kullanılmaz).
- Yanlış cevapta "yanlış!" yerine doğru bilgi ve kaynak gösterilir. Tekrar denemek serbesttir, can veya hak sistemi yoktur.
- Yangın dili kuralları:
  - Önce **112**, sonra 177.
  - Uydu bilgisiyle bir yangının söndüğü söylenmez. Haritada görünmemesi yangın olmadığı anlamına gelmez.
  - Olasılık ifadesi yok ("olası", "muhtemel", "%X ihtimal"). Mevcut `SADE-DIL-RAPORU.md` kuralıyla aynı.
- Bağlantısı açılmayan, yayımcısı belirsiz veya tek kaynağa dayanan kartlar içerik onayında işaretlenir.

İlk sürüm konuları: yangın güvenliği, yangın görünce ne yapmalı, orman ekolojisi, yanan alanların yenilenmesi. Hedef en az altı set; aşağıdaki iki set eksiksiz örnektir.

### 2.2 Ders seti A: "Yangın görürseniz"

> **Yayın öncesi uyarı:** Bu sette OGM dışında bir sivil toplum el ilanı (WWF-Türkiye sunucusunda) ve AKUT uyarıları kullanıldı. AFAD'ın halka yönelik sayfasını açamadım. Bu set, OGM veya AFAD'dan teyit edilmeden yayımlanmamalı.

**Kart A1: Önce arayın**

> Ateş ya da duman görürseniz hemen **112**'yi arayın. Orman yangını ihbar hattı **177**'yi de arayabilirsiniz.

- Kaynak: OGM Konya Orman Bölge Müdürlüğü, 17.05.2023. https://www.ogm.gov.tr/konyaobm/haberler/orman-yanginlariyla-mucadele-hazirlik-egitimlerini-tamamladik
- Kaynak: "Yangında sizin de yapacaklarınız var" el ilanı, WWF-Türkiye sunucusu (metinde yayıncı adı ve tarih yok). https://wwftr.awsassets.panda.org/downloads/yang-nan-ndayap-lacaklarafi-.pdf

**Kart A2: Yeri açıkça söyleyin**

> Ekiplerin size ulaşması için yeri net tarif edin. Doğru ve en kısa yolu söyleyin. Yapabiliyorsanız telefonunuzdan konumunuzu paylaşın.

- Kaynak: WWF-Türkiye sunucusundaki el ilanı (yukarıdaki bağlantı).
- Kaynak: AKUT Vakfı uyarıları, STGM sayfası, 03.07.2025. https://www.stgm.org.tr/en/vital-warnings-akut-foundation-against-forest-fires (AKUT resmî kurum değildir.)

**Kart A3: Haber verin, sonra uzaklaşın**

> Büyük bir yangına tek başınıza müdahale etmeyin. Söndürebileceğinizden emin değilseniz müdahale etmeyin. Haber verdikten sonra güvenli biçimde oradan uzaklaşın.

- Kaynak: WWF-Türkiye sunucusundaki el ilanı ("Büyük tehlike arz eden yangınlara tek başımıza müdahale etmeyelim").
- Kaynak: AKUT Vakfı uyarıları, STGM sayfası (yukarıdaki bağlantı).
- Editör notu: Kaynaklarda küçük yangınlara güvenli ilk müdahale de anlatılıyor. Uygulama bunu kasıtlı olarak öğretmez, çünkü "küçük" ve "güvenli" kararını telefondan vermek tehlikeli. AKUT'un kaçış yönü, vadi ve çukur önerileri de resmî teyit olmadan alınmadı.

**Kart A4: Yolu açık bırakın, yetkilileri dinleyin**

> Yangın ekiplerinin geçeceği yolları açık tutun, yol kenarına araç park etmeyin. Alevler evinize yaklaşırsa kapı ve pencereleri kapatın. Yetkililerin söylediklerine uyun.

- Kaynak: OGM Muğla Orman Bölge Müdürlüğü, 25.04.2024. https://www.ogm.gov.tr/muglaobm/haberler/koylerde-yangin-tedbirleri-film
- Kaynak: WWF-Türkiye sunucusundaki el ilanı (yukarıdaki bağlantı).

**Kart A5: Çantanız hazır olsun**

> Evden çıkmanız gerekirse yanınıza alacağınız çantayı önceden hazırlayın: önemli evraklar, ilaç, fener, su, maske ve telefon.

- Kaynak: WWF-Türkiye sunucusundaki el ilanı (yukarıdaki bağlantı).

**Mini test A**

1. *Ormanda duman gördünüz. Önce ne yaparsınız?*
   - **Doğru:** 112'yi ararım. 177'yi de arayabilirim.
   - Haritada görünüyor mu diye bakarım.
   - Yaklaşıp fotoğraf çekerim.
   - Geri bildirim: "Önce arayın. Uydular her yangını göremez: bulut, yoğun duman veya ağaç örtüsü yangını kapatabilir. Haritada görünmemesi yangın olmadığı anlamına gelmez."
   - Kaynak: NASA FIRMS Sık Sorulan Sorular. https://www.earthdata.nasa.gov/data/tools/firms/faq
2. *Ekipler yola çıkacak. En çok ne işe yarar?*
   - **Doğru:** Yeri net tarif etmek ve yolları açık bırakmak.
   - Yangının yanına araçla gitmek.
   - Yol kenarına park edip beklemek.
   - Kaynak: Kart A2 ve A4'teki sayfalar.

### 2.3 Ders seti B: "Yanan orman nasıl yenilenir?"

**Kart B1: Kozalaklar ağaçta bekleyebilir**

> Kızılçamın bazı kozalakları açılmadan yıllarca ağaçta kalabilir. Ormancılık Araştırma Enstitüsü'nün kitabı bu süreyi 8-9 yıl olarak veriyor. Böylece ağacın üzerinde bir tohum deposu oluşur.

- Kaynak: "Kızılçam", El Kitabı Dizisi 2, Ormancılık Araştırma Enstitüsü, s. 44 (OGM sitesi; yayın yılını belgede doğrulayamadım). https://www.ogm.gov.tr/icanadolu/yayinlarimiz-sitesi/Yayinlarimiz/El%20Kitaplar%C4%B1/El%20Kitab%C4%B1_2%20K%C4%B1z%C4%B1l%C3%A7am_Muhtelif_Yayinlar_Serisi-52.pdf
- Kaynak: Arbez, "Distribution, Ecology and Variation of Pinus brutia in Turkey", FAO Forest Genetic Resources Information No. 3 (eski bir saha yazısı, yılı sayfada yok). https://www.fao.org/4/e8705e/E8705E07.htm

**Kart B2: Yangın kozalağı açabilir**

> Yangın sırasında kozalağı kapalı tutan reçine erir. Tohumlar da böylece kolayca dökülür.

- Kaynak: "Kızılçam" El Kitabı, s. 44 (yukarıdaki bağlantı).

**Kart B3: Tohum toprakta bekleyebilir**

> Dökülen kızılçam tohumları, çimlenme gücünü kaybetmeden toprakta bir yıl ve daha uzun süre bekleyebilir.

- Kaynak: "Kızılçam" El Kitabı, s. 44 (yukarıdaki bağlantı).

**Kart B4: Yangının şiddeti sonucu değiştirir**

> Her yangından sonra aynı orman gelmez. Kastamonu'daki bir araştırmada, yerdeki örtüyü yakan yangından sonra karaçam yine en yaygın tür olarak kaldı. Ağaçların tepesine çıkan yangının alanında ise en yaygın bitki laden adlı bir çalıydı.

- Kaynak: Yılmaz, Küçük, Güney, Sağlam. Ormancılık Araştırma Dergisi, 2025, 12(2), 207-220. DOI: 10.17568/ogmoad.1727642. https://dergipark.org.tr/en/download/article-file/4992706

**Kart B5: İnsan eli de devreye girebilir**

> Yenileme için bazen insan eli de devreye girer. Manisa Soma'da 2024'te yanan 701 hektar orman için OGM üç yöntem açıkladı: 249 hektarda doğal yenilenme, 240 hektarda insan eliyle yenileme, 212 hektarda ağaçlandırma. Yeşil örtü oluşana kadar alanın korunacağını yazdı.

- Kaynak: OGM, "Yanan Alanlar Küllerinden Doğuyor", 05.02.2025. https://www.ogm.gov.tr/tr/haberler/yanan-alanlar-kullerinden-doguyor
- Kaynak: FAO, Vegetation Fire Management modülü, "Recovery" bölümü (yeniden dikim ve tohumlamanın istilacı türleri önlemeye yardım edebileceği). https://www.fao.org/sustainable-forest-management/toolbox/modules/vegetation-fire-management/basic-knowledge/en/?type=111
- Not: OGM metnindeki terimler "doğal gençleştirme" ve "yapay gençleştirme". Haber, 2025 sonu için hedef veriyor; hedefin gerçekleşip gerçekleşmediğini doğrulamadım, bu yüzden kartta sonuç iddiası yok.

**Mini test B**

1. *Kızılçam kozalakları hakkında hangisi doğru?*
   - **Doğru:** Bazıları açılmadan yıllarca ağaçta kalabilir.
   - Hepsi aynı yıl dökülür.
   - Yangında tohumları hep yanar.
   - Kaynak: Kart B1 ve B2.
2. *Yanan bir alan hakkında hangisi doğru?*
   - **Doğru:** Yangının şiddetine ve alana göre farklı yöntemler gerekebilir.
   - Her alan kendiliğinden aynı ormana döner.
   - Yanan alanlara hiçbir şey yapılmaz.
   - Kaynak: Kart B4 ve B5.

Kullanılmayan ama araştırılan konu: yanan alanların hukuki durumu ve imar tartışması. Bakanlık açıklamalarını yalnız arama sonucunda gördüm, ayrıca konu tartışmalı. Karta girmedi.

### 2.4 Kaynak denetim kaydı

| Kaynak | Durum |
|---|---|
| OGM Konya haberi, OGM Muğla haberi, OGM Soma haberi | Açıldı, okundu |
| OGM "Kızılçam" El Kitabı | Açıldı, s. 44 metni okundu |
| Ormancılık Araştırma Dergisi 12(2) makalesi | Açıldı, özet okundu |
| WWF-Türkiye sunucusundaki PDF | Açıldı, tek sayfa metni okundu; yayıncı adı metinde yok |
| STGM'deki AKUT uyarıları | Açıldı, özet aracılığıyla okundu |
| FAO modülü ve FAO Arbez sayfası, FAO arka plan sayfası | Açıldı |
| NASA FIRMS SSS | Açıldı |
| RSPB kış rehberi | Açıldı (İngiltere kaynaklı) |
| `afad.gov.tr` (ana sayfa, `/orman-yanginlari`, `/yanginlara-karsi-alinmasi-gereken-onlemler`) | **Açılamadı (HTTP 500).** Kartlarda kullanılmadı. |
| Tarım ve Orman Bakanlığı "İddialar ve Gerçekler" PDF | **Açılamadı (dosya çok büyük).** Kullanılmadı. |
| DOAJ, Soma doğal yenilenme makalesi | **Açılamadı (HTTP 403).** Kullanılmadı. |

HTML sayfalar bir özetleme aracıyla, PDF'ler metin çıkarılarak okundu. Yayından önce bir editör her kartı özgün sayfayla karşılaştırmalı.

## 3. Etkinlikler ve gelişmeler

### 3.1 Lisans ve kullanım şartları

Bu tablo hukuki görüş değildir. "İzin veriyor" yazmayan hiçbir şey izinli sayılmamalı.

| Kaynak | Kontrol edilen sayfa | Ne izin veriyor | Belirsiz olan / yazılı izin gereken |
|---|---|---|---|
| **OGM** | `ogm.gov.tr/tr/kullanim-kosullari` ve `/tr/yasal-uyari`: **404**. Ana sayfa altbilgisi, `/tr/takip-edin/rss`, `/tr/duyurular`: açıldı, kullanım şartı yok. | Yazılı bir izin bulamadım. Haber ve duyuru RSS'i herkese açık sunuluyor, ama bu tek başına yeniden yayım izni değildir. | Metin, fotoğraf, logo ve tam metin kullanımı. RSS'te tam metin geliyor, kanal düzeyinde telif etiketi yok. **Yazılı izin istenmeli.** |
| **TEMA Vakfı** | `tema.org.tr/kullanim-kosullari` ve `/yasal-uyari`: **404**. Ana sayfa, `/kvkk`, `/sikca-sorulan-sorular`, `/basin-odasi/basin-bultenleri`, `/basin-odasi/bizden-haberler`: açıldı. | Yeniden kullanım izni yok. Altbilgi: "©Copyright 1992 - 2026 TEMA...". | SSS sayfası: logo "yasal koruma altındadır, kullanımı belirli kurallara ve izne tabidir". Logo kullanılmamalı. Metin ve fotoğraf için **yazılı izin istenmeli.** |
| **WWF-Türkiye** | `wwf.org.tr/kullanim_kosullari/` ve ana sayfa: **403**. `wwf.panda.org/wwf_legal/`: **403**. | **Doğrulayamadım.** | Site koşulları okunamadı. Aramada yayınlara özgü farklı telif notları göründü, ama sayfaları açmadım, lisans sayılmaz. Açtığım PDF'in metninde telif notu yok. **Yazılı izin istenmeli.** |
| FAO | https://www.fao.org/contact-us/terms/en/ (açıldı) | Özel çalışma, araştırma, eğitim ve **ticari olmayan** ürünlerde kopyalama; FAO kaynak olarak belirtilmeli; FAO'nun onayı ima edilmemeli. Bağlantı vermek için izin gerekmez. | Çeviri, uyarlama, ticari kullanım başvuruya tabi. Fotoğraf değiştirilemez. Logo izinsiz kullanılamaz. |
| AFAD | `afad.gov.tr`: **HTTP 500**. | **Doğrulayamadım.** | Her kullanım. |
| Belediyeler | **Kontrol edilmedi.** | Varsayılamaz. | Her belediye ayrı kontrol edilir; yalnız izin ve koşulu kayıtlı olanlar listeye girer. |

Sitelerin menüsünde koşul bağlantısı olmadığı için `/kullanim-kosullari`, `/yasal-uyari`, `/kullanim_kosullari/` ve `/wwf_legal/` adreslerini tahminle denedim. 404 yanıtı, koşul metninin hiç olmadığını kanıtlamaz; yalnız bulamadığımı gösterir.

Yasal not: [5846 sayılı Kanun](https://www.mevzuat.gov.tr/mevzuatmetin/1.3.5846.pdf) madde 31 yalnız resmen yayımlanan kanun, kararname, yönetmelik, tebliğ, genelge ve yargı kararlarını serbest bırakıyor; kurum haberlerinden söz etmiyor. Madde 36 basın ve radyoda yayılmış günlük haberlerin alıntılanmasından söz ediyor. Bunun bir uygulamaya ve kurum sitelerine uygulanıp uygulanmadığı hukukçu sorusudur.

**Yazılı izin gelene kadar önerilen kural:** yalnız başlık, tarih, kaynak adı, kendi cümlemizle en çok iki cümle özet ve kaynağa bağlantı. Tam metin (`paragraphs`), fotoğraf ve logo yok. Sebep: `NewsDetailScreen` `paragraphs` ve `highlights` alanlarını gösteriyor; OGM RSS'i tam metin verdiği için `createNews` içindeki `body: cleanSummary` akışı olduğu gibi kullanılırsa tam metin yeniden yayımlanmış olur.

Teyit edilen örnek davranış: OGM beslemesinde restorasyon ve fidan haberleri var (son öğeler 30 Ekim - 6 Kasım 2026), ama etkinliğin başlangıç/bitiş tarihi ayrı alan olarak yok. TEMA sayfalarında güncel etkinlik takvimi bulamadım, RSS görmedim. TEMA SSS'si bağışçıların fidan dikimine katılamadığını söylüyor; fidan bağışı "etkinlik" diye gösterilmemeli.

### 3.2 Uydurma etkinlik olmaması için kurallar

- Bir kayıt ancak şunlar varsa yayımlanır: kaynak sayfa bağlantısı (https, onaylı alan adı), başlangıç ve bitiş tarihi, il, **insan onayı**.
- Tarih yoksa kayıt "Etkinlikler"e değil "Gelişmeler"e (`recovery`) gider.
- Etkinlik metni yapay zekâ ile üretilmez, tarih tahmin edilmez.
- Bitmiş etkinlik listeden düşer. Mevcut `_filteredItems` geçmiş etkinliği elemiyor; backend'de `event_end >= now` filtresi şart.
- `source` boş veya "Bilinmiyor" ise kayıt reddedilir.
- İçerik yoksa "Şu an doğruladığımız bir etkinlik yok." yazılır, örnek veri gösterilmez.

### 3.3 Haber sekmeleri altyapısıyla birleşme

Bugün var olan (Flutter):

- `NewsScreen._contentTypes`: `fires`, `recovery` (Yenilenme), `solidarity` (Dayanışma), `events` (Etkinlikler).
- `FeatureFlags.newsContentTabs` = `kDebugMode || NEWS_CONTENT_TYPES`. Release'te kapalı, yalnız yangın akışı görünür.
- `NewsService.fetchNewsFromRender(contentType:)`, `content_type` parametresini gönderiyor.
- `NewsItem`: `contentType`, `actionUrl`, `eventStart`, `eventEnd`, `eventCity`, `eventLocation`, `officialSource`.
- `NewsEventActions`: tarih satırı, "Katıl"/"Bağış yap" ve takvime ekleme. Düğmeler yalnız `officialSource` ve iki https bağlantıyla çıkıyor. Bu kural korunmalı.

Eksik olan (backend):

| # | Eksik | Yer |
|---|---|---|
| 1 | `news` tablosunda `content_type` (varsayılan `fires`), `action_url`, `event_start`, `event_end`, `event_city`, `event_location`, `official_source` sütunları; indeks | Yeni göç `016`; son göç `015` |
| 2 | `content_type` okuma ve SQL filtresi | `newsController.getAllNews`, `newsService.getAllNews` |
| 3 | Önbellek anahtarında tür yok: `news:v2:${category}:${limit}:${offset}`. Eklenmezse türler birbirine karışır. | `newsController` |
| 4 | `isInFiresFeed` / `relevantPageIds` yalnız yangın haberlerini geçiriyor; diğer türler bu kapıdan muaf olmalı, `fires` da yalnız `fires` döndürmeli | `newsService`, `newsRelevance.ts` |
| 5 | `createNews` INSERT listesi yeni alanları içermiyor; `News` tipi | `newsService.ts`, `types` |
| 6 | Doğa kaynağı ve onay akışı yok. `checkRelevance` yangın sözcüğü arıyor, kullanılamaz. | Yeni admin uç noktası, mevcut `requireAdminToken` ile |
| 7 | `dist/` derlenip commit edilmezse Render'a gitmez | Bellek notu: backend dağıtımı |

Eksik veya düzeltilecek (Flutter):

- Backend parametreyi yok sayarsa bütün öğeler `fires` döner ve `_ofCurrentType` hepsini eler: sekmeler sessizce boş kalır. Backend tamamlanmadan bayrak açılmamalı.
- `NewsScreen.initState` içindeki `_loadMyRegion`, `getNearestCity` ile **konumu sunucuya gönderiyor** ve konum izni isteyebiliyor. Doğa sekmesi bunu yapmamalı (bölüm 5). `NewsScreen` olduğu gibi gömülmemeli.
- İl sıralaması Doğa'da kullanıcının elle seçtiği ile veya kayıtlı yerlere göre yapılmalı.
- `officialSource` adı TEMA ve WWF gibi sivil kuruluşlar için yanıltıcı; bölüm 8.6.

Önerilen birleşme:

1. Veri tek yerde kalır: `news` tablosu ve `GET /api/news?content_type=...`. Ayrı "doğa etkinlik" tablosu açılmaz.
2. `NewsScreen`'deki yangın dışı dalları (yükleme, sayfalama, etkinlik sıralaması) konum çağırmayan ortak bir `ContentTypeFeed(contentType)` widget'ına taşınır. Kart olarak mevcut `NewsCard` + `NewsEventActions` kullanılır.
3. Doğa sekmesinde "Etkinlikler ve gelişmeler" bölümü: `events` + `recovery` + `solidarity` üç sekme.
4. Haberler sekmesi yangın akışı olarak kalır, kategori çipleri kaldırılır. Aynı içerik iki yerde görünmez (karar: bölüm 8.5).
5. Bu bölüm `FeatureFlags.newsContentTabs` ile açılır; bayrağın adı yeni anlamı için `natureFeed` olarak değiştirilebilir.

## 4. Rozetler ve hatırlatma

### 4.1 Rozetler

Yalnız kazanılır, geri alınmaz, süresi dolmaz.

| Rozet | Koşul |
|---|---|
| İlk Adım | İlk görev işaretlendi |
| Yedi Gün | Toplam 7 gün işaretlendi (üst üste olması gerekmez) |
| Otuz Gün | Toplam 30 gün işaretlendi |
| Dört Mevsim | Dört farklı mevsimde birer görev işaretlendi |
| Kuş Dostu | Kuş görevlerinden 5'i "evet" |
| Tasarrufçu | Enerji görevlerinden 5'i "evet" |
| Meraklı | 3 ders bitti |
| Bilgi Sahibi | Yangın güvenliği derslerinin tamamı bitti |

Puan tablosu, arkadaşlarla sıralama, satın alınan avantaj yoktur. Rozetler sunucuya gitmez, paylaşım isteğe bağlıdır ve yalnız görseli paylaşır.

### 4.2 Hatırlatma

- **Varsayılan kapalı.** Doğa ayarlarından açılır, saat seçilir (öneri 19:00). Kullanıcı açmadan izin penceresi çıkmaz.
- Günde en fazla **1**. O gün görev işaretlendiyse gönderilmez.
- Metin tek ve sakin: "Bugünün doğa görevi hazır." Seri sayısı yazılmaz, emoji ve ünlem yoktur.
- Kişi bir hafta hiç açmazsa hatırlatma kendiliğinden durur ve sebebi Doğa sekmesinde bir kez söylenir.

Kod etkisi (`NotificationService` okundu):

- Tamamen yerel: `flutter_local_notifications` ile. FCM ve sunucu kullanılmaz.
- `zonedSchedule` şu an kullanılmıyor. `timezone` paketi doğrudan bağımlılık olarak eklenmeli.
- Kesin alarm izni istenmez; `inexactAllowWhileIdle` yeterli.
- Telefon yeniden başlayınca zamanlamanın korunması için `AndroidManifest`'e önyükleme alıcısı gerekir; ayrıca her açılışta yeniden zamanlanır.
- Ayrı düşük önemli kanal: `firewatch_nature`. Yangın kanallarından bağımsız kapatılabilir.
- `showManualAlert` kullanılmaz, çünkü `AlertInbox`'a yazar. Doğa hatırlatması Uyarılar kutusuna girmemeli.
- `openPayload` içine `nature` eklenir. Uygulama kapalıyken bildirime dokunma için `getNotificationAppLaunchDetails` gerekiyor; kodda hiç yok.
- Yangın uyarısı gelen günün hatırlatması iptal edilir.

## 5. Gizlilik

### 5.1 Tasarım

- Görev yanıtları, seri, ders ve test sonuçları, rozetler ve hatırlatma saati yalnız cihazda, `shared_preferences` içinde tek bir sürümlü JSON (`nature_progress_v1`). Mevcut `WatchlistNotifier` deseni izlenir.
- Görev ve ders içeriği uygulamayla birlikte gelir (`assets/nature/*.json`), ağ isteği yapılmaz.
- `AndroidManifest` içinde `allowBackup="false"` ve `fullBackupContent="false"`: ilerleme Google yedeğine de gitmez. Bedeli: uygulama silinirse veya telefon değişirse ilerleme kaybolur. Bu kullanıcıya açıkça söylenir.
- Analitik eklenmez; politika "analitik veya izleme yazılımı yoktur" diyor. Bu yüzden özelliğin kullanım oranını ölçemeyiz. Tercih bilinçlidir.
- Ayarlar'a "Doğa verilerimi sil" eklenir.

İki sınır:

1. "Etkinlikler ve gelişmeler" listesi internetten gelir. Yeni kişisel veri göndermez, ama her istekte olduğu gibi IP ve erişim kaydı oluşur (politikada mevcut satır).
2. Dış bağlantı açıldığında kaynağın sitesi IP adresini görür.

### 5.2 Politika etkisi

`src/routes/legal.ts` içinde gerekli değişiklik küçük. "Yalnızca cihazınızda kalan veriler" paragrafına eklenecek metin:

- TR: "Doğa sekmesindeki görev yanıtlarınız, seriniz, ders ve test sonuçlarınız, rozetleriniz ve hatırlatma saatiniz de yalnızca telefonunuzda saklanır; bize gönderilmez."
- EN: "Your Nature tab task answers, streak, lesson and quiz results, badges and reminder time are also stored only on your phone and are never sent to us."

Ayrıca `POLICY_DATE_TR` ve `POLICY_DATE_EN` güncellenir. Dosyada `legal.ts` 73 ve 139. satırlar. Backend `dist/` de derlenip commit edilmeli. Google Play Veri Güvenliği beyanında değişiklik beklenmiyor; sürüm öncesi yeniden kontrol edilir.

## 6. Karanlık örüntü yasakları

| Yapılmayacak | Yerine |
|---|---|
| "Seriniz bozulacak!", "Bizi unuttunuz" | Hiç mesaj yok veya "Bugünün görevi hazır." |
| "Bugün doğaya yardım etmediniz" | "Hayır" yanıtı sessizce kaydedilir |
| Seri dondurma satışı, can veya hak sistemi | Haftada iki gün otomatik af |
| Üst üste bildirim, geri dönüş bildirimi, rozetli sekme simgesi | Günde en fazla 1, varsayılan kapalı, Doğa simgesinde kırmızı nokta yok |
| Kapatma düğmesini gizlemek | Her iletişim kutusunda görünür "Kapat" |
| Yangınla korkutarak görev yaptırmak | Yangın bilgisi sade ve sakin |
| Rozet karşılığı bağış isteme | Doğa görevleriyle bağış ilişkilendirilmez |
| İhbar sayısına göre ödül | İhbar ve 112 hiçbir ödül sistemine bağlanmaz |

Otomatik koruma: `test/plain_language_test.dart` benzeri bir test, Doğa içeriğinde şunları tarar: "kaybedeceksiniz", "unuttunuz", "bozulacak", "olası", "muhtemel", tam sözcük olarak "söndü" ve "sen" dili. Ayrıca her kartın en az bir https kaynağı olduğunu doğrular.

Not: mevcut Güvenlik Rehberi metinlerinde "sen" dili var ("Evdeysen ne yapmalısın?"). Doğa "siz" kullanacağı için tutarlılık ayrı bir karar (bölüm 8.8).

## 7. Taslaklar, süre, PR planı

### 7.1 Ekran taslakları

**Doğa ana ekranı**

```
+--------------------------------------+
| Doğa                         [Ayarlar]|
|--------------------------------------|
| Yangın görürseniz önce 112.    [Ara] |
|--------------------------------------|
| BUGÜNÜN GÖREVİ          Kış görevi   |
| Kuşlar için dışarıya temiz su        |
| koydunuz mu?                         |
|                                      |
|   [  Evet  ]      [ Hayır ]          |
|              Başka görev             |
|   Kaynak: RSPB                       |
|--------------------------------------|
| Bu hafta: ● ● ● ○ ○ ○ ○   3 gün      |
| Seri: 3 gün · Haftalık özet >        |
|--------------------------------------|
| DERSLER                              |
| [Yangın görürseniz     5 kart  2 dk] |
| [Yanan orman nasıl...  5 kart  2 dk] |
|--------------------------------------|
| ETKİNLİKLER VE GELİŞMELER            |
| (Etkinlik)(Yenilenme)(Dayanışma)     |
| [ Kaynak · tarih · il · Başlık     ] |
|--------------------------------------|
| Rozetlerim (2/8) >                   |
+--------------------------------------+
| Ana   Harita   Doğa   Haber   Uyarı  |
+--------------------------------------+
```

**Görev yanıtlandıktan sonra**

```
+--------------------------------------+
| BUGÜNÜN GÖREVİ                       |
| Kaydedildi. Teşekkürler.             |
| Yarın yeni bir görev burada olacak.  |
+--------------------------------------+
```

**Ders kartı**

```
+--------------------------------------+
| <  Yangın görürseniz      1 / 5      |
| ■■□□□                                |
|--------------------------------------|
|  Önce arayın                         |
|                                      |
|  Ateş ya da duman görürseniz hemen   |
|  112'yi arayın. Orman yangını ihbar  |
|  hattı 177'yi de arayabilirsiniz.    |
|                                      |
|  Kaynak                              |
|  OGM Konya Bölge Müd., 17.05.2023    |
|  ogm.gov.tr/konyaobm/... [Aç]        |
|--------------------------------------|
|      [ Geri ]      [ İleri ]         |
+--------------------------------------+
```

**Mini test**

```
+--------------------------------------+
| Soru 1 / 2                           |
| Ormanda duman gördünüz.              |
| Önce ne yaparsınız?                  |
|                                      |
| ( ) 112'yi ararım. 177'yi de         |
|     arayabilirim.                    |
| ( ) Haritada görünüyor mu bakarım.   |
| ( ) Yaklaşıp fotoğraf çekerim.       |
|                                      |
| Önce arayın. Uydular her yangını     |
| göremez. Haritada görünmemesi yangın |
| olmadığı anlamına gelmez.            |
| Kaynak: NASA FIRMS SSS [Aç]          |
|                 [ Devam ]            |
+--------------------------------------+
```

**Haftalık özet**

```
+--------------------------------------+
| <  Bu hafta                          |
|--------------------------------------|
| 4 gün görev işaretlediniz.           |
| 3 görevi yaptınız.                   |
| 1 ders bitirdiniz.                   |
|                                      |
| Bu bilgiler yalnızca telefonunuzda.  |
|                [ Tamam ]             |
+--------------------------------------+
```

**Etkinlik kartı ve boş durum**

```
+--------------------------------------+
| [Kurum adı]             Kaynağı aç > |
| Etkinlik başlığı                     |
| 12 Ara 10:00 · İl · Yer              |
| Kendi cümlemizle en çok iki cümle.   |
| [ Katıl ]   [ Takvime ekle ]         |
+--------------------------------------+
| Şu an doğruladığımız bir etkinlik    |
| yok. Yenisi eklenince burada olur.   |
+--------------------------------------+
```

**Doğa ayarları**

```
+--------------------------------------+
| <  Doğa ayarları                     |
| Günlük hatırlatma          [ kapalı ]|
| Saat                         19:00   |
| Seriyi göster              [ açık  ] |
|--------------------------------------|
| İlerlemeniz yalnızca bu telefonda.   |
| Uygulamayı silerseniz kaybolur.      |
| [ Doğa verilerimi sil ]              |
+--------------------------------------+
```

### 7.2 PR planı (sırayla)

Tahmin tek geliştirici içindir, gün cinsinden. 1.2.0 mağazaya çıktıktan ve çalışma ağacındaki açık değişiklikler commit edildikten sonra başlanmalı (`lib/l10n` dosyaları şu an değişmiş durumda).

| # | Depo | İçerik | Süre (gün) | Bağımlılık |
|---|---|---|---|---|
| 0 | Kod yok | Sekme kararı, OGM/TEMA/WWF/AFAD'a izin yazıları, AFAD içerik teyidi | 1 (yanıt süresi hariç) | - |
| 1 | Flutter | Sekme iskeleti, `FeatureFlags.natureTab`, gezinme, `/app?tab=nature` | 1,5 | 0 |
| 2 | Flutter | Yerel depo, görev seçici, seri kuralları, birim testleri | 2 | 1 |
| 3 | Flutter | Görev kartı, haftalık özet, mevsim havuzu | 2 | 2 |
| 4 | Flutter | Ders oynatıcı, mini test, içerik formatı, kaynak ve dil testleri | 3 | 1 |
| 5 | İçerik | 50 görev, en az 6 ders, kaynak doğrulama, TR/EN | 5 | 4 |
| 6 | Flutter | Rozetler | 1,5 | 2 |
| 7 | Flutter | Yerel hatırlatma, kanal, önyükleme, soğuk açılış yönlendirmesi | 2 | 2 |
| 8 | Her ikisi | Doğa ayarları, veri silme, politika metni, backend `dist` | 1 | 2, 7 |
| 9 | Backend | Göç 016, `content_type` filtresi, önbellek anahtarı, yerel doğrulama, `dist` | 2,5 | - |
| 10 | Backend | Onaylı içerik uç noktası, alan adı listesi, tarih kuralları | 2,5 | 9 |
| 11 | Flutter | `ContentTypeFeed`, Doğa etkinlik bölümü, Haberler sadeleştirme | 1,5 | 9, 10 |
| 12 | Her ikisi | 1.3.0 sürüm notu, mağaza metni, Veri Güvenliği kontrolü, uçtan uca test | 1,5 | hepsi |

**Toplam: yaklaşık 27 gün.** En belirsiz kalem izin yanıtlarıdır. PR 9-11 izin gelmeden biterse bölüm 3.1'deki yalnız bağlantı kuralıyla yayımlanır; hazır değilse 1.3.0 etkinlik bölümü olmadan çıkabilir, bölüm gizli kalır.

Doğrulama kuralı: her PR, yerelde uçtan uca çalıştığı görülmeden push edilmez. Bu makinede RAM düşük olduğu için emülatör testleri tek tek ve ayrı oturumlarda yapılmalı.

## 8. Karar sahibinin açık kararları

1. **Altıncı sekme mi, Risk'i taşımak mı?**
   - A: Altı sekme. Kod değişikliği küçük (`clamp(0,4)`, yönlendirici), ama dar ekranda sıkışır. Material 3 sayfasının içeriğini okuyamadığım için sınırı kaynaktan doğrulayamadım; genel bilinen sınır 3-5 hedeftir.
   - B: Beş sekme kalır, **Doğa, Risk'in yerine geçer**; Risk Ana Sayfa'dan açılır. `/risk` rotası ve Ana Sayfa'daki bağlantılar zaten var (`home_screen.dart` 787, 841, 893). `/app?tab=risk` yönlendirmeleri güncellenir.
   - Öneri: B. Yaz aylarında Risk'e erişimin azalıp azalmadığı izlenemeyeceği için karar sizin. Taslak B'ye göre çizildi.
2. AFAD sayfaları açılamadı. Ders A için OGM'ye yazılı teyit sorulsun mu, yoksa AFAD sayfasını siz mi kontrol edeceksiniz?
3. Mevsim tarihleri bölüm 1.2'deki gibi olsun mu? Akdeniz ve Karadeniz için ayrı dönem istenir mi? (İstenirse konum veya elle bölge seçimi gerekir.)
4. Kim izin yazısı gönderecek, kim etkinlikleri onaylayacak? Elle onay süreklilik gerektirir.
5. Yenilenme, Dayanışma ve Etkinlikler yalnız Doğa'da mı görünsün (öneri), Haberler'de de kalsın mı?
6. `official_source` TEMA ve WWF için de `true` olacak mı, yoksa `source_kind` (resmî / sivil toplum / belediye) alanı mı eklensin? "Katıl" düğmesi buna bağlı. Öneri: `source_kind`.
7. Doğa'da "Bağış yap" düğmesi olsun mu? Öneri: 1.3.0'da yok.
8. Güvenlik Rehberi'ndeki "sen" dili bu sürümde "siz"e çevrilsin mi?
9. Ticari model değişirse (B2B veya Pro) FAO'nun "ticari olmayan" koşulu dahil kaynak izinleri yeniden gözden geçirilmeli. Yazılı izin istekleri buna göre yazılsın mı?
10. RSPB dışında Türkiye'den kuş besleme kaynağı bulunamazsa kuş görevleri kalsın mı? (Yemek önerisi içermeyen su görevi kalabilir.)
11. Telefon değiştirenler için dışa aktarma istenir mi? Öneri: 1.3.0'da yok, "yalnızca cihazda" sözü en sade hâliyle kalır.

## Görsel karar (8 Kasım 2026)

Doğa sekmesi uygulamanın mevcut temasını kullanır. Ayrı açık tema veya lacivert/amber palet yoktur; yalnız hafif yeşil vurgular kullanılır. Bu belgede buna aykırı bir ifade varsa bu not geçerlidir.

## Uygulama durumu (8 Kasım 2026)

Sekme uygulandı. Kaynaklar yeniden açılıp kontrol edildi; aşağıdakiler içeriğe alınmadı:

| İçerik | Neden |
|---|---|
| Kızılçam kozalak ve tohum bilgileri | El kitabı PDF'i görüntü tabanlı, metni doğrulanamadı |
| "Yol kenarına park etmeyin" | OGM Muğla sayfası yalnız araçların köy içinden geçişini engellememekten söz ediyor |
| WWF el ilanı ve AKUT'a dayanan kartlar | Yayıncı belirsiz veya resmî kurum değil |
| Kuş besleme görevleri | Türkiye kaynağı yok |
| Etkinlikler ve gelişmeler | Backend ve yayın izni yok; uydurma etkinlik olmaması için bölüm eklenmedi |

Hatırlatma, seçilebilir saat yerine günde bir kez çalışan basit yerel bildirimdir ve o gün görev işaretlense de gönderilir.
