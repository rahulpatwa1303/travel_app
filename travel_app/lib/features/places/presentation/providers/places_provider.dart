import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:travel_app/features/places/domain/city_detail_model.dart';
import 'package:travel_app/features/places/domain/place_by_city_model.dart';
import 'package:travel_app/features/places/domain/place_model.dart';

import '../../data/repositories/places_repository.dart';
import '../../domain/top_place_model.dart';

part 'places_provider.g.dart'; // <--- Ensure this line exists

// ... other existing providers ...

@riverpod // <--- Ensure the annotation exists
Future<TopPlacesPaginatedResponse> topPlaces(TopPlacesRef ref) async {
  print("topPlaces provider executing...");
  final placesRepository = ref.watch(placesRepositoryProvider);
  final topPlacesData = await placesRepository.getTopPlaces(offset:10,limit: 10);
  return topPlacesData;
}
// Function that retrieves data
@riverpod
Future<List<PlacesCategory>> placesCategories(AutoDisposeFutureProviderRef<List<PlacesCategory>> ref) async {
  final placesRepository = ref.watch(placesRepositoryProvider);  // Adjust your repository provider if needed.
  final categoriesData = await placesRepository.getCategories();  // Ensure `getCategories` is a function in your repository
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