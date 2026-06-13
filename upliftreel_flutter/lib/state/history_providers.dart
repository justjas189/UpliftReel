import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/history_entry.dart';
import 'providers.dart';
import 'recommendation_controller.dart';
import 'watched_movies_controller.dart';

/// Live history rows: recomputes whenever a pick is generated or a movie
/// is marked watched, so the screen needs no manual refresh plumbing.
final historyEntriesProvider = Provider<List<HistoryEntry>>((ref) {
  ref.watch(watchedMoviesProvider);
  ref.watch(recommendationControllerProvider);
  return ref.watch(historyRepositoryProvider).entries();
});
