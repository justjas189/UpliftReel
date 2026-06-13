import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upliftreel/data/services/omdb_api.dart';
import 'package:upliftreel/data/services/tmdb_api.dart';
import 'package:upliftreel/domain/models/mood.dart';
import 'package:upliftreel/state/mood_controller.dart';
import 'package:upliftreel/state/preferences_controller.dart';
import 'package:upliftreel/state/providers.dart';
import 'package:upliftreel/state/recommendation_controller.dart';
import 'package:upliftreel/ui/core/theme/stitch_mood_theme.dart';

import '../data/fake_http_adapter.dart';

const _popularJson = '''
{"results": [
  {"id": 1, "title": "Front Runner", "overview": "A.",
   "release_date": "2020-05-01", "vote_average": 7.5,
   "genre_ids": [35, 18]},
  {"id": 3, "title": "Backup Pick", "overview": "B.",
   "release_date": "2021-03-01", "vote_average": 8.0,
   "genre_ids": [35]}
]}
''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late Box<String> movieCacheBox;
  late Box<String> historyBox;
  late Box<String> moodBox;
  late SharedPreferences sharedPreferences;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('state_test');
    Hive.init(tempDir.path);
    movieCacheBox = await Hive.openBox<String>('movie_cache');
    historyBox = await Hive.openBox<String>('history');
    moodBox = await Hive.openBox<String>('mood_log');
    SharedPreferences.setMockInitialValues({});
    sharedPreferences = await SharedPreferences.getInstance();
  });

  tearDown(() async {
    await movieCacheBox.deleteFromDisk();
    await historyBox.deleteFromDisk();
    await moodBox.deleteFromDisk();
    tempDir.deleteSync(recursive: true);
  });

  ProviderContainer makeContainer() {
    final tmdbAdapter = FakeHttpAdapter((options) {
      if (options.uri.path.endsWith('/movie/popular')) {
        return jsonResponse(_popularJson);
      }
      if (options.uri.path.endsWith('/movie/1')) {
        return jsonResponse('{"runtime": 110}');
      }
      if (options.uri.path.endsWith('/movie/3')) {
        return jsonResponse('{"runtime": 95}');
      }
      return jsonResponse('{}', statusCode: 404);
    });
    final omdbAdapter = FakeHttpAdapter(
      (_) => jsonResponse('{"Response": "True", "imdbRating": "8.3"}'),
    );

    final container = ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      movieCacheBoxProvider.overrideWithValue(movieCacheBox),
      historyBoxProvider.overrideWithValue(historyBox),
      moodBoxProvider.overrideWithValue(moodBox),
      tmdbApiProvider.overrideWithValue(TmdbApi(
        dio: Dio()..httpClientAdapter = tmdbAdapter,
        accessToken: 'token',
      )),
      omdbApiProvider.overrideWithValue(OmdbApi(
        dio: Dio()..httpClientAdapter = omdbAdapter,
        apiKey: 'key',
      )),
    ]);
    addTearDown(container.dispose);
    return container;
  }

  test('generate: candidates → engine → OMDb enrichment → persistence',
      () async {
    final container = makeContainer();
    final controller =
        container.read(recommendationControllerProvider.notifier);

    expect(
      await container.read(recommendationControllerProvider.future),
      isNull,
    );

    await controller.generate();

    final result =
        container.read(recommendationControllerProvider).requireValue!;
    // Front Runner wins on genre coverage (2/3 selected genres vs 1/3).
    expect(result.movie.id, 'tmdb-1');
    expect(result.isAlternative, isFalse);
    expect(result.movie.imdbRating, 8.3); // OMDb figure, not TMDB 7.5.

    final history = container.read(historyRepositoryProvider);
    expect(history.recommendationIds(), ['tmdb-1']);
    expect(history.todaysPick()!.movie.id, 'tmdb-1');
  });

  test('new container restores persisted pick without regenerating',
      () async {
    final first = makeContainer();
    await first
        .read(recommendationControllerProvider.notifier)
        .generate();

    final second = makeContainer();
    final restored =
        await second.read(recommendationControllerProvider.future);

    expect(restored!.movie.id, 'tmdb-1');
  });

  test('markWatched records the current pick', () async {
    final container = makeContainer();
    final controller =
        container.read(recommendationControllerProvider.notifier);

    await controller.generate();
    await controller.markWatched();

    expect(
      container.read(historyRepositoryProvider).watchedIds(),
      ['tmdb-1'],
    );
  });

  test('skip excludes the pick and re-rolls to the runner-up', () async {
    final container = makeContainer();
    final controller =
        container.read(recommendationControllerProvider.notifier);

    await controller.generate();
    await controller.skip();

    final preferences =
        await container.read(preferencesControllerProvider.future);
    expect(preferences.excludedMovieIds, ['tmdb-1']);

    final result =
        container.read(recommendationControllerProvider).requireValue!;
    expect(result.movie.id, 'tmdb-3');
  });

  test('unmatchable mood degrades to an alternative, not a failure',
      () async {
    final container = makeContainer();

    // Suspense wants intense/scary/exciting; comedy/drama candidates have
    // none, so the mood filter empties and edge-case strategy 1 kicks in.
    container.read(moodControllerProvider.notifier).select(
          const MoodInput(mood: Mood.suspense, intensity: 7, seriousness: 7),
        );
    await container.read(recommendationControllerProvider.notifier).generate();

    final result =
        container.read(recommendationControllerProvider).requireValue!;
    expect(result.isAlternative, isTrue);
  });

  test('select drives ambience; only commit writes the mood log', () async {
    final container = makeContainer();
    final controller = container.read(moodControllerProvider.notifier);

    expect(container.read(stitchMoodProvider), StitchMood.neutral);

    controller.select(
      const MoodInput(mood: Mood.relaxed, intensity: 4, seriousness: 3),
    );

    expect(container.read(stitchMoodProvider), StitchMood.relaxed);
    expect(container.read(moodRepositoryProvider).entries(), isEmpty);

    await controller.commit();
    expect(
      container.read(moodRepositoryProvider).entries().single.input.mood,
      Mood.relaxed,
    );

    controller.clear();
    expect(container.read(stitchMoodProvider), StitchMood.neutral);
  });

  test('preferences save applies validation clamps', () async {
    final container = makeContainer();
    final controller =
        container.read(preferencesControllerProvider.notifier);

    final loaded =
        await container.read(preferencesControllerProvider.future);
    await controller.save(loaded.copyWith(minRating: 0, maxRuntime: 999));

    final saved = container.read(preferencesControllerProvider).requireValue;
    expect(saved.minRating, 1.0);
    expect(saved.maxRuntime, 300);
  });
}
