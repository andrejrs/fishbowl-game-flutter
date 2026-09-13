import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fishbowl/screens/word_entry_screen.dart';

import '../test_helpers.dart';

void main() {
  Future<void> pump(
    WidgetTester tester, {
    required List<String> playerNames,
    int wordsPerPlayer = 2,
  }) {
    return pumpScreenWithArgs(
      tester,
      screen: const WordEntryScreen(),
      arguments: {
        'numTeams': 2,
        'numPlayers': playerNames.length,
        'wordsPerPlayer': wordsPerPlayer,
        'secondsPerTurn': 60,
        'playerNames': playerNames,
      },
      placeholderRoutes: const ['/game'],
    );
  }

  // Adding a word schedules a Future.delayed(100ms) to refocus the input;
  // pumping 150ms flushes it so no timer is left pending at test end.
  Future<void> addWord(WidgetTester tester, String word) async {
    await tester.enterText(find.widgetWithText(TextField, 'Word'), word);
    await tester.tap(find.byIcon(Icons.check));
    await tester.pump(const Duration(milliseconds: 150));
  }

  testWidgets('shows the first player and an empty word list initially', (tester) async {
    await pump(tester, playerNames: ['Alice', 'Bob']);

    expect(find.text('Player: Alice'), findsOneWidget);
    expect(find.text('Enter 2 words:'), findsOneWidget);
  });

  testWidgets('adds words as they are entered, up to wordsPerPlayer', (tester) async {
    await pump(tester, playerNames: ['Alice', 'Bob']);

    await addWord(tester, 'apple');
    expect(find.text('apple'), findsOneWidget);

    await addWord(tester, 'banana');
    expect(find.text('banana'), findsOneWidget);

    // Quota (2) reached: the input field disappears.
    expect(find.widgetWithText(TextField, 'Word'), findsNothing);
  });

  testWidgets('does not add a blank word', (tester) async {
    await pump(tester, playerNames: ['Alice', 'Bob']);

    await tester.enterText(find.widgetWithText(TextField, 'Word'), '   ');
    await tester.tap(find.byIcon(Icons.check));
    await tester.pump();

    expect(find.widgetWithText(TextField, 'Word'), findsOneWidget);
    final nextButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Next Player'),
    );
    expect(nextButton.onPressed, isNull);
  });

  testWidgets('rejects a duplicate word for the same player and shows an error', (tester) async {
    await pump(tester, playerNames: ['Alice', 'Bob']);

    await addWord(tester, 'apple');
    await addWord(tester, 'apple');

    expect(find.text('This word has already been entered.'), findsOneWidget);
    // Still only 1 word recorded (the field itself remains present).
    expect(find.widgetWithText(TextField, 'Word'), findsOneWidget);
  });

  testWidgets('clears the duplicate error once the field is edited', (tester) async {
    await pump(tester, playerNames: ['Alice', 'Bob']);

    await addWord(tester, 'apple');
    await addWord(tester, 'apple');
    expect(find.text('This word has already been entered.'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Word'), 'apple2');
    await tester.pump();

    expect(find.text('This word has already been entered.'), findsNothing);
  });

  testWidgets('rejects a word already used by a different player', (tester) async {
    await pump(tester, playerNames: ['Alice', 'Bob']);

    await addWord(tester, 'apple');
    await addWord(tester, 'banana');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Next Player'));
    await tester.pump();
    expect(find.text('Player: Bob'), findsOneWidget);

    await addWord(tester, 'apple'); // already used by Alice

    expect(find.text('This word has already been entered.'), findsOneWidget);
  });

  testWidgets('removing a word frees up a slot', (tester) async {
    await pump(tester, playerNames: ['Alice', 'Bob']);

    await addWord(tester, 'apple');
    await addWord(tester, 'banana');
    expect(find.widgetWithText(TextField, 'Word'), findsNothing);

    await tester.tap(find.byIcon(Icons.delete).first);
    await tester.pump();

    expect(find.widgetWithText(TextField, 'Word'), findsOneWidget);
    expect(find.text('apple'), findsNothing);
    expect(find.text('banana'), findsOneWidget);
  });

  testWidgets('Next Player button advances to the next player and resets word entry', (tester) async {
    await pump(tester, playerNames: ['Alice', 'Bob']);

    await addWord(tester, 'apple');
    await addWord(tester, 'banana');

    final nextButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Next Player'),
    );
    expect(nextButton.onPressed, isNotNull);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Next Player'));
    await tester.pump();

    expect(find.text('Player: Bob'), findsOneWidget);
    expect(find.text('apple'), findsNothing);
    expect(find.widgetWithText(TextField, 'Word'), findsOneWidget);
  });

  testWidgets('last player sees Continue instead of Next Player', (tester) async {
    await pump(tester, playerNames: ['Alice', 'Bob']);

    await addWord(tester, 'apple');
    await addWord(tester, 'banana');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Next Player'));
    await tester.pump();

    expect(find.widgetWithText(ElevatedButton, 'Continue'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Next Player'), findsNothing);
  });

  testWidgets('Continue on the last player navigates to /game with all flattened words', (tester) async {
    await pump(tester, playerNames: ['Alice', 'Bob']);

    await addWord(tester, 'apple');
    await addWord(tester, 'banana');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Next Player'));
    await tester.pump();

    await addWord(tester, 'cherry');
    await addWord(tester, 'date');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
    await tester.pumpAndSettle();

    expect(find.textContaining('placeholder:/game'), findsOneWidget);
    expect(find.textContaining('apple'), findsOneWidget);
    expect(find.textContaining('banana'), findsOneWidget);
    expect(find.textContaining('cherry'), findsOneWidget);
    expect(find.textContaining('date'), findsOneWidget);
  });
}
