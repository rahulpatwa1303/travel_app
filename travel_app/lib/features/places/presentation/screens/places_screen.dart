import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:travel_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:travel_app/features/places/domain/place_model.dart';
import 'package:travel_app/features/places/domain/top_place_model.dart';
import 'package:travel_app/features/places/presentation/controllers/places_controller.dart';
import 'package:travel_app/features/places/presentation/widget/carousel_view.dart';
import 'package:travel_app/widget/floating_heart_button.dart';

import '../providers/places_provider.dart'; // Ensure correct import

class PlacesScreen extends ConsumerWidget {
  const PlacesScreen({super.key});

  Widget _buildTopPlacesSkeleton(BuildContext context) {
    // Create dummy data for the skeleton structure
    final dummyPlaces = List.generate(
      3, // Show 3 skeleton cards
      (index) => TopPlace(
        id: index,
        name: 'Placeholder Name',
        latitude: 0.0,
        longitude: 0.0,
        tags: {"addr:city": "City"},
        // Add other required fields with dummy values if needed
      ),
    );
    return Skeletonizer(
      enabled: true, // Explicitly enabled
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 8,
            ), // Added vert padding
            child: Text(
              // Use Bone.text for specific text skeleton styling if needed
              'Recently Added',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          // Provide the CarouselViewWidget with dummy data for structure
          CarouselViewWidget(places: dummyPlaces),
        ],
      ),
    );
  }

  // --- Helper Function to Build Category Places Skeleton ---
  Widget _buildCategoryPlacesSkeleton(BuildContext context) {
    // Create dummy data
    final dummyPlaces = List.generate(
      5, // Show 5 skeleton items in the horizontal list
      (index) => Place(
        id: index,
        name: "Loading Place Name...",
        description: "This is a longer description loading...",
        imageURL: "",
      ),
    );

    return Skeletonizer(
      enabled: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // You can skeletonize the chips too if needed, but often not required
          // Skeletonizing the list is usually sufficient
          Padding(
            padding: const EdgeInsets.all(16),
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
                      Expanded(
                        child: Text(
                          place.description ?? '', // Will be skeletonized
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
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
    final params = PlacesParams(
      cityId: 1,
      category:
          selectedCategory ??
          'natural_wonder', // Default to 'natural_wonder' if null
      page: 1,
      size: 10,
    );

    // Watch the 'best-for-you' provider using the updated params
    final topPlacesAsync = ref.watch(topPlacesProvider);

     bool isLiked = false;

  void _updateLikedState(bool newLikedState) {
    // setState(() {
    //   isLiked = newLikedState;
    // });
  }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Places'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Top Places',
            onPressed: () {
              // Invalidate the topPlacesProvider to trigger a refetch
              ref.invalidate(topPlacesProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              // Invalidate providers before logging out
              ref.invalidate(topPlacesProvider);
              await ref.read(authControllerProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        // Add this to make the content scrollable
        child: Column(
          children: [
            // Top Places Section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: topPlacesAsync.when(
                data: (topPlacesList) {
                  if (topPlacesList.isEmpty) {
                    return const Text('No top places found.');
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Text(
                          'Recently Added',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      CarouselViewWidget(places: topPlacesList),
                    ],
                  );
                },
                loading: () => _buildTopPlacesSkeleton(context),
                error: (error, stackTrace) {
                  print("--- PlacesScreen Error (TopPlaces): $error ---");
                  print(stackTrace);
                  return Text('Error loading top places: $error');
                },
              ),
            ),

            // Categories Section with Chips
            categoryAsync.when(
              data: (categoryList) {
                // Set the initial category only once, outside of map
                if (ref.read(selectedCategoryProvider) == null &&
                    categoryList.isNotEmpty) {
                  Future.microtask(() {
                    ref.read(selectedCategoryProvider.notifier).state =
                        categoryList.first.osm_value;
                  });
                }
                if (categoryList.isEmpty) {
                  return const Text('No categories found.');
                }

                final selectedCategory = ref.watch(selectedCategoryProvider);
                final placesParams = PlacesParams(
                  cityId: 1,
                  category: selectedCategory ?? categoryList.first.osm_value,
                  page: 1,
                  size: 10,
                );

                final placesAsyncValue = ref.watch(
                  placesProvider(placesParams),
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Categories Header
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Category Chips Scroll
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children:
                            categoryList.map((category) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: ChoiceChip(
                                  label: Text(category.display_name),
                                  selected:
                                      selectedCategory == category.osm_value,
                                  onSelected: (selected) {
                                    ref
                                        .read(selectedCategoryProvider.notifier)
                                        .state = selected
                                            ? category.osm_value
                                            : null;

                                    // Trigger re-fetch for new category
                                    ref.invalidate(
                                      placesProvider(placesParams),
                                    );
                                  },
                                ),
                              );
                            }).toList(),
                      ),
                    ),

                    // Selected Category Info

                    // Fetched places list
                    placesAsyncValue.when(
                      data: (places) {
                        if (places.places.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('No places found for this category.'),
                          );
                        }

                        return SizedBox(
                          height: 180,
                          child: ListView.builder(
                            cacheExtent: 9999,
                            scrollDirection: Axis.horizontal,
                            itemCount: places.places.length,
                            itemBuilder: (context, index) {
                              final place = places.places[index];
                              final image =
                                  place.usesDefaultImage
                                      ? const AssetImage('assets/city.png')
                                      : NetworkImage(place.imageURL!)
                                          as ImageProvider;

                              return Container(
                                width: 160,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Stack(
                                  children: [
                                    // Background image
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        image: DecorationImage(
                                          image: image,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    // Dark overlay for readability
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.black.withOpacity(0.3),
                                            Colors.black.withOpacity(0.6),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Text content
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            place.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          Expanded(
                                            child: Text(
                                              place.description ??
                                                  'No description',
                                              maxLines: 4,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                      loading: () => _buildCategoryPlacesSkeleton(context),
                      error: (error, stack) {
                        print("--- Error fetching places: $error");
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text('Error: $error'),
                        );
                      },
                    ),
                  ],
                );
              },
              loading: () => _buildCategoryPlacesSkeleton(context),
              error: (error, stackTrace) {
                print("--- PlacesScreen Error (Categories): $error ---");
                return Text('Error loading categories: $error');
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.invalidate(topPlacesProvider); // Refresh top places data
        },
        tooltip: 'Refresh Top Places',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

// Define a StateProvider for selected category
final selectedCategoryProvider = StateProvider<String?>((ref) => null);
