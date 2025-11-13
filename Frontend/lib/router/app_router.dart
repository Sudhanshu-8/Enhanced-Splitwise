import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/controllers/auth_controller.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/expenses/presentation/add_expense_screen.dart';
import '../features/home/presentation/home_shell.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/settlements/presentation/settlements_screen.dart';
import '../features/splash/presentation/splash_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    debugLogDiagnostics: true, // Enable for debugging
    initialLocation: '/',
    redirect: (context, state) {
      // Don't redirect while loading initial auth state
      if (authState.isLoading) {
        return null;
      }

      final isLoggedIn = authState.value != null;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');
      final isSplashRoute = state.matchedLocation == '/';

      // If not logged in, redirect to login (unless already on auth route)
      if (!isLoggedIn) {
        if (isAuthRoute || isSplashRoute) {
          return null; // Allow access to auth routes and splash
        }
        return '/auth/login';
      }

      // If logged in, redirect away from auth routes and splash
      if (isAuthRoute || isSplashRoute) {
        return '/home/dashboard';
      }

      return null; // No redirect needed
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return HomeShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/dashboard',
                name: 'dashboard',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: DashboardScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/expenses',
                name: 'expenses',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: AddExpenseScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/settlements',
                name: 'settlements',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: SettlementsScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/profile',
                name: 'profile',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ProfileScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

