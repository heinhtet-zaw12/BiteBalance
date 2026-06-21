import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:bite_balance/features/analytics/presentation/pages/analytics_page.dart';
import 'package:bite_balance/features/auth/presentation/pages/login_page.dart';
import 'package:bite_balance/features/auth/presentation/pages/register_page.dart';
import 'package:bite_balance/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:bite_balance/features/food_log/presentation/pages/food_log_page.dart';
import 'package:bite_balance/features/main/presentation/pages/main_scaffold.dart';
import 'package:bite_balance/features/profile/presentation/pages/home_page.dart';
import 'package:bite_balance/features/profile/presentation/pages/profile_setup_page.dart';
import 'package:bite_balance/features/splash/presentation/pages/splash_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
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
