import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../domain/models/movie.dart';
import '../../../../domain/models/recommendation.dart';
import '../../../../state/watched_movies_controller.dart';
import '../../../core/format.dart';
import '../../../core/launch_trailer.dart';
import '../../../core/theme/stitch_theme.dart';
import '../../../core/widgets/stitch_button.dart';
import '../../../core/widgets/stitch_movie_card.dart';
import '../../../core/widgets/stitch_skeleton.dart';

class MovieDetailsScreen extends ConsumerWidget {
  const MovieDetailsScreen({super.key, required this.movie, this.result});

  final Movie? movie;

  /// Present when arriving from a recommendation; bare [Movie] navigation
  /// (e.g. history rows) leaves it null and hides the match card.
  final RecommendationResult? result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final target = movie;
    if (target == null) return const _NotFound();

    final colors = StitchColors.of(context);
    final moodTheme = StitchMoodTheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    final watched = ref.watch(watchedMoviesProvider).contains(target.id);

    final content = [
      Text(target.title, style: textTheme.displayMedium),
      const SizedBox(height: StitchSpacing.xs),
      Text(
        '${target.releaseYear} · ${formatRuntime(target.runtime)} · '
        '★ ${target.imdbRating.toStringAsFixed(1)}',
        style: StitchTypography.data(
          color: colors.parchment.withValues(alpha: 0.85),
          fontSize: 13,
        ),
      ),
      const SizedBox(height: StitchSpacing.md),
      Wrap(
        spacing: StitchSpacing.sm,
        runSpacing: StitchSpacing.sm,
        children: [
          for (final genre in target.genres)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: StitchSpacing.md,
                vertical: StitchSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: colors.charcoal,
                borderRadius: BorderRadius.circular(StitchRadius.full),
                border: Border.all(color: colors.hairline),
              ),
              child: Text(
                titleCase(genre.label),
                style: textTheme.bodySmall?.copyWith(color: colors.parchment),
              ),
            ),
        ],
      ),
      if (result != null) ...[
        const SizedBox(height: StitchSpacing.lg),
        StitchMovieCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${result!.matchScore.round()}% MATCH',
                style: StitchTypography.data(
                  color: moodTheme.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: StitchSpacing.sm),
              Text(result!.explanation, style: textTheme.bodyLarge),
              if (result!.alternativeReason != null) ...[
                const SizedBox(height: StitchSpacing.sm),
                Text(
                  result!.alternativeReason!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: moodTheme.accent,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
      if (target.synopsis.isNotEmpty) ...[
        const SizedBox(height: StitchSpacing.lg),
        Text('SYNOPSIS', style: textTheme.labelSmall),
        const SizedBox(height: StitchSpacing.sm),
        Text(target.synopsis, style: textTheme.bodyLarge),
      ],
      if (target.director.isNotEmpty || target.actors.isNotEmpty) ...[
        const SizedBox(height: StitchSpacing.lg),
        Text('CREDITS', style: textTheme.labelSmall),
        const SizedBox(height: StitchSpacing.sm),
        if (target.director.isNotEmpty)
          Text('Director: ${target.director}', style: textTheme.bodyMedium),
        if (target.actors.isNotEmpty)
          Text(
            'Cast: ${target.actors.join(', ')}',
            style: textTheme.bodyMedium,
          ),
      ],
      const SizedBox(height: StitchSpacing.xl),
      StitchButton(
        label: 'Watch trailer',
        variant: StitchButtonVariant.outline,
        icon: Icons.play_arrow,
        expand: true,
        onPressed: () => launchTrailer(context, target),
      ),
      const SizedBox(height: StitchSpacing.sm),
      StitchButton(
        label: watched ? 'Watched ✓' : 'Mark as watched',
        variant: StitchButtonVariant.mood,
        icon: watched ? null : Icons.check,
        expand: true,
        onPressed: watched
            ? null
            : () async {
                await ref.read(watchedMoviesProvider.notifier).mark(target.id);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Added to your watched history.'),
                  ),
                );
              },
      ),
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 340,
            backgroundColor: colors.charcoal,
            leading: _CircleBack(onTap: () => context.pop()),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'movie-${target.id}',
                child: _Backdrop(movie: target),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                StitchSpacing.base,
                StitchSpacing.lg,
                StitchSpacing.base,
                StitchSpacing.xxxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: content
                    .animate(interval: 50.ms)
                    .fadeIn(
                      duration: StitchMotion.reveal,
                      curve: StitchMotion.easeOut,
                    )
                    .slideY(
                      begin: 0.03,
                      end: 0,
                      duration: StitchMotion.reveal,
                      curve: StitchMotion.easeOut,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Backdrop extends StatelessWidget {
  const _Backdrop({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    final colors = StitchColors.of(context);
    final imageUrl = movie.backdropUrl ?? movie.posterUrl;

    final fallback = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.graphite, colors.charcoal],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.movie_outlined,
          size: 56,
          color: colors.smoke.withValues(alpha: 0.5),
        ),
      ),
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        if (imageUrl == null)
          fallback
        else
          CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            fadeInDuration: StitchMotion.reveal,
            placeholder: (_, _) => const StitchSkeleton(height: 340, radius: 0),
            errorWidget: (_, _, _) => fallback,
          ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                colors.voidBlack.withValues(alpha: 0.85),
              ],
              stops: const [0.5, 1],
            ),
          ),
        ),
      ],
    );
  }
}

class _CircleBack extends StatelessWidget {
  const _CircleBack({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = StitchColors.of(context);

    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.voidBlack.withValues(alpha: 0.55),
            border: Border.all(color: colors.parchment.withValues(alpha: 0.2)),
          ),
          child: Icon(Icons.arrow_back, size: 20, color: colors.parchment),
        ),
      ),
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(StitchSpacing.base),
          child: StitchMovieCard(
            padding: const EdgeInsets.all(StitchSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Movie not found',
                  style: textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: StitchSpacing.lg),
                StitchButton(
                  label: 'Back',
                  expand: true,
                  onPressed: () => context.pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
