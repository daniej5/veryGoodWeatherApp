// ignore_for_file: prefer_const_constructors

import 'package:json_annotation/json_annotation.dart';
import 'package:meta_weather_api/meta_weather_api.dart';
import 'package:test/test.dart';

void main() {
  group('Location', () {
    group('fromJson', () {
      test('throws CheckedFromJsonException when enum is unknown', () {
        expect(
          () => Location.fromJson(<String, dynamic>{
            'title': 'mock-title',
            'location_type': 'Unknown',
            'latt_long': '-34.75,83.28',
            'woeid': 42
          }),
          throwsA(isA<CheckedFromJsonException>()),
        );
      });
      test('returns proper object when given valid json', () {
        expect(
          Location.fromJson(<String, dynamic>{
            'title': 'mock-title',
            'location_type': 'City',
            'latt_long': '-34.75,83.28',
            'woeid': 42
          }),
          isA<Location>()
              .having((l) => l.title, 'title', 'mock-title')
              .having((l) => l.locationType, 'type', LocationType.city)
              .having(
                (l) => l.latLng,
                'latLng',
                isA<LatLng>()
                    .having((ll) => ll.latitude, 'latitude', -34.75)
                    .having((ll) => ll.longitude, 'longitude', 83.28),
              )
              .having((l) => l.woeid, 'woeid', 42),
        );
      });
      group('LatLngConverter', () {
        test('Latitude defaults to 0 if it cannot be parsed', () {
          expect(
            Location.fromJson(<String, dynamic>{
              'title': 'mock-title',
              'location_type': 'City',
              'latt_long': 'invalid,1',
              'woeid': 42
            }),
            isA<Location>().having(
              (l) => l.latLng,
              'latLng',
              isA<LatLng>()
                  .having((ll) => ll.latitude, 'latitude', 0)
                  .having((ll) => ll.longitude, 'longitude', 1),
            ),
          );
        });

        test('Longitude defaults to 0 if it cannot be parsed', () {
          expect(
            Location.fromJson(<String, dynamic>{
              'title': 'mock-title',
              'location_type': 'City',
              'latt_long': '1,invalid',
              'woeid': 42
            }),
            isA<Location>().having(
              (l) => l.latLng,
              'latLng',
              isA<LatLng>()
                  .having((ll) => ll.latitude, 'latitude', 1)
                  .having((ll) => ll.longitude, 'longitude', 0),
            ),
          );
        });

        test('LatLng defaults to 0 if given an invalid string format', () {
          expect(
            Location.fromJson(<String, dynamic>{
              'title': 'mock-title',
              'location_type': 'City',
              'latt_long': 'invalidLatLngFormat',
              'woeid': 42
            }),
            isA<Location>().having(
              (l) => l.latLng,
              'latLng',
              isA<LatLng>()
                  .having((ll) => ll.latitude, 'latitude', 0)
                  .having((ll) => ll.longitude, 'longitude', 0),
            ),
          );
        });
      });
    });
    group('toJson', () {
      const location = Location(
        title: 'mock-title',
        locationType: LocationType.city,
        latLng: LatLng(latitude: 1, longitude: 2),
        woeid: 42,
      );
      test('returns expected json when given valid object', () {
        expect(
            location.toJson(),
            equals(
              <String, dynamic>{
                'title': 'mock-title',
                'location_type': 'City',
                'latt_long': '1.0,2.0',
                'woeid': 42
              },
            ));
      });
    });
  });
}
