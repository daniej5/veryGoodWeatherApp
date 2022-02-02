// ignore_for_file: unnecessary_lambdas

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// import '../robots/search_robot.dart';
import '../robots/weather_robot.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // late SearchRobot searchRobot;
  late WeatherRobot weatherRobot;

  group(
    'search',
    () {
      testWidgets(
        'user is able to search for the weather by city',
        (WidgetTester tester) async {
          weatherRobot = WeatherRobot(tester);
          // searchRobot = SearchRobot(tester);

          await weatherRobot.launchApp();
          await weatherRobot.navigateToSearchPage();
        },
      );
    },
  );
}
