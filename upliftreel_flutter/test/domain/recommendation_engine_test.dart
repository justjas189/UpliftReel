import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:upliftreel/domain/engine/recommendation_engine.dart';
import 'package:upliftreel/domain/models/mood.dart';
import 'package:upliftreel/domain/models/movie.dart';
import 'package:upliftreel/domain/models/recommendation.dart';
import 'package:upliftreel/domain/models/user_preferences.dart';

Movie movie({
  String id = 'm1',
  String title = 'Test Movie',
  List<Genre> genres = const [Genre.comedy],
  double imdbRating = 8.0,
  int releaseYear = 2015,
  int runtime = 100,
  String director = 'Director',
  List<String> actors = const ['Actor'],
  List<MoodTag> moodTags = const [MoodTag.funny],
}) {
  return Movie(
    id: id,
    title: title,
    genres: genres,
    imdbRating: imdbRating,
    releaseYear: releaseYear,
    runtime: runtime,
    synopsis: 'Synopsis',
    director: director,
    actors: actors,
    moodTags: moodTags,
  );
}

UserPreferences prefs({
  List<Genre> selectedGenres = const [Genre.comedy, Genre.drama],
  double minRating = 6.0,
  double maxRating = 10.0,
  List<String> preferredActors = const [],
  List<String> preferredDirectors = const [],
  ReleaseYearRange? releaseYearRange,
  int? maxRuntime,
  List<Genre> excludedGenres = const [],
  List<String> excludedMovieIds = const [],
}) {
  return UserPreferences(
    selectedGenres: selectedGenres,
    minRating: minRating,
    maxRating: maxRating,
    preferredActors: preferredActors,
    preferredDirectors: preferredDirectors,
    releaseYearRange: releaseYearRange,
    maxRuntime: maxRuntime,
    excludedGenres: excludedGenres,
    excludedMovieIds: excludedMovieIds,
  );
}

void main() {
  final engine = RecommendationEngine(random: Random(42));

  group('hard filters', () {
    test('rejects by genre, rating, exclusions, year, runtime', () {
      final db = [
        movie(id: 'wrong-genre', genres: [Genre.horror]),
        movie(id: 'too-low', imdbRating: 5.9),
        movie(id: 'excluded-genre', genres: [Genre.comedy, Genre.thriller]),
        movie(id: 'excluded-id'),
        movie(id: 'too-old', releaseYear: 1980),
        movie(id: 'too-long', runtime: 200),
        movie(id: 'keeper'),
      ];

      final result = engine.findBestMatch(
        RecommendationContext(
          userPreferences: prefs(
            excludedGenres: [Genre.thriller],
            excludedMovieIds: ['excluded-id'],
            releaseYearRange: const ReleaseYearRange(min: 1990, max: 2030),
            maxRuntime: 180,
          ),
        ),
        db,
      );

      expect(result.movie.id, 'keeper');
      expect(result.isAlternative, isFalse);
    });
  });

  group('mood filtering', () {
    test('requires tag match AND seriousness within ±2', () {
      final db = [
        // Drama seriousness 9, |9-2|=7 → out despite uplifting tag.
        movie(
          id: 'heavy',
          genres: [Genre.drama],
          moodTags: [MoodTag.uplifting],
        ),
        // Comedy seriousness 2, |2-2|=0, funny tag matches happy mood.
        movie(id: 'light', genres: [Genre.comedy]),
        // Seriousness fits but no happy tag (intense ∉ {uplifting, funny}).
        movie(id: 'wrong-tag', moodTags: [MoodTag.intense]),
      ];

      final result = engine.findBestMatch(
        RecommendationContext(
          userPreferences: prefs(),
          currentMood: const MoodInput(
            mood: Mood.happy,
            intensity: 5,
            seriousness: 2,
          ),
        ),
        db,
      );

      expect(result.movie.id, 'light');
      expect(result.isAlternative, isFalse);
    });
  });

  group('match scoring (legacy weight parity)', () {
    test('full-stack score composes 40+20+15+15+5 = 95', () {
      final m = movie(
        genres: [Genre.comedy, Genre.drama],
        imdbRating: 10.0,
        runtime: 90,
        director: 'Wes Anderson',
        actors: ['Ralph Fiennes'],
        moodTags: [MoodTag.uplifting, MoodTag.funny],
      );

      final score = engine.calculateMatchScore(
        m,
        RecommendationContext(
          userPreferences: prefs(
            preferredActors: ['Ralph Fiennes'],
            preferredDirectors: ['Wes Anderson'],
            maxRuntime: 180,
          ),
          currentMood: const MoodInput(
            mood: Mood.happy,
            intensity: 5,
            seriousness: 5,
          ),
        ),
      );

      // genre 2/2*40 + rating (10-6)/(10-6)... span 4 → 20 + people 15
      // + mood 2/2*15 + runtime (180-90)/180*10 = 95.
      expect(score, 95.0);
    });

    test(
      'minRating == maxRating yields finite full rating score (bug fix)',
      () {
        final score = engine.calculateMatchScore(
          movie(imdbRating: 8.8),
          RecommendationContext(
            userPreferences: prefs(minRating: 8.8, maxRating: 8.8),
          ),
        );

        expect(score.isFinite, isTrue);
        // genre 1/2*40 = 20, rating full 20.
        expect(score, 40.0);
      },
    );
  });

  group('recency', () {
    test('skips previously recommended and watched movies', () {
      final db = [
        movie(id: 'recommended-before', imdbRating: 9.5),
        movie(id: 'watched-before', imdbRating: 9.4),
        movie(id: 'fresh', imdbRating: 7.0),
      ];

      final result = engine.findBestMatch(
        RecommendationContext(
          userPreferences: prefs(),
          previousRecommendationIds: const ['recommended-before'],
          watchedMovieIds: const ['watched-before'],
        ),
        db,
      );

      expect(result.movie.id, 'fresh');
    });
  });

  group('edge cases', () {
    test('strategy 1: relaxes rating by 0.5 and flags alternative', () {
      final db = [movie(id: 'near-miss', imdbRating: 5.6)];

      final result = engine.findBestMatch(
        RecommendationContext(userPreferences: prefs()),
        db,
      );

      expect(result.movie.id, 'near-miss');
      expect(result.isAlternative, isTrue);
      expect(result.alternativeReason, contains('below your minimum of 6.0'));
    });

    test('strategy 2: expands to related genres', () {
      // Action relates to adventure/thriller; 5.0 is beyond rating relax.
      final db = [
        movie(id: 'thriller-cousin', genres: [Genre.thriller]),
        movie(id: 'unrelated', genres: [Genre.documentary], imdbRating: 5.0),
      ];

      final result = engine.findBestMatch(
        RecommendationContext(
          userPreferences: prefs(selectedGenres: [Genre.action]),
        ),
        db,
      );

      expect(result.movie.id, 'thriller-cousin');
      expect(result.isAlternative, isTrue);
      expect(result.alternativeReason, contains('not exactly'));
    });
  });

  group('fallback', () {
    test('prefers highest-rated movie from selected genres', () {
      // Comedy relates to romance/animation only — horror is unreachable via
      // strategies, but selected-genre fallback still finds excluded-rating comedies.
      final db = [
        movie(id: 'low-comedy', imdbRating: 4.0),
        movie(id: 'high-comedy', imdbRating: 5.0),
      ];

      final result = engine.findBestMatch(
        RecommendationContext(
          userPreferences: prefs(selectedGenres: [Genre.comedy]),
        ),
        db,
      );

      expect(result.movie.id, 'high-comedy');
      expect(result.matchScore, 50);
      expect(result.isAlternative, isTrue);
    });

    test('seeded random pick is deterministic when nothing matches', () {
      final db = [
        movie(id: 'h1', genres: [Genre.horror], imdbRating: 5.0),
        movie(id: 'h2', genres: [Genre.horror], imdbRating: 5.0),
        movie(id: 'h3', genres: [Genre.horror], imdbRating: 5.0),
      ];
      final context = RecommendationContext(
        userPreferences: prefs(selectedGenres: [Genre.comedy]),
      );

      final a = RecommendationEngine(
        random: Random(7),
      ).findBestMatch(context, db);
      final b = RecommendationEngine(
        random: Random(7),
      ).findBestMatch(context, db);

      expect(a.movie.id, b.movie.id);
      expect(a.matchScore, 50);
    });
  });

  group('explanations', () {
    test('high score gets perfect-match prefix', () {
      final db = [
        movie(
          genres: [Genre.comedy, Genre.drama],
          imdbRating: 10.0,
          runtime: 90,
          director: 'Wes Anderson',
          actors: ['Ralph Fiennes'],
          moodTags: [MoodTag.uplifting, MoodTag.funny],
        ),
      ];

      final result = engine.findBestMatch(
        RecommendationContext(
          userPreferences: prefs(
            preferredActors: ['Ralph Fiennes'],
            preferredDirectors: ['Wes Anderson'],
            maxRuntime: 180,
          ),
          currentMood: const MoodInput(
            mood: Mood.happy,
            intensity: 5,
            seriousness: 5,
          ),
        ),
        db,
      );

      expect(result.explanation, startsWith('🎯 Perfect match!'));
      expect(result.explanation, contains('comedy/drama'));
      expect(result.explanation, contains('upbeat mood'));
      expect(result.explanation, contains('Ralph Fiennes'));
      expect(result.explanation, contains('Wes Anderson'));
    });
  });

  group('compatibility (normalized %)', () {
    test('100% when the movie nails every applicable criterion', () {
      // Only genre + rating apply (no mood/people/runtime), so denom = 60.
      final score = engine.compatibilityPercent(
        movie(genres: [Genre.comedy], imdbRating: 10.0),
        RecommendationContext(
          userPreferences: prefs(selectedGenres: [Genre.comedy]),
        ),
      );
      expect(score, 100.0);
    });

    test('normalizes against applicable weight, ignoring unset criteria', () {
      // genre 40 + rating (6.5-6)/4*20 = 2.5 → 42.5 of 60 applicable = 70.83%.
      final score = engine.compatibilityPercent(
        movie(genres: [Genre.comedy], imdbRating: 6.5),
        RecommendationContext(
          userPreferences: prefs(selectedGenres: [Genre.comedy]),
        ),
      );
      expect(score, closeTo(70.83, 0.01));
    });
  });

  group('75% match gate', () {
    test('does not flag a pick that clears the bar', () {
      final result = engine.findBestMatch(
        RecommendationContext(
          userPreferences: prefs(selectedGenres: [Genre.comedy]),
        ),
        [
          movie(genres: [Genre.comedy], imdbRating: 10.0),
        ],
      );

      expect(result.compatibility, 100.0);
      expect(result.isBelowThreshold, isFalse);
    });

    test('flags the best-available pick when nothing clears 75%', () {
      // Best comedy is only a 70.83% match → still returned, but flagged.
      final result = engine.findBestMatch(
        RecommendationContext(
          userPreferences: prefs(selectedGenres: [Genre.comedy]),
        ),
        [
          movie(id: 'weak', genres: [Genre.comedy], imdbRating: 6.5),
        ],
      );

      expect(result.movie.id, 'weak');
      expect(result.isBelowThreshold, isTrue);
      expect(result.compatibility, closeTo(70.83, 0.01));
      // The gate is orthogonal to the edge-case alternative flag.
      expect(result.isAlternative, isFalse);
    });
  });

  group('era filter', () {
    test('excludes movies outside the active era window', () {
      final db = [
        movie(id: 'too-old', releaseYear: 2005),
        movie(id: 'in-era', releaseYear: 2015),
      ];

      final result = engine.findBestMatch(
        RecommendationContext(
          userPreferences: prefs(selectedGenres: [Genre.comedy]),
          eraRange: const ReleaseYearRange(min: 2010, max: 2019),
        ),
        db,
      );

      expect(result.movie.id, 'in-era');
    });
  });
}
