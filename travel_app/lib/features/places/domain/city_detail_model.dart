// lib/features/places/domain/city_detail_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:travel_app/features/places/domain/country_model.dart';
// Remove if helper.dart is not used here
// import 'package:travel_app/features/places/presentation/controllers/helper.dart';

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
    String? timezone, // This might be the IANA timezone string from forecast?
    int? population,
    @JsonKey(name: 'wikidata_id') String? wikidataId,
    @JsonKey(name: 'details_last_updated') String? detailsLastUpdated,
    // Keep 'current_weather' ONLY if you have a separate API call populating this field.
    // If 'weather_forecast.current' is your SOLE source of current weather,
    // you might consider removing this top-level field later.
    @Deprecated("Use weatherForecast.currentData instead if using the new structure")
    @JsonKey(name: 'current_weather') CurrentWeather? currentWeatherDataField, // Keep old field name if needed for compatibility, but mark deprecated
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

// --- Nested Current Weather Model (FOR TOP-LEVEL 'current_weather') ---
// --- KEEP THIS UNCHANGED - It maps the structure expected for the top-level key ---
@freezed
class CurrentWeather with _$CurrentWeather {
  const factory CurrentWeather({
    @Default([]) List<WeatherInfo>? weather,
    WeatherMain? main,
    int? visibility,
    WeatherWind? wind,
    int? dt, // Timestamp
    int? timezone, // Timezone shift in seconds
    String? name, // City name
  }) = _CurrentWeather;

  factory CurrentWeather.fromJson(Map<String, dynamic> json) =>
      _$CurrentWeatherFromJson(json);
}

// --- WeatherInfo (for top-level CurrentWeather - UNCHANGED) ---
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

// --- WeatherMain (for top-level CurrentWeather - UNCHANGED) ---
@freezed
class WeatherMain with _$WeatherMain {
  const factory WeatherMain({
    double? temp,
    @JsonKey(name: 'feels_like') // Ensure key matches JSON source
    double? feelsLike,
    @JsonKey(name: 'temp_min')
    double? tempMin,
    @JsonKey(name: 'temp_max')
    double? tempMax,
    int? pressure,
    int? humidity,
  }) = _WeatherMain;

  factory WeatherMain.fromJson(Map<String, dynamic> json) =>
      _$WeatherMainFromJson(json);
}

// --- WeatherWind (for top-level CurrentWeather - UNCHANGED) ---
@freezed
class WeatherWind with _$WeatherWind {
   const factory WeatherWind({double? speed, int? deg}) = _WeatherWind;

  factory WeatherWind.fromJson(Map<String, dynamic> json) =>
      _$WeatherWindFromJson(json);
}


// --- Weather Forecast Models (TARGET FOR UPDATE) ---

// --- NEW: Model for 'currentUnits' nested within 'weather_forecast' ---
@freezed
class ForecastCurrentUnits with _$ForecastCurrentUnits {
  const factory ForecastCurrentUnits({
      String? time,
      String? interval,
      @JsonKey(name: 'temperature_2m') String? temperature2m,
      @JsonKey(name: 'is_day') String? isDay,
      String? weathercode,
      @JsonKey(name: 'windspeed_10m') String? windspeed10m,
      @JsonKey(name: 'winddirection_10m') String? winddirection10m,
  }) = _ForecastCurrentUnits;

   factory ForecastCurrentUnits.fromJson(Map<String, dynamic> json) => _$ForecastCurrentUnitsFromJson(json);
}

// --- NEW: Model for 'current' nested within 'weather_forecast' ---
@freezed
class ForecastCurrentData with _$ForecastCurrentData {
  const factory ForecastCurrentData({
     String? time,
     int? interval,
     @JsonKey(name: 'temperature2m') double? temperature2m,
     @JsonKey(name: 'is_day') int? isDay,
     int? weathercode,
     @JsonKey(name: 'windspeed_10m') double? windspeed10m,
     @JsonKey(name: 'winddirection_10m') int? winddirection10m,
  }) = _ForecastCurrentData;

  factory ForecastCurrentData.fromJson(Map<String, dynamic> json) => _$ForecastCurrentDataFromJson(json);
}


// --- Main WeatherForecast Model ---
@freezed
class WeatherForecast with _$WeatherForecast {
  const factory WeatherForecast({
    // --- Existing Fields (Keep UNCHANGED) ---
    HourlyUnits? hourlyUnits,
    HourlyData? hourly,
    DailyUnits? dailyUnits,
    DailyData? daily,
    double? latitude,
    double? longitude,
    @JsonKey(name: 'generationtime_ms') // Adjusted based on sample JSON key format
    double? generationtimeMs,
    @JsonKey(name: 'utc_offset_seconds') // Adjusted based on sample JSON key format
    int? utcOffsetSeconds,
    String? timezone,
    @JsonKey(name: 'timezone_abbreviation') // Adjusted based on sample JSON key format
    String? timezoneAbbreviation,
    double? elevation,

    // --- NEW Fields Added Here ---
    // Map 'currentUnits' JSON key to this field
    ForecastCurrentUnits? currentUnits,
    // Map 'current' JSON key to this field
    @JsonKey(name: 'current')
    ForecastCurrentData? currentData,

  }) = _WeatherForecast;

  factory WeatherForecast.fromJson(Map<String, dynamic> json) =>
      _$WeatherForecastFromJson(json);
}


// --- Existing HourlyUnits (UNCHANGED from previous version) ---
@freezed
class HourlyUnits with _$HourlyUnits {
  const factory HourlyUnits({
      // These names must match the keys in the 'hourlyUnits' part of YOUR JSON
      String? time, // Assuming 'time' is the key
      @JsonKey(name: 'temperature_2m') // From sample: use 'temperature_2m'
      String? temperature2m,
      @JsonKey(name: 'is_day') // From sample
      String? isDay,
      @JsonKey(name: 'sunshine_duration') // From sample
      String? sunshineDuration,
      String? weathercode, // From sample
      @JsonKey(name: 'precipitation_probability') // From sample
      String? precipitationProbability,
   }) = _HourlyUnits;

  factory HourlyUnits.fromJson(Map<String, dynamic> json) =>
      _$HourlyUnitsFromJson(json);
}

// --- Existing HourlyData (UNCHANGED from previous version) ---
@freezed
class HourlyData with _$HourlyData {
  const factory HourlyData({
      List<String>? time,
      // Corrected JsonKey name:
      @JsonKey(name: 'temperature2m') List<double>? temperature2m,
      // Corrected JsonKey name:
      @JsonKey(name: 'isDay') List<int>? isDay,
      // Corrected JsonKey name:
      @JsonKey(name: 'sunshineDuration') List<double>? sunshineDuration,
      // 'weathercode' matches field name, so JsonKey is optional but doesn't hurt
      // @JsonKey(name: 'weathercode') List<int>? weathercode,
      List<int>? weathercode, // Or just leave it without JsonKey
      // Corrected JsonKey name:
      @JsonKey(name: 'precipitationProbability') List<int>? precipitationProbability,
  }) = _HourlyData;

  factory HourlyData.fromJson(Map<String, dynamic> json) =>
      _$HourlyDataFromJson(json);
}

// --- Existing DailyUnits (UNCHANGED from previous version) ---
@freezed
class DailyUnits with _$DailyUnits {
  const factory DailyUnits({
      // These names must match the keys in the 'dailyUnits' part of YOUR JSON
      String? time,    // From sample
      String? sunrise, // From sample
      String? sunset,  // From sample
      // If your API provides daily min/max temp units, add them:
      // @JsonKey(name: 'temperature_2m_max') String? temperatureMax,
      // @JsonKey(name: 'temperature_2m_min') String? temperatureMin,
   }) = _DailyUnits;

  factory DailyUnits.fromJson(Map<String, dynamic> json) =>
      _$DailyUnitsFromJson(json);
}

// --- Existing DailyData (UNCHANGED from previous version) ---
@freezed
class DailyData with _$DailyData {
  const factory DailyData({
      // These names must match the keys in the 'daily' part of YOUR JSON
      List<String>? time,
      List<String>? sunrise, // From sample
      List<String>? sunset,  // From sample
      // If your API provides daily min/max temp data, add them:
      // @JsonKey(name: 'temperature_2m_max') List<double>? temperatureMax,
      // @JsonKey(name: 'temperature_2m_min') List<double>? temperatureMin,
  }) = _DailyData;

  factory DailyData.fromJson(Map<String, dynamic> json) =>
      _$DailyDataFromJson(json);
}


// --- Extensions (Keep or modify as needed) ---
class TemperatureRange { // Keep if used elsewhere
  final double minTemp;
  final double maxTemp;
  TemperatureRange(this.minTemp, this.maxTemp);
}

// Keep this extension if it's used and correct for your DailyData structure
// Note: This assumes DailyData has temperature_min/max fields.
// If not (based on sample), this extension will fail or return 0.
extension DailyDataExtensions on DailyData {
   // double getMinTempForDay(int index) => temperatureMin?[index] ?? 0; // Use field name from DailyData
   // double getMaxTempForDay(int index) => temperatureMax?[index] ?? 0; // Use field name from DailyData
}

// Remove or keep helper function if needed
/*
DailyData createDailyDataWithTemps({ ... }) {
   // Requires calculateDailyTempRanges to be defined elsewhere
}
*/

// Helper function definition needed if createDailyDataWithTemps is used
Map<String, TemperatureRange> calculateDailyTempRanges(List<String> hourlyTimes, List<double> hourlyTemps) {
 // Implement logic to group hourly temps by day and find min/max
 // Example (simplified, assumes times are sorted and cover full days):
 Map<String, List<double>> tempsByDay = {};
 for (int i = 0; i < hourlyTimes.length; i++) {
    final day = hourlyTimes[i].substring(0, 10); // Extract YYYY-MM-DD
    tempsByDay.putIfAbsent(day, () => []).add(hourlyTemps[i]);
 }
 Map<String, TemperatureRange> ranges = {};
 tempsByDay.forEach((day, temps) {
   if (temps.isNotEmpty) {
      ranges[day] = TemperatureRange(temps.reduce((a, b) => a < b ? a : b), temps.reduce((a, b) => a > b ? a : b));
   }
 });
 return ranges;
}