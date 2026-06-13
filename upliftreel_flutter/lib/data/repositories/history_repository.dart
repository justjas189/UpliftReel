import 'dart:convert';

import 'package:hive/hive.dart';

import '../../domain/models/history_entry.dart';
import '../../domain/models/movie.dart';
import '../../domain/models/recommendation.dart';

/// Recommendation history, watched list, and the daily-pick cache.
/// Replaces the legacy AsyncStorage key soup (`recommendation_history`,
/// `watched_movies`, `recommendation_<id>`, `daily_recommendation_<date>`)
/// with one hive box.
class HistoryRepository {
  HistoryRepository(this._box);

  final Box<String> _box;

  static const String _recommendationIdsKey = 'recommendation_ids';
  static const String _watchedIdsKey = 'watched_ids';
  static const String _dailyPickPrefix = 'daily_pick_';
  static const String _moviePrefix = 'movie_';

  /// Recommendation ids, oldest first (legacy append order).
  List<String> recommendationIds() => _readIds(_recommendationIdsKey);

  List<String> watchedIds() => _readIds(_watchedIdsKey);

  Future<void> addRecommendation(
    RecommendationResult result, {
    DateTime? now,
  }) async {
    final timestamp = now ?? DateTime.now();
    final ids = recommendationIds()..add(result.movie.id);
    await _box.put(_recommendationIdsKey, jsonEncode(ids));
    await _box.put(
      '$_dailyPickPrefix${_dateKey(timestamp)}',
      jsonEncode(result.toJson()),
    );
    await _box.put(
      '$_moviePrefix${result.movie.id}',
      jsonEncode({
        'movie': result.movie.toJson(),
        'date': timestamp.toIso8601String(),
        'matchScore': result.matchScore,
      }),
    );
  }

  /// All renderable history rows, newest first.
  List<HistoryEntry> entries() {
    final recommendationSet = recommendationIds().toSet();
    final watchedSet = watchedIds().toSet();

    final result = <HistoryEntry>[];
    for (final key in _box.keys.whereType<String>()) {
      if (!key.startsWith(_moviePrefix)) continue;
      final data = jsonDecode(_box.get(key)!) as Map<String, dynamic>;
      final movie = Movie.fromJson(data['movie'] as Map<String, dynamic>);
      result.add(HistoryEntry(
        movie: movie,
        date: DateTime.parse(data['date'] as String),
        matchScore: (data['matchScore'] as num?)?.toDouble(),
        isRecommendation: recommendationSet.contains(movie.id),
        isWatched: watchedSet.contains(movie.id),
      ));
    }

    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  }

  /// Wipes recommendations, watched list, daily picks, and snapshots.
  Future<void> clearAll() async {
    await _box.clear();
  }

  Future<void> markWatched(String movieId) async {
    final ids = watchedIds();
    if (ids.contains(movieId)) return;
    ids.add(movieId);
    await _box.put(_watchedIdsKey, jsonEncode(ids));
  }

  RecommendationResult? todaysPick({DateTime? now}) {
    final stored =
        _box.get('$_dailyPickPrefix${_dateKey(now ?? DateTime.now())}');
    if (stored == null) return null;
    return RecommendationResult.fromJson(
      jsonDecode(stored) as Map<String, dynamic>,
    );
  }

  /// Drops daily picks older than 30 days; legacy cleanupOldRecommendations.
  Future<void> cleanupOldPicks({DateTime? now}) async {
    final cutoff = (now ?? DateTime.now()).subtract(const Duration(days: 30));

    final staleKeys = _box.keys.whereType<String>().where((key) {
      if (!key.startsWith(_dailyPickPrefix)) return false;
      final date = DateTime.tryParse(key.substring(_dailyPickPrefix.length));
      return date != null && date.isBefore(cutoff);
    }).toList();

    await _box.deleteAll(staleKeys);
  }

  List<String> _readIds(String key) {
    final stored = _box.get(key);
    if (stored == null) return [];
    return (jsonDecode(stored) as List).cast<String>();
  }

  static String _dateKey(DateTime date) =>
      date.toIso8601String().split('T').first;
}
