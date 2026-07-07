import 'package:flutter/widgets.dart';

/// Shared GlobalKeys so the first-launch coach mark tour (built and shown
/// from MainShellScreen) can find and highlight widgets that live inside
/// other screens (HomeScreen's buttons, the bottom nav icons).
class CoachMarkKeys {
  static final mapNavIcon = GlobalKey();
  static final alertsNavIcon = GlobalKey();
  static final riskButton = GlobalKey();
  static final savedButton = GlobalKey();
}
