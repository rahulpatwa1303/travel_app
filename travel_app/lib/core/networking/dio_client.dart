import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/core/constants/app_constants.dart';
import 'package:travel_app/core/networking/auth_interceptor.dart';
import 'package:travel_app/core/storage/secure_storage_service.dart';

// Provider for the Dio instance
final dioProvider = Provider<Dio>((ref) {
  final baseOptions = BaseOptions(
    baseUrl: AppConstants.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    // Default headers can be set here, but Accept might be better in interceptor
  );

  final dio = Dio(baseOptions);

  // Add the Auth Interceptor
  final storageService = ref.watch(secureStorageServiceProvider);
  dio.interceptors.add(AuthInterceptor(storageService, ref));

  // Add Logging Interceptor for development
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
    requestHeader: true,
    responseHeader: false,
    error: true,
    logPrint: (obj) => print(obj.toString()), // Or use a logger package
  ));

  return dio;
});