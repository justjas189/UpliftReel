import 'dart:convert';

import 'package:hive/hive.dart';

import '../../domain/models/history_entry.dart';
import '../../domain/models/movie.dart';
import '../../domain/models/recommendation.dart';
import '../services/supabase_data_service.dart';

/// Recommendation history, watched list, and the daily-pick cache.
/// Replaces the legacy AsyncStorage key soup (`recommendation_history`,
/// `watched_movies`, `recommendation_<id>`, `daily_recommendation_<date>`)
/// with one hive box.
///
/// Multi-user: every key is prefixed with a per-user namespace so two accounts
/// sharing the device's single Hive box never see each other's ledger. The
/// recommendation/watched rows sync to Supabase (RLS-bound) best-effort —
/// writes upload when online, reads stay local, and [pull] hydrates local from
/// the cloud at app start. The derived daily-pick cache stays local-only.
class HistoryRepository {
  HistoryRepository(
    this._box, {
    String? userId,
    SupabaseDataService? dataService,
  }) : _userId = userId,
       _dataService = dataService;

  final Box<String> _box;
  final String? _userId;
  final SupabaseDataService? _dataService;

  static const String _recommendationIdsKey = 'recommendation_ids';
  static const String _watchedIdsKey = 'watched_ids';
  static const String _dailyPickPrefix = 'daily_pick_';
  static const String _moviePrefix = 'movie_';

  /// Signed-out / local-only uses bare keys (legacy + test back-compat);
  /// a signed-in user gets a `<uid>::` namespace on every key.
  String get _ns => _userId == null ? '' : '$_userId::';

  bool get _remoteEnabled =>
      _userId != null && (_dataService?.isConfigured ?? false);

  /// Recommendation ids, oldest first (legacy append order).
  List<String> recommendationIds() => _readIds(_recommendationIdsKey);

  List<String> watchedIds() => _readIds(_watchedIdsKey);

  Future<void> addRecommendation(
    RecommendationResult result, {
    DateTime? now,
  }) async {
    final timestamp = now ?? DateTime.now();
    final ids = recommendationIds()..add(result.movie.id);
    await _box.put('$_ns$_recommendationIdsKey', jsonEncode(ids));
    await _box.put(
      '$_ns$_dailyPickPrefix${_dateKey(timestamp)}',
      jsonEncode(result.toJson()),
    );
    await _box.put(
      '$_ns$_moviePrefix${result.movie.id}',
      jsonEncode({
        'movie': result.movie.toJson(),
        'date': timestamp.toIso8601String(),
        'matchScore': result.matchScore,
      }),
    );

    await _pushRow(result.movie.id);
  }

  /// All renderable history rows, newest first.
  List<HistoryEntry> entries() {
    final recommendationSet = recommendationIds().toSet();
    final watchedSet = watchedIds().toSet();
    final moviePrefix = '$_ns$_moviePrefix';

    final result = <HistoryEntry>[];
    for (final key in _box.keys.whereType<String>()) {
      if (!key.startsWith(moviePrefix)) continue;
      final data = jsonDecode(_box.get(key)!) as Map<String, dynamic>;
      final movie = Movie.fromJson(data['movie'] as Map<String, dynamic>);
      result.add(
        HistoryEntry(
          movie: movie,
          date: DateTime.parse(data['date'] as String),
          matchScore: (data['matchScore'] as num?)?.toDouble(),
          isRecommendation: recommendationSet.contains(movie.id),
          isWatched: watchedSet.contains(movie.id),
        ),
      );
    }

    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  }

  /// Wipes the current user's recommendations, watched list, daily picks, and
  /// snapshots. Signed-out/local-only clears the whole box (legacy parity);
  /// a signed-in user only clears their own namespace.
  Future<void> clearAll() async {
    final keys = _userId == null
        ? _box.keys.toList()
        : _box.keys
              .whereType<String>()
              .where((k) => k.startsWith(_ns))
              .toList();
    await _box.deleteAll(keys);
  }

  Future<void> markWatched(String movieId) async {
    final ids = watchedIds();
    if (ids.contains(movieId)) return;
    ids.add(movieId);
    await _box.put('$_ns$_watchedIdsKey', jsonEncode(ids));
    await _pushRow(movieId);
  }

  RecommendationResult? todaysPick({DateTime? now}) {
    final stored = _box.get(
      '$_ns$_dailyPickPrefix${_dateKey(now ?? DateTime.now())}',
    );
    if (stored == null) return null;
    return RecommendationResult.fromJson(
      jsonDecode(stored) as Map<String, dynamic>,
    );
  }

  /// Drops daily picks older than 30 days; legacy cleanupOldRecommendations.
  Future<void> cleanupOldPicks({DateTime? now}) async {
    final cutoff = (now ?? DateTime.now()).subtract(const Duration(days: 30));
    final pickPrefix = '$_ns$_dailyPickPrefix';

    final staleKeys = _box.keys.whereType<String>().where((key) {
      if (!key.startsWith(pickPrefix)) return false;
      final date = DateTime.tryParse(key.substring(pickPrefix.length));
      return date != null && date.isBefore(cutoff);
    }).toList();

    await _box.deleteAll(staleKeys);
  }

  /// Best-effort cloud → local hydration of the recommendation/watched ledger.
  /// Unions remote rows into local without clobbering existing snapshots;
  /// silently no-ops offline or when sync is disabled.
  Future<void> pull() async {
    if (!_remoteEnabled) return;
    try {
      final rows = await _dataService!.fetchWatchHistory();
      if (rows.isEmpty) return;

      final recommendationIds = this.recommendationIds();
      final watchedIds = this.watchedIds();
      final recSet = recommendationIds.toSet();
      final watchedSet = watchedIds.toSet();

      for (final row in rows) {
        final movieId = row['movie_id'] as String;
        final movie = row['movie'];
        if (movie is! Map<String, dynamic>) continue;

        await _box.put(
          '$_ns$_moviePrefix$movieId',
          jsonEncode({
            'movie': movie,
            'date': row['recommended_at'],
            'matchScore': row['match_score'],
          }),
        );

        if (row['is_recommendation'] == true && recSet.add(movieId)) {
          recommendationIds.add(movieId);
        }
        if (row['is_watched'] == true && watchedSet.add(movieId)) {
          watchedIds.add(movieId);
        }
      }

      await _box.put(
        '$_ns$_recommendationIdsKey',
        jsonEncode(recommendationIds),
      );
      await _box.put('$_ns$_watchedIdsKey', jsonEncode(watchedIds));
    } catch (_) {
      // Offline: keep local as-is.
    }
  }

  List<String> _readIds(String key) {
    final stored = _box.get('$_ns$key');
    if (stored == null) return [];
    return (jsonDecode(stored) as List).cast<String>();
  }

  /// Uploads the watch_history row for [movieId], reconstructed from the local
  /// snapshot. No snapshot (e.g. a movie watched but never recommended) means
  /// no movie blob to satisfy the NOT NULL column, so the push is skipped.
  Future<void> _pushRow(String movieId) async {
    if (!_remoteEnabled) return;
    final stored = _box.get('$_ns$_moviePrefix$movieId');
    if (stored == null) return;
    final data = jsonDecode(stored) as Map<String, dynamic>;
    try {
      await _dataService!.upsertWatchHistory([
        {
          'movie_id': movieId,
          'movie': data['movie'],
          'is_recommendation': recommendationIds().contains(movieId),
          'is_watched': watchedIds().contains(movieId),
          'match_score': data['matchScore'],
          'recommended_at': data['date'],
        },
      ]);
    } catch (_) {
      // Offline: local ledger stands; reconciled by the next write or [pull].
    }
  }

  static String _dateKey(DateTime date) =>
      date.toIso8601String().split('T').first;
}
