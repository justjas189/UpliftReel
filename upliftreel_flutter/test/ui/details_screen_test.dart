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
import 'package:upliftreel/ui/router.dart';

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

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('details_test');
    Hive.init(tempDir.path);
    movieCacheBox = await Hive.openBox<String>(
      'movie_cache',
      bytes: Uint8List(0),
    );
    historyBox = await Hive.openBox<String>('history', bytes: Uint8List(0));
    moodBox = await Hive.openBox<String>('mood_log', bytes: Uint8List(0));
    SharedPreferences.setMockInitialValues({});
    sharedPreferences = await SharedPreferences.getInstance();
  });

  tearDown(() async {
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  Widget makeApp() {
    final tmdbAdapter = FakeHttpAdapter((options) {
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
        tmdbApiProvider.overrideWithValue(
          TmdbApi(
            dio: Dio()..httpClientAdapter = tmdbAdapter,
            accessToken: 'token',
          ),
        ),
        omdbApiProvider.overrideWithValue(
          OmdbApi(dio: Dio()..httpClientAdapter = omdbAdapter, apiKey: 'key'),
        ),
      ],
      child: const UpliftReelApp(),
    );
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
  }

  Future<void> openDetailsFromPick(WidgetTester tester) async {
    await tester.pumpWidget(makeApp());
    await settle(tester);
    await tester.tap(find.text('Generate recommendation'));
    await settle(tester);
    await tester.ensureVisible(find.text('Details'));
    await tester.pump();
    await tester.tap(find.text('Details'));
    await settle(tester);
  }

  testWidgets('shows title, synopsis, genres; no match card', (tester) async {
    await openDetailsFromPick(tester);

    expect(find.text('Mark as watched'), findsOneWidget);
    expect(find.text('Quiet Comedy'), findsWidgets);
    expect(find.text('A gentle film.'), findsWidgets);
    expect(find.text('Comedy'), findsWidgets);
    expect(find.text('Drama'), findsWidgets);
    // The "why this pick / match %" card was removed from Details.
    expect(find.textContaining('% MATCH'), findsNothing);
    // No credits in the TMDB pool — section hidden, not empty.
    expect(find.text('CAST & CREW'), findsNothing);
  });

  testWidgets('mark as watched persists across leave and return', (
    tester,
  ) async {
    await openDetailsFromPick(tester);

    await tester.ensureVisible(find.text('Mark as watched'));
    await tester.pump();
    await tester.tap(find.text('Mark as watched'));
    await settle(tester);

    expect(find.text('Added to your watched history.'), findsOneWidget);
    expect(find.text('Watched ✓'), findsOneWidget);

    // Leave and return — legacy forgot watched state here.
    await tester.tap(find.byIcon(Icons.arrow_back));
    await settle(tester);
    await tester.ensureVisible(find.text('Details'));
    await tester.pump();
    await tester.tap(find.text('Details'));
    await settle(tester);

    expect(find.text('Watched ✓'), findsOneWidget);
    expect(find.text('Mark as watched'), findsNothing);
  });

  testWidgets('direct navigation without extra shows not-found guard', (
    tester,
  ) async {
    await tester.pumpWidget(makeApp());
    await settle(tester);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
      listen: false,
    );
    container.read(routerProvider).push('/details');
    await settle(tester);

    expect(find.text('Movie not found'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);
  });
}
