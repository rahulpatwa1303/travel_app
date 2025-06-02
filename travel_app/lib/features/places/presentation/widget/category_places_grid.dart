// lib/features/places/presentation/widget/category_places_horizontal_grid.dart (New or renamed file)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:travel_app/features/places/data/repositories/places_repository.dart';
import 'package:travel_app/features/places/domain/place_model.dart';
import 'package:travel_app/features/places/presentation/providers/paginated_category_places_provider.dart';
import 'dart:math' as math; // For min function

class CategoryPlacesHorizontalGridWidget extends ConsumerStatefulWidget {
  final CategoryPlacesParams params;
  final double gridPageWidth; // Width of one 3x3 grid "page"
  final double
  itemHeight; // Approximate height of one grid item, to calculate total height

  const CategoryPlacesHorizontalGridWidget({
    super.key,
    required this.params,
    this.gridPageWidth = 320, // Adjust based on your item width and spacing
    this.itemHeight = 120, // Adjust based on your item height and spacing
  });

  @override
  ConsumerState<CategoryPlacesHorizontalGridWidget> createState() =>
      _CategoryPlacesHorizontalGridWidgetState();
}

class _CategoryPlacesHorizontalGridWidgetState
    extends ConsumerState<CategoryPlacesHorizontalGridWidget> {
  final ScrollController _horizontalScrollController = ScrollController();
  static const int _itemsPerGridPage = 9; // 3x3

  @override
  void initState() {
    super.initState();
    _horizontalScrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant CategoryPlacesHorizontalGridWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.params != widget.params) {
      if (_horizontalScrollController.hasClients) {
        _horizontalScrollController.jumpTo(0);
      }
      // The provider family will handle refetching automatically.
    }
  }

  void _onScroll() {
    if (!mounted) return;
    final notifier = ref.read(
      paginatedCategoryPlacesProvider(widget.params).notifier,
    );
    final asyncValue = ref.read(paginatedCategoryPlacesProvider(widget.params));
    final currentDataState = asyncValue.valueOrNull;

    // --- Start Debug Prints ---
    if (currentDataState != null) {
      print("-----------------------------");
      print("_onScroll --- Current Page: ${currentDataState.currentPage}");
      print("_onScroll --- isLoadingMore: ${currentDataState.isLoadingMore}");
      print("_onScroll --- hasReachedMax: ${currentDataState.hasReachedMax}");
      print(
        "_onScroll --- Scroll Px: ${_horizontalScrollController.position.pixels.toStringAsFixed(1)}",
      );
      print(
        "_onScroll --- MaxScrollExtent: ${_horizontalScrollController.position.maxScrollExtent.toStringAsFixed(1)}",
      );
      final threshold =
          _horizontalScrollController.position.maxScrollExtent -
          widget.gridPageWidth * 0.5;
      print(
        "_onScroll --- Threshold for fetch: ${threshold.toStringAsFixed(1)}",
      );
      print(
        "_onScroll --- Is condition met for fetch? ${_horizontalScrollController.position.pixels >= threshold}",
      );
      print("-----------------------------");
    } else {
      print("_onScroll --- currentDataState is NULL");
      return; // Exit if no data state yet
    }
    // --- End Debug Prints ---

    if (!currentDataState.isLoadingMore && !currentDataState.hasReachedMax) {
      if (_horizontalScrollController.position.pixels >=
          _horizontalScrollController.position.maxScrollExtent -
              widget.gridPageWidth * 0.5) {
        print(">>>> _onScroll: Threshold REACHED! Calling fetchNextPage().");
        notifier.fetchNextPage();
      }
    } else {
      if (currentDataState.isLoadingMore)
        print(">>>> _onScroll: Already loading more.");
      if (currentDataState.hasReachedMax)
        print(">>>> _onScroll: Reached max, not fetching.");
    }
  }

  @override
  void dispose() {
    _horizontalScrollController.removeListener(_onScroll);
    _horizontalScrollController.dispose();
    super.dispose();
  }

  Widget _buildGridItemSkeleton(BuildContext context) {
    return Card(
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: const Bone(width: double.infinity, height: double.infinity),
    );
  }

  Widget _buildSingleGridPage(BuildContext context, List<Place> placesForPage) {
    return SizedBox(
      width: widget.gridPageWidth, // Each "page" of grid has a fixed width
      child: GridView.builder(
        physics:
            const NeverScrollableScrollPhysics(), // Grid itself doesn't scroll
        shrinkWrap: true, // Important for GridView inside ListView
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 4.0,
        ), // Padding for the 3x3 grid
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.9, // Adjust (width/height)
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: placesForPage.length, // Should be up to 9 for a full page
        itemBuilder: (context, index) {
          final place = placesForPage[index];
          print('place image ${place.images}');
          final image =
              place.usesDefaultImage
                  ? const AssetImage('assets/city.png')
                  : NetworkImage(place.primaryImageUrl!) as ImageProvider;

          return InkWell(
 // Example: onTap for a place item in your search results or grid
onTap: () async {
  // Assume 'placeSearchResult' is the item tapped, e.g., PlaceSearchSuggestion
  // It should have place.id
  final int placeIdToFetch = suggestionItem.id; // or placeItem.id

  // Show a loading indicator while fetching full details (optional)
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()));

  try {
    // Fetch full details using your repository
    final Place fullPlaceDetails = await ref.read(placesRepositoryProvider).getPlaceDetails(placeIdToFetch);
    Navigator.pop(context); // Dismiss loading dialog

    // Now show the bottom sheet with the full details
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows sheet to take more height
      backgroundColor: Colors.transparent, // Make scaffold bg visible for rounded corners
      builder: (BuildContext शीतContext) { // Use a different name for builder context
        return PlaceDetailBottomSheet(place: fullPlaceDetails);
      },
    );
  } catch (e) {
    Navigator.pop(context); // Dismiss loading dialog on error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to load place details: $e")),
    );
    print("Error fetching full place details: $e");
  }
}
            child: Card(
              elevation: 1,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image(image: image, fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        stops: const [0.6, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 6,
                    left: 6,
                    right: 6,
                    child: Text(
                      place.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryPlacesAsync = ref.watch(
      paginatedCategoryPlacesProvider(widget.params),
    );
    // Calculate approximate height for 3 rows of items
    // itemHeight + spacing for 3 rows
    final double gridContainerHeight =
        (widget.itemHeight * 3) +
        (8 * 2) +
        (8 * 2); // 3 items + 2 mainAxisSpacings + vertical padding

    return categoryPlacesAsync.when(
      data: (stateData) {
        // stateData is PaginatedListState<Place>
        if (stateData.items.isEmpty && !stateData.isLoadingMore) {
          return SizedBox(
            // Give it some height so parent layout doesn't collapse
            height: gridContainerHeight,
            child: const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No places found in this category.'),
              ),
            ),
          );
        }

        // Calculate number of horizontal "pages" (3x3 grids)
        final int numberOfGridPages =
            (stateData.items.length / _itemsPerGridPage).ceil();

        return SizedBox(
          height:
              gridContainerHeight, // Fixed height for the horizontal scrolling area
          child: ListView.builder(
            controller: _horizontalScrollController,
            scrollDirection: Axis.horizontal,
            itemCount: numberOfGridPages + (stateData.isLoadingMore ? 1 : 0),
            itemBuilder: (context, pageIndex) {
              if (pageIndex == numberOfGridPages && stateData.isLoadingMore) {
                // Loading indicator at the end of the horizontal list
                return SizedBox(
                  width: widget.gridPageWidth * 0.5, // Width for the loader
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                );
              }

              final startIndex = pageIndex * _itemsPerGridPage;
              final endIndex = math.min(
                startIndex + _itemsPerGridPage,
                stateData.items.length,
              );
              final placesForThisGridPage = stateData.items.sublist(
                startIndex,
                endIndex,
              );

              return _buildSingleGridPage(context, placesForThisGridPage);
            },
          ),
        );
      },
      loading: () {
        return Skeletonizer(
          // Skeleton for the first 3x3 grid page
          enabled: true,
          child: SizedBox(
            height: gridContainerHeight,
            width: widget.gridPageWidth, // Show one page skeleton initially
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 4.0,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.9,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _itemsPerGridPage,
              itemBuilder: (context, index) => _buildGridItemSkeleton(context),
            ),
          ),
        );
      },
      error:
          (error, stack) => SizedBox(
            height: gridContainerHeight,
            child: Center(child: Text('Failed to load places: $error')),
          ),
    );
  }
}
