// lib/features/cities/data/city_api_service.dart
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:travel_app/core/networking/dio_client.dart';
import 'package:travel_app/features/places/domain/city_suggestion_model.dart';
import 'package:travel_app/features/places/domain/place_suggestion_model.dart';

final cityRepositoryProvider = Provider<CityApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return CityApiService(dio);
});

class CityApiService {
  final Dio _dio;

  // Ideally, Dio is configured with baseUrl and interceptors (like for auth) elsewhere
  // and provided via Riverpod.
  CityApiService(this._dio);

  Future<List<CitySearchSuggestion>> searchCities(String query) async {
    if (query.isEmpty) {
      return []; // Don't hit API for empty query
    }
    try {
      // Replace with your actual base URL if not configured in Dio instance
      // final response = await _dio.get('http://localhost:8000/api/v1/cities/', queryParameters: {'q': query});
      final response = await _dio.get('/api/v1/cities/', queryParameters: {'q': query});


      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> results = response.data as List<dynamic>;
        return results
            .map((json) => CitySearchSuggestion.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        print('Error searching cities: ${response.statusCode} ${response.statusMessage}');
        throw Exception('Failed to load city suggestions');
      }
    } on DioException catch (e) {
      // Handle Dio-specific errors (network, timeout, etc.)
      print('DioError searching cities: ${e.message}');
      if (e.response != null) {
        print('DioError response: ${e.response?.data}');
      }
      throw Exception('Failed to load city suggestions (DioError)');
    } catch (e) {
      print('Unknown error searching cities: $e');
      throw Exception('Failed to load city suggestions (Unknown Error)');
    }
  }

  Future<List<PlaceSearchSuggestion>> searchPlaces(String query) async {
  if (query.isEmpty) return [];
  try {
    // Ensure this is your correct endpoint for searching places
    final response = await _dio.get('/api/v1/places/', queryParameters: {'q': query});
    // Your example response is a single object, but search APIs usually return a LIST.
    // Assuming your API actually returns a list of these objects:
    // e.g., `[ { "name": "Place A", ... }, { "name": "Place B", ... } ]`

    if (response.statusCode == 200 && response.data != null) {
      if (response.data is List) { // Check if data is a list
        final List<dynamic> results = response.data as List<dynamic>;
        return results
            .map((json) => PlaceSearchSuggestion.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (response.data is Map<String, dynamic>) {
        // If for some reason the API returns a single object directly (less common for search)
        // You might wrap it in a list or handle it as a special case.
        // For now, let's assume it's always a list for a search result.
        print("Warning: Place search API returned a single object, expected a list.");
        // return [PlaceSearchSuggestion.fromJson(response.data as Map<String, dynamic>)];
        return []; // Or handle appropriately
      } else {
        print("Warning: Place search API returned unexpected data format: ${response.data.runtimeType}");
        return [];
      }
    } else {
      throw Exception('Failed to load place suggestions (Status: ${response.statusCode})');
    }
  } catch (e) {
    print('Error searching places: $e');
    rethrow; // Or throw a more specific domain error
  }
}
}

// Riverpod provider for the service (optional, but good practice)
// Assuming you have a dioProvider for your configured Dio instance
// final dioProvider = Provider<Dio>((ref) {
//   final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8000'));
//   // Add interceptors for auth (like your Cookie) if needed globally
//   // dio.interceptors.add(InterceptorsWrapper(
//   //   onRequest: (options, handler) {
//   //     // TODO: Get your actual cookie value dynamically, e.g., from secure storage
//   //     const String jwtCookie = 'cflo_jwt_sign=YOUR_ACTUAL_COOKIE_VALUE_HERE';
//   //     options.headers['Cookie'] = jwtCookie;
//   //     options.headers['accept'] = 'application/json';
//   //     return handler.next(options);
//   //   },
//   // ));
//   return dio;
// });

// final cityApiServiceProvider = Provider<CityApiService>((ref) {
//   return CityApiService(ref.watch(dioProvider));
// });