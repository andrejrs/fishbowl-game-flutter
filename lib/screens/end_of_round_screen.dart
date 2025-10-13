import 'package:flutter/material.dart';

class EndOfRoundScreen extends StatelessWidget {
  final int roundNumber;
  final List<int> teamScores;
  final VoidCallback onNextRound;

  const EndOfRoundScreen({
    super.key,
    required this.roundNumber,
    required this.teamScores,
    required this.onNextRound,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('End of Round $roundNumber')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('End of Round $roundNumber', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Text('Current Scores:', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...teamScores.asMap().entries.map((entry) => ListTile(
                  title: Text('Team ${entry.key + 1}'),
                  trailing: Text('${entry.value}', style: const TextStyle(fontWeight: FontWeight.bold)),
                )),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: onNextRound,
              child: const Text('Start Next Round'),
            ),
          ],
        ),
      ),
    );
  }
}
