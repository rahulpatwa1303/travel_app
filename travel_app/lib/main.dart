// main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/core/constants/colors.dart';
import 'package:travel_app/core/router/app_router.dart';
// Import your AuthController and LikedCitiesNotifier providers
import 'package:travel_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:travel_app/features/places/presentation/providers/liked_cities_notifier.dart'; // Adjust path

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(child: AppRoot()), // Use AppRoot here
  );
}

class AppRoot extends ConsumerStatefulWidget {
  const AppRoot({super.key});

  @override
  ConsumerState<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends ConsumerState<AppRoot> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initial fetch for likedCitiesProvider is handled by its build method
    // when authControllerProvider reports authenticated.
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    super.didChangeAppLifecycleState(lifecycleState);
    if (lifecycleState == AppLifecycleState.resumed) {
      print("App resumed.");
      // Check current authentication state
      final authState = ref.read(authControllerProvider);
      if (authState == AuthState.authenticated) {
        print("User is authenticated. Refreshing liked cities on app resume.");
        ref.read(likedCitiesProvider.notifier).refresh();
      } else {
        print("User not authenticated on app resume. No refresh needed for liked cities.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // The MyApp widget is now a child, responsible for MaterialApp.router
    return const MyApp();
  }
}

// Your existing MyApp widget
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    // The likedCitiesProvider will be initialized/built when:
    // 1. It's first watched by a widget.
    // 2. Its notifier is read (`ref.read(likedCitiesProvider.notifier)`).
    // 3. The providers it watches (authControllerProvider) change.
    // No explicit watch here is strictly necessary unless you want to ensure it's
    // "awake" immediately, but its dependency on authControllerProvider handles most cases.

    return MaterialApp.router(
      title: 'Multi User App',
      theme: ThemeData(
        colorScheme: lightColorScheme,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: darkColorScheme,
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}