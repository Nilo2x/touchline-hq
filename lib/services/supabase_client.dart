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

  /// Ensures a logged-in (even if anonymous) Supabase user exists before
  /// any screen needs `currentUser`. Squads, ratings, and chat messages
  /// all require a real user id as their owner — without this, features
  /// like "Create Squad" crash with a null-check error the first time
  /// someone uses the app, since nothing else in the app ever signs
  /// anyone in. Safe to call repeatedly; it's a no-op once signed in.
  ///
  /// Returns null on success, or an error message string on failure —
  /// deliberately not throwing, so a transient sign-in failure doesn't
  /// crash app startup itself; screens that need a user can check
  /// `client.auth.currentUser` and show a retry option instead.
  static Future<String?> ensureSignedIn() async {
    if (client.auth.currentUser != null) return null;
    try {
      await client.auth.signInAnonymously();
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
