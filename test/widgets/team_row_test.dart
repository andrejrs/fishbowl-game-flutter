import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fishbowl/widgets/team_row.dart';

void main() {
  Future<void> pump(WidgetTester tester, List<String> players) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TeamRow(
            players: players,
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ),
      ),
    );
  }

  testWidgets('renders one avatar and name label per player', (tester) async {
    await pump(tester, ['Alice', 'Bob', 'Charlie']);

    expect(find.byType(CircleAvatar), findsNWidgets(3));
    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('Bob'), findsOneWidget);
    expect(find.text('Charlie'), findsOneWidget);
  });

  testWidgets('shows the uppercased first letter of each name in its avatar', (tester) async {
    await pump(tester, ['alice', 'bob']);

    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
  });

  testWidgets('renders nothing when the player list is empty', (tester) async {
    await pump(tester, []);

    expect(find.byType(CircleAvatar), findsNothing);
    expect(find.byType(Row), findsOneWidget);
  });

  testWidgets('assigns a stable, deterministic color per name', (tester) async {
    await pump(tester, ['Alice']);
    final avatar1 = tester.widget<CircleAvatar>(find.byType(CircleAvatar));

    await pump(tester, ['Alice']);
    final avatar2 = tester.widget<CircleAvatar>(find.byType(CircleAvatar));

    expect(avatar1.backgroundColor, avatar2.backgroundColor);
  });

  testWidgets('different names can map to different colors', (tester) async {
    // 'A' (code 65, %7 == 2 -> green) and 'B' (code 66, %7 == 3 -> orange)
    // are chosen so the hash-based color assignment is guaranteed to differ.
    await pump(tester, ['A', 'B']);
    final avatars = tester.widgetList<CircleAvatar>(find.byType(CircleAvatar)).toList();

    expect(avatars[0].backgroundColor, isNot(equals(avatars[1].backgroundColor)));
  });
}
