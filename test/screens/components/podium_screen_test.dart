import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fishbowl/screens/components/podium_screen.dart';

void main() {
  Future<void> pump(WidgetTester tester, List<int> teamScores) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: PodiumWidget(teamScores: teamScores),
          ),
        ),
      ),
    );
  }

  testWidgets('shows the top 3 teams as podium blocks, ranked by score', (tester) async {
    // Team 1 = 10, Team 2 = 30, Team 3 = 20 -> ranked: Team2, Team3, Team1
    await pump(tester, [10, 30, 20]);

    expect(find.text('Team 2'), findsOneWidget);
    expect(find.text('Team 3'), findsOneWidget);
    expect(find.text('Team 1'), findsOneWidget);
    // All 3 scores appear in the podium blocks.
    expect(find.text('30'), findsOneWidget);
    expect(find.text('20'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    // No ListTiles: 3 or fewer teams never overflow into the "rest" list.
    expect(find.byType(ListTile), findsNothing);
  });

  testWidgets('lists 4th place and below as ListTiles below the podium', (tester) async {
    await pump(tester, [5, 40, 30, 20, 10]);

    // Top 3 (40, 30, 20) are podium blocks; 5 and 10 fall to the list.
    expect(find.byType(ListTile), findsNWidgets(2));
    expect(find.widgetWithText(ListTile, 'Team 1'), findsOneWidget); // score 5
    expect(find.widgetWithText(ListTile, 'Team 5'), findsOneWidget); // score 10
  });

  testWidgets('handles a single team without crashing', (tester) async {
    await pump(tester, [15]);

    expect(find.text('Team 1'), findsOneWidget);
    expect(find.text('15'), findsOneWidget);
    expect(find.byType(ListTile), findsNothing);
  });

  testWidgets('handles two teams, leaving the 3rd podium slot empty', (tester) async {
    await pump(tester, [15, 25]);

    expect(find.text('Team 1'), findsOneWidget);
    expect(find.text('Team 2'), findsOneWidget);
    expect(find.byType(ListTile), findsNothing);
  });

  testWidgets('handles tied scores without crashing', (tester) async {
    await pump(tester, [10, 10, 10]);

    expect(find.text('Team 1'), findsOneWidget);
    expect(find.text('Team 2'), findsOneWidget);
    expect(find.text('Team 3'), findsOneWidget);
  });

  testWidgets('handles an empty team list without crashing', (tester) async {
    await pump(tester, []);

    expect(find.byType(ListTile), findsNothing);
    expect(find.byType(PodiumWidget), findsOneWidget);
  });
}
