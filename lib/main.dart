import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_services_binding/flutter_services_binding.dart';

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:very_good_weather_app/app.dart';
import 'package:very_good_weather_app/weather_bloc_observer.dart';
import 'package:weather_repository/weather_repository.dart';

// ignore: avoid_void_async
void main() async {
  await setupApp();
}

Future<void> setupApp() async {
  FlutterServicesBinding.ensureInitialized();
  final storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getTemporaryDirectory(),
  );
  HydratedBlocOverrides.runZoned(
    launchApp,
    blocObserver: WeatherBlocObserver(),
    storage: storage,
  );
}

void launchApp() => runApp(WeatherApp(weatherRepository: WeatherRepository()));
