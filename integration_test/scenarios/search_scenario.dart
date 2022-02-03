// ignore_for_file: unnecessary_lambdas

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../helpers/hydrated_bloc.dart';
import '../robots/robots.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late SearchRobot searchRobot;
  late WeatherRobot weatherRobot;

  group(
    'search',
    () {
      testWidgets(
        'user is able to search for the weather by city',
        (WidgetTester tester) async {
          weatherRobot = WeatherRobot(tester);
          searchRobot = SearchRobot(tester);
          await fakeHydratedStorage(
            () async {
              await weatherRobot.launchApp();
              await weatherRobot.navigateToSearchPage();
              await searchRobot.enterSearchTerm('Las Vegas');
              await searchRobot.submitSearch();
              await weatherRobot.validateSuccessfulResult();
            },
          );
        },
      );

      testWidgets(
        'user gets an error screen when searching for an invalid city',
        (WidgetTester tester) async {
          weatherRobot = WeatherRobot(tester);
          searchRobot = SearchRobot(tester);
          await fakeHydratedStorage(
            () async {
              await weatherRobot.launchApp();
              await weatherRobot.navigateToSearchPage();
              await searchRobot.enterSearchTerm('Invalid');
              await searchRobot.submitSearch();
              await weatherRobot.validateErrorResult();
            },
          );
        },
      );
    },
  );
}
