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

Country _$CountryFromJson(Map<String, dynamic> json) {
  return _Country.fromJson(json);
}

/// @nodoc
mixin _$Country {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  /// Serializes this Country to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Country
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CountryCopyWith<Country> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CountryCopyWith<$Res> {
  factory $CountryCopyWith(Country value, $Res Function(Country) then) =
      _$CountryCopyWithImpl<$Res, Country>;
  @useResult
  $Res call({int id, String name});
}

/// @nodoc
class _$CountryCopyWithImpl<$Res, $Val extends Country>
    implements $CountryCopyWith<$Res> {
  _$CountryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Country
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? name = null}) {
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CountryImplCopyWith<$Res> implements $CountryCopyWith<$Res> {
  factory _$$CountryImplCopyWith(
    _$CountryImpl value,
    $Res Function(_$CountryImpl) then,
  ) = __$$CountryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String name});
}

/// @nodoc
class __$$CountryImplCopyWithImpl<$Res>
    extends _$CountryCopyWithImpl<$Res, _$CountryImpl>
    implements _$$CountryImplCopyWith<$Res> {
  __$$CountryImplCopyWithImpl(
    _$CountryImpl _value,
    $Res Function(_$CountryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Country
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? name = null}) {
    return _then(
      _$CountryImpl(
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
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CountryImpl implements _Country {
  const _$CountryImpl({required this.id, required this.name});

  factory _$CountryImpl.fromJson(Map<String, dynamic> json) =>
      _$$CountryImplFromJson(json);

  @override
  final int id;
  @override
  final String name;

  @override
  String toString() {
    return 'Country(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CountryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name);

  /// Create a copy of Country
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CountryImplCopyWith<_$CountryImpl> get copyWith =>
      __$$CountryImplCopyWithImpl<_$CountryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CountryImplToJson(this);
  }
}

abstract class _Country implements Country {
  const factory _Country({required final int id, required final String name}) =
      _$CountryImpl;

  factory _Country.fromJson(Map<String, dynamic> json) = _$CountryImpl.fromJson;

  @override
  int get id;
  @override
  String get name;

  /// Create a copy of Country
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CountryImplCopyWith<_$CountryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CityDetail _$CityDetailFromJson(Map<String, dynamic> json) {
  return _CityDetail.fromJson(json);
}

/// @nodoc
mixin _$CityDetail {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  Country get country => throw _privateConstructorUsedError;
  List<dynamic>? get images => throw _privateConstructorUsedError;
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
    List<dynamic>? images,
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
  });

  $CountryCopyWith<$Res> get country;
  $CurrentWeatherCopyWith<$Res>? get currentWeather;
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
    Object? images = freezed,
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
                freezed == images
                    ? _value.images
                    : images // ignore: cast_nullable_to_non_nullable
                        as List<dynamic>?,
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
    List<dynamic>? images,
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
  });

  @override
  $CountryCopyWith<$Res> get country;
  @override
  $CurrentWeatherCopyWith<$Res>? get currentWeather;
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
    Object? images = freezed,
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
            freezed == images
                ? _value._images
                : images // ignore: cast_nullable_to_non_nullable
                    as List<dynamic>?,
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
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$CityDetailImpl extends _CityDetail {
  const _$CityDetailImpl({
    required this.id,
    required this.name,
    required this.country,
    final List<dynamic>? images = const [],
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
  final List<dynamic>? _images;
  @override
  @JsonKey()
  List<dynamic>? get images {
    final value = _images;
    if (value == null) return null;
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
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
  String toString() {
    return 'CityDetail(id: $id, name: $name, country: $country, images: $images, description: $description, bestTimeToTravel: $bestTimeToTravel, famousFor: $famousFor, timezone: $timezone, population: $population, wikidataId: $wikidataId, detailsLastUpdated: $detailsLastUpdated, currentWeather: $currentWeather, weatherLastUpdated: $weatherLastUpdated, budgetScale: $budgetScale, budgetSummary: $budgetSummary)';
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
                other.budgetSummary == budgetSummary));
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
    final List<dynamic>? images,
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
  List<dynamic>? get images;
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
  int? get dt => throw _privateConstructorUsedError; // Timestamp
  int? get timezone =>
      throw _privateConstructorUsedError; // Timezone offset in seconds?
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

@JsonSerializable(explicitToJson: true)
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
  // Timestamp
  @override
  final int? timezone;
  // Timezone offset in seconds?
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
  int? get dt; // Timestamp
  @override
  int? get timezone; // Timezone offset in seconds?
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
  $Res call({String? main, String? description, String? icon});
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
    Object? main = freezed,
    Object? description = freezed,
    Object? icon = freezed,
  }) {
    return _then(
      _value.copyWith(
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
  $Res call({String? main, String? description, String? icon});
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
    Object? main = freezed,
    Object? description = freezed,
    Object? icon = freezed,
  }) {
    return _then(
      _$WeatherInfoImpl(
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
  const _$WeatherInfoImpl({this.main, this.description, this.icon});

  factory _$WeatherInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeatherInfoImplFromJson(json);

  @override
  final String? main;
  @override
  final String? description;
  @override
  final String? icon;

  @override
  String toString() {
    return 'WeatherInfo(main: $main, description: $description, icon: $icon)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeatherInfoImpl &&
            (identical(other.main, main) || other.main == main) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.icon, icon) || other.icon == icon));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, main, description, icon);

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
    final String? main,
    final String? description,
    final String? icon,
  }) = _$WeatherInfoImpl;

  factory _WeatherInfo.fromJson(Map<String, dynamic> json) =
      _$WeatherInfoImpl.fromJson;

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
  double? get temp =>
      throw _privateConstructorUsedError; // Match JSON key if different (example: feels_like)
  @JsonKey(name: 'feelsLike')
  double? get feelsLike => throw _privateConstructorUsedError; // Adjusted key based on provided JSON
  @JsonKey(name: 'tempMin')
  double? get tempMin => throw _privateConstructorUsedError; // Adjusted key
  @JsonKey(name: 'tempMax')
  double? get tempMax => throw _privateConstructorUsedError; // Adjusted key
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
    @JsonKey(name: 'feelsLike') double? feelsLike,
    @JsonKey(name: 'tempMin') double? tempMin,
    @JsonKey(name: 'tempMax') double? tempMax,
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
    Object? feelsLike = freezed,
    Object? tempMin = freezed,
    Object? tempMax = freezed,
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
            feelsLike:
                freezed == feelsLike
                    ? _value.feelsLike
                    : feelsLike // ignore: cast_nullable_to_non_nullable
                        as double?,
            tempMin:
                freezed == tempMin
                    ? _value.tempMin
                    : tempMin // ignore: cast_nullable_to_non_nullable
                        as double?,
            tempMax:
                freezed == tempMax
                    ? _value.tempMax
                    : tempMax // ignore: cast_nullable_to_non_nullable
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
    @JsonKey(name: 'feelsLike') double? feelsLike,
    @JsonKey(name: 'tempMin') double? tempMin,
    @JsonKey(name: 'tempMax') double? tempMax,
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
    Object? feelsLike = freezed,
    Object? tempMin = freezed,
    Object? tempMax = freezed,
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
        feelsLike:
            freezed == feelsLike
                ? _value.feelsLike
                : feelsLike // ignore: cast_nullable_to_non_nullable
                    as double?,
        tempMin:
            freezed == tempMin
                ? _value.tempMin
                : tempMin // ignore: cast_nullable_to_non_nullable
                    as double?,
        tempMax:
            freezed == tempMax
                ? _value.tempMax
                : tempMax // ignore: cast_nullable_to_non_nullable
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
    @JsonKey(name: 'feelsLike') this.feelsLike,
    @JsonKey(name: 'tempMin') this.tempMin,
    @JsonKey(name: 'tempMax') this.tempMax,
    this.pressure,
    this.humidity,
  });

  factory _$WeatherMainImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeatherMainImplFromJson(json);

  @override
  final double? temp;
  // Match JSON key if different (example: feels_like)
  @override
  @JsonKey(name: 'feelsLike')
  final double? feelsLike;
  // Adjusted key based on provided JSON
  @override
  @JsonKey(name: 'tempMin')
  final double? tempMin;
  // Adjusted key
  @override
  @JsonKey(name: 'tempMax')
  final double? tempMax;
  // Adjusted key
  @override
  final int? pressure;
  @override
  final int? humidity;

  @override
  String toString() {
    return 'WeatherMain(temp: $temp, feelsLike: $feelsLike, tempMin: $tempMin, tempMax: $tempMax, pressure: $pressure, humidity: $humidity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeatherMainImpl &&
            (identical(other.temp, temp) || other.temp == temp) &&
            (identical(other.feelsLike, feelsLike) ||
                other.feelsLike == feelsLike) &&
            (identical(other.tempMin, tempMin) || other.tempMin == tempMin) &&
            (identical(other.tempMax, tempMax) || other.tempMax == tempMax) &&
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
    feelsLike,
    tempMin,
    tempMax,
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
    @JsonKey(name: 'feelsLike') final double? feelsLike,
    @JsonKey(name: 'tempMin') final double? tempMin,
    @JsonKey(name: 'tempMax') final double? tempMax,
    final int? pressure,
    final int? humidity,
  }) = _$WeatherMainImpl;

  factory _WeatherMain.fromJson(Map<String, dynamic> json) =
      _$WeatherMainImpl.fromJson;

  @override
  double? get temp; // Match JSON key if different (example: feels_like)
  @override
  @JsonKey(name: 'feelsLike')
  double? get feelsLike; // Adjusted key based on provided JSON
  @override
  @JsonKey(name: 'tempMin')
  double? get tempMin; // Adjusted key
  @override
  @JsonKey(name: 'tempMax')
  double? get tempMax; // Adjusted key
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
