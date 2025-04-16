import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/core/storage/secure_storage_service.dart';
import 'package:travel_app/features/auth/presentation/controllers/auth_controller.dart'; // We'll create this soon

class AuthInterceptor extends Interceptor {
  final SecureStorageService _storageService;
  final Ref _ref; // Riverpod Ref to read other providers if needed

  AuthInterceptor(this._storageService, this._ref);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Check if the request requires authentication (you might add flags/metadata later)
    // For now, assume most requests except login need it.
    if (!options.path.contains('/auth/')) { // Example: exclude auth paths
      final token = await _storageService.getToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
        print("--- Token Added to Header ---"); // For debugging
      } else {
         print("--- No Token Found for Request ---"); // For debugging
      }
    }
    // Add other common headers
    options.headers['Accept'] = 'application/json';
    print("--- Request: ${options.method} ${options.uri} ---"); // For debugging
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
     print("--- Error: ${err.requestOptions.uri} -> ${err.response?.statusCode} ---"); // For debugging
    if (err.response?.statusCode == 401) {
      print("--- Unauthorized (401) detected ---");
      // Token expired or invalid
      await _storageService.deleteToken();

      // Notify the auth controller to update state and trigger redirect
      // Use read to avoid listening loop, trigger state change
      _ref.read(authControllerProvider.notifier).logout();

      // Optionally: You could try to refresh the token here if your backend supports it.
      // If refresh succeeds, retry the original request.
      // If refresh fails or isn't implemented, reject the error.

      // Reject the error to prevent Dio from throwing it further *up*
      // The UI/Router should react based on the auth state change.
      // return handler.reject(err); // Let the caller handle it based on state? Maybe not ideal.
      // It might be better to just let the state change handle navigation.
      // We can pass a custom error or let the original 401 propagate
      // But since logout() changes state, the router should handle it.
       return handler.reject(DioException(
          requestOptions: err.requestOptions,
          error: "Token expired or invalid. Logged out.",
          response: err.response,
          type: err.type,
      ));
    }
    super.onError(err, handler);
  }

   @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
     print("--- Response: ${response.requestOptions.uri} -> ${response.statusCode} ---"); // For debugging
     super.onResponse(response, handler);
  }
}