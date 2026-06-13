import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../domain/models/mood.dart';
import '../../../../domain/models/recommendation.dart';
import '../../../../state/mood_controller.dart';
import '../../../../state/recommendation_controller.dart';
import '../../../core/launch_trailer.dart';
import '../../../core/theme/stitch_mood_icons.dart';
import '../../../core/theme/stitch_theme.dart';
import '../../../core/widgets/stitch_button.dart';
import '../../../core/widgets/stitch_movie_card.dart';
import '../../../core/widgets/stitch_movie_hero.dart';
import '../../../core/widgets/stitch_skeleton.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = StitchColors.of(context);
    final moodTheme = StitchMoodTheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    final recommendation = ref.watch(recommendationControllerProvider);
    final mood = ref.watch(moodControllerProvider);

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [moodTheme.halo, colors.voidBlack],
            stops: const [0, 0.55],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            color: moodTheme.accent,
            onRefresh: () =>
                ref.read(recommendationControllerProvider.notifier).generate(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                StitchSpacing.base,
                StitchSpacing.base,
                StitchSpacing.base,
                StitchSpacing.xxxl,
              ),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('UPLIFT REEL', style: textTheme.labelSmall),
                    ),
                    IconButton(
                      onPressed: () => context.push('/history'),
                      icon: Icon(Icons.history, color: colors.smoke),
                      tooltip: 'History',
                    ),
                    IconButton(
                      onPressed: () => context.push('/profile'),
                      icon: Icon(Icons.person_outline, color: colors.smoke),
                      tooltip: 'Profile',
                    ),
                  ],
                ),
                Text('Need a lift?', style: textTheme.displayLarge),
                const SizedBox(height: StitchSpacing.xs),
                Text(
                  'Find the perfect movie for your current vibe.',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: StitchSpacing.md),
                _MoodStatus(mood: mood?.mood),
                const SizedBox(height: StitchSpacing.lg),
                recommendation.when(
                  loading: () => const _HomeSkeleton(),
                  error: (error, _) => _ErrorCard(error: error),
                  data: (result) => result == null
                      ? const _EmptyCard()
                      : _PickSection(
                          key: ValueKey(result.movie.id),
                          result: result,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MoodStatus extends StatelessWidget {
  const _MoodStatus({this.mood});

  final Mood? mood;

  @override
  Widget build(BuildContext context) {
    final colors = StitchColors.of(context);
    final moodTheme = StitchMoodTheme.of(context);
    final mood = this.mood;

    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () => context.go('/mood'),
        child: AnimatedContainer(
          duration: StitchMotion.base,
          padding: const EdgeInsets.symmetric(
            horizontal: StitchSpacing.md,
            vertical: StitchSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: mood != null ? moodTheme.halo : colors.charcoal,
            borderRadius: BorderRadius.circular(StitchRadius.full),
            border: Border.all(
              color: mood != null ? moodTheme.accent : colors.hairline,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (mood != null) ...[
                Icon(stitchMoodIcon(mood), size: 16, color: moodTheme.accent),
                const SizedBox(width: StitchSpacing.xs),
              ],
              Text(
                mood != null
                    ? '${mood.label} mood · change'
                    : 'Set a mood for sharper picks →',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: mood != null ? moodTheme.accent : colors.smoke,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The recommendation content. Keyed by movie id so a fresh pick replays
/// the staggered entrance, while theme/mood rebuilds do not.
class _PickSection extends ConsumerWidget {
  const _PickSection({super.key, required this.result});

  final RecommendationResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = StitchColors.of(context);
    final moodTheme = StitchMoodTheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    final movie = result.movie;
    final controller = ref.read(recommendationControllerProvider.notifier);

    final children = [
      StitchMovieHero(
        movie: movie,
        matchScore: result.matchScore,
        onTap: () => context.push('/details', extra: result),
      ),
      const SizedBox(height: StitchSpacing.base),
      StitchMovieCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('WHY THIS PICK', style: textTheme.labelSmall),
            const SizedBox(height: StitchSpacing.sm),
            Text(result.explanation, style: textTheme.bodyLarge),
            if (result.alternativeReason != null) ...[
              const SizedBox(height: StitchSpacing.sm),
              Text(
                result.alternativeReason!,
                style: textTheme.bodyMedium?.copyWith(color: moodTheme.accent),
              ),
            ],
            if (movie.synopsis.isNotEmpty) ...[
              const SizedBox(height: StitchSpacing.md),
              Divider(color: colors.hairline),
              const SizedBox(height: StitchSpacing.md),
              Text('SYNOPSIS', style: textTheme.labelSmall),
              const SizedBox(height: StitchSpacing.sm),
              Text(
                movie.synopsis,
                style: textTheme.bodyMedium,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: StitchSpacing.base),
      Row(
        children: [
          Expanded(
            child: StitchButton(
              label: 'Watch trailer',
              variant: StitchButtonVariant.outline,
              icon: Icons.play_arrow,
              onPressed: () => launchTrailer(context, movie),
            ),
          ),
          const SizedBox(width: StitchSpacing.sm),
          Expanded(
            child: StitchButton(
              label: 'Details',
              variant: StitchButtonVariant.outline,
              icon: Icons.info_outline,
              onPressed: () => context.push('/details', extra: result),
            ),
          ),
        ],
      ),
      const SizedBox(height: StitchSpacing.sm),
      StitchButton(
        label: 'Watched it',
        variant: StitchButtonVariant.mood,
        icon: Icons.check,
        expand: true,
        onPressed: () async {
          await controller.markWatched();
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Saved to history'),
              action: SnackBarAction(
                label: 'View history',
                onPressed: () => context.push('/history'),
              ),
            ),
          );
        },
      ),
      const SizedBox(height: StitchSpacing.xs),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StitchButton(
            label: 'Skip for now',
            variant: StitchButtonVariant.ghost,
            onPressed: controller.skip,
          ),
          StitchButton(
            label: 'Share',
            variant: StitchButtonVariant.ghost,
            onPressed: () => SharePlus.instance.share(
              ShareParams(
                text:
                    'Uplift Reel pick: ${movie.title} '
                    '(${movie.releaseYear}) — IMDb '
                    '${movie.imdbRating.toStringAsFixed(1)}',
              ),
            ),
          ),
        ],
      ),
    ];

    return Column(
      children: children
          .animate(interval: 70.ms)
          .fadeIn(duration: StitchMotion.reveal, curve: StitchMotion.easeOut)
          .slideY(
            begin: 0.04,
            end: 0,
            duration: StitchMotion.reveal,
            curve: StitchMotion.easeOut,
          ),
    );
  }
}

class _EmptyCard extends ConsumerWidget {
  const _EmptyCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return StitchMovieCard(
      padding: const EdgeInsets.all(StitchSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Tap below to generate your first personalized recommendation.',
            style: textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: StitchSpacing.lg),
          StitchButton(
            label: 'Generate recommendation',
            expand: true,
            onPressed: () =>
                ref.read(recommendationControllerProvider.notifier).generate(),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends ConsumerWidget {
  const _ErrorCard({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = StitchColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    return StitchMovieCard(
      padding: const EdgeInsets.all(StitchSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Something went wrong fetching your pick.',
            style: textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: StitchSpacing.sm),
          Text(
            '$error',
            style: textTheme.bodySmall?.copyWith(color: colors.danger),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: StitchSpacing.lg),
          StitchButton(
            label: 'Try again',
            expand: true,
            onPressed: () =>
                ref.read(recommendationControllerProvider.notifier).generate(),
          ),
        ],
      ),
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        StitchSkeleton(height: 420, radius: StitchRadius.xl),
        SizedBox(height: StitchSpacing.base),
        StitchSkeleton(height: 120, radius: StitchRadius.lg),
        SizedBox(height: StitchSpacing.base),
        StitchSkeleton(height: 52),
      ],
    );
  }
}
