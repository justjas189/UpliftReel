import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../state/history_providers.dart';
import '../../../../state/providers.dart';
import '../../../core/theme/stitch_mood_icons.dart';
import '../../../core/theme/stitch_theme.dart';
import '../../../core/widgets/stitch_movie_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = StitchColors.of(context);
    final moodTheme = StitchMoodTheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    final entries = ref.watch(historyEntriesProvider);
    final picks = entries.where((e) => e.isRecommendation).length;
    final watched = entries.where((e) => e.isWatched).length;
    final scored = entries.where((e) => e.matchScore != null).toList();
    final averageScore = scored.isEmpty
        ? null
        : (scored.map((e) => e.matchScore!).reduce((a, b) => a + b) /
                  scored.length)
              .round();
    final insights = ref.watch(moodRepositoryProvider).insights();
    final hasMoodHistory = insights.moodFrequency.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(StitchSpacing.base),
        children: [
          StitchMovieCard(
            padding: const EdgeInsets.all(StitchSpacing.xl),
            child: Column(
              children: [
                Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: moodTheme.halo,
                    border: Border.all(color: moodTheme.accent),
                  ),
                  child: Center(
                    child: Text(
                      'UR',
                      style: textTheme.titleLarge?.copyWith(
                        color: moodTheme.accent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: StitchSpacing.md),
                Text('Uplift Reel Viewer', style: textTheme.titleLarge),
                const SizedBox(height: StitchSpacing.xs),
                Text(
                  'Your personalized movie journey.',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: StitchSpacing.lg),
                Row(
                  children: [
                    _Stat(label: 'PICKS', value: '$picks'),
                    _Stat(label: 'WATCHED', value: '$watched'),
                    _Stat(
                      label: 'AVG MATCH',
                      value: averageScore != null ? '$averageScore%' : '—',
                    ),
                  ],
                ),
                if (hasMoodHistory) ...[
                  const SizedBox(height: StitchSpacing.lg),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        stitchMoodIcon(insights.mostCommonMood),
                        size: 16,
                        color: moodTheme.accent,
                      ),
                      const SizedBox(width: StitchSpacing.xs),
                      Text(
                        'Most common mood: '
                        '${insights.mostCommonMood.label}',
                        style: textTheme.bodyMedium?.copyWith(
                          color: moodTheme.accent,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: StitchSpacing.base),
          _ActionTile(
            icon: Icons.tune,
            label: 'Movie preferences',
            onTap: () => context.go('/preferences'),
          ),
          _ActionTile(
            icon: Icons.history,
            label: 'Watch history',
            onTap: () => context.push('/history'),
          ),
          _ActionTile(
            icon: Icons.settings_outlined,
            label: 'App settings',
            onTap: () => context.push('/settings'),
          ),
          const SizedBox(height: StitchSpacing.sm),
          Center(
            child: Text(
              'Uplift Reel · Stitch 2.0',
              style: StitchTypography.data(color: colors.smoke, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final moodTheme = StitchMoodTheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: StitchTypography.data(
              color: moodTheme.accent,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: StitchSpacing.xxs),
          Text(label, style: textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = StitchColors.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: StitchSpacing.sm),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(StitchSpacing.base),
          decoration: BoxDecoration(
            color: colors.charcoal,
            borderRadius: BorderRadius.circular(StitchRadius.md),
            border: Border.all(color: colors.hairline),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: colors.smoke),
              const SizedBox(width: StitchSpacing.md),
              Text(label, style: Theme.of(context).textTheme.bodyLarge),
              const Spacer(),
              Icon(Icons.chevron_right, size: 20, color: colors.smoke),
            ],
          ),
        ),
      ),
    );
  }
}
