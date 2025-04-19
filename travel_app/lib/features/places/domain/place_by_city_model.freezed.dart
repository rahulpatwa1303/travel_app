// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'place_by_city_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PlaceByCity _$PlaceByCityFromJson(Map<String, dynamic> json) {
  return _PlaceByCity.fromJson(json);
}

/// @nodoc
mixin _$PlaceByCity {
  int get id => throw _privateConstructorUsedError;
  String get name =>
      throw _privateConstructorUsedError; // Make latitude and longitude required if they always exist
  double get latitude => throw _privateConstructorUsedError;
  double get longitude =>
      throw _privateConstructorUsedError; // Category seems required
  String get category =>
      throw _privateConstructorUsedError; // Address is nullable based on the JSON
  String? get address =>
      throw _privateConstructorUsedError; // city_id seems required
  @JsonKey(name: 'city_id')
  int get cityId => throw _privateConstructorUsedError; // Assuming images is a list, potentially dynamic or specific type
  // Default to empty list, make nullable if it can be absent
  @JsonKey(name: 'images')
  List<dynamic> get images => throw _privateConstructorUsedError;

  /// Serializes this PlaceByCity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlaceByCity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlaceByCityCopyWith<PlaceByCity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlaceByCityCopyWith<$Res> {
  factory $PlaceByCityCopyWith(
    PlaceByCity value,
    $Res Function(PlaceByCity) then,
  ) = _$PlaceByCityCopyWithImpl<$Res, PlaceByCity>;
  @useResult
  $Res call({
    int id,
    String name,
    double latitude,
    double longitude,
    String category,
    String? address,
    @JsonKey(name: 'city_id') int cityId,
    @JsonKey(name: 'images') List<dynamic> images,
  });
}

/// @nodoc
class _$PlaceByCityCopyWithImpl<$Res, $Val extends PlaceByCity>
    implements $PlaceByCityCopyWith<$Res> {
  _$PlaceByCityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlaceByCity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? category = null,
    Object? address = freezed,
    Object? cityId = null,
    Object? images = null,
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
            latitude:
                null == latitude
                    ? _value.latitude
                    : latitude // ignore: cast_nullable_to_non_nullable
                        as double,
            longitude:
                null == longitude
                    ? _value.longitude
                    : longitude // ignore: cast_nullable_to_non_nullable
                        as double,
            category:
                null == category
                    ? _value.category
                    : category // ignore: cast_nullable_to_non_nullable
                        as String,
            address:
                freezed == address
                    ? _value.address
                    : address // ignore: cast_nullable_to_non_nullable
                        as String?,
            cityId:
                null == cityId
                    ? _value.cityId
                    : cityId // ignore: cast_nullable_to_non_nullable
                        as int,
            images:
                null == images
                    ? _value.images
                    : images // ignore: cast_nullable_to_non_nullable
                        as List<dynamic>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PlaceByCityImplCopyWith<$Res>
    implements $PlaceByCityCopyWith<$Res> {
  factory _$$PlaceByCityImplCopyWith(
    _$PlaceByCityImpl value,
    $Res Function(_$PlaceByCityImpl) then,
  ) = __$$PlaceByCityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String name,
    double latitude,
    double longitude,
    String category,
    String? address,
    @JsonKey(name: 'city_id') int cityId,
    @JsonKey(name: 'images') List<dynamic> images,
  });
}

/// @nodoc
class __$$PlaceByCityImplCopyWithImpl<$Res>
    extends _$PlaceByCityCopyWithImpl<$Res, _$PlaceByCityImpl>
    implements _$$PlaceByCityImplCopyWith<$Res> {
  __$$PlaceByCityImplCopyWithImpl(
    _$PlaceByCityImpl _value,
    $Res Function(_$PlaceByCityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PlaceByCity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? category = null,
    Object? address = freezed,
    Object? cityId = null,
    Object? images = null,
  }) {
    return _then(
      _$PlaceByCityImpl(
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
        latitude:
            null == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                    as double,
        longitude:
            null == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                    as double,
        category:
            null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                    as String,
        address:
            freezed == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                    as String?,
        cityId:
            null == cityId
                ? _value.cityId
                : cityId // ignore: cast_nullable_to_non_nullable
                    as int,
        images:
            null == images
                ? _value._images
                : images // ignore: cast_nullable_to_non_nullable
                    as List<dynamic>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PlaceByCityImpl extends _PlaceByCity {
  const _$PlaceByCityImpl({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.category,
    this.address,
    @JsonKey(name: 'city_id') required this.cityId,
    @JsonKey(name: 'images') final List<dynamic> images = const [],
  }) : _images = images,
       super._();

  factory _$PlaceByCityImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlaceByCityImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  // Make latitude and longitude required if they always exist
  @override
  final double latitude;
  @override
  final double longitude;
  // Category seems required
  @override
  final String category;
  // Address is nullable based on the JSON
  @override
  final String? address;
  // city_id seems required
  @override
  @JsonKey(name: 'city_id')
  final int cityId;
  // Assuming images is a list, potentially dynamic or specific type
  // Default to empty list, make nullable if it can be absent
  final List<dynamic> _images;
  // Assuming images is a list, potentially dynamic or specific type
  // Default to empty list, make nullable if it can be absent
  @override
  @JsonKey(name: 'images')
  List<dynamic> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  @override
  String toString() {
    return 'PlaceByCity(id: $id, name: $name, latitude: $latitude, longitude: $longitude, category: $category, address: $address, cityId: $cityId, images: $images)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlaceByCityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.cityId, cityId) || other.cityId == cityId) &&
            const DeepCollectionEquality().equals(other._images, _images));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    latitude,
    longitude,
    category,
    address,
    cityId,
    const DeepCollectionEquality().hash(_images),
  );

  /// Create a copy of PlaceByCity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlaceByCityImplCopyWith<_$PlaceByCityImpl> get copyWith =>
      __$$PlaceByCityImplCopyWithImpl<_$PlaceByCityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlaceByCityImplToJson(this);
  }
}

abstract class _PlaceByCity extends PlaceByCity {
  const factory _PlaceByCity({
    required final int id,
    required final String name,
    required final double latitude,
    required final double longitude,
    required final String category,
    final String? address,
    @JsonKey(name: 'city_id') required final int cityId,
    @JsonKey(name: 'images') final List<dynamic> images,
  }) = _$PlaceByCityImpl;
  const _PlaceByCity._() : super._();

  factory _PlaceByCity.fromJson(Map<String, dynamic> json) =
      _$PlaceByCityImpl.fromJson;

  @override
  int get id;
  @override
  String get name; // Make latitude and longitude required if they always exist
  @override
  double get latitude;
  @override
  double get longitude; // Category seems required
  @override
  String get category; // Address is nullable based on the JSON
  @override
  String? get address; // city_id seems required
  @override
  @JsonKey(name: 'city_id')
  int get cityId; // Assuming images is a list, potentially dynamic or specific type
  // Default to empty list, make nullable if it can be absent
  @override
  @JsonKey(name: 'images')
  List<dynamic> get images;

  /// Create a copy of PlaceByCity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlaceByCityImplCopyWith<_$PlaceByCityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
