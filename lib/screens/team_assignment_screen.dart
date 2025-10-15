import 'package:flutter/material.dart';
import 'dart:math';
import 'package:fishbowl/widgets/team_row.dart';

/// Screen for randomly assigning players to teams and displaying the assignments.
class TeamAssignmentScreen extends StatelessWidget {
  /// Creates a [TeamAssignmentScreen].
  const TeamAssignmentScreen({super.key});

  /// Randomly assigns players to teams.
  ///
  /// [playerNames] is the list of all player names.
  /// [numTeams] is the number of teams to create.
  /// Returns a list of teams, each a list of player names.
  List<List<String>> _assignTeams(List<String> playerNames, int numTeams) {
    final shuffled = List<String>.from(playerNames)..shuffle(Random());
    final teams = List.generate(numTeams, (_) => <String>[]);
    for (int i = 0; i < shuffled.length; i++) {
      teams[i % numTeams].add(shuffled[i]);
    }
    return teams;
  }

  /// Builds the team assignment UI.
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final int numTeams = args['numTeams'];
    final List<String> playerNames = List<String>.from(args['playerNames']);
    final teams = _assignTeams(playerNames, numTeams);

    return Scaffold(
      backgroundColor: const Color(0xFF399EF1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF399EF1),
        foregroundColor: Colors.white,
        title: const Text('Team Assignment', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: teams.length,
                  itemBuilder: (context, i) {
                    final team = teams[i];
                    return Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Team ${i + 1}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            TeamRow(
                              players: team,
                              mainAxisAlignment: MainAxisAlignment.start,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                width: double.infinity, // dugme popunjava celu širinu
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF399EF1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16), // samo vertikalni padding
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/words', arguments: {
                      ...args,
                      'teams': teams,
                    });
                  },
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
