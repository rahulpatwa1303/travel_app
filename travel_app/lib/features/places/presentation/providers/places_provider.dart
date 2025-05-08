import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:travel_app/core/networking/lat_lng_model.dart';
import 'package:travel_app/features/places/data/repositories/cities_time.dart';
import 'package:travel_app/features/places/domain/city_detail_model.dart';
import 'package:travel_app/features/places/domain/place_by_city_model.dart';

import '../../data/repositories/places_repository.dart';
import '../../domain/top_place_model.dart';

part 'places_provider.g.dart'; // <--- Ensure this line exists

// ... other existing providers ...

class CachedLocalTime {
  final String timeString; // Raw string from API
  final DateTime expiresAt; // When the cache expires

  CachedLocalTime({required this.timeString, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

@riverpod // <--- Ensure the annotation exists
Future<TopPlacesPaginatedResponse> topPlaces(TopPlacesRef ref) async {
  print("topPlaces provider executing...");
  final placesRepository = ref.watch(placesRepositoryProvider);
  final topPlacesData = await placesRepository.getTopPlaces(
    offset: 10,
    limit: 10,
  );
  return topPlacesData;
}

// Function that retrieves data
@riverpod
Future<List<PlacesCategory>> placesCategories(
  AutoDisposeFutureProviderRef<List<PlacesCategory>> ref,
) async {
  final placesRepository = ref.watch(
    placesRepositoryProvider,
  ); // Adjust your repository provider if needed.
  final categoriesData =
      await placesRepository
          .getCategories(); // Ensure `getCategories` is a function in your repository
  return categoriesData;
}

@riverpod // Use riverpod_generator
Future<CityDetail> cityDetails(CityDetailsRef ref, int cityId) async {
  print("Executing cityDetails provider for ID: $cityId");
  // Watch the repository provider
  final placesRepository = ref.watch(placesRepositoryProvider);
  // Call the repository method
  final details = await placesRepository.getCityDetails(cityId);
  print("Received details for ID $cityId: ${details.name}");
  return details;
}

@riverpod
Future<List<PlaceByCity>> placesInCity(PlacesInCityRef ref, int cityId) async {
  print("Executing placesInCity provider for ID: $cityId");
  final placesRepository = ref.watch(placesRepositoryProvider);
  // You can pass sorting/limit options here if needed
  final places = await placesRepository.getPlacesInCity(cityId);
  print("Received ${places.length} places for city ID $cityId.");
  return places;
}
// Remember to run: flutter pub run build_runner build --delete-conflicting-outputs

@riverpod // autoDispose is default
Future<CachedLocalTime> currentLocalTime(
  CurrentLocalTimeRef ref,
  LatLng coordinates,
) async {
  // --- Caching Logic ---
  final cacheLink = ref.keepAlive();
  Timer? timer;
  ref.onDispose(() => timer?.cancel());
  ref.onResume(
    () =>
        timer = Timer(const Duration(minutes: 15), () {
          print(
            "Local time cache expired for $coordinates. Closing keepAlive link.",
          );
          cacheLink.close();
        }),
  );
  // Set initial timer
  timer = Timer(const Duration(minutes: 15), () {
    print(
      "Local time cache expired for $coordinates (Initial). Closing keepAlive link.",
    );
    cacheLink.close();
  });
  // --- End Caching Logic ---

  print(
    "PROVIDER: Fetching time for ${coordinates.latitude}, ${coordinates.longitude}",
  );
  try {
    // Call your actual API function to get the time string
    final timeString = await getCurrentTimeFromLatLng(
      coordinates.latitude,
      coordinates.longitude,
    );

    // Calculate expiry time
    final expiresAt = DateTime.now().add(const Duration(minutes: 15));
    print(
      "PROVIDER: Fetched time for ${coordinates.latitude}, ${coordinates.longitude}. Expires at $expiresAt",
    );

    // Return the data object
    return CachedLocalTime(timeString: timeString, expiresAt: expiresAt);
  } catch (e) {
    print(
      "PROVIDER: Error fetching time for ${coordinates.latitude}, ${coordinates.longitude}: $e",
    );
    // If the API call fails, we might want the provider to stay in error state
    // Or potentially return a previous value if available? For simplicity, just rethrow.
    // We might close the keepAlive link on error too if we don't want to cache errors.
    // cacheLink.close(); // Optional: uncomment to immediately allow disposal on error
    rethrow; // Rethrow the error to put the provider in AsyncError state
  }
}

@riverpod // Use riverpod_generator
Future<void> likeACity(CityDetailsRef ref, int cityId) async {
  print("Executing cityDetails provider for ID: $cityId");
  // Watch the repository provider
  final placesRepository = ref.watch(placesRepositoryProvider);
  // Call the repository method
  final details = await placesRepository.likeCity(cityId);
  return details;
}
