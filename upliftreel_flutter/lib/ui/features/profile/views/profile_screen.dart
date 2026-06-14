import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../domain/models/auth_user.dart';
import '../../../../state/auth_controller.dart';
import '../../../../state/history_providers.dart';
import '../../../../state/providers.dart';
import '../../../core/theme/stitch_mood_icons.dart';
import '../../../core/theme/stitch_theme.dart';
import '../../../core/widgets/stitch_button.dart';
import '../../../core/widgets/stitch_movie_card.dart';
import '../../auth/views/auth_sheet.dart';

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
    final user = ref.watch(authControllerProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(StitchSpacing.base),
        children: [
          StitchMovieCard(
            padding: const EdgeInsets.all(StitchSpacing.xl),
            child: Column(
              children: [
                _ProfileAvatar(user: user),
                const SizedBox(height: StitchSpacing.md),
                Text(
                  user?.displayName ?? user?.email ?? 'Uplift Reel Viewer',
                  style: textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: StitchSpacing.xs),
                Text(
                  user != null && user.displayName != null
                      ? user.email
                      : 'Your personalized movie journey.',
                  style: textTheme.bodyMedium,
                ),
                if (user == null) ...[
                  const SizedBox(height: StitchSpacing.lg),
                  StitchButton(
                    label: 'Sign in',
                    icon: Icons.login,
                    variant: StitchButtonVariant.mood,
                    onPressed: () => showAuthSheet(context),
                  ),
                ],
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
          if (user != null)
            _ActionTile(
              icon: Icons.logout,
              label: 'Sign out',
              color: colors.danger,
              onTap: () async {
                final ok = await ref
                    .read(authControllerProvider.notifier)
                    .signOut();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ok ? 'Signed out' : 'Sign out failed'),
                  ),
                );
              },
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

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.user});

  final AuthUser? user;

  @override
  Widget build(BuildContext context) {
    final moodTheme = StitchMoodTheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    final avatarUrl = user?.avatarUrl;
    final initials = switch (user) {
      AuthUser(:final displayName?) when displayName.isNotEmpty =>
        displayName.trim()[0].toUpperCase(),
      AuthUser(:final email) when email.isNotEmpty => email[0].toUpperCase(),
      _ => 'UR',
    };

    return Container(
      width: 74,
      height: 74,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: moodTheme.halo,
        border: Border.all(color: moodTheme.accent),
        image: avatarUrl != null
            ? DecorationImage(
                image: CachedNetworkImageProvider(avatarUrl),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: avatarUrl == null
          ? Center(
              child: Text(
                initials,
                style: textTheme.titleLarge?.copyWith(color: moodTheme.accent),
              ),
            )
          : null,
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

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
              Icon(icon, size: 20, color: color ?? colors.smoke),
              const SizedBox(width: StitchSpacing.md),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: color),
              ),
              const Spacer(),
              Icon(Icons.chevron_right, size: 20, color: colors.smoke),
            ],
          ),
        ),
      ),
    );
  }
}
