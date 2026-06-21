import 'package:supabase_flutter/supabase_flutter.dart';

/// Developer: Coach: Danilo
/// Initialize once in main.dart:
///   await AppSupabase.init();
class AppSupabase {
  AppSupabase._();

  static Future<void> init() async {
    await Supabase.initialize(
      url: const String.fromEnvironment('SUPABASE_URL',
          defaultValue: 'https://YOUR_PROJECT.supabase.co'),
      anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY',
          defaultValue: 'YOUR_ANON_KEY'),
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
