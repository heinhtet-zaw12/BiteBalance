import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:bite_balance/core/constants/app_theme.dart';
import 'package:bite_balance/features/auth/presentation/providers/auth_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  bool _navigating = false;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _checkAuth();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _checkAuth() async {
    // Let the Lottie animation play for at least 2s
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Wait for auth provider to resolve persisted session
    final authState = ref.read(authProvider);
    if (authState.isLoading) {
      ref.listenManual(authProvider, (previous, next) {
        if (!next.isLoading && mounted && !_navigating) {
          _navigate(next.valueOrNull != null);
        }
      });
      return;
    }

    _navigate(authState.valueOrNull != null);
  }

  void _navigate(bool isLoggedIn) {
    if (_navigating) return;
    _navigating = true;

    // Fade out then navigate
    _fadeController.forward().then((_) {
      if (!mounted) return;
      if (isLoggedIn) {
        context.go('/home');
      } else {
        context.go('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lottie animation
              Lottie.asset(
                'assets/animations/splash.json',
                width: 160,
                height: 160,
                fit: BoxFit.contain,
                repeat: true,
                animate: true,
              ),
              const SizedBox(height: 32),

              // App name
              Text(
                'Bite Balance',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your health, balanced',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
