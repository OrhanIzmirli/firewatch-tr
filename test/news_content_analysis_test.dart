import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:firewatch_tr/core/utils/news_content_analysis.dart';

void main() {
  group('classifyNewsRiskLevel', () {
    test('detects critical from tahliye', () {
      expect(classifyNewsRiskLevel('Muğla\'da tahliye emri verildi'), NewsRiskLevel.critical);
    });

    test('detects active from aktif yangın', () {
      expect(classifyNewsRiskLevel('Bölgede aktif yangın büyüyor'), NewsRiskLevel.active);
    });

    test('detects monitoring from kontrol altında', () {
      expect(classifyNewsRiskLevel('Yangın kontrol altında, ekipler bölgede'), NewsRiskLevel.monitoring);
    });

    test('defaults to info when nothing matches', () {
      expect(classifyNewsRiskLevel('Hava durumu bugün güneşli olacak'), NewsRiskLevel.info);
    });

    test('does not false-positive on "solunum" (contains "olu" as substring)', () {
      expect(classifyNewsRiskLevel('Solunum yolu hastalıkları hakkında bilgilendirme'), NewsRiskLevel.info);
    });
  });

  group('classifyNewsCategory', () {
    test('detects evacuation', () {
      expect(classifyNewsCategory('Köyde tahliye başladı'), NewsContentCategory.evacuation);
    });

    test('detects response from itfaiye', () {
      expect(classifyNewsCategory('İtfaiye ekipleri müdahale ediyor'), NewsContentCategory.response);
    });

    test('detects forest as fallback category', () {
      expect(classifyNewsCategory('Orman alanında duman görüldü'), NewsContentCategory.forest);
    });

    test('defaults to news', () {
      expect(classifyNewsCategory('Genel bir haber metni'), NewsContentCategory.news);
    });
  });

  group('highlightFireKeywords', () {
    const base = TextStyle(color: Colors.black);
    const highlight = TextStyle(color: Colors.orange);

    test('highlights whole-word keyword matches only', () {
      final spans = highlightFireKeywords('Orman yangını büyüyor', base, highlight);
      final highlighted = spans.where((s) => s.style == highlight).map((s) => s.text).toList();
      expect(highlighted, contains('Orman'));
    });

    test('does not highlight "sel" inside "Selçuk" (no word boundary)', () {
      final spans = highlightFireKeywords('Selçuk\'ta bugün etkinlik düzenlendi', base, highlight);
      final highlighted = spans.where((s) => s.style == highlight).map((s) => s.text).toList();
      expect(highlighted, isEmpty);
    });

    test('reconstructs the original text exactly', () {
      const title = 'İzmir\'de orman yangını ve tahliye çalışması sürüyor';
      final spans = highlightFireKeywords(title, base, highlight);
      final joined = spans.map((s) => s.text).join();
      expect(joined, title);
    });
  });
}
