import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firewatch_tr/l10n/app_localizations.dart';
import 'package:firewatch_tr/shared/widgets/coach_mark_overlay.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('marks the tour as seen before the overlay is shown, not after', (tester) async {
    final targetKey = GlobalKey();
    const prefsKey = 'hasSeenTestTour';

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: SizedBox(key: targetKey, width: 10, height: 10)),
      ),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(Scaffold));

    final prefsBefore = await SharedPreferences.getInstance();
    expect(prefsBefore.getBool(prefsKey), isNull);

    // Call the tour trigger but do NOT interact with it (simulates the user
    // switching tabs mid-tour, which disposes the screen before Skip/Got it
    // is ever pressed).
    await maybeShowScreenCoachMarks(
      context,
      prefsKey: prefsKey,
      steps: [
        CoachMarkStep(targetKey: targetKey, title: 'Step title', description: 'Step description'),
      ],
    );

    final prefsAfter = await SharedPreferences.getInstance();
    expect(prefsAfter.getBool(prefsKey), isTrue,
        reason: 'flag must be persisted as soon as the tour is shown, before the user finishes it');

    // A second call (simulating navigating back to the same screen) must be
    // a no-op — the tour must not be inserted again.
    await maybeShowScreenCoachMarks(
      context,
      prefsKey: prefsKey,
      steps: [
        CoachMarkStep(targetKey: targetKey, title: 'Step title', description: 'Step description'),
      ],
    );
    await tester.pump();
  });
}
