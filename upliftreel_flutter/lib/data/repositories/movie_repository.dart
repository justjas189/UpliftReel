import 'dart:convert';

import 'package:hive/hive.dart';

import '../../domain/models/era_filter.dart';
import '../../domain/models/movie.dart';
import '../services/omdb_api.dart';
import '../services/tmdb_api.dart';

/// Single source of truth for movies. Owns the TMDB→domain mapping and the
/// TMDB↔OMDb rating bridge that legacy left inside EnhancedHomeScreenImpl.
/// Consumers only ever see domain [Movie]s.
class MovieRepository {
  MovieRepository({
    required TmdbApi tmdbApi,
    required OmdbApi omdbApi,
    required Box<String> cacheBox,
  }) : _tmdbApi = tmdbApi,
       _omdbApi = omdbApi,
       _cacheBox = cacheBox;

  final TmdbApi _tmdbApi;
  final OmdbApi _omdbApi;
  final Box<String> _cacheBox;

  /// Median feature length; used when TMDB details has no runtime so the
  /// engine's runtime score isn't skewed to the maximum by a zero.
  static const int _defaultRuntime = 120;

  /// Inverse of legacy MoodDetectionService.getMoodFilters: that mapped
  /// moods to preferred genres; this tags genres with the moods they serve,
  /// so the engine can score live TMDB movies (legacy only ever scored the
  /// 5-movie sample DB).
  static const Map<Genre, List<MoodTag>> _genreMoodTags = {
    Genre.comedy: [MoodTag.funny, MoodTag.uplifting],
    Genre.romance: [MoodTag.romantic, MoodTag.uplifting],
    Genre.action: [MoodTag.exciting, MoodTag.intense],
    Genre.adventure: [MoodTag.exciting, MoodTag.inspiring],
    Genre.scifi: [MoodTag.thoughtProvoking, MoodTag.exciting],
    Genre.fantasy: [MoodTag.exciting, MoodTag.uplifting],
    Genre.animation: [MoodTag.funny, MoodTag.uplifting],
    Genre.mystery: [MoodTag.thoughtProvoking, MoodTag.intense],
    Genre.thriller: [MoodTag.intense, MoodTag.exciting],
    Genre.drama: [MoodTag.thoughtProvoking, MoodTag.relaxing],
    Genre.documentary: [MoodTag.thoughtProvoking, MoodTag.inspiring],
    Genre.horror: [MoodTag.scary, MoodTag.intense],
  };

  /// Today's recommendation pool: TMDB popular page mapped to domain movies,
  /// runtimes and trailers filled from the details endpoint, cached in hive
  /// for the day. [language] is an ISO-639-1 original-language filter; [era] is
  /// the transient Era Selector window. Both are part of the cache key so
  /// switching language or era refreshes the pool rather than serving a stale
  /// one.
  Future<List<Movie>> getDailyCandidates({
    DateTime? now,
    String language = 'en',
    EraFilter? era,
  }) async {
    final eraKey = (era == null || era.isAll)
        ? 'all'
        : '${era.minYear ?? ''}-${era.maxYear ?? ''}';
    final cacheKey =
        'candidates_${language}_${eraKey}_${_dateKey(now ?? DateTime.now())}';

    final cached = _cacheBox.get(cacheKey);
    if (cached != null) {
      final decoded = jsonDecode(cached) as List;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(Movie.fromJson)
          .toList();
    }

    final dtos = await _tmdbApi.fetchPopular(
      originalLanguage: language,
      minYear: era?.minYear,
      maxYear: era?.maxYear,
    );
    final movies = <Movie>[];

    for (final dto in dtos) {
      final genres = dto.genreIds
          .map(TmdbApi.genreFromId)
          .whereType<Genre>()
          .toSet()
          .toList();
      // No mapped genre means the engine can't filter or score it; skip.
      if (genres.isEmpty) continue;

      int? runtime;
      String? trailerUrl;
      String? tagline;
      var director = '';
      var actors = const <String>[];
      var writers = const <String>[];
      var producers = const <String>[];
      try {
        final details = await _tmdbApi.fetchDetails(dto.id);
        runtime = details.runtime;
        trailerUrl = details.trailerUrl;
        tagline = details.tagline;
        director = details.director;
        actors = details.cast;
        writers = details.writers;
        producers = details.producers;
      } on TmdbApiException {
        runtime = null; // Candidate is still usable with the default.
      }

      movies.add(
        Movie(
          id: 'tmdb-${dto.id}',
          title: dto.title,
          genres: genres,
          // TMDB community score as the baseline; the chosen pick gets the
          // real IMDb figure via enrichWithImdbRating, mirroring legacy
          // display priority (IMDb first, TMDB fallback).
          imdbRating: dto.voteAverage,
          releaseYear: _releaseYear(dto.releaseDate),
          runtime: runtime ?? _defaultRuntime,
          synopsis: dto.overview,
          director: director,
          actors: actors,
          writers: writers,
          producers: producers,
          tagline: tagline,
          moodTags: {
            for (final genre in genres) ..._genreMoodTags[genre]!,
          }.toList(),
          trailerUrl: trailerUrl,
          posterUrl: TmdbApi.posterUrl(dto.posterPath),
          backdropUrl: TmdbApi.backdropUrl(dto.backdropPath),
        ),
      );
    }

    await _cacheBox.put(
      cacheKey,
      jsonEncode([for (final m in movies) m.toJson()]),
    );
    return movies;
  }

  /// OMDb bridge for the selected pick only (keeps API usage low, as legacy
  /// did): swaps in the real IMDb rating and folds in the awards blurb.
  /// Returns the movie unchanged when OMDb has nothing or errors.
  Future<Movie> enrichWithImdbRating(Movie movie) async {
    try {
      final omdb = await _omdbApi.fetchEnrichment(
        movie.title,
        year: movie.releaseYear > 0 ? movie.releaseYear : null,
      );
      return movie.copyWith(
        imdbRating: omdb.imdbRating ?? movie.imdbRating,
        awards: omdb.awards ?? movie.awards,
      );
    } on OmdbApiException {
      return movie;
    }
  }

  static int _releaseYear(String releaseDate) {
    if (releaseDate.length < 4) return 0;
    return int.tryParse(releaseDate.substring(0, 4)) ?? 0;
  }

  static String _dateKey(DateTime date) =>
      date.toIso8601String().split('T').first;
}
