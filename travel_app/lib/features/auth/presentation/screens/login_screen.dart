import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/features/auth/presentation/controllers/auth_controller.dart';

// Simple provider to manage loading state specifically for the login button
final loginLoadingProvider = StateProvider<bool>((ref) => false);

class LoginScreen extends ConsumerWidget {
  LoginScreen({super.key});

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(loginLoadingProvider);

    // Listen to auth state changes for navigation (handled by router, but good for feedback)
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next == AuthState.authenticated) {
        // Navigation is handled by the router's redirect logic
        print("LoginScreen detected authenticated state.");
      }
      if (previous == AuthState.unknown && next == AuthState.unauthenticated) {
         // Just finished initial check, ready to login
          print("LoginScreen detected initial unauthenticated state.");
      }
    });


    // --- Placeholder for testing ---
    // TODO: Remove these default values in production
    _emailController.text = 'traveler@example.com'; // Replace with actual test user
    _passwordController.text = 'mysecretpassword!#'; // Replace with actual test password
    // --- End Placeholder ---

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty || !value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                   validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            ref.read(loginLoadingProvider.notifier).state = true;
                            final success = await ref
                                .read(authControllerProvider.notifier)
                                .login(
                                  _emailController.text.trim(),
                                  _passwordController.text.trim(),
                                );
                             ref.read(loginLoadingProvider.notifier).state = false;

                             if (!success && context.mounted) {
                               ScaffoldMessenger.of(context).showSnackBar(
                                 const SnackBar(content: Text('Login Failed. Please check credentials.')),
                               );
                             }
                             // Navigation happens via router listening to authControllerProvider
                          }
                        },
                        child: const Text('Login'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}