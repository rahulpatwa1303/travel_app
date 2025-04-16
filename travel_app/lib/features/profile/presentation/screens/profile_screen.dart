// lib/features/profile/presentation/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Import auth provider if you need to display user info or logout
// import '../../../../features/auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // You can watch user data providers here later
    // final userAsync = ref.watch(userDataProvider); // Example

    return Scaffold( // Add Scaffold if AppBar is screen-specific
       appBar: AppBar(
         title: const Text('Profile'),
         // Example Logout Action (can also be in ShellScaffold's AppBar if global)
         // actions: [
         //   IconButton(
         //     icon: const Icon(Icons.logout),
         //     tooltip: 'Logout',
         //     onPressed: () async {
         //       // Invalidate providers if needed
         //       await ref.read(authNotifierProvider.notifier).logout();
         //       // GoRouter redirect will handle navigation
         //     },
         //   ),
         // ],
       ),
       body: const Center(
        child: Text(
          'Profile Screen Content',
          style: TextStyle(fontSize: 20),
        ),
        // TODO: Add user details, settings, logout button etc.
      ),
    );
  }
}