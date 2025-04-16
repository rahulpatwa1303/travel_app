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
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  String? get website => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  int? get osm_id => throw _privateConstructorUsedError;
  Map<String, dynamic>? get tags => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  double? get relevance_score => throw _privateConstructorUsedError;
  List<String>? get reason => throw _privateConstructorUsedError;
  double? get distance_km => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_url')
  String? get imageUrl => throw _privateConstructorUsedError;

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
  $Res call({
    int id,
    String name,
    double latitude,
    double longitude,
    String? website,
    String? description,
    int? osm_id,
    Map<String, dynamic>? tags,
    String? category,
    double? relevance_score,
    List<String>? reason,
    double? distance_km,
    @JsonKey(name: 'image_url') String? imageUrl,
  });
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
    Object? latitude = null,
    Object? longitude = null,
    Object? website = freezed,
    Object? description = freezed,
    Object? osm_id = freezed,
    Object? tags = freezed,
    Object? category = freezed,
    Object? relevance_score = freezed,
    Object? reason = freezed,
    Object? distance_km = freezed,
    Object? imageUrl = freezed,
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
            website:
                freezed == website
                    ? _value.website
                    : website // ignore: cast_nullable_to_non_nullable
                        as String?,
            description:
                freezed == description
                    ? _value.description
                    : description // ignore: cast_nullable_to_non_nullable
                        as String?,
            osm_id:
                freezed == osm_id
                    ? _value.osm_id
                    : osm_id // ignore: cast_nullable_to_non_nullable
                        as int?,
            tags:
                freezed == tags
                    ? _value.tags
                    : tags // ignore: cast_nullable_to_non_nullable
                        as Map<String, dynamic>?,
            category:
                freezed == category
                    ? _value.category
                    : category // ignore: cast_nullable_to_non_nullable
                        as String?,
            relevance_score:
                freezed == relevance_score
                    ? _value.relevance_score
                    : relevance_score // ignore: cast_nullable_to_non_nullable
                        as double?,
            reason:
                freezed == reason
                    ? _value.reason
                    : reason // ignore: cast_nullable_to_non_nullable
                        as List<String>?,
            distance_km:
                freezed == distance_km
                    ? _value.distance_km
                    : distance_km // ignore: cast_nullable_to_non_nullable
                        as double?,
            imageUrl:
                freezed == imageUrl
                    ? _value.imageUrl
                    : imageUrl // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
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
  $Res call({
    int id,
    String name,
    double latitude,
    double longitude,
    String? website,
    String? description,
    int? osm_id,
    Map<String, dynamic>? tags,
    String? category,
    double? relevance_score,
    List<String>? reason,
    double? distance_km,
    @JsonKey(name: 'image_url') String? imageUrl,
  });
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
    Object? latitude = null,
    Object? longitude = null,
    Object? website = freezed,
    Object? description = freezed,
    Object? osm_id = freezed,
    Object? tags = freezed,
    Object? category = freezed,
    Object? relevance_score = freezed,
    Object? reason = freezed,
    Object? distance_km = freezed,
    Object? imageUrl = freezed,
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
        website:
            freezed == website
                ? _value.website
                : website // ignore: cast_nullable_to_non_nullable
                    as String?,
        description:
            freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                    as String?,
        osm_id:
            freezed == osm_id
                ? _value.osm_id
                : osm_id // ignore: cast_nullable_to_non_nullable
                    as int?,
        tags:
            freezed == tags
                ? _value._tags
                : tags // ignore: cast_nullable_to_non_nullable
                    as Map<String, dynamic>?,
        category:
            freezed == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                    as String?,
        relevance_score:
            freezed == relevance_score
                ? _value.relevance_score
                : relevance_score // ignore: cast_nullable_to_non_nullable
                    as double?,
        reason:
            freezed == reason
                ? _value._reason
                : reason // ignore: cast_nullable_to_non_nullable
                    as List<String>?,
        distance_km:
            freezed == distance_km
                ? _value.distance_km
                : distance_km // ignore: cast_nullable_to_non_nullable
                    as double?,
        imageUrl:
            freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                    as String?,
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
    required this.latitude,
    required this.longitude,
    this.website,
    this.description,
    this.osm_id,
    final Map<String, dynamic>? tags,
    this.category,
    this.relevance_score,
    final List<String>? reason,
    this.distance_km,
    @JsonKey(name: 'image_url') this.imageUrl,
  }) : _tags = tags,
       _reason = reason,
       super._();

  factory _$TopPlaceImpl.fromJson(Map<String, dynamic> json) =>
      _$$TopPlaceImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final String? website;
  @override
  final String? description;
  @override
  final int? osm_id;
  final Map<String, dynamic>? _tags;
  @override
  Map<String, dynamic>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableMapView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? category;
  @override
  final double? relevance_score;
  final List<String>? _reason;
  @override
  List<String>? get reason {
    final value = _reason;
    if (value == null) return null;
    if (_reason is EqualUnmodifiableListView) return _reason;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final double? distance_km;
  @override
  @JsonKey(name: 'image_url')
  final String? imageUrl;

  @override
  String toString() {
    return 'TopPlace(id: $id, name: $name, latitude: $latitude, longitude: $longitude, website: $website, description: $description, osm_id: $osm_id, tags: $tags, category: $category, relevance_score: $relevance_score, reason: $reason, distance_km: $distance_km, imageUrl: $imageUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TopPlaceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.website, website) || other.website == website) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.osm_id, osm_id) || other.osm_id == osm_id) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.relevance_score, relevance_score) ||
                other.relevance_score == relevance_score) &&
            const DeepCollectionEquality().equals(other._reason, _reason) &&
            (identical(other.distance_km, distance_km) ||
                other.distance_km == distance_km) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    latitude,
    longitude,
    website,
    description,
    osm_id,
    const DeepCollectionEquality().hash(_tags),
    category,
    relevance_score,
    const DeepCollectionEquality().hash(_reason),
    distance_km,
    imageUrl,
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
    required final double latitude,
    required final double longitude,
    final String? website,
    final String? description,
    final int? osm_id,
    final Map<String, dynamic>? tags,
    final String? category,
    final double? relevance_score,
    final List<String>? reason,
    final double? distance_km,
    @JsonKey(name: 'image_url') final String? imageUrl,
  }) = _$TopPlaceImpl;
  const _TopPlace._() : super._();

  factory _TopPlace.fromJson(Map<String, dynamic> json) =
      _$TopPlaceImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  String? get website;
  @override
  String? get description;
  @override
  int? get osm_id;
  @override
  Map<String, dynamic>? get tags;
  @override
  String? get category;
  @override
  double? get relevance_score;
  @override
  List<String>? get reason;
  @override
  double? get distance_km;
  @override
  @JsonKey(name: 'image_url')
  String? get imageUrl;

  /// Create a copy of TopPlace
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TopPlaceImplCopyWith<_$TopPlaceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PlacesCategories _$PlacesCategoriesFromJson(Map<String, dynamic> json) {
  return _PlacesCategories.fromJson(json);
}

/// @nodoc
mixin _$PlacesCategories {
  // Required fields
  String get name => throw _privateConstructorUsedError;
  String get display_name => throw _privateConstructorUsedError;
  String get osm_key => throw _privateConstructorUsedError;
  String get osm_value => throw _privateConstructorUsedError;

  /// Serializes this PlacesCategories to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlacesCategories
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlacesCategoriesCopyWith<PlacesCategories> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlacesCategoriesCopyWith<$Res> {
  factory $PlacesCategoriesCopyWith(
    PlacesCategories value,
    $Res Function(PlacesCategories) then,
  ) = _$PlacesCategoriesCopyWithImpl<$Res, PlacesCategories>;
  @useResult
  $Res call({
    String name,
    String display_name,
    String osm_key,
    String osm_value,
  });
}

/// @nodoc
class _$PlacesCategoriesCopyWithImpl<$Res, $Val extends PlacesCategories>
    implements $PlacesCategoriesCopyWith<$Res> {
  _$PlacesCategoriesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlacesCategories
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? display_name = null,
    Object? osm_key = null,
    Object? osm_value = null,
  }) {
    return _then(
      _value.copyWith(
            name:
                null == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String,
            display_name:
                null == display_name
                    ? _value.display_name
                    : display_name // ignore: cast_nullable_to_non_nullable
                        as String,
            osm_key:
                null == osm_key
                    ? _value.osm_key
                    : osm_key // ignore: cast_nullable_to_non_nullable
                        as String,
            osm_value:
                null == osm_value
                    ? _value.osm_value
                    : osm_value // ignore: cast_nullable_to_non_nullable
                        as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PlacesCategoriesImplCopyWith<$Res>
    implements $PlacesCategoriesCopyWith<$Res> {
  factory _$$PlacesCategoriesImplCopyWith(
    _$PlacesCategoriesImpl value,
    $Res Function(_$PlacesCategoriesImpl) then,
  ) = __$$PlacesCategoriesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    String display_name,
    String osm_key,
    String osm_value,
  });
}

/// @nodoc
class __$$PlacesCategoriesImplCopyWithImpl<$Res>
    extends _$PlacesCategoriesCopyWithImpl<$Res, _$PlacesCategoriesImpl>
    implements _$$PlacesCategoriesImplCopyWith<$Res> {
  __$$PlacesCategoriesImplCopyWithImpl(
    _$PlacesCategoriesImpl _value,
    $Res Function(_$PlacesCategoriesImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PlacesCategories
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? display_name = null,
    Object? osm_key = null,
    Object? osm_value = null,
  }) {
    return _then(
      _$PlacesCategoriesImpl(
        name:
            null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String,
        display_name:
            null == display_name
                ? _value.display_name
                : display_name // ignore: cast_nullable_to_non_nullable
                    as String,
        osm_key:
            null == osm_key
                ? _value.osm_key
                : osm_key // ignore: cast_nullable_to_non_nullable
                    as String,
        osm_value:
            null == osm_value
                ? _value.osm_value
                : osm_value // ignore: cast_nullable_to_non_nullable
                    as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PlacesCategoriesImpl implements _PlacesCategories {
  const _$PlacesCategoriesImpl({
    required this.name,
    required this.display_name,
    required this.osm_key,
    required this.osm_value,
  });

  factory _$PlacesCategoriesImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlacesCategoriesImplFromJson(json);

  // Required fields
  @override
  final String name;
  @override
  final String display_name;
  @override
  final String osm_key;
  @override
  final String osm_value;

  @override
  String toString() {
    return 'PlacesCategories(name: $name, display_name: $display_name, osm_key: $osm_key, osm_value: $osm_value)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlacesCategoriesImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.display_name, display_name) ||
                other.display_name == display_name) &&
            (identical(other.osm_key, osm_key) || other.osm_key == osm_key) &&
            (identical(other.osm_value, osm_value) ||
                other.osm_value == osm_value));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, display_name, osm_key, osm_value);

  /// Create a copy of PlacesCategories
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlacesCategoriesImplCopyWith<_$PlacesCategoriesImpl> get copyWith =>
      __$$PlacesCategoriesImplCopyWithImpl<_$PlacesCategoriesImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PlacesCategoriesImplToJson(this);
  }
}

abstract class _PlacesCategories implements PlacesCategories {
  const factory _PlacesCategories({
    required final String name,
    required final String display_name,
    required final String osm_key,
    required final String osm_value,
  }) = _$PlacesCategoriesImpl;

  factory _PlacesCategories.fromJson(Map<String, dynamic> json) =
      _$PlacesCategoriesImpl.fromJson;

  // Required fields
  @override
  String get name;
  @override
  String get display_name;
  @override
  String get osm_key;
  @override
  String get osm_value;

  /// Create a copy of PlacesCategories
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlacesCategoriesImplCopyWith<_$PlacesCategoriesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
