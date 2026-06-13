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
import 'package:upliftreel/ui/core/theme/stitch_theme.dart';

import 'data/fake_http_adapter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // No network in tests; fall back to bundled fonts.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  late Directory tempDir;
  late Box<String> movieCacheBox;
  late Box<String> historyBox;
  late Box<String> moodBox;
  late SharedPreferences sharedPreferences;

  // Boxes are memory-backed (bytes:): a real file write started inside the
  // testWidgets FakeAsync zone can never complete once the test body ends,
  // which deadlocks teardown on the box's write lock.
  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('widget_test');
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
    final offline = FakeHttpAdapter((_) => jsonResponse('{"results": []}'));
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        movieCacheBoxProvider.overrideWithValue(movieCacheBox),
        historyBoxProvider.overrideWithValue(historyBox),
        moodBoxProvider.overrideWithValue(moodBox),
        tmdbApiProvider.overrideWithValue(TmdbApi(
          dio: Dio()..httpClientAdapter = offline,
          accessToken: 'token',
        )),
        omdbApiProvider.overrideWithValue(OmdbApi(
          dio: Dio()..httpClientAdapter = offline,
          apiKey: 'key',
        )),
      ],
      child: const UpliftReelApp(),
    );
  }

  // Fixed pumps instead of pumpAndSettle: settle-waiting can spin forever
  // when a fire-and-forget hive write holds a pending real-IO future.
  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('shell boots to Home, tabs switch, mood recolors the app',
      (tester) async {
    await tester.pumpWidget(makeApp());
    await settle(tester);

    expect(find.text('Need a lift?'), findsOneWidget);

    await tester.tap(find.text('Mood'));
    await settle(tester);
    expect(find.text('How do you feel tonight?'), findsOneWidget);

    await tester.ensureVisible(find.text('Relaxed'));
    await tester.pump();
    await tester.tap(find.text('Relaxed'));
    await settle(tester); // Covers the 900ms ambience crossfade.

    // The title may have scrolled out of the ListView viewport; anchor on
    // the always-present nav bar instead.
    final context = tester.element(find.byType(NavigationBar));
    expect(
      StitchMoodTheme.of(context).accent,
      StitchMoodTheme.fromMood(StitchMood.relaxed).accent,
    );

    await tester.tap(find.text('Preferences'));
    await settle(tester);
    expect(find.text('Tune your taste'), findsOneWidget);
    expect(find.text('FAVORITE GENRES'), findsOneWidget);
  });
}
