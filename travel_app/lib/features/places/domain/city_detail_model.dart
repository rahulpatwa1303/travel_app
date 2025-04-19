// lib/features/places/domain/city_detail_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';
// Import the existing Country model (adjust path if needed)

part 'city_detail_model.freezed.dart';
part 'city_detail_model.g.dart';

@freezed
class Country with _$Country {
  const factory Country({
    required int id,
    required String name,
  }) = _Country;

  factory Country.fromJson(Map<String, dynamic> json) =>
      _$CountryFromJson(json);
}

// --- Main City Detail Model ---
@freezed
class CityDetail with _$CityDetail {
  @JsonSerializable(explicitToJson: true)
  const factory CityDetail({
    required int id,
    required String name,
    required Country country,
    @Default([]) List<dynamic>? images,
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
  }) = _CityDetail;

  // --- ADD THIS PRIVATE CONSTRUCTOR ---
  const CityDetail._();
  // --- END ADDED CONSTRUCTOR ---

  factory CityDetail.fromJson(Map<String, dynamic> json) =>
      _$CityDetailFromJson(json);

  // Helper getter for primary image URL
  String? get primaryImageUrl {
     if (images != null && images!.isNotEmpty) {
       var firstImage = images!.first;
       if (firstImage is Map<String, dynamic> && firstImage.containsKey('url')) {
         return firstImage['url'] as String?;
       } else if (firstImage is String) {
         return firstImage;
       }
     }
     return null;
   }

   // Helper to determine if default image should be used
   bool get usesDefaultImage => primaryImageUrl == null || primaryImageUrl!.isEmpty;

}
// --- Nested Current Weather Model ---
@freezed
class CurrentWeather with _$CurrentWeather {
   @JsonSerializable(explicitToJson: true)
   const factory CurrentWeather({
    @Default([]) List<WeatherInfo>? weather,
    WeatherMain? main,
    int? visibility,
    WeatherWind? wind,
    int? dt, // Timestamp
    int? timezone, // Timezone offset in seconds?
    String? name, // Name from weather source
  }) = _CurrentWeather;

  factory CurrentWeather.fromJson(Map<String, dynamic> json) =>
      _$CurrentWeatherFromJson(json);
}

// --- Nested Weather Info Model ---
@freezed
class WeatherInfo with _$WeatherInfo {
  const factory WeatherInfo({
    String? main,
    String? description,
    String? icon,
  }) = _WeatherInfo;

  factory WeatherInfo.fromJson(Map<String, dynamic> json) =>
      _$WeatherInfoFromJson(json);
}

// --- Nested Weather Main Model ---
@freezed
class WeatherMain with _$WeatherMain {
  const factory WeatherMain({
    double? temp,
    // Match JSON key if different (example: feels_like)
    @JsonKey(name: 'feelsLike') double? feelsLike, // Adjusted key based on provided JSON
    @JsonKey(name: 'tempMin') double? tempMin,     // Adjusted key
    @JsonKey(name: 'tempMax') double? tempMax,     // Adjusted key
    int? pressure,
    int? humidity,
  }) = _WeatherMain;

  factory WeatherMain.fromJson(Map<String, dynamic> json) =>
      _$WeatherMainFromJson(json);
}

// --- Nested Weather Wind Model ---
@freezed
class WeatherWind with _$WeatherWind {
  const factory WeatherWind({
    double? speed,
    int? deg,
  }) = _WeatherWind;

  factory WeatherWind.fromJson(Map<String, dynamic> json) =>
      _$WeatherWindFromJson(json);
}