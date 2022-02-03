// DISCLAIMER
// None of these tests pass :( I was having trouble getting pass app startup
// because of a StorageError being thrown.
// It seems even with the [HydratedBlocOverrides.runZoned] working in the app
// and unit tests, there is something in running integration tests that is
// causing the passed in storage inside the zone to be null on app launch.
//
// I have tried all of the following to get past this error to no avail:
//   - just run app.main() inside testWidgets for storage to be managed in
//     runtime environment, for a true e2e test experience
//   - separating app setup with app launch, then initializing storage in the
//     test environment to pass into the app launch method
//   - running the entire test execution inside a fake hydrated zone (current)
//
//   - To write the robot tests in the first place, I hardcoded a global
//     variable testMode, then for any HydratedCubits temporarily overrided the
//     storage calls that were throwing the StorageError
//     - this is not the solution at all, it just helped me see my robot tests
//       run in the first place. I reverted the setup, though, as I am not a fan
//       of global variables or making code self aware of its test executions
//
// I am looking forward to going over this with the VGV team and come up with
// the best solution to this together.

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
