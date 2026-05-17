import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';
import 'services/local_storage_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/add_pet_screen.dart';
import 'screens/pet_details_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/change_password_screen.dart';
import 'screens/my_pets_screen.dart';
import 'screens/my_orders_screen.dart';
import 'screens/my_sales_screen.dart';
import 'screens/chats_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/owner_pets_screen.dart';

class AppRouter {
  final AuthProvider authProvider;
  final LocalStorageService _storage;

  AppRouter(this.authProvider, this._storage);

  late final GoRouter router = GoRouter(
    initialLocation: '/login',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final isAuthenticated = authProvider.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';

      final userId = authProvider.currentUser?.id ?? _storage.getCurrentUserId() ?? '';
      final welcomeDone =
          userId.isNotEmpty && _storage.hasCompletedWelcomeTour(userId);

      // If not authenticated and not on login/signup, redirect to login
      if (!isAuthenticated && !isLoggingIn) {
        return '/login';
      }

      // Returning user: dashboard. New user this account: welcome.
      if (isAuthenticated && isLoggingIn) {
        return welcomeDone ? '/dashboard' : '/welcome';
      }

      // First session for this user — keep them on Get Started until completed
      if (isAuthenticated &&
          !welcomeDone &&
          state.matchedLocation != '/welcome') {
        return '/welcome';
      }

      if (isAuthenticated &&
          welcomeDone &&
          state.matchedLocation == '/welcome') {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/add-pet',
        builder: (context, state) => const AddPetScreen(),
      ),
      GoRoute(
        path: '/pet/:id',
        builder: (context, state) {
          final petId = state.pathParameters['id']!;
          return PetDetailsScreen(petId: petId);
        },
      ),
      GoRoute(
        path: '/categories',
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(
        path: '/category/:name',
        builder: (context, state) {
          final categoryName = state.pathParameters['name']!;
          return CategoryPetsScreen(categoryName: categoryName);
        },
      ),
      GoRoute(
        path: '/chat/:petId',
        builder: (context, state) {
          final petId = state.pathParameters['petId']!;
          return ChatScreen(petId: petId);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/my-pets',
        builder: (context, state) => const MyPetsScreen(),
      ),
      GoRoute(
        path: '/favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: '/owner/:ownerId',
        builder: (context, state) {
          final ownerId = state.pathParameters['ownerId']!;
          final ownerName = state.uri.queryParameters['name'];
          final ownerContact = state.uri.queryParameters['contact'];
          return OwnerPetsScreen(
            ownerId: ownerId,
            ownerName: ownerName,
            ownerContact: ownerContact,
          );
        },
      ),
      GoRoute(
        path: '/my-orders',
        builder: (context, state) => const MyOrdersScreen(),
      ),
      GoRoute(
        path: '/my-sales',
        builder: (context, state) => const MySalesScreen(),
      ),
      GoRoute(
        path: '/chats',
        builder: (context, state) => const ChatsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Page not found',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    ),
  );
}
