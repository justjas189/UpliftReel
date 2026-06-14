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
import 'package:upliftreel/state/recommendation_controller.dart';

import '../data/fake_http_adapter.dart';
import '../state/fake_auth_repository.dart';

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
    tempDir = Directory.systemTemp.createTempSync('history_test');
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

  Widget makeApp({FakeAuthRepository? authRepository}) {
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
        if (authRepository != null)
          authRepositoryProvider.overrideWithValue(authRepository),
      ],
      child: const UpliftReelApp(),
    );
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
  }

  ProviderContainer containerOf(WidgetTester tester) {
    return ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
      listen: false,
    );
  }

  Future<void> bootAndGenerate(WidgetTester tester) async {
    await tester.pumpWidget(makeApp());
    await settle(tester);
    await tester.tap(find.text('Generate recommendation'));
    await settle(tester);
  }

  // Header icons are ListView children: scrolling down disposes them, so
  // drag back to the top before tapping them.
  Future<void> scrollToTop(WidgetTester tester) async {
    await tester.drag(
      find.byType(Scrollable).hitTestable().first,
      const Offset(0, 800),
    );
    await tester.pump();
  }

  testWidgets('empty history shows the legacy invitation', (tester) async {
    await tester.pumpWidget(makeApp());
    await settle(tester);

    await tester.tap(find.byIcon(Icons.history));
    await settle(tester);

    expect(find.text('Nothing here yet'), findsOneWidget);
    expect(
      find.text('0 titles tracked, average match score 0'),
      findsOneWidget,
    );
  });

  testWidgets('generated pick appears with badge; watched filter follows', (
    tester,
  ) async {
    await bootAndGenerate(tester);

    await tester.tap(find.byIcon(Icons.history));
    await settle(tester);

    expect(find.text('Quiet Comedy'), findsOneWidget);
    expect(find.text('DAILY PICK'), findsOneWidget);
    expect(find.textContaining('% match'), findsOneWidget);

    await tester.tap(find.text('Watched'));
    await settle(tester);
    expect(find.text('Nothing here yet'), findsOneWidget);

    // Mark watched from home, return, re-check the filter.
    await tester.tap(find.byIcon(Icons.arrow_back));
    await settle(tester);
    await tester.ensureVisible(find.text('Watched it'));
    await tester.pump();
    await tester.tap(find.text('Watched it'));
    await settle(tester);

    await scrollToTop(tester);
    await tester.tap(find.byIcon(Icons.history));
    await settle(tester);
    await tester.tap(find.text('Watched'));
    await settle(tester);

    expect(find.text('Quiet Comedy'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets('history row opens details with the snapshot movie', (
    tester,
  ) async {
    await bootAndGenerate(tester);

    await tester.tap(find.byIcon(Icons.history));
    await settle(tester);
    await tester.tap(find.text('Quiet Comedy'));
    await settle(tester);

    // Bare-Movie navigation: details without a match card.
    expect(find.text('Mark as watched'), findsOneWidget);
    expect(find.text('WHY THIS PICK'), findsNothing);
  });

  testWidgets('profile surfaces stats and most common mood', (tester) async {
    await bootAndGenerate(tester);

    final container = containerOf(tester);
    container
        .read(moodControllerProvider.notifier)
        .select(
          const MoodInput(mood: Mood.happy, intensity: 5, seriousness: 5),
        );
    await container.read(moodControllerProvider.notifier).commit();

    await tester.ensureVisible(find.text('Watched it'));
    await tester.pump();
    await tester.tap(find.text('Watched it'));
    await settle(tester);

    await scrollToTop(tester);
    await tester.tap(find.byIcon(Icons.person_outline));
    await settle(tester);

    expect(find.text('PICKS'), findsOneWidget);
    expect(find.text('WATCHED'), findsOneWidget);
    expect(find.text('1'), findsNWidgets(2));
    expect(find.textContaining('Most common mood'), findsOneWidget);
    expect(find.textContaining('Happy'), findsOneWidget);
  });

  testWidgets('signed-out profile shows placeholder and opens the auth sheet', (
    tester,
  ) async {
    await tester.pumpWidget(makeApp());
    await settle(tester);

    await tester.tap(find.byIcon(Icons.person_outline));
    await settle(tester);

    expect(find.text('Uplift Reel Viewer'), findsOneWidget);
    expect(find.text('UR'), findsOneWidget);
    expect(find.text('Sign out'), findsNothing);

    await tester.tap(find.text('Sign in'));
    await settle(tester);

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });

  testWidgets('signed-in profile shows account identity and signs out', (
    tester,
  ) async {
    final authRepository = FakeAuthRepository(user: kFakeAuthUser);
    await tester.pumpWidget(makeApp(authRepository: authRepository));
    await settle(tester);

    await tester.tap(find.byIcon(Icons.person_outline));
    await settle(tester);

    expect(find.text('Jasper'), findsOneWidget);
    expect(find.text('jasper@example.com'), findsOneWidget);
    expect(find.text('Uplift Reel Viewer'), findsNothing);
    expect(find.text('Sign in'), findsNothing);

    await tester.ensureVisible(find.text('Sign out'));
    await tester.pump();
    await tester.tap(find.text('Sign out'));
    await settle(tester);

    expect(find.text('Signed out'), findsOneWidget);
    expect(find.text('Uplift Reel Viewer'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('email sign-in from the auth sheet updates the profile header', (
    tester,
  ) async {
    final authRepository = FakeAuthRepository();
    await tester.pumpWidget(makeApp(authRepository: authRepository));
    await settle(tester);

    await tester.tap(find.byIcon(Icons.person_outline));
    await settle(tester);
    await tester.tap(find.text('Sign in'));
    await settle(tester);

    await tester.enterText(
      find.widgetWithText(TextField, 'Email'),
      'jasper@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Password'),
      'secret1',
    );
    await tester.tap(find.widgetWithText(GestureDetector, 'Sign in').last);
    await settle(tester);

    // Sheet popped itself on AsyncData(user); header shows the account.
    expect(find.text('Welcome back'), findsNothing);
    expect(find.text('Jasper'), findsOneWidget);
    expect(find.text('jasper@example.com'), findsOneWidget);
  });

  testWidgets('settings clear-history wipes data after confirm', (
    tester,
  ) async {
    await bootAndGenerate(tester);

    await tester.tap(find.byIcon(Icons.person_outline));
    await settle(tester);
    await tester.tap(find.text('App settings'));
    await settle(tester);

    expect(find.text('Uplift Reel 1.0.0 · Stitch 2.0'), findsOneWidget);

    await tester.tap(find.text('Clear history'));
    await settle(tester);
    await tester.tap(find.text('Clear'));
    await settle(tester);

    expect(find.text('History cleared'), findsOneWidget);

    final container = containerOf(tester);
    expect(container.read(historyRepositoryProvider).entries(), isEmpty);
    // Invalidate triggers an async rebuild; .value would race it (loading
    // state carries the previous data). Await the rebuilt state instead.
    expect(
      await container.read(recommendationControllerProvider.future),
      isNull,
    );
  });
}
