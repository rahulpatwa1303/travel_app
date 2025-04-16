
// lib/core/router/shell_scaffold.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_app/core/router/app_router.dart';
// import '../../features/auth/presentation/providers/auth_provider.dart';

class ShellScaffold extends ConsumerWidget {
  final Widget child;

  const ShellScaffold({
    required this.child,
    super.key,
  });

  // Helper method to determine the selected index based on the current route
  int _calculateSelectedIndex(BuildContext context) {
    // Access the current route location using GoRouterState
    final String location = GoRouterState.of(context).matchedLocation;
    if (location == AppRoutePaths.home) {
      return 0;
    }
    if (location == AppRoutePaths.profile) {
      return 1;
    }
    // Add checks for future tabs here
    // if (location == '/settings') {
    //   return 2;
    // }
    return 0; // Default to home index if no match found
  }

  // Helper method to handle navigation when a tab is tapped
  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(AppRoutePaths.home);
        break;
      case 1:
        context.go(AppRoutePaths.profile);
        break;
      // Add cases for future tabs here
      // case 2:
      //   context.go('/settings');
      //   break;
    }
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      // AppBar can be here if global, or within each child screen
      // appBar: AppBar(title: Text('App Title')),
      body: child, // The active screen content provided by ShellRoute
      
      bottomNavigationBar: ClipRRect(
            borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
        child: BottomNavigationBar(
          
          currentIndex: _calculateSelectedIndex(context),
          onTap: (index) => _onItemTapped(index, context),
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
            // Add more items for future tabs here
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.settings_outlined),
            //   activeIcon: Icon(Icons.settings),
            //   label: 'Settings',
            // ),
          ],
          // Optional: Customize appearance
          // type: BottomNavigationBarType.fixed, // Or .shifting
          // selectedItemColor: Colors.amber[800],
          // unselectedItemColor: Colors.grey,
        ),
      ),
    );
  }
}