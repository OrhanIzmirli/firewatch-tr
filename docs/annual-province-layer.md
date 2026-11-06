# Geçmiş yıllar katmanı

Harita sekmesinde “Geçmiş yıllar” açılır; 2016–2025 arasındaki yıl seçilir.
Katman, mevcut FlutterMap içinde güncel olay/uydu işaretçilerinin altında çizilir.
Mevcut nokta filtreleri korunur. İl dolguları il genelindeki yıllık toplamları
gösterir; yangın sınırı, güncel risk veya anlık tespit değildir.

## Veri

Kullanıcının sağladığı il_sinirlari.geojson ve il_yil_veri.json değişmeden
assets/data altında paketlenir. İller iki haneli plaka koduyla eşleştirilir.
81 il ve 2016–2025 yılları bulunur. Dosyalardaki kaynak beyanları korunmuştur;
rakamlar bağımsız olarak resmi yayınlarla karşılaştırılmamıştır.

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
