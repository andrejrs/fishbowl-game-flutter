import 'package:flutter/material.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final List<int> teamScores = List<int>.from(args['teamScores'] ?? []);
    final List<MapEntry<int, int>> sorted = teamScores.asMap().entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Final Scores', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ...sorted.map((entry) => ListTile(
                  title: Text('Team ${entry.key + 1}'),
                  trailing: Text('${entry.value}', style: const TextStyle(fontWeight: FontWeight.bold)),
                )),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              },
              child: const Text('Restart Game'),
            ),
          ],
        ),
      ),
    );
  }
}
