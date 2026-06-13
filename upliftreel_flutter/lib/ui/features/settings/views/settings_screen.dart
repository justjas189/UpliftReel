import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../state/preferences_controller.dart';
import '../../../../state/providers.dart';
import '../../../../state/recommendation_controller.dart';
import '../../../../state/watched_movies_controller.dart';
import '../../../core/theme/stitch_theme.dart';

/// Legacy Settings had two switches that controlled nothing (local state,
/// never persisted). Dropped; this screen only shows real controls.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmClearHistory(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear history'),
        content: const Text(
          'Delete all recommendations and your watched list? '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(historyRepositoryProvider).clearAll();
    ref.invalidate(watchedMoviesProvider);
    ref.invalidate(recommendationControllerProvider);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('History cleared')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = StitchColors.of(context);
    final moodTheme = StitchMoodTheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    final reminderTime =
        ref.watch(preferencesControllerProvider).value?.notificationTime;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(StitchSpacing.base),
        children: [
          Text('REMINDER', style: textTheme.labelSmall),
          const SizedBox(height: StitchSpacing.sm),
          _SettingsTile(
            leading: Icons.notifications_none,
            title: 'Daily reminder at ${reminderTime ?? '—'}',
            trailing: Text(
              'Edit in Preferences',
              style:
                  textTheme.labelLarge?.copyWith(color: moodTheme.accent),
            ),
            onTap: () => context.go('/preferences'),
          ),
          const SizedBox(height: StitchSpacing.xl),
          Text('DATA', style: textTheme.labelSmall),
          const SizedBox(height: StitchSpacing.sm),
          _SettingsTile(
            leading: Icons.delete_outline,
            title: 'Clear history',
            titleColor: colors.danger,
            onTap: () => _confirmClearHistory(context, ref),
          ),
          const SizedBox(height: StitchSpacing.xl),
          Text('ABOUT', style: textTheme.labelSmall),
          const SizedBox(height: StitchSpacing.sm),
          _SettingsTile(
            leading: Icons.movie_outlined,
            title: 'Uplift Reel 1.0.0 · Stitch 2.0',
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.leading,
    required this.title,
    this.titleColor,
    this.trailing,
    this.onTap,
  });

  final IconData leading;
  final String title;
  final Color? titleColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = StitchColors.of(context);

    return GestureDetector(
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
            Icon(leading, size: 20, color: titleColor ?? colors.smoke),
            const SizedBox(width: StitchSpacing.md),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: titleColor ?? colors.parchment,
                    ),
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
