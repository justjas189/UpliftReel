import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/repositories/auth_repository.dart';
import '../data/repositories/history_repository.dart';
import '../data/repositories/mood_repository.dart';
import '../data/repositories/movie_repository.dart';
import '../data/repositories/preferences_repository.dart';
import '../data/services/omdb_api.dart';
import '../data/services/supabase_auth_service.dart';
import '../data/services/supabase_data_service.dart';
import '../data/services/tmdb_api.dart';
import '../domain/engine/recommendation_engine.dart';
import 'auth_controller.dart';

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

final supabaseDataServiceProvider = Provider<SupabaseDataService>(
  (ref) => SupabaseDataService(),
);

/// The currently authenticated Supabase user id, or null when signed out /
/// auth disabled. This is the isolation key: every per-user repository watches
/// it, so signing in or out rebuilds the repos against a different (or no)
/// namespace and the dependent controllers reload automatically. Data for one
/// account can never surface under another.
final currentUserIdProvider = Provider<String?>(
  (ref) => ref.watch(authControllerProvider).value?.id,
);

final movieRepositoryProvider = Provider<MovieRepository>(
  (ref) => MovieRepository(
    tmdbApi: ref.watch(tmdbApiProvider),
    omdbApi: ref.watch(omdbApiProvider),
    cacheBox: ref.watch(movieCacheBoxProvider),
  ),
);

final preferencesRepositoryProvider = Provider<PreferencesRepository>(
  (ref) => PreferencesRepository(
    ref.watch(sharedPreferencesProvider),
    userId: ref.watch(currentUserIdProvider),
    dataService: ref.watch(supabaseDataServiceProvider),
  ),
);

final historyRepositoryProvider = Provider<HistoryRepository>(
  (ref) => HistoryRepository(
    ref.watch(historyBoxProvider),
    userId: ref.watch(currentUserIdProvider),
    dataService: ref.watch(supabaseDataServiceProvider),
  ),
);

final moodRepositoryProvider = Provider<MoodRepository>(
  (ref) => MoodRepository(
    ref.watch(moodBoxProvider),
    userId: ref.watch(currentUserIdProvider),
    dataService: ref.watch(supabaseDataServiceProvider),
  ),
);

final recommendationEngineProvider = Provider<RecommendationEngine>(
  (ref) => RecommendationEngine(),
);

final supabaseAuthServiceProvider = Provider<SupabaseAuthService>(
  (ref) => SupabaseAuthService(),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(service: ref.watch(supabaseAuthServiceProvider)),
);
