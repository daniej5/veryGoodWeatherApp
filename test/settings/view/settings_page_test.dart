// ignore_for_file: prefer_const_constructors

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mocktail/mocktail.dart';

import 'package:very_good_weather_app/settings/settings.dart';

import 'package:very_good_weather_app/weather/weather.dart';
import 'package:weather_repository/weather_repository.dart' hide Weather;

class MockWeatherCubit extends MockCubit<WeatherState> implements WeatherCubit {
}

class MockWeatherRepository extends Mock implements WeatherRepository {}

void main() {
  group('SettingsPage', () {
    late WeatherCubit weatherCubit;
    final weatherState = WeatherState(
      status: WeatherStatus.success,
      weather: Weather(
        condition: WeatherCondition.clear,
        lastUpdated: DateTime(0),
        location: 'Las Vegas',
        temperature: Temperature(value: 0),
      ),
    );

    setUp(() {
      weatherCubit = MockWeatherCubit();
      when(() => weatherCubit.state).thenReturn(weatherState);
    });

    Future<void> setupWidget(WidgetTester tester) async {
      await tester.pumpWidget(
        BlocProvider.value(
          value: weatherCubit,
          child: MaterialApp(home: SettingsPage()),
        ),
      );
    }

    testWidgets('can render', (tester) async {
      await setupWidget(tester);
      expect(find.byType(SettingsPage), findsOneWidget);
    });

    testWidgets(
      'toggles the unit temperature when switch is tapped',
      (tester) async {
        await setupWidget(tester);

        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();

        verify(() => weatherCubit.toggleUnits()).called(1);
      },
    );
  });
}
