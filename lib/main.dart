import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'services/supabase_client.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';

/// Developer: Coach: Danilo
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSupabase.init();
  runApp(const ProviderScope(child: TouchlineHQApp()));
}

class TouchlineHQApp extends StatefulWidget {
  const TouchlineHQApp({super.key});

  @override
  State<TouchlineHQApp> createState() => _TouchlineHQAppState();
}

class _TouchlineHQAppState extends State<TouchlineHQApp> {
  bool _splashDone = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: _splashDone
          ? const DashboardScreen()
          : SplashScreen(onComplete: () => setState(() => _splashDone = true)),
    );
  }
}
