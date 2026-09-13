import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fishbowl/main.dart';
import 'package:fishbowl/screens/setup_screen.dart';
import 'package:fishbowl/screens/team_assignment_screen.dart';

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
}
