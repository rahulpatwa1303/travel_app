// place_state.dart (or a new top_places_state.dart)
import 'package:freezed_annotation/freezed_annotation.dart';
// Import the correct model
import 'package:travel_app/features/places/domain/top_place_model.dart';

part 'place_state.freezed.dart'; // Keep or rename if you changed the file name

@freezed
class PaginatedPlacesState with _$PaginatedPlacesState {
  const factory PaginatedPlacesState({
    @Default([]) List<TopPlace> places, // Use TopPlace model
    @Default(0) int nextOffset, // Offset for the *next* fetch, starts at 0
    @Default(true) bool hasMore, // Assume more initially
    @Default(false) bool isLoadingInitial,
    @Default(false) bool isLoadingMore,
    String? initialError,
    String? paginationError,
    @Default({}) Set<int> pendingImagePlaceIds, // Keep if using image polling
    // --- NEW: Store favorite IDs and like operation error ---
    @Default({}) Set<int> favoritePlaceIds,
    String? likeError,
    @Default({})
    Set<int> placesBeingLiked, // Optional: Track loading state per item
    // --- End NEW ---

    // Remove filter params if getTopPlaces doesn't use them
    // required int cityId,
    // required String category,
    // required String interests,
  }) = _PaginatedPlacesState;

  // Helper to check if it's okay to fetch more
  const PaginatedPlacesState._(); // Add private constructor for getter
  bool get canLoadMore => !isLoadingInitial && !isLoadingMore && hasMore;
  bool isLikingPlace(int placeId) => placesBeingLiked.contains(placeId);

}

// Run build_runner: flutter pub run build_runner build --delete-conflicting-outputs
