// End-to-end integration test: drives the real, compiled app (not just a
// pumped widget tree) through the full game flow on a real device/platform.
//
// Run with:
//   flutter test integration_test/app_test.dart            # attached device, fast + headless
//   flutter test integration_test/app_test.dart -d <id>     # specific device (e.g. over USB)
//
// To actually watch it drive the app on-screen (like a slow-mo Selenium
// run) instead of it flashing by in a few seconds, use `flutter drive` with
// a visible pause after every step:
//   flutter drive \
//     --driver=test_driver/integration_test.dart \
//     --target=integration_test/app_test.dart \
//     -d <id> \
//     --dart-define=STEP_DELAY_MS=800
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fishbowl/main.dart' as app;

import '../test/test_helpers.dart' show elevatedButtonWithText, elevatedButtonWithIcon;

/// Real-time pause inserted after each step when running with
/// `--dart-define=STEP_DELAY_MS=<ms>` (0 by default, i.e. no slowdown).
/// Only meaningful under `flutter drive`, which renders to the real screen;
/// `flutter test` runs off-screen regardless of this delay.
const _stepDelay = Duration(milliseconds: int.fromEnvironment('STEP_DELAY_MS'));

Future<void> _pauseForViewing(WidgetTester tester) async {
  if (_stepDelay > Duration.zero) {
    await tester.pump(_stepDelay);
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Start with no saved players so SetupScreen doesn't pre-fill names left
    // over from a previous run on the same device.
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'plays a full 2-team, 3-round game end-to-end and lands on the correct final scores',
    (tester) async {
      // Note: unlike the offline widget tests in test/, this drives a real
      // device's live display, so we must NOT override the window size
      // (e.g. via a helper like useTallTestViewport) - doing so conflicts
      // with the real physical surface and breaks rendering entirely,
      // leaving the screen stuck on the "Test starting..." placeholder.
      app.main();
      await tester.pumpAndSettle();
      await _pauseForViewing(tester);

      Future<void> addPlayer(String name) async {
        await tester.enterText(find.widgetWithText(TextField, 'Player name'), name);
        await tester.tap(find.byIcon(Icons.check));
        await tester.pump(const Duration(milliseconds: 150));
        await _pauseForViewing(tester);
      }

      Future<void> addWord(String word) async {
        await tester.enterText(find.widgetWithText(TextField, 'Word'), word);
        await tester.tap(find.byIcon(Icons.check));
        await tester.pump(const Duration(milliseconds: 150));
        await _pauseForViewing(tester);
      }

      // Guesses every remaining word this turn so the round ends immediately
      // instead of the test having to wait out the real countdown timer.
      // [isFirstTurn] picks between the plain "Start" button (very first
      // turn of the game) and the "Start"-with-icon button used from the
      // 2nd turn onward.
      Future<void> playTurnToCompletion(
        String readyLabel, {
        required bool isFirstTurn,
        required int wordsInRound,
      }) async {
        expect(find.text(readyLabel), findsOneWidget);
        final startFinder =
            isFirstTurn ? elevatedButtonWithText('Start') : elevatedButtonWithIcon(Icons.play_arrow);
        await tester.tap(startFinder);
        await tester.pump();
        await _pauseForViewing(tester);

        for (var i = 0; i < wordsInRound; i++) {
          await tester.tap(elevatedButtonWithText('Correct'));
          await tester.pump();
          await _pauseForViewing(tester);
        }
      }

      // --- Setup screen: defaults are already 2 teams / 2 players / 2 words
      // per player / 60s turns, so only the player names need entering.
      expect(find.text('Fishbowl Setup'), findsOneWidget);
      await addPlayer('Alice');
      await addPlayer('Bob');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
      await tester.pumpAndSettle();
      await _pauseForViewing(tester);

      // --- Team assignment screen ---
      expect(find.text('Team Assignment'), findsOneWidget);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
      await tester.pumpAndSettle();
      await _pauseForViewing(tester);

      // --- Word entry: 2 players x 2 words = 4 words total, shared by every round ---
      expect(find.text('Player: Alice'), findsOneWidget);
      await addWord('apple');
      await addWord('banana');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Next Player'));
      await tester.pumpAndSettle();
      await _pauseForViewing(tester);

      expect(find.text('Player: Bob'), findsOneWidget);
      await addWord('cherry');
      await addWord('date');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
      await tester.pumpAndSettle();
      await _pauseForViewing(tester);

      // --- Game screen: play through all 3 rounds ---
      expect(find.text('Round 1 of 3 - Taboo'), findsOneWidget);

      // Round 1 (Taboo): Team 1 plays and guesses all 4 words -> Team 1 +4.
      await playTurnToCompletion('Team 1 are you ready?', isFirstTurn: true, wordsInRound: 4);
      expect(find.text('End of Round 1'), findsOneWidget);
      await _pauseForViewing(tester);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Start Next Round'));
      await tester.pumpAndSettle();
      await _pauseForViewing(tester);

      // Round 2 (Charades): Team 2 plays and guesses all 4 words -> Team 2 +4.
      expect(find.text('Round 2 of 3 - Charades'), findsOneWidget);
      await playTurnToCompletion('Team 2 are you ready?', isFirstTurn: false, wordsInRound: 4);
      expect(find.text('End of Round 2'), findsOneWidget);
      await _pauseForViewing(tester);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Start Next Round'));
      await tester.pumpAndSettle();
      await _pauseForViewing(tester);

      // Round 3 (One Word): Team 1 plays again -> Team 1 +4 (total 8).
      expect(find.text('Round 3 of 3 - One Word'), findsOneWidget);
      await playTurnToCompletion('Team 1 are you ready?', isFirstTurn: false, wordsInRound: 4);
      expect(find.text('End of Round 3'), findsOneWidget);
      await _pauseForViewing(tester);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Start Next Round'));
      await tester.pumpAndSettle();
      await _pauseForViewing(tester);

      // --- Results screen: Team 1 scored 8 (rounds 1 & 3), Team 2 scored 4 (round 2) ---
      expect(find.text('Final Scores'), findsOneWidget);
      expect(find.text('Team 1'), findsOneWidget);
      expect(find.text('Team 2'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      await _pauseForViewing(tester);

      // Restarting returns to a fresh Setup screen.
      await tester.tap(find.widgetWithText(ElevatedButton, 'Restart Game'));
      await tester.pumpAndSettle();
      expect(find.text('Fishbowl Setup'), findsOneWidget);
    },
  );
}
