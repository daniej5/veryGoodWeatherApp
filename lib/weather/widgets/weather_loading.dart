import 'package:flutter/material.dart';

/// {@template weather_loading}
/// The page that is displayed when currently fetching the weather.
/// {@endtemplate}
class WeatherLoading extends StatelessWidget {
  /// {@macro weather_loading}
  const WeatherLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('⛅', style: TextStyle(fontSize: 64)),
        Text(
          'Loading Weather',
          style: theme.textTheme.headline5,
        ),
        const Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      ],
    );
  }
}
