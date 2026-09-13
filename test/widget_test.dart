import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fishbowl/main.dart';
import 'package:fishbowl/screens/setup_screen.dart';
import 'package:fishbowl/screens/team_assignment_screen.dart';
import 'package:fishbowl/screens/word_entry_screen.dart';
import 'package:fishbowl/screens/game_screen.dart';
import 'package:fishbowl/screens/results_screen.dart';

import 'test_helpers.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('launches on the Setup screen', (tester) async {
    await tester.pumpWidget(const FishbowlApp());
    await tester.pump();

    expect(find.byType(SetupScreen), findsOneWidget);
    expect(find.text('Fishbowl Setup'), findsOneWidget);
  });

  testWidgets('MaterialApp is configured with the expected title and routes', (tester) async {
    await tester.pumpWidget(const FishbowlApp());
    await tester.pump();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.title, 'Fishbowl Game');
    expect(
      app.routes?.keys,
      containsAll(['/', '/teams', '/words', '/game', '/results']),
    );
  });

  testWidgets('completing setup navigates to the Team Assignment screen', (tester) async {
    await tester.pumpWidget(const FishbowlApp());
    await tester.pump();

    Future<void> addPlayer(String name) async {
      await tester.enterText(find.widgetWithText(TextField, 'Player name'), name);
      await tester.tap(find.byIcon(Icons.check));
      await tester.pump(const Duration(milliseconds: 150));
    }

    // Defaults to 2 players; add both to enable Continue.
    await addPlayer('Alice');
    await addPlayer('Bob');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
    await tester.pumpAndSettle();

    expect(find.byType(TeamAssignmentScreen), findsOneWidget);
  });

  testWidgets(
    'playing a full game through the real app routes reaches the Results screen',
    (tester) async {
      await tester.pumpWidget(const FishbowlApp());
      await tester.pump();

      Future<void> addPlayer(String name) async {
        await tester.enterText(find.widgetWithText(TextField, 'Player name'), name);
        await tester.tap(find.byIcon(Icons.check));
        await tester.pump(const Duration(milliseconds: 150));
      }

      // Setup -> Teams (defaults: 2 teams, 2 players, 2 words/player, 60s/turn).
      await addPlayer('Alice');
      await addPlayer('Bob');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
      await tester.pumpAndSettle();
      expect(find.byType(TeamAssignmentScreen), findsOneWidget);

      // Teams -> Words.
      await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
      await tester.pumpAndSettle();
      expect(find.byType(WordEntryScreen), findsOneWidget);

      Future<void> addWord(String word) async {
        await tester.enterText(find.widgetWithText(TextField, 'Word'), word);
        await tester.tap(find.byIcon(Icons.check));
        await tester.pump(const Duration(milliseconds: 150));
      }

      // Words -> Game (2 words each for Alice, then Bob).
      await addWord('apple');
      await addWord('banana');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Next Player'));
      await tester.pump();
      await addWord('cherry');
      await addWord('date');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
      await tester.pumpAndSettle();
      expect(find.byType(GameScreen), findsOneWidget);

      // Play all 3 rounds (4 words to guess each round); the 3rd round's
      // "Start Next Round" pushes the real '/results' route.
      Future<void> playRoundAndAdvance({required bool isFinalRound}) async {
        await tester.tap(elevatedButtonWithText('Start'));
        await tester.pump();
        for (var i = 0; i < 4; i++) {
          await tester.tap(elevatedButtonWithText('Correct'));
          await tester.pump();
        }
        await tester.tap(elevatedButtonWithText('Start Next Round'));
        await (isFinalRound ? tester.pumpAndSettle() : tester.pump());
      }

      await playRoundAndAdvance(isFinalRound: false);
      await playRoundAndAdvance(isFinalRound: false);
      await playRoundAndAdvance(isFinalRound: true);

      expect(find.byType(ResultsScreen), findsOneWidget);
    },
  );
}
