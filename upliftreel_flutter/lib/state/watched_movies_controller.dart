import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';

/// Reactive watched set. Legacy kept a screen-local `isWatched` flag that
/// reset to false on every visit; this reads the real history and any
/// screen watching it updates when a movie is marked.
class WatchedMoviesController extends Notifier<Set<String>> {
  @override
  Set<String> build() =>
      ref.watch(historyRepositoryProvider).watchedIds().toSet();

  Future<void> mark(String movieId) async {
    if (state.contains(movieId)) return;
    await ref.read(historyRepositoryProvider).markWatched(movieId);
    state = {...state, movieId};
  }
}

final watchedMoviesProvider =
    NotifierProvider<WatchedMoviesController, Set<String>>(
  WatchedMoviesController.new,
);
