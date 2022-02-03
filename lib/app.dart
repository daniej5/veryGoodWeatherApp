import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:very_good_weather_app/theme/theme.dart';
import 'package:very_good_weather_app/weather/weather.dart';
import 'package:weather_repository/weather_repository.dart';

/// {@template weather_app}
/// A Flutter application which gives users the ability to look up the weather
/// for any location.
///
/// It takes in a [WeatherRepository] object that is responsible for fetching
/// the weather data. The weather data state is managed via a root
/// [RepositoryProvider] which uses a [BlocProvider] to manage the theme state.
///
/// Because the theme state is managed with a HydratedCubit,
/// it is important to run this app inside a overriden zone. For more details
/// on how this is done please refer to the [hydrated_bloc package documentation](https://pub.dev/documentation/hydrated_bloc/latest/).
/// {@endtemplate}
class WeatherApp extends StatelessWidget {
  /// {@macro weather_app}
  const WeatherApp({Key? key, required WeatherRepository weatherRepository})
      : _weatherRepository = weatherRepository,
        super(key: key);

  final WeatherRepository _weatherRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: _weatherRepository,
      child: BlocProvider(
        create: (_) => ThemeCubit(),
        child: const WeatherAppView(),
      ),
    );
  }
}

/// {@template weather_app_view}
/// The widget which creates the [MaterialApp] that reacts to theme changes
/// using a [BlocBuilder].
///
/// This widgets builds out the main [WeatherPage].
/// {@endtemplate}
class WeatherAppView extends StatelessWidget {
  /// {@macro weather_app_view}
  const WeatherAppView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return BlocBuilder<ThemeCubit, Color>(
      builder: (context, color) {
        return MaterialApp(
          theme: ThemeData(
            primaryColor: color,
            textTheme: GoogleFonts.rajdhaniTextTheme(),
            appBarTheme: AppBarTheme(
              titleTextStyle: GoogleFonts.rajdhaniTextTheme(textTheme)
                  .apply(bodyColor: Colors.white)
                  .headline6,
            ),
          ),
          home: const WeatherPage(),
        );
      },
    );
  }
}
