// // lib/features/places/presentation/screens/city_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Import your models
import 'package:travel_app/features/places/domain/city_detail_model.dart';
import 'package:travel_app/features/places/domain/place_by_city_model.dart'; // Use PlaceByCity
import 'package:travel_app/features/places/domain/top_place_model.dart'; // For initial data
import 'package:travel_app/features/places/presentation/providers/places_provider.dart';
import 'package:travel_app/features/places/presentation/widget/cities_places.dart';
import 'package:travel_app/features/places/presentation/widget/cities_time.dart';
import 'package:travel_app/features/places/presentation/widget/hourly_forecast_chart.dart';
import 'package:travel_app/widget/floating_heart_button.dart';


// Assume placeLikeStateProvider exists
final placeLikeStateProvider = StateProvider<Map<int, bool>>((ref) => {});

// Define TravelPeriod class if not imported
class TravelPeriod {
  final String when, why;
  const TravelPeriod({required this.when, required this.why});
}

// Assume parseBestTimeToTravel function is available
List<TravelPeriod> parseBestTimeToTravel(String? rawText) {
  return [];
}

// --- Delegate for Sticky TabBar ---
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  const _SliverTabBarDelegate(this.tabBar);
  final TabBar tabBar;
  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) =>
      tabBar != oldDelegate.tabBar ||
      tabBar.controller != oldDelegate.tabBar.controller;
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

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _screenTabController = TabController(length: _tabs.length, vsync: this);
    // *** ADD THIS LISTENER ***
    _screenTabController?.addListener(_handleTabSelection);
  }

  // *** ADD THIS HANDLER FUNCTION ***
  void _handleTabSelection() {
    // Ensure the setState is only called if the index has finished changing
    // and the widget is still mounted.
    if (_screenTabController != null &&
        !_screenTabController!.indexIsChanging &&
        mounted) {
      setState(() {
        // The call to setState triggers a rebuild, which will then use
        // the new _screenTabController.index in the build method.
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
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    // *** REMOVE THE LISTENER ***
    _screenTabController?.removeListener(_handleTabSelection);
    _screenTabController?.dispose();
    super.dispose();
  }

  // --- Scroll Listener for AppBar Color (Remains the same) ---
  void _onScroll() {
    if (!_scrollController.hasClients || !_isSolidColorSet) return;
    final offset = _scrollController.offset;
    final threshold = _colorChangeThreshold;
    final Color targetBgColor =
        offset > threshold ? _solidAppBarColor : Colors.transparent;
    final Color targetIconColor =
        offset > threshold ? _solidAppBarIconColor : Colors.white;
    if (_appBarColor != targetBgColor ||
        _appBarIconColor != targetIconColor ||
        (_currentScrollOffset - offset).abs() > 1.0) {
      if (mounted) {
        setState(() {
          _currentScrollOffset = offset;
          _appBarColor = targetBgColor;
          _appBarIconColor = targetIconColor;
        });
      }
    }
  }
  // --- End Scroll Listener ---

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

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          // --- SliverAppBar ---
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
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
              Container(
                child: FloatingHeartLikeButton(
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
              ),
            ],
            title: Text(
              displayName,
              style: TextStyle(fontSize: 18, color: _appBarIconColor),
            ),
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
                16.0,
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
                  const SizedBox(height: 8),
                  Text(
                    displayCountry,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  // Removed SizedBox(height: 24) here
                ],
              ),
            ),
          ), // --- End SliverList for Top Content ---
          // --- Sticky Header for Main Tabs ---
          SliverPersistentHeader(
            delegate: _SliverTabBarDelegate(
              TabBar(
                controller:
                    _screenTabController, // Use the screen's TabController
                isScrollable:
                    false, // Make tabs fit screen width or scroll if needed
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: Theme.of(context).primaryColor,
                tabs: _tabs, // Use the static list of Tabs
              ),
            ),
            pinned: true, // Make the header stick
          ),

          // --- Content Area for the Selected Main Tab ---
          // Use SliverFillRemaining to fill the rest of the viewport OR
          // Use SliverToBoxAdapter if content height is known/calculable
          // Using SliverToBoxAdapter assuming content might vary but won't be infinitely long
          SliverToBoxAdapter(
            child: AnimatedSwitcher(
              // Fade between tab contents
              duration: const Duration(milliseconds: 300),
              child: Container(
                key: ValueKey<int>(
                  _screenTabController?.index ?? 0,
                ), // Key by tab index
                // Add padding for the content INSIDE the tab view area
                padding: const EdgeInsets.all(16.0),
                child: _buildSelectedTabContent(
                  context,
                  ref,
                  cityDetailsAsync,
                  placesInCityAsync,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  } // End build

  // --- Helper to build content based on selected MAIN tab ---
  Widget _buildSelectedTabContent(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<CityDetail> cityDetailsAsync,
    AsyncValue<List<PlaceByCity>> placesInCityAsync,
  ) {
    final int currentTabIndex = _screenTabController?.index ?? 0;

    switch (currentTabIndex) {
      case 0: // Overview Tab
        return cityDetailsAsync.when(
          data: (details) {
            List<TravelPeriod> parsedTravelPeriods = parseBestTimeToTravel(
              details.bestTimeToTravel,
            );
            String? rawBestTimeText = details.bestTimeToTravel;
            // Assuming CityDetailsOverview is StatelessWidget
            return CityDetailsOverview(
              details: details,
              parsedTravelPeriods: parsedTravelPeriods,
              rawBestTimeText: rawBestTimeText,
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text("Error: $e")),
        );
      case 1: // Forecast Tab
        return cityDetailsAsync.when(
          data:
              (details) => HourlyForecastChart(
                hourlyData: details.weatherForecast?.hourly,
                locationKey: details.id.toString(),
                lastUpdated: details.weatherLastUpdated,
              ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text("Error: $e")),
        );
      case 2: // Sun Times Tab
        return cityDetailsAsync.when(
          data:
              (details) => buildCitySunDetailsContent(
                context,
                ref, // Assuming ref is available here
                details,
              ), // Pass details
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text("Error: $e")),
        );
      case 3: // Places Tab
        // Instantiate the stateful grid widget here
        return CityPlacesGrid(
          // USE THE STATEFUL WRAPPER
          placesInCityAsync: placesInCityAsync,
        );
      default:
        return const Center(child: Text("Unknown Tab"));
    }
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
  Widget build(BuildContext context) =>
      Text('\n${details.description ?? ""}');
}
