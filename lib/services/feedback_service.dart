import 'package:dio/dio.dart';

class FeedbackService {
  static const _url = 'https://firewatch-tr-backend.onrender.com/api/feedback';

  Future<void> submit({
    required int rating,
    required String category,
    required String message,
    String? email,
  }) async {
    await Dio().post(
      _url,
      data: {
        'rating': rating,
        'category': category,
        'message': message.trim(),
        'email': email?.trim().isEmpty == true ? null : email?.trim(),
        'app_version': '1.0.0',
      },
    );
  }
}
