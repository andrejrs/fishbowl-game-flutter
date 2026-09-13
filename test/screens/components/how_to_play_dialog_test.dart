import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fishbowl/screens/components/how_to_play_dialog.dart';

void main() {
  Future<void> pump(WidgetTester tester) {
    return tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => showHowToPlayDialog(context),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('opens a dialog explaining the 3 rounds', (tester) async {
    await pump(tester);

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('How to Play'), findsOneWidget);
    expect(find.textContaining('Taboo'), findsOneWidget);
    expect(find.textContaining('Charades'), findsOneWidget);
    expect(find.textContaining('One Word'), findsOneWidget);
  });

  testWidgets('closes when "Got it" is tapped', (tester) async {
    await pump(tester);

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('How to Play'), findsOneWidget);

    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();

    expect(find.text('How to Play'), findsNothing);
  });
}
