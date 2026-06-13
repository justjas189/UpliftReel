import 'package:dio/dio.dart';

import 'api_config.dart';

class OmdbApiException implements Exception {
  const OmdbApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'OmdbApiException($statusCode): $message';
}

/// OMDb rating lookup, ported from legacy omdb.ts.
/// Legacy used http://; this client is https-only.
class OmdbApi {
  OmdbApi({Dio? dio, String apiKey = ApiConfig.omdbApiKey})
      : _apiKey = apiKey,
        _dio = dio ?? Dio() {
    _dio.options = _dio.options.copyWith(
      baseUrl: 'https://www.omdbapi.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    );
  }

  final Dio _dio;
  final String _apiKey;

  /// Returns the IMDb rating for an exact title (+ optional year) match,
  /// or null when OMDb has no answer ("Response": "False" or "N/A").
  Future<double?> fetchImdbRating(String title, {int? year}) async {
    if (_apiKey.isEmpty) {
      throw const OmdbApiException(
        'Missing OMDb API key. Pass --dart-define=OMDB_API_KEY=<key>.',
      );
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/',
        queryParameters: {
          'apikey': _apiKey,
          't': title,
          if (year != null) 'y': '$year',
        },
      );

      final data = response.data ?? const {};
      if (data['Response'] == 'False') return null;

      final rating = data['imdbRating'];
      if (rating is! String || rating == 'N/A') return null;
      return double.tryParse(rating);
    } on DioException catch (e) {
      throw OmdbApiException(
        e.message ?? 'OMDb request failed',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
