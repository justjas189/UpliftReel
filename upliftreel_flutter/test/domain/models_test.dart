import 'package:flutter_test/flutter_test.dart';
import 'package:upliftreel/domain/models/mood.dart';
import 'package:upliftreel/domain/models/movie.dart';
import 'package:upliftreel/domain/models/recommendation.dart';
import 'package:upliftreel/domain/models/user_preferences.dart';

void main() {
  group('UserPreferences.defaults', () {
    test('matches legacy UserPreferenceManager values', () {
      final defaults = UserPreferences.defaults(currentYear: 2026);

      expect(defaults.selectedGenres,
          [Genre.comedy, Genre.drama, Genre.action]);
      expect(defaults.minRating, 6.0);
      expect(defaults.maxRating, 10.0);
      expect(defaults.releaseYearRange,
          const ReleaseYearRange(min: 1990, max: 2026));
      expect(defaults.maxRuntime, 180);
      expect(defaults.notificationTime, '19:00');
      expect(defaults.excludedGenres, isEmpty);
      expect(defaults.excludedMovieIds, isEmpty);
    });
  });

  group('JSON round-trips', () {
    test('Movie keeps legacy wire strings for enums', () {
      const m = Movie(
        id: '1',
        title: 'Inception',
        genres: [Genre.scifi, Genre.thriller],
        imdbRating: 8.8,
        releaseYear: 2010,
        runtime: 148,
        synopsis: 'Dreams within dreams.',
        director: 'Christopher Nolan',
        actors: ['Leonardo DiCaprio'],
        moodTags: [MoodTag.thoughtProvoking, MoodTag.intense],
        posterUrl: 'https://image.tmdb.org/t/p/w500/x.jpg',
      );

      final json = m.toJson();
      expect(json['genres'], ['sci-fi', 'thriller']);
      expect(json['moodTags'], ['thought-provoking', 'intense']);
      expect(Movie.fromJson(json), m);
    });

    test('RecommendationResult round-trips for daily-pick persistence', () {
      const result = RecommendationResult(
        movie: Movie(
          id: '1',
          title: 'Parasite',
          genres: [Genre.thriller, Genre.drama],
          imdbRating: 8.6,
          releaseYear: 2019,
          runtime: 132,
          synopsis: 'A shocking crime.',
          director: 'Bong Joon Ho',
          actors: ['Song Kang-ho'],
          moodTags: [MoodTag.intense],
        ),
        matchScore: 87.5,
        explanation: 'Great choice!',
        isAlternative: false,
      );

      expect(RecommendationResult.fromJson(result.toJson()), result);
    });

    test('MoodInput round-trips', () {
      const input =
          MoodInput(mood: Mood.introspective, intensity: 7, seriousness: 8);
      expect(MoodInput.fromJson(input.toJson()), input);
    });
  });

  group('Mood enum', () {
    test('carries legacy emoji and labels', () {
      expect(Mood.happy.emoji, '😊');
      expect(Mood.suspense.emoji, '😨');
      expect(Mood.values, hasLength(8));
    });
  });
}
