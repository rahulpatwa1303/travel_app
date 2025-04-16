import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/core/constants/app_constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Provider for the storage instance
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    // Options for Android and iOS security levels if needed
    // aOptions: AndroidOptions(encryptedSharedPreferences: true),
    // iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
});

// Provider for the service itself
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return SecureStorageService(storage);
});

// Service class for abstraction
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  Future<void> saveToken(String token) async {
    await _storage.write(key: AppConstants.secureStorageTokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: AppConstants.secureStorageTokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: AppConstants.secureStorageTokenKey);
  }

  Future<void> deleteAll() async {
    await _storage.deleteAll(); // Useful for complete logout/reset
  }
}