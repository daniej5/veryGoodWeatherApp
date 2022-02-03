import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:very_good_weather_app/weather/models/models.dart';
import 'package:weather_repository/weather_repository.dart' hide Weather;

/// {@template theme_cubit}
/// HydratedCubit which manages the theme's main color across app sessions
/// {@endtemplate}
class ThemeCubit extends HydratedCubit<Color> {
  /// {@macro theme_cubit}
  ThemeCubit() : super(defaultColor);

  /// Defaults to light blue
  static const defaultColor = Color(0xFF2196F3);

  /// Given a weather object will update the primary theme color
  void updateTheme(Weather? weather) {
    if (weather != null) emit(weather.toColor);
  }

  @override
  Color fromJson(Map<String, dynamic> json) {
    return Color(int.parse(json['color'] as String));
  }

  @override
  Map<String, dynamic> toJson(Color state) {
    return <String, String>{'color': '${state.value}'};
  }
}

extension on Weather {
  Color get toColor {
    switch (condition) {
      case WeatherCondition.clear:
        return Colors.orangeAccent;
      case WeatherCondition.snowy:
        return Colors.lightBlueAccent;
      case WeatherCondition.cloudy:
        return Colors.blueGrey;
      case WeatherCondition.rainy:
        return Colors.indigoAccent;
      case WeatherCondition.unknown:
        return ThemeCubit.defaultColor;
    }
  }
}
