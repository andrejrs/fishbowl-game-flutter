import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fishbowl/screens/end_of_round_screen.dart';

import '../test_helpers.dart';

void main() {
  Future<void> pump(
    WidgetTester tester, {
    required int roundNumber,
    required List<int> teamScores,
    VoidCallback? onNextRound,
  }) {
    return pumpScreenWithArgs(
      tester,
      screen: EndOfRoundScreen(
        roundNumber: roundNumber,
        teamScores: teamScores,
        onNextRound: onNextRound ?? () {},
      ),
      arguments: {'numTeams': teamScores.length},
    );
  }

  testWidgets('shows the round number in the title', (tester) async {
    await pump(tester, roundNumber: 2, teamScores: [10, 20]);
    expect(find.text('End of Round 2'), findsOneWidget);
  });

  testWidgets('shows every team name and score', (tester) async {
    await pump(tester, roundNumber: 1, teamScores: [10, 25, 5]);

    expect(find.text('Team 1'), findsOneWidget);
    expect(find.text('Team 2'), findsOneWidget);
    expect(find.text('Team 3'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('25'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('handles all-zero scores without dividing by zero', (tester) async {
    await pump(tester, roundNumber: 1, teamScores: [0, 0]);

    expect(find.text('Team 1'), findsOneWidget);
    expect(find.text('Team 2'), findsOneWidget);
    // Both show as 0 with no crash from the maxScore==0 case.
    expect(find.text('0'), findsNWidgets(2));
  });

  testWidgets('uses black text for a team far behind the leader, white otherwise', (tester) async {
    // Team 2's score (10) is 10% of the leader's (100) -> below the 0.2 threshold -> black.
    await pump(tester, roundNumber: 1, teamScores: [100, 10]);

    final leaderText = tester.widget<Text>(find.text('Team 1'));
    final laggingText = tester.widget<Text>(find.text('Team 2'));

    expect(leaderText.style?.color, Colors.white);
    expect(laggingText.style?.color, Colors.black);
  });

  testWidgets('tapping "Start Next Round" invokes the onNextRound callback', (tester) async {
    var called = false;
    await pump(
      tester,
      roundNumber: 1,
      teamScores: [10, 20],
      onNextRound: () => called = true,
    );

    await tester.tap(find.widgetWithText(ElevatedButton, 'Start Next Round'));
    await tester.pump();

    expect(called, isTrue);
  });
}
