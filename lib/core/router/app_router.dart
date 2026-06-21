import 'package:go_router/go_router.dart';

import 'package:bite_balance/features/auth/presentation/pages/login_page.dart';
import 'package:bite_balance/features/auth/presentation/pages/register_page.dart';
import 'package:bite_balance/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:bite_balance/features/food_log/presentation/pages/food_log_page.dart';
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
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/profile-setup',
      builder: (context, state) => const ProfileSetupPage(),
    ),
    GoRoute(
      path: '/food-log',
      builder: (context, state) => const FoodLogPage(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardPage(),
    ),
  ],
);
