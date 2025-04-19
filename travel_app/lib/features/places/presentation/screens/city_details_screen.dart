// lib/features/places/presentation/screens/city_details_screen.dart

import 'dart:math'; // For pagination calculation

import 'package:collection/collection.dart'; // For deep list equality check
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Import your models
import 'package:travel_app/features/places/domain/city_detail_model.dart';
import 'package:travel_app/features/places/domain/place_by_city_model.dart'; // Use PlaceByCity
import 'package:travel_app/features/places/domain/top_place_model.dart'; // For initial data
// Import helpers and providers
import 'package:travel_app/features/places/presentation/controllers/helper.dart';
import 'package:travel_app/features/places/presentation/providers/places_provider.dart';

// --- Convert to ConsumerStatefulWidget ---
class CityDetailsScreen extends ConsumerStatefulWidget {
  final String placeId;
  final TopPlace? initialPlaceData; // Keep initial TopPlace data

  const CityDetailsScreen({
    super.key,
    required this.placeId,
    this.initialPlaceData,
  });

  @override
  ConsumerState<CityDetailsScreen> createState() => _CityDetailsScreenState();
}

// --- State Class ---
class _CityDetailsScreenState extends ConsumerState<CityDetailsScreen>
    with TickerProviderStateMixin {
  // Added TickerProviderStateMixin for TabController

  // State variables for Tabs and Pagination

  TabController? _tabController;
  List<String> _categories = [];
  Map<String, List<PlaceByCity>> _groupedPlaces = {};
  Map<String, int> _categoryCurrentPage =
      {}; // Track current page per category (0-based)
  final int _itemsPerPage = 8; // Items per grid page
  final int _gridCrossAxisCount = 2; // <-- Fixed columns
  Map<String, PageController> _pageControllers = {};

  @override
  void initState() {
    super.initState();
    // Initialize controllers/data based on initial provider state *after* first build
    // Using ref.listen below is generally safer for reacting to provider changes
  }

  @override
  void dispose() {
    _tabController?.removeListener(_handleTabSelection);
    _tabController?.dispose();
    _pageControllers.values.forEach(
      (controller) => controller.dispose(),
    ); // Dispose ALL PageControllers
    super.dispose();
  }

  // --- Function to process places data and update tab state ---
  void _processPlacesData(List<PlaceByCity> places) {
    // Group places by category
    final grouped = <String, List<PlaceByCity>>{};
    for (final place in places) {
      (grouped[place.category] ??= []).add(place);
    }
    // Get sorted unique category keys
    final uniqueCategories = grouped.keys.toList()..sort();

    // Check if categories actually changed (order matters too)
    bool categoriesChanged =
        !const ListEquality().equals(_categories, uniqueCategories);

    // Prepare new state maps
    Map<String, int> newCurrentPages = {};
    Map<String, PageController> newPageControllers = {};

    // Create/update page controllers and current page index
    for (final category in uniqueCategories) {
      int initialPage = 0;
      if (!categoriesChanged && _categoryCurrentPage.containsKey(category)) {
        // Keep current page if categories haven't changed list/order
        initialPage = _categoryCurrentPage[category]!;
      }
      newCurrentPages[category] = initialPage;

      // Create or reuse PageController
      if (_pageControllers.containsKey(category) && !categoriesChanged) {
        newPageControllers[category] = _pageControllers[category]!;
        // Ensure controller page matches state if needed (might jump if data reloads)
        // WidgetsBinding.instance.addPostFrameCallback((_) {
        //    if (newPageControllers[category]?.hasClients == true && newPageControllers[category]!.page?.round() != initialPage) {
        //       newPageControllers[category]!.jumpToPage(initialPage);
        //    }
        // });
      } else {
        newPageControllers[category] = PageController(initialPage: initialPage);
        // Add listener ONLY to newly created controllers or if replacing old one
        newPageControllers[category]?.addListener(() {
          if (mounted &&
              newPageControllers[category]?.page?.round() !=
                  _categoryCurrentPage[category]) {
            setState(() {
              _categoryCurrentPage[category] =
                  newPageControllers[category]!.page!.round();
            });
          }
        });
      }
    }

    // Dispose controllers for categories that were removed
    _pageControllers.forEach((category, controller) {
      if (!newCurrentPages.containsKey(category)) {
        controller.dispose(); // Dispose removed controllers
      }
    });

    if (mounted) {
      setState(() {
        _groupedPlaces = grouped; // Always update grouped data
        _pageControllers = newPageControllers; // Update controller map

        if (categoriesChanged) {
          _categories = uniqueCategories;
          _categoryCurrentPage = newCurrentPages; // Update page indices

          // Dispose old TabController and create new one
          _tabController?.removeListener(_handleTabSelection);
          _tabController?.dispose();
          _tabController = null;
          if (_categories.isNotEmpty) {
            _tabController = TabController(
              length: _categories.length,
              vsync: this,
            );
            _tabController?.addListener(_handleTabSelection);
          }
        }
        // If only data changed, pages are potentially reset or kept via logic above
        else {
          _categoryCurrentPage = newCurrentPages;
        }
      });
    }
  }

  // Optional: Handle tab selection if needed (e.g., logging)
  void _handleTabSelection() {
    if (_tabController != null && _tabController!.indexIsChanging) {
      print("Selected tab index: ${_tabController!.index}");
    }
  }
  // --- End function to process data ---

  @override
  Widget build(BuildContext context) {
    final int cityIdInt = int.tryParse(widget.placeId) ?? -1;

    // Watch providers
    final AsyncValue<CityDetail> cityDetailsAsync = ref.watch(
      cityDetailsProvider(cityIdInt),
    );
    final AsyncValue<List<PlaceByCity>> placesInCityAsync = ref.watch(
      placesInCityProvider(cityIdInt),
    );

    // --- Listen to places provider to process data ---
    ref.listen<AsyncValue<List<PlaceByCity>>>(placesInCityProvider(cityIdInt), (
      previous,
      next,
    ) {
      if (next is AsyncData<List<PlaceByCity>>) {
        _processPlacesData(next.value);
      } else if (next is AsyncError && _tabController != null && mounted) {
        // Handle error: Clear tabs state if needed
        setState(() {
          _categories = [];
          _groupedPlaces = {};
          _categoryCurrentPage = {};
          _pageControllers.values.forEach((c) => c.dispose());
          _pageControllers = {};
          _tabController?.dispose();
          _tabController = null;
        });
      } else if (next is AsyncLoading &&
          (previous == null || previous is AsyncError) &&
          mounted &&
          _tabController != null) {
        // Handle going back to loading: Clear tabs state if needed
        setState(() {
          _categories = [];
          _groupedPlaces = {};
          _categoryCurrentPage = {};
          _pageControllers.values.forEach((c) => c.dispose());
          _pageControllers = {};
          _tabController?.dispose();
          _tabController = null;
        });
      }
    });
    // --- End Listener ---

    // Initial data setup
    String displayName = widget.initialPlaceData?.name ?? 'Loading...';
    String displayCountry = widget.initialPlaceData?.country.name ?? '...';
    String? displayImageUrl = widget.initialPlaceData?.imageUrl;
    bool useDefaultImage =
        widget.initialPlaceData?.usesDefaultImage ??
        (displayImageUrl == null || displayImageUrl.isEmpty);
    String? rawBestTimeText;
    List<TravelPeriod> parsedTravelPeriods = [];

    cityDetailsAsync.maybeWhen(
      data: (details) {
        displayName = details.name;
        displayCountry = details.country.name;
        displayImageUrl = details.primaryImageUrl;
        useDefaultImage = details.usesDefaultImage;
        rawBestTimeText = details.bestTimeToTravel;
        parsedTravelPeriods = parseBestTimeToTravel(rawBestTimeText);
      },
      orElse: () {},
    );
    print('displayImageUrl $displayImageUrl');
    final heroTag = 'place-image-${widget.placeId}';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ), // Show name in AppBar
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: heroTag,
              child: Container(
                // Image Container
                height: 350,
                width: double.infinity,
                decoration: BoxDecoration(/* ... Image Decoration ... */),
                child: Container(/* ... Gradient Overlay ... */),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display Name and Country (always show based on initial/loaded data)
                  Text(
                    displayName,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    displayCountry,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),

                  // --- City Details Section ---
                  cityDetailsAsync.when(
                    data:
                        (details) => _buildCityDetailsContent(
                          context,
                          details,
                          parsedTravelPeriods,
                          rawBestTimeText,
                        ),
                    loading:
                        () => const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 32.0),
                            child: Text("Loading details..."),
                          ),
                        ), // Show simpler loading text here
                    error:
                        (err, stack) => Center(
                          child: Text(
                            "Error loading city details: $err",
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                  ),

                  // --- End City Details Section ---
                  const SizedBox(height: 24), // Space before places section
                  // --- Places In City Section (Tabs + Grid) ---
                  _buildPlacesSection(
                    context,
                    placesInCityAsync,
                  ), // Build the tabbed section
                  // --- End Places In City Section ---
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper for City Details Content ---
  Widget _buildCityDetailsContent(
    BuildContext context,
    CityDetail details,
    List<TravelPeriod> parsedTravelPeriods,
    String? rawBestTimeText,
  ) {
    Widget bestTimeSection = buildBestTimeSection(
      context,
      parsedTravelPeriods,
      rawBestTimeText,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (details.description != null && details.description!.isNotEmpty) ...[
          Text(
            "Description:",
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(details.description!, style: const TextStyle(height: 1.5)),
          const SizedBox(height: 16),
        ],
        bestTimeSection, // Display best time section
        if (details.famousFor != null && details.famousFor!.isNotEmpty) ...[
          Text(
            "Famous For:",
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(details.famousFor!),
          const SizedBox(height: 16),
        ],
        if (details.currentWeather?.main?.temp != null) ...[
          // Display weather if available
          Text(
            "Current Weather:",
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text("${details.currentWeather!.main!.temp!.toStringAsFixed(1)} °C"),
          // Optionally display weather description
          if (details.currentWeather!.weather != null &&
              details.currentWeather!.weather!.isNotEmpty)
            Text(
              details.currentWeather!.weather!.first.description
                      ?.capitalizeFirst() ??
                  '',
            ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  // --- Helper for Best Time Section (Carousel/Fallback) ---
  Widget buildBestTimeSection(
    BuildContext context,
    List<TravelPeriod> parsedTravelPeriods,
    String? rawBestTimeText,
  ) {
    // Your existing implementation for the best time carousel or raw text
    if (parsedTravelPeriods.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              "Best Time to Travel:",
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: parsedTravelPeriods.length,
              // Add some padding around the list
              padding: const EdgeInsets.symmetric(
                horizontal: 0,
                vertical: 4,
              ), // Adjust horizontal if needed
              itemBuilder: (context, index) {
                final period = parsedTravelPeriods[index];
                // --- Create a Card for each period ---
                return Container(
                  width: 200, // Adjust width as needed
                  margin: EdgeInsets.only(
                    right: index < parsedTravelPeriods.length - 1 ? 12.0 : 0,
                  ), // Add spacing between cards
                  child: Card(
                    elevation: 0.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias, // Good for consistency
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center, // Center content vertically
                        children: [
                          Text(
                            period.when,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                            maxLines: 2, // Allow wrapping for longer 'when'
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (period.why.isNotEmpty) ...[
                            const SizedBox(
                              height: 6,
                            ), // Space between when and why
                            Expanded(
                              // Allow 'why' text to fill remaining space
                              child: Text(
                                period.why,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey[700]),
                                // Allow multiple lines for reason
                                overflow:
                                    TextOverflow
                                        .ellipsis, // Add ellipsis if too long
                                maxLines: 3, // Limit max lines
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
                // --- End Card ---
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      );
    } else if (rawBestTimeText != null && rawBestTimeText.isNotEmpty) {
      return Column(/* ... Raw Text Fallback ... */);
    } else {
      return const SizedBox.shrink();
    }
  }

  double _calculateGridViewHeight(BuildContext context) {
    // Get screen width minus horizontal padding
    double availableWidth =
        MediaQuery.of(context).size.width - 32.0; // 16 padding on each side
    double itemWidth =
        (availableWidth - 8.0 * (_gridCrossAxisCount - 1)) /
        _gridCrossAxisCount;
    double itemHeight =
        itemWidth / 0.7; // TARGET ASPECT RATIO for 4 rows x 2 columns
    double gridHeight =
        (itemHeight * 4) + (8.0 * 3); // 4 rows high + 3 spacing gaps
    double paginationHeight = 30.0; // Estimated height for dot indicators
    return gridHeight + paginationHeight + 16.0; // Add some overall padding
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

  // --- Helper for the entire Places Section (Title + Tabs/Grid) ---
  // --- UPDATED: Helper for the entire Places Section ---
  Widget _buildPlacesSection(
    BuildContext context,
    AsyncValue<List<PlaceByCity>> placesAsyncValue,
  ) {
    return placesAsyncValue.when(
      data: (places) {
        if (_tabController == null || _categories.isEmpty) {
          // Handle loading/empty state for categories/controller
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
          mainAxisSize: MainAxisSize.min, // Make column wrap content height
          children: [
            Text("Places Nearby:" /* ... Style ... */),
            const SizedBox(height: 8), // Minimal gap
            TabBar(
              controller: _tabController!,
              isScrollable: true,
              indicatorWeight: 2.0,
              indicatorPadding: EdgeInsets.zero,
              labelPadding: const EdgeInsets.symmetric(horizontal: 12.0),
              padding: EdgeInsets.zero,
              tabs:
                  _categories.map((category) {
                    final displayName =
                        category.replaceAll('_', ' ').capitalizeFirst();
                    return Tab(text: displayName);
                  }).toList(),
              // --- Add onTap to handle manual tab changes (optional but recommended) ---
              onTap: (index) {
                // Although listener handles it, explicitly setting state here can feel more responsive
                if (mounted && _tabController?.index == index) {
                  setState(
                    () {},
                  ); // Trigger rebuild if tapped same tab (might not be needed)
                }
              },
              // --- End onTap ---
            ),
            const SizedBox(height: 12), // Space between TabBar and Content
            // --- Directly build the content for the CURRENT tab ---
            // AnimatedSwitcher provides a nice fade transition between tab contents
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Container(
                // Use a Key to help AnimatedSwitcher differentiate content
                key: ValueKey<int>(
                  _tabController!.index,
                ), // Key based on tab index
                child: _buildPaginatedCategoryGrid(
                  _categories[_tabController!.index],
                ),
              ),
            ),
            // --- End Content ---
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

  // --- Helper for Paginated Grid within a Tab ---

  // --- UPDATED: Helper for Paginated Grid within a Tab ---
  Widget _buildPaginatedCategoryGrid(String category) {
    final List<PlaceByCity> categoryPlaces = _groupedPlaces[category] ?? [];
    if (categoryPlaces.isEmpty)
      return const Center(child: Text("No places in this category."));

    final int currentPage = _categoryCurrentPage[category] ?? 0;
    final int totalItems = categoryPlaces.length;
    final int totalPages =
        (totalItems / _itemsPerPage).ceil(); // 8 items per page
    final int startIndex = currentPage * _itemsPerPage;
    final int endIndex = min(startIndex + _itemsPerPage, totalItems);
    final List<PlaceByCity> itemsForCurrentPage = categoryPlaces.sublist(
      startIndex,
      endIndex,
    );

    return Column(
      // Column wraps content height
      mainAxisSize: MainAxisSize.min, // Make it wrap height
      children: [
        // --- GridView with shrinkWrap ---
        GridView.builder(
          // *** USE shrinkWrap and NeverScrollableScrollPhysics ***
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          // *** -------------------------------------------- ***
          padding: const EdgeInsets.only(bottom: 8.0), // Padding below grid
          itemCount: itemsForCurrentPage.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _gridCrossAxisCount, // 2 COLUMNS
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio:
                0.75, // TUNE THIS for 4 rows x 2 columns appearance
          ),
          itemBuilder: (context, index) {
            final place = itemsForCurrentPage[index];
            // --- Grid Item Card ---
            return Card(
              elevation: 1,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  /* TODO: Handle tap */
                },
                child: Column(
                  // Structure for Image + Text
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      // Image takes most space
                      child: Container(
                        color: Colors.grey[200],
                        child:
                            place
                                    .usesDefaultImage // Use helper getter
                                ? Image.asset(
                                  'assets/city.png',
                                  fit: BoxFit.cover,
                                )
                                : (place.primaryImageUrl !=
                                        null // Use helper getter
                                    ? Image.network(
                                      place.primaryImageUrl!,
                                      fit: BoxFit.cover /* loading/error */,
                                    )
                                    : const Icon(Icons.image_not_supported)),
                      ),
                    ),
                    Padding(
                      // Padding for name
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
} // End of _CityDetailsScreenState

// --- Helper Extension for Capitalizing (Keep this) ---
extension StringExtension on String {
  String capitalizeFirst() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
