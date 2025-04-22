// lib/features/places/presentation/screens/city_details_screen.dart

import 'dart:convert';
import 'dart:math'; // For pagination calculation

import 'package:collection/collection.dart'; // For deep list equality check
import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:travel_app/core/constants/weather_icons.dart';
import 'package:travel_app/features/places/data/repositories/cities_time.dart';
// Import your models
import 'package:travel_app/features/places/domain/city_detail_model.dart';
import 'package:travel_app/features/places/domain/place_by_city_model.dart'; // Use PlaceByCity
import 'package:travel_app/features/places/domain/top_place_model.dart'; // For initial data
// Import helpers and providers
import 'package:travel_app/features/places/presentation/controllers/helper.dart';
import 'package:travel_app/features/places/presentation/providers/places_provider.dart';
import 'package:travel_app/widget/sun_position_arc.dart';

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
                child: Container(/* Gradient Overlay */),
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
                    data: (details) {
                      return Column(
                        children: [
                          _buildCityDetailsContent(
                            context,
                            details,
                            parsedTravelPeriods,
                            rawBestTimeText,
                          ),
                          Card(
                            elevation: 1, // Optional elevation
                            margin:
                                EdgeInsets
                                    .zero, // Remove Card's default margin if needed
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: _buildCitySunDetailsContent(
                              context,
                              details,
                              parsedTravelPeriods,
                              rawBestTimeText,
                            ),
                          ),
                        ],
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
  // --- UPDATED Helper for City Details Content ---
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
    // Remove 'formattedData' if not used elsewhere
    // final formattedData = details.weatherForecast?.hourly?.formattedHourlyWeather;
    final hourlyRaw = details.weatherForecast?.hourly;

    // --- Data Extraction for Chart ---
    List<Map<String, dynamic>>? chartData;
    if (hourlyRaw?.time != null &&
        hourlyRaw?.temperature2m != null &&
        hourlyRaw?.weathercode != null && // Check weathercode
        hourlyRaw?.isDay != null && // Check isDay
        hourlyRaw?.time!.length == hourlyRaw?.temperature2m!.length &&
        hourlyRaw?.time!.length == hourlyRaw?.weathercode!.length &&
        hourlyRaw?.time!.length == hourlyRaw?.isDay!.length) {
      chartData = [];
      for (int i = 0; i < hourlyRaw!.time!.length; i++) {
        String timeStr = hourlyRaw.time![i];
        String displayTime = timeStr.split('T').last; // "HH:MM"
        int weatherCode = hourlyRaw.weathercode![i];
        int isDay = hourlyRaw.isDay![i];

        // --- Look up Description and Icon ---
        final codeInfo = wmoWeatherCodes[weatherCode.toString()];
        String description = "Unknown";
        String iconUrl =
            "http://openweathermap.org/img/wn/01d@2x.png"; // Sensible default

        if (codeInfo != null) {
          final dayNightKey = isDay == 1 ? 'day' : 'night';
          if (codeInfo[dayNightKey] != null && codeInfo[dayNightKey] is Map) {
            description =
                codeInfo[dayNightKey]['description'] as String? ?? description;
            iconUrl = codeInfo[dayNightKey]['image'] as String? ?? iconUrl;
          }
        }
        // --- End Lookup ---

        chartData.add({
          'time': displayTime,
          'temperature': hourlyRaw.temperature2m![i],
          'weathercode': weatherCode,
          'description': description, // Include description
          'iconUrl': iconUrl, // Include correct icon URL
        });
      }
    }
    // --- End Data Extraction ---

    // Prepare data for ECharts only if chartData is valid
    List<String> xAxisData = [];
    List<Map<String, dynamic>> seriesData = []; // Use the enriched data
    double yAxisMax = 30; // Default max
    double yAxisMin = 0; // Default min

    if (chartData != null && chartData.isNotEmpty) {
      xAxisData = chartData.map((e) => e['time'] as String).toList();
      // Create the series data expected by the formatter
      seriesData =
          chartData
              .map(
                (e) => {
                  'value': e['temperature'], // Y-value for the line
                  'time':
                      e['time'], // Needed by formatter? No longer needed in label
                  'description': e['description'], // Needed by tooltip
                  'iconUrl':
                      e['iconUrl'], // Needed by rich text label formatter
                },
              )
              .toList();

      // Calculate Y-Axis Max/Min from temperature data
      try {
        // Add try-catch for safety if list might be empty after filtering
        double maxTemp =
            chartData
                .map((e) => e['temperature'] as num)
                .reduce(max)
                .toDouble();
        double minTemp =
            chartData
                .map((e) => e['temperature'] as num)
                .reduce(min)
                .toDouble();
        yAxisMax = (maxTemp + 6).ceilToDouble(); // Padding above
        yAxisMin = (minTemp - 2).floorToDouble(); // Padding below
      } catch (e) {
        print("Error calculating min/max temp: $e");
        // Keep default yAxisMin/Max
      }
    }

    // --- FINAL ECharts Option Map ---
    // Build only if data is available
    final String? echartsOption =
        (chartData != null && chartData.isNotEmpty)
            ? '''
    {
      tooltip: {
        trigger: 'axis',
        formatter: function (params) {
            var param = params[0];
            var data = param.data;
            if (!data) return '';
            var temp = data.value;
            var tempStr = (typeof temp === 'number') ? temp.toFixed(1) + '°C' : '--';
            // Tooltip: Time (axis label) + Description + Temp
            return param.axisValueLabel + '<br/>'
                   + data.description + '<br/>'
                   + tempStr;
        }
      },
      grid: { left: '8%', right: '8%', bottom: '15%', top: '28%', containLabel: false }, // Adjusted margins
      xAxis: {
        type: 'category', boundaryGap: false, show: true, position: 'top',
        data: ${jsonEncode(xAxisData)},
        axisLabel: { interval: 0, rotate: 0, hideOverlap: true, fontSize: 10,fontWeight:800, color: '#666' },
        axisTick: { length: 3, alignWithLabel: true },
        axisLine: { show: true, lineStyle: { color: '#eee' } }
      },
      yAxis: { type: 'value', show: false, scale: true, max: $yAxisMax, min: $yAxisMin },
      dataZoom: [
        { type: 'inside', xAxisIndex: 0, filterMode: 'filter', zoomLock: true, start: 0, end: 30 },
        { type: 'slider', show: false, xAxisIndex: 0 }
      ],
      series: [{
        name: 'Temperature', type: 'line', smooth: true, symbol: 'circle', symbolSize: 4, sampling: 'lttb',
        data: ${jsonEncode(seriesData)}, // <-- PASS CORRECT DATA HERE
        lineStyle: { width: 2 },
        areaStyle: { opacity: 0.1 },
        label: {
            show: true, position: 'top', distance: 8,
            formatter: function(params) {
               var data = params.data;
               var temp = data.value;
               var tempStr = (typeof temp === 'number') ? temp.toFixed(0) + '°' : '--';
               // Return rich text array [image, temp]
               return [ '{img|}', '{tempStyle|' + tempStr + '}' ].join('\\n');
            },
            rich: {
               img: {
                  // Explicitly check params.data exists before accessing iconUrl
                    backgroundColor: {
                      image: function(params) {
                         // Verify params and data structure again carefully
                         console.log("Rich Img Params:", params); // DEBUG
                         if (params && params.data && params.data.iconUrl && params.data.iconUrl.length > 0) {
                             console.log("Using Icon URL:", params.data.iconUrl); // DEBUG
                             return params.data.iconUrl;
                         }
                         console.warn("Icon URL missing or invalid, using default."); // DEBUG
                         return 'http://openweathermap.org/img/wn/01d@2x.png'; // Default placeholder
                       }
                  },
                  height: 16, width: 16, align: 'center',
                  padding: [0, 0, 1, 0] // Padding below image
               },
               tempStyle: { color: '#333', fontSize: 9, fontWeight: 'bold', align: 'center', lineHeight: 11 }
            }
        }
      }]
    }
    '''
            : null; // Set option to null if no data
    // --- End ECharts Option Map ---

    // --- Main return Column ---
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display Description, Best Time, Famous For (as before)
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
        const SizedBox(height: 24), // Space before chart
        // --- Conditionally display Chart ---
        if (echartsOption != null) ...[
          // Only build if option was generated
          Text(
            "Hourly Forecast:",
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 230,
            width: double.infinity,
            child: Card(
              // Wrap Echarts in Card
              elevation: 1, // Optional elevation
              margin: EdgeInsets.zero, // Remove Card's default margin if needed
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Echarts(
                key: ValueKey(
                  'weather-chart-${widget.placeId}-${details.weatherLastUpdated}',
                ),
                option: echartsOption, // Pass the generated option string
                captureHorizontalGestures: true,
                captureAllGestures: true,
                // Removed reloadAfterInit and onLoad - not needed with ValueKey update
              ),
            ),
          ),
          const SizedBox(height: 16), // Spacing after chart
        ] else ...[
          // Optionally show a message if chart data is missing
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              "Hourly forecast data not available.",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
        // --- End Chart ---
      ],
    );
  }

  Widget _buildCitySunDetailsContent(
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

    // --- Extract Sunrise/Sunset Times (Example) ---
    // IMPORTANT: Your DailyData time strings might need parsing!
    // Assuming daily.time[0] is today, daily.sunrise[0] and daily.sunset[0] are ISO strings
    DateTime? sunriseTime;
    DateTime? sunsetTime;
    final dailyData = details.weatherForecast?.daily;
    if (dailyData?.sunrise != null && dailyData!.sunrise!.isNotEmpty) {
      sunriseTime = DateTime.tryParse(dailyData.sunrise!.first);
    }
    if (dailyData?.sunset != null && dailyData!.sunset!.isNotEmpty) {
      sunsetTime = DateTime.tryParse(dailyData.sunset!.first);
    }
    // --- End Time Extraction ---

    // Get current time (can be passed in or fetched)
    final DateTime now = DateTime.now(); // Use actual current time

    final lat = details.weatherForecast?.latitude;
    final lng = details.weatherForecast?.longitude;

    if (lat == null || lng == null) {
      return Text('Location not available');
    }
    final DateFormat localTimeFormatter = DateFormat.jm();
    final DateFormat dateTimeParser = DateFormat(
      "yyyy-MM-dd HH:mm",
    ); // EXAMPLE PARSER - ADJUST TO YOUR API's RETURN FORMAT
    return FutureBuilder<String>(
      future: getCurrentTimeFromLatLng(lat, lng),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData) {
          return const Text('No data received');
        }

        final String localTimeString = snapshot.data!;
        DateTime? localTimeDateTime; // Keep it nullable initially
        String displayLocalTime = "N/A";

        try {
          // *** IMPORTANT: ADJUST PARSING FORMAT HERE ***
          // Example 1: If API returns ISO 8601 string (e.g., "2023-10-27T15:30:00Z" or "2023-10-27T10:30:00-05:00")
          localTimeDateTime = DateTime.parse(localTimeString).toLocal();

          // Example 2: If API returns "YYYY-MM-DD HH:MM" (adjust format string)
          // localTimeDateTime = dateTimeParser.parse(localTimeString, true).toLocal();

          // If parsing successful, format for display
          displayLocalTime = localTimeFormatter.format(localTimeDateTime);
        } catch (e) {
          print(
            "Error parsing fetched local time string '$localTimeString': $e",
          );
          displayLocalTime = localTimeString; // Show raw string as fallback
        }
        // --- End Time Processing ---

        String sunMessage = "";
        if (localTimeDateTime != null &&
            sunriseTime != null &&
            sunsetTime != null) {
          final Duration timeUntilSunrise = sunriseTime.difference(
            localTimeDateTime,
          );
          final Duration timeUntilSunset = sunsetTime.difference(
            localTimeDateTime,
          );

          // Check if sunrise is upcoming (within next 90 mins)
          if (timeUntilSunrise > Duration.zero &&
              timeUntilSunrise <= const Duration(minutes: 90)) {
            sunMessage = "Sunrise soon! Don't miss it.";
          }
          // Check if sunset is upcoming (within next 90 mins)
          else if (timeUntilSunset > Duration.zero &&
              timeUntilSunset <= const Duration(minutes: 90)) {
            sunMessage = "Sunset approaching! Find a good spot.";
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ), // Space below time text
              child: Text(
                "Current time is $displayLocalTime",
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            if (sunMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(
                  right: 12,left: 12,
                  bottom: 10,
                ), // Space below message
                child: Text(
                  sunMessage,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            // --- Add Sun Arc Widget ---
            if (sunriseTime != null && sunsetTime != null)
              Center(
                // Center the Arc widget horizontally
                child: SunPositionArc(
                  sunrise: sunriseTime,
                  sunset: sunsetTime,
                  currentTime: localTimeDateTime,
                  size: 180, // Adjust size
                  arcColor: Colors.orange.shade300,
                  sunColor: Colors.yellow.shade700,
                  timeColor: Colors.black54,
                  strokeWidth: 2,
                  sunRadius: 8,
                ),
              )
            else
              const Text(
                "Sunrise/sunset data unavailable.",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),

            // --- End Sun Arc ---
            const SizedBox(height: 24), // Space after sun arc
          ],
        );
      },
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
