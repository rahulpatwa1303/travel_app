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
import 'package:travel_app/features/places/presentation/widget/cities_time.dart';
import 'package:travel_app/features/places/presentation/widget/city_details.dart';
import 'package:travel_app/features/places/presentation/widget/hourly_forecast_chart.dart';
import 'package:travel_app/widget/floating_heart_button.dart';

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
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  // Added TickerProviderStateMixin for TabController
  @override
  bool get wantKeepAlive => true; // KEEP ALIVE
  // State variables for Tabs and Pagination

  Map<String, PageController> _pageControllers = {};

  // State variables for Tabs and Pagination
  TabController? _tabController;
  List<String> _categories = [];
  Map<String, List<PlaceByCity>> _groupedPlaces = {};
  Map<String, int> _categoryCurrentPage = {};
  final int _itemsPerPage = 8;
  final int _gridCrossAxisCount = 2;

  // --- State for AppBar Color Change ---
  late ScrollController _scrollController;
  Color _appBarColor = Colors.transparent;
  Color _appBarIconColor = Colors.white; // Start with white icons/text
  Color _solidAppBarColor = Colors.white; // Default solid color
  Color _solidAppBarIconColor =
      Colors.black87; // Default icon color for solid background
  bool _isSolidColorSet = false;
  final double _colorChangeThreshold =
      200.0; // Pixels to scroll before changing color (adjust)
  // --- End AppBar Color State ---
  double _currentScrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController =
        ScrollController()..addListener(_onScroll); // Add listener
    _fetchInitialData(); // Fetch data needed for the screen
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Set solid colors based on Theme AFTER context is available
    if (!_isSolidColorSet) {
      final theme = Theme.of(context);
      // Use surface for solid app bar, or fallback to primary
      _solidAppBarColor =
          theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface;
      // Use onSurface for solid app bar icons/text, or fallback to onPrimary
      _solidAppBarIconColor =
          theme.appBarTheme.foregroundColor ?? theme.colorScheme.onSurface;
      // Set initial icon color based on scroll position (should be transparent at start)
      _appBarIconColor = Colors.white; // Explicitly white for transparent start
      _isSolidColorSet = true;
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll); // Clean up scroll listener!
    _scrollController.dispose();
    _tabController?.removeListener(_handleTabSelection);
    _tabController?.dispose();
    super.dispose();
  }

  // --- Function to process places data ---
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

      if (needNewController) {
        oldController?.removeListener(_handleTabSelection);
        oldController?.dispose();
        if (uniqueCategories.isNotEmpty) {
          _tabController = TabController(
            length: uniqueCategories.length,
            vsync: this,
          );
          _tabController?.addListener(_handleTabSelection);
        } else {
          _tabController = null;
        }
      }

      setState(() {
        _groupedPlaces = grouped;
        if (categoriesChanged) {
          _categories = uniqueCategories;
          _categoryCurrentPage = newCurrentPages;
          // Controller handled above
        }
      });
    }
  }

  // --- Listener for TabController ---
  void _handleTabSelection() {
    if (_tabController != null && mounted && !_tabController!.indexIsChanging) {
      setState(() {
        /* Trigger rebuild to show correct grid */
      });
    }
  }

  // --- Listener for ScrollController (AppBar Color Change) ---
  void _onScroll() {
    if (!_scrollController.hasClients || !_isSolidColorSet)
      return; // Ensure colors are set

    final offset = _scrollController.offset;
    // Change color slightly before the AppBar fully collapses for smoother transition
    final threshold = _colorChangeThreshold; // Use defined threshold

    // Determine target colors based on scroll offset
    final Color targetBgColor =
        offset > threshold ? _solidAppBarColor : Colors.transparent;
    final Color targetIconColor =
        offset > threshold ? _solidAppBarIconColor : Colors.white;

    // Update state only if colors actually change
    if (_appBarColor != targetBgColor ||
        _appBarIconColor != targetIconColor ||
        (_currentScrollOffset - offset).abs() > 1.0) {
      setState(() {
        _currentScrollOffset = offset;
        _appBarColor = targetBgColor;
        _appBarIconColor = targetIconColor;
      });
    }
  }
  // --- End Listeners ---

  // --- Initial Data Fetch Trigger ---
  Future<void> _fetchInitialData() async {
    // This function now primarily sets up listeners.
    // The actual fetching is triggered by ref.watch in the build method.
    _setupListeners();
  }

  void _setupListeners() {
    // Setup listener for City Details to fetch time *after* details are loaded
    // (No need to store subscription if managed by provider lifecycle)
    ref.listenManual<
      AsyncValue<CityDetail>
    >(cityDetailsProvider(int.tryParse(widget.placeId) ?? -1), (
      previous,
      next,
    ) {
      // We don't need to fetch time manually here anymore if using time provider
      // if (next is AsyncData<CityDetail>) { _fetchLocalTime(next.value); }
      if (next is AsyncError && mounted) {
        // Handle error related to fetching city details itself if needed
        print("Error fetching city details: ${next.error}");
      }
    });

    // Setup listener for Places in City
    ref.listenManual<
      AsyncValue<List<PlaceByCity>>
    >(placesInCityProvider(int.tryParse(widget.placeId) ?? -1), (
      previous,
      next,
    ) {
      if (next is AsyncData<List<PlaceByCity>>) {
        _processPlacesData(next.value);
      } else if (mounted && _tabController != null) {
        // Clear state on error/loading for places if desired
        // setState(() { _categories = []; _groupedPlaces = {}; _categoryCurrentPage = {}; _tabController?.dispose(); _tabController = null; });
      }
    });
  }

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
    final double offset = _currentScrollOffset;

    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: _appBarColor,
      //   elevation: 0,
      //   actions: <Widget>[
      //     FloatingHeartLikeButton(
      //       initialIsLiked: true,
      //       size: 24, // Adjust size as needed
      //       onLikedChanged: (bool liked) {
      //         // print("Place ${place.id} liked: $liked");
      //         // // Update the state using the provider
      //         // ref.read(placeLikeStateProvider.notifier).update((state) {
      //         //    // Create a mutable copy, update, return immutable
      //         //    final newState = Map<int, bool>.from(state);
      //         //    newState[place.id] = liked;
      //         //    return newState;
      //         // });
      //         // TODO: Add logic here to sync with your backend API
      //       },
      //     ),
      //   ],
      // ), // Show name in AppBar
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true, // Keep AppBar pinned
            floating: false,
            snap: false,
            stretch: true,
            backgroundColor: _appBarColor, // Use state variable for background
            foregroundColor:
                _appBarIconColor, // Use state variable for icons/text
            surfaceTintColor:
                Colors.transparent, // Optional: Remove M3 tint when collapsed
            elevation:
                _appBarColor == Colors.transparent
                    ? 0
                    : 1, // Add elevation when solid
            leading: Container(
              // Custom leading for consistent background
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                // Background slightly visible even when AppBar transparent
                color: Colors.black.withOpacity(
                  offset > _colorChangeThreshold * 0.5 ? 0.0 : 0.4,
                ), // Fade out background
                shape: BoxShape.circle,
              ),
              child: BackButton(color: _appBarIconColor), // Icon color changes
            ),
            actions: <Widget>[
              FloatingHeartLikeButton(
                initialIsLiked: true,
                size: 24, // Adjust size as needed
                onLikedChanged: (bool liked) {
                  // print("Place ${place.id} liked: $liked");
                  // // Update the state using the provider
                  // ref.read(placeLikeStateProvider.notifier).update((state) {
                  //    // Create a mutable copy, update, return immutable
                  //    final newState = Map<int, bool>.from(state);
                  //    newState[place.id] = liked;
                  //    return newState;
                  // });
                  // TODO: Add logic here to sync with your backend API
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Hero(
                tag: heroTag,
                child: Container(
                  height: 350,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[300], // Fallback
                    image:
                        useDefaultImage
                            ? const DecorationImage(
                              image: AssetImage('assets/city.png'),
                              fit: BoxFit.cover,
                            )
                            : (displayImageUrl != null
                                ? DecorationImage(
                                  image: NetworkImage(
                                    displayImageUrl!,
                                  ), // Use updated URL
                                  fit: BoxFit.cover,
                                )
                                : null),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.4],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate.fixed([
              Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayCountry,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 24),

                    // --- City Details Section ---
                    cityDetailsAsync.when(
                      data: (details) {
                        const int tabCount = 4;
                        return DefaultTabController(
                           length: tabCount,
                          child: Column(
                            children: [
                              buildCityDetailsContent(
                                context,
                                details,
                                parsedTravelPeriods,
                                rawBestTimeText,
                              ),
                              // --- Conditionally display Chart ---
                              HourlyForecastChart(
                                hourlyData:
                                    details
                                        .weatherForecast
                                        ?.hourly, // Pass the hourly data
                                locationKey:
                                    details.id.toString(), // Pass city ID for key
                                lastUpdated:
                                    details
                                        .weatherLastUpdated, // Pass update time for key
                              ),
                              // --- End City Details Section ---
                              const SizedBox(
                                height: 24,
                              ), // Space before places section
                              Card(
                                elevation: 1, // Optional elevation
                                margin:
                                    EdgeInsets
                                        .zero, // Remove Card's default margin if needed
                                clipBehavior: Clip.antiAlias,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: buildCitySunDetailsContent(
                                  context,
                                  ref,
                                  details,
                                ),
                              ),
                              const SizedBox(height: 24),
                              // --- Places In City Section (Tabs + Grid) ---
                              _buildPlacesSection(context, placesInCityAsync),
                            ],
                          ),
                        );
                      },
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
                  ],
                ),
              ),
            ]),
          ),
        ],

        // child: SingleChildScrollView(
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       Hero(
        //         tag: heroTag,
        //         child: Container(
        //           height: 350,
        //           width: double.infinity,
        //           decoration: BoxDecoration(
        //             color: Colors.blueGrey[300], // Fallback
        //             image:
        //                 useDefaultImage
        //                     ? const DecorationImage(
        //                       image: AssetImage('assets/city.png'),
        //                       fit: BoxFit.cover,
        //                     )
        //                     : (displayImageUrl != null
        //                         ? DecorationImage(
        //                           image: NetworkImage(
        //                             displayImageUrl!,
        //                           ), // Use updated URL
        //                           fit: BoxFit.cover,
        //                         )
        //                         : null),
        //           ),
        //           child: Container(/* Gradient Overlay */),
        //         ),
        //       ),
        //       Padding(
        //         padding: const EdgeInsets.all(16.0),
        //         child: Column(
        //           crossAxisAlignment: CrossAxisAlignment.start,
        //           children: [
        //             // Display Name and Country (always show based on initial/loaded data)
        //             Text(
        //               displayName,
        //               style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        //                 fontWeight: FontWeight.bold,
        //               ),
        //             ),
        //             const SizedBox(height: 8),
        //             Text(
        //               displayCountry,
        //               style: Theme.of(context).textTheme.titleMedium,
        //             ),
        //             const SizedBox(height: 24),

        //             // --- City Details Section ---
        //             cityDetailsAsync.when(
        //               data: (details) {
        //                 return Column(
        //                   children: [
        //                     buildCityDetailsContent(
        //                       context,
        //                       details,
        //                       parsedTravelPeriods,
        //                       rawBestTimeText,
        //                     ),
        //                     SizedBox(height: 24),
        //                     Card(
        //                       elevation: 1, // Optional elevation
        //                       margin:
        //                           EdgeInsets
        //                               .zero, // Remove Card's default margin if needed
        //                       clipBehavior: Clip.antiAlias,
        //                       shape: RoundedRectangleBorder(
        //                         borderRadius: BorderRadius.circular(8),
        //                       ),
        //                       child: buildCitySunDetailsContent(
        //                         context,
        //                         details,
        //                         parsedTravelPeriods,
        //                         rawBestTimeText,
        //                       ),
        //                     ),
        //                   ],
        //                 );
        //               },
        //               loading:
        //                   () => const Center(
        //                     child: Padding(
        //                       padding: EdgeInsets.symmetric(vertical: 32.0),
        //                       child: Text("Loading details..."),
        //                     ),
        //                   ), // Show simpler loading text here
        //               error:
        //                   (err, stack) => Center(
        //                     child: Text(
        //                       "Error loading city details: $err",
        //                       style: const TextStyle(color: Colors.red),
        //                     ),
        //                   ),
        //             ),

        //             // --- End City Details Section ---
        //             const SizedBox(height: 24), // Space before places section
        //             // --- Places In City Section (Tabs + Grid) ---
        //             _buildPlacesSection(
        //               context,
        //               placesInCityAsync,
        //             ), // Build the tabbed section
        //             // --- End Places In City Section ---
        //           ],
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
      ),
    );
  }

  // --- Helper for Best Time Section (Carousel/Fallback) ---

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
                      child: Container(
                        color: Colors.grey[200],
                        child:
                            place.usesDefaultImage
                                ? Image.asset(
                                  'assets/city.png',
                                  fit: BoxFit.cover,
                                )
                                : (place.primaryImageUrl != null &&
                                    place.primaryImageUrl!.isNotEmpty)
                                ? Image.network(
                                  place.primaryImageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.broken_image);
                                  },
                                  loadingBuilder: (
                                    context,
                                    child,
                                    loadingProgress,
                                  ) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                )
                                : const Icon(Icons.image_not_supported),
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
