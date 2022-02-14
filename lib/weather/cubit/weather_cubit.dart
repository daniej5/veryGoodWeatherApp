import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:very_good_weather_app/weather/models/models.dart';
import 'package:weather_repository/weather_repository.dart'
    show WeatherRepository;

part 'weather_cubit.g.dart';
part 'weather_state.dart';

/// {@template weather_cubit}
/// HydratedCubit which manages the current state for the weather page.
/// This will persist data across app sessions using storage, so be sure
/// to run this cubit inside a zone. For more details on how this is done
/// please refer to the [hydrated_bloc package documentation](https://pub.dev/documentation/hydrated_bloc/latest/).
/// {@endtemplate}
class WeatherCubit extends HydratedCubit<WeatherState> {
  /// {@macro weather_cubit}
  WeatherCubit(this._weatherRepository) : super(WeatherState());

  final WeatherRepository _weatherRepository;

  /// This method will fetch the weather given a city. It will emit a
  /// success state if a city is found, and will emit a failure state if the
  /// weather could not be fetched.
  Future<void> addWeather(String? city) async {
    if (city == null || city.isEmpty) return;

    final cityAlreadyAdded = state.weathers.indexWhere(
          (weather) => weather.location.toLowerCase() == city.toLowerCase(),
        ) !=
        -1;
    if (cityAlreadyAdded) return;

    emit(state.copyWith(status: WeatherStatus.loading));

    try {
      final weather = await fetchWeather(city);
      emit(
        state.copyWith(
          status: WeatherStatus.loaded,
          weathers: [...state.weathers, weather],
        ),
      );
    } on Exception {
      emit(state.copyWith(status: WeatherStatus.failure));
    }
  }

  /// This method is meant to update the current city's weather information.
  /// If no city selected will do nothing.
  Future<void> refreshWeather() async {
    if (state.status.isEmpty) return;
    try {
      final weathers = await Future.wait<Weather>(
        state.weathers
            .map((weather) async => fetchWeather(weather.location))
            .toList(),
      );

      emit(
        state.copyWith(
          status: WeatherStatus.loaded,
          weathers: weathers,
        ),
      );
    } on Exception {
      emit(state);
    }
  }

  /// This method toggles the current unit to be either metric or imperial.
  void toggleUnits() {
    final units = state.temperatureUnits.isFahrenheit
        ? TemperatureUnits.celsius
        : TemperatureUnits.fahrenheit;

    if (state.weathers.isEmpty) {
      emit(state.copyWith(temperatureUnits: units));
      return;
    }

    final convertedWeathers = state.weathers.map<Weather>(
      (weather) {
        final temperature = weather.temperature;
        final value = units.isCelsius
            ? temperature.value.toCelsius()
            : temperature.value.toFahrenheit();
        return weather.copyWith(temperature: Temperature(value: value));
      },
    ).toList();

    emit(
      state.copyWith(
        temperatureUnits: units,
        weathers: convertedWeathers,
      ),
    );
  }

  /// This method will remove a given weather card from the main WeatherPage
  void removeWeather(Weather weather) {
    final filteredWeathers = state.weathers
        .where(
          (w) => w.location != weather.location,
        )
        .toList();
    final status =
        filteredWeathers.isEmpty ? WeatherStatus.empty : WeatherStatus.loaded;
    emit(
      state.copyWith(
        status: status,
        weathers: filteredWeathers,
      ),
    );
  }

  /// Helper method meant to be used to fetch and reload weather.
  @visibleForTesting
  Future<Weather> fetchWeather(String city) async {
    final initialWeather = Weather.fromRepository(
      await _weatherRepository.getWeather(city),
    );
    final units = state.temperatureUnits;
    final value = units.isFahrenheit
        ? initialWeather.temperature.value.toFahrenheit()
        : initialWeather.temperature.value;
    final convertedWeather = initialWeather.copyWith(
      temperature: Temperature(value: value),
    );
    return convertedWeather;
  }

  /// Method which reloads the weather list page after a failure in adding
  ///  a weather card.
  void reloadWeatherAfterFailure() {
    final status =
        state.weathers.isEmpty ? WeatherStatus.empty : WeatherStatus.loaded;
    emit(state.copyWith(status: status));
  }

  @override
  WeatherState fromJson(Map<String, dynamic> json) =>
      WeatherState.fromJson(json);

  @override
  Map<String, dynamic> toJson(WeatherState state) => state.toJson();
}

extension on double {
  double toFahrenheit() => (this * 9 / 5) + 32;
  double toCelsius() => (this - 32) * 5 / 9;
}
