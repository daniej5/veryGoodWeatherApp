part of 'weather_cubit.dart';

/// {@template weather_status}
/// The status of fetching the weather for a city
/// {@endtemplate}
enum WeatherStatus {
  /// The initial loaded state. No city is selected.
  initial,

  /// The state when currently fetching the weather for a city.
  loading,

  /// The weather information is displaying for the selected city.
  success,

  /// The weather information was attempted to be fetched, but the fetch failed.
  failure,
}

/// An extension which provides flag getters based on the [WeatherStatus]
extension WeatherStatusX on WeatherStatus {
  /// Returns `true` if a city's weather information is loaded.
  bool get isSuccess => this == WeatherStatus.success;
}

/// {@template weather_state}
/// The current state of the weather app. This state keeps track of the current
/// temperature units with the weather fetch status. If a city is successfully
/// loaded, the state will hold the weather information for that city.
/// {@endtemplate}
@JsonSerializable()
class WeatherState extends Equatable {
  /// {@macro weather_state}
  WeatherState({
    this.status = WeatherStatus.initial,
    this.temperatureUnits = TemperatureUnits.celsius,
    Weather? weather,
  }) : weather = weather ?? Weather.empty;

  /// Given a valid json will return a [WeatherState] object.
  factory WeatherState.fromJson(Map<String, dynamic> json) =>
      _$WeatherStateFromJson(json);

  /// {@macro weather_status}
  final WeatherStatus status;

  /// The current weather information for a certain city.
  final Weather weather;

  /// Whether the temperature is displayed imperial or metric.
  final TemperatureUnits temperatureUnits;

  /// Duplicates the current state but with selected field variations.
  WeatherState copyWith({
    WeatherStatus? status,
    TemperatureUnits? temperatureUnits,
    Weather? weather,
  }) {
    return WeatherState(
      status: status ?? this.status,
      temperatureUnits: temperatureUnits ?? this.temperatureUnits,
      weather: weather ?? this.weather,
    );
  }

  /// Converts the weather state object into json data
  Map<String, dynamic> toJson() => _$WeatherStateToJson(this);

  @override
  List<Object?> get props => [status, temperatureUnits, weather];
}
