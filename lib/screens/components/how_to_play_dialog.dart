import 'package:flutter/material.dart';

/// Shows a dialog explaining the Fishbowl rules: team setup, word pool,
/// and the three rounds (Taboo, Charades, One Word).
Future<void> showHowToPlayDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('How to Play'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Split into teams. Every player writes down a few words or '
              'names — they all go into one shared pool used for every round.',
            ),
            const SizedBox(height: 16),
            const Text(
              'Teams take turns racing the clock to get their teammates to '
              'guess as many words as possible. The same words come back '
              'for all 3 rounds, each with a different way to give clues:',
            ),
            const SizedBox(height: 12),
            _roundLine('1', 'Taboo', "Describe the word out loud — just don't say the word itself."),
            const SizedBox(height: 8),
            _roundLine('2', 'Charades', 'Act it out silently. No talking or sounds.'),
            const SizedBox(height: 8),
            _roundLine('3', 'One Word', 'Give only a single word as a clue.'),
            const SizedBox(height: 16),
            const Text(
              'Your team scores a point for every word guessed correctly '
              "before your turn's timer runs out. Most points after all "
              '3 rounds wins!',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Got it'),
        ),
      ],
    ),
  );
}

Widget _roundLine(String number, String title, String description) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CircleAvatar(
        radius: 12,
        backgroundColor: const Color(0xFF399EF1),
        child: Text(number, style: const TextStyle(fontSize: 12, color: Colors.white)),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text.rich(
          TextSpan(
            style: const TextStyle(color: Colors.black, fontSize: 14),
            children: [
              TextSpan(text: '$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: description),
            ],
          ),
        ),
      ),
    ],
  );
}
