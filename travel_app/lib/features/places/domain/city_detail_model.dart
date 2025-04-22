// lib/features/places/domain/city_detail_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:travel_app/features/places/domain/country_model.dart';
import 'package:travel_app/features/places/presentation/controllers/helper.dart';

part 'city_detail_model.freezed.dart';
part 'city_detail_model.g.dart';

// --- Main City Detail Model ---
@freezed
class CityDetail with _$CityDetail {
  const factory CityDetail({
    required int id,
    required String name,
    required Country country,
    @JsonKey(name: 'images') @Default([]) List<String> images,
    String? description,
    @JsonKey(name: 'best_time_to_travel') String? bestTimeToTravel,
    @JsonKey(name: 'famous_for') String? famousFor,
    String? timezone,
    int? population,
    @JsonKey(name: 'wikidata_id') String? wikidataId,
    @JsonKey(name: 'details_last_updated') String? detailsLastUpdated,
    @JsonKey(name: 'current_weather') CurrentWeather? currentWeather,
    @JsonKey(name: 'weather_last_updated') String? weatherLastUpdated,
    @JsonKey(name: 'budget_scale') dynamic budgetScale,
    @JsonKey(name: 'budget_summary') String? budgetSummary,
    @JsonKey(name: 'weather_forecast') WeatherForecast? weatherForecast,
  }) = _CityDetail;

  factory CityDetail.fromJson(Map<String, dynamic> json) =>
      _$CityDetailFromJson(json);

  const CityDetail._();

  String? get primaryImageUrl => images.isNotEmpty ? images.first : null;
  bool get usesDefaultImage =>
      primaryImageUrl == null || primaryImageUrl!.isEmpty;
}

// --- Nested Current Weather Model ---
@freezed
class CurrentWeather with _$CurrentWeather {
  const factory CurrentWeather({
    @Default([]) List<WeatherInfo>? weather,
    WeatherMain? main,
    int? visibility,
    WeatherWind? wind,
    int? dt,
    int? timezone,
    String? name,
  }) = _CurrentWeather;

  factory CurrentWeather.fromJson(Map<String, dynamic> json) =>
      _$CurrentWeatherFromJson(json);
}

// --- WeatherInfo ---
@freezed
class WeatherInfo with _$WeatherInfo {
  const factory WeatherInfo({
    int? id,
    String? main,
    String? description,
    String? icon,
  }) = _WeatherInfo;

  factory WeatherInfo.fromJson(Map<String, dynamic> json) =>
      _$WeatherInfoFromJson(json);
}

// --- WeatherMain ---
@freezed
class WeatherMain with _$WeatherMain {
  const factory WeatherMain({
    double? temp,
    double? feels_like,
    double? temp_min,
    double? temp_max,
    int? pressure,
    int? humidity,
  }) = _WeatherMain;

  factory WeatherMain.fromJson(Map<String, dynamic> json) =>
      _$WeatherMainFromJson(json);
}

// --- WeatherWind ---
@freezed
class WeatherWind with _$WeatherWind {
  const factory WeatherWind({double? speed, int? deg}) = _WeatherWind;

  factory WeatherWind.fromJson(Map<String, dynamic> json) =>
      _$WeatherWindFromJson(json);
}

// --- Weather Forecast Models ---
@freezed
class WeatherForecast with _$WeatherForecast {
  const factory WeatherForecast({
    HourlyUnits? hourlyUnits,
    HourlyData? hourly,
    DailyUnits? dailyUnits,
    DailyData? daily,
    double? latitude,
    double? longitude,
    @JsonKey(name: 'generationtimeMs')
    double? generationtimeMs, // Keep JsonKey for case difference
    int? utcOffsetSeconds,
    String? timezone, // IANA Timezone Name (e.g., "America/Costa_Rica")
    String? timezoneAbbreviation, // e.g., "GMT-6"
    double? elevation,
  }) = _WeatherForecast;

  factory WeatherForecast.fromJson(Map<String, dynamic> json) =>
      _$WeatherForecastFromJson(json);
}

@freezed
class HourlyUnits with _$HourlyUnits {
  const factory HourlyUnits({String? temperature, String? time}) = _HourlyUnits;

  factory HourlyUnits.fromJson(Map<String, dynamic> json) =>
      _$HourlyUnitsFromJson(json);
}

@freezed
class HourlyData with _$HourlyData {
  const factory HourlyData({
    List<String>? time,
    @JsonKey(name: 'temperature2m') List<double>? temperature2m,
    List<int>? isDay,
    List<double>? sunshineDuration,
    List<int>? weathercode,
    @JsonKey(name: 'precipitationProbability')
    List<int>? precipitationProbability,
  }) = _HourlyData;

  factory HourlyData.fromJson(Map<String, dynamic> json) =>
      _$HourlyDataFromJson(json);
}

@freezed
class DailyUnits with _$DailyUnits {
  const factory DailyUnits({
    String? temperature_max,
    String? temperature_min,
    String? sunrise,
    String? sunset,
    String? time,
  }) = _DailyUnits;

  factory DailyUnits.fromJson(Map<String, dynamic> json) =>
      _$DailyUnitsFromJson(json);
}

@freezed
class DailyData with _$DailyData {
  const factory DailyData({
    List<String>? time,
    List<double>? temperature_max,
    List<double>? temperature_min,
    List<String>? sunrise,
    List<String>? sunset,
  }) = _DailyData;

  factory DailyData.fromJson(Map<String, dynamic> json) =>
      _$DailyDataFromJson(json);
}

class TemperatureRange {
  final double minTemp;
  final double maxTemp;

  TemperatureRange(this.minTemp, this.maxTemp);
}

extension DailyDataExtensions on DailyData {
  double getMinTempForDay(int index) => temperature_min?[index] ?? 0;
  double getMaxTempForDay(int index) => temperature_max?[index] ?? 0;
}

DailyData createDailyDataWithTemps({
  required List<String> dailyTimes,
  List<String>? sunrise,
  List<String>? sunset,
  required List<String> hourlyTimes,
  required List<double> hourlyTemps,
}) {
  final ranges = calculateDailyTempRanges(hourlyTimes, hourlyTemps);
  final minTemps = <double>[];
  final maxTemps = <double>[];

  for (final date in dailyTimes) {
    final range = ranges[date];
    minTemps.add(range?.minTemp ?? 0);
    maxTemps.add(range?.maxTemp ?? 0);
  }

  return DailyData(
    time: dailyTimes,
    sunrise: sunrise,
    sunset: sunset,
    temperature_min: minTemps,
    temperature_max: maxTemps,
  );
}
