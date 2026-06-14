import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upliftreel/data/repositories/history_repository.dart';
import 'package:upliftreel/data/repositories/mood_repository.dart';
import 'package:upliftreel/data/repositories/preferences_repository.dart';
import 'package:upliftreel/domain/models/mood.dart';
import 'package:upliftreel/domain/models/movie.dart';
import 'package:upliftreel/domain/models/recommendation.dart';
import 'package:upliftreel/domain/models/user_preferences.dart';

/// Verifies that per-user key namespacing isolates two accounts sharing one
/// device's storage, with no Supabase configured (the pure-local fallback the
/// app runs in offline / unconfigured). The DB's RLS is the second line of
/// defense; this proves the first.
RecommendationResult _pick(String movieId) => RecommendationResult(
  movie: Movie(
    id: movieId,
    title: 'Movie $movieId',
    genres: const [Genre.comedy],
    imdbRating: 8.0,
    releaseYear: 2020,
    runtime: 100,
    synopsis: 's',
    director: 'd',
    actors: const [],
    moodTags: const [MoodTag.funny],
  ),
  matchScore: 80,
  explanation: 'e',
  isAlternative: false,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('preferences isolation', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('one account never sees another account\'s saved profile', () async {
      final prefs = await SharedPreferences.getInstance();
      final alice = PreferencesRepository(prefs, userId: 'alice');
      final bob = PreferencesRepository(prefs, userId: 'bob');

      await alice.save(
        UserPreferences.defaults().copyWith(
          selectedGenres: [Genre.horror],
          minRating: 9.0,
        ),
      );

      // Bob is a different uid → his own slot → untouched defaults.
      final bobPrefs = await bob.load();
      expect(bobPrefs.selectedGenres, isNot(contains(Genre.horror)));
      expect(bobPrefs.minRating, 6.0);

      // Alice still has hers.
      final alicePrefs = await alice.load();
      expect(alicePrefs.selectedGenres, [Genre.horror]);
      expect(alicePrefs.minRating, 9.0);
    });

    test('signed-out keeps the legacy un-suffixed key', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final guest = PreferencesRepository(prefs);

      await guest.save(UserPreferences.defaults().copyWith(minRating: 7.5));

      expect(prefs.getString('user_preferences'), isNotNull);
      expect(prefs.containsKey('user_preferences__null'), isFalse);
    });
  });

  group('hive-backed isolation', () {
    late Directory tempDir;
    late Box<String> historyBox;
    late Box<String> moodBox;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('isolation_test');
      Hive.init(tempDir.path);
      historyBox = await Hive.openBox<String>('history');
      moodBox = await Hive.openBox<String>('mood_log');
    });

    tearDown(() async {
      await historyBox.deleteFromDisk();
      await moodBox.deleteFromDisk();
      tempDir.deleteSync(recursive: true);
    });

    test('watch history is isolated per uid', () async {
      final alice = HistoryRepository(historyBox, userId: 'alice');
      final bob = HistoryRepository(historyBox, userId: 'bob');

      await alice.addRecommendation(_pick('a1'), now: DateTime(2026, 6, 14));
      await alice.markWatched('a1');

      expect(bob.recommendationIds(), isEmpty);
      expect(bob.watchedIds(), isEmpty);
      expect(bob.entries(), isEmpty);

      expect(alice.recommendationIds(), ['a1']);
      expect(alice.watchedIds(), ['a1']);
      expect(alice.entries().single.movie.id, 'a1');
    });

    test('clearAll only wipes the current uid namespace', () async {
      final alice = HistoryRepository(historyBox, userId: 'alice');
      final bob = HistoryRepository(historyBox, userId: 'bob');

      await alice.addRecommendation(_pick('a1'), now: DateTime(2026, 6, 14));
      await bob.addRecommendation(_pick('b1'), now: DateTime(2026, 6, 14));

      await alice.clearAll();

      expect(alice.entries(), isEmpty);
      expect(bob.entries().single.movie.id, 'b1');
    });

    test('mood log is isolated per uid', () async {
      final alice = MoodRepository(moodBox, userId: 'alice');
      final bob = MoodRepository(moodBox, userId: 'bob');

      await alice.logMood(
        const MoodInput(mood: Mood.happy, intensity: 5, seriousness: 5),
        now: DateTime(2026, 6, 14),
      );

      expect(alice.entries(), hasLength(1));
      expect(bob.entries(), isEmpty);
    });
  });
}
