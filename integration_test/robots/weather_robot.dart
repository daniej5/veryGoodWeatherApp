import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:very_good_weather_app/main.dart';
import 'package:very_good_weather_app/weather/weather.dart';

class WeatherRobot {
  const WeatherRobot(this.tester);

  final WidgetTester tester;

  Future<void> launchApp() async {
    await tester.pumpWidget(getWeatherApp());
    await tester.pumpAndSettle();
  }

  Future<void> navigateToSearchPage() async {
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
  }

  Future<void> navigateToSettingsPage() async {
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
  }

  Future<void> validateSuccessfulResult() async {
    expect(find.byType(WeatherList), findsOneWidget);
  }

  Future<void> validateErrorResult() async {
    expect(find.byType(SnackBar), findsOneWidget);
  }

  Future<void> validateMetricUnit() async {
    expect(find.textContaining('°C'), findsOneWidget);
  }

  Future<void> validateImperialUnit() async {
    expect(find.textContaining('°F'), findsOneWidget);
  }

  Future<void> validatePullToRefresh() async {
    final beforeRefreshFinder = find.textContaining('Last Updated at');
    await tester.pump(const Duration(minutes: 1));
    await tester.fling(
      beforeRefreshFinder,
      const Offset(0, 500),
      1000,
    );
    await tester.pumpAndSettle();

    final afterRefreshFinder = find.textContaining('Last Updated at');

    final beforeRefreshTime =
        beforeRefreshFinder.evaluate().single.widget as Text;
    final afterRefreshTime =
        afterRefreshFinder.evaluate().single.widget as Text;

    expect(afterRefreshTime, isNot(beforeRefreshTime));
  }
}
