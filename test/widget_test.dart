import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'package:firewatch_tr/main.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
  });

  testWidgets('FireWatch TR splash screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: FireWatchApp()));
    expect(find.text('FireWatch TR'), findsOneWidget);

    // Let the splash screen's navigation timer fire so no timers remain pending.
    await tester.pump(const Duration(milliseconds: 1900));
    await tester.pump();
  });
}
