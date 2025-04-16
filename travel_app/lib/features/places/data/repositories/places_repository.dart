import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/core/networking/dio_client.dart';
import 'package:travel_app/features/places/domain/place_model.dart';
import 'package:travel_app/features/places/domain/top_place_model.dart'; // Import your Place model

// Provider for the PlacesRepository
final placesRepositoryProvider = Provider<PlacesRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return PlacesRepository(dio);
});

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

  Future<List<TopPlace>> getTopPlaces() async {
    try {
      print("Fetching /places/top..."); // Debugging
      final response = await _dio.get('/places/top'); // Call the new endpoint

      if (response.statusCode == 200 && response.data != null) {
        // The response data is expected to be a List
        if (response.data is List) {
          print("Received list data from /places/top"); // Debugging
          final List<dynamic> dataList = response.data as List<dynamic>;
          // Parse each item in the list using the TopPlace.fromJson factory
          final List<TopPlace> places =
              dataList
                  .map((item) {
                    try {
                      // Ensure item is a map before parsing
                      if (item is Map<String, dynamic>) {
                        return TopPlace.fromJson(item);
                      } else {
                        print(
                          "Skipping invalid item in list: $item",
                        ); // Debugging
                        return null; // Or throw specific error
                      }
                    } catch (e) {
                      print(
                        "Error parsing item: $item, Error: $e",
                      ); // Debugging
                      return null; // Skip items that fail parsing
                    }
                  })
                  .whereType<
                    TopPlace
                  >() // Filter out any nulls from failed parsing
                  .toList();
          print(
            "Successfully parsed ${places.length} top places.",
          ); // Debugging
          return places;
        } else {
          // Handle cases where the response is not a list
          print(
            "Error: Expected a List but got ${response.data.runtimeType}",
          ); // Debugging
          throw Exception('Invalid response format: Expected a List.');
        }
      } else {
        print(
          "Error fetching /places/top: Status ${response.statusCode}",
        ); // Debugging
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: "Failed to fetch top places (${response.statusCode})",
        );
      }
    } on DioException catch (e) {
      print("DioException fetching /places/top: ${e.message}"); // Debugging
      // Interceptor handles 401, but rethrow for UI handling
      rethrow;
    } catch (e) {
      print("Unknown error fetching /places/top: $e"); // Debugging
      throw Exception("An unexpected error occurred fetching top places: $e");
    }
  }

  Future<List<PlacesCategories>> getCategories() async {
    try {
      print("Fetching /places/categories...");

      final response = await _dio.get('/places/categories');

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is List) {
          print("Received list data from /places/categories");

          final List<dynamic> dataList = response.data as List<dynamic>;

          final List<PlacesCategories> categories =
              dataList
                  .map((item) {
                    try {
                      if (item is Map<String, dynamic>) {
                        return PlacesCategories.fromJson(item);
                      } else {
                        print("Skipping invalid item in list: $item");
                        return null;
                      }
                    } catch (e) {
                      print("Error parsing item: $item, Error: $e");
                      return null;
                    }
                  })
                  .whereType<PlacesCategories>()
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
}
