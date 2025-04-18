import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/core/networking/dio_client.dart';
import 'package:travel_app/core/storage/secure_storage_service.dart';
// Import user model if needed for getCurrentUser
// import 'package:multi_user_app/models/user_model.dart';

// Provider for the AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final storageService = ref.watch(secureStorageServiceProvider);
  return AuthRepository(dio, storageService);
});

class AuthRepository {
  final Dio _dio;
  final SecureStorageService _storageService;

  AuthRepository(this._dio, this._storageService);

  // --- LOGIN ---
  // IMPORTANT: Adapt this to your *actual* login endpoint and response format.
  // The curl example provided (`/auth/users/me`) is NOT a login endpoint.
  // Assuming a hypothetical endpoint '/auth/login' that takes email/password
  // and returns a JSON like {"access_token": "your_jwt_token"}
  Future<String?> login(String email, String password) async {
    try {
      // !!! Replace with your actual login endpoint and request body !!!
      final response = await _dio.post(
        '/api/v1/auth/login', // Example login endpoint
        data: FormData.fromMap({ // Backend expects form data based on common FastAPI auth
          'username': email,
          'password': password,
        }),
        options: Options(
           contentType: Headers.formUrlEncodedContentType, // Important for FastAPI OAuth2PasswordRequestForm
        )
      );

      if (response.statusCode == 200 && response.data != null) {
        // Adjust key based on your backend's response structure
        final token = response.data['access_token'] as String?;
        if (token != null && token.isNotEmpty) {
          print("--- Token received from backend: $token ---"); // Debugging
          return token;
        } else {
           print("--- Login successful but no 'access_token' found in response ---"); // Debugging
           throw Exception("Login successful but token not found in response.");
        }
      } else {
         print("--- Login failed with status: ${response.statusCode} ---"); // Debugging
         // Optionally parse error message from response.data['detail']
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: "Login failed with status code ${response.statusCode}",
        );
      }
    } on DioException catch (e) {
       print("--- Login DioException: ${e.message} ---"); // Debugging
       // Log specific Dio error details
       if (e.response != null) {
         print("Response data: ${e.response?.data}");
         print("Response headers: ${e.response?.headers}");
       } else {
         print("Error sending request: ${e.message}");
       }
       // Re-throw or handle specific errors (e.g., 401 invalid credentials)
      rethrow; // Let the controller handle it
    } catch (e) {
       print("--- Unknown Login Error: $e ---"); // Debugging
      // Handle other potential errors (network issues, parsing errors)
      throw Exception("An unexpected error occurred during login: $e");
    }
  }

  // --- GET CURRENT USER (Example using the provided /users/me) ---
  // You might call this after login or on app start to validate the token
  Future<void> getCurrentUser() async {
    // This requires the token to be set by the interceptor
    try {
      final response = await _dio.get('/auth/users/me');
      if (response.statusCode == 200 && response.data != null) {
        // TODO: Parse the user data into a UserModel
        // return UserModel.fromJson(response.data);
        print("--- Successfully fetched user data ---"); // Debugging
        return; // Return void or UserModel
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: "Failed to fetch user data (${response.statusCode})",
        );
      }
    } on DioException catch (e) {
       print("--- Get User DioException: ${e.message} ---"); // Debugging
       // Specific handling if needed, otherwise rethrow
       rethrow;
    } catch (e) {
       print("--- Get User Unknown Error: $e ---"); // Debugging
       throw Exception("An unexpected error occurred fetching user data: $e");
    }
  }


  // --- LOGOUT ---
  Future<void> logout() async {
    // Perform local cleanup
    await _storageService.deleteToken();
    print("--- Token deleted locally ---"); // Debugging

    // Optional: Call a backend logout endpoint if it exists
    // try {
    //   await _dio.post('/auth/logout'); // Example
    // } catch (e) {
    //   // Log error but proceed with local logout
    //   print("Failed to call backend logout endpoint: $e");
    // }
  }
}