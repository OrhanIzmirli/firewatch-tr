/// Keeps thermal detections that fall on Turkish territory, by coordinate
/// boxes alone (no polygon, no network).
///
/// GET /api/thermal is NASA's raw CSV for a box that reaches into Greece,
/// Bulgaria, Syria, Iraq, Iran, Armenia, Georgia and Cyprus, so the map has
/// to drop the foreign rows itself. The old rule cut everything west of
/// 26.5°E below 41°N, which also removed Gökçeada, Bozcaada, Enez and
/// İpsala. These rules carve out the Greek islands one by one instead and
/// keep every Turkish island: Gökçeada (40.1–40.3°N, 25.6–26.1°E),
/// Bozcaada (39.8°N, 26.0°E), Cunda, the Marmara islands, the Datça and
/// Bozburun peninsulas, Meis-side Kaş.
///
/// Boxes are coarse. Known leaks that stay: Kobani (36.9°N, 38.4°E) and
/// Jarabulus sit on the Syrian side of a border this grid cannot trace,
/// and the Meriç valley west bank between Edirne and İpsala. Known losses:
/// none of the 81 province centres; see test/turkey_land_filter_test.dart.
bool isOnTurkishLand(double lat, double lng) {
  // Outer frame: Cyprus and Iraq south of it, Georgia and the Black Sea
  // north, Limnos west, Iran east.
  if (lat < 35.8 || lat > 42.15) return false;
  if (lng < 25.6 || lng > 44.85) return false;

  // Greek Aegean islands, north to south. Each box stops just short of the
  // nearest Turkish coast or island.
  if (lat >= 40.35 && lat <= 40.6 && lng < 25.8) return false; // Samothrace (Gökçeada is south of 40.3)
  if (lat >= 38.9 && lat <= 39.45 && lng < 26.56) return false; // Lesbos (Cunda's west tip is 26.56)
  if (lat >= 38.1 && lat <= 38.65 && lng < 26.22) return false; // Chios (Çeşme is 26.30)
  if (lat >= 37.6 && lat <= 37.85 && lng < 27.08) return false; // Samos (Dilek peninsula is 27.1)
  if (lat < 37.6 && lng < 27.0) return false; // Ikaria, Fourni, Patmos, Leros
  if (lat >= 36.65 && lat <= 36.92 && lng < 27.33) return false; // Kos (Datça's tip is 27.36)
  if (lat < 36.66 && lng < 28.3) return false; // Rhodes, Symi, Tilos, Nisyros (Bozburun is north of 36.66)

  // Bulgaria and the Greek side of the Meriç.
  if (lat > 42.02 && lng < 28.05) return false; // Bulgaria (Kırklareli's coast ends at 41.98)
  if (lat > 41.75 && lng < 26.62) return false; // Svilengrad side (Lalapaşa is 26.73)
  if (lat >= 41.0 && lat <= 41.75 && lng < 26.33) return false; // Evros west bank (Edirne city is 26.55)

  // Syria and Iraq south of the land border, west to east.
  if (lng > 36.6 && lng <= 38.2 && lat < 36.68) return false; // Idlib, Afrin, Azaz (Reyhanlı is 36.57°E, Kilis 36.72°N)
  if (lng > 38.2 && lng <= 40.2 && lat < 36.69) return false; // Tell Abyad, Ras al-Ayn (Akçakale is 36.71°N)
  if (lng > 40.2 && lng <= 41.3 && lat < 36.95) return false; // Al-Hasakah (Kızıltepe is 37.19°N; Qamishli at 37.03°N stays, 4 km from Nusaybin)
  if (lng > 41.3 && lat < 37.05) return false; // Iraq's north-east (Nusaybin is 37.07°N)
  if (lng > 44.0 && lat < 37.5) return false; // Iraq, Iran (Hakkari's corner)

  // Iran, Nakhchivan, Armenia, Georgia.
  if (lng > 44.5 && lat < 39.6) return false; // Iran, Nakhchivan (Gürbulak is 44.4)
  if (lng > 43.75 && lat > 40.5) return false; // Armenia (Kars' edge is 43.6)
  if (lng > 41.5 && lat > 41.55) return false; // Georgia (Sarp is 41.52°N)

  return true;
}
