// lib/features/places/presentation/providers/paginated_places_provider.dart (New or modified provider)
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/features/places/data/repositories/places_repository.dart';
import 'package:travel_app/features/places/domain/place_model.dart';
// Import your models and repository/service

// Parameter class for the provider family
// (You might already have this as CategoryPlacesParams)
class PaginatedPlacesParams {
  final int cityId;
  final String category;
  final String interests;
  // Size is fixed per page for this provider, page is managed internally

  PaginatedPlacesParams({
    required this.cityId,
    required this.category,
    required this.interests,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaginatedPlacesParams &&
          runtimeType == other.runtimeType &&
          cityId == other.cityId &&
          category == other.category &&
          interests == other.interests;

  @override
  int get hashCode => cityId.hashCode ^ category.hashCode ^ interests.hashCode;
}

// State for our notifier
class PaginatedPlacesState {
  final List<Place> places;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final int currentPage;
  final String? errorMessage;

  PaginatedPlacesState({
    this.places = const [],
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.errorMessage,
  });

  PaginatedPlacesState copyWith({
    List<Place>? places,
    bool? isLoadingMore,
    bool? hasReachedMax,
    int? currentPage,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return PaginatedPlacesState(
      places: places ?? this.places,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class PaginatedPlacesNotifier extends FamilyAsyncNotifier<PaginatedPlacesState, PaginatedPlacesParams> {
  // Define how many items per page (matches your 3x3 grid desire)
  static const int _itemsPerPage = 9;

  PlacesRepository get _repository => ref.read(placesRepositoryProvider); // Your place repository

  @override
  Future<PaginatedPlacesState> build(PaginatedPlacesParams arg) async {
    // Initial fetch for page 1
    // 'arg' holds cityId, category, interests
    state = const AsyncValue.loading(); // Set initial state to loading
    return await _fetchPage(arg, 1);
  }

  Future<PaginatedPlacesState> _fetchPage(PaginatedPlacesParams params, int pageToFetch) async {
    try {
      final PlacesResponse response = await _repository.getPlacesListByCategory(
        category: params.category,
        interests: params.interests,
        page: pageToFetch,
        size: _itemsPerPage,
      );

      final bool hasReachedMax = response.places.isEmpty || pageToFetch >= response.totalPages;

      // If it's the first page, replace data. Otherwise, append.
      final List<Place> newPlacesList = pageToFetch == 1
          ? response.places
          : [ ...state.value?.places ?? [], ...response.places]; // Use current places if available

      return PaginatedPlacesState(
        places: newPlacesList,
        currentPage: pageToFetch,
        hasReachedMax: hasReachedMax,
        isLoadingMore: false,
      );
    } catch (e) {
      // If it's the first page, the error will be handled by AsyncValue.error
      // If loading more, we update the state with an error message
      if (pageToFetch > 1 && state.value != null) {
        return state.value!.copyWith(isLoadingMore: false, errorMessage: e.toString());
      }
      rethrow; // Rethrow for initial load to be caught by AsyncValue.error
    }
  }

  Future<void> fetchNextPage() async {
    // Ensure 'state.value' is not null and we are not already loading or at max
    if (state.value == null || state.value!.isLoadingMore || state.value!.hasReachedMax) {
      return;
    }

    // Update state to show loading more indicator
    state = AsyncData(state.value!.copyWith(isLoadingMore: true, clearErrorMessage: true));

    final nextPage = state.value!.currentPage + 1;
    final PaginatedPlacesState nextPageData = await _fetchPage(arg, nextPage); // 'arg' is available from FamilyAsyncNotifier

    // Update the state with the new data (or error if one occurred)
    state = AsyncData(nextPageData);
  }

  // Call this when parameters (cityId, category, interests) change to reset and fetch page 1
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = AsyncData(await _fetchPage(arg, 1));
  }
}

// The provider
final paginatedPlacesProvider = AsyncNotifierProvider.family<
    PaginatedPlacesNotifier, PaginatedPlacesState, PaginatedPlacesParams>(
  PaginatedPlacesNotifier.new,
);

// You'll also need your PlaceRepository provider
// final placeRepositoryProvider = Provider<PlaceRepository>((ref) {
//   return PlaceRepository(ref.watch(dioProvider)); // Assuming PlaceRepository takes Dio
// });