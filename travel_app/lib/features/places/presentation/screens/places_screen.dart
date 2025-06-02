import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:travel_app/core/enums/search_type.dart';
import 'package:travel_app/core/router/app_router.dart';
import 'package:travel_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:travel_app/features/places/domain/city_suggestion_model.dart';
import 'package:travel_app/features/places/domain/place_model.dart'; // Still needed for Category section
import 'package:travel_app/features/places/domain/place_state.dart';
import 'package:travel_app/features/places/domain/place_suggestion_model.dart';
import 'package:travel_app/features/places/domain/places_notifier.dart';
import 'package:travel_app/features/places/domain/top_place_model.dart'; // Needed for Top Places section
import 'package:travel_app/features/places/presentation/controllers/places_controller.dart';
import 'package:travel_app/features/places/presentation/providers/paginated_category_places_provider.dart';
// Import the State and Notifier for infinite scroll
import 'package:travel_app/features/places/presentation/widget/carousel_view.dart';
import 'package:travel_app/features/places/presentation/widget/category_places_grid.dart';
import 'package:travel_app/features/places/presentation/widget/city_autocomplete_search.dart';
import 'package:travel_app/widget/floating_heart_button.dart';
import 'package:go_router/go_router.dart';

// Import other providers
import '../providers/places_provider.dart'; // Contains placesCategoriesProvider, placesProvider

// Define a StateProvider for selected category (if not already defined elsewhere)
// Keeping it here for a self-contained example
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final placeLikeStateProvider = StateProvider<Map<int, bool>>((ref) {
  // TODO: Load initial like states from backend/storage here
  return {};
});

class PlacesScreen extends ConsumerWidget {
  const PlacesScreen({super.key});

  // --- Helper Function to Build Top Places Skeleton ---
  Widget _buildTopPlacesSkeleton(BuildContext context) {
    // Create dummy data specifically for the skeleton structure
    final dummyPlaces = List.generate(
      3, // Show 3 skeleton cards - adjust count as needed for visual balance
      (index) => TopPlace(
        // Provide placeholder values for fields used by CarouselViewWidget's item builder
        id: -index, // Use negative or distinct IDs for dummies
        name: 'Placeholder Location Name', // Placeholder text
        country: Country(id: 0, name: 'Placeholder Country'), // Dummy country
        // Set image fields based on how _buildPlaceImage handles them
        // Add any other non-nullable fields required by TopPlace constructor
        // with appropriate dummy/default values. Example:
        // description: 'Loading description...',
        // rating: 0.0,
      ),
    );

    // 2. Wrap the structure you want to skeletonize with Skeletonizer
    return Skeletonizer(
      enabled: true, // Keep enabled during loading
      // Optional: Customize skeleton appearance further if needed
      // ignoreContainers: false, // Set true if you want containers (like Card background) to NOT be skeletonized
      // containersColor: Colors.grey[300],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Skeleton for the Title
          const Padding(
            // Use const here
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Text(
              'Recently Added', // The actual text content doesn't matter here
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              // Optional: Use Bone.text for finer control if needed
              // child: Bone.text(words: 2, style: ...),
            ),
          ),

          // Provide the CarouselViewWidget with DUMMY data and inactive callbacks
          // This allows Skeletonizer to understand the layout (ListView, Cards)
          CarouselViewWidget(
            places: dummyPlaces, // <-- Use the generated dummy list
            isLoadingMore: false, // <-- Skeleton doesn't show loading indicator
            canLoadMore: false, // <-- Skeleton cannot load more
            onLoadMore:
                () {}, // <-- Provide an empty function, it won't be called
            // --- Provide Dummy Values for Like Parameters ---
            // likeStates: const {}, // <-- Provide an empty constant map
            favoritePlaceIds: const {}, // <-- Provide an empty constant set
            placesBeingLiked: const {}, // <-- Provide an empty constant set
            onLikeChanged:
                (placeId, isLiked) {}, // <-- Empty function signature still
          ),
        ],
      ),
    );
  }

  // --- Helper Function to Build Category Places Skeleton ---
  // (This section seems correct based on your previous code and uses the Place model)
  Widget _buildCategoryPlacesSkeleton(BuildContext context) {
    // Create dummy data
    final dummyPlaces = List.generate(
      5, // Show 5 skeleton items in the horizontal list
      (index) => Place(
        id: index,
        name: "Loading Place Name...",
        attributes: {},
        // Ensure imageUrl is not null if the widget expects it
        images: [], // Or a valid placeholder URL if required by widget logic
        // Add other required fields from your Place model with dummy values
        // city: City(id: 0, name: 'City'),
      ),
    );

    return Skeletonizer(
      enabled: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            // Use const here
            padding: EdgeInsets.all(16),
            child: Text(
              'Categories',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16), // Spacer
          SizedBox(
            height: 180, // Match the height of the real list
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: dummyPlaces.length,
              itemBuilder: (context, index) {
                final place = dummyPlaces[index];
                // Use the same widget structure as the real data case
                return Container(
                  width: 160,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.all(12),
                  // Use Bone for container background if desired
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300, // Placeholder color
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name, // Will be skeletonized
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // Add skeletons for other elements if present in the real item
                      // const SizedBox(height: 4),
                      // const Bone.text(words: 1, width: 0.6), // Example for city/location line
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the 'categories' provider and the current category selection
    final categoryAsync = ref.watch(placesCategoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    // Update PlacesParams with the selected category when it changes
    // This is for the *Category-filtered* list, not the Top Places list
    final categoryPlacesParams = PlacesParams(
      cityId: 1, // Example City ID - adjust as needed
      category:
          selectedCategory ??
          'natural_wonder', // Default to 'natural_wonder' if null
      page: 1, // This specific provider is not paginated in your current code
      size: 10, // This specific provider is not paginated in your current code
    );

    // Watch the 'best-for-you' provider using the updated params
    // final placesAsyncValue = ref.watch(placesProvider(categoryPlacesParams)); // Used for category list

    // --- Watch the NEW paginated Top Places provider ---
    final topPlacesState = ref.watch(paginatedTopPlacesProvider);
    // Read the notifier to call methods (like fetchMorePlaces, refresh)
    final topPlacesNotifier = ref.read(paginatedTopPlacesProvider.notifier);
    // --- End NEW provider watching ---
    final likeStates = ref.watch(placeLikeStateProvider);

    // --- Display Like/Dislike Error using SnackBar ---
    ref.listen<PaginatedPlacesState>(paginatedTopPlacesProvider, (_, next) {
      if (next.likeError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.likeError!),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        // Optional: Clear the error after showing it?
        // Future.delayed(Duration.zero, () => ref.read(paginatedTopPlacesProvider.notifier).clearLikeError());
        // Requires a clearLikeError method in the notifier: state = state.copyWith(likeError: null);
      }
    });
    // --- End Error Display ---

    // Helper variable to build the Top Places section based on its state
    Widget topPlacesSection;

    // --- Build the Top Places section based on the state ---
    if (topPlacesState.isLoadingInitial) {
      // Show skeleton while the first page is loading
      topPlacesSection = _buildTopPlacesSkeleton(context);
    } else if (topPlacesState.initialError != null) {
      // Show error if the initial load failed
      print(
        "--- PlacesScreen Error (TopPlaces Initial): ${topPlacesState.initialError} ---",
      );
      topPlacesSection = Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Error loading top places: ${topPlacesState.initialError}',
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else if (topPlacesState.places.isEmpty) {
      // Show empty message if initial load was successful but returned no data
      topPlacesSection = const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No top places found.'),
        ),
      );
    } else {
      // Data is available, display the carousel
      topPlacesSection = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Text(
              'Recently Added', // Keep your title
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          CarouselViewWidget(
            places: topPlacesState.places, // Pass the list from the state
            isLoadingMore:
                topPlacesState
                    .isLoadingMore, // Pass loading state for indicator
            canLoadMore:
                topPlacesState.canLoadMore, // Pass if more pages are available
            onLoadMore: () {
              // Call the notifier's fetchMorePlaces method
              topPlacesNotifier.fetchMorePlaces();
            },
            // likeStates: likeStates, // Pass the map from the provider
            // --- Pass Updated State ---
            favoritePlaceIds:
                topPlacesState.favoritePlaceIds, // Pass the set of IDs
            placesBeingLiked:
                topPlacesState.placesBeingLiked, // Pass the loading set
            onLikeChanged: (placeId, currentIsLiked) {
              // Call the notifier method to handle logic
              topPlacesNotifier.toggleLikeStatus(placeId, currentIsLiked);
            },
          ),
          // Optional: Show pagination error below the list
          if (topPlacesState.paginationError != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18.0,
                vertical: 4.0,
              ),
              child: Text(
                'Could not load more top places: ${topPlacesState.paginationError}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      );
    }
    // --- End Build Top Places section ---

    // Helper variable to build the Category Places section
    Widget categorySection;

    // --- Build the Category Places section based on categoryAsync state ---
    categorySection = categoryAsync.when(
      data: (categoryList) {
        // Set the initial category only once if it's null
        // Using Future.microtask to avoid setState during build
        if (ref.read(selectedCategoryProvider) == null &&
            categoryList.isNotEmpty) {
          Future.microtask(() {
            ref.read(selectedCategoryProvider.notifier).state =
                categoryList.first.name;
          });
        }

        if (categoryList.isEmpty) {
          // Even if categories loaded, if the list is empty, show message
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No categories available.'),
          );
        }

        // Watch the specific places list based on the *current* category selection
        // **IMPORTANT:** This provider currently fetches a fixed size list (not paginated)
        final placesAsyncValue = ref.watch(
          placesProvider(categoryPlacesParams),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Categories Header
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Categories',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            // Category Chips Scroll
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const SizedBox(width: 8), // Add some leading space
                  ...categoryList.map((category) {
                    final isSelected = selectedCategory == category.name;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4, // Reduced horizontal padding for chips
                      ),
                      child: ChoiceChip(
                        label: Text(category.displayName),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            // Only update if selecting, not deselecting (ChoiceChip behavior)
                            ref.read(selectedCategoryProvider.notifier).state =
                                category.name;
                            // The `placesProvider` automatically updates because its parameter (`categoryPlacesParams`)
                            // changes when `selectedCategoryProvider` changes, which it watches.
                            // So, explicit invalidate might not be strictly necessary here, but doesn't hurt.
                            // ref.invalidate(placesProvider(categoryPlacesParams));
                          }
                          // If you want deselection to set it to null:
                          // ref.read(selectedCategoryProvider.notifier).state = selected ? category.osm_value : null;
                        },
                      ),
                    );
                  }).toList(),
                  const SizedBox(width: 8), // Add some trailing space
                ],
              ),
            ),
            const SizedBox(height: 16), // Spacer below chips
            // Fetched places list for the selected category
            placesAsyncValue.when(
              data: (placesResponse) {
                // placesResponse is of type PlacesResponse
                if (placesResponse.places.isEmpty) {
                  // Access the list correctly
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No places found for this category.'),
                  );
                }
                if (selectedCategory != null) {
                  // selectedCategory is from ref.watch(selectedCategoryProvider)
                  final categoryPlacesParams = CategoryPlacesParams(
                    category:
                        selectedCategory, // This is the OSM value or API key
                    interests:
                        "food,sightseeing", // TODO: Source this appropriately (e.g., user profile, fixed)
                  );

                  // The CategoryPlacesGridWidget needs bounded height.
                  // If its parent Column is inside SingleChildScrollView, give it a fixed height.
                  return SizedBox(
                    height:
                        450, // <<<< ADJUST THIS HEIGHT as needed for your 3x3 grid + potential extra rows
                    child: CategoryPlacesHorizontalGridWidget(
                      params: categoryPlacesParams,
                      // Optionally adjust these if your items are very different in size:
                      // gridPageWidth: 350, // total width for one 3x3 grid "page"
                      // itemHeight: 110, // height of a single item in the grid
                    ),
                  );
                } else {
                  // If no category is selected yet, show a placeholder or prompt
                  return Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text("Select a category to see places."),
                    ),
                  );
                }
                // return SizedBox(
                //   height: 180, // Fixed height for the category list
                //   child: ListView.builder(
                //     cacheExtent:
                //         9999, // Consider reducing this if performance is an issue
                //     scrollDirection: Axis.horizontal,
                //     itemCount: placesResponse.places.length, // Use list length
                //     padding: const EdgeInsets.symmetric(
                //       horizontal: 8.0,
                //     ), // Add padding for list edges
                //     itemBuilder: (context, index) {
                //       final place = placesResponse.places[index];
                //       // Handle image loading for this section
                //       final image =
                //           place.usesDefaultImage
                //               ? const AssetImage('assets/city.png')
                //               : NetworkImage(place.imageURL!) as ImageProvider;

                //       return Container(
                //         width: 160,
                //         margin: const EdgeInsets.symmetric(horizontal: 8),
                //         child: Stack(
                //           children: [
                //             // Background image
                //             Container(
                //               decoration: BoxDecoration(
                //                 borderRadius: BorderRadius.circular(12),
                //                 image: DecorationImage(
                //                   image: image,
                //                   fit: BoxFit.cover,
                //                 ),
                //               ),
                //             ),
                //             // Dark overlay for readability
                //             Container(
                //               decoration: BoxDecoration(
                //                 borderRadius: BorderRadius.circular(12),
                //                 gradient: LinearGradient(
                //                   begin: Alignment.topCenter,
                //                   end: Alignment.bottomCenter,
                //                   colors: [
                //                     Colors.black.withOpacity(0.3),
                //                     Colors.black.withOpacity(0.6),
                //                   ],
                //                 ),
                //               ),
                //             ),
                //             // Text content
                //             Padding(
                //               padding: const EdgeInsets.all(12),
                //               child: Column(
                //                 crossAxisAlignment: CrossAxisAlignment.start,
                //                 children: [
                //                   Text(
                //                     place.name,
                //                     style: const TextStyle(
                //                       fontWeight: FontWeight.bold,
                //                       fontSize: 16,
                //                       color: Colors.white,
                //                     ),
                //                     maxLines: 1,
                //                     overflow: TextOverflow.ellipsis,
                //                   ),
                //                   const SizedBox(height: 8),
                //                   Expanded(
                //                     child: Text(
                //                       place.description ?? 'No description',
                //                       maxLines: 4,
                //                       overflow: TextOverflow.ellipsis,
                //                       style: const TextStyle(
                //                         fontSize: 12,
                //                         color: Colors.white70,
                //                       ),
                //                     ),
                //                   ),
                //                 ],
                //               ),
                //             ),
                //           ],
                //         ),
                //       );
                //     },
                //   ),
                // );
              },
              loading:
                  () => _buildCategoryPlacesSkeleton(
                    context,
                  ), // Use category skeleton here
              error: (error, stack) {
                print("--- Error fetching places for category: $error");
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error loading places: $error'),
                );
              },
            ),
          ],
        );
      },
      loading:
          () => _buildCategoryPlacesSkeleton(
            context,
          ), // Show skeleton while categories load
      error: (error, stackTrace) {
        print("--- PlacesScreen Error (Categories List): $error ---");
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Error loading categories: $error'),
        );
      },
    );
    // --- End Build Category Places section ---

    void _unfocus(BuildContext context) {
      FocusScopeNode currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
        // currentFocus.focusedChild!.unfocus(); // This might be too aggressive
        FocusManager.instance.primaryFocus?.unfocus(); // More common way
      }
    }

    final TextEditingController searchController = TextEditingController();

    return GestureDetector(
      onTap: () => _unfocus(context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Places'), // Updated title
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh Top Places',
              onPressed: () {
                // Invalidate the NEW paginatedTopPlacesProvider to trigger a refetch from offset 0
                ref.invalidate(paginatedTopPlacesProvider);
                // Optionally invalidate categories/places as well if needed
                // ref.invalidate(placesCategoriesProvider);
                // ref.invalidate(placesProvider(categoryPlacesParams)); // Requires categoryParams available here
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () async {
                // Invalidate relevant providers before logging out
                ref.invalidate(paginatedTopPlacesProvider);
                ref.invalidate(placesCategoriesProvider);
                // Note: invalidating placesProvider requires its parameter, potentially tricky here
                // ref.invalidate(placesProvider(categoryPlacesParams));
                await ref.read(authControllerProvider.notifier).logout();
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            ref.refresh(paginatedTopPlacesProvider);
            ref.refresh(placesCategoriesProvider);
          },
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Align sections to the start
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: UnifiedAutocompleteSearch(
                    // controller: searchController, // Optional: Pass your own controller
                    initialHintText: 'Start typing...', // Generic hint
                    onSuggestionSelected: (suggestion, type) {
                      // This callback receives the selected item and its type

                      _unfocus(
                        context,
                      ); // Unfocus after selection (widget also does this)
                      // SearchController() // Clear the search field

                      if (type == SearchType.city &&
                          suggestion is CitySearchSuggestion) {
                        // It's a City!
                        print(
                          'Selected City: ${suggestion.name} (ID: ${suggestion.id})',
                        );
                        print('Country: ${suggestion.countryName}');

                        // Example: Navigate to City Details Screen
                        final cityDetailPath = AppRoutePaths.cityDetails
                            .replaceFirst(
                              ':placeId', // Assuming your city detail route uses :placeId for city_id
                              suggestion.id.toString(),
                            );
                        context.push(
                          cityDetailPath,
                          extra: suggestion,
                        ); // Pass CitySearchSuggestion as extra

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('City selected: ${suggestion.name}'),
                          ),
                        );
                      } else if (type == SearchType.place &&
                          suggestion is PlaceSearchSuggestion) {
                        // It's a Place!
                        print(
                          'Selected Place: ${suggestion.name} (ID: ${suggestion.id})',
                        );
                        print(
                          'Category: ${suggestion.category}, Address: ${suggestion.address}',
                        );
                        // If you have images for places:
                        // print('First Image: ${suggestion.images.isNotEmpty ? suggestion.images.first : "No image"}');

                        // Example: Navigate to Place Details Screen (if you have one)
                        // Or maybe show it on a map, or add to a list, etc.
                        // final placeDetailPath = AppRoutePaths.placeDetails.replaceFirst(':placeId', suggestion.id.toString());
                        // context.push(placeDetailPath, extra: suggestion);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Place selected: ${suggestion.name}'),
                          ),
                        );
                      }
                    },
                  ),
                ),
                // Integrate the built Top Places section widget
                topPlacesSection,
                const SizedBox(height: 24), // Add space between sections
                // Integrate the built Categories section widget
                categorySection,

                // You might have other sections here
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18),
                  child: Text(
                    'Other Sections...',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 200), // Placeholder space
              ],
            ),
          ),
        ),
        // Consider removing the FAB if the AppBar refresh is sufficient
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //      ref.invalidate(paginatedTopPlacesProvider); // Refresh top places data
        //   },
        //   tooltip: 'Refresh Top Places',
        //   child: const Icon(Icons.refresh),
        // ),
      ),
    );
  }
}
