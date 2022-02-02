// ignore_for_file: prefer_const_constructors

import 'package:test/test.dart';
import 'package:weather_repository/weather_repository.dart';

void main() {
  group('Weather', () {
    const weatherObject = Weather(
      location: 'mock-location',
      temperature: 70.0,
      condition: WeatherCondition.clear,
    );
    const weatherJson = <String, dynamic>{
      'location': 'mock-location',
      'temperature': 70.0,
      'condition': 'clear',
    };
    group('fromJson', () {
      test('returns expected object given valid json ', () {
        expect(Weather.fromJson(weatherJson), weatherObject);
      });
    });

    group('toJson', () {
      test('returns expected json when called on valid object', () {
        expect(weatherObject.toJson(), weatherJson);
      });
    });
  });
}
