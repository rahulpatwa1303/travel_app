// lib/features/places/presentation/widget/city_places_grid.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import 'package:collection/collection.dart'; // For ListEquality

// Import Models and Providers if needed for type hints, though data is passed in
import 'package:travel_app/features/places/domain/place_by_city_model.dart';
// Import Helpers if needed (e.g., StringExtension)
import 'package:travel_app/features/places/presentation/controllers/helper.dart';

// --- New StatefulWidget for the Places Section ---
class CityPlacesGrid extends ConsumerStatefulWidget {
  final AsyncValue<List<PlaceByCity>>
  placesInCityAsync; // Receive the AsyncValue

  const CityPlacesGrid({super.key, required this.placesInCityAsync});

  @override
  ConsumerState<CityPlacesGrid> createState() => _CityPlacesGridState();
}

class _CityPlacesGridState extends ConsumerState<CityPlacesGrid>
    with TickerProviderStateMixin {
  // Need Ticker for TabController

  // --- State Variables for Tabs and Pagination (Moved Here) ---
  TabController? _tabController;
  List<String> _categories = [];
  Map<String, List<PlaceByCity>> _groupedPlaces = {};
  Map<String, int> _categoryCurrentPage = {};
  final int _itemsPerPage = 8; // 4 rows * 2 columns
  final int _gridCrossAxisCount = 2; // 2 COLUMNS

  @override
  void initState() {
    super.initState();
    // Process initial data passed via the widget property
    _processDataFromAsyncValue(widget.placesInCityAsync);
  }

  @override
  void didUpdateWidget(covariant CityPlacesGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-process data if the AsyncValue input changes instance or state
    if (widget.placesInCityAsync != oldWidget.placesInCityAsync) {
      _processDataFromAsyncValue(widget.placesInCityAsync);
    }
  }

  @override
  void dispose() {
    _tabController?.removeListener(_handleTabSelection);
    _tabController?.dispose();
    super.dispose();
  }

  // --- Function to process data from AsyncValue ---
  void _processDataFromAsyncValue(AsyncValue<List<PlaceByCity>> asyncValue) {
    // Only process if data is available
    if (asyncValue is AsyncData<List<PlaceByCity>>) {
      _processPlacesData(asyncValue.value);
    } else if (mounted && _tabController != null) {
      // Clear state if input becomes loading/error after having data
      // Avoid clearing if it was already loading/error to prevent flicker
      if (asyncValue is! AsyncLoading && asyncValue is! AsyncError) {
        setState(() {
          _categories = [];
          _groupedPlaces = {};
          _categoryCurrentPage = {};
          _tabController?.dispose();
          _tabController = null;
        });
      }
    }
  }

  // --- Function to process the actual list of places ---
  void _processPlacesData(List<PlaceByCity> places) {
    final grouped = <String, List<PlaceByCity>>{};
    for (final place in places) {
      (grouped[place.category] ??= []).add(place);
    }
    final uniqueCategories = grouped.keys.toList()..sort();
    bool categoriesChanged =
        !const ListEquality().equals(_categories, uniqueCategories);
    Map<String, int> newCurrentPages = {};

    for (final category in uniqueCategories) {
      newCurrentPages[category] =
          (categoriesChanged ? 0 : _categoryCurrentPage[category]) ?? 0;
    }

    if (mounted) {
      bool needNewController =
          categoriesChanged &&
          (_tabController == null ||
              _tabController!.length != uniqueCategories.length);
      TabController? oldController = _tabController;
      TabController? newController; // Declare outside setState

      if (needNewController) {
        if (uniqueCategories.isNotEmpty) {
          newController = TabController(
            length: uniqueCategories.length,
            vsync: this,
          );
          newController.addListener(_handleTabSelection);
        }
      }

      setState(() {
        _groupedPlaces = grouped; // Update grouped data regardless
        if (categoriesChanged) {
          _categories = uniqueCategories;
          _categoryCurrentPage = newCurrentPages;
          // Dispose old and assign new controller inside setState
          oldController?.removeListener(_handleTabSelection);
          oldController?.dispose(); // Dispose the old one
          _tabController = newController; // Assign the new one (can be null)
        } else {
          // Keep existing controller, but update page state if needed
          // _categoryCurrentPage = newCurrentPages; // Optional page reset on data refresh
        }
      });
    }
  }

  // --- Listener for TabController ---
  void _handleTabSelection() {
    if (mounted && _tabController != null && !_tabController!.indexIsChanging) {
      setState(() {
        /* Trigger rebuild to show correct grid for the new tab index */
      });
    }
  }
  // --- End Listeners ---

  @override
  Widget build(BuildContext context) {
    // Build UI based on the AsyncValue passed in widget.placesInCityAsync
    return widget.placesInCityAsync.when(
      data: (places) {
        // Use internal state (_tabController, _categories) to build UI
        if (_tabController == null || _categories.isEmpty) {
          // Handle state where processing is pending or resulted in no categories
          if (places.isNotEmpty && _categories.isEmpty)
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text("Processing places..."),
            );
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text("No specific places found nearby."),
          );
        }

        // --- Build TabBar and the CONTENT for the SELECTED tab ---
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Wrap content height
          children: [
            Text(
              // Section Title
              "Places Nearby:",
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8), // Minimal gap
            TabBar(
              controller: _tabController!,
              isScrollable: true,
              // indicatorWeight: 2.0,
              // indicatorPadding: EdgeInsets.zero,
              labelPadding: const EdgeInsets.symmetric(horizontal: 12.0),
              padding: EdgeInsets.zero,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: Theme.of(context).primaryColor,

              dividerHeight: 0,
              // --- Indicator Customization ---
              indicatorSize:
                  TabBarIndicatorSize
                      .tab, // Make indicator span the entire tab width
              indicatorPadding: EdgeInsets.symmetric(
                vertical: 2.0,
                horizontal: 4.0,
              ),
              indicatorWeight: 0,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),

                border: Border.all(
                  color:
                      Theme.of(context).primaryColor, // Color of the box border
                  width: 2.0, // Thickness of the box border
                ),
                // Optional: You could add a subtle background color to the selected tab's box
                color: Theme.of(context).primaryColor.withOpacity(0.1),
              ),

              tabs:
                  _categories.map((category) {
                    final displayName =
                        category.replaceAll('_', ' ').capitalizeFirst();
                    return Tab(text: displayName);
                  }).toList(),
              onTap: (index) {
                // Optional: Trigger rebuild immediately on tap
                if (mounted && _tabController?.index == index) {
                  setState(() {});
                }
              },
            ),
            const SizedBox(height: 12), // Space between TabBar and Content
            // --- Directly build the content for the CURRENT tab ---
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Container(
                key: ValueKey<int>(
                  _tabController!.index,
                ), // Key based on tab index
                child: buildPaginatedCategoryGrid(
                  _categories[_tabController!.index],
                ),
              ),
            ),
          ],
        );
      },
      loading:
          () => const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32.0),
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text("Loading places..."),
                ],
              ),
            ),
          ),
      error:
          (err, stack) => Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                "Error loading places: $err",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ),
    );
  }

  Widget buildPaginatedCategoryGrid(String category) {
    final List<PlaceByCity> categoryPlaces = _groupedPlaces[category] ?? [];
    if (categoryPlaces.isEmpty)
      return const Center(child: Text("No places in this category."));

    final int currentPage = _categoryCurrentPage[category] ?? 0;
    final int totalItems = categoryPlaces.length;
    final int totalPages = (totalItems / _itemsPerPage).ceil();
    final int startIndex = currentPage * _itemsPerPage;
    final int endIndex = min(startIndex + _itemsPerPage, totalItems);
    final List<PlaceByCity> itemsForCurrentPage = categoryPlaces.sublist(
      startIndex,
      endIndex,
    );

    return Column(
      mainAxisSize: MainAxisSize.min, // Wrap height
      children: [
        // --- GridView ---
        GridView.builder(
          shrinkWrap: true, // Keep shrinkWrap
          physics:
              const NeverScrollableScrollPhysics(), // Keep physics override
          padding: const EdgeInsets.only(bottom: 8.0),
          itemCount: itemsForCurrentPage.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _gridCrossAxisCount, // 2 COLUMNS
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 0.7, // TUNE THIS for 4 rows x 2 columns
          ),
          itemBuilder: (context, index) {
            final place = itemsForCurrentPage[index];
            final placeImageUrl = place.primaryImageUrl;
            final useDefaultPlaceImage = place.usesDefaultImage;
            // --- Grid Item Card ---
            return Card(
              elevation: 1,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ), // Optional rounded corners
              child: InkWell(
                onTap: () {
                  print("Tapped Place: ${place.name}"); /* TODO: Handle tap */
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Container(
                        color: Colors.grey[200], // Background placeholder
                        child:
                            useDefaultPlaceImage
                                ? Image.asset(
                                  'assets/city.png',
                                  fit: BoxFit.cover,
                                )
                                : (placeImageUrl != null
                                    ? Image.network(
                                      placeImageUrl,
                                      fit: BoxFit.cover,
                                      // Optional Loading/Error for grid images
                                      loadingBuilder: (
                                        context,
                                        child,
                                        loadingProgress,
                                      ) {
                                        if (loadingProgress == null)
                                          return child;
                                        return const Center(
                                          child: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                                Icons.broken_image,
                                                color: Colors.grey,
                                              ),
                                    )
                                    : const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                    )), // Fallback
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Text(
                        place.name,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ); // --- End Grid Item Card ---
          },
        ), // --- End GridView ---
        // --- Dot Indicator Pagination ---
        if (totalPages > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: _buildDotIndicator(totalPages, currentPage, (index) {
              // Update page index directly via setState when dot tapped
              setState(() {
                _categoryCurrentPage[category] = index;
              });
            }),
          ),
      ],
    );
  }

  Widget _buildDotIndicator(
    int pageCount,
    int currentPage,
    ValueChanged<int> onDotTapped,
  ) {
    const int maxDotsToShow = 7;
    int startDot = 0;
    int endDot = pageCount;
    if (pageCount > maxDotsToShow) {
      startDot = max(0, currentPage - (maxDotsToShow ~/ 2));
      endDot = startDot + maxDotsToShow;
      if (endDot > pageCount) {
        endDot = pageCount;
        startDot = endDot - maxDotsToShow;
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(endDot - startDot, (indexInRow) {
        int actualIndex = startDot + indexInRow;
        bool isActive = actualIndex == currentPage;
        return GestureDetector(
          onTap: () => onDotTapped(actualIndex),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            height: isActive ? 10.0 : 8.0,
            width: isActive ? 10.0 : 8.0,
            decoration: BoxDecoration(
              color:
                  isActive ? Theme.of(context).primaryColor : Colors.grey[400],
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}
