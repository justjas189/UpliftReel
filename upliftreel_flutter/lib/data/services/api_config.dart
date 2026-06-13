/// Compile-time API credentials. Pass at build/run time:
/// flutter run --dart-define=TMDB_ACCESS_TOKEN=... --dart-define=OMDB_API_KEY=...
/// Replaces legacy EXPO_PUBLIC_TMDB_ACCESS_TOKEN / EXPO_PUBLIC_OMDB_API_KEY.
abstract final class ApiConfig {
  static const String tmdbAccessToken = String.fromEnvironment(
    'TMDB_ACCESS_TOKEN',
  );
  static const String omdbApiKey = String.fromEnvironment('OMDB_API_KEY');
}
