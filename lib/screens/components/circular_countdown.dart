import 'package:flutter/material.dart';

class CircularCountdown extends StatelessWidget {
  final int secondsLeft;
  final int totalSeconds;

  // Constants
  static const double _circleSize = 100;
  static const double _strokeWidth = 12;
  static const double _borderWidth = 8;
  static const double _fontSize = 28;

  const CircularCountdown({
    super.key,
    required this.secondsLeft,
    required this.totalSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final progress = secondsLeft / totalSeconds;

    // Dynamic color (green → yellow → red)
    Color progressColor;
    if (progress > 0.6) {
      progressColor = Colors.green;
    } else if (progress > 0.3) {
      progressColor = Colors.yellow;
    } else {
      progressColor = Colors.red;
    }

    return Center(
      child: Container(
        // 👇 Outer visible border with shadow
        padding: const EdgeInsets.all(_borderWidth),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: _borderWidth),
          boxShadow: [
            // BoxShadow(
            //   color: Colors.black.withOpacity(0.15),
            //   blurRadius: 6,
            //   spreadRadius: 1,
            //   offset: const Offset(0, 2),
            // ),
          ],
        ),
        child: SizedBox(
          width: _circleSize,
          height: _circleSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Inner white background
              Container(
                width: _circleSize - _strokeWidth,
                height: _circleSize - _strokeWidth,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),

              // Grey background ring
              SizedBox(
                width: _circleSize,
                height: _circleSize,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: _strokeWidth,
                  valueColor: AlwaysStoppedAnimation(Colors.grey.shade300),
                ),
              ),

              // Colored progress ring
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
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
