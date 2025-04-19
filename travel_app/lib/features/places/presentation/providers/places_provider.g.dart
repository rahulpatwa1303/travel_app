// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'places_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$topPlacesHash() => r'dbfb3f80848b5b24731b0f6eef3cee9ad643cd57';

/// See also [topPlaces].
@ProviderFor(topPlaces)
final topPlacesProvider =
    AutoDisposeFutureProvider<TopPlacesPaginatedResponse>.internal(
      topPlaces,
      name: r'topPlacesProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$topPlacesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TopPlacesRef = AutoDisposeFutureProviderRef<TopPlacesPaginatedResponse>;
String _$placesCategoriesHash() => r'62a647f3a3ade8ff6884a17ca3bca5e576afa634';

/// See also [placesCategories].
@ProviderFor(placesCategories)
final placesCategoriesProvider =
    AutoDisposeFutureProvider<List<PlacesCategory>>.internal(
      placesCategories,
      name: r'placesCategoriesProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$placesCategoriesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PlacesCategoriesRef =
    AutoDisposeFutureProviderRef<List<PlacesCategory>>;
String _$cityDetailsHash() => r'd6a72c81b0d92898d9a974f8edbb1e06afe236fa';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [cityDetails].
@ProviderFor(cityDetails)
const cityDetailsProvider = CityDetailsFamily();

/// See also [cityDetails].
class CityDetailsFamily extends Family<AsyncValue<CityDetail>> {
  /// See also [cityDetails].
  const CityDetailsFamily();

  /// See also [cityDetails].
  CityDetailsProvider call(int cityId) {
    return CityDetailsProvider(cityId);
  }

  @override
  CityDetailsProvider getProviderOverride(
    covariant CityDetailsProvider provider,
  ) {
    return call(provider.cityId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'cityDetailsProvider';
}

/// See also [cityDetails].
class CityDetailsProvider extends AutoDisposeFutureProvider<CityDetail> {
  /// See also [cityDetails].
  CityDetailsProvider(int cityId)
    : this._internal(
        (ref) => cityDetails(ref as CityDetailsRef, cityId),
        from: cityDetailsProvider,
        name: r'cityDetailsProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$cityDetailsHash,
        dependencies: CityDetailsFamily._dependencies,
        allTransitiveDependencies: CityDetailsFamily._allTransitiveDependencies,
        cityId: cityId,
      );

  CityDetailsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.cityId,
  }) : super.internal();

  final int cityId;

  @override
  Override overrideWith(
    FutureOr<CityDetail> Function(CityDetailsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CityDetailsProvider._internal(
        (ref) => create(ref as CityDetailsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        cityId: cityId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<CityDetail> createElement() {
    return _CityDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CityDetailsProvider && other.cityId == cityId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, cityId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CityDetailsRef on AutoDisposeFutureProviderRef<CityDetail> {
  /// The parameter `cityId` of this provider.
  int get cityId;
}

class _CityDetailsProviderElement
    extends AutoDisposeFutureProviderElement<CityDetail>
    with CityDetailsRef {
  _CityDetailsProviderElement(super.provider);

  @override
  int get cityId => (origin as CityDetailsProvider).cityId;
}

String _$placesInCityHash() => r'fa6dc7b9c550f06cb9762321082ca01719e5f4c8';

/// See also [placesInCity].
@ProviderFor(placesInCity)
const placesInCityProvider = PlacesInCityFamily();

/// See also [placesInCity].
class PlacesInCityFamily extends Family<AsyncValue<List<PlaceByCity>>> {
  /// See also [placesInCity].
  const PlacesInCityFamily();

  /// See also [placesInCity].
  PlacesInCityProvider call(int cityId) {
    return PlacesInCityProvider(cityId);
  }

  @override
  PlacesInCityProvider getProviderOverride(
    covariant PlacesInCityProvider provider,
  ) {
    return call(provider.cityId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'placesInCityProvider';
}

/// See also [placesInCity].
class PlacesInCityProvider
    extends AutoDisposeFutureProvider<List<PlaceByCity>> {
  /// See also [placesInCity].
  PlacesInCityProvider(int cityId)
    : this._internal(
        (ref) => placesInCity(ref as PlacesInCityRef, cityId),
        from: placesInCityProvider,
        name: r'placesInCityProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$placesInCityHash,
        dependencies: PlacesInCityFamily._dependencies,
        allTransitiveDependencies:
            PlacesInCityFamily._allTransitiveDependencies,
        cityId: cityId,
      );

  PlacesInCityProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.cityId,
  }) : super.internal();

  final int cityId;

  @override
  Override overrideWith(
    FutureOr<List<PlaceByCity>> Function(PlacesInCityRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PlacesInCityProvider._internal(
        (ref) => create(ref as PlacesInCityRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        cityId: cityId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<PlaceByCity>> createElement() {
    return _PlacesInCityProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PlacesInCityProvider && other.cityId == cityId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, cityId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PlacesInCityRef on AutoDisposeFutureProviderRef<List<PlaceByCity>> {
  /// The parameter `cityId` of this provider.
  int get cityId;
}

class _PlacesInCityProviderElement
    extends AutoDisposeFutureProviderElement<List<PlaceByCity>>
    with PlacesInCityRef {
  _PlacesInCityProviderElement(super.provider);

  @override
  int get cityId => (origin as PlacesInCityProvider).cityId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
