// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'city_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CountryImpl _$$CountryImplFromJson(Map<String, dynamic> json) =>
    _$CountryImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
    );

Map<String, dynamic> _$$CountryImplToJson(_$CountryImpl instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

_$CityDetailImpl _$$CityDetailImplFromJson(Map<String, dynamic> json) =>
    _$CityDetailImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      country: Country.fromJson(json['country'] as Map<String, dynamic>),
      images: json['images'] as List<dynamic>? ?? const [],
      description: json['description'] as String?,
      bestTimeToTravel: json['best_time_to_travel'] as String?,
      famousFor: json['famous_for'] as String?,
      timezone: json['timezone'] as String?,
      population: (json['population'] as num?)?.toInt(),
      wikidataId: json['wikidata_id'] as String?,
      detailsLastUpdated: json['details_last_updated'] as String?,
      currentWeather:
          json['current_weather'] == null
              ? null
              : CurrentWeather.fromJson(
                json['current_weather'] as Map<String, dynamic>,
              ),
      weatherLastUpdated: json['weather_last_updated'] as String?,
      budgetScale: json['budget_scale'],
      budgetSummary: json['budget_summary'] as String?,
    );

Map<String, dynamic> _$$CityDetailImplToJson(_$CityDetailImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'country': instance.country.toJson(),
      'images': instance.images,
      'description': instance.description,
      'best_time_to_travel': instance.bestTimeToTravel,
      'famous_for': instance.famousFor,
      'timezone': instance.timezone,
      'population': instance.population,
      'wikidata_id': instance.wikidataId,
      'details_last_updated': instance.detailsLastUpdated,
      'current_weather': instance.currentWeather?.toJson(),
      'weather_last_updated': instance.weatherLastUpdated,
      'budget_scale': instance.budgetScale,
      'budget_summary': instance.budgetSummary,
    };

_$CurrentWeatherImpl _$$CurrentWeatherImplFromJson(Map<String, dynamic> json) =>
    _$CurrentWeatherImpl(
      weather:
          (json['weather'] as List<dynamic>?)
              ?.map((e) => WeatherInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      main:
          json['main'] == null
              ? null
              : WeatherMain.fromJson(json['main'] as Map<String, dynamic>),
      visibility: (json['visibility'] as num?)?.toInt(),
      wind:
          json['wind'] == null
              ? null
              : WeatherWind.fromJson(json['wind'] as Map<String, dynamic>),
      dt: (json['dt'] as num?)?.toInt(),
      timezone: (json['timezone'] as num?)?.toInt(),
      name: json['name'] as String?,
    );

Map<String, dynamic> _$$CurrentWeatherImplToJson(
  _$CurrentWeatherImpl instance,
) => <String, dynamic>{
  'weather': instance.weather?.map((e) => e.toJson()).toList(),
  'main': instance.main?.toJson(),
  'visibility': instance.visibility,
  'wind': instance.wind?.toJson(),
  'dt': instance.dt,
  'timezone': instance.timezone,
  'name': instance.name,
};

_$WeatherInfoImpl _$$WeatherInfoImplFromJson(Map<String, dynamic> json) =>
    _$WeatherInfoImpl(
      main: json['main'] as String?,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
    );

Map<String, dynamic> _$$WeatherInfoImplToJson(_$WeatherInfoImpl instance) =>
    <String, dynamic>{
      'main': instance.main,
      'description': instance.description,
      'icon': instance.icon,
    };

_$WeatherMainImpl _$$WeatherMainImplFromJson(Map<String, dynamic> json) =>
    _$WeatherMainImpl(
      temp: (json['temp'] as num?)?.toDouble(),
      feelsLike: (json['feelsLike'] as num?)?.toDouble(),
      tempMin: (json['tempMin'] as num?)?.toDouble(),
      tempMax: (json['tempMax'] as num?)?.toDouble(),
      pressure: (json['pressure'] as num?)?.toInt(),
      humidity: (json['humidity'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$WeatherMainImplToJson(_$WeatherMainImpl instance) =>
    <String, dynamic>{
      'temp': instance.temp,
      'feelsLike': instance.feelsLike,
      'tempMin': instance.tempMin,
      'tempMax': instance.tempMax,
      'pressure': instance.pressure,
      'humidity': instance.humidity,
    };

_$WeatherWindImpl _$$WeatherWindImplFromJson(Map<String, dynamic> json) =>
    _$WeatherWindImpl(
      speed: (json['speed'] as num?)?.toDouble(),
      deg: (json['deg'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$WeatherWindImplToJson(_$WeatherWindImpl instance) =>
    <String, dynamic>{'speed': instance.speed, 'deg': instance.deg};
