import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/models/movie.dart';
import '../domain/models/recommendation.dart';
import 'features/details/views/movie_details_screen.dart';
import 'features/history/views/history_screen.dart';
import 'features/home/views/home_screen.dart';
import 'features/mood/views/mood_screen.dart';
import 'features/preferences/views/preferences_screen.dart';
import 'features/profile/views/profile_screen.dart';
import 'features/settings/views/settings_screen.dart';

/// Legacy kept three parallel stacks each duplicating History/Details/
/// Profile/Settings; here those are root-level routes pushed over the shell,
/// defined once.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            StitchShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/mood',
              builder: (context, state) => const MoodScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/preferences',
              builder: (context, state) => const PreferencesScreen(),
            ),
          ]),
        ],
      ),
      GoRoute(
        path: '/details',
        builder: (context, state) => switch (state.extra) {
          final RecommendationResult result =>
            MovieDetailsScreen(movie: result.movie, result: result),
          final Movie movie => MovieDetailsScreen(movie: movie),
          _ => const MovieDetailsScreen(movie: null),
        },
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});

class StitchShell extends StatelessWidget {
  const StitchShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: navigationShell.goBranch,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.mood_outlined),
            selectedIcon: Icon(Icons.mood),
            label: 'Mood',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune),
            label: 'Preferences',
          ),
        ],
      ),
    );
  }
}
