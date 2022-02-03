import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:very_good_weather_app/search/search.dart';
import 'package:very_good_weather_app/settings/settings.dart';
import 'package:very_good_weather_app/theme/cubit/theme_cubit.dart';
import 'package:very_good_weather_app/weather/cubit/weather_cubit.dart';
import 'package:very_good_weather_app/weather/widgets/widgets.dart';
import 'package:weather_repository/weather_repository.dart';

/// {@template weather_page}
/// The widget which creates a [BlocProvider] to manage the state of
/// displaying certain weather conditions.
/// {@endtemplate}
class WeatherPage extends StatelessWidget {
  /// {@macro weather_page}
  const WeatherPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WeatherCubit(context.read<WeatherRepository>()),
      child: const WeatherView(),
    );
  }
}

/// {@template weather_view}
/// The Widget of the main weather page. It will either display the initial
/// select a city screen, weather information for a certain city, or an error
/// screen if something went wrong.
/// {@endtemplate}
class WeatherView extends StatelessWidget {
  /// {@macro weather_view}
  const WeatherView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final weatherCubit = context.read<WeatherCubit>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Weather'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push<void>(
                SettingsPage.route(
                  context.read<WeatherCubit>(),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: BlocConsumer<WeatherCubit, WeatherState>(
          listener: (context, state) {
            if (state.status.isSuccess) {
              context.read<ThemeCubit>().updateTheme(state.weather);
            }
          },
          builder: (context, state) {
            switch (state.status) {
              case WeatherStatus.initial:
                return const WeatherEmpty();
              case WeatherStatus.loading:
                return const WeatherLoading();
              case WeatherStatus.success:
                return WeatherPopulated(
                  weather: state.weather,
                  units: state.temperatureUnits,
                  onRefresh: () {
                    return context.read<WeatherCubit>().refreshWeather();
                  },
                );
              case WeatherStatus.failure:
                return const WeatherError();
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.search),
        onPressed: () async {
          final city = await Navigator.of(context).push(SearchPage.route());
          await weatherCubit.fetchWeather(city);
        },
      ),
    );
  }
}
