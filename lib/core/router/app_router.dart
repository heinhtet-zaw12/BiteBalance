import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bite_balance/features/analytics/presentation/pages/analytics_page.dart';
import 'package:bite_balance/features/auth/presentation/pages/email_confirmation_page.dart';
import 'package:bite_balance/features/auth/presentation/pages/login_page.dart';
import 'package:bite_balance/features/auth/presentation/pages/register_page.dart';
import 'package:bite_balance/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:bite_balance/features/food_log/presentation/pages/food_log_page.dart';
import 'package:bite_balance/features/main/presentation/pages/main_scaffold.dart';
import 'package:bite_balance/features/profile/presentation/pages/home_page.dart';
import 'package:bite_balance/features/profile/presentation/pages/profile_setup_page.dart';
import 'package:bite_balance/features/splash/presentation/pages/splash_page.dart';
import 'package:bite_balance/features/auth/presentation/providers/auth_provider.dart';

/// Routes that require authentication.
const _protectedRoutes = {'/home', '/dashboard', '/analytics', '/food-log', '/profile-setup'};

/// Routes that should redirect authenticated users away (login/register).
const _authRoutes = {'/login', '/register'};

/// Creates the app router with auth-aware redirect logic.
GoRouter createRouter(Ref ref) {
  final authRefresh = ref.watch(authRefreshProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: authRefresh,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final location = state.matchedLocation;

      // Allow splash page through — it handles its own auth check
      if (location == '/') return null;

      // Allow email confirmation through (no auth required)
      if (location == '/email-confirmation') return null;

      // While auth state is loading (e.g. restoring persisted session),
      // don't redirect — wait for it to resolve.
      if (authState.isLoading) return null;

      final isLoggedIn = authState.valueOrNull != null;

      // Not logged in + trying to access a protected route → go to login
      if (!isLoggedIn && _protectedRoutes.contains(location)) {
        return '/login';
      }

      // Logged in + trying to access auth routes → go to home
      if (isLoggedIn && _authRoutes.contains(location)) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/email-confirmation',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return EmailConfirmationPage(email: email);
        },
      ),
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomePage(),
            ),
          ),
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardPage(),
            ),
          ),
          GoRoute(
            path: '/analytics',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AnalyticsPage(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/profile-setup',
        builder: (context, state) => const ProfileSetupPage(),
      ),
      GoRoute(
        path: '/food-log',
        builder: (context, state) => const FoodLogPage(),
      ),
    ],
  );
}

/// Provider that creates and caches the GoRouter instance.
final appRouterProvider = Provider<GoRouter>((ref) {
  return createRouter(ref);
});
