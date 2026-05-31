import '../models/news_item.dart';

class MockNewsData {
  static const List<NewsItem> items = [
    NewsItem(
      id: 'n1',
      title: 'Ege hattında sıcaklık ve rüzgar etkisi risk seviyesini yükseltti',
      source: 'AFAD Bülten Özeti',
      publishedAt: '15:10',
      summary:
      'Ege bölgesinde artan sıcaklık, düşük nem ve rüzgar kombinasyonu nedeniyle saha ekipleri yüksek dikkat uyarısı veriyor.',
      category: 'Risk',
      relatedRegion: 'Ege Bölgesi',
      readMinutes: 3,
      isBreaking: true,
      highlights: [
        'Rüzgar etkisi yayılım riskini artırıyor',
        'Düşük nem nedeniyle kontrol süresi uzayabilir',
        'Vatandaşların resmi duyuruları takip etmesi öneriliyor',
      ],
      paragraphs: [
        'Güncel saha değerlendirmelerine göre Ege hattında sıcaklık ve rüzgar birleşimi yangın riskini yukarı taşıyan temel etkenler arasında yer alıyor.',
        'Özellikle bitki örtüsünün yoğun olduğu alanlarda küçük çaplı kıvılcımların daha kısa sürede büyüme ihtimali bulunduğu belirtiliyor.',
        'Yetkili kurumlar, vatandaşların açık alanda ateş yakmaktan kaçınmasını ve bölgesel uyarıları düzenli biçimde takip etmesini öneriyor.',
      ],
    ),
    NewsItem(
      id: 'n2',
      title: 'Muğla çevresinde izlenen bölgelerde ekip yoğunluğu artırıldı',
      source: 'Saha Güncellemesi',
      publishedAt: '14:35',
      summary:
      'İzlenen bölgelerde olası yayılımı erkenden durdurmak için ekip ve araç sayısında takviye planı devreye alındı.',
      category: 'Operasyon',
      relatedRegion: 'Muğla',
      readMinutes: 2,
      isBreaking: false,
      highlights: [
        'Önleyici müdahale ekipleri sahada',
        'İzleme altındaki bölgeler yeniden değerlendiriliyor',
        'Yerel duyuruların dikkate alınması isteniyor',
      ],
      paragraphs: [
        'Muğla çevresindeki izleme alanlarında saha ekiplerinin yoğunluğu artırıldı ve devriye sıklığı yeniden düzenlendi.',
        'Amaç, aktif bir olay başlamadan önce riskli noktaları belirlemek ve erken müdahaleyi kolaylaştırmak.',
        'Yetkililer, vatandaşlardan yol, duman ve yönlendirme uyarılarına dikkat etmelerini istiyor.',
      ],
    ),
    NewsItem(
      id: 'n3',
      title: 'Antalya hattında kontrol altına alınan alanlarda soğutma çalışmaları sürüyor',
      source: 'Yerel Durum Özeti',
      publishedAt: '13:20',
      summary:
      'Kontrol altına alınan bölgelerde yeniden alevlenme ihtimaline karşı soğutma ve saha taraması devam ediyor.',
      category: 'Güncelleme',
      relatedRegion: 'Antalya',
      readMinutes: 2,
      isBreaking: false,
      highlights: [
        'Soğutma ekipleri bölgede kalmaya devam ediyor',
        'Yeni risk noktaları taranıyor',
        'Bölgeye giriş kısıtlamaları sürebilir',
      ],
      paragraphs: [
        'Kontrol altına alınan bölgelerde operasyonun bittiği düşünülmüyor; saha ekipleri soğutma çalışmalarını sürdürüyor.',
        'Özellikle rüzgarın yön değiştirmesi durumunda yeniden alevlenme riskine karşı hassas alanlar düzenli olarak kontrol ediliyor.',
        'Yetkili ekipler, vatandaşların bölge çevresindeki yönlendirme ve güvenlik sınırlarına uymasını istiyor.',
      ],
    ),
    NewsItem(
      id: 'n4',
      title: 'Yangın sezonunda acil çanta hazırlığına yönelik uyarılar yenilendi',
      source: 'Güvenlik Rehberi',
      publishedAt: '12:05',
      summary:
      'Uzmanlar, tahliye ihtimali bulunan bölgelerde temel ihtiyaçları içeren acil çantanın hazır tutulmasını öneriyor.',
      category: 'Güvenlik',
      relatedRegion: 'Türkiye Geneli',
      readMinutes: 4,
      isBreaking: false,
      highlights: [
        'Kimlik ve telefon öncelikli eşyalar arasında',
        'Su ve temel ilaçlar öneriliyor',
        'Tahliye planının aile bireyleriyle önceden konuşulması isteniyor',
      ],
      paragraphs: [
        'Acil durum hazırlık önerileri yeniden paylaşılırken özellikle tahliye gerektiren senaryolarda zaman kaybını azaltacak kişisel hazırlıklara dikkat çekildi.',
        'Uzmanlara göre kimlik, telefon, şarj cihazı, su ve temel kişisel ihtiyaçlar erişilebilir bir çantada hazır tutulmalı.',
        'Aile üyeleriyle ortak buluşma noktası belirlenmesi ve resmi uyarı kanallarının takip edilmesi öneriler arasında yer alıyor.',
      ],
    ),
  ];
}