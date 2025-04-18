// places_notifier.dart (or top_places_notifier.dart)
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/features/places/data/repositories/places_repository.dart';
import 'package:travel_app/features/places/domain/place_state.dart';
import 'package:travel_app/features/places/domain/top_place_model.dart';

// No need for PlaceFilterParams if getTopPlaces doesn't use filters

// The StateNotifier for Top Places
class PaginatedTopPlacesNotifier extends StateNotifier<PaginatedPlacesState> {
  final PlacesRepository _placesRepository;
  // Use the limit your API expects (e.g., 10 or 30)
  static const int _limit = 10; // Or 30, based on your info
  Timer? _imageUpdateTimer;
  static const Duration _imageCheckInterval = Duration(seconds: 60);
  static const Duration _initialImageCheckDelay = Duration(seconds: 30);

  PaginatedTopPlacesNotifier(this._placesRepository)
    : super(const PaginatedPlacesState()) {
    // Initial state
    fetchInitialPlaces(); // Fetch first page on creation
  }

  @override
  void dispose() {
    _imageUpdateTimer?.cancel();
    super.dispose();
  }

  // --- Modified Initial Fetch ---
  Future<void> fetchInitialData() async {
    if (state.isLoadingInitial) return;
    state = state.copyWith(
      isLoadingInitial: true,
      initialError: null,
      likeError: null,
    );

    try {
      // Fetch places and favorite IDs concurrently
      final results = await Future.wait([
        _placesRepository.getTopPlaces(offset: 0, limit: _limit),
        _placesRepository.getFavoritePlaceIds(),
      ]);

      final placesResponse = results[0] as TopPlacesPaginatedResponse;
      final favoriteIds = results[1] as Set<int>;

      final newPendingImageIds = _findPendingImageIds(placesResponse.places);

      state = state.copyWith(
        places: placesResponse.places,
        nextOffset: placesResponse.places.length,
        hasMore: placesResponse.hasMore,
        favoritePlaceIds: favoriteIds, // Store favorite IDs
        pendingImagePlaceIds: newPendingImageIds,
        isLoadingInitial: false,
      );

      _scheduleImageUpdateCheckIfNeeded(isInitialSchedule: true);
    } catch (e) {
      state = state.copyWith(
        isLoadingInitial: false,
        initialError: "Failed to load initial data: $e",
      );
      print("Error fetching initial data: $e");
    }
  }
  // --- End Modified Initial Fetch ---

  Set<int> _findPendingImageIds(List<TopPlace> places) {
    return {1};
  }

  // Image Update Check Logic (if used)
  void _scheduleImageUpdateCheckIfNeeded({bool isInitialSchedule = false}) {
    /* ... as before ... */
  }

  Future<void> fetchInitialPlaces() async {
    if (state.isLoadingInitial) return;

    state = state.copyWith(isLoadingInitial: true, initialError: null);

    try {
      // Fetch first page using offset 0
      final response = await _placesRepository.getTopPlaces(
        offset: 0, // Always start at offset 0
        limit: _limit,
      );

      state = state.copyWith(
        places: response.places,
        // Next offset is the number of items just fetched
        nextOffset: response.places.length,
        // Use hasMore from the repository response
        hasMore: response.hasMore,
        isLoadingInitial: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingInitial: false,
        initialError: "Failed to load top places: $e",
      );
      print("Error fetching initial top places: $e");
    }
  }

  // --- Like/Dislike Logic ---

  Future<void> toggleLikeStatus(int placeId, bool currentIsLiked) async {
    // Prevent action if already liking/disliking this item
    if (state.isLikingPlace(placeId)) return;

    final originalFavoriteIds = state.favoritePlaceIds;
    Set<int> optimisticFavoriteIds;

    // Update loading state
    state = state.copyWith(
      placesBeingLiked: {...state.placesBeingLiked, placeId},
      likeError: null, // Clear previous like errors
    );

    try {
      if (currentIsLiked) {
        // --- Dislike Logic ---
        print("Optimistically disliking $placeId");
        optimisticFavoriteIds = Set.from(originalFavoriteIds)..remove(placeId);
        state = state.copyWith(
          favoritePlaceIds: optimisticFavoriteIds,
        ); // Optimistic UI update
        await _placesRepository.dislikePlace(placeId);
        print("Successfully disliked $placeId via API");
      } else {
        // --- Like Logic ---
        print("Optimistically liking $placeId");
        optimisticFavoriteIds = Set.from(originalFavoriteIds)..add(placeId);
        state = state.copyWith(
          favoritePlaceIds: optimisticFavoriteIds,
        ); // Optimistic UI update
        await _placesRepository.likePlace(placeId);
        print("Successfully liked $placeId via API");
      }
      // If API call succeeds, the optimistic state is now the correct state.
    } catch (e) {
      print("Error toggling like status for $placeId: $e. Reverting state.");
      // Revert state on error
      state = state.copyWith(
        favoritePlaceIds: originalFavoriteIds, // Put back original set
        likeError:
            "Failed to ${currentIsLiked ? 'dislike' : 'like'} place. Please try again.",
      );
    } finally {
      // Always remove from loading state, whether success or failure
      state = state.copyWith(
        placesBeingLiked: Set.from(state.placesBeingLiked)..remove(placeId),
      );
    }
  }
  // --- End Like/Dislike Logic ---

  Future<void> fetchMorePlaces() async {
    if (!state.canLoadMore) {
      print(
        "Cannot load more top places: isLoadingInitial=${state.isLoadingInitial}, isLoadingMore=${state.isLoadingMore}, hasMore=${state.hasMore}",
      );
      return;
    }

    state = state.copyWith(isLoadingMore: true, paginationError: null);

    try {
      // Fetch next page using the current state's nextOffset
      final response = await _placesRepository.getTopPlaces(
        offset: state.nextOffset, // Use the stored offset
        limit: _limit,
      );

      state = state.copyWith(
        // Append new places to the existing list
        places: [...state.places, ...response.places],
        // Update next offset by adding the count of newly fetched items
        nextOffset: state.nextOffset + response.places.length,
        // Update hasMore based on the latest response
        hasMore: response.hasMore,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        paginationError: "Failed to load more top places: $e",
        // Important: Decide if an error stops future attempts.
        // Setting hasMore = false stops it. Keeping it true allows retry on next scroll.
        // hasMore: false,
      );
      print("Error fetching more top places: $e");
    }
  }

  // Optional: Method to refresh (refetch from offset 0)
  Future<void> refresh() async {
    // Reset state completely and fetch initial page
    state = const PaginatedPlacesState(); // Reset state
    await fetchInitialPlaces(); // Fetch again
  }
}

// The Provider - No longer needs .family if filters aren't used
final paginatedTopPlacesProvider = StateNotifierProvider.autoDispose<
  PaginatedTopPlacesNotifier,
  PaginatedPlacesState
>((ref) {
  final placesRepository = ref.watch(placesRepositoryProvider);
  return PaginatedTopPlacesNotifier(placesRepository);
});
