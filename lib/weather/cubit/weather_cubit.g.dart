// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeatherState _$WeatherStateFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'WeatherState',
      json,
      ($checkedConvert) {
        final val = WeatherState(
          status: $checkedConvert(
              'status',
              (v) =>
                  $enumDecodeNullable(_$WeatherStatusEnumMap, v) ??
                  WeatherStatus.empty),
          temperatureUnits: $checkedConvert(
              'temperature_units',
              (v) =>
                  $enumDecodeNullable(_$TemperatureUnitsEnumMap, v) ??
                  TemperatureUnits.celsius),
          weathers: $checkedConvert(
              'weathers',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => Weather.fromJson(e as Map<String, dynamic>))
                  .toList()),
        );
        return val;
      },
      fieldKeyMap: const {'temperatureUnits': 'temperature_units'},
    );

Map<String, dynamic> _$WeatherStateToJson(WeatherState instance) =>
    <String, dynamic>{
      'status': _$WeatherStatusEnumMap[instance.status],
      'weathers': instance.weathers.map((e) => e.toJson()).toList(),
      'temperature_units': _$TemperatureUnitsEnumMap[instance.temperatureUnits],
    };

const _$WeatherStatusEnumMap = {
  WeatherStatus.empty: 'empty',
  WeatherStatus.loading: 'loading',
  WeatherStatus.loaded: 'loaded',
  WeatherStatus.failure: 'failure',
};

const _$TemperatureUnitsEnumMap = {
  TemperatureUnits.fahrenheit: 'fahrenheit',
  TemperatureUnits.celsius: 'celsius',
};
