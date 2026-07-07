import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/fire_point.dart';
import '../../services/fire_api_service.dart';
import '../../services/fire_mapper.dart';

/// Resolves a notification's `fire_id` (encoded as `lat_lng`) against the
/// currently live NASA FIRMS points and opens the matching fire's detail
/// screen. Falls back to the home tab if the point can no longer be found
/// (e.g. it aged out of the satellite's active window).
class FireDeepLinkScreen extends StatefulWidget {
  final String fireId;

  const FireDeepLinkScreen({super.key, required this.fireId});

  @override
  State<FireDeepLinkScreen> createState() => _FireDeepLinkScreenState();
}

class _FireDeepLinkScreenState extends State<FireDeepLinkScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolve());
  }

  Future<void> _resolve() async {
    double? targetLat;
    double? targetLng;
    final parts = widget.fireId.split('_');
    if (parts.length == 2) {
      targetLat = double.tryParse(parts[0]);
      targetLng = double.tryParse(parts[1]);
    }

    if (targetLat != null && targetLng != null) {
      try {
        final apiService = FireApiService();
        final fires = await apiService.fetchTurkeyFires();
        FirePointMatch? closest;
        for (final point in fires) {
          final dLat = point.latitude - targetLat;
          final dLng = point.longitude - targetLng;
          final distSq = dLat * dLat + dLng * dLng;
          if (closest == null || distSq < closest.distSq) {
            closest = FirePointMatch(point, distSq);
          }
        }
        // ~0.05 deg (~5km) tolerance to account for float rounding in the id.
        if (closest != null && closest.distSq < 0.05 * 0.05) {
          // Only the matched point needs a city lookup — cheap single call.
          final cityInfo = await apiService.getNearestCity(closest.point.latitude, closest.point.longitude);
          final enrichedPoint = closest.point.copyWith(
            cityName: cityInfo['city'],
            nearestRegion: cityInfo['region'],
          );
          if (!mounted) return;
          final l10n = AppLocalizations.of(context)!;
          context.go('/fire-detail', extra: convertPointToFireEvent(enrichedPoint, l10n));
          return;
        }
      } catch (_) {
        // fall through to the generic fallback below
      }
    }

    if (!mounted) return;
    context.go('/app?tab=alerts');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
  }
}

class FirePointMatch {
  final FirePoint point;
  final double distSq;
  FirePointMatch(this.point, this.distSq);
}
