import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fishbowl/screens/components/circular_countdown.dart';

void main() {
  Future<void> pump(WidgetTester tester, int secondsLeft, int totalSeconds) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CircularCountdown(
            secondsLeft: secondsLeft,
            totalSeconds: totalSeconds,
          ),
        ),
      ),
    );
  }

  Color progressColorOf(WidgetTester tester) {
    final indicators = tester.widgetList<CircularProgressIndicator>(
      find.byType(CircularProgressIndicator),
    ).toList();
    // The second indicator is the colored progress ring (the first is the
    // static grey background ring, always AlwaysStoppedAnimation(grey)).
    final progressRing = indicators[1];
    return progressRing.valueColor!.value!;
  }

  testWidgets('displays the seconds left with an "s" suffix', (tester) async {
    await pump(tester, 42, 60);
    expect(find.text('42 s'), findsOneWidget);
  });

  testWidgets('is green when more than 60% of time remains', (tester) async {
    await pump(tester, 61, 100);
    expect(progressColorOf(tester), Colors.green);
  });

  testWidgets('is yellow between 30% and 60% of time remaining', (tester) async {
    await pump(tester, 45, 100);
    expect(progressColorOf(tester), Colors.yellow);
  });

  testWidgets('is red at 30% of time remaining or below', (tester) async {
    await pump(tester, 30, 100);
    expect(progressColorOf(tester), Colors.red);
  });

  testWidgets('is red when time has run out', (tester) async {
    await pump(tester, 0, 60);
    expect(progressColorOf(tester), Colors.red);
    expect(find.text('0 s'), findsOneWidget);
  });

  testWidgets('renders two progress indicators (background + progress ring)', (tester) async {
    await pump(tester, 30, 60);
    expect(find.byType(CircularProgressIndicator), findsNWidgets(2));
  });
}
