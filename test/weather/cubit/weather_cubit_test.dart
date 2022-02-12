// ignore_for_file: prefer_const_constructors
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:very_good_weather_app/weather/weather.dart';
import 'package:weather_repository/weather_repository.dart'
    as weather_repository;

import '../../helpers/hydrated_bloc.dart';

const weatherLocation = 'London';
const weatherCondition = weather_repository.WeatherCondition.rainy;
const weatherTemperature = 9.8;

class MockWeatherRepository extends Mock
    implements weather_repository.WeatherRepository {}

class MockWeather extends Mock implements weather_repository.Weather {}

void main() {
  group('WeatherCubit', () {
    late weather_repository.Weather weather;
    late weather_repository.WeatherRepository weatherRepository;

    setUp(() {
      weather = MockWeather();
      weatherRepository = MockWeatherRepository();
      when(() => weather.condition).thenReturn(weatherCondition);
      when(() => weather.location).thenReturn(weatherLocation);
      when(() => weather.temperature).thenReturn(weatherTemperature);
      when(
        () => weatherRepository.getWeather(any()),
      ).thenAnswer((_) async => weather);
    });

    test('initial state is correct', () {
      mockHydratedStorage(() {
        final weatherCubit = WeatherCubit(weatherRepository);
        expect(weatherCubit.state, WeatherState());
      });
    });

    group('toJson/fromJson', () {
      test('work properly', () {
        mockHydratedStorage(() {
          final weatherCubit = WeatherCubit(weatherRepository);
          expect(
            weatherCubit.fromJson(weatherCubit.toJson(weatherCubit.state)),
            weatherCubit.state,
          );
        });
      });
    });

    group('addWeather', () {
      blocTest<WeatherCubit, WeatherState>(
        'emits nothing when city is null',
        build: () => mockHydratedStorage(() => WeatherCubit(weatherRepository)),
        act: (cubit) => cubit.addWeather(null),
        expect: () => <WeatherState>[],
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits nothing when city is empty',
        build: () => mockHydratedStorage(() => WeatherCubit(weatherRepository)),
        act: (cubit) => cubit.addWeather(''),
        expect: () => <WeatherState>[],
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits nothing when city is already added',
        build: () => mockHydratedStorage(() => WeatherCubit(weatherRepository)),
        seed: () => WeatherState(
          status: WeatherStatus.loaded,
          weathers: [
            Weather(
              location: weatherLocation,
              condition: weatherCondition,
              lastUpdated: DateTime(2020),
              temperature: Temperature(
                value: weatherTemperature,
              ),
            )
          ],
        ),
        act: (cubit) => cubit.addWeather(weatherLocation),
        expect: () => <WeatherState>[],
      );

      blocTest<WeatherCubit, WeatherState>(
        'calls getWeather with correct city',
        build: () => mockHydratedStorage(() => WeatherCubit(weatherRepository)),
        act: (cubit) => cubit.addWeather(weatherLocation),
        verify: (_) {
          verify(() => weatherRepository.getWeather(weatherLocation)).called(1);
        },
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits [loading, failure] when getWeather throws',
        setUp: () {
          when(
            () => weatherRepository.getWeather(any()),
          ).thenThrow(Exception('oops'));
        },
        build: () => mockHydratedStorage(() => WeatherCubit(weatherRepository)),
        act: (cubit) => cubit.addWeather(weatherLocation),
        expect: () => <WeatherState>[
          WeatherState(status: WeatherStatus.loading),
          WeatherState(status: WeatherStatus.failure),
        ],
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits [loading, success] when getWeather returns (celsius)',
        build: () => mockHydratedStorage(() => WeatherCubit(weatherRepository)),
        act: (cubit) => cubit.addWeather(weatherLocation),
        expect: () => <dynamic>[
          WeatherState(status: WeatherStatus.loading),
          isA<WeatherState>()
              .having((w) => w.status, 'status', WeatherStatus.loaded)
              .having(
                (w) => w.weathers,
                'weathers',
                isA<List<Weather>>()
                    .having((w) => w.isNotEmpty, 'isNotEmpty', isTrue)
                    .having(
                      (w) => w.first.lastUpdated,
                      'lastUpdated',
                      isNotNull,
                    )
                    .having(
                      (w) => w.first.condition,
                      'condition',
                      weatherCondition,
                    )
                    .having(
                      (w) => w.first.temperature,
                      'temperature',
                      Temperature(value: weatherTemperature),
                    )
                    .having(
                      (w) => w.first.location,
                      'location',
                      weatherLocation,
                    ),
              ),
        ],
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits [loading, success] when getWeather returns (fahrenheit)',
        build: () => mockHydratedStorage(() => WeatherCubit(weatherRepository)),
        seed: () => WeatherState(temperatureUnits: TemperatureUnits.fahrenheit),
        act: (cubit) => cubit.addWeather(weatherLocation),
        expect: () => <dynamic>[
          WeatherState(
            status: WeatherStatus.loading,
            temperatureUnits: TemperatureUnits.fahrenheit,
          ),
          isA<WeatherState>()
              .having((w) => w.status, 'status', WeatherStatus.loaded)
              .having(
                (w) => w.weathers,
                'weathers',
                isA<List<Weather>>()
                    .having((w) => w.isNotEmpty, 'isNotEmpty', isTrue)
                    .having(
                      (w) => w.first.lastUpdated,
                      'lastUpdated',
                      isNotNull,
                    )
                    .having(
                      (w) => w.first.condition,
                      'condition',
                      weatherCondition,
                    )
                    .having(
                      (w) => w.first.temperature,
                      'temperature',
                      Temperature(value: weatherTemperature.toFahrenheit()),
                    )
                    .having(
                      (w) => w.first.location,
                      'location',
                      weatherLocation,
                    ),
              ),
        ],
      );
    });

    group('refreshWeather', () {
      blocTest<WeatherCubit, WeatherState>(
        'emits nothing when status is not success',
        build: () => mockHydratedStorage(() => WeatherCubit(weatherRepository)),
        act: (cubit) => cubit.refreshWeather(),
        expect: () => <WeatherState>[],
        verify: (_) {
          verifyNever(() => weatherRepository.getWeather(any()));
        },
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits nothing when location is null',
        build: () => mockHydratedStorage(() => WeatherCubit(weatherRepository)),
        seed: () => WeatherState(status: WeatherStatus.loaded),
        act: (cubit) => cubit.refreshWeather(),
        expect: () => <WeatherState>[],
        verify: (_) {
          verifyNever(() => weatherRepository.getWeather(any()));
        },
      );

      blocTest<WeatherCubit, WeatherState>(
        'invokes getWeather with correct location',
        build: () => mockHydratedStorage(() => WeatherCubit(weatherRepository)),
        seed: () => WeatherState(
          status: WeatherStatus.loaded,
          weathers: [
            Weather(
              location: weatherLocation,
              temperature: Temperature(value: weatherTemperature),
              lastUpdated: DateTime(2020),
              condition: weatherCondition,
            ),
          ],
        ),
        act: (cubit) => cubit.refreshWeather(),
        verify: (_) {
          verify(() => weatherRepository.getWeather(weatherLocation)).called(1);
        },
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits nothing when exception is thrown',
        setUp: () {
          when(
            () => weatherRepository.getWeather(any()),
          ).thenThrow(Exception('oops'));
        },
        build: () => mockHydratedStorage(() => WeatherCubit(weatherRepository)),
        seed: () => WeatherState(
          status: WeatherStatus.loaded,
          weathers: [
            Weather(
              location: weatherLocation,
              temperature: Temperature(value: weatherTemperature),
              lastUpdated: DateTime(2020),
              condition: weatherCondition,
            ),
          ],
        ),
        act: (cubit) => cubit.refreshWeather(),
        expect: () => <WeatherState>[],
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits updated weather (celsius)',
        build: () => mockHydratedStorage(() => WeatherCubit(weatherRepository)),
        seed: () => WeatherState(
          status: WeatherStatus.loaded,
          weathers: [
            Weather(
              location: weatherLocation,
              temperature: Temperature(value: 0),
              lastUpdated: DateTime(2020),
              condition: weatherCondition,
            ),
          ],
        ),
        act: (cubit) => cubit.refreshWeather(),
        expect: () => <Matcher>[
          isA<WeatherState>()
              .having((w) => w.status, 'status', WeatherStatus.loaded)
              .having(
                (w) => w.weathers,
                'weathers',
                isA<List<Weather>>()
                    .having((w) => w.isNotEmpty, 'isNotEmpty', isTrue)
                    .having(
                      (w) => w.first.lastUpdated,
                      'lastUpdated',
                      isNotNull,
                    )
                    .having(
                      (w) => w.first.condition,
                      'condition',
                      weatherCondition,
                    )
                    .having(
                      (w) => w.first.temperature,
                      'temperature',
                      Temperature(value: weatherTemperature),
                    )
                    .having(
                      (w) => w.first.location,
                      'location',
                      weatherLocation,
                    ),
              ),
        ],
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits updated weather (fahrenheit)',
        build: () => mockHydratedStorage(() => WeatherCubit(weatherRepository)),
        seed: () => WeatherState(
          temperatureUnits: TemperatureUnits.fahrenheit,
          status: WeatherStatus.loaded,
          weathers: [
            Weather(
              location: weatherLocation,
              temperature: Temperature(value: 0),
              lastUpdated: DateTime(2020),
              condition: weatherCondition,
            ),
          ],
        ),
        act: (cubit) => cubit.refreshWeather(),
        expect: () => <Matcher>[
          isA<WeatherState>()
              .having((w) => w.status, 'status', WeatherStatus.loaded)
              .having(
                (w) => w.weathers,
                'weathers',
                isA<List<Weather>>()
                    .having((w) => w.isNotEmpty, 'isNotEmpty', isTrue)
                    .having(
                      (w) => w.first.lastUpdated,
                      'lastUpdated',
                      isNotNull,
                    )
                    .having(
                      (w) => w.first.condition,
                      'condition',
                      weatherCondition,
                    )
                    .having(
                      (w) => w.first.temperature,
                      'temperature',
                      Temperature(value: weatherTemperature.toFahrenheit()),
                    )
                    .having(
                      (w) => w.first.location,
                      'location',
                      weatherLocation,
                    ),
              ),
        ],
      );
    });

    group('toggleUnits', () {
      blocTest<WeatherCubit, WeatherState>(
        'emits updated units when status is not success',
        build: () => mockHydratedStorage(() => WeatherCubit(weatherRepository)),
        act: (cubit) => cubit.toggleUnits(),
        expect: () => <WeatherState>[
          WeatherState(temperatureUnits: TemperatureUnits.fahrenheit),
        ],
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits updated units and temperature '
        'when status is success (celsius)',
        build: () => mockHydratedStorage(() => WeatherCubit(weatherRepository)),
        seed: () => WeatherState(
          status: WeatherStatus.loaded,
          temperatureUnits: TemperatureUnits.fahrenheit,
          weathers: [
            Weather(
              location: weatherLocation,
              temperature: Temperature(value: weatherTemperature),
              lastUpdated: DateTime(2020),
              condition: weather_repository.WeatherCondition.rainy,
            ),
          ],
        ),
        act: (cubit) => cubit.toggleUnits(),
        expect: () => <WeatherState>[
          WeatherState(
            status: WeatherStatus.loaded,
            weathers: [
              Weather(
                location: weatherLocation,
                temperature: Temperature(value: weatherTemperature.toCelsius()),
                lastUpdated: DateTime(2020),
                condition: weather_repository.WeatherCondition.rainy,
              ),
            ],
          ),
        ],
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits updated units and temperature '
        'when status is success (fahrenheit)',
        build: () => mockHydratedStorage(() => WeatherCubit(weatherRepository)),
        seed: () => WeatherState(
          status: WeatherStatus.loaded,
          weathers: [
            Weather(
              location: weatherLocation,
              temperature: Temperature(value: weatherTemperature),
              lastUpdated: DateTime(2020),
              condition: weather_repository.WeatherCondition.rainy,
            ),
          ],
        ),
        act: (cubit) => cubit.toggleUnits(),
        expect: () => <WeatherState>[
          WeatherState(
            status: WeatherStatus.loaded,
            temperatureUnits: TemperatureUnits.fahrenheit,
            weathers: [
              Weather(
                location: weatherLocation,
                temperature: Temperature(
                  value: weatherTemperature.toFahrenheit(),
                ),
                lastUpdated: DateTime(2020),
                condition: weather_repository.WeatherCondition.rainy,
              ),
            ],
          ),
        ],
      );
    });

    group('removeWeather', () {
      final weatherToRemove = Weather(
        location: weatherLocation,
        temperature: Temperature(value: weatherTemperature),
        lastUpdated: DateTime(2020),
        condition: weather_repository.WeatherCondition.rainy,
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits empty state if removing the last item',
        build: () => mockHydratedStorage(() => WeatherCubit(weatherRepository)),
        seed: () => WeatherState(
          status: WeatherStatus.loaded,
          weathers: [weatherToRemove],
        ),
        act: (cubit) => cubit.removeWeather(weatherToRemove),
        expect: () => <WeatherState>[
          WeatherState(weathers: const []),
        ],
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits loaded state with removed weather',
        build: () => mockHydratedStorage(() => WeatherCubit(weatherRepository)),
        seed: () => WeatherState(
          status: WeatherStatus.loaded,
          weathers: [
            weatherToRemove,
            weatherToRemove.copyWith(location: 'Las Vegas'),
          ],
        ),
        act: (cubit) => cubit.removeWeather(weatherToRemove),
        expect: () => <WeatherState>[
          WeatherState(
            status: WeatherStatus.loaded,
            weathers: [
              weatherToRemove.copyWith(location: 'Las Vegas'),
            ],
          ),
        ],
      );
    });

    group('reloadWeatherAfterFailure', () {
      final weathers = [
        Weather(
          location: weatherLocation,
          condition: weatherCondition,
          temperature: Temperature(value: weatherTemperature),
          lastUpdated: DateTime(2020),
        ),
      ];

      blocTest<WeatherCubit, WeatherState>(
        'emits loaded state if containing weather items',
        build: () => mockHydratedStorage(() => WeatherCubit(weatherRepository)),
        seed: () => WeatherState(
          status: WeatherStatus.failure,
          weathers: weathers,
        ),
        act: (cubit) => cubit.reloadWeatherAfterFailure(),
        expect: () => <WeatherState>[
          WeatherState(
            status: WeatherStatus.loaded,
            weathers: weathers,
          ),
        ],
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits empty state if no weather items',
        build: () => mockHydratedStorage(() => WeatherCubit(weatherRepository)),
        seed: () => WeatherState(
          status: WeatherStatus.failure,
          weathers: const [],
        ),
        act: (cubit) => cubit.reloadWeatherAfterFailure(),
        expect: () => <WeatherState>[
          WeatherState(weathers: const []),
        ],
      );
    });
  });
}

extension on double {
  double toFahrenheit() => (this * 9 / 5) + 32;
  double toCelsius() => (this - 32) * 5 / 9;
}
