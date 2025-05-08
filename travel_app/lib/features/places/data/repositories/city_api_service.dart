// lib/features/cities/data/city_api_service.dart
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:travel_app/core/networking/dio_client.dart';
import 'package:travel_app/features/places/domain/city_suggestion_model.dart';

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