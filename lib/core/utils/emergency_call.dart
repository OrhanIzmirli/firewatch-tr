import 'package:url_launcher/url_launcher.dart';

/// The general emergency number in Türkiye (fire, ambulance, police).
const String emergencyNumber = '112';

/// `tel:` URI for [number]. Opens the dialer with the number filled in; it
/// never places the call by itself.
Uri dialUri([String number = emergencyNumber]) => Uri(scheme: 'tel', path: number);

/// Opens the phone's dialer on [number].
///
/// Deliberately does not ask `canLaunchUrl` first: on Android 11+ that
/// answers false unless the manifest declares a `tel` `<queries>` entry, and
/// a 112 button that silently does nothing is the worst possible failure.
/// Launching directly and reporting the result is both simpler and safer.
Future<bool> openDialer([
  String number = emergencyNumber,
  Future<bool> Function(Uri uri, {LaunchMode mode})? launcher,
]) async {
  final launch = launcher ?? ((Uri uri, {LaunchMode mode = LaunchMode.platformDefault}) => launchUrl(uri, mode: mode));
  try {
    return await launch(dialUri(number), mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}
