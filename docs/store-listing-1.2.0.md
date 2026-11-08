# Mağaza kaydı taslağı, FireWatch TR 1.2.0 (8)

Taslak. Play Console'a yüklenmedi. Çıkış kodundaki özelliklerle eşleştirildi; release'te gizli özellikler (Geçmiş yangınlar, il/ilçe risk haritası, restorasyon, haber sekmeleri) yazılmadı. Tarayıcı açıldığında mevcut mağaza metniyle karşılaştırılacak.

## Kısa açıklama (en fazla 80 karakter)

Türkiye'deki uydu ısı tespitleri, risk ve takip ettiğin yerler için bildirim.

## Tam açıklama (en fazla 4000 karakter)

FireWatch TR, NASA FIRMS uydularının Türkiye'de tespit ettiği ısı noktalarını tek haritada gösterir. Hesap gerekmez, reklam ve izleme yazılımı yoktur.

TAKİP ETTİĞİN YERLER
Evini, köyünü, yazlığını ya da bağını ekle. 5 yere kadar, 5, 10 veya 25 km yarıçapla. Yakınında yeni bir uydu ısı tespiti olduğunda bildirim al. Konum sunucuda yaklaşık 1 km hassasiyetle saklanır.

HARİTA
• Birden çok uydu geçişinde görülen olaylar ve tek tek ısı noktaları
• Her nokta için ısı gücü (FRP), NASA güven düzeyi ve tespit saati
• Yangın Hava Endeksi (Copernicus EFFIS) katmanı
• Geçmiş yıllar katmanı: 2016-2025 il bazında OGM yanan alan verileri
• Harita daha önce açtığın bölgelerde çevrimdışı da görünür

RİSK
Yedi coğrafi bölge için hava verisi ve uydu tespitlerinden yaklaşık 3 saatte bir hesaplanan risk puanı. Puan bir endekstir, yangın çıkma olasılığı değildir.

HABERLER
Türkiye'deki orman yangınlarıyla ilgili haberler, kaynağıyla birlikte. Aynı haberin kopyaları tek gösterilir.

BİLMEN GEREKENLER
Uydu bir ısı kaynağını görür, yangını doğrulamaz. Anız yakımı, sanayi tesisleri ve gaz bacaları da tespit edilebilir. Uydu günde birkaç kez geçer, bulut ve duman altını göremez ve NASA'nın işleme süresi nedeniyle tespitler birkaç saat gecikebilir. Bir yerde tespit olmaması orada yangın olmadığı anlamına gelmez.

Bu uygulama acil durum hizmeti değildir ve bildirimleri resmî kurumlara iletmez. Yangın, duman görürsen hemen 112'yi ara.

VERİ KAYNAKLARI
NASA FIRMS (VIIRS, MODIS), Copernicus EFFIS, Open-Meteo, MET Norway, Orman Genel Müdürlüğü istatistikleri. Harita ve sınır verileri © OpenStreetMap katkıcıları. FireWatch TR bu kurumlarla bağlantılı değildir.

Gizlilik politikası: https://firewatch-tr-backend.onrender.com/privacy

## Yenilikler (en fazla 500 karakter)

• Takip ettiğim yerler: 5 yere kadar yer kaydet, yakınında uydu ısı tespiti olunca bildirim al.
• Olaylar katmanı yalnız çoklu geçiş tespitlerini gösterir; güçlü ama doğrulanmamış tespitler ayrı işaretlenir.
• Her noktada tespit güveni puanı.
• Harita daha önce açılan bölgelerde çevrimdışı da görünür.
• İller gerçek sınırlarla; Türkiye dışındaki noktalar daha iyi ayıklanıyor.
• Metinler netleştirildi: ısı tespiti doğrulanmış yangın değildir.
• Tüm kartlarda 112.

## Yayından önce kontrol

- Backend PR'ı (`fix/accuracy-audit`) deploy edilmeden 1.2.0 yayımlanmamalı (`DOGRULUK-RAPORU.md`, bölüm 4).
- `RELEASE-NOTES-tr.txt` bu metnin eski hâli; "kendiliğinden yenilenir" ve "şehir adları önbellekte" maddeleri kullanıcıya fayda anlatmadığı için çıkarıldı.
