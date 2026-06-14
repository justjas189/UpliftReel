import 'dart:math';

import '../models/mood.dart';
import '../models/movie.dart';
import '../models/recommendation.dart';

/// Pure port of legacy UpliftReelRecommendationEngine
/// (src/services/RecommendationEngine.ts). No Flutter, no IO.
///
/// Pipeline: hard filters → mood filter → recency removal → weighted scoring
/// → edge-case relaxation (rating ±0.5, then related genres) → fallback.
///
/// Deviations from legacy, both approved in the Phase 2 plan:
/// - [Random] is injected so the last-ditch fallback is testable.
/// - minRating == maxRating no longer produces a NaN score.
class RecommendationEngine {
  RecommendationEngine({Random? random}) : _random = random ?? Random();

  final Random _random;

  /// Scoring weights, legacy-exact: genre 40 + rating 20 + people 15 +
  /// mood 15 + runtime 10 = 100.
  static const double _genreWeight = 40;
  static const double _ratingWeight = 20;
  static const double _actorBonus = 7.5;
  static const double _directorBonus = 7.5;
  static const double _moodWeight = 15;
  static const double _runtimeWeight = 10;

  /// Hard matchmaking gate: a pick whose normalized [compatibilityPercent]
  /// falls below this is flagged [RecommendationResult.isBelowThreshold] so
  /// the UI can warn the user it didn't clear their bar.
  static const double _minCompatibility = 75;

  static const int _seriousnessTolerance = 2;

  static const Map<Mood, List<MoodTag>> _moodToTags = {
    Mood.happy: [MoodTag.uplifting, MoodTag.funny],
    Mood.suspense: [MoodTag.intense, MoodTag.scary, MoodTag.exciting],
    Mood.introspective: [MoodTag.thoughtProvoking, MoodTag.nostalgic],
    Mood.excited: [MoodTag.exciting, MoodTag.uplifting],
    Mood.romantic: [MoodTag.romantic, MoodTag.uplifting],
    Mood.adventurous: [MoodTag.exciting, MoodTag.inspiring],
    Mood.relaxed: [MoodTag.relaxing, MoodTag.uplifting],
    Mood.curious: [MoodTag.thoughtProvoking, MoodTag.inspiring],
  };

  /// 1 (lightest) … 10 (heaviest) per genre.
  static const Map<Genre, int> _genreSeriousness = {
    Genre.comedy: 2,
    Genre.romance: 4,
    Genre.adventure: 5,
    Genre.action: 6,
    Genre.scifi: 6,
    Genre.fantasy: 5,
    Genre.animation: 3,
    Genre.mystery: 7,
    Genre.thriller: 8,
    Genre.drama: 9,
    Genre.horror: 7,
    Genre.documentary: 8,
  };

  static const Map<Genre, List<Genre>> _relatedGenres = {
    Genre.action: [Genre.adventure, Genre.thriller],
    Genre.adventure: [Genre.action, Genre.fantasy],
    Genre.comedy: [Genre.romance, Genre.animation],
    Genre.drama: [Genre.thriller, Genre.mystery],
    Genre.horror: [Genre.thriller, Genre.mystery],
    Genre.romance: [Genre.comedy, Genre.drama],
    Genre.scifi: [Genre.fantasy, Genre.adventure],
    Genre.thriller: [Genre.mystery, Genre.horror, Genre.action],
    Genre.documentary: [Genre.drama],
    Genre.fantasy: [Genre.adventure, Genre.scifi],
    Genre.mystery: [Genre.thriller, Genre.drama],
    Genre.animation: [Genre.comedy, Genre.adventure],
  };

  static const Map<Mood, String> _moodDescriptions = {
    Mood.happy: 'upbeat',
    Mood.suspense: 'thrilling',
    Mood.introspective: 'contemplative',
    Mood.excited: 'energetic',
    Mood.romantic: 'romantic',
    Mood.adventurous: 'adventurous',
    Mood.relaxed: 'chill',
    Mood.curious: 'thought-provoking',
  };

  RecommendationResult findBestMatch(
    RecommendationContext context,
    List<Movie> movieDatabase,
  ) {
    var filtered = _applyHardFilters(movieDatabase, context);

    final mood = context.currentMood;
    if (mood != null) {
      filtered = _applyMoodFiltering(filtered, mood);
    }

    filtered = _removeRecentMovies(filtered, context);

    if (filtered.isNotEmpty) {
      // Compatibility is matchScore / applicableWeight, and applicableWeight is
      // constant across this context, so argmax(matchScore) == argmax(
      // compatibility): the legacy best pick is also the highest-compatibility
      // pick. The 75% gate therefore reduces to flagging that single best —
      // if it doesn't clear the bar, nothing in the pool does.
      final (movie, score) = _selectBestMatch(filtered, context);
      final compatibility = compatibilityPercent(movie, context);
      return RecommendationResult(
        movie: movie,
        matchScore: score,
        compatibility: compatibility,
        isBelowThreshold: compatibility < _minCompatibility,
        explanation: _generateExplanation(movie, context, score),
        isAlternative: false,
      );
    }

    return handleEdgeCases(context, movieDatabase) ??
        _fallbackRecommendation(context, movieDatabase);
  }

  /// Normalized 0–100 match compatibility: [calculateMatchScore] as a
  /// percentage of the weight actually in play for this context. A movie that
  /// nails every applicable criterion scores 100 regardless of whether the
  /// user set a mood, preferred people, or a runtime cap.
  double compatibilityPercent(Movie movie, RecommendationContext context) {
    final applicable = _applicableWeight(context);
    if (applicable == 0) return 0;
    return (calculateMatchScore(movie, context) / applicable * 100).clamp(
      0,
      100,
    );
  }

  /// Sum of the scoring weights that can contribute for this context. Genre and
  /// rating always apply (a valid profile has ≥1 genre); the rest are
  /// conditional on the user having set them, mirroring [calculateMatchScore].
  double _applicableWeight(RecommendationContext context) {
    final prefs = context.userPreferences;
    var weight = _genreWeight + _ratingWeight;

    if (prefs.preferredActors.isNotEmpty) weight += _actorBonus;
    if (prefs.preferredDirectors.isNotEmpty) weight += _directorBonus;

    final mood = context.currentMood;
    if (mood != null && (_moodToTags[mood.mood]?.isNotEmpty ?? false)) {
      weight += _moodWeight;
    }

    if (prefs.maxRuntime != null) weight += _runtimeWeight;

    return weight;
  }

  List<Movie> _applyHardFilters(
    List<Movie> movies,
    RecommendationContext context,
  ) {
    final prefs = context.userPreferences;

    return movies.where((movie) {
      final hasMatchingGenre = movie.genres.any(prefs.selectedGenres.contains);
      if (!hasMatchingGenre) return false;

      if (movie.imdbRating < prefs.minRating ||
          movie.imdbRating > prefs.maxRating) {
        return false;
      }

      if (movie.genres.any(prefs.excludedGenres.contains)) return false;
      if (prefs.excludedMovieIds.contains(movie.id)) return false;

      final yearRange = prefs.releaseYearRange;
      if (yearRange != null &&
          (movie.releaseYear < yearRange.min ||
              movie.releaseYear > yearRange.max)) {
        return false;
      }

      // Transient Era Selector overlay, intersected on top of the persisted
      // range above. Enforced here as well as at the TMDB query so the
      // English /movie/popular path (which can't pre-filter by year) is
      // still era-correct.
      final era = context.eraRange;
      if (era != null &&
          (movie.releaseYear < era.min || movie.releaseYear > era.max)) {
        return false;
      }

      final maxRuntime = prefs.maxRuntime;
      if (maxRuntime != null && movie.runtime > maxRuntime) return false;

      return true;
    }).toList();
  }

  List<Movie> _applyMoodFiltering(List<Movie> movies, MoodInput moodInput) {
    final moodTags = _moodToTags[moodInput.mood] ?? const [];

    return movies.where((movie) {
      final hasMoodMatch = movie.moodTags.any(moodTags.contains);
      final seriousnessMatch =
          (_movieSeriousness(movie) - moodInput.seriousness).abs() <=
          _seriousnessTolerance;
      return hasMoodMatch && seriousnessMatch;
    }).toList();
  }

  int _movieSeriousness(Movie movie) {
    final total = movie.genres.fold<int>(
      0,
      (sum, genre) => sum + _genreSeriousness[genre]!,
    );
    return (total / movie.genres.length).round();
  }

  /// Zero-duplication guard: cross-references the active recommendation queue
  /// ([RecommendationContext.previousRecommendationIds], the recency window the
  /// controller passes) against the user's watch history
  /// ([RecommendationContext.watchedMovieIds]) and drops any candidate present
  /// in either, so a movie is never surfaced twice.
  List<Movie> _removeRecentMovies(
    List<Movie> movies,
    RecommendationContext context,
  ) {
    final seen = {
      ...context.previousRecommendationIds,
      ...context.watchedMovieIds,
    };
    return movies.where((movie) => !seen.contains(movie.id)).toList();
  }

  /// Era + dedup predicate shared by the edge-case relaxation strategies, so a
  /// relaxed pick still honors the Era Selector and never repeats a movie.
  bool _withinEraAndUnseen(Movie movie, RecommendationContext context) {
    final era = context.eraRange;
    if (era != null &&
        (movie.releaseYear < era.min || movie.releaseYear > era.max)) {
      return false;
    }
    return !context.previousRecommendationIds.contains(movie.id) &&
        !context.watchedMovieIds.contains(movie.id);
  }

  double calculateMatchScore(Movie movie, RecommendationContext context) {
    final prefs = context.userPreferences;
    var score = 0.0;

    final matchingGenres = movie.genres
        .where(prefs.selectedGenres.contains)
        .length;
    score += matchingGenres / prefs.selectedGenres.length * _genreWeight;

    // Legacy divided by (max - min) unguarded; equal bounds gave NaN. A movie
    // that passed filters with min == max sits exactly on the bound: full marks.
    final ratingSpan = prefs.maxRating - prefs.minRating;
    score += ratingSpan == 0
        ? _ratingWeight
        : (movie.imdbRating - prefs.minRating) / ratingSpan * _ratingWeight;

    if (prefs.preferredActors.any(movie.actors.contains)) {
      score += _actorBonus;
    }
    if (prefs.preferredDirectors.contains(movie.director)) {
      score += _directorBonus;
    }

    final mood = context.currentMood;
    if (mood != null) {
      final moodTags = _moodToTags[mood.mood] ?? const [];
      if (moodTags.isNotEmpty) {
        final matching = movie.moodTags.where(moodTags.contains).length;
        score += matching / moodTags.length * _moodWeight;
      }
    }

    final maxRuntime = prefs.maxRuntime;
    if (maxRuntime != null) {
      score += max(
        0,
        (maxRuntime - movie.runtime) / maxRuntime * _runtimeWeight,
      );
    }

    return score.clamp(0, 100);
  }

  (Movie, double) _selectBestMatch(
    List<Movie> movies,
    RecommendationContext context,
  ) {
    var bestMovie = movies.first;
    var bestScore = calculateMatchScore(bestMovie, context);

    for (final movie in movies.skip(1)) {
      final score = calculateMatchScore(movie, context);
      if (score > bestScore) {
        bestMovie = movie;
        bestScore = score;
      }
    }

    return (bestMovie, bestScore);
  }

  RecommendationResult? handleEdgeCases(
    RecommendationContext context,
    List<Movie> movieDatabase,
  ) {
    final prefs = context.userPreferences;

    // Strategy 1: relax rating bounds by 0.5 either side.
    final relaxedMin = max(1.0, prefs.minRating - 0.5);
    final relaxedMax = min(10.0, prefs.maxRating + 0.5);
    final relaxedRating = movieDatabase.where((movie) {
      return movie.genres.any(prefs.selectedGenres.contains) &&
          movie.imdbRating >= relaxedMin &&
          movie.imdbRating <= relaxedMax &&
          !prefs.excludedMovieIds.contains(movie.id) &&
          _withinEraAndUnseen(movie, context);
    }).toList();

    if (relaxedRating.isNotEmpty) {
      final (movie, score) = _selectBestMatch(relaxedRating, context);
      final belowMin = movie.imdbRating < prefs.minRating;
      final bound = belowMin ? prefs.minRating : prefs.maxRating;
      final ratingDiff = (movie.imdbRating - prefs.minRating).abs();

      return RecommendationResult(
        movie: movie,
        matchScore: score,
        compatibility: compatibilityPercent(movie, context),
        isBelowThreshold:
            compatibilityPercent(movie, context) < _minCompatibility,
        explanation: _generateAlternativeExplanation(
          movie,
          context,
          _AlternativeReason.rating,
        ),
        isAlternative: true,
        alternativeReason:
            'This is rated ${movie.imdbRating}, ${ratingDiff < 1 ? 'just ' : ''}'
            '${belowMin ? 'below' : 'above'} your '
            '${belowMin ? 'minimum' : 'maximum'} of $bound, but it\'s highly '
            'regarded in ${movie.genres.map((g) => g.label).join(', ')}!',
      );
    }

    // Strategy 2: expand to related genres.
    final related = <Genre>{
      for (final genre in prefs.selectedGenres) ..._relatedGenres[genre]!,
    };
    final expandedGenre = movieDatabase.where((movie) {
      return movie.genres.any(related.contains) &&
          movie.imdbRating >= prefs.minRating &&
          movie.imdbRating <= prefs.maxRating &&
          !prefs.excludedMovieIds.contains(movie.id) &&
          _withinEraAndUnseen(movie, context);
    }).toList();

    if (expandedGenre.isNotEmpty) {
      final (movie, score) = _selectBestMatch(expandedGenre, context);
      return RecommendationResult(
        movie: movie,
        matchScore: score,
        compatibility: compatibilityPercent(movie, context),
        isBelowThreshold:
            compatibilityPercent(movie, context) < _minCompatibility,
        explanation: _generateAlternativeExplanation(
          movie,
          context,
          _AlternativeReason.genre,
        ),
        isAlternative: true,
        alternativeReason:
            'While not exactly in your preferred genres, this '
            '${movie.genres.map((g) => g.label).join('/')} film shares '
            'similar themes and might surprise you!',
      );
    }

    return null;
  }

  RecommendationResult _fallbackRecommendation(
    RecommendationContext context,
    List<Movie> movieDatabase,
  ) {
    final fallbacks =
        movieDatabase
            .where(
              (movie) =>
                  movie.genres.any(
                    context.userPreferences.selectedGenres.contains,
                  ) &&
                  _withinEraAndUnseen(movie, context),
            )
            .toList()
          ..sort((a, b) => b.imdbRating.compareTo(a.imdbRating));

    final movie = fallbacks.isNotEmpty
        ? fallbacks.first
        : movieDatabase[_random.nextInt(movieDatabase.length)];

    return RecommendationResult(
      movie: movie,
      matchScore: 50,
      compatibility: compatibilityPercent(movie, context),
      // A crowd-favorite fallback never clears the user's own bar by
      // definition; flag it so the UI is honest about the stretch.
      isBelowThreshold:
          compatibilityPercent(movie, context) < _minCompatibility,
      explanation:
          "We couldn't find a perfect match for your current preferences, "
          'so here\'s a highly-rated '
          '${movie.genres.map((g) => g.label).join('/')} film that many '
          'users love!',
      isAlternative: true,
      alternativeReason:
          'Your preferences are quite specific, so we picked a crowd '
          'favorite instead!',
    );
  }

  String _generateExplanation(
    Movie movie,
    RecommendationContext context,
    double score,
  ) {
    final prefs = context.userPreferences;
    final parts = <String>[];

    final matchingGenres = movie.genres
        .where(prefs.selectedGenres.contains)
        .toList();
    if (matchingGenres.isNotEmpty) {
      parts.add(
        'This ${matchingGenres.map((g) => g.label).join('/')} film '
        'matches your genre preferences',
      );
    }

    if (movie.imdbRating >= prefs.minRating) {
      parts.add('with its excellent ${movie.imdbRating}/10 IMDb rating');
    }

    final mood = context.currentMood;
    if (mood != null) {
      parts.add('and fits your current ${_moodDescriptions[mood.mood]} mood');
    }

    final matchingActor = movie.actors
        .where(prefs.preferredActors.contains)
        .firstOrNull;
    if (matchingActor != null) {
      parts.add('featuring your favorite actor $matchingActor');
    }

    if (prefs.preferredDirectors.contains(movie.director)) {
      parts.add('directed by ${movie.director}, whom you love');
    }

    final explanation = '${parts.join(', ')}!';
    if (score >= 90) return '🎯 Perfect match! $explanation';
    if (score >= 75) return '⭐ Great choice! $explanation';
    if (score >= 60) return '👍 Good pick! $explanation';
    return explanation;
  }

  String _generateAlternativeExplanation(
    Movie movie,
    RecommendationContext context,
    _AlternativeReason reason,
  ) {
    final base = _generateExplanation(movie, context, 70).toLowerCase();
    return switch (reason) {
      _AlternativeReason.rating =>
        "While the rating doesn't perfectly match your range, $base",
      _AlternativeReason.genre =>
        "Though it's outside your usual genres, $base",
    };
  }
}

enum _AlternativeReason { rating, genre }
