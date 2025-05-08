// liked_cities_provider.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/features/places/data/repositories/places_repository.dart';
// Import your PlaceRepo and its provider

// Dummy auth provider for demonstration. Replace with your actual auth provider.
// It should tell us if the user is authenticated.
// e.g., enum AuthState { authenticated, unauthenticated, unknown }
// final authStateProvider = StateProvider<AuthState>((ref) => AuthState.unauthenticated);
// For simplicity, let's assume a boolean provider for now:
final isLoggedInProvider = StateProvider<bool>((ref) => false); // You'd update this on login/logout

class LikedCitiesNotifier extends AsyncNotifier<Set<int>> {
  PlacesRepository get _placeRepo => ref.read(placesRepositoryProvider);

  @override
  Future<Set<int>> build() async {
    // Listen to authentication state. If auth state changes, this provider will re-evaluate.
    final isLoggedIn = ref.watch(isLoggedInProvider);

    if (!isLoggedIn) {
      print("User not logged in. Returning empty set for liked cities.");
      return {}; // Return empty set if not logged in
    }

    // User is logged in, fetch their liked cities
    try {
      print("LikedCitiesNotifier: build() - fetching initial liked cities.");
      return await _placeRepo.fetchLikedCityIds();
    } catch (e, s) {
      print("LikedCitiesNotifier: Error in build(): $e");
      // You might want to handle specific errors, like 401, differently
      // or rethrow to let AsyncValue.error handle it.
      // For now, we let it become AsyncError.
      throw e; // Re-throw to propagate the error to the AsyncValue
    }
  }

  Future<void> likeCity(int cityId) async {
    // Optimistic update
    final previousState = state;
    state = AsyncData((state.value ?? {}).toSet()..add(cityId));

    try {
      await _placeRepo.likeCity(cityId);
      // No need to refetch if API call is source of truth and local state matches
      // If API returns the new set, you could update state with it:
      // state = AsyncData(await _placeRepo.fetchLikedCityIds());
    } catch (e) {
      // Rollback on error
      state = previousState;
      // Optionally, rethrow or handle the error (e.g., show a snackbar)
      print("Failed to like city $cityId: $e");
      // Consider re-throwing to allow UI to show an error message
      // throw e;
    }
  }

  Future<void> dislikeCity(int cityId) async {
    // Optimistic update
    final previousState = state;
    state = AsyncData((state.value ?? {}).toSet()..remove(cityId));

    try {
      await _placeRepo.dislikeCity(cityId);
    } catch (e) {
      // Rollback on error
      state = previousState;
      print("Failed to dislike city $cityId: $e");
      // throw e;
    }
  }

  // Method to explicitly refresh data
  Future<void> refresh() async {
    final isLoggedIn = ref.read(isLoggedInProvider);
    if (!isLoggedIn) {
      state = const AsyncData({});
      return;
    }
    state = const AsyncLoading(); // Set to loading
    try {
      state = AsyncData(await _placeRepo.fetchLikedCityIds());
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }

  // Helper method to check if a city is liked (can be used in UI)
  bool isCityLiked(int cityId) {
    return state.value?.contains(cityId) ?? false;
  }
}

final likedCitiesProvider =
    AsyncNotifierProvider<LikedCitiesNotifier, Set<int>>(
  LikedCitiesNotifier.new,
);