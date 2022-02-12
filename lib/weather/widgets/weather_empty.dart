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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🏙️', style: TextStyle(fontSize: 64)),
          Text(
            'Please Add a City!',
            style: theme.textTheme.headline5,
          ),
        ],
      ),
    );
  }
}
