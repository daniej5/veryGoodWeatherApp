// ignore_for_file: prefer_const_constructors

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mocktail/mocktail.dart';
import 'package:very_good_weather_app/search/search.dart';

import 'package:very_good_weather_app/settings/settings.dart';

import 'package:very_good_weather_app/weather/weather.dart';
import 'package:weather_repository/weather_repository.dart' hide Weather;

import '../../helpers/hydrated_bloc.dart';

class MockWeatherRepository extends Mock implements WeatherRepository {}

class MockWeatherCubit extends MockCubit<WeatherState> implements WeatherCubit {
}

void main() {
  group('WeatherPage', () {
    late WeatherRepository weatherRepository;

    setUp(() {
      weatherRepository = MockWeatherRepository();
    });

    setUpAll(() {
      registerFallbackValue(Weather.empty);
    });

    testWidgets('renders WeatherView', (tester) async {
      await mockHydratedStorage(() async {
        await tester.pumpWidget(
          RepositoryProvider.value(
            value: weatherRepository,
            child: MaterialApp(home: WeatherPage()),
          ),
        );
      });
      expect(find.byType(WeatherView), findsOneWidget);
    });
  });

  group('WeatherView', () {
    final weathers = [
      Weather(
        temperature: Temperature(value: 4.2),
        condition: WeatherCondition.unknown,
        lastUpdated: DateTime(2020),
        location: 'London',
      ),
    ];
    late WeatherCubit weatherCubit;

    setUp(() {
      weatherCubit = MockWeatherCubit();
    });

    testWidgets('renders WeatherEmpty for WeatherStatus.empty', (tester) async {
      when(() => weatherCubit.state).thenReturn(WeatherState());
      await tester.pumpWidget(
        BlocProvider.value(
          value: weatherCubit,
          child: MaterialApp(home: WeatherView()),
        ),
      );
      expect(find.byType(WeatherEmpty), findsOneWidget);
    });

    testWidgets(
      'renders empty SizedBox for WeatherStatus.failure',
      (tester) async {
        when(() => weatherCubit.state).thenReturn(
          WeatherState(
            status: WeatherStatus.failure,
            weathers: weathers,
          ),
        );

        await tester.pumpWidget(
          BlocProvider.value(
            value: weatherCubit,
            child: MaterialApp(home: WeatherView()),
          ),
        );

        expect(
          find.byKey(ValueKey('weather_failure_box')),
          findsOneWidget,
        );
      },
    );

    testWidgets('renders WeatherLoading for WeatherStatus.loading',
        (tester) async {
      when(() => weatherCubit.state).thenReturn(
        WeatherState(
          status: WeatherStatus.loading,
        ),
      );
      await tester.pumpWidget(
        BlocProvider.value(
          value: weatherCubit,
          child: MaterialApp(home: WeatherView()),
        ),
      );
      expect(find.byType(WeatherLoading), findsOneWidget);
    });

    testWidgets('renders WeatherList for WeatherStatus.loaded', (tester) async {
      when(() => weatherCubit.state).thenReturn(
        WeatherState(
          status: WeatherStatus.loaded,
          weathers: weathers,
        ),
      );
      await tester.pumpWidget(
        BlocProvider.value(
          value: weatherCubit,
          child: MaterialApp(home: WeatherView()),
        ),
      );
      expect(find.byType(WeatherList), findsOneWidget);
    });

    testWidgets('state is cached', (tester) async {
      final storage = MockStorage();
      when<dynamic>(() => storage.read('WeatherCubit')).thenReturn(
        WeatherState(
          status: WeatherStatus.loaded,
          weathers: weathers,
          temperatureUnits: TemperatureUnits.fahrenheit,
        ).toJson(),
      );
      await mockHydratedStorage(
        () async {
          await tester.pumpWidget(
            BlocProvider.value(
              value: WeatherCubit(MockWeatherRepository()),
              child: MaterialApp(home: WeatherView()),
            ),
          );
        },
        storage: storage,
      );
      expect(find.byType(WeatherList), findsOneWidget);
    });

    testWidgets(
      'triggers removeWeather on weather card dismiss',
      (tester) async {
        when(() => weatherCubit.state).thenReturn(
          WeatherState(
            status: WeatherStatus.loaded,
            weathers: weathers,
          ),
        );
        when(() => weatherCubit.removeWeather(any())).thenAnswer((_) async {});
        await tester.pumpWidget(
          BlocProvider.value(
            value: weatherCubit,
            child: MaterialApp(home: WeatherView()),
          ),
        );
        await tester.fling(
          find.text('London'),
          const Offset(-100, 0),
          1000,
        );
        await tester.pumpAndSettle();
        verify(() => weatherCubit.removeWeather(any())).called(1);
      },
    );

    testWidgets('navigates to SettingsPage when settings icon is tapped',
        (tester) async {
      when(() => weatherCubit.state).thenReturn(WeatherState());
      await tester.pumpWidget(
        BlocProvider.value(
          value: weatherCubit,
          child: MaterialApp(home: WeatherView()),
        ),
      );
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsPage), findsOneWidget);
    });

    testWidgets('navigates to SearchPage when search button is tapped',
        (tester) async {
      when(() => weatherCubit.state).thenReturn(WeatherState());
      await tester.pumpWidget(
        BlocProvider.value(
          value: weatherCubit,
          child: MaterialApp(home: WeatherView()),
        ),
      );
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(SearchPage), findsOneWidget);
    });

    testWidgets('triggers refreshWeather on pull to refresh', (tester) async {
      when(() => weatherCubit.state).thenReturn(
        WeatherState(
          status: WeatherStatus.loaded,
          weathers: weathers,
        ),
      );
      when(() => weatherCubit.refreshWeather()).thenAnswer((_) async {});
      await tester.pumpWidget(
        BlocProvider.value(
          value: weatherCubit,
          child: MaterialApp(home: WeatherView()),
        ),
      );
      await tester.fling(
        find.text('London'),
        const Offset(0, 500),
        1000,
      );
      await tester.pumpAndSettle();
      verify(() => weatherCubit.refreshWeather()).called(1);
    });

    testWidgets('triggers fetch on search pop', (tester) async {
      when(() => weatherCubit.state).thenReturn(WeatherState());
      when(() => weatherCubit.addWeather(any())).thenAnswer((_) async {});
      await tester.pumpWidget(
        BlocProvider.value(
          value: weatherCubit,
          child: MaterialApp(home: WeatherView()),
        ),
      );
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Chicago');
      await tester.tap(find.byKey(const Key('searchPage_search_iconButton')));
      await tester.pumpAndSettle();
      verify(() => weatherCubit.addWeather('Chicago')).called(1);
    });

    testWidgets('shows snack bar when status is failure',
        (WidgetTester tester) async {
      final weatherState = WeatherState(weathers: const []);

      when(() => weatherCubit.state).thenReturn(weatherState);

      whenListen(
        weatherCubit,
        Stream<WeatherState>.fromIterable(
          [
            weatherState,
            weatherState.copyWith(status: WeatherStatus.failure),
          ],
        ),
      );

      await tester.pumpWidget(
        BlocProvider.value(
          value: weatherCubit,
          child: MaterialApp(home: WeatherView()),
        ),
      );
      expect(find.byType(SnackBar), findsNothing);
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
