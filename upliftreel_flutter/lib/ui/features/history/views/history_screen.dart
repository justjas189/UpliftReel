import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../domain/models/history_entry.dart';
import '../../../../state/history_providers.dart';
import '../../../core/format.dart';
import '../../../core/theme/stitch_theme.dart';
import '../../../core/widgets/stitch_movie_card.dart';

enum _Filter { all, picks, watched }

enum _Sort { date, title, score }

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  _Filter _filter = _Filter.all;
  _Sort _sort = _Sort.date;

  List<HistoryEntry> _visible(List<HistoryEntry> all) {
    final scoped = switch (_filter) {
      _Filter.all => all,
      _Filter.picks => all.where((e) => e.isRecommendation).toList(),
      _Filter.watched => all.where((e) => e.isWatched).toList(),
    };

    return scoped
      ..sort(switch (_sort) {
        _Sort.date => (a, b) => b.date.compareTo(a.date),
        _Sort.title => (a, b) => a.movie.title.compareTo(b.movie.title),
        _Sort.score => (a, b) =>
            (b.matchScore ?? 0).compareTo(a.matchScore ?? 0),
      });
  }

  @override
  Widget build(BuildContext context) {
    final colors = StitchColors.of(context);
    final moodTheme = StitchMoodTheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    final all = ref.watch(historyEntriesProvider);
    final entries = _visible([...all]);

    final scored = all.where((e) => e.matchScore != null).toList();
    final averageScore = scored.isEmpty
        ? 0
        : (scored.map((e) => e.matchScore!).reduce((a, b) => a + b) /
                scored.length)
            .round();

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          StitchSpacing.base,
          StitchSpacing.sm,
          StitchSpacing.base,
          StitchSpacing.xxxl,
        ),
        children: [
          Text(
            '${all.length} titles tracked, average match score $averageScore',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: StitchSpacing.base),
          Row(
            children: [
              for (final filter in _Filter.values) ...[
                Expanded(
                  child: _FilterPill(
                    label: switch (filter) {
                      _Filter.all => 'All',
                      _Filter.picks => 'Picks',
                      _Filter.watched => 'Watched',
                    },
                    selected: _filter == filter,
                    onTap: () => setState(() => _filter = filter),
                  ),
                ),
                if (filter != _Filter.values.last)
                  const SizedBox(width: StitchSpacing.sm),
              ],
            ],
          ),
          const SizedBox(height: StitchSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final sort in _Sort.values)
                GestureDetector(
                  onTap: () => setState(() => _sort = sort),
                  child: Text(
                    switch (sort) {
                      _Sort.date => 'Sort: Date',
                      _Sort.title => 'Title',
                      _Sort.score => 'Score',
                    },
                    style: textTheme.bodySmall?.copyWith(
                      color: _sort == sort ? moodTheme.accent : colors.smoke,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: StitchSpacing.base),
          if (entries.isEmpty)
            StitchMovieCard(
              padding: const EdgeInsets.all(StitchSpacing.xl),
              child: Column(
                children: [
                  Text('Nothing here yet', style: textTheme.titleLarge),
                  const SizedBox(height: StitchSpacing.sm),
                  Text(
                    'Watch a movie or generate a recommendation to start '
                    'your timeline.',
                    style: textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            for (final entry in entries)
              Padding(
                padding: const EdgeInsets.only(bottom: StitchSpacing.sm),
                child: _HistoryRow(entry: entry),
              ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = StitchColors.of(context);
    final moodTheme = StitchMoodTheme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: StitchMotion.base,
        curve: StitchMotion.easeOut,
        padding: const EdgeInsets.symmetric(vertical: StitchSpacing.sm),
        decoration: BoxDecoration(
          color: selected ? moodTheme.halo : colors.charcoal,
          borderRadius: BorderRadius.circular(StitchRadius.full),
          border: Border.all(
            color: selected ? moodTheme.accent : colors.hairline,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: selected ? moodTheme.accent : colors.smoke,
              ),
        ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.entry});

  final HistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final colors = StitchColors.of(context);
    final moodTheme = StitchMoodTheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    final movie = entry.movie;

    return GestureDetector(
      onTap: () => context.push('/details', extra: movie),
      child: StitchMovieCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(movie.title, style: textTheme.titleLarge),
                ),
                if (entry.isRecommendation)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: StitchSpacing.sm,
                      vertical: StitchSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(StitchRadius.full),
                      border: Border.all(color: moodTheme.accent),
                    ),
                    child: Text(
                      'DAILY PICK',
                      style: StitchTypography.data(
                        color: moodTheme.accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: StitchSpacing.xs),
            Text(
              '${movie.releaseYear} · ${formatRuntime(movie.runtime)} · '
              '★ ${movie.imdbRating.toStringAsFixed(1)}',
              style: StitchTypography.data(
                color: colors.smoke,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: StitchSpacing.sm),
            Row(
              children: [
                if (entry.matchScore != null)
                  Text(
                    '${entry.matchScore!.round()}% match',
                    style: StitchTypography.data(
                      color: moodTheme.accent,
                      fontSize: 12,
                    ),
                  ),
                if (entry.isWatched) ...[
                  const SizedBox(width: StitchSpacing.md),
                  Tooltip(
                    message: 'Watched',
                    child: Icon(Icons.check_circle,
                        size: 14, color: colors.success),
                  ),
                ],
                const Spacer(),
                Text(
                  entry.date.toIso8601String().split('T').first,
                  style: StitchTypography.data(
                    color: colors.smoke,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
