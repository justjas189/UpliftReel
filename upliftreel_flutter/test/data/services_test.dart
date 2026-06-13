import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:upliftreel/data/services/omdb_api.dart';
import 'package:upliftreel/data/services/tmdb_api.dart';
import 'package:upliftreel/domain/models/movie.dart';

import 'fake_http_adapter.dart';

TmdbApi tmdbWith(FakeHttpAdapter adapter) {
  final dio = Dio()..httpClientAdapter = adapter;
  return TmdbApi(dio: dio, accessToken: 'test-token');
}

OmdbApi omdbWith(FakeHttpAdapter adapter) {
  final dio = Dio()..httpClientAdapter = adapter;
  return OmdbApi(dio: dio, apiKey: 'test-key');
}

void main() {
  group('TmdbApi', () {
    test('parses popular results and sends bearer auth', () async {
      late RequestOptions seen;
      final adapter = FakeHttpAdapter((options) {
        seen = options;
        return jsonResponse(
          '{"results": [{"id": 27205, "title": "Inception", '
          '"overview": "Dreams.", "poster_path": "/p.jpg", '
          '"release_date": "2010-07-15", "vote_average": 8.4, '
          '"genre_ids": [878, 53]}]}',
        );
      });

      final movies = await tmdbWith(adapter).fetchPopular();

      expect(seen.headers['Authorization'], 'Bearer test-token');
      expect(seen.uri.path, endsWith('/movie/popular'));
      expect(movies, hasLength(1));
      expect(movies.first.title, 'Inception');
      expect(movies.first.genreIds, [878, 53]);
    });

    test(
      'non-en language goes through discover with original language',
      () async {
        late RequestOptions seen;
        final adapter = FakeHttpAdapter((options) {
          seen = options;
          return jsonResponse('{"results": []}');
        });

        await tmdbWith(adapter).fetchPopular(originalLanguage: 'ja');

        expect(seen.uri.path, endsWith('/discover/movie'));
        expect(seen.uri.queryParameters['with_original_language'], 'ja');
        expect(seen.uri.queryParameters['sort_by'], 'popularity.desc');
      },
    );

    test('fetchDetails parses runtime and prefers official trailer', () async {
      late RequestOptions seen;
      final adapter = FakeHttpAdapter((options) {
        seen = options;
        return jsonResponse(
          '{"runtime": 148, "videos": {"results": ['
          '{"site": "YouTube", "type": "Teaser", "key": "tease"},'
          '{"site": "YouTube", "type": "Trailer", "key": "fanCut", '
          '"official": false},'
          '{"site": "YouTube", "type": "Trailer", "key": "real1", '
          '"official": true},'
          '{"site": "Vimeo", "type": "Trailer", "key": "vimeo1", '
          '"official": true}'
          ']}}',
        );
      });

      final details = await tmdbWith(adapter).fetchDetails(27205);

      expect(seen.uri.queryParameters['append_to_response'], 'videos');
      expect(details.runtime, 148);
      expect(details.trailerUrl, 'https://www.youtube.com/watch?v=real1');
    });

    test(
      'fetchDetails falls back to teaser, null when no youtube videos',
      () async {
        final teaserOnly = FakeHttpAdapter(
          (_) => jsonResponse(
            '{"runtime": 90, "videos": {"results": ['
            '{"site": "YouTube", "type": "Teaser", "key": "tz"}]}}',
          ),
        );
        final teased = await tmdbWith(teaserOnly).fetchDetails(1);
        expect(teased.trailerUrl, 'https://www.youtube.com/watch?v=tz');

        final none = FakeHttpAdapter((_) => jsonResponse('{"runtime": 90}'));
        final empty = await tmdbWith(none).fetchDetails(1);
        expect(empty.runtime, 90);
        expect(empty.trailerUrl, isNull);
      },
    );

    test('missing token throws without any request', () async {
      final adapter = FakeHttpAdapter((_) => jsonResponse('{}'));
      final api = TmdbApi(
        dio: Dio()..httpClientAdapter = adapter,
        accessToken: '',
      );

      await expectLater(api.fetchPopular(), throwsA(isA<TmdbApiException>()));
      expect(adapter.requests, isEmpty);
    });

    test('http error surfaces as TmdbApiException with status', () async {
      final adapter = FakeHttpAdapter(
        (_) => jsonResponse('{"status_message": "denied"}', statusCode: 401),
      );

      await expectLater(
        tmdbWith(adapter).fetchPopular(),
        throwsA(
          isA<TmdbApiException>().having(
            (e) => e.statusCode,
            'statusCode',
            401,
          ),
        ),
      );
    });

    test('genre map folds crime into thriller, skips unmapped ids', () {
      expect(TmdbApi.genreFromId(80), Genre.thriller);
      expect(TmdbApi.genreFromId(35), Genre.comedy);
      expect(TmdbApi.genreFromId(10752), isNull); // war
    });

    test('image urls are null-safe', () {
      expect(
        TmdbApi.posterUrl('/x.jpg'),
        'https://image.tmdb.org/t/p/w500/x.jpg',
      );
      expect(TmdbApi.posterUrl(null), isNull);
    });
  });

  group('OmdbApi', () {
    test('fetches over https and parses rating', () async {
      late RequestOptions seen;
      final adapter = FakeHttpAdapter((options) {
        seen = options;
        return jsonResponse('{"Response": "True", "imdbRating": "8.8"}');
      });

      final rating = await omdbWith(
        adapter,
      ).fetchImdbRating('Inception', year: 2010);

      expect(seen.uri.scheme, 'https');
      expect(seen.uri.queryParameters['t'], 'Inception');
      expect(seen.uri.queryParameters['y'], '2010');
      expect(rating, 8.8);
    });

    test('returns null on Response False and on N/A', () async {
      final notFound = FakeHttpAdapter(
        (_) => jsonResponse('{"Response": "False", "Error": "not found"}'),
      );
      expect(await omdbWith(notFound).fetchImdbRating('X'), isNull);

      final na = FakeHttpAdapter(
        (_) => jsonResponse('{"Response": "True", "imdbRating": "N/A"}'),
      );
      expect(await omdbWith(na).fetchImdbRating('X'), isNull);
    });
  });
}
