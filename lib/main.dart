import 'package:flutter/material.dart';

import 'screens/setup_screen.dart';
import 'screens/team_assignment_screen.dart';
import 'screens/word_entry_screen.dart';
import 'screens/game_screen.dart';
import 'screens/results_screen.dart';

void main() {
  runApp(const FishbowlApp());
}


class FishbowlApp extends StatelessWidget {
  const FishbowlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fishbowl Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SetupScreen(),
        '/teams': (context) => const TeamAssignmentScreen(),
        '/words': (context) => const WordEntryScreen(),
        '/game': (context) => const GameScreen(),
        '/results': (context) => const ResultsScreen(),
      },
    );
  }
}
