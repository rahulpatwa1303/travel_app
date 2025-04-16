import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/core/storage/secure_storage_service.dart';
import 'package:travel_app/features/auth/data/repositories/auth_repository.dart';

// Represents the possible authentication states
enum AuthState { unknown, authenticated, unauthenticated }

// State Notifier for authentication state
class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final SecureStorageService _secureStorageService;

  AuthController(this._authRepository, this._secureStorageService)
      : super(AuthState.unknown) {
    _checkInitialAuthStatus();
  }

  // Check storage on startup
  Future<void> _checkInitialAuthStatus() async {
    final token = await _secureStorageService.getToken();
    if (token != null) {
      // Optional: Validate token by making a simple authenticated API call
      // try {
      //   await _authRepository.getCurrentUser(); // Example validation
           state = AuthState.authenticated;
      // } catch (e) {
      //   // Token likely invalid/expired
      //   await _secureStorageService.deleteToken();
      //   state = AuthState.unauthenticated;
      // }
    } else {
      state = AuthState.unauthenticated;
    }
     print("Initial Auth State Checked: $state"); // Debugging
  }

  // Login method
  Future<bool> login(String email, String password) async {
    try {
      final token = await _authRepository.login(email, password);
      if (token != null) {
        await _secureStorageService.saveToken(token);
        state = AuthState.authenticated;
        print("Login Successful, State: $state"); // Debugging
        return true;
      }
      // Handle case where login API doesn't return a token properly
      state = AuthState.unauthenticated;
      print("Login Failed (No Token), State: $state"); // Debugging
      return false;
    } catch (e) {
      print("Login Error: $e"); // Debugging
      // Ensure state remains unauthenticated on error
      state = AuthState.unauthenticated;
      // Consider logging the error or showing a user-friendly message
      return false;
    }
  }

  // Logout method
  Future<void> logout() async {
    await _authRepository.logout(); // Repository handles token deletion via service
    state = AuthState.unauthenticated;
     print("Logout Successful, State: $state"); // Debugging
    // IMPORTANT: Invalidate user-specific data providers here if needed
    // Example: ref.invalidate(userProfileProvider);
    // Example: ref.invalidate(placesProvider); // If places depend on user
  }
}

// Provider for the AuthController
final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final storageService = ref.watch(secureStorageServiceProvider);
  return AuthController(authRepository, storageService);
});