// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'place_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$PaginatedPlacesState {
  List<TopPlace> get places =>
      throw _privateConstructorUsedError; // Use TopPlace model
  int get nextOffset =>
      throw _privateConstructorUsedError; // Offset for the *next* fetch, starts at 0
  bool get hasMore =>
      throw _privateConstructorUsedError; // Assume more initially
  bool get isLoadingInitial => throw _privateConstructorUsedError;
  bool get isLoadingMore => throw _privateConstructorUsedError;
  String? get initialError => throw _privateConstructorUsedError;
  String? get paginationError => throw _privateConstructorUsedError;
  Set<int> get pendingImagePlaceIds =>
      throw _privateConstructorUsedError; // Keep if using image polling
  // --- NEW: Store favorite IDs and like operation error ---
  Set<int> get favoritePlaceIds => throw _privateConstructorUsedError;
  String? get likeError => throw _privateConstructorUsedError;
  Set<int> get placesBeingLiked => throw _privateConstructorUsedError;

  /// Create a copy of PaginatedPlacesState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaginatedPlacesStateCopyWith<PaginatedPlacesState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaginatedPlacesStateCopyWith<$Res> {
  factory $PaginatedPlacesStateCopyWith(
    PaginatedPlacesState value,
    $Res Function(PaginatedPlacesState) then,
  ) = _$PaginatedPlacesStateCopyWithImpl<$Res, PaginatedPlacesState>;
  @useResult
  $Res call({
    List<TopPlace> places,
    int nextOffset,
    bool hasMore,
    bool isLoadingInitial,
    bool isLoadingMore,
    String? initialError,
    String? paginationError,
    Set<int> pendingImagePlaceIds,
    Set<int> favoritePlaceIds,
    String? likeError,
    Set<int> placesBeingLiked,
  });
}

/// @nodoc
class _$PaginatedPlacesStateCopyWithImpl<
  $Res,
  $Val extends PaginatedPlacesState
>
    implements $PaginatedPlacesStateCopyWith<$Res> {
  _$PaginatedPlacesStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaginatedPlacesState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? places = null,
    Object? nextOffset = null,
    Object? hasMore = null,
    Object? isLoadingInitial = null,
    Object? isLoadingMore = null,
    Object? initialError = freezed,
    Object? paginationError = freezed,
    Object? pendingImagePlaceIds = null,
    Object? favoritePlaceIds = null,
    Object? likeError = freezed,
    Object? placesBeingLiked = null,
  }) {
    return _then(
      _value.copyWith(
            places:
                null == places
                    ? _value.places
                    : places // ignore: cast_nullable_to_non_nullable
                        as List<TopPlace>,
            nextOffset:
                null == nextOffset
                    ? _value.nextOffset
                    : nextOffset // ignore: cast_nullable_to_non_nullable
                        as int,
            hasMore:
                null == hasMore
                    ? _value.hasMore
                    : hasMore // ignore: cast_nullable_to_non_nullable
                        as bool,
            isLoadingInitial:
                null == isLoadingInitial
                    ? _value.isLoadingInitial
                    : isLoadingInitial // ignore: cast_nullable_to_non_nullable
                        as bool,
            isLoadingMore:
                null == isLoadingMore
                    ? _value.isLoadingMore
                    : isLoadingMore // ignore: cast_nullable_to_non_nullable
                        as bool,
            initialError:
                freezed == initialError
                    ? _value.initialError
                    : initialError // ignore: cast_nullable_to_non_nullable
                        as String?,
            paginationError:
                freezed == paginationError
                    ? _value.paginationError
                    : paginationError // ignore: cast_nullable_to_non_nullable
                        as String?,
            pendingImagePlaceIds:
                null == pendingImagePlaceIds
                    ? _value.pendingImagePlaceIds
                    : pendingImagePlaceIds // ignore: cast_nullable_to_non_nullable
                        as Set<int>,
            favoritePlaceIds:
                null == favoritePlaceIds
                    ? _value.favoritePlaceIds
                    : favoritePlaceIds // ignore: cast_nullable_to_non_nullable
                        as Set<int>,
            likeError:
                freezed == likeError
                    ? _value.likeError
                    : likeError // ignore: cast_nullable_to_non_nullable
                        as String?,
            placesBeingLiked:
                null == placesBeingLiked
                    ? _value.placesBeingLiked
                    : placesBeingLiked // ignore: cast_nullable_to_non_nullable
                        as Set<int>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PaginatedPlacesStateImplCopyWith<$Res>
    implements $PaginatedPlacesStateCopyWith<$Res> {
  factory _$$PaginatedPlacesStateImplCopyWith(
    _$PaginatedPlacesStateImpl value,
    $Res Function(_$PaginatedPlacesStateImpl) then,
  ) = __$$PaginatedPlacesStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<TopPlace> places,
    int nextOffset,
    bool hasMore,
    bool isLoadingInitial,
    bool isLoadingMore,
    String? initialError,
    String? paginationError,
    Set<int> pendingImagePlaceIds,
    Set<int> favoritePlaceIds,
    String? likeError,
    Set<int> placesBeingLiked,
  });
}

/// @nodoc
class __$$PaginatedPlacesStateImplCopyWithImpl<$Res>
    extends _$PaginatedPlacesStateCopyWithImpl<$Res, _$PaginatedPlacesStateImpl>
    implements _$$PaginatedPlacesStateImplCopyWith<$Res> {
  __$$PaginatedPlacesStateImplCopyWithImpl(
    _$PaginatedPlacesStateImpl _value,
    $Res Function(_$PaginatedPlacesStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaginatedPlacesState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? places = null,
    Object? nextOffset = null,
    Object? hasMore = null,
    Object? isLoadingInitial = null,
    Object? isLoadingMore = null,
    Object? initialError = freezed,
    Object? paginationError = freezed,
    Object? pendingImagePlaceIds = null,
    Object? favoritePlaceIds = null,
    Object? likeError = freezed,
    Object? placesBeingLiked = null,
  }) {
    return _then(
      _$PaginatedPlacesStateImpl(
        places:
            null == places
                ? _value._places
                : places // ignore: cast_nullable_to_non_nullable
                    as List<TopPlace>,
        nextOffset:
            null == nextOffset
                ? _value.nextOffset
                : nextOffset // ignore: cast_nullable_to_non_nullable
                    as int,
        hasMore:
            null == hasMore
                ? _value.hasMore
                : hasMore // ignore: cast_nullable_to_non_nullable
                    as bool,
        isLoadingInitial:
            null == isLoadingInitial
                ? _value.isLoadingInitial
                : isLoadingInitial // ignore: cast_nullable_to_non_nullable
                    as bool,
        isLoadingMore:
            null == isLoadingMore
                ? _value.isLoadingMore
                : isLoadingMore // ignore: cast_nullable_to_non_nullable
                    as bool,
        initialError:
            freezed == initialError
                ? _value.initialError
                : initialError // ignore: cast_nullable_to_non_nullable
                    as String?,
        paginationError:
            freezed == paginationError
                ? _value.paginationError
                : paginationError // ignore: cast_nullable_to_non_nullable
                    as String?,
        pendingImagePlaceIds:
            null == pendingImagePlaceIds
                ? _value._pendingImagePlaceIds
                : pendingImagePlaceIds // ignore: cast_nullable_to_non_nullable
                    as Set<int>,
        favoritePlaceIds:
            null == favoritePlaceIds
                ? _value._favoritePlaceIds
                : favoritePlaceIds // ignore: cast_nullable_to_non_nullable
                    as Set<int>,
        likeError:
            freezed == likeError
                ? _value.likeError
                : likeError // ignore: cast_nullable_to_non_nullable
                    as String?,
        placesBeingLiked:
            null == placesBeingLiked
                ? _value._placesBeingLiked
                : placesBeingLiked // ignore: cast_nullable_to_non_nullable
                    as Set<int>,
      ),
    );
  }
}

/// @nodoc

class _$PaginatedPlacesStateImpl extends _PaginatedPlacesState {
  const _$PaginatedPlacesStateImpl({
    final List<TopPlace> places = const [],
    this.nextOffset = 0,
    this.hasMore = true,
    this.isLoadingInitial = false,
    this.isLoadingMore = false,
    this.initialError,
    this.paginationError,
    final Set<int> pendingImagePlaceIds = const {},
    final Set<int> favoritePlaceIds = const {},
    this.likeError,
    final Set<int> placesBeingLiked = const {},
  }) : _places = places,
       _pendingImagePlaceIds = pendingImagePlaceIds,
       _favoritePlaceIds = favoritePlaceIds,
       _placesBeingLiked = placesBeingLiked,
       super._();

  final List<TopPlace> _places;
  @override
  @JsonKey()
  List<TopPlace> get places {
    if (_places is EqualUnmodifiableListView) return _places;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_places);
  }

  // Use TopPlace model
  @override
  @JsonKey()
  final int nextOffset;
  // Offset for the *next* fetch, starts at 0
  @override
  @JsonKey()
  final bool hasMore;
  // Assume more initially
  @override
  @JsonKey()
  final bool isLoadingInitial;
  @override
  @JsonKey()
  final bool isLoadingMore;
  @override
  final String? initialError;
  @override
  final String? paginationError;
  final Set<int> _pendingImagePlaceIds;
  @override
  @JsonKey()
  Set<int> get pendingImagePlaceIds {
    if (_pendingImagePlaceIds is EqualUnmodifiableSetView)
      return _pendingImagePlaceIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_pendingImagePlaceIds);
  }

  // Keep if using image polling
  // --- NEW: Store favorite IDs and like operation error ---
  final Set<int> _favoritePlaceIds;
  // Keep if using image polling
  // --- NEW: Store favorite IDs and like operation error ---
  @override
  @JsonKey()
  Set<int> get favoritePlaceIds {
    if (_favoritePlaceIds is EqualUnmodifiableSetView) return _favoritePlaceIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_favoritePlaceIds);
  }

  @override
  final String? likeError;
  final Set<int> _placesBeingLiked;
  @override
  @JsonKey()
  Set<int> get placesBeingLiked {
    if (_placesBeingLiked is EqualUnmodifiableSetView) return _placesBeingLiked;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_placesBeingLiked);
  }

  @override
  String toString() {
    return 'PaginatedPlacesState(places: $places, nextOffset: $nextOffset, hasMore: $hasMore, isLoadingInitial: $isLoadingInitial, isLoadingMore: $isLoadingMore, initialError: $initialError, paginationError: $paginationError, pendingImagePlaceIds: $pendingImagePlaceIds, favoritePlaceIds: $favoritePlaceIds, likeError: $likeError, placesBeingLiked: $placesBeingLiked)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaginatedPlacesStateImpl &&
            const DeepCollectionEquality().equals(other._places, _places) &&
            (identical(other.nextOffset, nextOffset) ||
                other.nextOffset == nextOffset) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore) &&
            (identical(other.isLoadingInitial, isLoadingInitial) ||
                other.isLoadingInitial == isLoadingInitial) &&
            (identical(other.isLoadingMore, isLoadingMore) ||
                other.isLoadingMore == isLoadingMore) &&
            (identical(other.initialError, initialError) ||
                other.initialError == initialError) &&
            (identical(other.paginationError, paginationError) ||
                other.paginationError == paginationError) &&
            const DeepCollectionEquality().equals(
              other._pendingImagePlaceIds,
              _pendingImagePlaceIds,
            ) &&
            const DeepCollectionEquality().equals(
              other._favoritePlaceIds,
              _favoritePlaceIds,
            ) &&
            (identical(other.likeError, likeError) ||
                other.likeError == likeError) &&
            const DeepCollectionEquality().equals(
              other._placesBeingLiked,
              _placesBeingLiked,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_places),
    nextOffset,
    hasMore,
    isLoadingInitial,
    isLoadingMore,
    initialError,
    paginationError,
    const DeepCollectionEquality().hash(_pendingImagePlaceIds),
    const DeepCollectionEquality().hash(_favoritePlaceIds),
    likeError,
    const DeepCollectionEquality().hash(_placesBeingLiked),
  );

  /// Create a copy of PaginatedPlacesState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaginatedPlacesStateImplCopyWith<_$PaginatedPlacesStateImpl>
  get copyWith =>
      __$$PaginatedPlacesStateImplCopyWithImpl<_$PaginatedPlacesStateImpl>(
        this,
        _$identity,
      );
}

abstract class _PaginatedPlacesState extends PaginatedPlacesState {
  const factory _PaginatedPlacesState({
    final List<TopPlace> places,
    final int nextOffset,
    final bool hasMore,
    final bool isLoadingInitial,
    final bool isLoadingMore,
    final String? initialError,
    final String? paginationError,
    final Set<int> pendingImagePlaceIds,
    final Set<int> favoritePlaceIds,
    final String? likeError,
    final Set<int> placesBeingLiked,
  }) = _$PaginatedPlacesStateImpl;
  const _PaginatedPlacesState._() : super._();

  @override
  List<TopPlace> get places; // Use TopPlace model
  @override
  int get nextOffset; // Offset for the *next* fetch, starts at 0
  @override
  bool get hasMore; // Assume more initially
  @override
  bool get isLoadingInitial;
  @override
  bool get isLoadingMore;
  @override
  String? get initialError;
  @override
  String? get paginationError;
  @override
  Set<int> get pendingImagePlaceIds; // Keep if using image polling
  // --- NEW: Store favorite IDs and like operation error ---
  @override
  Set<int> get favoritePlaceIds;
  @override
  String? get likeError;
  @override
  Set<int> get placesBeingLiked;

  /// Create a copy of PaginatedPlacesState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaginatedPlacesStateImplCopyWith<_$PaginatedPlacesStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}
