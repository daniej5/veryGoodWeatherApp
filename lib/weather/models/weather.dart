import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weather_repository/weather_repository.dart' hide Weather;
import 'package:weather_repository/weather_repository.dart'
    as weather_repository;

part 'weather.g.dart';

/// enumerates the temperature units between the metric and imperial system
enum TemperatureUnits {
  /// Temperature unit for the imperial system
  fahrenheit,

  /// Temperature unit for the metric system
  celsius,
}

/// An extension which provides flag getters based on the current unit
extension TemperatureUnitsX on TemperatureUnits {
  /// Returns `true` if this object is Fahrenheit
  bool get isFahrenheit => this == TemperatureUnits.fahrenheit;

  /// Returns `true` if this object is Celsius
  bool get isCelsius => this == TemperatureUnits.celsius;
}

/// {@template temperature}
/// Model which holds a temperature value.
/// {@endtemplate}
@JsonSerializable()
class Temperature extends Equatable {
  /// {@macro temperature}
  const Temperature({required this.value});

  /// Given a valid json will return a [Temperature] object.
  factory Temperature.fromJson(Map<String, dynamic> json) =>
      _$TemperatureFromJson(json);

  /// The current number value of the temperature.
  final double value;

  /// Turns this object into a json
  Map<String, dynamic> toJson() => _$TemperatureToJson(this);

  @override
  List<Object> get props => [value];
}

/// {@template weather}
/// Data model for the weather.
/// {@endtemplate}
@JsonSerializable()
class Weather extends Equatable {
  /// {@macro weather}
  const Weather({
    required this.condition,
    required this.lastUpdated,
    required this.location,
    required this.temperature,
  });

  /// Given a valid json will return a [Weather] object.
  factory Weather.fromJson(Map<String, dynamic> json) =>
      _$WeatherFromJson(json);

  /// Given a [Weather] object from the app's weather repository, will convert
  /// to a [Weather] object to be used for the weather page.
  factory Weather.fromRepository(weather_repository.Weather weather) {
    return Weather(
      condition: weather.condition,
      lastUpdated: DateTime.now(),
      location: weather.location,
      temperature: Temperature(value: weather.temperature),
    );
  }

  /// The default weather object.
  static final empty = Weather(
    condition: WeatherCondition.unknown,
    lastUpdated: DateTime(0),
    temperature: const Temperature(value: 0),
    location: '--',
  );

  /// The condition of the weather.
  final WeatherCondition condition;

  /// The timestamp of the current weather information.
  final DateTime lastUpdated;

  /// The city with this weather.
  final String location;

  /// The temperature of the current weather.
  final Temperature temperature;

  @override
  List<Object> get props => [condition, lastUpdated, location, temperature];

  /// Turns this object into a json
  Map<String, dynamic> toJson() => _$WeatherToJson(this);

  /// Will duplicate the current object with selected field variations.
  Weather copyWith({
    WeatherCondition? condition,
    DateTime? lastUpdated,
    String? location,
    Temperature? temperature,
  }) {
    return Weather(
      condition: condition ?? this.condition,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      location: location ?? this.location,
      temperature: temperature ?? this.temperature,
    );
  }
}
