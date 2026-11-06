import 'package:flutter/foundation.dart';

/// What a release build may show. Debug builds show everything so the
/// screens can still be reviewed; release builds hide any screen that would
/// otherwise run on sample data or on a backend field that does not exist
/// yet. Each data source is switched on with a --dart-define at build time.
abstract final class FeatureFlags {
  /// GeoJSON endpoint for district risk scores. Empty → sample data.
  static const districtRiskUrl = String.fromEnvironment('DISTRICT_RISK_URL');

  /// GeoJSON endpoint for past fire areas. Empty → sample records.
  static const fireHistoryUrl = String.fromEnvironment('FIRE_HISTORY_URL');

  /// Set to true once GET /api/news filters by `content_type` and returns
  /// that field (backend 7daa8ee does neither).
  static const _newsContentTypes = bool.fromEnvironment('NEWS_CONTENT_TYPES');

  /// Set to true once the burned-area backend feeds the restoration screen
  /// (it shows placeholders only until then).
  static const _restorationData = bool.fromEnvironment('RESTORATION_DATA');

  static bool get districtRiskMap => kDebugMode || districtRiskUrl.isNotEmpty;

  static bool get fireHistory => kDebugMode || fireHistoryUrl.isNotEmpty;

  static bool get restoration => kDebugMode || _restorationData;

  /// Recovery / Solidarity / Events news tabs. Without them only the fires
  /// feed is shown.
  static bool get newsContentTabs => kDebugMode || _newsContentTypes;

  /// Placeholder lines for data the backend does not send yet ("not shared
  /// yet") appear in debug only; release simply leaves them out.
  static bool get showPendingDataNotes => kDebugMode;
}
