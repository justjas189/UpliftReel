import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/user_preferences.dart';
import 'providers.dart';

/// Replaces the preferences slice of the legacy AppContext reducer.
/// Loading/error states come free as AsyncValue.
class PreferencesController extends AsyncNotifier<UserPreferences> {
  @override
  Future<UserPreferences> build() =>
      ref.watch(preferencesRepositoryProvider).load();

  Future<void> save(UserPreferences preferences) async {
    final repository = ref.read(preferencesRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repository.save(preferences);
      // Reload so the state reflects post-validation values.
      return repository.load();
    });
  }

  Future<void> reset() async {
    final repository = ref.read(preferencesRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repository.reset();
      return repository.load();
    });
  }

  /// Legacy "Skip for now" support: hide a movie from future recommendations.
  Future<void> excludeMovie(String movieId) async {
    final current = await future;
    if (current.excludedMovieIds.contains(movieId)) return;
    await save(current.copyWith(
      excludedMovieIds: [...current.excludedMovieIds, movieId],
    ));
  }
}

final preferencesControllerProvider =
    AsyncNotifierProvider<PreferencesController, UserPreferences>(
  PreferencesController.new,
);
