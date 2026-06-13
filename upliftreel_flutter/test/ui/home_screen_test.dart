import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upliftreel/data/services/omdb_api.dart';
import 'package:upliftreel/data/services/tmdb_api.dart';
import 'package:upliftreel/main.dart';
import 'package:upliftreel/state/providers.dart';

import '../data/fake_http_adapter.dart';

const _popularJson = '''
{"results": [
  {"id": 9, "title": "Quiet Comedy", "overview": "A gentle film.",
   "release_date": "2020-05-01", "vote_average": 7.5,
   "genre_ids": [35, 18]}
]}
''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  late Directory tempDir;
  late Box<String> movieCacheBox;
  late Box<String> historyBox;
  late Box<String> moodBox;
  late SharedPreferences sharedPreferences;

  // Memory-backed boxes + IO in setUp: see Phase 4 FakeAsync deadlock note.
  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('home_test');
    Hive.init(tempDir.path);
    movieCacheBox =
        await Hive.openBox<String>('movie_cache', bytes: Uint8List(0));
    historyBox = await Hive.openBox<String>('history', bytes: Uint8List(0));
    moodBox = await Hive.openBox<String>('mood_log', bytes: Uint8List(0));
    SharedPreferences.setMockInitialValues({});
    sharedPreferences = await SharedPreferences.getInstance();
  });

  tearDown(() async {
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  Widget makeApp({bool failTmdb = false}) {
    final tmdbAdapter = FakeHttpAdapter((options) {
      if (failTmdb) return jsonResponse('{}', statusCode: 500);
      if (options.uri.path.endsWith('/movie/popular')) {
        return jsonResponse(_popularJson);
      }
      if (options.uri.path.endsWith('/movie/9')) {
        return jsonResponse('{"runtime": 110}');
      }
      return jsonResponse('{}', statusCode: 404);
    });
    final omdbAdapter = FakeHttpAdapter(
      (_) => jsonResponse('{"Response": "True", "imdbRating": "8.3"}'),
    );

    return ProviderScope(
      overrides: [
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
      ],
      child: const UpliftReelApp(),
    );
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('empty state shows legacy invitation copy', (tester) async {
    await tester.pumpWidget(makeApp());
    await settle(tester);

    expect(find.text('Need a lift?'), findsOneWidget);
    expect(
      find.text(
          'Tap below to generate your first personalized recommendation.'),
      findsOneWidget,
    );
    expect(find.text('Generate recommendation'), findsOneWidget);
    expect(find.text('Set a mood for sharper picks →'), findsOneWidget);
  });

  testWidgets('generate renders hero, match badge, and explanation card',
      (tester) async {
    await tester.pumpWidget(makeApp());
    await settle(tester);

    await tester.tap(find.text('Generate recommendation'));
    await settle(tester);

    expect(find.text('Quiet Comedy'), findsOneWidget);
    expect(find.textContaining('% MATCH'), findsOneWidget);
    expect(find.text('WHY THIS PICK'), findsOneWidget);
    // OMDb-enriched rating and details runtime, not TMDB fallbacks.
    expect(find.textContaining('1h 50m'), findsOneWidget);
    expect(find.textContaining('8.3'), findsWidgets);
  });

  testWidgets('watched flow confirms via snackbar', (tester) async {
    await tester.pumpWidget(makeApp());
    await settle(tester);
    await tester.tap(find.text('Generate recommendation'));
    await settle(tester);

    // scrollUntilVisible exits early: the button already "exists" inside the
    // ListView cache extent while still off-screen. ensureVisible scrolls
    // the render object into the viewport for real.
    await tester.ensureVisible(find.text('Watched it'));
    await tester.pump();
    await tester.tap(find.text('Watched it'));
    await settle(tester);

    expect(find.text('Saved to history'), findsOneWidget);
  });

  testWidgets('failed generate shows error card with retry', (tester) async {
    await tester.pumpWidget(makeApp(failTmdb: true));
    await settle(tester);

    await tester.tap(find.text('Generate recommendation'));
    await settle(tester);

    expect(
      find.text('Something went wrong fetching your pick.'),
      findsOneWidget,
    );
    expect(find.text('Try again'), findsOneWidget);
  });
}
