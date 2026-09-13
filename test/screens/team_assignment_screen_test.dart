import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fishbowl/screens/team_assignment_screen.dart';
import 'package:fishbowl/widgets/team_row.dart';

import '../test_helpers.dart';

void main() {
  Future<void> pump(
    WidgetTester tester, {
    required int numTeams,
    required List<String> playerNames,
  }) {
    return pumpScreenWithArgs(
      tester,
      screen: const TeamAssignmentScreen(),
      arguments: {
        'numTeams': numTeams,
        'numPlayers': playerNames.length,
        'wordsPerPlayer': 2,
        'secondsPerTurn': 60,
        'playerNames': playerNames,
      },
      placeholderRoutes: const ['/words'],
    );
  }

  testWidgets('renders exactly numTeams team cards', (tester) async {
    await pump(tester, numTeams: 3, playerNames: ['Alice', 'Bob', 'Charlie', 'Dana', 'Eve']);

    expect(find.byType(Card), findsNWidgets(3));
    expect(find.text('Team 1'), findsOneWidget);
    expect(find.text('Team 2'), findsOneWidget);
    expect(find.text('Team 3'), findsOneWidget);
  });

  testWidgets('distributes every player to exactly one team', (tester) async {
    final players = ['Alice', 'Bob', 'Charlie', 'Dana', 'Eve', 'Frank', 'Grace'];
    await pump(tester, numTeams: 3, playerNames: players);

    final teamRows = tester.widgetList<TeamRow>(find.byType(TeamRow)).toList();
    final allAssigned = teamRows.expand((row) => row.players).toList();

    expect(allAssigned.length, players.length);
    expect(allAssigned.toSet(), players.toSet());
  });

  testWidgets('balances team sizes within 1 of each other', (tester) async {
    final players = ['Alice', 'Bob', 'Charlie', 'Dana', 'Eve']; // 5 players, 2 teams -> 3/2
    await pump(tester, numTeams: 2, playerNames: players);

    final teamRows = tester.widgetList<TeamRow>(find.byType(TeamRow)).toList();
    final sizes = teamRows.map((row) => row.players.length).toList()..sort();

    expect(sizes, [2, 3]);
  });

  testWidgets('tapping Continue advances to /words carrying the assigned teams', (tester) async {
    final players = ['Alice', 'Bob', 'Charlie', 'Dana'];
    await pump(tester, numTeams: 2, playerNames: players);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
    await tester.pumpAndSettle();

    expect(find.textContaining('placeholder:/words'), findsOneWidget);
    expect(find.textContaining('teams'), findsOneWidget);
  });
}
