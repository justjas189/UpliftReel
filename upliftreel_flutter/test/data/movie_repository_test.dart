import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:upliftreel/data/repositories/movie_repository.dart';
import 'package:upliftreel/data/services/omdb_api.dart';
import 'package:upliftreel/data/services/tmdb_api.dart';
import 'package:upliftreel/domain/models/movie.dart';

import 'fake_http_adapter.dart';

const _popularJson = '''
{"results": [
  {"id": 1, "title": "Mapped", "overview": "A film.",
   "poster_path": "/p.jpg", "backdrop_path": "/b.jpg",
   "release_date": "2020-05-01", "vote_average": 7.5,
   "genre_ids": [35, 18]},
  {"id": 2, "title": "Unmappable", "release_date": "2021-01-01",
   "vote_average": 9.0, "genre_ids": [10770]}
]}
''';

void main() {
  late Directory tempDir;
  late Box<String> box;
  late FakeHttpAdapter tmdbAdapter;
  late FakeHttpAdapter omdbAdapter;
  late MovieRepository repository;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('movie_repo_test');
    Hive.init(tempDir.path);
    box = await Hive.openBox<String>('movie_cache');

    tmdbAdapter = FakeHttpAdapter((options) {
      if (options.uri.path.endsWith('/movie/popular')) {
        return jsonResponse(_popularJson);
      }
      if (options.uri.path.endsWith('/movie/1')) {
        return jsonResponse(
          '{"runtime": 110, "videos": {"results": ['
          '{"site": "YouTube", "type": "Trailer", "key": "abc123", '
          '"official": true}]}}',
        );
      }
      if (options.uri.path.endsWith('/discover/movie')) {
        return jsonResponse(_popularJson);
      }
      return jsonResponse('{"status_message": "missing"}', statusCode: 404);
    });
    omdbAdapter = FakeHttpAdapter(
      (_) => jsonResponse('{"Response": "True", "imdbRating": "8.3"}'),
    );

    repository = MovieRepository(
      tmdbApi: TmdbApi(
        dio: Dio()..httpClientAdapter = tmdbAdapter,
        accessToken: 'token',
      ),
      omdbApi: OmdbApi(
        dio: Dio()..httpClientAdapter = omdbAdapter,
        apiKey: 'key',
      ),
      cacheBox: box,
    );
  });

  tearDown(() async {
    await box.deleteFromDisk();
    tempDir.deleteSync(recursive: true);
  });

  test('maps TMDB dto to domain Movie with inferred mood tags', () async {
    final movies = await repository.getDailyCandidates();

    expect(movies, hasLength(1)); // Unmappable genre (TV movie) skipped.
    final movie = movies.single;
    expect(movie.id, 'tmdb-1');
    expect(movie.genres, [Genre.comedy, Genre.drama]);
    expect(movie.imdbRating, 7.5);
    expect(movie.releaseYear, 2020);
    expect(movie.runtime, 110);
    expect(movie.trailerUrl, 'https://www.youtube.com/watch?v=abc123');
    expect(movie.posterUrl, 'https://image.tmdb.org/t/p/w500/p.jpg');
    expect(movie.backdropUrl, 'https://image.tmdb.org/t/p/w780/b.jpg');
    expect(
      movie.moodTags,
      containsAll([
        MoodTag.funny,
        MoodTag.uplifting,
        MoodTag.thoughtProvoking,
        MoodTag.relaxing,
      ]),
    );
  });

  test('caches candidates for the day — no second network hit', () async {
    await repository.getDailyCandidates();
    final callsAfterFirst = tmdbAdapter.requests.length;

    final second = await repository.getDailyCandidates();

    expect(tmdbAdapter.requests.length, callsAfterFirst);
    expect(second.single.id, 'tmdb-1');
  });

  test('different day misses cache', () async {
    await repository.getDailyCandidates(now: DateTime(2026, 6, 12));
    final callsAfterFirst = tmdbAdapter.requests.length;

    await repository.getDailyCandidates(now: DateTime(2026, 6, 13));

    expect(tmdbAdapter.requests.length, greaterThan(callsAfterFirst));
  });

  test('language is part of the cache key and routed to discover', () async {
    await repository.getDailyCandidates();
    final callsAfterEn = tmdbAdapter.requests.length;

    await repository.getDailyCandidates(language: 'ja');

    expect(tmdbAdapter.requests.length, greaterThan(callsAfterEn));
    final discover = tmdbAdapter.requests.firstWhere(
      (r) => r.path.endsWith('/discover/movie'),
    );
    expect(discover.queryParameters['with_original_language'], 'ja');

    // Second ja call hits the ja cache.
    final callsAfterJa = tmdbAdapter.requests.length;
    await repository.getDailyCandidates(language: 'ja');
    expect(tmdbAdapter.requests.length, callsAfterJa);
  });

  test('enrichWithImdbRating swaps in the OMDb figure', () async {
    final movies = await repository.getDailyCandidates();

    final enriched = await repository.enrichWithImdbRating(movies.single);

    expect(enriched.imdbRating, 8.3);
    expect(omdbAdapter.requests.single.queryParameters['t'], 'Mapped');
  });

  test('enrichWithImdbRating returns original on OMDb failure', () async {
    final failing = MovieRepository(
      tmdbApi: TmdbApi(
        dio: Dio()..httpClientAdapter = tmdbAdapter,
        accessToken: 'token',
      ),
      omdbApi: OmdbApi(
        dio: Dio()
          ..httpClientAdapter = FakeHttpAdapter(
            (_) => jsonResponse('{}', statusCode: 500),
          ),
        apiKey: 'key',
      ),
      cacheBox: box,
    );

    final movies = await failing.getDailyCandidates();
    final result = await failing.enrichWithImdbRating(movies.single);

    expect(result.imdbRating, 7.5);
  });
}
