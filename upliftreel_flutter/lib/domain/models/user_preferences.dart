import 'package:freezed_annotation/freezed_annotation.dart';

import 'movie.dart';

part 'user_preferences.freezed.dart';
part 'user_preferences.g.dart';

/// Preferred-movie-language catalog: ISO-639-1 code → display label.
/// Codes are TMDB original-language values ('tl' is Filipino/Tagalog).
const Map<String, String> kPreferredLanguages = {
  'en': 'English',
  'ja': 'Japanese',
  'ko': 'Korean',
  'tl': 'Filipino',
  'fr': 'French',
  'es': 'Spanish',
  'de': 'German',
  'it': 'Italian',
  'hi': 'Hindi',
  'zh': 'Chinese',
};

@freezed
abstract class ReleaseYearRange with _$ReleaseYearRange {
  const factory ReleaseYearRange({required int min, required int max}) =
      _ReleaseYearRange;

  factory ReleaseYearRange.fromJson(Map<String, dynamic> json) =>
      _$ReleaseYearRangeFromJson(json);
}

@freezed
abstract class UserPreferences with _$UserPreferences {
  const factory UserPreferences({
    required List<Genre> selectedGenres,
    required double minRating,
    required double maxRating,
    @Default([]) List<String> preferredActors,
    @Default([]) List<String> preferredDirectors,
    ReleaseYearRange? releaseYearRange,

    /// Minutes.
    int? maxRuntime,
    @Default([]) List<Genre> excludedGenres,
    @Default([]) List<String> excludedMovieIds,

    /// 24h "HH:MM".
    @Default('19:00') String notificationTime,

    /// ISO-639-1 original-language filter for TMDB discovery.
    /// Must be a key of [kPreferredLanguages].
    @Default('en') String preferredLanguage,
  }) = _UserPreferences;

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);

  /// Legacy UserPreferenceManager.getDefaultPreferences, values unchanged.
  factory UserPreferences.defaults({int? currentYear}) => UserPreferences(
    selectedGenres: const [Genre.comedy, Genre.drama, Genre.action],
    minRating: 6.0,
    maxRating: 10.0,
    releaseYearRange: ReleaseYearRange(
      min: 1990,
      max: currentYear ?? DateTime.now().year,
    ),
    maxRuntime: 180,
  );
}
