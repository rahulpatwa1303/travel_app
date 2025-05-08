// // lib/features/places/presentation/screens/city_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/features/places/data/repositories/places_repository.dart';
// Import your models
import 'package:travel_app/features/places/domain/city_detail_model.dart';
import 'package:travel_app/features/places/domain/place_by_city_model.dart'; // Use PlaceByCity
import 'package:travel_app/features/places/domain/top_place_model.dart'; // For initial data
import 'package:travel_app/features/places/presentation/controllers/helper.dart';
import 'package:travel_app/features/places/presentation/providers/liked_cities_notifier.dart';
import 'package:travel_app/features/places/presentation/providers/places_provider.dart';
import 'package:travel_app/features/places/presentation/widget/best_time_to_travel.dart';
import 'package:travel_app/features/places/presentation/widget/cities_places.dart';
import 'package:travel_app/features/places/presentation/widget/cities_time.dart';
import 'package:travel_app/features/places/presentation/widget/hourly_forecast_chart.dart';
import 'package:travel_app/widget/floating_heart_button.dart';

// Remove any conflicting import that might bring in the old local definition
// Assume placeLikeStateProvider exists
final placeLikeStateProvider = StateProvider<Map<int, bool>>((ref) => {});

// Define TravelPeriod class if not imported
// class TravelPeriod {
//   final String when, why;
//   const TravelPeriod({required this.when, required this.why});
// }

// Assume parseBestTimeToTravel function is available
// List<TravelPeriod> parseBestTimeToTravel(String? rawText) {
//   // 1. Handle null or empty input
//   if (rawText == null || rawText.trim().isEmpty) {
//     return [];
//   }

//   // 2. Basic cleaning: Remove leading/trailing whitespace and potential quote pairs
//   String cleanedText = rawText.trim();
//   if (cleanedText.startsWith("'") && cleanedText.endsWith("'")) {
//     cleanedText = cleanedText.substring(1, cleanedText.length - 1);
//   }
//   // Also handle potential trailing comma from copy-paste errors like `...',`
//    if (cleanedText.endsWith(',')) {
//       cleanedText = cleanedText.substring(0, cleanedText.length - 1);
//    }
//   cleanedText = cleanedText.trim(); // Trim again after potential modifications

//   // 3. Split into potential sentences or distinct period descriptions using '.' as a primary separator
//   // Filter out empty strings that might result from splitting (e.g., double periods)
//   List<String> potentialPeriods = cleanedText
//       .split('.')
//       .map((s) => s.trim()) // Trim each potential part
//       .where((s) => s.isNotEmpty) // Keep only non-empty parts
//       .toList();

//   List<TravelPeriod> parsedPeriods = [];

//   // 4. Process each potential period description
//   for (String part in potentialPeriods) {
//     // 5. Look for the colon ':' which often separates 'when' from 'why'
//     int colonIndex = part.indexOf(':');

//     if (colonIndex != -1) {
//       // Found a colon, assume 'when: why' structure
//       String whenPart = part.substring(0, colonIndex).trim();
//       String whyPart = part.substring(colonIndex + 1).trim();

//       // Basic validation: only add if both parts seem to have content
//       if (whenPart.isNotEmpty && whyPart.isNotEmpty) {
//         // Create the TravelPeriod object (ensure this uses the class from helper.dart)
//         parsedPeriods.add(TravelPeriod(when: whenPart, why: whyPart));
//       }
//       // Optional: Handle cases where only one part is present?
//       // else { print("Warning: Found colon but missing when/why in part: '$part'"); }

//     } else {
//       // 6. No colon found in this part.
//       // It *might* be a general statement or formatted differently.
//       // For simplicity in this version, we'll only capture parts with a clear colon separator.
//       // More complex logic (e.g., Regex for "Month to Month") could be added here if needed.
//       print("Info: Skipping part without colon separator: '$part'");
//     }
//   }

//   // 7. Return the list of successfully parsed periods
//   return parsedPeriods;
// }

// --- Delegate for Sticky TabBar ---
// class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
//   const _SliverTabBarDelegate(this.tabBar);
//   final TabBar tabBar;
//   @override
//   double get minExtent => tabBar.preferredSize.height;
//   @override
//   double get maxExtent => tabBar.preferredSize.height;
//   @override
//   Widget build(
//     BuildContext context,
//     double shrinkOffset,
//     bool overlapsContent,
//   ) {
//     return Container(
//       color: Theme.of(context).scaffoldBackgroundColor,
//       child: tabBar,
//     );
//   }

//   @override
//   bool shouldRebuild(_SliverTabBarDelegate oldDelegate) =>
//       tabBar != oldDelegate.tabBar ||
//       tabBar.controller != oldDelegate.tabBar.controller;
// }

// --- Delegate for the Sticky TabBar ---
// class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
//   _SliverTabBarDelegate(this.tabBar, {required this.backgroundColor});

//   final TabBar tabBar;
//   final Color backgroundColor;

//   double get _tabBarHeight {
//     double height = tabBar.preferredSize.height;
//     if (tabBar.padding is EdgeInsets) {
//       height += (tabBar.padding as EdgeInsets).vertical;
//     }
//     return height;
//   }

//   @override
//   double get minExtent => _tabBarHeight;
//   @override
//   double get maxExtent => _tabBarHeight;

//   @override
//   Widget build(
//       BuildContext context, double shrinkOffset, bool overlapsContent) {
//     return Container(
//       color: backgroundColor, // Apply background color to the entire persistent header area
//       child: tabBar,
//     );
//   }

//   @override
//   bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
//     return tabBar != oldDelegate.tabBar ||
//            backgroundColor != oldDelegate.backgroundColor;
//   }
// }
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate({
    required this.tabBar,
    required this.backgroundColor,
    required this.topSafeAreaPadding,
  });

  final TabBar tabBar;
  final Color backgroundColor;
  final double topSafeAreaPadding;

  double get _tabBarContentHeight {
    double height = tabBar.preferredSize.height;
    final tabBarOwnPadding = tabBar.padding;
    if (tabBarOwnPadding is EdgeInsets) {
      height += tabBarOwnPadding.vertical;
    }
    return height;
  }

  @override
  double get minExtent => _tabBarContentHeight + topSafeAreaPadding;
  @override
  double get maxExtent => _tabBarContentHeight + topSafeAreaPadding;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      padding: EdgeInsets.only(top: topSafeAreaPadding),
      color: backgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar ||
        backgroundColor != oldDelegate.backgroundColor ||
        topSafeAreaPadding != oldDelegate.topSafeAreaPadding;
  }
}

// --- CityDetailsScreen StatefulWidget ---
class CityDetailsScreen extends ConsumerStatefulWidget {
  final String placeId;
  final TopPlace? initialPlaceData;

  const CityDetailsScreen({
    super.key,
    required this.placeId,
    this.initialPlaceData,
  });

  @override
  ConsumerState<CityDetailsScreen> createState() => _CityDetailsScreenState();
}

class _CityDetailsScreenState extends ConsumerState<CityDetailsScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // --- State for AppBar Color Change ---
  late ScrollController _scrollController;
  Color _appBarColor = Colors.transparent;
  Color _appBarIconColor = Colors.white;
  Color _solidAppBarColor = Colors.white;
  Color _solidAppBarIconColor = Colors.black87;
  bool _isSolidColorSet = false;
  final double _colorChangeThreshold = 200.0;
  double _currentScrollOffset = 0.0;
  // --- End AppBar Color State ---

  // --- TabController State (Managed HERE) ---
  // We manage ONE TabController for the WHOLE screen layout
  TabController? _screenTabController;
  // Define the tabs statically for this screen layout
  final List<Widget> _tabs = const [
    Tab(text: 'Overview'),
    Tab(text: 'Forecast'),
    Tab(text: 'Sun Times'),
    Tab(text: 'Places'),
  ];
  // --- End TabController State ---

  // --- State for Scroll-Linked Tabs ---
  final List<GlobalKey> _sectionKeys = List.generate(
    4,
    (_) => GlobalKey(),
  ); // One key per section
  // Map to store calculated offsets (index -> offset) - Optional caching
  // final Map<int, double> _tabOffsets = {};
  bool _isTapScrolling =
      false; // Flag to prevent scroll listener reacting to tab taps
  bool _isScrollUpdatingTabs =
      false; // Flag to prevent tab listener reacting to scroll updates
  double _pinnedHeaderHeight =
      kToolbarHeight; // Approximate initial height, will update
  // --- End Scroll-Linked Tabs State ---
  final GlobalKey _tabBarHeaderKey = GlobalKey();
  late final TabBar
  _tabBarWidget; // Will initialize in initState/didChangeDependencies

  @override
  void initState() {
    super.initState();
    _screenTabController = TabController(length: _tabs.length, vsync: this);
    _scrollController = ScrollController();

    // Add listeners
    _scrollController.addListener(_onScroll); // Existing + new logic
    _screenTabController?.addListener(
      _handleTabSelection,
    ); // Existing + modified logic

    // Get Pinned Header height AFTER first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Calculate actual TabBar height (better than kToolbarHeight)
        final double? headerHeight =
            _tabBarHeaderKey
                .currentContext
                ?.size
                ?.height; // <<< USE THE NEW KEY
        final RenderBox? tabBarBox =
            _sectionKeys[0].currentContext
                ?.findAncestorRenderObjectOfType<RenderSliverPersistentHeader>()
                ?.child; // Accessing the delegate's child renderbox MIGHT work, but is fragile.
        // A simpler approach is often to measure the TabBar itself if possible
        // Or use a known constant if layout is fixed. Let's stick to approx for now.
        setState(() {
          _pinnedHeaderHeight = headerHeight ?? kTextTabBarHeight;
        });
        _onScroll(); // Initial check after layout
      }
    });
  }

  void _handleTabSelection() {
    if (_screenTabController == null ||
        _isScrollUpdatingTabs ||
        !_screenTabController!.indexIsChanging) {
      // If the change was triggered by scrolling, or it's not user-initiated, do nothing
      return;
    }

    final int index = _screenTabController!.index;
    _scrollToSection(index);
  }

  // --- New Method: Scroll to a Section ---
  Future<void> _scrollToSection(int index) async {
    if (_sectionKeys[index].currentContext == null) {
      print("Warning: Context for section $index not found, cannot scroll.");
      return;
    }

    // Prevent scroll listener from interfering
    _isTapScrolling = true;

    // Calculate target offset: Section top - pinned header height (approx)
    // Using ensureVisible is generally more robust as it handles sliver contexts
    await Scrollable.ensureVisible(
      _sectionKeys[index].currentContext!,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      // alignment: 0.0, // Align to the top edge
      // alignmentPolicy: ScrollPositionAlignmentPolicy.explicit, // Requires specific alignment value
    );

    // Add a small delay to ensure scroll finishes before allowing scroll listener to update tabs again
    await Future.delayed(
      const Duration(milliseconds: 450),
    ); // Slightly longer than animation
    if (mounted) {
      setState(() {
        _isTapScrolling = false;
      });
    }
  }

  // --- Modified _onScroll (Handles AppBar Color AND Tab Updates) ---
  void _onScroll() {
    // 1. AppBar Color Change Logic (Keep as is)
    if (!_scrollController.hasClients || !_isSolidColorSet) return;
    final offset = _scrollController.offset;
    final threshold = _colorChangeThreshold;
    final bool showSolid = offset > threshold;
    final Color targetBgColor =
        showSolid ? _solidAppBarColor : Colors.transparent;
    final Color targetIconColor =
        showSolid ? _solidAppBarIconColor : Colors.white;

    // Update AppBar color state if needed
    if (_appBarColor != targetBgColor || _appBarIconColor != targetIconColor) {
      if (mounted) {
        setState(() {
          _currentScrollOffset = offset;
          _appBarColor = targetBgColor;
          _appBarIconColor = targetIconColor;
        });
      }
    } else if ((_currentScrollOffset - offset).abs() > 1.0 && mounted) {
      // Still update offset if it changes significantly, even if colors don't
      setState(() {
        _currentScrollOffset = offset;
      });
    }

    // 2. Tab Update Logic
    if (_isTapScrolling || _screenTabController == null || !mounted) {
      // Don't update tabs if we are programmatically scrolling from a tap
      return;
    }

    // Determine which tab index corresponds to the current scroll position
    int? currentVisibleIndex;
    double closestEdge = double.infinity;

    for (int i = 0; i < _sectionKeys.length; i++) {
      final keyContext = _sectionKeys[i].currentContext;
      if (keyContext != null) {
        final RenderBox? renderBox =
            keyContext.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          // More robust (usually): Find position relative to Scrollable ancestor
          try {
            final scrollableBox =
                Scrollable.of(keyContext)?.context.findRenderObject()
                    as RenderBox?;
            if (scrollableBox != null) {
              final sectionOffsetInScrollable =
                  renderBox
                      .localToGlobal(Offset.zero, ancestor: scrollableBox)
                      .dy;
              // Calculate distance from the ideal position (just below pinned header)
              final targetPosition =
                  _pinnedHeaderHeight +
                  5; // Target position just below the tab bar + small buffer
              final distance =
                  (sectionOffsetInScrollable - targetPosition).abs();

              // Check if this section's top is *above* or very near the target position
              // and closer than any previous section found
              if (sectionOffsetInScrollable <= targetPosition + 20 &&
                  distance < closestEdge) {
                // Allow a small tolerance window below the target
                closestEdge = distance;
                currentVisibleIndex = i;
              }
            }
          } catch (e) {
            print("Error calculating offset: $e");
          }
        }
      }
    }

    // Update TabController index if it changed and isn't already animating
    if (currentVisibleIndex != null &&
        currentVisibleIndex != _screenTabController!.index &&
        !_screenTabController!.indexIsChanging) {
      _isScrollUpdatingTabs = true; // Signal that scroll is causing the update
      _screenTabController!.animateTo(currentVisibleIndex!);
      // Reset flag after animation likely started/finished (can be tricky)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _isScrollUpdatingTabs = false;
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isSolidColorSet) {
      final theme = Theme.of(context);
      _solidAppBarColor =
          theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface;
      _solidAppBarIconColor =
          theme.appBarTheme.foregroundColor ?? theme.colorScheme.onSurface;
      // Keep initial icon color white for transparent app bar
      // _appBarIconColor = Colors.white; // Already set initially
      _isSolidColorSet = true;
      // Update initial colors based on scroll position *after* theme colors are set
      _onScroll();

      _tabBarWidget = TabBar(
        controller:
            _screenTabController, // Controller needed for correct sizing? Usually not.
        isScrollable: false,
        labelColor: Theme.of(context).primaryColor, // Use current theme
        unselectedLabelColor: Colors.grey[600], // Use current theme
        indicatorColor: Theme.of(context).primaryColor, // Use current theme
        tabs: _tabs,
      );

      // Get the preferred height and update state if it changed
      final double calculatedHeight = _tabBarWidget.preferredSize.height;

      if (_pinnedHeaderHeight != calculatedHeight) {
        // Use setState only if needed, prevents unnecessary rebuild cycles if called multiple times
        setState(() {
          _pinnedHeaderHeight = calculatedHeight;
          print(
            "Pinned Header Height Updated: $_pinnedHeaderHeight",
          ); // Debugging
        });
      }

      // Ensure initial scroll check runs after potential height update
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _onScroll();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _screenTabController?.removeListener(_handleTabSelection);
    _scrollController.dispose();
    _screenTabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // KeepAlive call

    final double offset = _currentScrollOffset;
    final int cityIdInt = int.tryParse(widget.placeId) ?? -1;

    // Watch providers
    final AsyncValue<CityDetail> cityDetailsAsync = ref.watch(
      cityDetailsProvider(cityIdInt),
    );
    final AsyncValue<List<PlaceByCity>> placesInCityAsync = ref.watch(
      placesInCityProvider(cityIdInt),
    );

    // Initial display variable setup
    String displayName =
        widget.initialPlaceData?.name ??
        cityDetailsAsync.valueOrNull?.name ??
        'Details';
    String displayCountry =
        widget.initialPlaceData?.country.name ??
        cityDetailsAsync.valueOrNull?.country.name ??
        '...';
    String? displayImageUrl =
        widget.initialPlaceData?.imageUrl ??
        cityDetailsAsync.valueOrNull?.primaryImageUrl;
    bool useDefaultImage =
        widget.initialPlaceData?.usesDefaultImage ??
        cityDetailsAsync.valueOrNull?.usesDefaultImage ??
        (displayImageUrl == null || displayImageUrl.isEmpty);
    final heroTag = 'place-image-${widget.placeId}';
    // final isLiked = ref.watch(placeLikeStateProvider)[cityIdInt] ?? false;
    final double topSafeArea = MediaQuery.paddingOf(context).top;

    final likedCitiesAsyncValue = ref.watch(likedCitiesProvider);
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          // --- SliverAppBar ---
          SliverAppBar(
            expandedHeight: 300.0,
            // pinned: false,
            floating: true,
            snap: true,
            backgroundColor: _appBarColor,
            foregroundColor: _appBarIconColor,
            /* ... other AppBar properties (elevation, surfaceTintColor) ... */
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
              likedCitiesAsyncValue.when(
                data: (likedIds) {
                  final bool isCurrentlyLiked =
                      cityIdInt != -1 && likedIds.contains(cityIdInt);

                  return Container(
                    child: FloatingHeartLikeButton(
                      key: ValueKey('like-button-$cityIdInt-$isCurrentlyLiked'),
                      initialIsLiked: isCurrentlyLiked,
                      size: 24, // Adjust size as needed

                      onLikedChanged: (bool buttonWantsToBecomeLiked) async {
                        if (cityIdInt == -1) {
                          print(
                            "Error: City ID is invalid ($cityIdInt), cannot like/unlike.",
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Cannot update like status: Invalid City ID.",
                                ),
                              ),
                            );
                          }
                          return; // Prevent action and visual change if ID is invalid
                        }

                        final notifier = ref.read(likedCitiesProvider.notifier);

                        try {
                          if (buttonWantsToBecomeLiked) {
                            await notifier.likeCity(cityIdInt);
                            print("Action: Attempted to LIKE city $cityIdInt");
                          } else {
                            await notifier.dislikeCity(cityIdInt);
                            print(
                              "Action: Attempted to DISLIKE city $cityIdInt",
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Failed to update like status: ${e.toString()}',
                                ),
                              ),
                            );
                          }
                        }
                        ;
                      },
                    ),
                  );
                },
                loading: () => Container(),
                error: (error, stackTrace) => Container(),
              ),
            ],
            centerTitle: true,
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
                                    displayImageUrl,
                                  ), // Use updated URL
                                  fit: BoxFit.cover,
                                )
                                : null),
                  ),
                ),
              ),
            ),
          ), // --- End SliverAppBar ---
          // --- SliverList for Top Static Content (Name/Country) ---
          SliverToBoxAdapter(
            // Use SliverToBoxAdapter for single box widgets
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                16.0,
                20.0,
                16.0,
                0,
              ), // Adjust padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: Text(
                      displayCountry,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  // Removed SizedBox(height: 24) here
                ],
              ),
            ),
          ), // --- End SliverList for Top Content ---
          // --- Sticky Header for Main Tabs ---
          SliverPersistentHeader(
            delegate: _SliverTabBarDelegate(
              backgroundColor: Theme.of(context).colorScheme.surface,
              topSafeAreaPadding: topSafeArea,
              tabBar: TabBar(
                padding: EdgeInsets.all(10),
                controller:
                    _screenTabController, // Use the screen's TabController
                isScrollable:
                    false, // Make tabs fit screen width or scroll if needed
                labelColor: Theme.of(context).primaryColor,
                labelPadding: EdgeInsets.symmetric(horizontal: 8.0),
                dividerHeight: 0,
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: Theme.of(context).primaryColor,
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
                        Theme.of(
                          context,
                        ).primaryColor, // Color of the box border
                    width: 2.0, // Thickness of the box border
                  ),
                  // Optional: You could add a subtle background color to the selected tab's box
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                ),
                // --- End Indicator Customization ---
                tabs: _tabs, // Use the static list of Tabs
              ),
            ),
            pinned: true, // Make the header stick
          ),

          _buildSectionSliver(
            context: context,
            key: _sectionKeys[0], // Key for Overview section
            child: cityDetailsAsync.when(
              data: (details) {
                List<TravelPeriod> parsedTravelPeriods = parseBestTimeToTravel(
                  details.bestTimeToTravel,
                );
                return Column(
                  children: [
                    CityDetailsOverview(
                      details: details,
                      parsedTravelPeriods: parsedTravelPeriods,
                      rawBestTimeText: details.bestTimeToTravel,
                    ),
                  ],
                );
              },
              loading: () => _buildLoadingIndicator(),
              error: (e, s) => _buildErrorWidget("Overview", e),
            ),
          ),

          _buildSectionSliver(
            context: context,
            key: _sectionKeys[1], // Key for Forecast section
            child: cityDetailsAsync.when(
              data:
                  (details) => HourlyForecastChart(
                    weatherForecast: details.weatherForecast,

                    locationKey: details.id.toString(),
                    lastUpdated: details.weatherLastUpdated,
                  ),
              loading: () => _buildLoadingIndicator(),
              error: (e, s) => _buildErrorWidget("Forecast", e),
            ),
          ),

          _buildSectionSliver(
            context: context,
            key: _sectionKeys[2], // Key for Sun Times section
            child: cityDetailsAsync.when(
              data:
                  (details) =>
                      buildCitySunDetailsContent(context, ref, details),
              loading: () => _buildLoadingIndicator(),
              error: (e, s) => _buildErrorWidget("Sun Times", e),
            ),
          ),

          _buildSectionSliver(
            context: context,
            key: _sectionKeys[3], // Key for Places section
            // Use the stateful widget directly if it handles its own AsyncValue state
            child: CityPlacesGrid(placesInCityAsync: placesInCityAsync),
            // Or, if CityPlacesGrid expects List<PlaceByCity>:
            // child: placesInCityAsync.when(
            //    data: (places) => CityPlacesGrid(places: places), // Adjust CityPlacesGrid constructor
            //    loading: () => _buildLoadingIndicator(),
            //    error: (e, s) => _buildErrorWidget("Places", e),
            // ),
          ),
        ],
      ),
    );
  } // End build

  // Helper to build section slivers with padding and key
  Widget _buildSectionSliver({
    required BuildContext context,
    required GlobalKey key,
    required Widget child,
  }) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 24.0,
      ), // Add padding around each section
      sliver: SliverToBoxAdapter(
        child: Container(
          // <<< WRAP child in a Container (or KeyedSubtree)
          key: key, // <<< ATTACH KEY HERE (to the RenderBox)
          child: child,
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 32.0),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorWidget(String sectionName, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: Text('Error loading $sectionName: $error'),
      ),
    );
  }
}

// --- Placeholder definitions for external widgets (REPLACE WITH YOUR ACTUAL IMPORTS) ---
class CityDetailsOverview extends StatelessWidget {
  final CityDetail details;
  final List<TravelPeriod> parsedTravelPeriods;
  final String? rawBestTimeText;
  const CityDetailsOverview({
    Key? key,
    required this.details,
    required this.parsedTravelPeriods,
    required this.rawBestTimeText,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text('\n${details.description ?? ""}'),
      // buildBestTimeSection(context, parsedTravelPeriods, rawBestTimeText)
    ],
  );
}
