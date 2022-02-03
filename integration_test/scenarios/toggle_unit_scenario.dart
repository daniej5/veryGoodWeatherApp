import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../helpers/hydrated_bloc.dart';
import '../robots/robots.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late SettingsRobot settingsRobot;
  late SearchRobot searchRobot;
  late WeatherRobot weatherRobot;

  group(
    'toggle',
    () {
      testWidgets(
        'user is able to toggle the temperature unit after a search result',
        (WidgetTester tester) async {
          weatherRobot = WeatherRobot(tester);
          searchRobot = SearchRobot(tester);
          settingsRobot = SettingsRobot(tester);
          await fakeHydratedStorage(() async {
            await weatherRobot.launchApp();
            await weatherRobot.navigateToSearchPage();
            await searchRobot.enterSearchTerm('Las Vegas');
            await searchRobot.submitSearch();
            await weatherRobot.validateMetricUnit();
            await weatherRobot.navigateToSettingsPage();
            await settingsRobot.toggleUnitSwitch();
            await settingsRobot.navigateToWeatherPage();
            await weatherRobot.validateImperialUnit();
          });
        },
      );

      testWidgets(
        'user is able to toggle the temperature unit before a search result',
        (WidgetTester tester) async {
          weatherRobot = WeatherRobot(tester);
          searchRobot = SearchRobot(tester);
          settingsRobot = SettingsRobot(tester);
          await fakeHydratedStorage(() async {
            await weatherRobot.launchApp();
            await weatherRobot.navigateToSettingsPage();
            await settingsRobot.toggleUnitSwitch();
            await settingsRobot.navigateToWeatherPage();
            await weatherRobot.navigateToSearchPage();
            await searchRobot.enterSearchTerm('Las Vegas');
            await searchRobot.submitSearch();
            await weatherRobot.validateImperialUnit();
          });
        },
      );
    },
  );
}
