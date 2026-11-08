# FireWatch TR etkileşim stratejisi

Kod yazılmadı; bu bir öneri belgesi. Kurallar: acil durum uygulamasında güven, kullanıcı sayısından önce gelir.

**Temel ilke:** İnsanı geri getiren şey "bildirim sayısı" değil, "bana ait bir yerde gerçekten bir şey olduğunda haber veriyor" hissidir. Yanlış alarm ve boş hatırlatma, bildirimin kapatılmasına yol açar; bu uygulamada bildirimin kapanması asıl değerin kaybıdır.

Emek: **S** 1 günden az, **M** 2-5 gün, **L** 1 haftadan çok. Etki, ölçülmemiş tahmindir; önce ölç (en altta).

## Öncelik sırası

| # | Fikir | Emek | Etki | Rahatsızlık riski |
|---|---|---|---|---|
| 1 | Takip edilen yer eklemeyi ilk açılışa taşı | S | Çok yüksek | Düşük |
| 2 | Sessiz saatler | S | Yüksek | Azaltır |
| 3 | Tek bildirimde topla (zaten var), yer başına sıklık ayarı | S | Yüksek | Azaltır |
| 4 | Sezon açılışı tek bildirimi | S | Yüksek | Düşük |
| 5 | Mağaza sayfası ve ekran görüntüleri | M | Yüksek | Yok |
| 6 | "Tespit sonrası ne oldu" takibi | M | Yüksek | Düşük |
| 7 | Paylaşım kartı | M | Orta | Düşük |
| 8 | Sezon özeti | M | Orta | Düşük |
| 9 | Haftalık özet (isteğe bağlı) | M | Orta | Orta |
| 10 | Ana ekran widget'ı | L | Orta-yüksek | Yok |

## Bildirim zamanlaması

- **Sessiz saatler (S).** Varsayılan 23:00-07:00 sadece *takip edilen yerin 10 km içindeki* tespitler geçsin, geri kalanı sabah özete düşsün. Bir ayar olarak kapatılabilsin.
- **Risk bildirimini seyrelt (S).** Bölge başına 6 saatlik sınır 400 km'lik bir çevreye gidiyor. Sezon dışında günde en fazla bir, yalnız puan seviye atladığında.
- **Tekrara izin verme (var).** Takip edilen yerlerde özet mekanizması var; aynı mantığı bölge uyarılarına da uygula.
- **Sessiz çalışma penceresi (S).** İlk 3 gün sadece kullanıcının eklediği yerler için bildirim gelsin; ilk izlenim güven oluşturur.
- **Yapma:** "Bir süredir uğramadınız" bildirimi, seri sayaçları, rozetler. Yangın uygulamasında oyunlaştırma yanlış duygu verir.

## Takip edilen yerler

Uygulamanın en güçlü geri dönüş nedeni bu.

- **İlk açılışta (S).** Onboarding'in son adımı: "Evin, köyün, yazlığın nerede?" Tek yer eklemek bildirim iznini de anlamlı kılar.
- **Hazır öneriler (S).** Bulunduğun il, memleket seçimi.
- **Boş rahatlatma (S).** Yerin kartında "Son 24 saatte yakında tespit yok" (uyarıyla: "bulut altını göremez").
- **Yer başına kişi (L).** Aile için aynı yeri paylaşma. Gizlilik politikası güncellemesi gerektirir.
- **Yapma:** 5 yer sınırını ücrete bağlama. Yol haritanda "güvenlik asla ücretli değil" kuralı var.

## Mevsimsel içerik

Türkiye'de yanan alanın çoğu Haziran-Eylül'de. Kışın uygulamanın işi farklıdır.

| Dönem | İçerik | Emek |
|---|---|---|
| Mayıs ortası | Tek bildirim: "Yangın sezonu başlıyor, takip ettiğin yerleri kontrol et." | S |
| Haziran-Eylül | Normal uyarılar, FWI katmanı öne çıkar | Var |
| Ekim | Sezon özeti: il bazında tespit ve OGM verisi yayımlandıkça | M |
| Kasım-Nisan | Anız ve kış yangınları, hazırlık kartları, bildirim seyrek | S |
| Yıl dönümü | Manavgat gibi olaylar için **hatırlatma yapma**; insanların acısını kancaya çevirir | — |

"Tespit sonrası ne oldu" (M): Takip edilen bir olayın geçişleri, yayılımı, haber bağlantıları tek zaman çizelgesinde. Kişiyi aynı olaya doğal olarak geri getirir. "Söndü" dememe kuralı aynen geçerli.

## Paylaşım

- **Paylaşım kartı (M).** Olay için görsel: il, ilk ve son tespit, geçiş sayısı, "doğrulanmış yangın değildir" satırı, NASA FIRMS atfı, küçük harita (OSM atfıyla).
- **Tam konum yok.** Kullanıcının kendi yeri kartta görünmesin; ihbar fotoğrafları paylaşılmasın.
- **Muhtar/köy grubu formatı (S).** WhatsApp'a düz metin + uygulama bağlantısı. Türkiye'de yangın bilgisi bu kanaldan yayılıyor.
- **Riskli olan:** Dramatik görseller ve "ACİL" başlıkları paniğe ve yanlış bilgiye yol açar. Kart soğukkanlı olmalı.

## Mağaza sayfası ve ASO

Metin taslağı: `docs/store-listing-1.2.0.md`.

**Kelimeler.** "orman yangını", "yangın haritası", "yangın takip", "yangın uyarı", "uydu", "Türkiye yangın". Başlıkta en güçlüsü olsun: *FireWatch TR: Orman Yangını Haritası*. "NASA" kelimesini ürün adına koyma; kaynak olarak açıklamada geçsin. NASA ürün onayı izlenimi vermemek gerekir.

**Yazmaması gerekenler.** "Canlı", "anlık", "erken uyarı", "yangını haber verir", "%100". Bu denetimde uygulamadan çıkardığımız iddialar mağazaya geri girmemeli. Mağaza kuralları da yanıltıcı iddiaya izin vermez.

**Ekran görüntüleri (M).** Şu sırayla, her birinde tek cümle:

1. Harita: "Türkiye'deki uydu ısı tespitleri tek haritada" (`D21_harita.png`)
2. Takip edilen yerler: "Evinin yakınında ısı tespit edilince haber al" (`67b_urla_liste.png`)
3. Olay paneli: "Kaç geçiş, ne kadar süre, ne kadar güçlü" (`D29_olay_karti_uyari_112.png`)
4. Risk: "Bölgenin bugünkü yangın hava koşulları" (`D30_risk_bolgeler.png`)
5. Geçmiş yıllar: "2016-2025 il bazında yanan alan" (`E04_gecmis_yillar_yeni_sinirlar.png`)
6. Veri kaynakları: "Her rakamın nereden geldiği açık" (`E06_veri_kaynaklari_sinirlar.png`)

Görüntüler `firewatch-test-1.2.0` klasöründe; yeni metinlerle yeniden çekilmeli. "Geçmiş yangınlar" ve haber sekmeleri release'te gizli olduğu için onları gösterme.

**Güven işaretleri.** İlk paragrafta "hesap gerekmez, reklam yok, izleme yok" (gizlilik politikasıyla tutarlı). Yorumlara yanıt düzenli olsun.

**Küçük ASO deneyleri.** Play "Mağaza kaydı deneyleri" ile kısa açıklama A/B: "takip ettiğin yerler" ile "uydu haritası" vurgusu.

## Ölçüm

Uygulamada analitik yok ve politika bunu açıkça söylüyor. Bunu bozma. Şunlar yeter:

- Play Console: kurulum, kaldırma, 1/7/30 gün tutma, mağaza dönüşümü.
- Sunucu toplamları (kişisel veri olmadan): etkin FCM belirteci, takip edilen yeri olan cihaz sayısı, bildirim gönderilen sayı.
- **Bildirim yorgunluğu göstergesi:** Haftalık "bildirimi kapatan cihaz" oranı. Bu artarsa yeni bildirim ekleme.

## İlk 30 gün önerisi

1. 1.2.0 yayını ve backend düzeltmesi.
2. Mağaza metni ve 6 ekran görüntüsü.
3. Yer eklemeyi onboarding'e taşı, sessiz saatler.
4. Mayıs'tan önce: sezon bildirimi, paylaşım kartı.
