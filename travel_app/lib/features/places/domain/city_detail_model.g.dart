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
      currentWeatherDataField:
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
      'current_weather': instance.currentWeatherDataField,
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
      feelsLike: (json['feels_like'] as num?)?.toDouble(),
      tempMin: (json['temp_min'] as num?)?.toDouble(),
      tempMax: (json['temp_max'] as num?)?.toDouble(),
      pressure: (json['pressure'] as num?)?.toInt(),
      humidity: (json['humidity'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$WeatherMainImplToJson(_$WeatherMainImpl instance) =>
    <String, dynamic>{
      'temp': instance.temp,
      'feels_like': instance.feelsLike,
      'temp_min': instance.tempMin,
      'temp_max': instance.tempMax,
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

_$ForecastCurrentUnitsImpl _$$ForecastCurrentUnitsImplFromJson(
  Map<String, dynamic> json,
) => _$ForecastCurrentUnitsImpl(
  time: json['time'] as String?,
  interval: json['interval'] as String?,
  temperature2m: json['temperature_2m'] as String?,
  isDay: json['is_day'] as String?,
  weathercode: json['weathercode'] as String?,
  windspeed10m: json['windspeed_10m'] as String?,
  winddirection10m: json['winddirection_10m'] as String?,
);

Map<String, dynamic> _$$ForecastCurrentUnitsImplToJson(
  _$ForecastCurrentUnitsImpl instance,
) => <String, dynamic>{
  'time': instance.time,
  'interval': instance.interval,
  'temperature_2m': instance.temperature2m,
  'is_day': instance.isDay,
  'weathercode': instance.weathercode,
  'windspeed_10m': instance.windspeed10m,
  'winddirection_10m': instance.winddirection10m,
};

_$ForecastCurrentDataImpl _$$ForecastCurrentDataImplFromJson(
  Map<String, dynamic> json,
) => _$ForecastCurrentDataImpl(
  time: json['time'] as String?,
  interval: (json['interval'] as num?)?.toInt(),
  temperature2m: (json['temperature2m'] as num?)?.toDouble(),
  isDay: (json['is_day'] as num?)?.toInt(),
  weathercode: (json['weathercode'] as num?)?.toInt(),
  windspeed10m: (json['windspeed_10m'] as num?)?.toDouble(),
  winddirection10m: (json['winddirection_10m'] as num?)?.toInt(),
);

Map<String, dynamic> _$$ForecastCurrentDataImplToJson(
  _$ForecastCurrentDataImpl instance,
) => <String, dynamic>{
  'time': instance.time,
  'interval': instance.interval,
  'temperature2m': instance.temperature2m,
  'is_day': instance.isDay,
  'weathercode': instance.weathercode,
  'windspeed_10m': instance.windspeed10m,
  'winddirection_10m': instance.winddirection10m,
};

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
  generationtimeMs: (json['generationtime_ms'] as num?)?.toDouble(),
  utcOffsetSeconds: (json['utc_offset_seconds'] as num?)?.toInt(),
  timezone: json['timezone'] as String?,
  timezoneAbbreviation: json['timezone_abbreviation'] as String?,
  elevation: (json['elevation'] as num?)?.toDouble(),
  currentUnits:
      json['currentUnits'] == null
          ? null
          : ForecastCurrentUnits.fromJson(
            json['currentUnits'] as Map<String, dynamic>,
          ),
  currentData:
      json['current'] == null
          ? null
          : ForecastCurrentData.fromJson(
            json['current'] as Map<String, dynamic>,
          ),
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
  'generationtime_ms': instance.generationtimeMs,
  'utc_offset_seconds': instance.utcOffsetSeconds,
  'timezone': instance.timezone,
  'timezone_abbreviation': instance.timezoneAbbreviation,
  'elevation': instance.elevation,
  'currentUnits': instance.currentUnits,
  'current': instance.currentData,
};

_$HourlyUnitsImpl _$$HourlyUnitsImplFromJson(Map<String, dynamic> json) =>
    _$HourlyUnitsImpl(
      time: json['time'] as String?,
      temperature2m: json['temperature_2m'] as String?,
      isDay: json['is_day'] as String?,
      sunshineDuration: json['sunshine_duration'] as String?,
      weathercode: json['weathercode'] as String?,
      precipitationProbability: json['precipitation_probability'] as String?,
    );

Map<String, dynamic> _$$HourlyUnitsImplToJson(_$HourlyUnitsImpl instance) =>
    <String, dynamic>{
      'time': instance.time,
      'temperature_2m': instance.temperature2m,
      'is_day': instance.isDay,
      'sunshine_duration': instance.sunshineDuration,
      'weathercode': instance.weathercode,
      'precipitation_probability': instance.precipitationProbability,
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
      time: json['time'] as String?,
      sunrise: json['sunrise'] as String?,
      sunset: json['sunset'] as String?,
    );

Map<String, dynamic> _$$DailyUnitsImplToJson(_$DailyUnitsImpl instance) =>
    <String, dynamic>{
      'time': instance.time,
      'sunrise': instance.sunrise,
      'sunset': instance.sunset,
    };

_$DailyDataImpl _$$DailyDataImplFromJson(Map<String, dynamic> json) =>
    _$DailyDataImpl(
      time: (json['time'] as List<dynamic>?)?.map((e) => e as String).toList(),
      sunrise:
          (json['sunrise'] as List<dynamic>?)?.map((e) => e as String).toList(),
      sunset:
          (json['sunset'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$DailyDataImplToJson(_$DailyDataImpl instance) =>
    <String, dynamic>{
      'time': instance.time,
      'sunrise': instance.sunrise,
      'sunset': instance.sunset,
    };
