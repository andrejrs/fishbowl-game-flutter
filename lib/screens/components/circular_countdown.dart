import 'package:flutter/material.dart';

class CircularCountdown extends StatelessWidget {
  final int secondsLeft;
  final int totalSeconds;

  // Constants for styling
  static const double _circleSize = 100;
  static const double _strokeWidth = 12;
  static const double _fontSize = 28;

  const CircularCountdown({super.key, required this.secondsLeft, required this.totalSeconds});

  @override
  Widget build(BuildContext context) {
    final progress = secondsLeft / totalSeconds;

    // Color changes: green → yellow → red
    Color progressColor;
    if (progress > 0.6) {
      progressColor = Colors.green;
    } else if (progress > 0.3) {
      progressColor = Colors.yellow;
    } else {
      progressColor = Colors.red;
    }

    return Center(
      child: SizedBox(
        width: _circleSize,
        height: _circleSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background circle
            SizedBox(
              width: _circleSize,
              height: _circleSize,
              child: CircularProgressIndicator(
                value: 1.0,
                strokeWidth: _strokeWidth,
                valueColor: AlwaysStoppedAnimation(Colors.grey.shade300),
              ),
            ),
            // Foreground progress
            SizedBox(
              width: _circleSize,
              height: _circleSize,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: _strokeWidth,
                valueColor: AlwaysStoppedAnimation(progressColor),
              ),
            ),
            // Timer text
            Text(
              '$secondsLeft s',
              style: const TextStyle(
                fontSize: _fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
