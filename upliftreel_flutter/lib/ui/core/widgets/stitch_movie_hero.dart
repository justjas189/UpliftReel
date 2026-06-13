import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../domain/models/movie.dart';
import '../format.dart';
import '../theme/stitch_theme.dart';
import 'stitch_skeleton.dart';

/// The cinematic centerpiece. Upgrades over legacy StitchMovieHero:
/// cached imagery with shimmer skeleton, bottom-up scrim instead of a flat
/// 72% black overlay, mood-glow edge, Fraunces title, mono meta row.
class StitchMovieHero extends StatelessWidget {
  const StitchMovieHero({
    super.key,
    required this.movie,
    this.matchScore,
    this.onTap,
  });

  final Movie movie;
  final double? matchScore;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = StitchColors.of(context);
    final moodTheme = StitchMoodTheme.of(context);
    final textTheme = Theme.of(context).textTheme;
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

    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: 'movie-${movie.id}',
        child: Container(
          height: 420,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(StitchRadius.xl),
            boxShadow: [
              BoxShadow(
                color: moodTheme.glow,
                blurRadius: 28,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(StitchRadius.xl),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (imageUrl == null)
                  fallback
                else
                  CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    fadeInDuration: StitchMotion.reveal,
                    placeholder: (_, _) =>
                        const StitchSkeleton(height: 420, radius: 0),
                    errorWidget: (_, _, _) => fallback,
                  ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        colors.voidBlack.withValues(alpha: 0.55),
                        colors.voidBlack.withValues(alpha: 0.95),
                      ],
                      stops: const [0.35, 0.7, 1.0],
                    ),
                  ),
                ),
                if (matchScore != null)
                  Positioned(
                    top: StitchSpacing.base,
                    right: StitchSpacing.base,
                    child: _MatchBadge(score: matchScore!),
                  ),
                Positioned(
                  left: StitchSpacing.xl,
                  right: StitchSpacing.xl,
                  bottom: StitchSpacing.xl,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Wrap(
                        spacing: StitchSpacing.sm,
                        runSpacing: StitchSpacing.xs,
                        children: [
                          for (final genre in movie.genres.take(3))
                            _GenreChip(label: titleCase(genre.label)),
                        ],
                      ),
                      const SizedBox(height: StitchSpacing.sm),
                      Text(
                        movie.title,
                        style: textTheme.displayMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: StitchSpacing.xs),
                      Text(
                        '${movie.releaseYear} · '
                        '${formatRuntime(movie.runtime)} · '
                        '★ ${movie.imdbRating.toStringAsFixed(1)}',
                        style: StitchTypography.data(
                          color: colors.parchment.withValues(alpha: 0.85),
                          fontSize: 13,
                        ),
                      ),
                    ],
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

class _MatchBadge extends StatelessWidget {
  const _MatchBadge({required this.score});

  final double score;

  @override
  Widget build(BuildContext context) {
    final colors = StitchColors.of(context);
    final moodTheme = StitchMoodTheme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: StitchSpacing.md,
        vertical: StitchSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.voidBlack.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(StitchRadius.full),
        border: Border.all(color: moodTheme.accent.withValues(alpha: 0.8)),
      ),
      child: Text(
        '${score.round()}% MATCH',
        style: StitchTypography.data(
          color: moodTheme.accent,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _GenreChip extends StatelessWidget {
  const _GenreChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = StitchColors.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: StitchSpacing.md,
        vertical: StitchSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: colors.parchment.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(StitchRadius.full),
        border: Border.all(
          color: colors.parchment.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: colors.parchment),
      ),
    );
  }
}
