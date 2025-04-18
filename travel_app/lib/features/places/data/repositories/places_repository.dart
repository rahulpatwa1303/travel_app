import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/core/networking/dio_client.dart';
import 'package:travel_app/features/places/domain/city_detail_model.dart';
import 'package:travel_app/features/places/domain/place_by_city_model.dart';
import 'package:travel_app/features/places/domain/place_model.dart';
import 'package:travel_app/features/places/domain/top_place_model.dart'; // Import your Place model

// Provider for the PlacesRepository
final placesRepositoryProvider = Provider<PlacesRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return PlacesRepository(dio);
});

class TopPlacesPaginatedResponse {
  final List<TopPlace> places;
  final bool hasMore; // Calculated based on list length vs limit

  TopPlacesPaginatedResponse({required this.places, required this.hasMore});
}

class PlacesRepository {
  final Dio _dio;

  PlacesRepository(this._dio);

  Future<PlacesResponse> getBestPlaces({
    required int cityId,
    required String category,
    required String interests,
    required int page,
    required int size,
  }) async {
    try {
      final response = await _dio.get(
        '/places/best-for-you/$cityId', // API endpoint structure
        queryParameters: {
          'category': category,
          'interests': interests,
          'page': page,
          'size': size,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        // Assuming the entire response body is the structure PlacesResponse expects
        // or that it's nested e.g., response.data['data']
        print(
          "--- Places API Response Data: ${response.data} ---",
        ); // Debugging
        return PlacesResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: "Failed to fetch places (${response.statusCode})",
        );
      }
    } on DioException catch (e) {
      print("--- Get Places DioException: ${e.message} ---"); // Debugging
      if (e.response?.statusCode == 401) {
        // The interceptor should handle this, but good to log here too
        print("Unauthorized access to places endpoint.");
      }
      rethrow; // Let the caller handle the error UI
    } catch (e) {
      print("--- Get Places Unknown Error: $e ---"); // Debugging
      throw Exception("An unexpected error occurred fetching places: $e");
    }
  }

  Future<TopPlacesPaginatedResponse> getTopPlaces({
    required int offset,
    required int limit,
  }) async {
    try {
      print(
        "Fetching /api/v1/cities/popular with offset: $offset, limit: $limit",
      );
      final response = await _dio.get(
        '/api/v1/cities/popular', // Use the correct endpoint
        queryParameters: {'offset': offset, 'limit': limit},
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is List) {
          print("Received list data from /api/v1/cities/popular");
          final List<dynamic> dataList = response.data as List<dynamic>;
          final List<TopPlace> places =
              dataList
                  .map((item) {
                    try {
                      if (item is Map<String, dynamic>) {
                        return TopPlace.fromJson(item);
                      } else {
                        print("Skipping invalid item in list: $item");
                        return null;
                      }
                    } catch (e) {
                      print("Error parsing item: $item, Error: $e");
                      return null;
                    }
                  })
                  .whereType<TopPlace>()
                  .toList();

          print("Successfully parsed ${places.length} top places.");

          // --- Infer hasMore (Option B) ---
          final bool hasMore = places.length == limit;
          print(
            "Calculated hasMore: $hasMore (list size: ${places.length}, limit: $limit)",
          );
          // --- End Infer hasMore ---

          return TopPlacesPaginatedResponse(places: places, hasMore: hasMore);
        } else {
          print("Error: Expected a List but got ${response.data.runtimeType}");
          throw Exception('Invalid response format: Expected a List.');
        }
      } else {
        print(
          "Error fetching /api/v1/cities/popular: Status ${response.statusCode}",
        );
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: "Failed to fetch top places (${response.statusCode})",
        );
        ;
      }
    } on DioException catch (e) {
      print("DioException fetching /api/v1/cities/popular: ${e.message}");
      rethrow;
    } catch (e) {
      print("Unknown error fetching /api/v1/cities/popular: $e");
      throw Exception("An unexpected error occurred fetching top places: $e");
    }
  }

  // --- NEW: Fetch Favorite Place IDs ---
  Future<Set<int>> getFavoritePlaceIds() async {
    try {
      print("Fetching favorite place IDs: /api/v1/users/me/favorites/ids");
      final response = await _dio.get('/api/v1/users/me/favorites/ids');

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is List) {
          // Assuming the API returns a list of integers
          final List<dynamic> idList = response.data as List<dynamic>;
          final Set<int> favoriteIds = idList.whereType<int>().toSet();
          print("Received ${favoriteIds.length} favorite IDs.");
          return favoriteIds;
        } else {
          print(
            "Error: Expected a List of favorite IDs but got ${response.data.runtimeType}",
          );
          throw Exception(
            'Invalid response format for favorite IDs: Expected a List.',
          );
        }
      } else {
        print("Error fetching favorite IDs: Status ${response.statusCode}");
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: "Failed to fetch favorite IDs (${response.statusCode})",
        );
      }
    } on DioException catch (e) {
      print("DioException fetching favorite IDs: ${e.message}");
      // Handle specific errors like 401 if needed, though interceptor might handle it
      rethrow;
    } catch (e) {
      print("Unknown error fetching favorite IDs: $e");
      throw Exception("An unexpected error occurred fetching favorite IDs: $e");
    }
  }
  // --- End Fetch Favorite Place IDs ---

  // --- NEW: Like a Place ---
  Future<void> likePlace(int placeId) async {
    try {
      print("Liking place: POST /api/v1/users/me/favorites/$placeId");
      final response = await _dio.post('/api/v1/users/me/favorites/$placeId');

      // Check for success status code (e.g., 200, 201, 204 No Content)
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        print("Successfully liked place $placeId");
        // No specific data needed from response based on curl example
        return;
      } else {
        print("Error liking place $placeId: Status ${response.statusCode}");
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: "Failed to like place $placeId (${response.statusCode})",
        );
      }
    } on DioException catch (e) {
      print("DioException liking place $placeId: ${e.message}");
      rethrow; // Let the notifier handle UI feedback
    } catch (e) {
      print("Unknown error liking place $placeId: $e");
      throw Exception("An unexpected error occurred liking place $placeId: $e");
    }
  }
  // --- End Like a Place ---

  // --- NEW: Dislike a Place ---
  Future<void> dislikePlace(int placeId) async {
    try {
      print("Disliking place: DELETE /api/v1/users/me/favorites/$placeId");
      final response = await _dio.delete('/api/v1/users/me/favorites/$placeId');

      // Check for success status code (e.g., 200 OK, 204 No Content)
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        print("Successfully disliked place $placeId");
        // No specific data needed from response based on curl example
        return;
      } else {
        print("Error disliking place $placeId: Status ${response.statusCode}");
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: "Failed to dislike place $placeId (${response.statusCode})",
        );
      }
    } on DioException catch (e) {
      print("DioException disliking place $placeId: ${e.message}");
      rethrow; // Let the notifier handle UI feedback
    } catch (e) {
      print("Unknown error disliking place $placeId: $e");
      throw Exception(
        "An unexpected error occurred disliking place $placeId: $e",
      );
    }
  }
  // --- End Dislike a Place ---

  Future<List<PlacesCategory>> getCategories() async {
    try {
      print("Fetching /places/categories...");

      final response = await _dio.get('/api/v1/places/categories');

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is List) {
          print("Received list data from /places/categories");

          final List<dynamic> dataList = response.data as List<dynamic>;

          final List<PlacesCategory> categories =
              dataList
                  .map((item) {
                    try {
                      if (item is String) {
                        return PlacesCategory.fromJson(item);
                      } else {
                        print("Skipping invalid item in list: $item");
                        return null;
                      }
                    } catch (e) {
                      print("Error parsing item: $item, Error: $e");
                      return null;
                    }
                  })
                  .whereType<PlacesCategory>()
                  .toList();

          print("Successfully parsed ${categories.length} categories.");
          return categories;
        } else {
          print("Error: Expected a List but got ${response.data.runtimeType}");
          throw Exception('Invalid response format: Expected a List.');
        }
      } else {
        print(
          "Error fetching /places/categories: Status ${response.statusCode}",
        );
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: "Failed to fetch categories (${response.statusCode})",
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      print("DioException fetching /places/categories: ${e.message}");
      rethrow;
    } catch (e) {
      print("Unknown error fetching /places/categories: $e");
      throw Exception("An unexpected error occurred fetching categories: $e");
    }
  }

  Future<CityDetail> getCityDetails(int cityId) async {
    // Return TopPlace for now
    try {
      print("Fetching city details: GET /api/v1/cities/$cityId");
      final response = await _dio.get('/api/v1/cities/$cityId');

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          print("Received city details for ID $cityId");
          // Use TopPlace.fromJson - ensure it can handle the details response structure
          // You might need to adjust TopPlace.fromJson or create a CityDetail model
          // For example, TopPlace might expect 'imageUrl' but details has 'images' list
          try {
            // Create a temporary map to potentially adjust fields before parsing
            Map<String, dynamic> jsonData = Map<String, dynamic>.from(
              response.data,
            );

            // --- Handle potential model mismatch ---
            // Example: If TopPlace expects 'imageUrl' but API gives 'images' list
            if (jsonData.containsKey('images') &&
                jsonData['images'] is List &&
                (jsonData['images'] as List).isNotEmpty) {
              // Try to take the first image URL if the list is not empty
              // You might need more sophisticated logic here
              var firstImage = (jsonData['images'] as List).first;
              if (firstImage is Map && firstImage.containsKey('url')) {
                jsonData['imageUrl'] =
                    firstImage['url']; // Add the expected field
              } else if (firstImage is String) {
                // Simple list of strings?
                jsonData['imageUrl'] = firstImage;
              }
            }
            // Remove the original 'images' if 'imageUrl' is preferred by TopPlace model
            // jsonData.remove('images');

            // Example: If TopPlace expects 'usesDefaultImage' but API doesn't provide it
            jsonData['usesDefaultImage'] =
                jsonData['imageUrl'] == null ||
                (jsonData['imageUrl'] as String).isEmpty;
            // --- End Handle model mismatch ---

            return CityDetail.fromJson(
              jsonData,
            ); // Parse the potentially adjusted data
          } catch (e) {
            print("Error parsing city details JSON for ID $cityId: $e");
            print("Original JSON: ${response.data}");
            throw Exception("Failed to parse city details response.");
          }
        } else {
          print(
            "Error: Expected a Map for city details but got ${response.data.runtimeType}",
          );
          throw Exception('Invalid response format for city details.');
        }
      } else {
        print(
          "Error fetching city details $cityId: Status ${response.statusCode}",
        );
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: "Failed to fetch categories (${response.statusCode})",
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      print("DioException fetching city details $cityId: ${e.message}");
      rethrow;
    } catch (e) {
      print("Unknown error fetching city details $cityId: $e");
      throw Exception(
        "An unexpected error occurred fetching city details $cityId: $e",
      );
    }
  }

  Future<List<PlaceByCity>> getPlacesInCity(
    // <-- Update return type
    int cityId, {
    int limit = 50,
    String sortBy = 'name_desc', // Default sort
  }) async {
    try {
      print("Fetching places in city: GET /api/v1/places/ for city_id=$cityId");
      final response = await _dio.get(
        '/api/v1/places/', // Endpoint for the list of places
        queryParameters: {'city_id': cityId, 'sort_by': sortBy, 'limit': limit},
      );

      if (response.statusCode == 200 && response.data != null) {
        // --- Adjust based on actual API response structure ---

        // Helper function for parsing to avoid repetition
        PlaceByCity? parseItem(dynamic item) {
          try {
            if (item is Map<String, dynamic>) {
              return PlaceByCity.fromJson(item); // Use PlaceByCity.fromJson
            }
            print(
              "Skipping invalid place item type: ${item?.runtimeType ?? 'null'}",
            );
            return null;
          } catch (e) {
            print("Error parsing place item: $item, Error: $e");
            return null;
          }
        }

        // Scenario A: Response data IS the list
        if (response.data is List) {
          print("Received list of places for city $cityId.");
          final List<dynamic> dataList = response.data as List<dynamic>;
          // Use PlaceByCity in map and whereType
          final List<PlaceByCity> places =
              dataList
                  .map(parseItem) // Use helper function
                  .whereType<
                    PlaceByCity
                  >() // Filter out nulls AND ensure correct type
                  .toList();
          print("Parsed ${places.length} places (Scenario A).");
          return places; // Return List<PlaceByCity>
        }
        // Scenario B: Response data is a Map containing the list (e.g., under a 'results' key)
        else if (response.data is Map<String, dynamic> &&
            response.data['results'] is List) {
          // Adjust 'results' key if needed
          print("Received map containing list of places for city $cityId.");
          final List<dynamic> dataList =
              response.data['results'] as List<dynamic>;
          // Use PlaceByCity in map and whereType
          final List<PlaceByCity> places =
              dataList
                  .map(parseItem) // Use helper function
                  .whereType<
                    PlaceByCity
                  >() // Filter out nulls AND ensure correct type
                  .toList();
          print("Parsed ${places.length} places (Scenario B).");
          return places; // Return List<PlaceByCity>
        }
        // --- End Adjustment ---
        else {
          print(
            "Error: Expected a List (or Map with 'results' list) for places but got ${response.data.runtimeType}",
          );
          throw Exception('Invalid response format for places in city.');
        }
      } else {
        print(
          "Error fetching places for city $cityId: Status ${response.statusCode}",
        );
        // Use the existing DioException or create a new one
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error:
              "Failed to fetch places for city $cityId (${response.statusCode})",
          // Consider adding type if known, e.g., DioExceptionType.badResponse
        );
      }
    } on DioException catch (e) {
      print("DioException fetching places for city $cityId: ${e.message}");
      rethrow;
    } catch (e) {
      print("Unknown error fetching places for city $cityId: $e");
      throw Exception(
        "An unexpected error occurred fetching places for city $cityId: $e",
      );
    }
  }
}
