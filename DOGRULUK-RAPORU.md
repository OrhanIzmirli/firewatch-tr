# FireWatch TR doğruluk denetimi

Tarih: 8 Kasım 2026. Canlı veri anlık görüntüsü: **08:26 UTC**. Uygulama: `integrate/orhan` (1.2.0+8). Backend: `origin/main` (`648ba49`).

## Sonuç

**Uydu, hava durumu, risk puanı ve OGM rakamlarında uydurma ya da yanlış veri bulunmadı.** Sorunlar verinin kendisinde değil, verinin **anlatımında** ve bir **bozuk eşleştirmede**:

- En ciddi bulgu: yangın ihbarı gönderen kullanıcıya "acil durum ekipleri zaten bilgilendirildi" yazan bir metin vardı. Kodda böyle bir iletim yok.
- İhbar doğrulaması boş bir tabloya bakıyordu; hiçbir ihbar eşleşemezdi.
- Uygulama ısı tespitlerine birçok yerde "canlı yangın" diyordu, 3 saatlik puana "gerçek zamanlı" diyordu.

## 1. Veri karşılaştırmaları

| Alan | Neyle karşılaştırıldı | Örneklem | Sonuç |
|---|---|---|---|
| Termal tespitler (`/api/thermal`) | NASA FIRMS açık NOAA-20 24 saatlik CSV (anahtarsız) | 98 satır, Türkiye kutusu | **98/98 eşleşti.** Eksik ve fazla satır yok. Koordinat, tarih, saat, FRP, parlaklık, tarama boyutları, gece/gündüz aynı. Güven değeri aynı, yalnız yazımı farklı (`n` = `nominal`). |
| Olaylar (`/api/incidents`) | Aynı NASA dosyası | NASA penceresindeki 25 tek pikselli NOAA-20 olayı | **25/25** saat, konum ve FRP birebir. |
| Saat dilimi | Kod ve NASA | API `00:43Z` = NASA `0043`; uygulamada `DateTime.utc` ile ayrıştırılıyor | Doğru. Ekranda gösterim koddan incelendi, cihazda çalıştırılmadı. |
| İl atamaları | Eski GADM çokgenleri (bağımsız), ayrışanlar için Nominatim | 100 olay, 24 geçmiş kaydı | 94 olay iki kaynakta aynı. Ayrışan 7 Türkiye noktasının **7'sinde** Nominatim backend'i doğruladı; hatalı olan eski, kaba sınırlar. |
| Sınır dışı olay | Pakette gelen il sınırları | 100 olay | 1 olay (13560) Yunanistan tarafında, sınırdan 5,1 km dışarıda, "Edirne" etiketli. 6 Kasım tarihli, yani 1,5 km'lik sınır kapısından (migration 012, 7 Kasım) önce kayda geçmiş. Süresi dolunca listeden çıkar; yeni kayıt beklenmiyor. |
| Bölge eşlemesi | 81 ilin resmî coğrafi bölge listesi | 100 olay | Uyuşmazlık yok. |
| Hava verisi | Open-Meteo ham yanıtı, aynı saat ve nokta | 7 bölge | **7/7** yuvarlama farkı içinde aynı. MET Norway yedeği aynı büyüklükte, rüzgârda doğal farklar var. |
| Risk puanı, seviye, kuruluk, bitki baskısı | Formül elle yeniden hesaplandı | 7 bölge | **7/7** birebir. Eşikler 25/50/75. |
| OGM yanan alan, ülke toplamı | TBMM yanıtları, Ormancılar Derneği, basına yansıyan OGM verisi | 2016-2025 | 2021 (139.503 ha, 2.793 yangın), 2022 (12.799 ha, 2.160), 2023 (15.520 ha, 2.579), 2024 (27.485 ha, 3.797) ve 2025 (81.473 ha, 3.224) tutuyor. 2016-2024 toplamı, 2015'in 3.219 ha'sıyla birlikte yayımlanan 10 yıllık toplama (257.622 ha, 27.332 yangın) **tam** eşit. |
| OGM, il kırılımı | Yalnızca makul olup olmadığı | Antalya 2021: 60.367 ha, Muğla 50.603 ha | Yıl toplamları tuttuğu için büyük olasılıkla doğru; **il il resmî tabloyla karşılaştırılamadı**. |
| EFFIS alanı | Bağımsız kaynak aranıyor | 10 yıl | **Doğrulanamadı.** EFFIS'in yıllık ülke API'sine erişilemedi. TBMM önergesindeki 81.985 ha yıllık ortalama aynı büyüklükte ama dönemi farklı olabilir. |
| Uydu noktası sayısı (yıllık katman) | — | — | **Doğrulanamadı.** Veri dosyasının beyanına dayanıyor; uygulama bunu zaten böyle söylüyor. |
| Haberler | Her haberin kaynak sayfası indirildi | 100 haber | **Uydurma yok.** 100/100 sayfa açıldı, başlık kelimeleri sayfada bulundu. Tarih bulunan 97 haberin hiçbirinde 24 saatten büyük fark yok; en büyük fark 8,4 saat (RSS tarihi sayfadakinden sonra). |
| Haber alakası | Elle okuma | 100 haber | 3 alakasız haber vardı (aşağıda B7). |
| Haber güncelliği | Canlı RSS | 10 kaynak | En yeni haber 24 Ekim. Bugün akışlarda yalnız bina yangını var; boşluk büyük olasılıkla mevsimsel. Geçmiş iki hafta tek tek doğrulanamadı. |

## 2. Bulunan hatalar ve düzeltmeler

Durum: **Uygulama** düzeltmeleri `integrate/orhan` üzerinde yerel commit (`0002ac5`, `f14b908`, `2d76d1e`). **Backend** düzeltmeleri `fix/accuracy-audit` dalında yerel commit (`a2e89b1`). İkisi de henüz push edilmedi, bkz. bölüm 4.

| # | Önem | Yanlış olan | Kaynağı | Düzeltme | Test |
|---|---|---|---|---|---|
| B1 | **Kritik** | "Burası aktif bir yangın bölgesi — acil durum ekipleri zaten bilgilendirildi." Kimseye iletim yok; kişi 112'yi aramayabilir. | `reportPanelResponseTimeVerified` | "Bu bildirim acil durum ekiplerine iletilmez. Yangın görüyorsanız hemen 112'yi arayın." | `no_unverified_claims_test` |
| B2 | **Yüksek** | İhbar doğrulaması hiç veri yazılmayan `fires` tablosuna bakıyordu, zaman sınırı da yoktu. Hiçbir ihbar eşleşemezdi. | `routes/fires.ts` | `fire_detections`, 10 km, son 24 saat. | `test-alert-text` |
| B3 | **Yüksek** | "Rapor Doğrulandı", "NASA verisiyle otomatik doğrulanacak". 10 km içinde ısı olması yangını doğrulamaz. "Ekibimiz manuel inceliyor" diye bir süreç de görünmüyor. | ARB, `fires.ts` | "Uydu Tespitiyle Eşleşti", "tek başına doğrulamaz". | aynı |
| B4 | **Yüksek** | Risk bildirimi her zaman "Sıcaklık yüksek, nem düşük" diyordu; puan rüzgâr ve tespitlerden de gelebilir. | `riskCalculatorJob.ts` | Gerçek sıcaklık, nem, rüzgâr yazılıyor. | `test-alert-text` |
| B5 | **Yüksek** | "Kritik: Çoklu Yangın Tespiti": uydu noktalarına yangın deniyordu. | `riskCalculatorJob.ts` | "Çoklu Uydu Isı Tespiti", "Doğrulanmış yangın değildir", 112. | aynı |
| B6 | **Yüksek** | "Son Dakika" rozeti sonsuza kadar kalıyordu; 9 Eylül haberi bugün de öyleydi, "Termometre 30 derecelerde" dahil. | Uygulama yaş kontrolü yapmıyordu | Yayımdan sonra 6 saat. | `news_breaking_badge_test` |
| B7 | Orta | Ev yangını (#3271), halı saha malzemesi yangını (#3142), hava durumu (#3123) orman yangını akışındaydı. | `wildfireRelevance.ts` | Filtre genişletildi; veri silinmedi, gösterim süzülüyor. | `test-wildfire-relevance` |
| B8 | Orta | Risk puanının "RSS haber akışları" ile hesaplandığı yazıyordu. Haber formülde yok. | `riskInfoSourcesBody` | Düzeltildi; ayrıca her bölgenin tek noktadan hesaplandığı yazıldı. | `no_unverified_claims_test` |
| B9 | Orta | "gerçek zamanlı risk analizi". Hesap yaklaşık 3 saatte bir. | ARB | "yaklaşık 3 saatte bir". | aynı |
| B10 | Orta | "canlı yangın noktaları/tespitleri" (öğretici ekranlar). Bunlar ısı tespiti. | ARB | "uydu ısı tespiti, her biri yangın olmayabilir". | aynı |
| B11 | Orta | Uydu verisi "her 3 saatte bir güncellenir". Çekme işi 30 dakikada bir. | ARB | "yaklaşık 30 dakikada bir", gecikme notu. | — |
| B12 | Orta | "ormanlık, yüksek riskli bir bölgede", "tarım arazisinde", "kentsel alanda": yalnızca **il adından** noktaya hüküm. | `smartLocationHint*` | "ormanlık alanı geniş bir ilde" vb. | `no_unverified_claims_test` |
| B13 | Orta | 98 tespitin 3'ü Yunanistan/Irak tarafında olduğu hâlde Türkiye sayılıyordu; aynı kurallar Yüksekova ve Esendere'yi siliyordu. | `turkey_land_filter.dart` | Sınır tabloları pakette gelen il çokgenlerinden üretildi. Sonuç: 3 sızıntı gitti. Kalan 2 nokta Çanakkale kıyısında, 150 m'den yakın. | `turkey_land_filter_test` |
| B14 | Düşük | "Yangın tespit edildi, N saattir görülmüyor". | ARB | "Isı tespit edildi". | — |
| B15 | Düşük | Risk formülü sayfasında +20'ye kadar sıcak-kuru eki yoktu; "NASA Yangın Sayısı" yanlış adlandırmaydı. | ARB, `risk_screen` | Satır eklendi, ad düzeltildi. | — |
| B16 | Düşük | "VIIRS: Suomi NPP uydusu": 2 Kasım'dan beri veri yok. | ARB | NOAA-20/21. | — |
| B17 | Düşük | "EFFIS ... yeniden erişime açıldığında eklenecektir": tarihsiz vaat. | `trustMapSource` | Kaldırıldı. | — |
| B18 | Düşük | "15 dakikada bir yangın kontrolü": Android süreyi geciktirebilir. | ARB | "yaklaşık ... (Android bunu geciktirebilir)". | — |
| B19 | Düşük | "Canlı Harita/Veri/Bilgi Akışı": NASA'nın NRT verisi saatlerle gecikebilir. | ARB | "Güncel", "Uydu Verisi", "Haber Akışı". | — |

Kontrol edilip doğru bulunanlar: 50 km uyarı yarıçapı, 1,2 km küme yarıçapı, 188 m geçmiş izi, 30 MW / 350 K eşiği, 25/50/75 bantları, yer başına 5 takip, "söndü" iddiası olmaması.

## 3. Düzeltilmeyen, senin bilmen gerekenler

| Konu | Neden düzeltmedim |
|---|---|
| Her bölgenin riski tek noktanın havasından geliyor (Ege = İzmir, Akdeniz = Antalya…). Isı haritası bu 7 nokta arasında yumuşatma yapıyor, ince bir ayrıntı varmış gibi görünüyor. | Metinde artık açıkça yazıyor. Çözüm ürün kararı: daha çok nokta, daha çok Open-Meteo isteği. |
| `fires` tablosu ve `GET /api/fires` boş ve işlevsiz. | Silmek geri alınamaz; rapora yazıyorum. |
| Yıllık katman dosyasında `kaynak` alanı hâlâ GADM diyor. | Dosya değişmeden paketleniyor; uygulama bu beyanı açıklıyor. |
| İhbarların incelendiği bir süreç var mı? | Bunu ben bilemem. Metin artık bir süreç iddia etmiyor. Gizlilik politikası "ihbarı incelemek" diyor; süreç yoksa o cümle de gözden geçirilmeli. |

## 4. Durum ve sınırlar

- `flutter analyze` temiz, `flutter test` **272/272**. Backend `tsc` temiz; `alert-text`, `wildfire-relevance`, `news-geography`, `nearby-fire-count`, `official-status`, `heat-source`, `firms-products`, `weather-providers`, `border-gate`, `provinces`, `tracked-places`, `location-privacy`, `fire-history`, `news-sighting` geçti.
- **Gerçek veritabanında çalıştırılmadı:** B2'nin yeni SQL'i. Sütun adları migration'dan doğrulandı; sorgu hata verirse ihbar yine kaydedilir, yalnızca eşleşme olmaz.
- **Sıralama önemli:** Uygulamadaki yeni metinler backend düzeltmesiyle birlikte anlam kazanır. Backend deploy edilmeden 1.2.0 yayımlanırsa kullanıcı "yakında tespit bulunmadı" görür, oysa gerçek karşılaştırma yapılmamıştır.
- Tek bir anlık görüntü: yaz sezonu yoğunluğu ve MODIS satırları (bu anda akışta yoktu) örneklenmedi.
- NOAA-21 ham dosyası yalnızca "Europe" bölgesi için indirildi; satır satır karşılaştırma NOAA-20 ile yapıldı.
- Uygulama cihazda çalıştırılmadı; metin ve mantık kodla, testlerle doğrulandı.

## Kaynaklar

[NASA FIRMS açık veri](https://firms.modaps.eosdis.nasa.gov/active_fire/), [Open-Meteo](https://open-meteo.com/), [MET Norway](https://api.met.no/), [Nominatim](https://nominatim.openstreetmap.org/), [Ormancılar Derneği yangın istatistikleri](https://www.ormancilardernegi.org/Yangin), [Karar: OGM 2025 verisi](https://www.karar.com/guncel-haberler/ogm-acikladi-2025te-81-bin-hektar-orman-kul-oldu-2035214), [Turkish Minute: 2021 JRC raporu](https://www.turkishminute.com/2022/11/01/largest-area-burnt-in-forest-fires-in-2021-report/), [TBMM soru önergesi (EFFIS)](https://cdn.tbmm.gov.tr/KKBSPublicFile/D28/Y3/T7/WebOnergeMetni/9399c03f-6c65-41c9-89c0-e382df74421b.pdf).
