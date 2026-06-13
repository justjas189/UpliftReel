import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:upliftreel/data/repositories/history_repository.dart';
import 'package:upliftreel/data/repositories/mood_repository.dart';
import 'package:upliftreel/domain/models/mood.dart';
import 'package:upliftreel/domain/models/movie.dart';
import 'package:upliftreel/domain/models/recommendation.dart';

RecommendationResult result(String movieId) {
  return RecommendationResult(
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
}

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('repo_test');
    Hive.init(tempDir.path);
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  group('HistoryRepository', () {
    late Box<String> box;
    late HistoryRepository repo;

    setUp(() async {
      box = await Hive.openBox<String>('history');
      repo = HistoryRepository(box);
    });

    tearDown(() async {
      await box.deleteFromDisk();
    });

    test('addRecommendation appends id and stores daily pick', () async {
      final now = DateTime(2026, 6, 12);

      await repo.addRecommendation(result('a'), now: now);
      await repo.addRecommendation(result('b'), now: now);

      expect(repo.recommendationIds(), ['a', 'b']);
      expect(repo.todaysPick(now: now)!.movie.id, 'b');
      expect(repo.todaysPick(now: DateTime(2026, 6, 13)), isNull);
    });

    test('markWatched deduplicates', () async {
      await repo.markWatched('a');
      await repo.markWatched('a');
      expect(repo.watchedIds(), ['a']);
    });

    test('entries assemble from snapshots, newest first, with flags',
        () async {
      await repo.addRecommendation(result('a'), now: DateTime(2026, 6, 10));
      await repo.addRecommendation(result('b'), now: DateTime(2026, 6, 12));
      await repo.markWatched('a');

      final entries = repo.entries();

      expect(entries.map((e) => e.movie.id), ['b', 'a']);
      expect(entries.first.isRecommendation, isTrue);
      expect(entries.first.isWatched, isFalse);
      expect(entries.first.matchScore, 80);
      expect(entries.last.isWatched, isTrue);
      expect(entries.last.movie.title, 'Movie a');
    });

    test('clearAll wipes ids, picks, and snapshots', () async {
      await repo.addRecommendation(result('a'), now: DateTime(2026, 6, 10));
      await repo.markWatched('a');

      await repo.clearAll();

      expect(repo.entries(), isEmpty);
      expect(repo.recommendationIds(), isEmpty);
      expect(repo.watchedIds(), isEmpty);
      expect(repo.todaysPick(now: DateTime(2026, 6, 10)), isNull);
    });

    test('cleanupOldPicks keeps the 30-day window', () async {
      await repo.addRecommendation(result('old'), now: DateTime(2026, 5, 1));
      await repo.addRecommendation(result('new'), now: DateTime(2026, 6, 10));

      await repo.cleanupOldPicks(now: DateTime(2026, 6, 12));

      expect(repo.todaysPick(now: DateTime(2026, 5, 1)), isNull);
      expect(repo.todaysPick(now: DateTime(2026, 6, 10)), isNotNull);
      // History ids survive cleanup; only daily picks expire (legacy parity).
      expect(repo.recommendationIds(), ['old', 'new']);
    });
  });

  group('MoodRepository', () {
    late Box<String> box;
    late MoodRepository repo;

    setUp(() async {
      box = await Hive.openBox<String>('moods');
      repo = MoodRepository(box);
    });

    tearDown(() async {
      await box.deleteFromDisk();
    });

    test('caps log at 100 entries, dropping oldest', () async {
      for (var i = 0; i < 105; i++) {
        await repo.logMood(
          MoodInput(
            mood: Mood.values[i % Mood.values.length],
            intensity: 5,
            seriousness: 5,
          ),
          now: DateTime(2026, 1, 1).add(Duration(hours: i)),
        );
      }

      final entries = repo.entries();
      expect(entries, hasLength(100));
      expect(entries.first.timestamp,
          DateTime(2026, 1, 1).add(const Duration(hours: 5)));
    });

    test('insights aggregate frequency, intensity, weekly pattern', () async {
      // Monday 2026-06-08, Tuesday 2026-06-09.
      await repo.logMood(
        const MoodInput(mood: Mood.happy, intensity: 4, seriousness: 3),
        now: DateTime(2026, 6, 8),
      );
      await repo.logMood(
        const MoodInput(mood: Mood.happy, intensity: 6, seriousness: 3),
        now: DateTime(2026, 6, 8, 20),
      );
      await repo.logMood(
        const MoodInput(mood: Mood.suspense, intensity: 8, seriousness: 8),
        now: DateTime(2026, 6, 9),
      );

      final insights = repo.insights();

      expect(insights.mostCommonMood, Mood.happy);
      expect(insights.averageIntensity, 6.0);
      expect(insights.moodFrequency[Mood.happy], 2);
      expect(insights.weeklyPattern['Monday'], Mood.happy);
      expect(insights.weeklyPattern['Tuesday'], Mood.suspense);
    });

    test('empty log returns legacy defaults', () {
      final insights = repo.insights();
      expect(insights.mostCommonMood, Mood.happy);
      expect(insights.averageIntensity, 5);
      expect(insights.moodFrequency, isEmpty);
    });
  });
}
