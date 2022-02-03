import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class SettingsRobot {
  const SettingsRobot(this.tester);

  final WidgetTester tester;

  Future<void> navigateToWeatherPage() async {
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
  }

  Future<void> toggleUnitSwitch() async {
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
  }
}
