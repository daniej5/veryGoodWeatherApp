import 'package:flutter/material.dart';

/// {@template weather_empty}
/// The page that is displayed if no city has been searched yet.
/// {@endtemplate}
class WeatherEmpty extends StatelessWidget {
  /// {@macro weather_empty}
  const WeatherEmpty({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('🏙️', style: TextStyle(fontSize: 64)),
        Text(
          'Please Select a City!',
          style: theme.textTheme.headline5,
        ),
      ],
    );
  }
}
