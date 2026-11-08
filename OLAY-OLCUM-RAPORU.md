# Olay ölçüm raporu

Tarih: 8 Kasım 2026. Haritada o an görünen güçlü olayların tek tek incelemesi.

**Yöntem:** `/api/incidents?days=7` içinden güçlü olaylar (en az 2 geçiş ve 8 MW, ya da tek geçişte 15 MW). Arazi örtüsü ESA WorldCover 2021 (10 m), olayın 750 m çevresi. Haber: haber akışı (son orman yangını haberi 24 Ekim 2026). Sabit kaynak: sunucudaki `heat_source` etiketi ve görülme günü.

**Sonuç:** 25 güçlü olayın 23 tanesi tarım alanında, 1 tanesi sanayi/yapı alanında, 1 tanesi orman/doğal alanda. Hiçbirinin 7 günlük pencerede orman yangını haberi yok. Değerlendirme arazi örtüsü ve mevsime dayanır; hiçbiri sahada doğrulanmadı.

| Olay | İl | Geçiş | FRP (MW) | Görülen gün | Arazi payları (%) | Sınıf | Haber | Sabit kaynak | Değerlendirme |
|---|---|---|---|---|---|---|---|---|---|
| 13575 | Ankara | 2 | 17.04 | 2 | crop 91, grass 7, tree 2 | Tarım | Yok | Etiket yok | Anız yakma olması beklenir |
| 13652 | Kırşehir | 2 | 9.53 | 1 | crop 99, grass 1 | Tarım | Yok | Etiket yok | Anız yakma olması beklenir |
| 13683 | Yozgat | 1 | 30.54 | 1 | crop 92, grass 8 | Tarım | Yok | Etiket yok | Anız yakma olması beklenir |
| 13604 | Kırıkkale | 2 | 8.64 | 2 | crop 97, grass 3 | Tarım | Yok | Etiket yok | Anız yakma olması beklenir |
| 13692 | Çorum | 1 | 17.49 | 1 | crop 88, grass 11, bare 2 | Tarım | Yok | Etiket yok | Anız yakma olması beklenir |
| 13607 | Tekirdağ | 2 | 10.72 | 2 | crop 100 | Tarım | Yok | Etiket yok | Anız yakma olması beklenir |
| 13672 | Konya | 1 | 23.31 | 1 | crop 82, grass 18 | Tarım | Yok | Etiket yok | Anız yakma olması beklenir |
| 13639 | Aydın | 2 | 8.52 | 1 | tree 49, grass 48, shrub 3 | Orman/doğal | Yok | Etiket yok | Orman yangını olabilir; haberle doğrulanmadı |
| 7197 | Hatay | 132 | 12.02 | 35 | built 62, bare 19, water 10, tree 8 | Sanayi/yapı | Yok | Etiket yok | 35 gündür aynı noktada; sanayi kaynağı (İskenderun körfezi) |
| 13653 | Kırşehir | 1 | 25 | 1 | crop 83, grass 16 | Tarım | Yok | Etiket yok | Anız yakma olması beklenir |
| 13630 | Kırıkkale | 1 | 16.67 | 1 | crop 90, grass 10 | Tarım | Yok | Etiket yok | Anız yakma olması beklenir |
| 13574 | Aksaray | 2 | 18.97 | 1 | crop 86, grass 14 | Tarım | Yok | Etiket yok | Anız yakma olması beklenir |
| 13572 | Konya | 2 | 10.53 | 1 | crop 99 | Tarım | Yok | Etiket yok | Anız yakma olması beklenir |
| 13571 | Denizli | 1 | 18.13 | 1 | crop 83, grass 17 | Tarım | Yok | Etiket yok | Anız yakma olması beklenir |
| 13516 | Kahramanmaraş | 2 | 8.52 | 1 | crop 99, grass 1 | Tarım | Yok | Etiket yok | Anız yakma olması beklenir |
| 13394 | Çorum | 2 | 23.25 | 2 | crop 73, grass 13, tree 11, bare 3 | Tarım | Yok | Etiket yok | Anız yakma olması beklenir |
| 13433 | Çorum | 2 | 21.35 | 2 | crop 68, grass 32 | Tarım | Yok | Etiket yok | Anız yakma olması beklenir |
| 13511 | Çorum | 1 | 15.16 | 1 | crop 82, grass 10, built 5, tree 1 | Tarım | Yok | Etiket yok | Anız yakma olması beklenir |
| 13478 | Şanlıurfa | 2 | 10.87 | 2 | crop 83, grass 10, built 5, bare 1, tree 1 | Tarım | Yok | Etiket yok | Anız yakma olması beklenir |
| 13383 | Batman | 2 | 17.23 | 2 | grass 60, crop 38, bare 1, tree 1 | Tarım | Yok | Etiket yok | Anız yakma olması beklenir |
| 13462 | Nevşehir | 2 | 8.83 | 1 | crop 82, grass 15, bare 3 | Tarım | Yok | Etiket yok | Anız yakma olması beklenir |
| 13348 | Şanlıurfa | 2 | 12.8 | 2 | crop 99, grass 1 | Tarım | Yok | Etiket yok | Anız yakma olması beklenir |
| 13458 | Konya | 1 | 41.17 | 1 | crop 85, grass 12, bare 2, built 1 | Tarım | Yok | Etiket yok | Anız yakma olması beklenir |
| 13446 | Şanlıurfa | 1 | 15.3 | 1 | grass 55, crop 45 | Tarım | Yok | Etiket yok | Anız yakma olması beklenir |
| 13349 | Şanlıurfa | 2 | 16.37 | 2 | crop 85, grass 9, bare 5, built 1 | Tarım | Yok | Etiket yok | Anız yakma olması beklenir |

## Uygulanan kural

| Katman | İçerik |
|---|---|
| Olaylar (varsayılan) | Orman/doğal alanda çoklu geçişli ve güçlü tespitler, artı haberle doğrulananlar. Henüz sınıflanmamış olay kalır, çünkü başarısız bir sorgu gerçek bir yangını gizlememeli. |
| Noktalar | Diğer her şey. Tarım alanındakiler "Tarım alanında — anız yakma olabilir" etiketiyle. |
| Haberlerde doğrulandı | Tek il ve tek ilçe adı geçen orman yangını haberi, ilçe merkezi olaya en fazla 15 km, tarih tespitten en fazla bir gün uzakta. Şüphede eşleşmez. |

Sınıflama: yapı payı en az %30 ise sanayi/yapı; tarım payı en az %35 ve ağaç+çalı %35 altındaysa tarım; doğal pay en az %60 ise orman/doğal; aksi halde diğer.

Ölçümden sonra son 30 günün olayları sınıflandı. Son 7 günde: 249 tarım, 38 orman/doğal, 30 diğer, 21 sanayi/yapı.

## Haber akışı neden 14 gündür yeni haber göstermiyor

Sunucu ve önbellek bozuk değil. 8 Kasım'da 11 kaynaktan 9'u bu makineden yanıt verdi (NTV 403, İzmir Haber zaman aşımı) ve en yeni öğeler aynı güne aitti. Son orman yangını haberi 24 Ekim'de; kasımdaki yangın başlıkları bina, depo ve araç yangınları olduğu için süzgeçten geçmiyor. Hata uygulamadaydı: eski haberlere "yeni" deniyordu. Toplayıcı artık her çalışmasını `job_runs` tablosuna yazıyor.
