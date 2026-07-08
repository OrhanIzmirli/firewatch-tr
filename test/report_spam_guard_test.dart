import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firewatch_tr/services/report_spam_guard.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('blocks exact same-location resubmission within cooldown', () async {
    const lat = 39.925018;
    const lng = 32.836955;

    final first = await ReportSpamGuard.instance.checkBeforeSubmit(lat, lng);
    expect(first.isBlocked, isFalse);

    await ReportSpamGuard.instance.recordReport(lat, lng);

    final second = await ReportSpamGuard.instance.checkBeforeSubmit(lat, lng);
    expect(second.isBlocked, isTrue);
    expect(second.reason, ReportBlockReason.duplicateLocation);
  });

  test('allows a report far outside the 500m radius', () async {
    const lat = 39.925018;
    const lng = 32.836955;

    await ReportSpamGuard.instance.recordReport(lat, lng);

    final far = await ReportSpamGuard.instance.checkBeforeSubmit(lat + 0.5, lng + 0.5);
    expect(far.isBlocked, isFalse);
  });

  test('enforces daily limit after 5 reports', () async {
    const baseLat = 30.0;
    const baseLng = 40.0;

    for (var i = 0; i < 5; i++) {
      final lat = baseLat + i * 2;
      final check = await ReportSpamGuard.instance.checkBeforeSubmit(lat, baseLng);
      expect(check.isBlocked, isFalse);
      await ReportSpamGuard.instance.recordReport(lat, baseLng);
    }

    final sixth = await ReportSpamGuard.instance.checkBeforeSubmit(baseLat + 20, baseLng);
    expect(sixth.isBlocked, isTrue);
    expect(sixth.reason, ReportBlockReason.dailyLimit);
  });
}
