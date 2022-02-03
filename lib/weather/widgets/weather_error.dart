import 'package:flutter/material.dart';

/// {@template weather_error}
/// The page that is displayed if the weather could not be fetched successfully.
/// {@endtemplate}
class WeatherError extends StatelessWidget {
  /// {@macro weather_error}
  const WeatherError({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('🙈', style: TextStyle(fontSize: 64)),
        Text(
          'Something went wrong!',
          style: theme.textTheme.headline5,
        ),
      ],
    );
  }
}
