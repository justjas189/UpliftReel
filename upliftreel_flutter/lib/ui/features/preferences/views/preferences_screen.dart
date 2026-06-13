import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../domain/models/movie.dart';
import '../../../../domain/models/user_preferences.dart';
import '../../../../state/preferences_controller.dart';
import '../../../core/format.dart';
import '../../../core/theme/stitch_theme.dart';
import '../../../core/widgets/stitch_button.dart';
import '../../../core/widgets/stitch_movie_card.dart';

/// Legacy GENRE_OPTIONS order, unchanged.
const List<Genre> _genreOrder = [
  Genre.comedy,
  Genre.drama,
  Genre.action,
  Genre.thriller,
  Genre.horror,
  Genre.romance,
  Genre.scifi,
  Genre.adventure,
  Genre.fantasy,
  Genre.mystery,
  Genre.animation,
  Genre.documentary,
];

class _RatingTier {
  const _RatingTier(this.label, this.detail, this.value);

  final String label;
  final String detail;
  final double value;
}

/// Legacy RATING_OPTIONS, except "Any" now carries 1.0: legacy saved 0,
/// validation clamped it to 1 on disk, and reload matched no tier.
const List<_RatingTier> _ratingTiers = [
  _RatingTier('Any rating', 'All movies', 1.0),
  _RatingTier('Decent+', '5.0+ IMDb', 5.0),
  _RatingTier('Good+', '6.0+ IMDb', 6.0),
  _RatingTier('Great+', '7.0+ IMDb', 7.0),
  _RatingTier('Excellent+', '8.0+ IMDb', 8.0),
  _RatingTier('Masterpiece', '9.0+ IMDb', 9.0),
];

const List<(String, int?)> _runtimePresets = [
  ('< 90 min', 90),
  ('< 2 h', 120),
  ('< 3 h', 180),
  ('Any length', null),
];

class PreferencesScreen extends ConsumerStatefulWidget {
  const PreferencesScreen({super.key});

  @override
  ConsumerState<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends ConsumerState<PreferencesScreen> {
  UserPreferences? _draft;
  bool _saving = false;

  void _edit(UserPreferences next) {
    HapticFeedback.selectionClick();
    setState(() => _draft = next);
  }

  Future<void> _save(UserPreferences draft) async {
    setState(() => _saving = true);
    try {
      await ref.read(preferencesControllerProvider.notifier).save(draft);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Preferences updated'),
          action: SnackBarAction(
            label: 'Go Home',
            onPressed: () => context.go('/home'),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset preferences'),
        content: const Text('Restore your default profile settings?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(preferencesControllerProvider.notifier).reset();
    // The ref.listen reseed only fires when the persisted value changes —
    // resetting with unsaved edits over unchanged defaults wouldn't, leaving
    // a stale draft. Drop it explicitly; build reseeds from persisted.
    if (mounted) setState(() => _draft = null);
  }

  Future<void> _pickReminderTime(UserPreferences draft) async {
    final parts = draft.notificationTime.split(':');
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      ),
    );
    if (picked == null) return;
    final formatted =
        '${picked.hour.toString().padLeft(2, '0')}:'
        '${picked.minute.toString().padLeft(2, '0')}';
    _edit(draft.copyWith(notificationTime: formatted));
  }

  @override
  Widget build(BuildContext context) {
    final colors = StitchColors.of(context);
    final moodTheme = StitchMoodTheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    final persistedAsync = ref.watch(preferencesControllerProvider);

    // Reseed the draft when persistence changes underneath us (reset, save).
    ref.listen(preferencesControllerProvider, (previous, next) {
      final value = next.value;
      if (value != null && value != previous?.value) {
        setState(() => _draft = value);
      }
    });

    final persisted = persistedAsync.value;
    if (persisted == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final draft = _draft ??= persisted;

    final dirty = draft != persisted;
    final hasGenres = draft.selectedGenres.isNotEmpty;
    final tier = _ratingTiers
        .where((t) => t.value == draft.minRating)
        .firstOrNull;

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
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              StitchSpacing.base,
              StitchSpacing.xl,
              StitchSpacing.base,
              StitchSpacing.xxxl,
            ),
            children: [
              Text('PREFERENCES', style: textTheme.labelSmall),
              const SizedBox(height: StitchSpacing.sm),
              Text('Tune your taste', style: textTheme.displayMedium),
              const SizedBox(height: StitchSpacing.xs),
              Text(
                'Tune your recommendation style.',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: StitchSpacing.xl),
              Text('FAVORITE GENRES', style: textTheme.labelSmall),
              const SizedBox(height: StitchSpacing.sm),
              Wrap(
                spacing: StitchSpacing.sm,
                runSpacing: StitchSpacing.sm,
                children: [
                  for (final genre in _genreOrder)
                    _GenrePill(
                      label: titleCase(genre.label),
                      selected: draft.selectedGenres.contains(genre),
                      onTap: () {
                        final next = draft.selectedGenres.contains(genre)
                            ? draft.selectedGenres
                                  .where((g) => g != genre)
                                  .toList()
                            : [...draft.selectedGenres, genre];
                        _edit(draft.copyWith(selectedGenres: next));
                      },
                    ),
                ],
              ),
              if (!hasGenres) ...[
                const SizedBox(height: StitchSpacing.sm),
                Text(
                  'Choose at least one genre.',
                  style: textTheme.bodySmall?.copyWith(color: colors.danger),
                ),
              ],
              const SizedBox(height: StitchSpacing.xl),
              Text('MINIMUM IMDB RATING', style: textTheme.labelSmall),
              const SizedBox(height: StitchSpacing.sm),
              for (final option in _ratingTiers)
                Padding(
                  padding: const EdgeInsets.only(bottom: StitchSpacing.sm),
                  child: _RatingTile(
                    tier: option,
                    selected: option.value == draft.minRating,
                    onTap: () => _edit(draft.copyWith(minRating: option.value)),
                  ),
                ),
              const SizedBox(height: StitchSpacing.base),
              Text('MAX RUNTIME', style: textTheme.labelSmall),
              const SizedBox(height: StitchSpacing.sm),
              Wrap(
                spacing: StitchSpacing.sm,
                runSpacing: StitchSpacing.sm,
                children: [
                  for (final (label, minutes) in _runtimePresets)
                    _GenrePill(
                      label: label,
                      selected: draft.maxRuntime == minutes,
                      onTap: () => _edit(draft.copyWith(maxRuntime: minutes)),
                    ),
                ],
              ),
              const SizedBox(height: StitchSpacing.xl),
              Text('PREFERRED MOVIE LANGUAGE', style: textTheme.labelSmall),
              const SizedBox(height: StitchSpacing.sm),
              Wrap(
                spacing: StitchSpacing.sm,
                runSpacing: StitchSpacing.sm,
                children: [
                  for (final entry in kPreferredLanguages.entries)
                    _GenrePill(
                      label: entry.value,
                      selected: draft.preferredLanguage == entry.key,
                      onTap: () =>
                          _edit(draft.copyWith(preferredLanguage: entry.key)),
                    ),
                ],
              ),
              const SizedBox(height: StitchSpacing.xl),
              Text('DAILY REMINDER', style: textTheme.labelSmall),
              const SizedBox(height: StitchSpacing.sm),
              GestureDetector(
                onTap: () => _pickReminderTime(draft),
                child: Container(
                  padding: const EdgeInsets.all(StitchSpacing.base),
                  decoration: BoxDecoration(
                    color: colors.charcoal,
                    borderRadius: BorderRadius.circular(StitchRadius.md),
                    border: Border.all(color: colors.hairline),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 20,
                        color: colors.smoke,
                      ),
                      const SizedBox(width: StitchSpacing.md),
                      Text(
                        draft.notificationTime,
                        style: StitchTypography.data(
                          color: colors.parchment,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Change',
                        style: textTheme.labelLarge?.copyWith(
                          color: moodTheme.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: StitchSpacing.xl),
              StitchMovieCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CURRENT SETUP', style: textTheme.labelSmall),
                    const SizedBox(height: StitchSpacing.sm),
                    _SummaryRow(
                      text: '${draft.selectedGenres.length} genres selected',
                    ),
                    _SummaryRow(
                      text: tier != null
                          ? '${tier.label} (${tier.detail})'
                          : 'Min rating ${draft.minRating}',
                    ),
                    _SummaryRow(
                      text: draft.maxRuntime != null
                          ? 'Up to ${formatRuntime(draft.maxRuntime!)}'
                          : 'Any runtime',
                    ),
                    _SummaryRow(
                      text:
                          '${kPreferredLanguages[draft.preferredLanguage] ?? draft.preferredLanguage} movies',
                    ),
                    _SummaryRow(text: 'Reminder at ${draft.notificationTime}'),
                  ],
                ),
              ),
              const SizedBox(height: StitchSpacing.base),
              StitchButton(
                label: 'Save changes',
                expand: true,
                loading: _saving,
                onPressed: dirty && hasGenres ? () => _save(draft) : null,
              ),
              const SizedBox(height: StitchSpacing.xs),
              StitchButton(
                label: 'Reset defaults',
                variant: StitchButtonVariant.ghost,
                expand: true,
                onPressed: _confirmReset,
              ),
              const SizedBox(height: StitchSpacing.base),
              StitchMovieCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline, color: moodTheme.accent),
                    const SizedBox(width: StitchSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('PRO TIP', style: textTheme.labelSmall),
                          const SizedBox(height: StitchSpacing.xs),
                          Text(
                            'Mixing distinct genres like Comedy and '
                            'Sci-Fi often yields the most unique and '
                            'uplifting movie recommendations.',
                            style: textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenrePill extends StatelessWidget {
  const _GenrePill({
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

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: StitchMotion.base,
        curve: StitchMotion.easeOut,
        padding: const EdgeInsets.symmetric(
          horizontal: StitchSpacing.md,
          vertical: StitchSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected
              ? Color.alphaBlend(
                  colors.ember.withValues(alpha: 0.16),
                  colors.charcoal,
                )
              : colors.charcoal,
          borderRadius: BorderRadius.circular(StitchRadius.full),
          border: Border.all(color: selected ? colors.ember : colors.hairline),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? Icons.check : Icons.add,
              size: 14,
              color: selected ? colors.ember : colors.smoke,
            ),
            const SizedBox(width: StitchSpacing.xs),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: selected ? colors.ember : colors.smoke,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingTile extends StatelessWidget {
  const _RatingTile({
    required this.tier,
    required this.selected,
    required this.onTap,
  });

  final _RatingTier tier;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = StitchColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: StitchMotion.base,
        curve: StitchMotion.easeOut,
        padding: const EdgeInsets.symmetric(
          horizontal: StitchSpacing.base,
          vertical: StitchSpacing.md,
        ),
        decoration: BoxDecoration(
          color: selected
              ? Color.alphaBlend(
                  colors.ember.withValues(alpha: 0.1),
                  colors.charcoal,
                )
              : colors.charcoal,
          borderRadius: BorderRadius.circular(StitchRadius.md),
          border: Border.all(color: selected ? colors.ember : colors.hairline),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tier.label,
                    style: textTheme.titleMedium?.copyWith(
                      color: selected ? colors.ember : colors.parchment,
                    ),
                  ),
                  Text(
                    tier.detail,
                    style: StitchTypography.data(
                      color: colors.smoke,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.ember,
                ),
                child: Icon(Icons.check, size: 16, color: colors.voidBlack),
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = StitchColors.of(context);
    final moodTheme = StitchMoodTheme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: StitchSpacing.xs),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, size: 18, color: moodTheme.accent),
          const SizedBox(width: StitchSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.parchment),
            ),
          ),
        ],
      ),
    );
  }
}
