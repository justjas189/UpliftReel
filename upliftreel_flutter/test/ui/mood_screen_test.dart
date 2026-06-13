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
import 'package:upliftreel/domain/models/mood.dart';
import 'package:upliftreel/main.dart';
import 'package:upliftreel/state/mood_controller.dart';
import 'package:upliftreel/state/providers.dart';
import 'package:upliftreel/ui/core/theme/stitch_theme.dart';

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
    tempDir = Directory.systemTemp.createTempSync('mood_test');
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

  Future<void> openMoodTab(WidgetTester tester) async {
    await tester.pumpWidget(makeApp());
    await settle(tester);
    await tester.tap(find.text('Mood'));
    await settle(tester);
  }

  // Anchor on the nav bar: list content scrolls out of the viewport and
  // gets disposed, but the shell chrome is always present.
  ProviderContainer containerOf(WidgetTester tester) {
    return ProviderScope.containerOf(
      tester.element(find.byType(NavigationBar)),
      listen: false,
    );
  }

  testWidgets('renders all 8 mood cards with genre hints and suggestions',
      (tester) async {
    await openMoodTab(tester);

    for (final mood in Mood.values) {
      expect(find.text(mood.label), findsAtLeastNWidgets(1));
    }
    expect(find.text('Comedy, Feel-Good'), findsOneWidget);
    expect(find.text("TONIGHT'S SUGGESTIONS"), findsOneWidget);
    expect(find.text('ENERGY'), findsOneWidget);
    expect(find.text('TONE'), findsOneWidget);
  });

  testWidgets('selecting a mood shifts ambience without logging',
      (tester) async {
    await openMoodTab(tester);

    await tester.ensureVisible(find.text('Suspense'));
    await tester.tap(find.text('Suspense'));
    await settle(tester);

    final context = tester.element(find.byType(NavigationBar));
    expect(
      StitchMoodTheme.of(context).accent,
      StitchMoodTheme.fromMood(StitchMood.suspense).accent,
    );

    final container = containerOf(tester);
    expect(container.read(moodRepositoryProvider).entries(), isEmpty);
  });

  testWidgets('energy preset updates intensity on the selection',
      (tester) async {
    await openMoodTab(tester);

    await tester.ensureVisible(find.text('Relaxed'));
    await tester.tap(find.text('Relaxed'));
    await settle(tester);
    await tester.ensureVisible(find.text('High Energy'));
    await tester.pump();
    await tester.tap(find.text('High Energy'));
    await settle(tester);

    final input = containerOf(tester).read(moodControllerProvider);
    expect(input!.mood, Mood.relaxed);
    expect(input.intensity, 9);
  });

  testWidgets('submit commits mood, generates, and lands on Home',
      (tester) async {
    await openMoodTab(tester);

    await tester.ensureVisible(find.text('Happy'));
    await tester.tap(find.text('Happy'));
    await settle(tester);

    final container = containerOf(tester);

    await tester.ensureVisible(find.text('Find my movie'));
    await tester.pump();
    await tester.tap(find.text('Find my movie'));
    await settle(tester);

    expect(find.text('Quiet Comedy'), findsOneWidget);
    expect(find.textContaining('% MATCH'), findsOneWidget);
    expect(
      container.read(moodRepositoryProvider).entries().single.input.mood,
      Mood.happy,
    );
  });
}
