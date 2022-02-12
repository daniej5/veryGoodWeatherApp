import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:very_good_weather_app/search/search.dart';
import 'package:very_good_weather_app/settings/settings.dart';
import 'package:very_good_weather_app/weather/weather.dart';
import 'package:weather_repository/weather_repository.dart';

class WeatherPage extends StatelessWidget {
  const WeatherPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WeatherCubit(
        context.read<WeatherRepository>(),
      ),
      child: const WeatherView(),
    );
  }
}

class WeatherView extends StatelessWidget {
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
      body: BlocConsumer<WeatherCubit, WeatherState>(
        listener: (context, state) {
          if (state.status.isFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error in adding city.'),
                backgroundColor: Colors.red,
              ),
            );
            context.read<WeatherCubit>().reloadWeatherAfterFailure();
          }
        },
        builder: (context, state) {
          switch (state.status) {
            case WeatherStatus.failure:
              return const SizedBox.shrink(
                key: ValueKey('weather_failure_box'),
              );
            case WeatherStatus.empty:
              return const WeatherEmpty();
            case WeatherStatus.loading:
              return const WeatherLoading();
            case WeatherStatus.loaded:
              return const WeatherList();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final city = await Navigator.of(context).push(SearchPage.route());
          await weatherCubit.addWeather(city);
        },
      ),
    );
  }
}
