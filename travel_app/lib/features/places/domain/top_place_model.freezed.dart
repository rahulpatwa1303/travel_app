// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'top_place_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TopPlace _$TopPlaceFromJson(Map<String, dynamic> json) {
  return _TopPlace.fromJson(json);
}

/// @nodoc
mixin _$TopPlace {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  Country get country => throw _privateConstructorUsedError;
  List<String>? get images => throw _privateConstructorUsedError;

  /// Serializes this TopPlace to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TopPlace
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TopPlaceCopyWith<TopPlace> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TopPlaceCopyWith<$Res> {
  factory $TopPlaceCopyWith(TopPlace value, $Res Function(TopPlace) then) =
      _$TopPlaceCopyWithImpl<$Res, TopPlace>;
  @useResult
  $Res call({int id, String name, Country country, List<String>? images});

  $CountryCopyWith<$Res> get country;
}

/// @nodoc
class _$TopPlaceCopyWithImpl<$Res, $Val extends TopPlace>
    implements $TopPlaceCopyWith<$Res> {
  _$TopPlaceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TopPlace
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? country = null,
    Object? images = freezed,
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
                        as List<String>?,
          )
          as $Val,
    );
  }

  /// Create a copy of TopPlace
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CountryCopyWith<$Res> get country {
    return $CountryCopyWith<$Res>(_value.country, (value) {
      return _then(_value.copyWith(country: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TopPlaceImplCopyWith<$Res>
    implements $TopPlaceCopyWith<$Res> {
  factory _$$TopPlaceImplCopyWith(
    _$TopPlaceImpl value,
    $Res Function(_$TopPlaceImpl) then,
  ) = __$$TopPlaceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String name, Country country, List<String>? images});

  @override
  $CountryCopyWith<$Res> get country;
}

/// @nodoc
class __$$TopPlaceImplCopyWithImpl<$Res>
    extends _$TopPlaceCopyWithImpl<$Res, _$TopPlaceImpl>
    implements _$$TopPlaceImplCopyWith<$Res> {
  __$$TopPlaceImplCopyWithImpl(
    _$TopPlaceImpl _value,
    $Res Function(_$TopPlaceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TopPlace
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? country = null,
    Object? images = freezed,
  }) {
    return _then(
      _$TopPlaceImpl(
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
                    as List<String>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TopPlaceImpl extends _TopPlace {
  const _$TopPlaceImpl({
    required this.id,
    required this.name,
    required this.country,
    final List<String>? images,
  }) : _images = images,
       super._();

  factory _$TopPlaceImpl.fromJson(Map<String, dynamic> json) =>
      _$$TopPlaceImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final Country country;
  final List<String>? _images;
  @override
  List<String>? get images {
    final value = _images;
    if (value == null) return null;
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'TopPlace(id: $id, name: $name, country: $country, images: $images)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TopPlaceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.country, country) || other.country == country) &&
            const DeepCollectionEquality().equals(other._images, _images));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    country,
    const DeepCollectionEquality().hash(_images),
  );

  /// Create a copy of TopPlace
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TopPlaceImplCopyWith<_$TopPlaceImpl> get copyWith =>
      __$$TopPlaceImplCopyWithImpl<_$TopPlaceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TopPlaceImplToJson(this);
  }
}

abstract class _TopPlace extends TopPlace {
  const factory _TopPlace({
    required final int id,
    required final String name,
    required final Country country,
    final List<String>? images,
  }) = _$TopPlaceImpl;
  const _TopPlace._() : super._();

  factory _TopPlace.fromJson(Map<String, dynamic> json) =
      _$TopPlaceImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  Country get country;
  @override
  List<String>? get images;

  /// Create a copy of TopPlace
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TopPlaceImplCopyWith<_$TopPlaceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

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

/// @nodoc
mixin _$PlacesCategory {
  // `name` is the raw category string coming from the API
  String get name =>
      throw _privateConstructorUsedError; // `displayName` is the value to be shown to users, computed automatically
  String get displayName => throw _privateConstructorUsedError;

  /// Create a copy of PlacesCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlacesCategoryCopyWith<PlacesCategory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlacesCategoryCopyWith<$Res> {
  factory $PlacesCategoryCopyWith(
    PlacesCategory value,
    $Res Function(PlacesCategory) then,
  ) = _$PlacesCategoryCopyWithImpl<$Res, PlacesCategory>;
  @useResult
  $Res call({String name, String displayName});
}

/// @nodoc
class _$PlacesCategoryCopyWithImpl<$Res, $Val extends PlacesCategory>
    implements $PlacesCategoryCopyWith<$Res> {
  _$PlacesCategoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlacesCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? displayName = null}) {
    return _then(
      _value.copyWith(
            name:
                null == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String,
            displayName:
                null == displayName
                    ? _value.displayName
                    : displayName // ignore: cast_nullable_to_non_nullable
                        as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PlacesCategoryImplCopyWith<$Res>
    implements $PlacesCategoryCopyWith<$Res> {
  factory _$$PlacesCategoryImplCopyWith(
    _$PlacesCategoryImpl value,
    $Res Function(_$PlacesCategoryImpl) then,
  ) = __$$PlacesCategoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String displayName});
}

/// @nodoc
class __$$PlacesCategoryImplCopyWithImpl<$Res>
    extends _$PlacesCategoryCopyWithImpl<$Res, _$PlacesCategoryImpl>
    implements _$$PlacesCategoryImplCopyWith<$Res> {
  __$$PlacesCategoryImplCopyWithImpl(
    _$PlacesCategoryImpl _value,
    $Res Function(_$PlacesCategoryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PlacesCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? displayName = null}) {
    return _then(
      _$PlacesCategoryImpl(
        name:
            null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String,
        displayName:
            null == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                    as String,
      ),
    );
  }
}

/// @nodoc

class _$PlacesCategoryImpl implements _PlacesCategory {
  const _$PlacesCategoryImpl({required this.name, required this.displayName});

  // `name` is the raw category string coming from the API
  @override
  final String name;
  // `displayName` is the value to be shown to users, computed automatically
  @override
  final String displayName;

  @override
  String toString() {
    return 'PlacesCategory(name: $name, displayName: $displayName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlacesCategoryImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName));
  }

  @override
  int get hashCode => Object.hash(runtimeType, name, displayName);

  /// Create a copy of PlacesCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlacesCategoryImplCopyWith<_$PlacesCategoryImpl> get copyWith =>
      __$$PlacesCategoryImplCopyWithImpl<_$PlacesCategoryImpl>(
        this,
        _$identity,
      );
}

abstract class _PlacesCategory implements PlacesCategory {
  const factory _PlacesCategory({
    required final String name,
    required final String displayName,
  }) = _$PlacesCategoryImpl;

  // `name` is the raw category string coming from the API
  @override
  String get name; // `displayName` is the value to be shown to users, computed automatically
  @override
  String get displayName;

  /// Create a copy of PlacesCategory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlacesCategoryImplCopyWith<_$PlacesCategoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
