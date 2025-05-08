// features/places/presentation/providers/liked_cities_notifier.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Adjust path to your PlaceRepo and its provider
// Adjust path to your AuthController and its provider
import 'package:travel_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:travel_app/features/places/data/repositories/places_repository.dart';

class LikedCitiesNotifier extends AsyncNotifier<Set<int>> {
  // Helper to get PlaceRepo instance
  PlacesRepository get _placeRepo => ref.read(placesRepositoryProvider); // Ensure placeRepoProvider is defined

  @override
  Future<Set<int>> build() async {
    // Watch the authentication state from your existing AuthController
    final authState = ref.watch(authControllerProvider);

    // If the user is not authenticated, return an empty set.
    // This will also handle logout: when authState changes to unauthenticated,
    // this provider will rebuild and return an empty set.
    if (authState != AuthState.authenticated) {
      print("LikedCitiesNotifier: User not authenticated (state: $authState). Returning empty set.");
      return {};
    }

    // User is authenticated, proceed to fetch liked cities.
    // This will be called automatically when authState transitions to authenticated (on login).
    print("LikedCitiesNotifier: User authenticated. Fetching liked city IDs.");
    try {
      return await _placeRepo.fetchLikedCityIds();
    } catch (e, s) {
      print("LikedCitiesNotifier: Error fetching liked city IDs in build(): $e");
      // If a 401 error occurs here, your Dio interceptor should ideally
      // trigger a logout, which changes authState, and this provider rebuilds.
      // Propagate the error to be handled by AsyncValue.error.
      throw e;
    }
  }

  Future<void> likeCity(int cityId) async {
    // Ensure user is authenticated before attempting to like
    final authState = ref.read(authControllerProvider);
    if (authState != AuthState.authenticated) {
      print("LikedCitiesNotifier: Cannot like city. User not authenticated.");
      // Optionally, throw an error or display a message to the user
      return; // Or throw Exception("User not authenticated");
    }

    // Optimistic update: Add to current state immediately
    final currentStateValue = state.value ?? {};
    state = AsyncData(Set<int>.from(currentStateValue)..add(cityId));

    try {
      await _placeRepo.likeCity(cityId);
      // Optional: if API returns the new set of liked IDs, you can update state with it:
      // state = AsyncData(await _placeRepo.fetchLikedCityIds());
      // But if the optimistic update is reliable and API confirms, no need to refetch.
    } catch (e) {
      print("LikedCitiesNotifier: Failed to like city $cityId. Error: $e");
      // Rollback on error: Revert to previous state (without the new like)
      state = AsyncData(currentStateValue);
      throw e; // Re-throw to allow UI to handle it (e.g., show a snackbar)
    }
  }

  Future<void> dislikeCity(int cityId) async {
    final authState = ref.read(authControllerProvider);
    if (authState != AuthState.authenticated) {
      print("LikedCitiesNotifier: Cannot dislike city. User not authenticated.");
      return; // Or throw Exception("User not authenticated");
    }

    final currentStateValue = state.value ?? {};
    if (!currentStateValue.contains(cityId)) return; // Already not liked

    // Optimistic update: Remove from current state immediately
    state = AsyncData(Set<int>.from(currentStateValue)..remove(cityId));

    try {
      await _placeRepo.dislikeCity(cityId);
    } catch (e) {
      print("LikedCitiesNotifier: Failed to dislike city $cityId. Error: $e");
      // Rollback on error: Revert to previous state (with the city still liked)
      state = AsyncData(currentStateValue);
      throw e;
    }
  }

  // Method to explicitly refresh data, e.g., on app resume
  Future<void> refresh() async {
    final authState = ref.read(authControllerProvider);
    if (authState != AuthState.authenticated) {
      print("LikedCitiesNotifier: Refresh called, but user not authenticated. Setting empty set.");
      state = const AsyncData({}); // Ensure state is cleared if not authenticated
      return;
    }

    print("LikedCitiesNotifier: Refreshing liked cities...");
    state = const AsyncLoading(); // Set state to loading
    try {
      final likedIds = await _placeRepo.fetchLikedCityIds();
      state = AsyncData(likedIds);
    } catch (e, s) {
      print("LikedCitiesNotifier: Error during refresh: $e");
      state = AsyncError(e, s);
    }
  }

  // Helper method to check if a city is liked (can be used in UI)
  bool isCityLiked(int cityId) {
    return state.value?.contains(cityId) ?? false;
  }
}

// Define the provider
final likedCitiesProvider =
    AsyncNotifierProvider<LikedCitiesNotifier, Set<int>>(
  LikedCitiesNotifier.new,
);

// --- IMPORTANT: Ensure you have placeRepoProvider defined ---
// Example: (Put this in your place_repo.dart or a dedicated providers file)
// final dioProvider = Provider<Dio>((ref) => Dio()); // Your configured Dio instance
//
// final placeRepoProvider = Provider<PlaceRepo>((ref) {
//   final dio = ref.watch(dioProvider); // Assuming you have a dioProvider
//   return PlaceRepo(dio);
// });