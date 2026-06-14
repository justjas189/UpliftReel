import 'package:dio/dio.dart';

import '../../domain/models/movie.dart';
import '../models/tmdb_movie_dto.dart';
import 'api_config.dart';

class TmdbApiException implements Exception {
  const TmdbApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'TmdbApiException($statusCode): $message';
}

/// TMDB v3 client. Endpoints and auth scheme ported from legacy tmdb.ts.
class TmdbApi {
  TmdbApi({Dio? dio, String accessToken = ApiConfig.tmdbAccessToken})
    : _accessToken = accessToken,
      _dio = dio ?? Dio() {
    _dio.options = _dio.options.copyWith(
      baseUrl: 'https://api.themoviedb.org/3',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    );
  }

  final Dio _dio;
  final String _accessToken;

  static const String _imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  static const String _backdropBaseUrl = 'https://image.tmdb.org/t/p/w780';

  /// Legacy display map (EnhancedHomeScreenImpl) re-pointed at the domain
  /// enum. TMDB crime (80) folds into thriller; family/history/music/
  /// tv-movie/war/western have no domain equivalent and return null.
  static const Map<int, Genre> _genreById = {
    28: Genre.action,
    12: Genre.adventure,
    16: Genre.animation,
    35: Genre.comedy,
    80: Genre.thriller,
    99: Genre.documentary,
    18: Genre.drama,
    14: Genre.fantasy,
    27: Genre.horror,
    9648: Genre.mystery,
    10749: Genre.romance,
    878: Genre.scifi,
    53: Genre.thriller,
  };

  static Genre? genreFromId(int id) => _genreById[id];

  static String? posterUrl(String? path) =>
      path == null ? null : '$_imageBaseUrl$path';

  static String? backdropUrl(String? path) =>
      path == null ? null : '$_backdropBaseUrl$path';

  /// English with no era constraint keeps the legacy /movie/popular endpoint
  /// (behavior parity). Any other preferred language — or an active Era
  /// Selector ([minYear]/[maxYear], inclusive) — goes through /discover/movie,
  /// sorted by popularity to mirror it, with `with_original_language` and
  /// `primary_release_date.gte/lte` applied so the date window is filtered
  /// server-side before the candidate pool is even built.
  Future<List<TmdbMovieDto>> fetchPopular({
    int page = 1,
    String originalLanguage = 'en',
    int? minYear,
    int? maxYear,
  }) async {
    final hasEra = minYear != null || maxYear != null;
    final Map<String, dynamic> data;
    if (originalLanguage == 'en' && !hasEra) {
      data = await _get('/movie/popular', {
        'language': 'en-US',
        'page': '$page',
      });
    } else {
      data = await _get('/discover/movie', {
        'language': 'en-US',
        'page': '$page',
        'sort_by': 'popularity.desc',
        'include_adult': 'false',
        'with_original_language': originalLanguage,
        if (minYear != null) 'primary_release_date.gte': '$minYear-01-01',
        if (maxYear != null) 'primary_release_date.lte': '$maxYear-12-31',
      });
    }

    final results = data['results'];
    if (results is! List) return const [];
    return results
        .whereType<Map<String, dynamic>>()
        .map(TmdbMovieDto.fromJson)
        .toList();
  }

  /// Runtime, videos, tagline, and credits live only on the details endpoint,
  /// not in list results. `append_to_response=videos,credits` folds them all
  /// into the single per-candidate request we already make — no extra calls.
  Future<
    ({
      int? runtime,
      String? trailerUrl,
      String? tagline,
      String director,
      List<String> cast,
      List<String> writers,
      List<String> producers,
    })
  >
  fetchDetails(int movieId) async {
    final data = await _get('/movie/$movieId', const {
      'append_to_response': 'videos,credits',
    });
    final runtime = data['runtime'];
    final tagline = data['tagline'];
    final credits = data['credits'];
    return (
      runtime: runtime is int && runtime > 0 ? runtime : null,
      trailerUrl: _trailerUrlFrom(data['videos']),
      tagline: tagline is String && tagline.isNotEmpty ? tagline : null,
      director: _directorFrom(credits),
      cast: _castFrom(credits),
      writers: _crewByJobs(credits, const {
        'Writer',
        'Screenplay',
        'Story',
        'Author',
      }),
      producers: _crewByJobs(credits, const {'Producer'}),
    );
  }

  /// Top billed names; TMDB returns `cast` pre-sorted by billing order.
  static const int _maxCast = 8;

  /// Cap per crew role so a sprawling producer list doesn't dominate the view.
  static const int _maxCrewPerRole = 3;

  static List<Map<String, dynamic>> _crewList(Object? credits) {
    if (credits is! Map<String, dynamic>) return const [];
    final crew = credits['crew'];
    return crew is List
        ? crew.whereType<Map<String, dynamic>>().toList()
        : const [];
  }

  static String _directorFrom(Object? credits) {
    for (final member in _crewList(credits)) {
      if (member['job'] == 'Director' && member['name'] is String) {
        return member['name'] as String;
      }
    }
    return '';
  }

  static List<String> _crewByJobs(Object? credits, Set<String> jobs) {
    final names = <String>[];
    for (final member in _crewList(credits)) {
      if (jobs.contains(member['job']) && member['name'] is String) {
        final name = member['name'] as String;
        if (!names.contains(name)) names.add(name);
        if (names.length >= _maxCrewPerRole) break;
      }
    }
    return names;
  }

  static List<String> _castFrom(Object? credits) {
    if (credits is! Map<String, dynamic>) return const [];
    final cast = credits['cast'];
    if (cast is! List) return const [];
    return cast
        .whereType<Map<String, dynamic>>()
        .where((member) => member['name'] is String)
        .take(_maxCast)
        .map((member) => member['name'] as String)
        .toList();
  }

  /// Best YouTube key from a /movie/{id}/videos payload: official trailer
  /// first, then any trailer, then any teaser.
  static String? _trailerUrlFrom(Object? videos) {
    if (videos is! Map<String, dynamic>) return null;
    final results = videos['results'];
    if (results is! List) return null;

    final youtube = results
        .whereType<Map<String, dynamic>>()
        .where((v) => v['site'] == 'YouTube' && v['key'] is String)
        .toList();

    bool isTrailer(Map<String, dynamic> v) => v['type'] == 'Trailer';
    final pick =
        youtube
            .where((v) => isTrailer(v) && v['official'] == true)
            .firstOrNull ??
        youtube.where(isTrailer).firstOrNull ??
        youtube.where((v) => v['type'] == 'Teaser').firstOrNull;

    final key = pick?['key'];
    return key is String ? 'https://www.youtube.com/watch?v=$key' : null;
  }

  Future<Map<String, dynamic>> _get(
    String path,
    Map<String, String> query,
  ) async {
    if (_accessToken.isEmpty) {
      throw const TmdbApiException(
        'Missing TMDB access token. '
        'Pass --dart-define=TMDB_ACCESS_TOKEN=<token>.',
      );
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: query,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $_accessToken',
          },
        ),
      );
      return response.data ?? const {};
    } on DioException catch (e) {
      throw TmdbApiException(
        e.response?.data?.toString() ?? e.message ?? 'TMDB request failed',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
