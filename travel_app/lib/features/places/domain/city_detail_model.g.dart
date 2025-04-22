// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'city_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CityDetailImpl _$$CityDetailImplFromJson(Map<String, dynamic> json) =>
    _$CityDetailImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      country: Country.fromJson(json['country'] as Map<String, dynamic>),
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
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
      weatherForecast:
          json['weather_forecast'] == null
              ? null
              : WeatherForecast.fromJson(
                json['weather_forecast'] as Map<String, dynamic>,
              ),
    );

Map<String, dynamic> _$$CityDetailImplToJson(_$CityDetailImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'country': instance.country,
      'images': instance.images,
      'description': instance.description,
      'best_time_to_travel': instance.bestTimeToTravel,
      'famous_for': instance.famousFor,
      'timezone': instance.timezone,
      'population': instance.population,
      'wikidata_id': instance.wikidataId,
      'details_last_updated': instance.detailsLastUpdated,
      'current_weather': instance.currentWeather,
      'weather_last_updated': instance.weatherLastUpdated,
      'budget_scale': instance.budgetScale,
      'budget_summary': instance.budgetSummary,
      'weather_forecast': instance.weatherForecast,
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
  'weather': instance.weather,
  'main': instance.main,
  'visibility': instance.visibility,
  'wind': instance.wind,
  'dt': instance.dt,
  'timezone': instance.timezone,
  'name': instance.name,
};

_$WeatherInfoImpl _$$WeatherInfoImplFromJson(Map<String, dynamic> json) =>
    _$WeatherInfoImpl(
      id: (json['id'] as num?)?.toInt(),
      main: json['main'] as String?,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
    );

Map<String, dynamic> _$$WeatherInfoImplToJson(_$WeatherInfoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'main': instance.main,
      'description': instance.description,
      'icon': instance.icon,
    };

_$WeatherMainImpl _$$WeatherMainImplFromJson(Map<String, dynamic> json) =>
    _$WeatherMainImpl(
      temp: (json['temp'] as num?)?.toDouble(),
      feels_like: (json['feels_like'] as num?)?.toDouble(),
      temp_min: (json['temp_min'] as num?)?.toDouble(),
      temp_max: (json['temp_max'] as num?)?.toDouble(),
      pressure: (json['pressure'] as num?)?.toInt(),
      humidity: (json['humidity'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$WeatherMainImplToJson(_$WeatherMainImpl instance) =>
    <String, dynamic>{
      'temp': instance.temp,
      'feels_like': instance.feels_like,
      'temp_min': instance.temp_min,
      'temp_max': instance.temp_max,
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

_$WeatherForecastImpl _$$WeatherForecastImplFromJson(
  Map<String, dynamic> json,
) => _$WeatherForecastImpl(
  hourlyUnits:
      json['hourlyUnits'] == null
          ? null
          : HourlyUnits.fromJson(json['hourlyUnits'] as Map<String, dynamic>),
  hourly:
      json['hourly'] == null
          ? null
          : HourlyData.fromJson(json['hourly'] as Map<String, dynamic>),
  dailyUnits:
      json['dailyUnits'] == null
          ? null
          : DailyUnits.fromJson(json['dailyUnits'] as Map<String, dynamic>),
  daily:
      json['daily'] == null
          ? null
          : DailyData.fromJson(json['daily'] as Map<String, dynamic>),
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  generationtimeMs: (json['generationtimeMs'] as num?)?.toDouble(),
  utcOffsetSeconds: (json['utcOffsetSeconds'] as num?)?.toInt(),
  timezone: json['timezone'] as String?,
  timezoneAbbreviation: json['timezoneAbbreviation'] as String?,
  elevation: (json['elevation'] as num?)?.toDouble(),
);

Map<String, dynamic> _$$WeatherForecastImplToJson(
  _$WeatherForecastImpl instance,
) => <String, dynamic>{
  'hourlyUnits': instance.hourlyUnits,
  'hourly': instance.hourly,
  'dailyUnits': instance.dailyUnits,
  'daily': instance.daily,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'generationtimeMs': instance.generationtimeMs,
  'utcOffsetSeconds': instance.utcOffsetSeconds,
  'timezone': instance.timezone,
  'timezoneAbbreviation': instance.timezoneAbbreviation,
  'elevation': instance.elevation,
};

_$HourlyUnitsImpl _$$HourlyUnitsImplFromJson(Map<String, dynamic> json) =>
    _$HourlyUnitsImpl(
      temperature: json['temperature'] as String?,
      time: json['time'] as String?,
    );

Map<String, dynamic> _$$HourlyUnitsImplToJson(_$HourlyUnitsImpl instance) =>
    <String, dynamic>{
      'temperature': instance.temperature,
      'time': instance.time,
    };

_$HourlyDataImpl _$$HourlyDataImplFromJson(Map<String, dynamic> json) =>
    _$HourlyDataImpl(
      time: (json['time'] as List<dynamic>?)?.map((e) => e as String).toList(),
      temperature2m:
          (json['temperature2m'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList(),
      isDay:
          (json['isDay'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList(),
      sunshineDuration:
          (json['sunshineDuration'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList(),
      weathercode:
          (json['weathercode'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList(),
      precipitationProbability:
          (json['precipitationProbability'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList(),
    );

Map<String, dynamic> _$$HourlyDataImplToJson(_$HourlyDataImpl instance) =>
    <String, dynamic>{
      'time': instance.time,
      'temperature2m': instance.temperature2m,
      'isDay': instance.isDay,
      'sunshineDuration': instance.sunshineDuration,
      'weathercode': instance.weathercode,
      'precipitationProbability': instance.precipitationProbability,
    };

_$DailyUnitsImpl _$$DailyUnitsImplFromJson(Map<String, dynamic> json) =>
    _$DailyUnitsImpl(
      temperature_max: json['temperature_max'] as String?,
      temperature_min: json['temperature_min'] as String?,
      sunrise: json['sunrise'] as String?,
      sunset: json['sunset'] as String?,
      time: json['time'] as String?,
    );

Map<String, dynamic> _$$DailyUnitsImplToJson(_$DailyUnitsImpl instance) =>
    <String, dynamic>{
      'temperature_max': instance.temperature_max,
      'temperature_min': instance.temperature_min,
      'sunrise': instance.sunrise,
      'sunset': instance.sunset,
      'time': instance.time,
    };

_$DailyDataImpl _$$DailyDataImplFromJson(Map<String, dynamic> json) =>
    _$DailyDataImpl(
      time: (json['time'] as List<dynamic>?)?.map((e) => e as String).toList(),
      temperature_max:
          (json['temperature_max'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList(),
      temperature_min:
          (json['temperature_min'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList(),
      sunrise:
          (json['sunrise'] as List<dynamic>?)?.map((e) => e as String).toList(),
      sunset:
          (json['sunset'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$DailyDataImplToJson(_$DailyDataImpl instance) =>
    <String, dynamic>{
      'time': instance.time,
      'temperature_max': instance.temperature_max,
      'temperature_min': instance.temperature_min,
      'sunrise': instance.sunrise,
      'sunset': instance.sunset,
    };
