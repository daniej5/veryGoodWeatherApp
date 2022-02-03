import 'package:test/test.dart';
import 'package:very_good_weather_app/weather/models/models.dart';

void main() {
  group('Weather', () {
    group('copyWith', () {
      final weather = Weather.empty;
      test(
        'can update field',
        () {
          expect(
            weather.copyWith(location: 'Las Vegas'),
            isA<Weather>().having(
              (w) => w.location,
              'location',
              equals('Las Vegas'),
            ),
          );
        },
      );
    });
  });
}
