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
import 'package:upliftreel/domain/models/movie.dart';
import 'package:upliftreel/main.dart';
import 'package:upliftreel/state/preferences_controller.dart';
import 'package:upliftreel/state/providers.dart';

import '../data/fake_http_adapter.dart';

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
    tempDir = Directory.systemTemp.createTempSync('prefs_test');
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
    final offline = FakeHttpAdapter((_) => jsonResponse('{"results": []}'));
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        movieCacheBoxProvider.overrideWithValue(movieCacheBox),
        historyBoxProvider.overrideWithValue(historyBox),
        moodBoxProvider.overrideWithValue(moodBox),
        tmdbApiProvider.overrideWithValue(
          TmdbApi(
            dio: Dio()..httpClientAdapter = offline,
            accessToken: 'token',
          ),
        ),
        omdbApiProvider.overrideWithValue(
          OmdbApi(dio: Dio()..httpClientAdapter = offline, apiKey: 'key'),
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

  Future<void> openPreferences(WidgetTester tester) async {
    await tester.pumpWidget(makeApp());
    await settle(tester);
    await tester.tap(find.text('Preferences'));
    await settle(tester);
  }

  // Below-fold ListView children are never built, so plain finders (and
  // ensureVisible) come up empty. scrollUntilVisible drags until the child
  // builds; scoped to the hit-testable scrollable because the shell keeps
  // other tab branches alive offstage.
  Future<void> reveal(WidgetTester tester, Finder finder) async {
    if (finder.evaluate().isEmpty) {
      await tester.scrollUntilVisible(
        finder,
        150,
        scrollable: find.byType(Scrollable).hitTestable().first,
      );
    }
    await tester.ensureVisible(finder);
    await tester.pump();
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await reveal(tester, finder);
    await tester.tap(finder);
    await settle(tester);
  }

  ProviderContainer containerOf(WidgetTester tester) {
    return ProviderScope.containerOf(
      tester.element(find.byType(NavigationBar)),
      listen: false,
    );
  }

  testWidgets('renders defaults: Good+ tier, 3 genres, 3h runtime', (
    tester,
  ) async {
    await openPreferences(tester);

    expect(find.text('Tune your taste'), findsOneWidget);
    await reveal(tester, find.text('3 genres selected'));
    expect(find.text('Good+ (6.0+ IMDb)'), findsOneWidget);
    await reveal(tester, find.text('Up to 3h 0m'));
    expect(find.text('Reminder at 19:00'), findsOneWidget);
    await reveal(tester, find.textContaining('Mixing distinct genres'));
  });

  testWidgets('genre toggle updates summary and save persists', (tester) async {
    await openPreferences(tester);

    await tapVisible(tester, find.text('Horror'));
    await reveal(tester, find.text('4 genres selected'));

    await tapVisible(tester, find.text('Save changes'));
    expect(find.text('Preferences updated'), findsOneWidget);

    final saved = containerOf(
      tester,
    ).read(preferencesControllerProvider).value!;
    expect(saved.selectedGenres, contains(Genre.horror));
  });

  testWidgets('Any-rating tier round-trips as 1.0 (legacy 0-clamp bug)', (
    tester,
  ) async {
    await openPreferences(tester);

    await tapVisible(tester, find.text('Any rating'));
    await tapVisible(tester, find.text('Save changes'));

    final saved = containerOf(
      tester,
    ).read(preferencesControllerProvider).value!;
    expect(saved.minRating, 1.0);
    // Summary still resolves to the tier — legacy showed "Great+" here.
    await reveal(tester, find.text('Any rating (All movies)'));
  });

  testWidgets('save disabled with zero genres', (tester) async {
    await openPreferences(tester);

    await tapVisible(tester, find.text('Comedy'));
    await tapVisible(tester, find.text('Drama'));
    await tapVisible(tester, find.text('Action'));

    expect(find.text('Choose at least one genre.'), findsOneWidget);

    await tapVisible(tester, find.text('Save changes'));
    expect(find.text('Preferences updated'), findsNothing);
  });

  testWidgets('runtime preset Any persists as no limit', (tester) async {
    await openPreferences(tester);

    await tapVisible(tester, find.text('Any length'));
    await tapVisible(tester, find.text('Save changes'));

    final saved = containerOf(
      tester,
    ).read(preferencesControllerProvider).value!;
    expect(saved.maxRuntime, isNull);
    await reveal(tester, find.text('Any runtime'));
  });

  testWidgets('reset confirm restores defaults; cancel keeps edits', (
    tester,
  ) async {
    await openPreferences(tester);

    await tapVisible(tester, find.text('Horror'));
    await reveal(tester, find.text('4 genres selected'));

    await tapVisible(tester, find.text('Reset defaults'));
    await tapVisible(tester, find.text('Cancel'));
    await reveal(tester, find.text('4 genres selected'));

    await tapVisible(tester, find.text('Reset defaults'));
    await tapVisible(tester, find.text('Reset'));

    final saved = containerOf(
      tester,
    ).read(preferencesControllerProvider).value!;
    expect(saved.selectedGenres, [Genre.comedy, Genre.drama, Genre.action]);
    await reveal(tester, find.text('3 genres selected'));
  });

  testWidgets('language pill persists ISO code and updates summary', (
    tester,
  ) async {
    await openPreferences(tester);

    await tapVisible(tester, find.text('Japanese'));
    await reveal(tester, find.text('Japanese movies'));
    await tapVisible(tester, find.text('Save changes'));

    final saved = containerOf(
      tester,
    ).read(preferencesControllerProvider).value!;
    expect(saved.preferredLanguage, 'ja');
  });

  testWidgets('reminder tile opens time picker', (tester) async {
    await openPreferences(tester);

    await tapVisible(tester, find.text('Change'));
    expect(find.text('Cancel'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await settle(tester);
    await reveal(tester, find.text('Reminder at 19:00'));
  });
}
