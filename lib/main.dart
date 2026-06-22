import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_colors.dart';
import 'services/supabase_client.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';

/// Developer: Coach: Danilo
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSupabase.init();
  final signInError = await AppSupabase.ensureSignedIn();
  runApp(ProviderScope(child: TouchlineHQApp(signInError: signInError)));
}

class TouchlineHQApp extends StatefulWidget {
  final String? signInError;
  const TouchlineHQApp({super.key, this.signInError});

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
      home: widget.signInError != null
          ? _StartupErrorScreen(message: widget.signInError!)
          : (_splashDone
              ? const DashboardScreen()
              : SplashScreen(onComplete: () => setState(() => _splashDone = true))),
    );
  }
}

/// Shown if anonymous sign-in fails on startup (e.g. no internet, or
/// Anonymous Sign-Ins not enabled in the Supabase dashboard) instead of
/// silently continuing into screens that will crash later.
class _StartupErrorScreen extends StatelessWidget {
  final String message;
  const _StartupErrorScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, color: AppColors.neonMagentaAlert, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Could not connect',
                style: TextStyle(color: AppColors.neonWhite, fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.neonWhite.withOpacity(0.6), fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
