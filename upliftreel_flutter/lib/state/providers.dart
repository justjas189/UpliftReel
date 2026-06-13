import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/repositories/history_repository.dart';
import '../data/repositories/mood_repository.dart';
import '../data/repositories/movie_repository.dart';
import '../data/repositories/preferences_repository.dart';
import '../data/services/omdb_api.dart';
import '../data/services/tmdb_api.dart';
import '../domain/engine/recommendation_engine.dart';

/// Infrastructure handles opened in main() before runApp; the throwing
/// defaults make a missing override fail loudly at first read.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Override in ProviderScope at boot'),
);

final movieCacheBoxProvider = Provider<Box<String>>(
  (ref) => throw UnimplementedError('Override in ProviderScope at boot'),
);

final historyBoxProvider = Provider<Box<String>>(
  (ref) => throw UnimplementedError('Override in ProviderScope at boot'),
);

final moodBoxProvider = Provider<Box<String>>(
  (ref) => throw UnimplementedError('Override in ProviderScope at boot'),
);

final tmdbApiProvider = Provider<TmdbApi>((ref) => TmdbApi());

final omdbApiProvider = Provider<OmdbApi>((ref) => OmdbApi());

final movieRepositoryProvider = Provider<MovieRepository>(
  (ref) => MovieRepository(
    tmdbApi: ref.watch(tmdbApiProvider),
    omdbApi: ref.watch(omdbApiProvider),
    cacheBox: ref.watch(movieCacheBoxProvider),
  ),
);

final preferencesRepositoryProvider = Provider<PreferencesRepository>(
  (ref) => PreferencesRepository(ref.watch(sharedPreferencesProvider)),
);

final historyRepositoryProvider = Provider<HistoryRepository>(
  (ref) => HistoryRepository(ref.watch(historyBoxProvider)),
);

final moodRepositoryProvider = Provider<MoodRepository>(
  (ref) => MoodRepository(ref.watch(moodBoxProvider)),
);

final recommendationEngineProvider = Provider<RecommendationEngine>(
  (ref) => RecommendationEngine(),
);
