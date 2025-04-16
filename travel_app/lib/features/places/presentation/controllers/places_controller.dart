import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/features/places/data/repositories/places_repository.dart';
import 'package:travel_app/features/places/domain/place_model.dart';

// Define parameters for the provider using a simple class or tuple
// Using a class is often more readable
class PlacesParams {
  final int cityId;
  final String category;
  String? interests;
  final int page;
  final int size;

  PlacesParams({
    required this.cityId,
    required this.category,
    this.interests,
    required this.page,
    required this.size,
  });

  // Implement equality and hashCode if using this class as a key directly
  // or rely on Riverpod's default behavior if passing primitives via .family
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlacesParams &&
          runtimeType == other.runtimeType &&
          cityId == other.cityId &&
          category == other.category &&
          interests == other.interests &&
          page == other.page &&
          size == other.size;

  @override
  int get hashCode =>
      cityId.hashCode ^
      category.hashCode ^
      interests.hashCode ^
      page.hashCode ^
      size.hashCode;
}


// Provider to fetch places data
// Using autoDispose to clean up when not listened to
// Using family to pass parameters
final placesProvider = FutureProvider.autoDispose
    .family<PlacesResponse, PlacesParams>((ref, params) async {
  // Make sure the user is authenticated before fetching user-specific data
  // Although the interceptor adds the token, this prevents unnecessary calls
  // if the user logs out while the request is pending or being setup.
  // final authState = ref.watch(authControllerProvider);
  // if (authState != AuthState.authenticated) {
  //   throw Exception("User not authenticated"); // Or return empty list
  // }
  // This check might be redundant if routing already protects the screen

  final placesRepository = ref.watch(placesRepositoryProvider);
  print("--- Fetching places with params: ${params.cityId}, ${params.category}, ${params.interests} ---");
  return placesRepository.getBestPlaces(
    cityId: params.cityId,
    category: params.category,
    interests: params.interests ?? "",
    page: params.page,
    size: params.size,
  );
});