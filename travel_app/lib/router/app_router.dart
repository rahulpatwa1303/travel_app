import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:travel_app/features/auth/presentation/screens/login_screen.dart';
import 'package:travel_app/features/places/presentation/screens/places_screen.dart'; // Import PlacesScreen

// Provider for the GoRouter instance
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  // Key to trigger rebuilds when auth state changes, useful for redirects
  final routerNotifier = ValueNotifier<AuthState>(authState);
  ref.listen<AuthState>(authControllerProvider, (previous, next) {
     print("Router Notifier updated: $next"); // Debugging
    routerNotifier.value = next;
  });


  return GoRouter(
    // Use the notifier to refresh the router state when auth changes
    refreshListenable: routerNotifier,

    // Initial location based on auth state (optional, redirect handles it)
    // initialLocation: authState == AuthState.authenticated ? '/' : '/login',

    debugLogDiagnostics: true, // Enable GoRouter logging

    // Define routes
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => LoginScreen(),
      ),
      GoRoute(
        path: '/', // Home route (protected)
        name: 'home',
        builder: (context, state) => const PlacesScreen(),
        // Add more protected routes here as needed
      ),
      // Example of another protected route
      // GoRoute(
      //   path: '/profile',
      //   name: 'profile',
      //   builder: (context, state) => const ProfileScreen(), // Create this screen
      // ),
    ],

    // Redirect logic
    redirect: (BuildContext context, GoRouterState state) {
      final currentState = ref.read(authControllerProvider); // Read current state
       print("Redirect Check: Current Auth State = $currentState, Target Location = ${state.uri}"); // Debugging

      final isLoggingIn = state.matchedLocation == '/login';

      // Handle loading state (optional, prevents flicker during initial check)
      if (currentState == AuthState.unknown) {
         print("Redirect: Auth state unknown, waiting..."); // Debugging
         // Show a loading screen or return null to wait
         // Returning null might cause issues if initial check is slow.
         // Consider a dedicated loading route or widget.
         return null; // Stay on current route while checking
      }

      // If user is not authenticated:
      if (currentState != AuthState.authenticated) {
         print("Redirect: Not authenticated."); // Debugging
        // If they are not on the login page, redirect them there.
        return isLoggingIn ? null : '/login';
      }

      // If user IS authenticated:
      if (isLoggingIn) {
         print("Redirect: Authenticated but on login page, redirecting to home."); // Debugging
        // If they are authenticated and somehow landed on login, redirect home.
        return '/';
      }

      // No redirect needed
       print("Redirect: No redirect needed."); // Debugging
      return null;
    },
  );
});