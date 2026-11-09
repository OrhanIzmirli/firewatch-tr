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
/// The long land borders where boxes cannot follow the line, Syria/Iraq, Iran
/// and the Meriç, use the step tables below. Each step is the southernmost
/// (westernmost, easternmost) Turkish point in that band of the bundled province
/// polygons, less 0.02° (about 2 km) of slack for the polygon's own error and
/// VIIRS positional error. A detection a few hundred metres over the line can
/// still pass; that is the tolerance, not a leak. No province centre is lost;
/// see test/turkey_land_filter_test.dart.
const double _southEdgeStartLng = 36.6;
const double _southEdgeStepLng = 0.1;
const List<double> _southEdgeLat = [36.19, 36.77, 36.75, 36.72, 36.61, 36.63, 36.64, 36.62, 36.61, 36.65, 36.69, 36.72, 36.74, 36.77, 36.80, 36.86, 36.88, 36.87, 36.84, 36.78, 36.71, 36.68, 36.68, 36.68, 36.67, 36.65, 36.64, 36.66, 36.67, 36.68, 36.70, 36.72, 36.73, 36.76, 36.80, 36.84, 36.87, 36.91, 36.99, 37.00, 37.04, 37.08, 37.08, 37.09, 37.07, 37.04, 37.04, 37.05, 37.05, 37.05, 37.08, 37.09, 37.11, 37.13, 37.16, 37.21, 37.24, 37.08, 37.09, 37.11, 37.16, 37.28, 37.30, 37.29, 37.31, 37.33, 37.28, 37.27, 37.22, 37.21, 37.19, 37.20, 37.17, 37.20, 37.29, 37.05, 36.94, 36.94, 37.03, 37.07, 37.14, 37.12, 37.24];

const double _eastEdgeStartLat = 37.0;
const double _eastEdgeStepLat = 0.1;
const List<double> _eastEdgeLng = [44.53, 44.81, 44.84, 44.83, 44.68, 44.64, 44.65, 44.66, 44.47, 44.29, 44.36, 44.43, 44.50, 44.54, 44.35, 44.35, 44.35, 44.33, 44.34, 44.25, 44.25, 44.25, 44.13, 44.38, 44.46, 44.48, 44.84];

const double _evrosStartLat = 41.0;
const double _evrosStepLat = 0.05;
const List<double> _evrosWestEdgeLng = [26.30, 26.29, 26.28, 26.28, 26.29, 26.30, 26.44, 26.60, 26.59, 26.57, 26.57, 26.56, 26.47, 26.35, 26.30];

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
  if (lat >= _evrosStartLat && lat < 41.75) { // Evros west bank
    final i = ((lat - _evrosStartLat) / _evrosStepLat).floor();
    if (lng < _evrosWestEdgeLng[i.clamp(0, _evrosWestEdgeLng.length - 1)]) return false;
  }

  // Syria and Iraq, south of the land border.
  if (lng >= _southEdgeStartLng) {
    final i = ((lng - _southEdgeStartLng) / _southEdgeStepLng).floor();
    if (lat < _southEdgeLat[i.clamp(0, _southEdgeLat.length - 1)]) return false;
  }

  // Iran, Nakhchivan, Armenia, Georgia.
  if (lat >= _eastEdgeStartLat && lat < 39.7) { // Iran, Nakhchivan
    final i = ((lat - _eastEdgeStartLat) / _eastEdgeStepLat).floor();
    if (lng > _eastEdgeLng[i.clamp(0, _eastEdgeLng.length - 1)]) return false;
  }
  if (lng > 43.75 && lat > 40.5) return false; // Armenia (Kars' edge is 43.6)
  if (lng > 41.5 && lat > 41.55) return false; // Georgia (Sarp is 41.52°N)

  return true;
}
