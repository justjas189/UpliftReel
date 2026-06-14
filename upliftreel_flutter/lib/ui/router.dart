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
import 'core/theme/stitch_theme.dart';
import 'core/widgets/stitch_button.dart';

/// Legacy kept three parallel stacks each duplicating History/Details/
/// Profile/Settings; here those are root-level routes pushed over the shell,
/// defined once.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    // The OAuth deep link (com.upliftreel.upliftreel://login-callback/) reopens
    // the app at host `login-callback`, path `/` — neither is a real route.
    // supabase_flutter's own deep-link observer extracts the session token and
    // emits on onAuthStateChange (AuthController catches it); the router must
    // not try to render the callback. Send it (and any bare root) to /home.
    redirect: (context, state) {
      final uri = state.uri;
      final isAuthCallback =
          uri.host == 'login-callback' || uri.path.contains('login-callback');
      if (isAuthCallback || uri.path.isEmpty || uri.path == '/') {
        return '/home';
      }
      return null;
    },
    // Final safety net: an unknown deep-link path lands on a clean Stitch
    // surface instead of GoRouter's raw red "page not found" exception screen.
    errorBuilder: (context, state) => const _RouteNotFoundScreen(),
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            StitchShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/mood',
                builder: (context, state) => const MoodScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/preferences',
                builder: (context, state) => const PreferencesScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/details',
        builder: (context, state) => switch (state.extra) {
          final RecommendationResult result => MovieDetailsScreen(
            movie: result.movie,
            result: result,
          ),
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

/// Shown by [GoRouter.errorBuilder] for any location that doesn't resolve —
/// e.g. a malformed deep link. One tap back to the home shell.
class _RouteNotFoundScreen extends StatelessWidget {
  const _RouteNotFoundScreen();

  @override
  Widget build(BuildContext context) {
    final colors = StitchColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.charcoal,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(StitchSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.explore_off_outlined, size: 48, color: colors.smoke),
              const SizedBox(height: StitchSpacing.lg),
              Text(
                'Lost the reel',
                style: textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: StitchSpacing.xs),
              Text(
                "That link didn't lead anywhere we recognise.",
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: StitchSpacing.xl),
              StitchButton(
                label: 'Back to home',
                icon: Icons.home_outlined,
                onPressed: () => context.go('/home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
