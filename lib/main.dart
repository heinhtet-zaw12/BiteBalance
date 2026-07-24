import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:bite_balance/core/constants/app_theme.dart';
import 'package:bite_balance/core/router/app_router.dart';
import 'package:bite_balance/core/utils/app_logger.dart';
import 'package:bite_balance/core/utils/url_strategy.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load .env file (local dev), fall back to --dart-define (Vercel deploy)
    await dotenv.load(fileName: '.env');

    final supabaseUrl =
        dotenv.env['SUPABASE_URL'] ?? String.fromEnvironment('SUPABASE_URL');
    final supabaseAnonKey =
        dotenv.env['SUPABASE_ANON_KEY'] ?? String.fromEnvironment('SUPABASE_ANON_KEY');

    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabaseAnonKey,
    );
    AppLogger.info('Supabase initialized successfully');
  } catch (e, stackTrace) {
    AppLogger.error('Failed to initialize Supabase', e, stackTrace);
    rethrow;
  }
  usePathUrlStrategy();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Bite Balance',
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
