import 'dart:io';

import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../core/config/api_config.dart';

class FeedbackService {
  static const _url = '${ApiConfig.apiBaseUrl}/feedback';
  static final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    sendTimeout: const Duration(seconds: 15),
  ));

  Future<void> submit({
    required int rating,
    required String category,
    required String message,
    String? email,
  }) async {
    if (rating < 1 || rating > 5) throw ArgumentError.value(rating, 'rating');
    if (message.trim().isEmpty || message.trim().length > 4000) {
      throw ArgumentError.value(message, 'message');
    }
    final packageInfo = await PackageInfo.fromPlatform();
    await _dio.post(
      _url,
      data: {
        'rating': rating,
        'category': category,
        'message': message.trim(),
        'email': email?.trim().isEmpty == true ? null : email?.trim(),
        'app_version': '${packageInfo.version}+${packageInfo.buildNumber}',
      },
    );
  }

  /// Bug reports don't collect a star rating in the UI (it's a simplified
  /// form) — a fixed neutral value is sent since the backend requires one.
  Future<void> submitBugReport({
    required String whatHappened,
    required String whatExpected,
  }) async {
    final deviceInfo = deviceInfoSummary();
    final body = StringBuffer()
      ..writeln('What happened: ${whatHappened.trim()}')
      ..writeln('What I expected: ${whatExpected.trim()}')
      ..write('Device: $deviceInfo');
    await submit(rating: 3, category: 'bug', message: body.toString());
  }

  String deviceInfoSummary() =>
      '${Platform.operatingSystem} ${Platform.operatingSystemVersion}';
}
