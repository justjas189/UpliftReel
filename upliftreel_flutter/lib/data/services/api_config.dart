/// Compile-time API credentials. Pass at build/run time:
/// flutter run --dart-define=TMDB_ACCESS_TOKEN=... --dart-define=OMDB_API_KEY=...
/// Replaces legacy EXPO_PUBLIC_TMDB_ACCESS_TOKEN / EXPO_PUBLIC_OMDB_API_KEY.
abstract final class ApiConfig {
  static const String tmdbAccessToken = String.fromEnvironment(
    'TMDB_ACCESS_TOKEN',
  );
  static const String omdbApiKey = String.fromEnvironment('OMDB_API_KEY');

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );

  /// Auth is optional: with no Supabase keys the app runs local-only and
  /// the login sheet reports the missing configuration.
  static const bool supabaseConfigured =
      supabaseUrl != '' && supabaseAnonKey != '';
}
