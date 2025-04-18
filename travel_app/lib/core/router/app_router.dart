// lib/core/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:travel_app/features/places/presentation/screens/city_details_screen.dart';

// Import your screens
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/places/presentation/screens/places_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import 'shell_scaffold.dart';

class AppRoutePaths {
  static const String login = '/login';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String cityDetails = '/place/:placeId';
}

// REMOVE the top-level key definitions:
// final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root'); // <-- REMOVE
// final _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell'); // <-- REMOVE

final routerProvider = Provider<GoRouter>((ref) {
  // DEFINE the keys INSIDE the provider's build scope:
  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  final shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey, // Use the key defined above
    initialLocation: AppRoutePaths.home,
    debugLogDiagnostics: true,

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

    routes: [
      // Login Route (Outside the Shell)
      GoRoute(
        path: AppRoutePaths.login,
        name: 'login',
        parentNavigatorKey: rootNavigatorKey, // Use the key defined above
        builder: (context, state) => LoginScreen(),
      ),
      GoRoute(
        path: AppRoutePaths.cityDetails, // e.g., '/place/:placeId'
        name: 'city_details',
        parentNavigatorKey: rootNavigatorKey, // IMPORTANT: Use ROOT key
        builder: (context, state) {
          // Extract the placeId from the path parameters
          final placeId = state.pathParameters['placeId'];
          if (placeId == null) {
            // Handle error: ID is missing, maybe redirect or show error page
            return Scaffold(
              body: Center(child: Text("Error: Missing Place ID")),
            );
          }
          return CityDetailsScreen(placeId: placeId);
        },
      ),
      // ShellRoute for authenticated routes with Bottom Nav Bar
      ShellRoute(
        navigatorKey: shellNavigatorKey, // Use the key defined above
        builder: (context, state, child) {
          return ShellScaffold(child: child);
        },
        // Define the routes managed by this ShellRoute
        routes: [
          GoRoute(
            path: AppRoutePaths.home,
            name: 'home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PlacesScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutePaths.profile,
            name: 'profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
          // Add more routes/tabs here later
        ],
      ),
    ],
     errorBuilder: (context, state) {
       print("GoRouter Error: ${state.error}");
       return Scaffold(body: Center(child: Text("Oops! Page not found.\n${state.error}")));
     }
  );
});