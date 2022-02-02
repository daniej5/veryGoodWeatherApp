import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class WeatherRobot {
  const WeatherRobot(this.tester);

  final WidgetTester tester;

  Future<void> launchApp() async {
    await tester.pumpAndSettle();
  }

  Future<void> navigateToSearchPage() async {
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
  }
}
