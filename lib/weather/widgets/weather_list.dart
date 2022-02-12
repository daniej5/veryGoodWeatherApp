import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:very_good_weather_app/weather/weather.dart';

class WeatherList extends StatelessWidget {
  const WeatherList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeatherCubit, WeatherState>(
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: context.read<WeatherCubit>().refreshWeather,
          child: ListView.builder(
            itemCount: state.weathers.length,
            itemBuilder: (context, index) {
              final weather = state.weathers[index];
              return _WeatherCard(
                weather: weather,
                units: state.temperatureUnits,
              );
            },
          ),
        );
      },
    );
  }
}

class _WeatherCard extends StatelessWidget {
  const _WeatherCard({
    Key? key,
    required this.weather,
    required this.units,
  }) : super(key: key);

  final Weather weather;
  final TemperatureUnits units;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = weather.toColor;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Dismissible(
        key: ValueKey(weather.location),
        onDismissed: (_) {
          context.read<WeatherCubit>().removeWeather(weather);
        },
        background: Container(color: Colors.red),
        child: Container(
          height: 400,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: weather.toColor,
            boxShadow: kElevationToShadow[2],
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.25, 0.75, 0.90, 1.0],
              colors: [
                color,
                color.brighten(10),
                color.brighten(33),
                color.brighten(50),
              ],
            ),
          ),
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 48),
                _WeatherIcon(condition: weather.condition),
                Text(
                  weather.location,
                  style: theme.textTheme.headline2?.copyWith(
                    fontWeight: FontWeight.w200,
                  ),
                ),
                Text(
                  weather.formattedTemperature(units),
                  style: theme.textTheme.headline3?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '''Last Updated at ${TimeOfDay.fromDateTime(weather.lastUpdated).format(context)}''',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WeatherIcon extends StatelessWidget {
  const _WeatherIcon({Key? key, required this.condition}) : super(key: key);

  static const _iconSize = 100.0;

  final WeatherCondition condition;

  @override
  Widget build(BuildContext context) {
    return Text(
      condition.toEmoji,
      style: const TextStyle(fontSize: _iconSize),
    );
  }
}

extension on WeatherCondition {
  String get toEmoji {
    switch (this) {
      case WeatherCondition.clear:
        return '☀️';
      case WeatherCondition.rainy:
        return '🌧️';
      case WeatherCondition.cloudy:
        return '☁️';
      case WeatherCondition.snowy:
        return '🌨️';
      case WeatherCondition.unknown:
        return '❓';
    }
  }
}

extension on Color {
  Color brighten(int percent) {
    assert(
      1 <= percent && percent <= 100,
      'Color brighten percentage can only be from 1-100',
    );
    final p = percent / 100;
    return Color.fromARGB(
      alpha,
      red + ((255 - red) * p).round(),
      green + ((255 - green) * p).round(),
      blue + ((255 - blue) * p).round(),
    );
  }
}

extension on Weather {
  String formattedTemperature(TemperatureUnits units) {
    return '''${temperature.value.toStringAsPrecision(2)}°${units.isCelsius ? 'C' : 'F'}''';
  }

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
        return Colors.white;
    }
  }
}
