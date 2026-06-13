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

  /// English keeps the legacy /movie/popular endpoint (behavior parity);
  /// any other preferred language goes through /discover/movie with
  /// `with_original_language`, sorted by popularity to mirror it.
  Future<List<TmdbMovieDto>> fetchPopular({
    int page = 1,
    String originalLanguage = 'en',
  }) async {
    final Map<String, dynamic> data;
    if (originalLanguage == 'en') {
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
      });
    }

    final results = data['results'];
    if (results is! List) return const [];
    return results
        .whereType<Map<String, dynamic>>()
        .map(TmdbMovieDto.fromJson)
        .toList();
  }

  /// Runtime and videos live only on the details endpoint, not in list
  /// results. `append_to_response=videos` folds both into one request.
  Future<({int? runtime, String? trailerUrl})> fetchDetails(int movieId) async {
    final data = await _get('/movie/$movieId', const {
      'append_to_response': 'videos',
    });
    final runtime = data['runtime'];
    return (
      runtime: runtime is int && runtime > 0 ? runtime : null,
      trailerUrl: _trailerUrlFrom(data['videos']),
    );
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
