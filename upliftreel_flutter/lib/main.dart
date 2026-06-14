import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/services/api_config.dart';
import 'state/mood_controller.dart';
import 'state/providers.dart';
import 'ui/core/theme/stitch_theme.dart';
import 'ui/router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Optional: without Supabase keys the app runs local-only (no auth).
  if (ApiConfig.supabaseConfigured) {
    await Supabase.initialize(
      url: ApiConfig.supabaseUrl,
      // Accepts the project's anon / publishable key (interchangeable).
      publishableKey: ApiConfig.supabaseAnonKey,
    );
  }

  await Hive.initFlutter();
  final movieCacheBox = await Hive.openBox<String>('movie_cache');
  final historyBox = await Hive.openBox<String>('history');
  final moodBox = await Hive.openBox<String>('mood_log');
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        movieCacheBoxProvider.overrideWithValue(movieCacheBox),
        historyBoxProvider.overrideWithValue(historyBox),
        moodBoxProvider.overrideWithValue(moodBox),
      ],
      child: const UpliftReelApp(),
    ),
  );
}

class UpliftReelApp extends ConsumerWidget {
  const UpliftReelApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stitchMood = ref.watch(stitchMoodProvider);

    return MaterialApp.router(
      title: 'Uplift Reel',
      debugShowCheckedModeBanner: false,
      theme: StitchTheme.dark(mood: stitchMood),
      themeAnimationDuration: StitchMotion.ambient,
      themeAnimationCurve: StitchMotion.easeOut,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
