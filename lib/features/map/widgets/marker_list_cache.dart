import 'package:flutter_map/flutter_map.dart';

/// Keeps a marker list's identity stable until its inputs change.
///
/// flutter_map_marker_cluster rebuilds its whole cluster tree — every
/// marker, for every zoom level from min to max — whenever the `markers`
/// list it is given is a different object (MarkerClusterLayer
/// .didUpdateWidget compares with `!=`). The map screen used to build a
/// fresh list in every build(), so a pinch (a setState every 0.2 zoom), an
/// opacity slider tick or opening a panel re-clustered every event.
///
/// [inputs] are compared element-wise: by identity for lists (data lists
/// are replaced, never mutated in place), by `==` for everything else
/// (filters, flags).
class MarkerListCache {
  List<Object?>? _inputs;
  List<Marker>? _markers;

  /// How many times the list was actually rebuilt (for tests and profiling).
  int builds = 0;

  List<Marker> get(List<Object?> inputs, List<Marker> Function() build) {
    final cached = _markers;
    if (cached != null && _same(_inputs!, inputs)) return cached;
    _inputs = List.unmodifiable(inputs);
    builds++;
    return _markers = List.unmodifiable(build());
  }

  static bool _same(List<Object?> a, List<Object?> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      final x = a[i], y = b[i];
      if (identical(x, y)) continue;
      if (x is List || y is List) return false;
      if (x != y) return false;
    }
    return true;
  }
}
