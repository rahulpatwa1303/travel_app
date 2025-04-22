// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'city_detail_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CityDetail _$CityDetailFromJson(Map<String, dynamic> json) {
  return _CityDetail.fromJson(json);
}

/// @nodoc
mixin _$CityDetail {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  Country get country => throw _privateConstructorUsedError;
  @JsonKey(name: 'images')
  List<String> get images => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'best_time_to_travel')
  String? get bestTimeToTravel => throw _privateConstructorUsedError;
  @JsonKey(name: 'famous_for')
  String? get famousFor => throw _privateConstructorUsedError;
  String? get timezone => throw _privateConstructorUsedError;
  int? get population => throw _privateConstructorUsedError;
  @JsonKey(name: 'wikidata_id')
  String? get wikidataId => throw _privateConstructorUsedError;
  @JsonKey(name: 'details_last_updated')
  String? get detailsLastUpdated => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_weather')
  CurrentWeather? get currentWeather => throw _privateConstructorUsedError;
  @JsonKey(name: 'weather_last_updated')
  String? get weatherLastUpdated => throw _privateConstructorUsedError;
  @JsonKey(name: 'budget_scale')
  dynamic get budgetScale => throw _privateConstructorUsedError;
  @JsonKey(name: 'budget_summary')
  String? get budgetSummary => throw _privateConstructorUsedError;
  @JsonKey(name: 'weather_forecast')
  WeatherForecast? get weatherForecast => throw _privateConstructorUsedError;

  /// Serializes this CityDetail to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CityDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CityDetailCopyWith<CityDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CityDetailCopyWith<$Res> {
  factory $CityDetailCopyWith(
    CityDetail value,
    $Res Function(CityDetail) then,
  ) = _$CityDetailCopyWithImpl<$Res, CityDetail>;
  @useResult
  $Res call({
    int id,
    String name,
    Country country,
    @JsonKey(name: 'images') List<String> images,
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
  });

  $CountryCopyWith<$Res> get country;
  $CurrentWeatherCopyWith<$Res>? get currentWeather;
  $WeatherForecastCopyWith<$Res>? get weatherForecast;
}

/// @nodoc
class _$CityDetailCopyWithImpl<$Res, $Val extends CityDetail>
    implements $CityDetailCopyWith<$Res> {
  _$CityDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CityDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? country = null,
    Object? images = null,
    Object? description = freezed,
    Object? bestTimeToTravel = freezed,
    Object? famousFor = freezed,
    Object? timezone = freezed,
    Object? population = freezed,
    Object? wikidataId = freezed,
    Object? detailsLastUpdated = freezed,
    Object? currentWeather = freezed,
    Object? weatherLastUpdated = freezed,
    Object? budgetScale = freezed,
    Object? budgetSummary = freezed,
    Object? weatherForecast = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int,
            name:
                null == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String,
            country:
                null == country
                    ? _value.country
                    : country // ignore: cast_nullable_to_non_nullable
                        as Country,
            images:
                null == images
                    ? _value.images
                    : images // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            description:
                freezed == description
                    ? _value.description
                    : description // ignore: cast_nullable_to_non_nullable
                        as String?,
            bestTimeToTravel:
                freezed == bestTimeToTravel
                    ? _value.bestTimeToTravel
                    : bestTimeToTravel // ignore: cast_nullable_to_non_nullable
                        as String?,
            famousFor:
                freezed == famousFor
                    ? _value.famousFor
                    : famousFor // ignore: cast_nullable_to_non_nullable
                        as String?,
            timezone:
                freezed == timezone
                    ? _value.timezone
                    : timezone // ignore: cast_nullable_to_non_nullable
                        as String?,
            population:
                freezed == population
                    ? _value.population
                    : population // ignore: cast_nullable_to_non_nullable
                        as int?,
            wikidataId:
                freezed == wikidataId
                    ? _value.wikidataId
                    : wikidataId // ignore: cast_nullable_to_non_nullable
                        as String?,
            detailsLastUpdated:
                freezed == detailsLastUpdated
                    ? _value.detailsLastUpdated
                    : detailsLastUpdated // ignore: cast_nullable_to_non_nullable
                        as String?,
            currentWeather:
                freezed == currentWeather
                    ? _value.currentWeather
                    : currentWeather // ignore: cast_nullable_to_non_nullable
                        as CurrentWeather?,
            weatherLastUpdated:
                freezed == weatherLastUpdated
                    ? _value.weatherLastUpdated
                    : weatherLastUpdated // ignore: cast_nullable_to_non_nullable
                        as String?,
            budgetScale:
                freezed == budgetScale
                    ? _value.budgetScale
                    : budgetScale // ignore: cast_nullable_to_non_nullable
                        as dynamic,
            budgetSummary:
                freezed == budgetSummary
                    ? _value.budgetSummary
                    : budgetSummary // ignore: cast_nullable_to_non_nullable
                        as String?,
            weatherForecast:
                freezed == weatherForecast
                    ? _value.weatherForecast
                    : weatherForecast // ignore: cast_nullable_to_non_nullable
                        as WeatherForecast?,
          )
          as $Val,
    );
  }

  /// Create a copy of CityDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CountryCopyWith<$Res> get country {
    return $CountryCopyWith<$Res>(_value.country, (value) {
      return _then(_value.copyWith(country: value) as $Val);
    });
  }

  /// Create a copy of CityDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CurrentWeatherCopyWith<$Res>? get currentWeather {
    if (_value.currentWeather == null) {
      return null;
    }

    return $CurrentWeatherCopyWith<$Res>(_value.currentWeather!, (value) {
      return _then(_value.copyWith(currentWeather: value) as $Val);
    });
  }

  /// Create a copy of CityDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WeatherForecastCopyWith<$Res>? get weatherForecast {
    if (_value.weatherForecast == null) {
      return null;
    }

    return $WeatherForecastCopyWith<$Res>(_value.weatherForecast!, (value) {
      return _then(_value.copyWith(weatherForecast: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CityDetailImplCopyWith<$Res>
    implements $CityDetailCopyWith<$Res> {
  factory _$$CityDetailImplCopyWith(
    _$CityDetailImpl value,
    $Res Function(_$CityDetailImpl) then,
  ) = __$$CityDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String name,
    Country country,
    @JsonKey(name: 'images') List<String> images,
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
  });

  @override
  $CountryCopyWith<$Res> get country;
  @override
  $CurrentWeatherCopyWith<$Res>? get currentWeather;
  @override
  $WeatherForecastCopyWith<$Res>? get weatherForecast;
}

/// @nodoc
class __$$CityDetailImplCopyWithImpl<$Res>
    extends _$CityDetailCopyWithImpl<$Res, _$CityDetailImpl>
    implements _$$CityDetailImplCopyWith<$Res> {
  __$$CityDetailImplCopyWithImpl(
    _$CityDetailImpl _value,
    $Res Function(_$CityDetailImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CityDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? country = null,
    Object? images = null,
    Object? description = freezed,
    Object? bestTimeToTravel = freezed,
    Object? famousFor = freezed,
    Object? timezone = freezed,
    Object? population = freezed,
    Object? wikidataId = freezed,
    Object? detailsLastUpdated = freezed,
    Object? currentWeather = freezed,
    Object? weatherLastUpdated = freezed,
    Object? budgetScale = freezed,
    Object? budgetSummary = freezed,
    Object? weatherForecast = freezed,
  }) {
    return _then(
      _$CityDetailImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int,
        name:
            null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String,
        country:
            null == country
                ? _value.country
                : country // ignore: cast_nullable_to_non_nullable
                    as Country,
        images:
            null == images
                ? _value._images
                : images // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        description:
            freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                    as String?,
        bestTimeToTravel:
            freezed == bestTimeToTravel
                ? _value.bestTimeToTravel
                : bestTimeToTravel // ignore: cast_nullable_to_non_nullable
                    as String?,
        famousFor:
            freezed == famousFor
                ? _value.famousFor
                : famousFor // ignore: cast_nullable_to_non_nullable
                    as String?,
        timezone:
            freezed == timezone
                ? _value.timezone
                : timezone // ignore: cast_nullable_to_non_nullable
                    as String?,
        population:
            freezed == population
                ? _value.population
                : population // ignore: cast_nullable_to_non_nullable
                    as int?,
        wikidataId:
            freezed == wikidataId
                ? _value.wikidataId
                : wikidataId // ignore: cast_nullable_to_non_nullable
                    as String?,
        detailsLastUpdated:
            freezed == detailsLastUpdated
                ? _value.detailsLastUpdated
                : detailsLastUpdated // ignore: cast_nullable_to_non_nullable
                    as String?,
        currentWeather:
            freezed == currentWeather
                ? _value.currentWeather
                : currentWeather // ignore: cast_nullable_to_non_nullable
                    as CurrentWeather?,
        weatherLastUpdated:
            freezed == weatherLastUpdated
                ? _value.weatherLastUpdated
                : weatherLastUpdated // ignore: cast_nullable_to_non_nullable
                    as String?,
        budgetScale:
            freezed == budgetScale
                ? _value.budgetScale
                : budgetScale // ignore: cast_nullable_to_non_nullable
                    as dynamic,
        budgetSummary:
            freezed == budgetSummary
                ? _value.budgetSummary
                : budgetSummary // ignore: cast_nullable_to_non_nullable
                    as String?,
        weatherForecast:
            freezed == weatherForecast
                ? _value.weatherForecast
                : weatherForecast // ignore: cast_nullable_to_non_nullable
                    as WeatherForecast?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CityDetailImpl extends _CityDetail {
  const _$CityDetailImpl({
    required this.id,
    required this.name,
    required this.country,
    @JsonKey(name: 'images') final List<String> images = const [],
    this.description,
    @JsonKey(name: 'best_time_to_travel') this.bestTimeToTravel,
    @JsonKey(name: 'famous_for') this.famousFor,
    this.timezone,
    this.population,
    @JsonKey(name: 'wikidata_id') this.wikidataId,
    @JsonKey(name: 'details_last_updated') this.detailsLastUpdated,
    @JsonKey(name: 'current_weather') this.currentWeather,
    @JsonKey(name: 'weather_last_updated') this.weatherLastUpdated,
    @JsonKey(name: 'budget_scale') this.budgetScale,
    @JsonKey(name: 'budget_summary') this.budgetSummary,
    @JsonKey(name: 'weather_forecast') this.weatherForecast,
  }) : _images = images,
       super._();

  factory _$CityDetailImpl.fromJson(Map<String, dynamic> json) =>
      _$$CityDetailImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final Country country;
  final List<String> _images;
  @override
  @JsonKey(name: 'images')
  List<String> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  @override
  final String? description;
  @override
  @JsonKey(name: 'best_time_to_travel')
  final String? bestTimeToTravel;
  @override
  @JsonKey(name: 'famous_for')
  final String? famousFor;
  @override
  final String? timezone;
  @override
  final int? population;
  @override
  @JsonKey(name: 'wikidata_id')
  final String? wikidataId;
  @override
  @JsonKey(name: 'details_last_updated')
  final String? detailsLastUpdated;
  @override
  @JsonKey(name: 'current_weather')
  final CurrentWeather? currentWeather;
  @override
  @JsonKey(name: 'weather_last_updated')
  final String? weatherLastUpdated;
  @override
  @JsonKey(name: 'budget_scale')
  final dynamic budgetScale;
  @override
  @JsonKey(name: 'budget_summary')
  final String? budgetSummary;
  @override
  @JsonKey(name: 'weather_forecast')
  final WeatherForecast? weatherForecast;

  @override
  String toString() {
    return 'CityDetail(id: $id, name: $name, country: $country, images: $images, description: $description, bestTimeToTravel: $bestTimeToTravel, famousFor: $famousFor, timezone: $timezone, population: $population, wikidataId: $wikidataId, detailsLastUpdated: $detailsLastUpdated, currentWeather: $currentWeather, weatherLastUpdated: $weatherLastUpdated, budgetScale: $budgetScale, budgetSummary: $budgetSummary, weatherForecast: $weatherForecast)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CityDetailImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.country, country) || other.country == country) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.bestTimeToTravel, bestTimeToTravel) ||
                other.bestTimeToTravel == bestTimeToTravel) &&
            (identical(other.famousFor, famousFor) ||
                other.famousFor == famousFor) &&
            (identical(other.timezone, timezone) ||
                other.timezone == timezone) &&
            (identical(other.population, population) ||
                other.population == population) &&
            (identical(other.wikidataId, wikidataId) ||
                other.wikidataId == wikidataId) &&
            (identical(other.detailsLastUpdated, detailsLastUpdated) ||
                other.detailsLastUpdated == detailsLastUpdated) &&
            (identical(other.currentWeather, currentWeather) ||
                other.currentWeather == currentWeather) &&
            (identical(other.weatherLastUpdated, weatherLastUpdated) ||
                other.weatherLastUpdated == weatherLastUpdated) &&
            const DeepCollectionEquality().equals(
              other.budgetScale,
              budgetScale,
            ) &&
            (identical(other.budgetSummary, budgetSummary) ||
                other.budgetSummary == budgetSummary) &&
            (identical(other.weatherForecast, weatherForecast) ||
                other.weatherForecast == weatherForecast));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    country,
    const DeepCollectionEquality().hash(_images),
    description,
    bestTimeToTravel,
    famousFor,
    timezone,
    population,
    wikidataId,
    detailsLastUpdated,
    currentWeather,
    weatherLastUpdated,
    const DeepCollectionEquality().hash(budgetScale),
    budgetSummary,
    weatherForecast,
  );

  /// Create a copy of CityDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CityDetailImplCopyWith<_$CityDetailImpl> get copyWith =>
      __$$CityDetailImplCopyWithImpl<_$CityDetailImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CityDetailImplToJson(this);
  }
}

abstract class _CityDetail extends CityDetail {
  const factory _CityDetail({
    required final int id,
    required final String name,
    required final Country country,
    @JsonKey(name: 'images') final List<String> images,
    final String? description,
    @JsonKey(name: 'best_time_to_travel') final String? bestTimeToTravel,
    @JsonKey(name: 'famous_for') final String? famousFor,
    final String? timezone,
    final int? population,
    @JsonKey(name: 'wikidata_id') final String? wikidataId,
    @JsonKey(name: 'details_last_updated') final String? detailsLastUpdated,
    @JsonKey(name: 'current_weather') final CurrentWeather? currentWeather,
    @JsonKey(name: 'weather_last_updated') final String? weatherLastUpdated,
    @JsonKey(name: 'budget_scale') final dynamic budgetScale,
    @JsonKey(name: 'budget_summary') final String? budgetSummary,
    @JsonKey(name: 'weather_forecast') final WeatherForecast? weatherForecast,
  }) = _$CityDetailImpl;
  const _CityDetail._() : super._();

  factory _CityDetail.fromJson(Map<String, dynamic> json) =
      _$CityDetailImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  Country get country;
  @override
  @JsonKey(name: 'images')
  List<String> get images;
  @override
  String? get description;
  @override
  @JsonKey(name: 'best_time_to_travel')
  String? get bestTimeToTravel;
  @override
  @JsonKey(name: 'famous_for')
  String? get famousFor;
  @override
  String? get timezone;
  @override
  int? get population;
  @override
  @JsonKey(name: 'wikidata_id')
  String? get wikidataId;
  @override
  @JsonKey(name: 'details_last_updated')
  String? get detailsLastUpdated;
  @override
  @JsonKey(name: 'current_weather')
  CurrentWeather? get currentWeather;
  @override
  @JsonKey(name: 'weather_last_updated')
  String? get weatherLastUpdated;
  @override
  @JsonKey(name: 'budget_scale')
  dynamic get budgetScale;
  @override
  @JsonKey(name: 'budget_summary')
  String? get budgetSummary;
  @override
  @JsonKey(name: 'weather_forecast')
  WeatherForecast? get weatherForecast;

  /// Create a copy of CityDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CityDetailImplCopyWith<_$CityDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CurrentWeather _$CurrentWeatherFromJson(Map<String, dynamic> json) {
  return _CurrentWeather.fromJson(json);
}

/// @nodoc
mixin _$CurrentWeather {
  List<WeatherInfo>? get weather => throw _privateConstructorUsedError;
  WeatherMain? get main => throw _privateConstructorUsedError;
  int? get visibility => throw _privateConstructorUsedError;
  WeatherWind? get wind => throw _privateConstructorUsedError;
  int? get dt => throw _privateConstructorUsedError;
  int? get timezone => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;

  /// Serializes this CurrentWeather to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CurrentWeather
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CurrentWeatherCopyWith<CurrentWeather> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CurrentWeatherCopyWith<$Res> {
  factory $CurrentWeatherCopyWith(
    CurrentWeather value,
    $Res Function(CurrentWeather) then,
  ) = _$CurrentWeatherCopyWithImpl<$Res, CurrentWeather>;
  @useResult
  $Res call({
    List<WeatherInfo>? weather,
    WeatherMain? main,
    int? visibility,
    WeatherWind? wind,
    int? dt,
    int? timezone,
    String? name,
  });

  $WeatherMainCopyWith<$Res>? get main;
  $WeatherWindCopyWith<$Res>? get wind;
}

/// @nodoc
class _$CurrentWeatherCopyWithImpl<$Res, $Val extends CurrentWeather>
    implements $CurrentWeatherCopyWith<$Res> {
  _$CurrentWeatherCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CurrentWeather
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weather = freezed,
    Object? main = freezed,
    Object? visibility = freezed,
    Object? wind = freezed,
    Object? dt = freezed,
    Object? timezone = freezed,
    Object? name = freezed,
  }) {
    return _then(
      _value.copyWith(
            weather:
                freezed == weather
                    ? _value.weather
                    : weather // ignore: cast_nullable_to_non_nullable
                        as List<WeatherInfo>?,
            main:
                freezed == main
                    ? _value.main
                    : main // ignore: cast_nullable_to_non_nullable
                        as WeatherMain?,
            visibility:
                freezed == visibility
                    ? _value.visibility
                    : visibility // ignore: cast_nullable_to_non_nullable
                        as int?,
            wind:
                freezed == wind
                    ? _value.wind
                    : wind // ignore: cast_nullable_to_non_nullable
                        as WeatherWind?,
            dt:
                freezed == dt
                    ? _value.dt
                    : dt // ignore: cast_nullable_to_non_nullable
                        as int?,
            timezone:
                freezed == timezone
                    ? _value.timezone
                    : timezone // ignore: cast_nullable_to_non_nullable
                        as int?,
            name:
                freezed == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of CurrentWeather
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WeatherMainCopyWith<$Res>? get main {
    if (_value.main == null) {
      return null;
    }

    return $WeatherMainCopyWith<$Res>(_value.main!, (value) {
      return _then(_value.copyWith(main: value) as $Val);
    });
  }

  /// Create a copy of CurrentWeather
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WeatherWindCopyWith<$Res>? get wind {
    if (_value.wind == null) {
      return null;
    }

    return $WeatherWindCopyWith<$Res>(_value.wind!, (value) {
      return _then(_value.copyWith(wind: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CurrentWeatherImplCopyWith<$Res>
    implements $CurrentWeatherCopyWith<$Res> {
  factory _$$CurrentWeatherImplCopyWith(
    _$CurrentWeatherImpl value,
    $Res Function(_$CurrentWeatherImpl) then,
  ) = __$$CurrentWeatherImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<WeatherInfo>? weather,
    WeatherMain? main,
    int? visibility,
    WeatherWind? wind,
    int? dt,
    int? timezone,
    String? name,
  });

  @override
  $WeatherMainCopyWith<$Res>? get main;
  @override
  $WeatherWindCopyWith<$Res>? get wind;
}

/// @nodoc
class __$$CurrentWeatherImplCopyWithImpl<$Res>
    extends _$CurrentWeatherCopyWithImpl<$Res, _$CurrentWeatherImpl>
    implements _$$CurrentWeatherImplCopyWith<$Res> {
  __$$CurrentWeatherImplCopyWithImpl(
    _$CurrentWeatherImpl _value,
    $Res Function(_$CurrentWeatherImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CurrentWeather
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weather = freezed,
    Object? main = freezed,
    Object? visibility = freezed,
    Object? wind = freezed,
    Object? dt = freezed,
    Object? timezone = freezed,
    Object? name = freezed,
  }) {
    return _then(
      _$CurrentWeatherImpl(
        weather:
            freezed == weather
                ? _value._weather
                : weather // ignore: cast_nullable_to_non_nullable
                    as List<WeatherInfo>?,
        main:
            freezed == main
                ? _value.main
                : main // ignore: cast_nullable_to_non_nullable
                    as WeatherMain?,
        visibility:
            freezed == visibility
                ? _value.visibility
                : visibility // ignore: cast_nullable_to_non_nullable
                    as int?,
        wind:
            freezed == wind
                ? _value.wind
                : wind // ignore: cast_nullable_to_non_nullable
                    as WeatherWind?,
        dt:
            freezed == dt
                ? _value.dt
                : dt // ignore: cast_nullable_to_non_nullable
                    as int?,
        timezone:
            freezed == timezone
                ? _value.timezone
                : timezone // ignore: cast_nullable_to_non_nullable
                    as int?,
        name:
            freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CurrentWeatherImpl implements _CurrentWeather {
  const _$CurrentWeatherImpl({
    final List<WeatherInfo>? weather = const [],
    this.main,
    this.visibility,
    this.wind,
    this.dt,
    this.timezone,
    this.name,
  }) : _weather = weather;

  factory _$CurrentWeatherImpl.fromJson(Map<String, dynamic> json) =>
      _$$CurrentWeatherImplFromJson(json);

  final List<WeatherInfo>? _weather;
  @override
  @JsonKey()
  List<WeatherInfo>? get weather {
    final value = _weather;
    if (value == null) return null;
    if (_weather is EqualUnmodifiableListView) return _weather;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final WeatherMain? main;
  @override
  final int? visibility;
  @override
  final WeatherWind? wind;
  @override
  final int? dt;
  @override
  final int? timezone;
  @override
  final String? name;

  @override
  String toString() {
    return 'CurrentWeather(weather: $weather, main: $main, visibility: $visibility, wind: $wind, dt: $dt, timezone: $timezone, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CurrentWeatherImpl &&
            const DeepCollectionEquality().equals(other._weather, _weather) &&
            (identical(other.main, main) || other.main == main) &&
            (identical(other.visibility, visibility) ||
                other.visibility == visibility) &&
            (identical(other.wind, wind) || other.wind == wind) &&
            (identical(other.dt, dt) || other.dt == dt) &&
            (identical(other.timezone, timezone) ||
                other.timezone == timezone) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_weather),
    main,
    visibility,
    wind,
    dt,
    timezone,
    name,
  );

  /// Create a copy of CurrentWeather
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CurrentWeatherImplCopyWith<_$CurrentWeatherImpl> get copyWith =>
      __$$CurrentWeatherImplCopyWithImpl<_$CurrentWeatherImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CurrentWeatherImplToJson(this);
  }
}

abstract class _CurrentWeather implements CurrentWeather {
  const factory _CurrentWeather({
    final List<WeatherInfo>? weather,
    final WeatherMain? main,
    final int? visibility,
    final WeatherWind? wind,
    final int? dt,
    final int? timezone,
    final String? name,
  }) = _$CurrentWeatherImpl;

  factory _CurrentWeather.fromJson(Map<String, dynamic> json) =
      _$CurrentWeatherImpl.fromJson;

  @override
  List<WeatherInfo>? get weather;
  @override
  WeatherMain? get main;
  @override
  int? get visibility;
  @override
  WeatherWind? get wind;
  @override
  int? get dt;
  @override
  int? get timezone;
  @override
  String? get name;

  /// Create a copy of CurrentWeather
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CurrentWeatherImplCopyWith<_$CurrentWeatherImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WeatherInfo _$WeatherInfoFromJson(Map<String, dynamic> json) {
  return _WeatherInfo.fromJson(json);
}

/// @nodoc
mixin _$WeatherInfo {
  int? get id => throw _privateConstructorUsedError;
  String? get main => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get icon => throw _privateConstructorUsedError;

  /// Serializes this WeatherInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WeatherInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeatherInfoCopyWith<WeatherInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeatherInfoCopyWith<$Res> {
  factory $WeatherInfoCopyWith(
    WeatherInfo value,
    $Res Function(WeatherInfo) then,
  ) = _$WeatherInfoCopyWithImpl<$Res, WeatherInfo>;
  @useResult
  $Res call({int? id, String? main, String? description, String? icon});
}

/// @nodoc
class _$WeatherInfoCopyWithImpl<$Res, $Val extends WeatherInfo>
    implements $WeatherInfoCopyWith<$Res> {
  _$WeatherInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeatherInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? main = freezed,
    Object? description = freezed,
    Object? icon = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int?,
            main:
                freezed == main
                    ? _value.main
                    : main // ignore: cast_nullable_to_non_nullable
                        as String?,
            description:
                freezed == description
                    ? _value.description
                    : description // ignore: cast_nullable_to_non_nullable
                        as String?,
            icon:
                freezed == icon
                    ? _value.icon
                    : icon // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WeatherInfoImplCopyWith<$Res>
    implements $WeatherInfoCopyWith<$Res> {
  factory _$$WeatherInfoImplCopyWith(
    _$WeatherInfoImpl value,
    $Res Function(_$WeatherInfoImpl) then,
  ) = __$$WeatherInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int? id, String? main, String? description, String? icon});
}

/// @nodoc
class __$$WeatherInfoImplCopyWithImpl<$Res>
    extends _$WeatherInfoCopyWithImpl<$Res, _$WeatherInfoImpl>
    implements _$$WeatherInfoImplCopyWith<$Res> {
  __$$WeatherInfoImplCopyWithImpl(
    _$WeatherInfoImpl _value,
    $Res Function(_$WeatherInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WeatherInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? main = freezed,
    Object? description = freezed,
    Object? icon = freezed,
  }) {
    return _then(
      _$WeatherInfoImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int?,
        main:
            freezed == main
                ? _value.main
                : main // ignore: cast_nullable_to_non_nullable
                    as String?,
        description:
            freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                    as String?,
        icon:
            freezed == icon
                ? _value.icon
                : icon // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WeatherInfoImpl implements _WeatherInfo {
  const _$WeatherInfoImpl({this.id, this.main, this.description, this.icon});

  factory _$WeatherInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeatherInfoImplFromJson(json);

  @override
  final int? id;
  @override
  final String? main;
  @override
  final String? description;
  @override
  final String? icon;

  @override
  String toString() {
    return 'WeatherInfo(id: $id, main: $main, description: $description, icon: $icon)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeatherInfoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.main, main) || other.main == main) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.icon, icon) || other.icon == icon));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, main, description, icon);

  /// Create a copy of WeatherInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeatherInfoImplCopyWith<_$WeatherInfoImpl> get copyWith =>
      __$$WeatherInfoImplCopyWithImpl<_$WeatherInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WeatherInfoImplToJson(this);
  }
}

abstract class _WeatherInfo implements WeatherInfo {
  const factory _WeatherInfo({
    final int? id,
    final String? main,
    final String? description,
    final String? icon,
  }) = _$WeatherInfoImpl;

  factory _WeatherInfo.fromJson(Map<String, dynamic> json) =
      _$WeatherInfoImpl.fromJson;

  @override
  int? get id;
  @override
  String? get main;
  @override
  String? get description;
  @override
  String? get icon;

  /// Create a copy of WeatherInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeatherInfoImplCopyWith<_$WeatherInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WeatherMain _$WeatherMainFromJson(Map<String, dynamic> json) {
  return _WeatherMain.fromJson(json);
}

/// @nodoc
mixin _$WeatherMain {
  double? get temp => throw _privateConstructorUsedError;
  double? get feels_like => throw _privateConstructorUsedError;
  double? get temp_min => throw _privateConstructorUsedError;
  double? get temp_max => throw _privateConstructorUsedError;
  int? get pressure => throw _privateConstructorUsedError;
  int? get humidity => throw _privateConstructorUsedError;

  /// Serializes this WeatherMain to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WeatherMain
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeatherMainCopyWith<WeatherMain> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeatherMainCopyWith<$Res> {
  factory $WeatherMainCopyWith(
    WeatherMain value,
    $Res Function(WeatherMain) then,
  ) = _$WeatherMainCopyWithImpl<$Res, WeatherMain>;
  @useResult
  $Res call({
    double? temp,
    double? feels_like,
    double? temp_min,
    double? temp_max,
    int? pressure,
    int? humidity,
  });
}

/// @nodoc
class _$WeatherMainCopyWithImpl<$Res, $Val extends WeatherMain>
    implements $WeatherMainCopyWith<$Res> {
  _$WeatherMainCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeatherMain
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? temp = freezed,
    Object? feels_like = freezed,
    Object? temp_min = freezed,
    Object? temp_max = freezed,
    Object? pressure = freezed,
    Object? humidity = freezed,
  }) {
    return _then(
      _value.copyWith(
            temp:
                freezed == temp
                    ? _value.temp
                    : temp // ignore: cast_nullable_to_non_nullable
                        as double?,
            feels_like:
                freezed == feels_like
                    ? _value.feels_like
                    : feels_like // ignore: cast_nullable_to_non_nullable
                        as double?,
            temp_min:
                freezed == temp_min
                    ? _value.temp_min
                    : temp_min // ignore: cast_nullable_to_non_nullable
                        as double?,
            temp_max:
                freezed == temp_max
                    ? _value.temp_max
                    : temp_max // ignore: cast_nullable_to_non_nullable
                        as double?,
            pressure:
                freezed == pressure
                    ? _value.pressure
                    : pressure // ignore: cast_nullable_to_non_nullable
                        as int?,
            humidity:
                freezed == humidity
                    ? _value.humidity
                    : humidity // ignore: cast_nullable_to_non_nullable
                        as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WeatherMainImplCopyWith<$Res>
    implements $WeatherMainCopyWith<$Res> {
  factory _$$WeatherMainImplCopyWith(
    _$WeatherMainImpl value,
    $Res Function(_$WeatherMainImpl) then,
  ) = __$$WeatherMainImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double? temp,
    double? feels_like,
    double? temp_min,
    double? temp_max,
    int? pressure,
    int? humidity,
  });
}

/// @nodoc
class __$$WeatherMainImplCopyWithImpl<$Res>
    extends _$WeatherMainCopyWithImpl<$Res, _$WeatherMainImpl>
    implements _$$WeatherMainImplCopyWith<$Res> {
  __$$WeatherMainImplCopyWithImpl(
    _$WeatherMainImpl _value,
    $Res Function(_$WeatherMainImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WeatherMain
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? temp = freezed,
    Object? feels_like = freezed,
    Object? temp_min = freezed,
    Object? temp_max = freezed,
    Object? pressure = freezed,
    Object? humidity = freezed,
  }) {
    return _then(
      _$WeatherMainImpl(
        temp:
            freezed == temp
                ? _value.temp
                : temp // ignore: cast_nullable_to_non_nullable
                    as double?,
        feels_like:
            freezed == feels_like
                ? _value.feels_like
                : feels_like // ignore: cast_nullable_to_non_nullable
                    as double?,
        temp_min:
            freezed == temp_min
                ? _value.temp_min
                : temp_min // ignore: cast_nullable_to_non_nullable
                    as double?,
        temp_max:
            freezed == temp_max
                ? _value.temp_max
                : temp_max // ignore: cast_nullable_to_non_nullable
                    as double?,
        pressure:
            freezed == pressure
                ? _value.pressure
                : pressure // ignore: cast_nullable_to_non_nullable
                    as int?,
        humidity:
            freezed == humidity
                ? _value.humidity
                : humidity // ignore: cast_nullable_to_non_nullable
                    as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WeatherMainImpl implements _WeatherMain {
  const _$WeatherMainImpl({
    this.temp,
    this.feels_like,
    this.temp_min,
    this.temp_max,
    this.pressure,
    this.humidity,
  });

  factory _$WeatherMainImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeatherMainImplFromJson(json);

  @override
  final double? temp;
  @override
  final double? feels_like;
  @override
  final double? temp_min;
  @override
  final double? temp_max;
  @override
  final int? pressure;
  @override
  final int? humidity;

  @override
  String toString() {
    return 'WeatherMain(temp: $temp, feels_like: $feels_like, temp_min: $temp_min, temp_max: $temp_max, pressure: $pressure, humidity: $humidity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeatherMainImpl &&
            (identical(other.temp, temp) || other.temp == temp) &&
            (identical(other.feels_like, feels_like) ||
                other.feels_like == feels_like) &&
            (identical(other.temp_min, temp_min) ||
                other.temp_min == temp_min) &&
            (identical(other.temp_max, temp_max) ||
                other.temp_max == temp_max) &&
            (identical(other.pressure, pressure) ||
                other.pressure == pressure) &&
            (identical(other.humidity, humidity) ||
                other.humidity == humidity));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    temp,
    feels_like,
    temp_min,
    temp_max,
    pressure,
    humidity,
  );

  /// Create a copy of WeatherMain
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeatherMainImplCopyWith<_$WeatherMainImpl> get copyWith =>
      __$$WeatherMainImplCopyWithImpl<_$WeatherMainImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WeatherMainImplToJson(this);
  }
}

abstract class _WeatherMain implements WeatherMain {
  const factory _WeatherMain({
    final double? temp,
    final double? feels_like,
    final double? temp_min,
    final double? temp_max,
    final int? pressure,
    final int? humidity,
  }) = _$WeatherMainImpl;

  factory _WeatherMain.fromJson(Map<String, dynamic> json) =
      _$WeatherMainImpl.fromJson;

  @override
  double? get temp;
  @override
  double? get feels_like;
  @override
  double? get temp_min;
  @override
  double? get temp_max;
  @override
  int? get pressure;
  @override
  int? get humidity;

  /// Create a copy of WeatherMain
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeatherMainImplCopyWith<_$WeatherMainImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WeatherWind _$WeatherWindFromJson(Map<String, dynamic> json) {
  return _WeatherWind.fromJson(json);
}

/// @nodoc
mixin _$WeatherWind {
  double? get speed => throw _privateConstructorUsedError;
  int? get deg => throw _privateConstructorUsedError;

  /// Serializes this WeatherWind to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WeatherWind
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeatherWindCopyWith<WeatherWind> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeatherWindCopyWith<$Res> {
  factory $WeatherWindCopyWith(
    WeatherWind value,
    $Res Function(WeatherWind) then,
  ) = _$WeatherWindCopyWithImpl<$Res, WeatherWind>;
  @useResult
  $Res call({double? speed, int? deg});
}

/// @nodoc
class _$WeatherWindCopyWithImpl<$Res, $Val extends WeatherWind>
    implements $WeatherWindCopyWith<$Res> {
  _$WeatherWindCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeatherWind
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? speed = freezed, Object? deg = freezed}) {
    return _then(
      _value.copyWith(
            speed:
                freezed == speed
                    ? _value.speed
                    : speed // ignore: cast_nullable_to_non_nullable
                        as double?,
            deg:
                freezed == deg
                    ? _value.deg
                    : deg // ignore: cast_nullable_to_non_nullable
                        as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WeatherWindImplCopyWith<$Res>
    implements $WeatherWindCopyWith<$Res> {
  factory _$$WeatherWindImplCopyWith(
    _$WeatherWindImpl value,
    $Res Function(_$WeatherWindImpl) then,
  ) = __$$WeatherWindImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double? speed, int? deg});
}

/// @nodoc
class __$$WeatherWindImplCopyWithImpl<$Res>
    extends _$WeatherWindCopyWithImpl<$Res, _$WeatherWindImpl>
    implements _$$WeatherWindImplCopyWith<$Res> {
  __$$WeatherWindImplCopyWithImpl(
    _$WeatherWindImpl _value,
    $Res Function(_$WeatherWindImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WeatherWind
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? speed = freezed, Object? deg = freezed}) {
    return _then(
      _$WeatherWindImpl(
        speed:
            freezed == speed
                ? _value.speed
                : speed // ignore: cast_nullable_to_non_nullable
                    as double?,
        deg:
            freezed == deg
                ? _value.deg
                : deg // ignore: cast_nullable_to_non_nullable
                    as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WeatherWindImpl implements _WeatherWind {
  const _$WeatherWindImpl({this.speed, this.deg});

  factory _$WeatherWindImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeatherWindImplFromJson(json);

  @override
  final double? speed;
  @override
  final int? deg;

  @override
  String toString() {
    return 'WeatherWind(speed: $speed, deg: $deg)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeatherWindImpl &&
            (identical(other.speed, speed) || other.speed == speed) &&
            (identical(other.deg, deg) || other.deg == deg));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, speed, deg);

  /// Create a copy of WeatherWind
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeatherWindImplCopyWith<_$WeatherWindImpl> get copyWith =>
      __$$WeatherWindImplCopyWithImpl<_$WeatherWindImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WeatherWindImplToJson(this);
  }
}

abstract class _WeatherWind implements WeatherWind {
  const factory _WeatherWind({final double? speed, final int? deg}) =
      _$WeatherWindImpl;

  factory _WeatherWind.fromJson(Map<String, dynamic> json) =
      _$WeatherWindImpl.fromJson;

  @override
  double? get speed;
  @override
  int? get deg;

  /// Create a copy of WeatherWind
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeatherWindImplCopyWith<_$WeatherWindImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WeatherForecast _$WeatherForecastFromJson(Map<String, dynamic> json) {
  return _WeatherForecast.fromJson(json);
}

/// @nodoc
mixin _$WeatherForecast {
  HourlyUnits? get hourlyUnits => throw _privateConstructorUsedError;
  HourlyData? get hourly => throw _privateConstructorUsedError;
  DailyUnits? get dailyUnits => throw _privateConstructorUsedError;
  DailyData? get daily => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  @JsonKey(name: 'generationtimeMs')
  double? get generationtimeMs => throw _privateConstructorUsedError; // Keep JsonKey for case difference
  int? get utcOffsetSeconds => throw _privateConstructorUsedError;
  String? get timezone =>
      throw _privateConstructorUsedError; // IANA Timezone Name (e.g., "America/Costa_Rica")
  String? get timezoneAbbreviation =>
      throw _privateConstructorUsedError; // e.g., "GMT-6"
  double? get elevation => throw _privateConstructorUsedError;

  /// Serializes this WeatherForecast to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WeatherForecast
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeatherForecastCopyWith<WeatherForecast> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeatherForecastCopyWith<$Res> {
  factory $WeatherForecastCopyWith(
    WeatherForecast value,
    $Res Function(WeatherForecast) then,
  ) = _$WeatherForecastCopyWithImpl<$Res, WeatherForecast>;
  @useResult
  $Res call({
    HourlyUnits? hourlyUnits,
    HourlyData? hourly,
    DailyUnits? dailyUnits,
    DailyData? daily,
    double? latitude,
    double? longitude,
    @JsonKey(name: 'generationtimeMs') double? generationtimeMs,
    int? utcOffsetSeconds,
    String? timezone,
    String? timezoneAbbreviation,
    double? elevation,
  });

  $HourlyUnitsCopyWith<$Res>? get hourlyUnits;
  $HourlyDataCopyWith<$Res>? get hourly;
  $DailyUnitsCopyWith<$Res>? get dailyUnits;
  $DailyDataCopyWith<$Res>? get daily;
}

/// @nodoc
class _$WeatherForecastCopyWithImpl<$Res, $Val extends WeatherForecast>
    implements $WeatherForecastCopyWith<$Res> {
  _$WeatherForecastCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeatherForecast
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hourlyUnits = freezed,
    Object? hourly = freezed,
    Object? dailyUnits = freezed,
    Object? daily = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? generationtimeMs = freezed,
    Object? utcOffsetSeconds = freezed,
    Object? timezone = freezed,
    Object? timezoneAbbreviation = freezed,
    Object? elevation = freezed,
  }) {
    return _then(
      _value.copyWith(
            hourlyUnits:
                freezed == hourlyUnits
                    ? _value.hourlyUnits
                    : hourlyUnits // ignore: cast_nullable_to_non_nullable
                        as HourlyUnits?,
            hourly:
                freezed == hourly
                    ? _value.hourly
                    : hourly // ignore: cast_nullable_to_non_nullable
                        as HourlyData?,
            dailyUnits:
                freezed == dailyUnits
                    ? _value.dailyUnits
                    : dailyUnits // ignore: cast_nullable_to_non_nullable
                        as DailyUnits?,
            daily:
                freezed == daily
                    ? _value.daily
                    : daily // ignore: cast_nullable_to_non_nullable
                        as DailyData?,
            latitude:
                freezed == latitude
                    ? _value.latitude
                    : latitude // ignore: cast_nullable_to_non_nullable
                        as double?,
            longitude:
                freezed == longitude
                    ? _value.longitude
                    : longitude // ignore: cast_nullable_to_non_nullable
                        as double?,
            generationtimeMs:
                freezed == generationtimeMs
                    ? _value.generationtimeMs
                    : generationtimeMs // ignore: cast_nullable_to_non_nullable
                        as double?,
            utcOffsetSeconds:
                freezed == utcOffsetSeconds
                    ? _value.utcOffsetSeconds
                    : utcOffsetSeconds // ignore: cast_nullable_to_non_nullable
                        as int?,
            timezone:
                freezed == timezone
                    ? _value.timezone
                    : timezone // ignore: cast_nullable_to_non_nullable
                        as String?,
            timezoneAbbreviation:
                freezed == timezoneAbbreviation
                    ? _value.timezoneAbbreviation
                    : timezoneAbbreviation // ignore: cast_nullable_to_non_nullable
                        as String?,
            elevation:
                freezed == elevation
                    ? _value.elevation
                    : elevation // ignore: cast_nullable_to_non_nullable
                        as double?,
          )
          as $Val,
    );
  }

  /// Create a copy of WeatherForecast
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $HourlyUnitsCopyWith<$Res>? get hourlyUnits {
    if (_value.hourlyUnits == null) {
      return null;
    }

    return $HourlyUnitsCopyWith<$Res>(_value.hourlyUnits!, (value) {
      return _then(_value.copyWith(hourlyUnits: value) as $Val);
    });
  }

  /// Create a copy of WeatherForecast
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $HourlyDataCopyWith<$Res>? get hourly {
    if (_value.hourly == null) {
      return null;
    }

    return $HourlyDataCopyWith<$Res>(_value.hourly!, (value) {
      return _then(_value.copyWith(hourly: value) as $Val);
    });
  }

  /// Create a copy of WeatherForecast
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DailyUnitsCopyWith<$Res>? get dailyUnits {
    if (_value.dailyUnits == null) {
      return null;
    }

    return $DailyUnitsCopyWith<$Res>(_value.dailyUnits!, (value) {
      return _then(_value.copyWith(dailyUnits: value) as $Val);
    });
  }

  /// Create a copy of WeatherForecast
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DailyDataCopyWith<$Res>? get daily {
    if (_value.daily == null) {
      return null;
    }

    return $DailyDataCopyWith<$Res>(_value.daily!, (value) {
      return _then(_value.copyWith(daily: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$WeatherForecastImplCopyWith<$Res>
    implements $WeatherForecastCopyWith<$Res> {
  factory _$$WeatherForecastImplCopyWith(
    _$WeatherForecastImpl value,
    $Res Function(_$WeatherForecastImpl) then,
  ) = __$$WeatherForecastImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    HourlyUnits? hourlyUnits,
    HourlyData? hourly,
    DailyUnits? dailyUnits,
    DailyData? daily,
    double? latitude,
    double? longitude,
    @JsonKey(name: 'generationtimeMs') double? generationtimeMs,
    int? utcOffsetSeconds,
    String? timezone,
    String? timezoneAbbreviation,
    double? elevation,
  });

  @override
  $HourlyUnitsCopyWith<$Res>? get hourlyUnits;
  @override
  $HourlyDataCopyWith<$Res>? get hourly;
  @override
  $DailyUnitsCopyWith<$Res>? get dailyUnits;
  @override
  $DailyDataCopyWith<$Res>? get daily;
}

/// @nodoc
class __$$WeatherForecastImplCopyWithImpl<$Res>
    extends _$WeatherForecastCopyWithImpl<$Res, _$WeatherForecastImpl>
    implements _$$WeatherForecastImplCopyWith<$Res> {
  __$$WeatherForecastImplCopyWithImpl(
    _$WeatherForecastImpl _value,
    $Res Function(_$WeatherForecastImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WeatherForecast
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hourlyUnits = freezed,
    Object? hourly = freezed,
    Object? dailyUnits = freezed,
    Object? daily = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? generationtimeMs = freezed,
    Object? utcOffsetSeconds = freezed,
    Object? timezone = freezed,
    Object? timezoneAbbreviation = freezed,
    Object? elevation = freezed,
  }) {
    return _then(
      _$WeatherForecastImpl(
        hourlyUnits:
            freezed == hourlyUnits
                ? _value.hourlyUnits
                : hourlyUnits // ignore: cast_nullable_to_non_nullable
                    as HourlyUnits?,
        hourly:
            freezed == hourly
                ? _value.hourly
                : hourly // ignore: cast_nullable_to_non_nullable
                    as HourlyData?,
        dailyUnits:
            freezed == dailyUnits
                ? _value.dailyUnits
                : dailyUnits // ignore: cast_nullable_to_non_nullable
                    as DailyUnits?,
        daily:
            freezed == daily
                ? _value.daily
                : daily // ignore: cast_nullable_to_non_nullable
                    as DailyData?,
        latitude:
            freezed == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                    as double?,
        longitude:
            freezed == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                    as double?,
        generationtimeMs:
            freezed == generationtimeMs
                ? _value.generationtimeMs
                : generationtimeMs // ignore: cast_nullable_to_non_nullable
                    as double?,
        utcOffsetSeconds:
            freezed == utcOffsetSeconds
                ? _value.utcOffsetSeconds
                : utcOffsetSeconds // ignore: cast_nullable_to_non_nullable
                    as int?,
        timezone:
            freezed == timezone
                ? _value.timezone
                : timezone // ignore: cast_nullable_to_non_nullable
                    as String?,
        timezoneAbbreviation:
            freezed == timezoneAbbreviation
                ? _value.timezoneAbbreviation
                : timezoneAbbreviation // ignore: cast_nullable_to_non_nullable
                    as String?,
        elevation:
            freezed == elevation
                ? _value.elevation
                : elevation // ignore: cast_nullable_to_non_nullable
                    as double?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WeatherForecastImpl implements _WeatherForecast {
  const _$WeatherForecastImpl({
    this.hourlyUnits,
    this.hourly,
    this.dailyUnits,
    this.daily,
    this.latitude,
    this.longitude,
    @JsonKey(name: 'generationtimeMs') this.generationtimeMs,
    this.utcOffsetSeconds,
    this.timezone,
    this.timezoneAbbreviation,
    this.elevation,
  });

  factory _$WeatherForecastImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeatherForecastImplFromJson(json);

  @override
  final HourlyUnits? hourlyUnits;
  @override
  final HourlyData? hourly;
  @override
  final DailyUnits? dailyUnits;
  @override
  final DailyData? daily;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  @JsonKey(name: 'generationtimeMs')
  final double? generationtimeMs;
  // Keep JsonKey for case difference
  @override
  final int? utcOffsetSeconds;
  @override
  final String? timezone;
  // IANA Timezone Name (e.g., "America/Costa_Rica")
  @override
  final String? timezoneAbbreviation;
  // e.g., "GMT-6"
  @override
  final double? elevation;

  @override
  String toString() {
    return 'WeatherForecast(hourlyUnits: $hourlyUnits, hourly: $hourly, dailyUnits: $dailyUnits, daily: $daily, latitude: $latitude, longitude: $longitude, generationtimeMs: $generationtimeMs, utcOffsetSeconds: $utcOffsetSeconds, timezone: $timezone, timezoneAbbreviation: $timezoneAbbreviation, elevation: $elevation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeatherForecastImpl &&
            (identical(other.hourlyUnits, hourlyUnits) ||
                other.hourlyUnits == hourlyUnits) &&
            (identical(other.hourly, hourly) || other.hourly == hourly) &&
            (identical(other.dailyUnits, dailyUnits) ||
                other.dailyUnits == dailyUnits) &&
            (identical(other.daily, daily) || other.daily == daily) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.generationtimeMs, generationtimeMs) ||
                other.generationtimeMs == generationtimeMs) &&
            (identical(other.utcOffsetSeconds, utcOffsetSeconds) ||
                other.utcOffsetSeconds == utcOffsetSeconds) &&
            (identical(other.timezone, timezone) ||
                other.timezone == timezone) &&
            (identical(other.timezoneAbbreviation, timezoneAbbreviation) ||
                other.timezoneAbbreviation == timezoneAbbreviation) &&
            (identical(other.elevation, elevation) ||
                other.elevation == elevation));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    hourlyUnits,
    hourly,
    dailyUnits,
    daily,
    latitude,
    longitude,
    generationtimeMs,
    utcOffsetSeconds,
    timezone,
    timezoneAbbreviation,
    elevation,
  );

  /// Create a copy of WeatherForecast
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeatherForecastImplCopyWith<_$WeatherForecastImpl> get copyWith =>
      __$$WeatherForecastImplCopyWithImpl<_$WeatherForecastImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WeatherForecastImplToJson(this);
  }
}

abstract class _WeatherForecast implements WeatherForecast {
  const factory _WeatherForecast({
    final HourlyUnits? hourlyUnits,
    final HourlyData? hourly,
    final DailyUnits? dailyUnits,
    final DailyData? daily,
    final double? latitude,
    final double? longitude,
    @JsonKey(name: 'generationtimeMs') final double? generationtimeMs,
    final int? utcOffsetSeconds,
    final String? timezone,
    final String? timezoneAbbreviation,
    final double? elevation,
  }) = _$WeatherForecastImpl;

  factory _WeatherForecast.fromJson(Map<String, dynamic> json) =
      _$WeatherForecastImpl.fromJson;

  @override
  HourlyUnits? get hourlyUnits;
  @override
  HourlyData? get hourly;
  @override
  DailyUnits? get dailyUnits;
  @override
  DailyData? get daily;
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  @JsonKey(name: 'generationtimeMs')
  double? get generationtimeMs; // Keep JsonKey for case difference
  @override
  int? get utcOffsetSeconds;
  @override
  String? get timezone; // IANA Timezone Name (e.g., "America/Costa_Rica")
  @override
  String? get timezoneAbbreviation; // e.g., "GMT-6"
  @override
  double? get elevation;

  /// Create a copy of WeatherForecast
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeatherForecastImplCopyWith<_$WeatherForecastImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HourlyUnits _$HourlyUnitsFromJson(Map<String, dynamic> json) {
  return _HourlyUnits.fromJson(json);
}

/// @nodoc
mixin _$HourlyUnits {
  String? get temperature => throw _privateConstructorUsedError;
  String? get time => throw _privateConstructorUsedError;

  /// Serializes this HourlyUnits to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HourlyUnits
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HourlyUnitsCopyWith<HourlyUnits> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HourlyUnitsCopyWith<$Res> {
  factory $HourlyUnitsCopyWith(
    HourlyUnits value,
    $Res Function(HourlyUnits) then,
  ) = _$HourlyUnitsCopyWithImpl<$Res, HourlyUnits>;
  @useResult
  $Res call({String? temperature, String? time});
}

/// @nodoc
class _$HourlyUnitsCopyWithImpl<$Res, $Val extends HourlyUnits>
    implements $HourlyUnitsCopyWith<$Res> {
  _$HourlyUnitsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HourlyUnits
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? temperature = freezed, Object? time = freezed}) {
    return _then(
      _value.copyWith(
            temperature:
                freezed == temperature
                    ? _value.temperature
                    : temperature // ignore: cast_nullable_to_non_nullable
                        as String?,
            time:
                freezed == time
                    ? _value.time
                    : time // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$HourlyUnitsImplCopyWith<$Res>
    implements $HourlyUnitsCopyWith<$Res> {
  factory _$$HourlyUnitsImplCopyWith(
    _$HourlyUnitsImpl value,
    $Res Function(_$HourlyUnitsImpl) then,
  ) = __$$HourlyUnitsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? temperature, String? time});
}

/// @nodoc
class __$$HourlyUnitsImplCopyWithImpl<$Res>
    extends _$HourlyUnitsCopyWithImpl<$Res, _$HourlyUnitsImpl>
    implements _$$HourlyUnitsImplCopyWith<$Res> {
  __$$HourlyUnitsImplCopyWithImpl(
    _$HourlyUnitsImpl _value,
    $Res Function(_$HourlyUnitsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HourlyUnits
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? temperature = freezed, Object? time = freezed}) {
    return _then(
      _$HourlyUnitsImpl(
        temperature:
            freezed == temperature
                ? _value.temperature
                : temperature // ignore: cast_nullable_to_non_nullable
                    as String?,
        time:
            freezed == time
                ? _value.time
                : time // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$HourlyUnitsImpl implements _HourlyUnits {
  const _$HourlyUnitsImpl({this.temperature, this.time});

  factory _$HourlyUnitsImpl.fromJson(Map<String, dynamic> json) =>
      _$$HourlyUnitsImplFromJson(json);

  @override
  final String? temperature;
  @override
  final String? time;

  @override
  String toString() {
    return 'HourlyUnits(temperature: $temperature, time: $time)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HourlyUnitsImpl &&
            (identical(other.temperature, temperature) ||
                other.temperature == temperature) &&
            (identical(other.time, time) || other.time == time));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, temperature, time);

  /// Create a copy of HourlyUnits
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HourlyUnitsImplCopyWith<_$HourlyUnitsImpl> get copyWith =>
      __$$HourlyUnitsImplCopyWithImpl<_$HourlyUnitsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HourlyUnitsImplToJson(this);
  }
}

abstract class _HourlyUnits implements HourlyUnits {
  const factory _HourlyUnits({final String? temperature, final String? time}) =
      _$HourlyUnitsImpl;

  factory _HourlyUnits.fromJson(Map<String, dynamic> json) =
      _$HourlyUnitsImpl.fromJson;

  @override
  String? get temperature;
  @override
  String? get time;

  /// Create a copy of HourlyUnits
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HourlyUnitsImplCopyWith<_$HourlyUnitsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HourlyData _$HourlyDataFromJson(Map<String, dynamic> json) {
  return _HourlyData.fromJson(json);
}

/// @nodoc
mixin _$HourlyData {
  List<String>? get time => throw _privateConstructorUsedError;
  @JsonKey(name: 'temperature2m')
  List<double>? get temperature2m => throw _privateConstructorUsedError;
  List<int>? get isDay => throw _privateConstructorUsedError;
  List<double>? get sunshineDuration => throw _privateConstructorUsedError;
  List<int>? get weathercode => throw _privateConstructorUsedError;
  @JsonKey(name: 'precipitationProbability')
  List<int>? get precipitationProbability => throw _privateConstructorUsedError;

  /// Serializes this HourlyData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HourlyData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HourlyDataCopyWith<HourlyData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HourlyDataCopyWith<$Res> {
  factory $HourlyDataCopyWith(
    HourlyData value,
    $Res Function(HourlyData) then,
  ) = _$HourlyDataCopyWithImpl<$Res, HourlyData>;
  @useResult
  $Res call({
    List<String>? time,
    @JsonKey(name: 'temperature2m') List<double>? temperature2m,
    List<int>? isDay,
    List<double>? sunshineDuration,
    List<int>? weathercode,
    @JsonKey(name: 'precipitationProbability')
    List<int>? precipitationProbability,
  });
}

/// @nodoc
class _$HourlyDataCopyWithImpl<$Res, $Val extends HourlyData>
    implements $HourlyDataCopyWith<$Res> {
  _$HourlyDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HourlyData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? time = freezed,
    Object? temperature2m = freezed,
    Object? isDay = freezed,
    Object? sunshineDuration = freezed,
    Object? weathercode = freezed,
    Object? precipitationProbability = freezed,
  }) {
    return _then(
      _value.copyWith(
            time:
                freezed == time
                    ? _value.time
                    : time // ignore: cast_nullable_to_non_nullable
                        as List<String>?,
            temperature2m:
                freezed == temperature2m
                    ? _value.temperature2m
                    : temperature2m // ignore: cast_nullable_to_non_nullable
                        as List<double>?,
            isDay:
                freezed == isDay
                    ? _value.isDay
                    : isDay // ignore: cast_nullable_to_non_nullable
                        as List<int>?,
            sunshineDuration:
                freezed == sunshineDuration
                    ? _value.sunshineDuration
                    : sunshineDuration // ignore: cast_nullable_to_non_nullable
                        as List<double>?,
            weathercode:
                freezed == weathercode
                    ? _value.weathercode
                    : weathercode // ignore: cast_nullable_to_non_nullable
                        as List<int>?,
            precipitationProbability:
                freezed == precipitationProbability
                    ? _value.precipitationProbability
                    : precipitationProbability // ignore: cast_nullable_to_non_nullable
                        as List<int>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$HourlyDataImplCopyWith<$Res>
    implements $HourlyDataCopyWith<$Res> {
  factory _$$HourlyDataImplCopyWith(
    _$HourlyDataImpl value,
    $Res Function(_$HourlyDataImpl) then,
  ) = __$$HourlyDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<String>? time,
    @JsonKey(name: 'temperature2m') List<double>? temperature2m,
    List<int>? isDay,
    List<double>? sunshineDuration,
    List<int>? weathercode,
    @JsonKey(name: 'precipitationProbability')
    List<int>? precipitationProbability,
  });
}

/// @nodoc
class __$$HourlyDataImplCopyWithImpl<$Res>
    extends _$HourlyDataCopyWithImpl<$Res, _$HourlyDataImpl>
    implements _$$HourlyDataImplCopyWith<$Res> {
  __$$HourlyDataImplCopyWithImpl(
    _$HourlyDataImpl _value,
    $Res Function(_$HourlyDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HourlyData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? time = freezed,
    Object? temperature2m = freezed,
    Object? isDay = freezed,
    Object? sunshineDuration = freezed,
    Object? weathercode = freezed,
    Object? precipitationProbability = freezed,
  }) {
    return _then(
      _$HourlyDataImpl(
        time:
            freezed == time
                ? _value._time
                : time // ignore: cast_nullable_to_non_nullable
                    as List<String>?,
        temperature2m:
            freezed == temperature2m
                ? _value._temperature2m
                : temperature2m // ignore: cast_nullable_to_non_nullable
                    as List<double>?,
        isDay:
            freezed == isDay
                ? _value._isDay
                : isDay // ignore: cast_nullable_to_non_nullable
                    as List<int>?,
        sunshineDuration:
            freezed == sunshineDuration
                ? _value._sunshineDuration
                : sunshineDuration // ignore: cast_nullable_to_non_nullable
                    as List<double>?,
        weathercode:
            freezed == weathercode
                ? _value._weathercode
                : weathercode // ignore: cast_nullable_to_non_nullable
                    as List<int>?,
        precipitationProbability:
            freezed == precipitationProbability
                ? _value._precipitationProbability
                : precipitationProbability // ignore: cast_nullable_to_non_nullable
                    as List<int>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$HourlyDataImpl implements _HourlyData {
  const _$HourlyDataImpl({
    final List<String>? time,
    @JsonKey(name: 'temperature2m') final List<double>? temperature2m,
    final List<int>? isDay,
    final List<double>? sunshineDuration,
    final List<int>? weathercode,
    @JsonKey(name: 'precipitationProbability')
    final List<int>? precipitationProbability,
  }) : _time = time,
       _temperature2m = temperature2m,
       _isDay = isDay,
       _sunshineDuration = sunshineDuration,
       _weathercode = weathercode,
       _precipitationProbability = precipitationProbability;

  factory _$HourlyDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$HourlyDataImplFromJson(json);

  final List<String>? _time;
  @override
  List<String>? get time {
    final value = _time;
    if (value == null) return null;
    if (_time is EqualUnmodifiableListView) return _time;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<double>? _temperature2m;
  @override
  @JsonKey(name: 'temperature2m')
  List<double>? get temperature2m {
    final value = _temperature2m;
    if (value == null) return null;
    if (_temperature2m is EqualUnmodifiableListView) return _temperature2m;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<int>? _isDay;
  @override
  List<int>? get isDay {
    final value = _isDay;
    if (value == null) return null;
    if (_isDay is EqualUnmodifiableListView) return _isDay;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<double>? _sunshineDuration;
  @override
  List<double>? get sunshineDuration {
    final value = _sunshineDuration;
    if (value == null) return null;
    if (_sunshineDuration is EqualUnmodifiableListView)
      return _sunshineDuration;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<int>? _weathercode;
  @override
  List<int>? get weathercode {
    final value = _weathercode;
    if (value == null) return null;
    if (_weathercode is EqualUnmodifiableListView) return _weathercode;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<int>? _precipitationProbability;
  @override
  @JsonKey(name: 'precipitationProbability')
  List<int>? get precipitationProbability {
    final value = _precipitationProbability;
    if (value == null) return null;
    if (_precipitationProbability is EqualUnmodifiableListView)
      return _precipitationProbability;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'HourlyData(time: $time, temperature2m: $temperature2m, isDay: $isDay, sunshineDuration: $sunshineDuration, weathercode: $weathercode, precipitationProbability: $precipitationProbability)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HourlyDataImpl &&
            const DeepCollectionEquality().equals(other._time, _time) &&
            const DeepCollectionEquality().equals(
              other._temperature2m,
              _temperature2m,
            ) &&
            const DeepCollectionEquality().equals(other._isDay, _isDay) &&
            const DeepCollectionEquality().equals(
              other._sunshineDuration,
              _sunshineDuration,
            ) &&
            const DeepCollectionEquality().equals(
              other._weathercode,
              _weathercode,
            ) &&
            const DeepCollectionEquality().equals(
              other._precipitationProbability,
              _precipitationProbability,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_time),
    const DeepCollectionEquality().hash(_temperature2m),
    const DeepCollectionEquality().hash(_isDay),
    const DeepCollectionEquality().hash(_sunshineDuration),
    const DeepCollectionEquality().hash(_weathercode),
    const DeepCollectionEquality().hash(_precipitationProbability),
  );

  /// Create a copy of HourlyData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HourlyDataImplCopyWith<_$HourlyDataImpl> get copyWith =>
      __$$HourlyDataImplCopyWithImpl<_$HourlyDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HourlyDataImplToJson(this);
  }
}

abstract class _HourlyData implements HourlyData {
  const factory _HourlyData({
    final List<String>? time,
    @JsonKey(name: 'temperature2m') final List<double>? temperature2m,
    final List<int>? isDay,
    final List<double>? sunshineDuration,
    final List<int>? weathercode,
    @JsonKey(name: 'precipitationProbability')
    final List<int>? precipitationProbability,
  }) = _$HourlyDataImpl;

  factory _HourlyData.fromJson(Map<String, dynamic> json) =
      _$HourlyDataImpl.fromJson;

  @override
  List<String>? get time;
  @override
  @JsonKey(name: 'temperature2m')
  List<double>? get temperature2m;
  @override
  List<int>? get isDay;
  @override
  List<double>? get sunshineDuration;
  @override
  List<int>? get weathercode;
  @override
  @JsonKey(name: 'precipitationProbability')
  List<int>? get precipitationProbability;

  /// Create a copy of HourlyData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HourlyDataImplCopyWith<_$HourlyDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DailyUnits _$DailyUnitsFromJson(Map<String, dynamic> json) {
  return _DailyUnits.fromJson(json);
}

/// @nodoc
mixin _$DailyUnits {
  String? get temperature_max => throw _privateConstructorUsedError;
  String? get temperature_min => throw _privateConstructorUsedError;
  String? get sunrise => throw _privateConstructorUsedError;
  String? get sunset => throw _privateConstructorUsedError;
  String? get time => throw _privateConstructorUsedError;

  /// Serializes this DailyUnits to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyUnits
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyUnitsCopyWith<DailyUnits> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyUnitsCopyWith<$Res> {
  factory $DailyUnitsCopyWith(
    DailyUnits value,
    $Res Function(DailyUnits) then,
  ) = _$DailyUnitsCopyWithImpl<$Res, DailyUnits>;
  @useResult
  $Res call({
    String? temperature_max,
    String? temperature_min,
    String? sunrise,
    String? sunset,
    String? time,
  });
}

/// @nodoc
class _$DailyUnitsCopyWithImpl<$Res, $Val extends DailyUnits>
    implements $DailyUnitsCopyWith<$Res> {
  _$DailyUnitsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyUnits
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? temperature_max = freezed,
    Object? temperature_min = freezed,
    Object? sunrise = freezed,
    Object? sunset = freezed,
    Object? time = freezed,
  }) {
    return _then(
      _value.copyWith(
            temperature_max:
                freezed == temperature_max
                    ? _value.temperature_max
                    : temperature_max // ignore: cast_nullable_to_non_nullable
                        as String?,
            temperature_min:
                freezed == temperature_min
                    ? _value.temperature_min
                    : temperature_min // ignore: cast_nullable_to_non_nullable
                        as String?,
            sunrise:
                freezed == sunrise
                    ? _value.sunrise
                    : sunrise // ignore: cast_nullable_to_non_nullable
                        as String?,
            sunset:
                freezed == sunset
                    ? _value.sunset
                    : sunset // ignore: cast_nullable_to_non_nullable
                        as String?,
            time:
                freezed == time
                    ? _value.time
                    : time // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DailyUnitsImplCopyWith<$Res>
    implements $DailyUnitsCopyWith<$Res> {
  factory _$$DailyUnitsImplCopyWith(
    _$DailyUnitsImpl value,
    $Res Function(_$DailyUnitsImpl) then,
  ) = __$$DailyUnitsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? temperature_max,
    String? temperature_min,
    String? sunrise,
    String? sunset,
    String? time,
  });
}

/// @nodoc
class __$$DailyUnitsImplCopyWithImpl<$Res>
    extends _$DailyUnitsCopyWithImpl<$Res, _$DailyUnitsImpl>
    implements _$$DailyUnitsImplCopyWith<$Res> {
  __$$DailyUnitsImplCopyWithImpl(
    _$DailyUnitsImpl _value,
    $Res Function(_$DailyUnitsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DailyUnits
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? temperature_max = freezed,
    Object? temperature_min = freezed,
    Object? sunrise = freezed,
    Object? sunset = freezed,
    Object? time = freezed,
  }) {
    return _then(
      _$DailyUnitsImpl(
        temperature_max:
            freezed == temperature_max
                ? _value.temperature_max
                : temperature_max // ignore: cast_nullable_to_non_nullable
                    as String?,
        temperature_min:
            freezed == temperature_min
                ? _value.temperature_min
                : temperature_min // ignore: cast_nullable_to_non_nullable
                    as String?,
        sunrise:
            freezed == sunrise
                ? _value.sunrise
                : sunrise // ignore: cast_nullable_to_non_nullable
                    as String?,
        sunset:
            freezed == sunset
                ? _value.sunset
                : sunset // ignore: cast_nullable_to_non_nullable
                    as String?,
        time:
            freezed == time
                ? _value.time
                : time // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyUnitsImpl implements _DailyUnits {
  const _$DailyUnitsImpl({
    this.temperature_max,
    this.temperature_min,
    this.sunrise,
    this.sunset,
    this.time,
  });

  factory _$DailyUnitsImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyUnitsImplFromJson(json);

  @override
  final String? temperature_max;
  @override
  final String? temperature_min;
  @override
  final String? sunrise;
  @override
  final String? sunset;
  @override
  final String? time;

  @override
  String toString() {
    return 'DailyUnits(temperature_max: $temperature_max, temperature_min: $temperature_min, sunrise: $sunrise, sunset: $sunset, time: $time)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyUnitsImpl &&
            (identical(other.temperature_max, temperature_max) ||
                other.temperature_max == temperature_max) &&
            (identical(other.temperature_min, temperature_min) ||
                other.temperature_min == temperature_min) &&
            (identical(other.sunrise, sunrise) || other.sunrise == sunrise) &&
            (identical(other.sunset, sunset) || other.sunset == sunset) &&
            (identical(other.time, time) || other.time == time));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    temperature_max,
    temperature_min,
    sunrise,
    sunset,
    time,
  );

  /// Create a copy of DailyUnits
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyUnitsImplCopyWith<_$DailyUnitsImpl> get copyWith =>
      __$$DailyUnitsImplCopyWithImpl<_$DailyUnitsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyUnitsImplToJson(this);
  }
}

abstract class _DailyUnits implements DailyUnits {
  const factory _DailyUnits({
    final String? temperature_max,
    final String? temperature_min,
    final String? sunrise,
    final String? sunset,
    final String? time,
  }) = _$DailyUnitsImpl;

  factory _DailyUnits.fromJson(Map<String, dynamic> json) =
      _$DailyUnitsImpl.fromJson;

  @override
  String? get temperature_max;
  @override
  String? get temperature_min;
  @override
  String? get sunrise;
  @override
  String? get sunset;
  @override
  String? get time;

  /// Create a copy of DailyUnits
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyUnitsImplCopyWith<_$DailyUnitsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DailyData _$DailyDataFromJson(Map<String, dynamic> json) {
  return _DailyData.fromJson(json);
}

/// @nodoc
mixin _$DailyData {
  List<String>? get time => throw _privateConstructorUsedError;
  List<double>? get temperature_max => throw _privateConstructorUsedError;
  List<double>? get temperature_min => throw _privateConstructorUsedError;
  List<String>? get sunrise => throw _privateConstructorUsedError;
  List<String>? get sunset => throw _privateConstructorUsedError;

  /// Serializes this DailyData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyDataCopyWith<DailyData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyDataCopyWith<$Res> {
  factory $DailyDataCopyWith(DailyData value, $Res Function(DailyData) then) =
      _$DailyDataCopyWithImpl<$Res, DailyData>;
  @useResult
  $Res call({
    List<String>? time,
    List<double>? temperature_max,
    List<double>? temperature_min,
    List<String>? sunrise,
    List<String>? sunset,
  });
}

/// @nodoc
class _$DailyDataCopyWithImpl<$Res, $Val extends DailyData>
    implements $DailyDataCopyWith<$Res> {
  _$DailyDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? time = freezed,
    Object? temperature_max = freezed,
    Object? temperature_min = freezed,
    Object? sunrise = freezed,
    Object? sunset = freezed,
  }) {
    return _then(
      _value.copyWith(
            time:
                freezed == time
                    ? _value.time
                    : time // ignore: cast_nullable_to_non_nullable
                        as List<String>?,
            temperature_max:
                freezed == temperature_max
                    ? _value.temperature_max
                    : temperature_max // ignore: cast_nullable_to_non_nullable
                        as List<double>?,
            temperature_min:
                freezed == temperature_min
                    ? _value.temperature_min
                    : temperature_min // ignore: cast_nullable_to_non_nullable
                        as List<double>?,
            sunrise:
                freezed == sunrise
                    ? _value.sunrise
                    : sunrise // ignore: cast_nullable_to_non_nullable
                        as List<String>?,
            sunset:
                freezed == sunset
                    ? _value.sunset
                    : sunset // ignore: cast_nullable_to_non_nullable
                        as List<String>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DailyDataImplCopyWith<$Res>
    implements $DailyDataCopyWith<$Res> {
  factory _$$DailyDataImplCopyWith(
    _$DailyDataImpl value,
    $Res Function(_$DailyDataImpl) then,
  ) = __$$DailyDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<String>? time,
    List<double>? temperature_max,
    List<double>? temperature_min,
    List<String>? sunrise,
    List<String>? sunset,
  });
}

/// @nodoc
class __$$DailyDataImplCopyWithImpl<$Res>
    extends _$DailyDataCopyWithImpl<$Res, _$DailyDataImpl>
    implements _$$DailyDataImplCopyWith<$Res> {
  __$$DailyDataImplCopyWithImpl(
    _$DailyDataImpl _value,
    $Res Function(_$DailyDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DailyData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? time = freezed,
    Object? temperature_max = freezed,
    Object? temperature_min = freezed,
    Object? sunrise = freezed,
    Object? sunset = freezed,
  }) {
    return _then(
      _$DailyDataImpl(
        time:
            freezed == time
                ? _value._time
                : time // ignore: cast_nullable_to_non_nullable
                    as List<String>?,
        temperature_max:
            freezed == temperature_max
                ? _value._temperature_max
                : temperature_max // ignore: cast_nullable_to_non_nullable
                    as List<double>?,
        temperature_min:
            freezed == temperature_min
                ? _value._temperature_min
                : temperature_min // ignore: cast_nullable_to_non_nullable
                    as List<double>?,
        sunrise:
            freezed == sunrise
                ? _value._sunrise
                : sunrise // ignore: cast_nullable_to_non_nullable
                    as List<String>?,
        sunset:
            freezed == sunset
                ? _value._sunset
                : sunset // ignore: cast_nullable_to_non_nullable
                    as List<String>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyDataImpl implements _DailyData {
  const _$DailyDataImpl({
    final List<String>? time,
    final List<double>? temperature_max,
    final List<double>? temperature_min,
    final List<String>? sunrise,
    final List<String>? sunset,
  }) : _time = time,
       _temperature_max = temperature_max,
       _temperature_min = temperature_min,
       _sunrise = sunrise,
       _sunset = sunset;

  factory _$DailyDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyDataImplFromJson(json);

  final List<String>? _time;
  @override
  List<String>? get time {
    final value = _time;
    if (value == null) return null;
    if (_time is EqualUnmodifiableListView) return _time;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<double>? _temperature_max;
  @override
  List<double>? get temperature_max {
    final value = _temperature_max;
    if (value == null) return null;
    if (_temperature_max is EqualUnmodifiableListView) return _temperature_max;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<double>? _temperature_min;
  @override
  List<double>? get temperature_min {
    final value = _temperature_min;
    if (value == null) return null;
    if (_temperature_min is EqualUnmodifiableListView) return _temperature_min;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _sunrise;
  @override
  List<String>? get sunrise {
    final value = _sunrise;
    if (value == null) return null;
    if (_sunrise is EqualUnmodifiableListView) return _sunrise;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _sunset;
  @override
  List<String>? get sunset {
    final value = _sunset;
    if (value == null) return null;
    if (_sunset is EqualUnmodifiableListView) return _sunset;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'DailyData(time: $time, temperature_max: $temperature_max, temperature_min: $temperature_min, sunrise: $sunrise, sunset: $sunset)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyDataImpl &&
            const DeepCollectionEquality().equals(other._time, _time) &&
            const DeepCollectionEquality().equals(
              other._temperature_max,
              _temperature_max,
            ) &&
            const DeepCollectionEquality().equals(
              other._temperature_min,
              _temperature_min,
            ) &&
            const DeepCollectionEquality().equals(other._sunrise, _sunrise) &&
            const DeepCollectionEquality().equals(other._sunset, _sunset));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_time),
    const DeepCollectionEquality().hash(_temperature_max),
    const DeepCollectionEquality().hash(_temperature_min),
    const DeepCollectionEquality().hash(_sunrise),
    const DeepCollectionEquality().hash(_sunset),
  );

  /// Create a copy of DailyData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyDataImplCopyWith<_$DailyDataImpl> get copyWith =>
      __$$DailyDataImplCopyWithImpl<_$DailyDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyDataImplToJson(this);
  }
}

abstract class _DailyData implements DailyData {
  const factory _DailyData({
    final List<String>? time,
    final List<double>? temperature_max,
    final List<double>? temperature_min,
    final List<String>? sunrise,
    final List<String>? sunset,
  }) = _$DailyDataImpl;

  factory _DailyData.fromJson(Map<String, dynamic> json) =
      _$DailyDataImpl.fromJson;

  @override
  List<String>? get time;
  @override
  List<double>? get temperature_max;
  @override
  List<double>? get temperature_min;
  @override
  List<String>? get sunrise;
  @override
  List<String>? get sunset;

  /// Create a copy of DailyData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyDataImplCopyWith<_$DailyDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
