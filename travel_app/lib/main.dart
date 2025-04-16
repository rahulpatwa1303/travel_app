import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/core/router/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Needed for plugins like secure_storage
  // Optional: Setup logging, error reporting, etc. here
  runApp(
    // Wrap the entire app in ProviderScope for Riverpod
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the router instance from the provider
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Multi User App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Use routerConfig for GoRouter 7.0+
      routerConfig: router,
    );
  }
}