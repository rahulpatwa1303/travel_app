// lib/features/places/presentation/providers/paginated_category_places_provider.dart (New File)
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/features/places/data/repositories/places_repository.dart';
import 'package:travel_app/features/places/domain/place_model.dart';

// Parameter class for the provider family
class CategoryPlacesParams {
  // You might already have this or a similar one
  final int? cityId;
  final String category; // OSM value or API key for category
  final String interests; // If your API uses this for filtering category places

  CategoryPlacesParams({
    this.cityId,
    required this.category,
    required this.interests,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryPlacesParams &&
          runtimeType == other.runtimeType &&
          cityId == other.cityId &&
          category == other.category &&
          interests == other.interests;

  @override
  int get hashCode => cityId.hashCode ^ category.hashCode ^ interests.hashCode;
}

// State for our notifier (can reuse PaginatedPlacesState if suitable or create a specific one)
// For now, let's assume PaginatedPlacesState can be reused if it holds List<Place> and pagination fields.
// If Place model for categories is different, create a new state object.
// Let's use a generic name if the structure is the same:
class PaginatedListState<T> {
  // Generic state
  final List<T> items;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final int currentPage;
  final String? errorMessage;

  PaginatedListState({
    this.items = const [],
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.errorMessage,
  });

  PaginatedListState<T> copyWith({
    List<T>? items,
    bool? isLoadingMore,
    bool? hasReachedMax,
    int? currentPage,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return PaginatedListState<T>(
      items: items ?? this.items,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class PaginatedCategoryPlacesNotifier
    extends
        FamilyAsyncNotifier<PaginatedListState<Place>, CategoryPlacesParams> {
  static const int _itemsPerPage =
      9; // This is correct for a 3x3 grid per "page"

  PlacesRepository get _repository => ref.read(placesRepositoryProvider);

  @override
  Future<PaginatedListState<Place>> build(CategoryPlacesParams arg) async {
    return await _fetchPage(arg, 1);
  }

  Future<PaginatedListState<Place>> _fetchPage(
    CategoryPlacesParams params,
    int pageToFetch,
  ) async {
    try {
      final PlacesResponse response = await _repository.getPlacesListByCategory(
        category: params.category,
        interests: params.interests,
        page: pageToFetch,
        size: _itemsPerPage, // Fetching 9 items
      );

      final bool hasReachedMax =
          response.places.isEmpty || (response.places.length < _itemsPerPage);

      final currentStateValue = state.valueOrNull;
      final List<Place> currentPlaces = currentStateValue?.items ?? [];

      // All fetched items are part of the flat list in the state
      final List<Place> newTotalPlacesList =
          pageToFetch == 1
              ? response.places
              : [...currentPlaces, ...response.places];

      return PaginatedListState<Place>(
        items: newTotalPlacesList, // This list will grow with all items
        currentPage: pageToFetch,
        hasReachedMax: hasReachedMax,
        isLoadingMore: false,
      );
    } catch (e, s) {
      print(
        "Error fetching category places page $pageToFetch for ${params.category}: $e \n$s",
      );
      final currentStateValue = state.valueOrNull;
      if (pageToFetch > 1 && currentStateValue != null) {
        return currentStateValue.copyWith(
          isLoadingMore: false,
          errorMessage: e.toString(),
        );
      }
      rethrow;
    }
  }

  Future<void> fetchNextPage() async {
    final currentStateValue = state.valueOrNull;
    if (currentStateValue == null ||
        currentStateValue.isLoadingMore ||
        currentStateValue.hasReachedMax) {
      return;
    }
    state = AsyncData(
      currentStateValue.copyWith(isLoadingMore: true, clearErrorMessage: true),
    );
    final nextPage = currentStateValue.currentPage + 1;
    final PaginatedListState<Place> nextPageData = await _fetchPage(
      arg,
      nextPage,
    );
    state = AsyncData(nextPageData);
  }
}

// The provider
final paginatedCategoryPlacesProvider = AsyncNotifierProvider.family<
  PaginatedCategoryPlacesNotifier,
  PaginatedListState<Place>,
  CategoryPlacesParams
>(PaginatedCategoryPlacesNotifier.new);

// Assuming PlaceRepository and its provider are defined elsewhere
// final placeRepositoryProvider = Provider<PlaceRepository>((ref) => PlaceRepository(ref.watch(dioProvider)));
