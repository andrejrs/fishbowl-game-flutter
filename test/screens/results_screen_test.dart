import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fishbowl/screens/results_screen.dart';
import 'package:fishbowl/screens/components/podium_screen.dart';

import '../test_helpers.dart';

void main() {
  Future<void> pump(WidgetTester tester, List<int> teamScores) {
    return pumpScreenWithArgs(
      tester,
      screen: const ResultsScreen(),
      arguments: {'teamScores': teamScores},
      placeholderRoutes: const ['/'],
    );
  }

  testWidgets('shows the Final Scores heading and a podium', (tester) async {
    await pump(tester, [10, 30, 20]);

    expect(find.text('Final Scores'), findsOneWidget);
    expect(find.byType(PodiumWidget), findsOneWidget);
  });

  testWidgets('passes team scores through to the podium unsorted', (tester) async {
    await pump(tester, [10, 30, 20]);

    final podium = tester.widget<PodiumWidget>(find.byType(PodiumWidget));
    expect(podium.teamScores, [10, 30, 20]);
  });

  testWidgets('handles a missing teamScores argument gracefully', (tester) async {
    await pumpScreenWithArgs(
      tester,
      screen: const ResultsScreen(),
      arguments: const {},
      placeholderRoutes: const ['/'],
    );

    expect(find.text('Final Scores'), findsOneWidget);
    final podium = tester.widget<PodiumWidget>(find.byType(PodiumWidget));
    expect(podium.teamScores, isEmpty);
  });

  testWidgets('tapping Restart Game navigates back to the initial route', (tester) async {
    await pump(tester, [10, 30, 20]);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Restart Game'));
    await tester.pumpAndSettle();

    expect(find.textContaining('placeholder:/'), findsOneWidget);
    expect(find.byType(ResultsScreen), findsNothing);
  });
}
