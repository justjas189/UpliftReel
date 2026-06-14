import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/recommendation.dart';
import 'era_filter_controller.dart';
import 'mood_controller.dart';
import 'preferences_controller.dart';
import 'providers.dart';
import 'watched_movies_controller.dart';

/// Orchestrates the daily pick: candidates → engine → OMDb enrichment →
/// persistence. Ports the legacy DailyRecommendationService flow minus
/// notifications (deferred).
class RecommendationController extends AsyncNotifier<RecommendationResult?> {
  /// Legacy slice(-30): only the most recent recommendations block repeats.
  static const int _recencyWindow = 30;

  @override
  Future<RecommendationResult?> build() async {
    final history = ref.watch(historyRepositoryProvider);
    // Hydrate the local ledgers from the cloud at session start. Best-effort:
    // a no-op offline or when Supabase isn't configured. Watching the repo
    // means a sign-in/out (uid change) re-runs build against the new user's
    // namespace, so the restored pick is always the right account's.
    await history.pull();
    await ref.watch(moodRepositoryProvider).pull();
    return history.todaysPick();
  }

  Future<void> generate() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_generate);
  }

  Future<RecommendationResult?> _generate() async {
    final preferences = await ref.read(preferencesControllerProvider.future);
    final mood = ref.read(moodControllerProvider);
    final era = ref.read(eraFilterControllerProvider);
    final history = ref.read(historyRepositoryProvider);
    final movieRepository = ref.read(movieRepositoryProvider);
    final engine = ref.read(recommendationEngineProvider);

    // Era is parsed into the TMDB payload (server-side date window) AND into
    // the engine context (hard filter), so the pool is era-correct on every
    // path including English /movie/popular.
    final candidates = await movieRepository.getDailyCandidates(
      language: preferences.preferredLanguage,
      era: era,
    );
    final recommendationIds = history.recommendationIds();

    final context = RecommendationContext(
      userPreferences: preferences,
      currentMood: mood,
      previousRecommendationIds: recommendationIds.length > _recencyWindow
          ? recommendationIds.sublist(recommendationIds.length - _recencyWindow)
          : recommendationIds,
      watchedMovieIds: history.watchedIds(),
      eraRange: era.toRange(),
    );

    var result = engine.findBestMatch(context, candidates);

    final enriched = await movieRepository.enrichWithImdbRating(result.movie);
    result = result.copyWith(movie: enriched);

    await history.addRecommendation(result);
    return result;
  }

  Future<void> markWatched() async {
    final movieId = state.value?.movie.id;
    if (movieId == null) return;
    await ref.read(watchedMoviesProvider.notifier).mark(movieId);
  }

  /// Legacy "Skip for now": exclude the current pick, then re-roll.
  Future<void> skip() async {
    final movieId = state.value?.movie.id;
    if (movieId == null) return;
    await ref
        .read(preferencesControllerProvider.notifier)
        .excludeMovie(movieId);
    await generate();
  }
}

final recommendationControllerProvider =
    AsyncNotifierProvider<RecommendationController, RecommendationResult?>(
      RecommendationController.new,
    );
