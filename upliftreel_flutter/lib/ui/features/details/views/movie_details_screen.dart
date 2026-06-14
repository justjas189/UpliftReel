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
import '../../../core/widgets/share_movie_button.dart';
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

    final tagline = target.tagline;
    final hasCredits =
        target.director.isNotEmpty ||
        target.actors.isNotEmpty ||
        target.writers.isNotEmpty ||
        target.producers.isNotEmpty;
    final awards = target.awards;

    final content = [
      Text(target.title, style: textTheme.displayMedium),
      if (tagline != null && tagline.isNotEmpty) ...[
        const SizedBox(height: StitchSpacing.xs),
        Text(
          '“$tagline”',
          style: textTheme.bodyMedium?.copyWith(
            color: colors.smoke,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
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
      if (target.synopsis.isNotEmpty) ...[
        const SizedBox(height: StitchSpacing.lg),
        Text('SYNOPSIS', style: textTheme.labelSmall),
        const SizedBox(height: StitchSpacing.sm),
        Text(target.synopsis, style: textTheme.bodyLarge),
      ],
      if (hasCredits) ...[
        const SizedBox(height: StitchSpacing.lg),
        Text('CAST & CREW', style: textTheme.labelSmall),
        const SizedBox(height: StitchSpacing.sm),
        if (target.director.isNotEmpty)
          _CreditLine(label: 'Director', value: target.director),
        if (target.actors.isNotEmpty)
          _CreditLine(label: 'Starring', value: target.actors.join(', ')),
        if (target.writers.isNotEmpty)
          _CreditLine(label: 'Writers', value: target.writers.join(', ')),
        if (target.producers.isNotEmpty)
          _CreditLine(label: 'Producers', value: target.producers.join(', ')),
      ],
      if (awards != null) ...[
        const SizedBox(height: StitchSpacing.lg),
        Text('AWARDS', style: textTheme.labelSmall),
        const SizedBox(height: StitchSpacing.sm),
        StitchMovieCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.emoji_events_outlined, color: moodTheme.accent),
              const SizedBox(width: StitchSpacing.md),
              Expanded(
                child: Text(
                  awards,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.parchment,
                  ),
                ),
              ),
            ],
          ),
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
      const SizedBox(height: StitchSpacing.sm),
      ShareMovieButton(
        movie: target,
        variant: StitchButtonVariant.outline,
        expand: true,
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

/// One labelled line of the CAST & CREW block: a fixed-width role caption
/// beside the comma-joined names, so Director/Starring/Writers/Producers align.
class _CreditLine extends StatelessWidget {
  const _CreditLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = StitchColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: StitchSpacing.xxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 84,
            child: Text(
              label.toUpperCase(),
              style: textTheme.labelSmall?.copyWith(color: colors.smoke),
            ),
          ),
          const SizedBox(width: StitchSpacing.sm),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyMedium?.copyWith(color: colors.parchment),
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
