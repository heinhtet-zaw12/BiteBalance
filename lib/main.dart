import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:bite_balance/core/constants/app_theme.dart';
import 'package:bite_balance/core/router/app_router.dart';
import 'package:bite_balance/core/utils/app_logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  try {
    await Supabase.initialize(
      url: dotenv.get('SUPABASE_URL'),
      publishableKey: dotenv.get('SUPABASE_ANON_KEY'),
    );
    AppLogger.info('Supabase initialized successfully');
  } catch (e, stackTrace) {
    AppLogger.error('Failed to initialize Supabase', e, stackTrace);
    rethrow;
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Bite Balance',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
