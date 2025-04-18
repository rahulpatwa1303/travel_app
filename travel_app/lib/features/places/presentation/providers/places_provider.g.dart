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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
