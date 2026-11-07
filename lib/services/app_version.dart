import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// "v1.2.0 (5)": the installed build, read from the platform, so the number
/// shown in Settings can never again lag behind pubspec.yaml.
String formatAppVersion(PackageInfo info) {
  final build = info.buildNumber.trim();
  return build.isEmpty ? 'v${info.version}' : 'v${info.version} ($build)';
}

final appVersionProvider = FutureProvider<String>((ref) async {
  return formatAppVersion(await PackageInfo.fromPlatform());
});
