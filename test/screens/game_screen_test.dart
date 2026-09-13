import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fishbowl/screens/game_screen.dart';

import '../test_helpers.dart';

void main() {
  Future<void> pump(
    WidgetTester tester, {
    required int numTeams,
    required List<List<String>> teams,
    required List<String> words,
    int secondsPerTurn = 60,
  }) {
    return pumpScreenWithArgs(
      tester,
      screen: const GameScreen(),
      arguments: {
        'numTeams': numTeams,
        'secondsPerTurn': secondsPerTurn,
        'teams': teams,
        'words': words,
      },
      placeholderRoutes: const ['/results'],
    );
  }

  testWidgets('shows round 1 and prompts team 1 to start', (tester) async {
    await pump(
      tester,
      numTeams: 2,
      teams: [
        ['Alice'],
        ['Bob'],
      ],
      words: ['apple', 'banana'],
    );

    expect(find.text('Round 1 of 3 - Taboo'), findsOneWidget);
    expect(find.text('Team 1 are you ready?'), findsOneWidget);
    expect(elevatedButtonWithText('Start'), findsOneWidget);
    expect(find.text('Words left: 2'), findsOneWidget);
  });

  testWidgets('Start begins the turn: shows a word, the Correct button and the countdown', (tester) async {
    await pump(
      tester,
      numTeams: 2,
      teams: [
        ['Alice'],
        ['Bob'],
      ],
      words: ['apple', 'banana'],
      secondsPerTurn: 60,
    );

    await tester.tap(elevatedButtonWithText('Start'));
    await tester.pump();

    expect(find.text('60 s'), findsOneWidget);
    expect(elevatedButtonWithText('Correct'), findsOneWidget);
    // One of the two words is showing as the current clue.
    expect(find.text('apple').evaluate().isNotEmpty || find.text('banana').evaluate().isNotEmpty, isTrue);

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('59 s'), findsOneWidget);

    // Guess both words so the round ends immediately and the internal
    // countdown timer is cancelled cleanly before the test ends.
    await tester.tap(elevatedButtonWithText('Correct'));
    await tester.pump();
    await tester.tap(elevatedButtonWithText('Correct'));
    await tester.pump();
  });

  testWidgets('tapping Correct twice guesses both words and ends the round immediately', (tester) async {
    await pump(
      tester,
      numTeams: 2,
      teams: [
        ['Alice'],
        ['Bob'],
      ],
      words: ['apple', 'banana'],
    );

    await tester.tap(elevatedButtonWithText('Start'));
    await tester.pump();
    expect(find.text('Words left: 2'), findsOneWidget);

    await tester.tap(elevatedButtonWithText('Correct'));
    await tester.pump();
    expect(find.text('Words left: 1'), findsOneWidget);

    await tester.tap(elevatedButtonWithText('Correct'));
    await tester.pump();

    // Last word guessed -> round ends immediately with no leftover timer.
    expect(find.text('End of Round 1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget); // team 1's score this round
  });

  testWidgets(
    'a full 3-round, 2-team game reaches the results screen with correct final scores',
    (tester) async {
      final teams = [
        ['Alice'],
        ['Bob'],
      ];
      const words = ['apple', 'banana'];

      await pump(tester, numTeams: 2, teams: teams, words: words);

      Future<void> playTurnToCompletion(String readyTeamLabel, {required bool isFirstTurn}) async {
        expect(find.text(readyTeamLabel), findsOneWidget);
        final startButtonFinder = isFirstTurn
            ? elevatedButtonWithText('Start')
            : elevatedButtonWithIcon(Icons.play_arrow);
        await tester.tap(startButtonFinder);
        await tester.pump();

        await tester.tap(elevatedButtonWithText('Correct'));
        await tester.pump();
        await tester.tap(elevatedButtonWithText('Correct'));
        await tester.pump();
      }

      // Round 1: Team 1 plays.
      await playTurnToCompletion('Team 1 are you ready?', isFirstTurn: true);
      expect(find.text('End of Round 1'), findsOneWidget);

      await tester.tap(elevatedButtonWithText('Start Next Round'));
      await tester.pump();

      // Round 2: Team 2 plays.
      await playTurnToCompletion('Team 2 are you ready?', isFirstTurn: false);
      expect(find.text('End of Round 2'), findsOneWidget);

      await tester.tap(elevatedButtonWithText('Start Next Round'));
      await tester.pump();

      // Round 3 (final): Team 1 plays again.
      await playTurnToCompletion('Team 1 are you ready?', isFirstTurn: false);
      expect(find.text('End of Round 3'), findsOneWidget);

      await tester.tap(elevatedButtonWithText('Start Next Round'));
      await tester.pumpAndSettle();

      // Team 1 scored 2 in rounds 1 and 3 (total 4); Team 2 scored 2 in round 2.
      expect(find.textContaining('placeholder:/results'), findsOneWidget);
      expect(find.textContaining('[4, 2]'), findsOneWidget);
    },
  );

  testWidgets(
    'when time runs out before all words are guessed, the turn ends and the score carries over',
    (tester) async {
      await pump(
        tester,
        numTeams: 2,
        teams: [
          ['Alice'],
          ['Bob'],
        ],
        words: ['apple', 'banana', 'cherry'],
        secondsPerTurn: 2,
      );

      await tester.tap(elevatedButtonWithText('Start'));
      await tester.pump();

      await tester.tap(elevatedButtonWithText('Correct'));
      await tester.pump();
      expect(find.text('Words left: 2'), findsOneWidget);

      // Let the 2-second timer run out without guessing the rest.
      await tester.pump(const Duration(seconds: 2));
      // Flush the 500ms Future.delayed inside _endTurn that advances state.
      await tester.pump(const Duration(milliseconds: 500));

      // Round isn't over (2 words remain) -> team 2 is now up, not end-of-round.
      expect(find.text('End of Round 1'), findsNothing);
      expect(find.text('Team 2 are you ready?'), findsOneWidget);
      expect(elevatedButtonWithIcon(Icons.play_arrow), findsOneWidget);
      expect(find.text('Words left: 2'), findsOneWidget);
    },
  );
}
