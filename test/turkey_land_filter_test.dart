import 'package:flutter_test/flutter_test.dart';
import 'package:firewatch_tr/core/utils/turkey_land_filter.dart';

/// The land filter must keep Turkish islands and border towns and drop the
/// neighbours' islands and towns that NASA's Turkey box also contains.
void main() {
  const turkish = <String, (double, double)>{
    'Gökçeada': (40.19, 25.90),
    'Bozcaada': (39.83, 26.06),
    'Cunda (Alibey)': (39.37, 26.62),
    'Marmara Adası': (40.60, 27.57),
    'Avşa': (40.50, 27.49),
    'Datça (Knidos)': (36.69, 27.37),
    'Bozburun': (36.70, 28.05),
    'Kaş': (36.20, 29.64),
    'Çeşme': (38.32, 26.30),
    'Enez': (40.72, 26.08),
    'İpsala': (40.92, 26.38),
    'Edirne': (41.68, 26.56),
    'Lalapaşa': (41.84, 26.73),
    'Kırklareli': (41.73, 27.22),
    'Yalova': (40.65, 29.27),
    'Hopa': (41.40, 41.43),
    'Iğdır': (39.92, 44.04),
    'Doğubayazıt': (39.55, 44.08),
    'Reyhanlı': (36.27, 36.57),
    'Yayladağı': (35.90, 36.06),
    'Kilis': (36.72, 37.12),
    'Akçakale': (36.71, 38.95),
    'Ceylanpınar': (36.85, 40.05),
    'Cizre': (37.33, 42.19),
    'Hakkari': (37.58, 43.74),
    // Hakkari's south-east corner dips to about 37.0°N; an older
    // "east of 44°E, south of 37.5°N is Iraq" rule dropped it, and
    // "east of 44.5°E is Iran" dropped Esendere.
    'Yüksekova south (Hakkari)': (37.30, 44.60),
    'Esendere': (37.72, 44.60),
  };
  const foreign = <String, (double, double)>{
    'Lesbos (Mytilene)': (39.10, 26.55),
    'Chios': (38.37, 26.13),
    'Samos': (37.75, 26.97),
    'Kos': (36.89, 27.29),
    'Rhodes': (36.44, 28.22),
    'Samothrace': (40.47, 25.52),
    'Limnos': (39.92, 25.25),
    'Svilengrad (BG)': (41.77, 26.20),
    'Burgas (BG)': (42.50, 27.47),
    'Orestiada west bank (GR)': (41.50, 26.30),
    // Real NASA rows from 7-8 Nov 2026 that passed the older boxes.
    'Didymoteicho side (GR)': (41.44704, 26.49238),
    'Zakho side (IQ) 1': (37.0779, 42.55581),
    'Zakho side (IQ) 2': (37.08312, 42.54362),
    'Idlib (SY)': (35.93, 36.63),
    'Afrin (SY)': (36.51, 36.87),
    'Tell Abyad (SY)': (36.60, 38.95),
    'Al-Hasakah (SY)': (36.50, 40.74),
    'Kirkuk (IQ)': (35.47, 44.39),
    'Urmia (IR)': (37.55, 45.07),
    'Batumi (GE)': (41.64, 41.64),
    'Gyumri (AM)': (40.79, 43.84),
    'Nicosia (CY)': (35.17, 33.36),
  };

  for (final e in turkish.entries) {
    test('keeps ${e.key}', () => expect(isOnTurkishLand(e.value.$1, e.value.$2), isTrue));
  }
  for (final e in foreign.entries) {
    test('drops ${e.key}', () => expect(isOnTurkishLand(e.value.$1, e.value.$2), isFalse));
  }
}
