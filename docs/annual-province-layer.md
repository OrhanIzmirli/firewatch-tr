# Geçmiş yıllar katmanı

Harita sekmesinde “Geçmiş yıllar” açılır; 2016–2025 arasındaki yıl seçilir.
Katman, mevcut FlutterMap içinde güncel olay/uydu işaretçilerinin altında çizilir.
Mevcut nokta filtreleri korunur. İl dolguları il genelindeki yıllık toplamları
gösterir; yangın sınırı, güncel risk veya anlık tespit değildir.

## Veri

il_yil_veri.json (kullanıcının sağladığı il-yıl özeti) değişmeden paketlenir;
içindeki kaynak beyanı korunmuştur, rakamlar bağımsız olarak resmi yayınlarla
karşılaştırılmamıştır. Beyana göre il toplamları GADM 4.1 sınırlarıyla
hesaplanmıştır.

il_sinirlari.geojson 7 Kasım 2026'da değiştirildi. Eski dosya GADM 4.1'den
geliyordu; GADM ticari kullanıma ve yeniden dağıtıma izin vermez. Yeni dosya:
geoBoundaries gbOpen TUR ADM1 (TUR-ADM1-25984515, sadeleştirilmiş sürüm),
OpenStreetMap verisinden türetilmiştir — © OpenStreetMap katkıda bulunanlar,
ODbL 1.0. Koordinatlar 6 ondalığa yuvarlandı (daha az ondalık çokgenleri
bozuyordu); plaka geoBoundaries'in shapeISO alanından (TR-01…TR-81), il adları
veritabanındaki yazımla (Hakkari, Mersin). 81 il, 55.865 köşe, iller arası
örtüşme 0 km² (eski dosyada 813 km²).

Aynı dosya backend'de il atamasının kaynağıdır (firewatch-tr-backend,
database/seed/turkey_province_borders.geojson). İki kopyanın SHA-256 değeri
iki depodaki testlerde sabitlenmiştir; biri değişirse diğeri de değişmelidir.
İller iki haneli plaka koduyla eşleştirilir; 81 il ve 2016–2025 yılları bulunur.

İl sınırları ve dört yıllık ölçü ağ bağlantısı olmadan yüklenir. Güncel
tespitlerin yenilenmesi ve CARTO altlığı bağlantı gerektirir. CARTO anahtarı
olmadan il poligonları yine görünür; altlık harita yoktur.

## Gösterim

- Renk yalnız OGM yanan orman alanına bağlıdır: log10(ha + 1) / 4.7808.
- Duraklar: #FFF7ED, #FDBA74, #F97316, #7C2D12; opaklık %80.
- Eksik veri şeffaf, gerçek sıfır açık kremdir.
- İl kartı OGM yangın sayısı, OGM hektar, uydu noktası ve EFFIS hektarını gösterir.
- Uydu noktası yangın sayısı değildir; kaynakların kapsamları farklıdır.
- Ayrı HTML/WebView veya uzak veri servisi eklenmemiştir.

## Kontrol

Testler plaka eşleşmesini, yılları, sıfır/eksik değerleri, renk değişimini,
yerel dosya yüklemesini, dar ekran detaylarını ve işaretçilerin il katmanı
üzerinde dokunulabilir kalmasını kapsar. Emülatör görsel onayı birleştirmeden
önce ayrıca tamamlanmalıdır.
