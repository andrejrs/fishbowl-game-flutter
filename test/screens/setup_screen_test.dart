import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fishbowl/screens/setup_screen.dart';

import '../test_helpers.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pump(WidgetTester tester) async {
    useTallTestViewport(tester);
    // Force a fresh Navigator each call: pumping a structurally similar tree
    // reuses the existing Navigator's route stack instead of resetting to
    // initialRoute, which matters for the "reload after relaunch" test.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      MaterialApp(
        onGenerateRoute: (settings) {
          if (settings.name == '/') {
            return MaterialPageRoute(builder: (_) => const SetupScreen());
          }
          if (settings.name == '/teams') {
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => Scaffold(body: Text('teams:${settings.arguments}')),
            );
          }
          return null;
        },
        initialRoute: '/',
      ),
    );
    // pumpAndSettle (rather than a single pump) lets SetupScreen's async
    // SharedPreferences load in initState fully resolve before we inspect it.
    await tester.pumpAndSettle();
  }

  // Adding a player name schedules a Future.delayed(100ms) to refocus the
  // input; pumping 150ms flushes it so no timer is left pending at test end.
  Future<void> addPlayer(WidgetTester tester, String name) async {
    await tester.enterText(find.widgetWithText(TextField, 'Player name'), name);
    await tester.tap(find.byIcon(Icons.check));
    await tester.pump(const Duration(milliseconds: 150));
  }

  testWidgets('starts with the documented defaults', (tester) async {
    await pump(tester);

    // Number of teams, number of players, and words per player all default to 2.
    expect(find.widgetWithText(TextFormField, '2'), findsNWidgets(3));
    expect(find.widgetWithText(TextFormField, 'Seconds per turn'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '60'), findsOneWidget);
  });

  testWidgets('the help icon opens the How to Play dialog', (tester) async {
    await pump(tester);

    await tester.tap(find.byIcon(Icons.help_outline));
    await tester.pumpAndSettle();

    expect(find.text('How to Play'), findsOneWidget);
  });

  testWidgets('Continue is disabled until all player names are entered', (tester) async {
    await pump(tester);

    final continueButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Continue'),
    );
    expect(continueButton.onPressed, isNull);
  });

  testWidgets('adding player names up to numPlayers enables Continue', (tester) async {
    await pump(tester);

    await addPlayer(tester, 'Alice');
    await addPlayer(tester, 'Bob');

    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('Bob'), findsOneWidget);
    // Input field for a new name should be gone: 2/2 players entered.
    expect(find.widgetWithText(TextField, 'Player name'), findsNothing);

    final continueButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Continue'),
    );
    expect(continueButton.onPressed, isNotNull);
  });

  testWidgets('does not add duplicate player names', (tester) async {
    await pump(tester);

    await addPlayer(tester, 'Alice');
    await addPlayer(tester, 'Alice');

    // Only 1 player row was actually created (the 2nd "Alice" was rejected);
    // the rejected attempt just leaves its text sitting in the input field.
    expect(find.byIcon(Icons.delete), findsOneWidget);
    // The name field is still visible because only 1 of 2 players was added.
    expect(find.widgetWithText(TextField, 'Player name'), findsOneWidget);
  });

  testWidgets('does not add an empty/blank player name', (tester) async {
    await pump(tester);

    await tester.enterText(find.widgetWithText(TextField, 'Player name'), '   ');
    await tester.tap(find.byIcon(Icons.check));
    await tester.pump();

    // Nothing was added: the name field is still asking for the 1st player.
    expect(find.widgetWithText(TextField, 'Player name'), findsOneWidget);
    final continueButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Continue'),
    );
    expect(continueButton.onPressed, isNull);
  });

  testWidgets('removing a player name frees up a slot', (tester) async {
    await pump(tester);

    await addPlayer(tester, 'Alice');
    await addPlayer(tester, 'Bob');
    expect(find.widgetWithText(TextField, 'Player name'), findsNothing);

    await tester.tap(find.byIcon(Icons.delete).first);
    await tester.pump();

    expect(find.widgetWithText(TextField, 'Player name'), findsOneWidget);
  });

  testWidgets('increasing number of players adds a name slot', (tester) async {
    await pump(tester);

    await tester.enterText(find.widgetWithText(TextFormField, 'Number of players'), '3');
    await tester.pump();

    await addPlayer(tester, 'Alice');
    await addPlayer(tester, 'Bob');
    // Still need a 3rd player.
    expect(find.widgetWithText(TextField, 'Player name'), findsOneWidget);

    await addPlayer(tester, 'Charlie');

    expect(find.widgetWithText(TextField, 'Player name'), findsNothing);
    final continueButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Continue'),
    );
    expect(continueButton.onPressed, isNotNull);
  });

  testWidgets('number of players cannot go below number of teams', (tester) async {
    await pump(tester);

    await tester.enterText(find.widgetWithText(TextFormField, 'Number of teams'), '5');
    await tester.pump();
    await tester.enterText(find.widgetWithText(TextFormField, 'Number of players'), '1');
    await tester.pump();

    // numPlayers is clamped up to numTeams (5): adding just 1 name should
    // still leave the "add a name" field visible, asking for more.
    await addPlayer(tester, 'Alice');
    expect(find.widgetWithText(TextField, 'Player name'), findsOneWidget);

    await addPlayer(tester, 'Bob');
    await addPlayer(tester, 'Charlie');
    await addPlayer(tester, 'Dana');
    // Still need a 5th player.
    expect(find.widgetWithText(TextField, 'Player name'), findsOneWidget);

    await addPlayer(tester, 'Eve');
    expect(find.widgetWithText(TextField, 'Player name'), findsNothing);
  });

  testWidgets('changing words per player is reflected in the config passed onward', (tester) async {
    await pump(tester);

    await tester.enterText(find.widgetWithText(TextFormField, 'Words per player'), '7');
    await tester.pump();

    await addPlayer(tester, 'Alice');
    await addPlayer(tester, 'Bob');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
    await tester.pumpAndSettle();

    expect(find.textContaining('wordsPerPlayer: 7'), findsOneWidget);
  });

  testWidgets('words per player is clamped to the 1-20 range', (tester) async {
    await pump(tester);

    await tester.enterText(find.widgetWithText(TextFormField, 'Words per player'), '99');
    await tester.pump();

    await addPlayer(tester, 'Alice');
    await addPlayer(tester, 'Bob');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
    await tester.pumpAndSettle();

    expect(find.textContaining('wordsPerPlayer: 20'), findsOneWidget);
  });

  testWidgets('changing seconds per turn is reflected in the config passed onward', (tester) async {
    await pump(tester);

    await tester.enterText(find.widgetWithText(TextFormField, 'Seconds per turn'), '45');
    await tester.pump();

    await addPlayer(tester, 'Alice');
    await addPlayer(tester, 'Bob');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
    await tester.pumpAndSettle();

    expect(find.textContaining('secondsPerTurn: 45'), findsOneWidget);
  });

  testWidgets('seconds per turn is clamped to the 10-300 range', (tester) async {
    await pump(tester);

    await tester.enterText(find.widgetWithText(TextFormField, 'Seconds per turn'), '5');
    await tester.pump();

    await addPlayer(tester, 'Alice');
    await addPlayer(tester, 'Bob');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
    await tester.pumpAndSettle();

    expect(find.textContaining('secondsPerTurn: 10'), findsOneWidget);
  });

  testWidgets('decreasing number of players truncates already-entered names', (tester) async {
    await pump(tester);

    await tester.enterText(find.widgetWithText(TextFormField, 'Number of players'), '3');
    await tester.pump();
    await addPlayer(tester, 'Alice');
    await addPlayer(tester, 'Bob');
    await addPlayer(tester, 'Charlie');
    expect(find.byIcon(Icons.delete), findsNWidgets(3));

    await tester.enterText(find.widgetWithText(TextFormField, 'Number of players'), '2');
    await tester.pump();

    expect(find.byIcon(Icons.delete), findsNWidgets(2));
    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('Bob'), findsOneWidget);
    expect(find.text('Charlie'), findsNothing);
    final continueButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Continue'),
    );
    expect(continueButton.onPressed, isNotNull);
  });

  testWidgets('submitting the player name field (keyboard "done") adds the player', (tester) async {
    await pump(tester);

    await tester.enterText(find.widgetWithText(TextField, 'Player name'), 'Alice');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump(const Duration(milliseconds: 150));

    expect(find.text('Alice'), findsOneWidget);
    expect(find.byIcon(Icons.delete), findsOneWidget);
  });

  testWidgets('tapping Continue navigates to /teams with the entered config', (tester) async {
    await pump(tester);

    await addPlayer(tester, 'Alice');
    await addPlayer(tester, 'Bob');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
    await tester.pumpAndSettle();

    expect(find.textContaining('teams:'), findsOneWidget);
    expect(find.textContaining('Alice'), findsOneWidget);
    expect(find.textContaining('Bob'), findsOneWidget);
  });

  testWidgets('persists player names to SharedPreferences and reloads them', (tester) async {
    await pump(tester);

    await addPlayer(tester, 'Alice');
    await addPlayer(tester, 'Bob');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('playerNames'), ['Alice', 'Bob']);

    // A fresh SetupScreen should reload the saved names.
    await pump(tester);
    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('Bob'), findsOneWidget);
  });
}
