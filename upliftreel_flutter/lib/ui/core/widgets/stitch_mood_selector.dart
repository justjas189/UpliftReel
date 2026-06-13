import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../domain/models/mood.dart';
import '../theme/stitch_mood_icons.dart';
import '../theme/stitch_theme.dart';

/// Immersive mood picker: each card whispers its own neon at rest and
/// floods with it when selected. Controlled — selection state lives above.
class StitchMoodSelector extends StatelessWidget {
  const StitchMoodSelector({
    super.key,
    required this.selectedMood,
    required this.intensity,
    required this.seriousness,
    required this.onMoodChanged,
    required this.onIntensityChanged,
    required this.onSeriousnessChanged,
  });

  final Mood? selectedMood;

  /// 1–10 (legacy energy presets: 3 / 6 / 9).
  final int intensity;

  /// 1 = fun … 10 = serious.
  final int seriousness;

  final ValueChanged<Mood> onMoodChanged;
  final ValueChanged<int> onIntensityChanged;
  final ValueChanged<int> onSeriousnessChanged;

  /// Legacy MOOD_OPTIONS genre subtitles, unchanged.
  static const Map<Mood, String> genreHints = {
    Mood.happy: 'Comedy, Feel-Good',
    Mood.relaxed: 'Drama, Nature',
    Mood.excited: 'Action, Adventure',
    Mood.introspective: 'Documentary, Sci-Fi',
    Mood.suspense: 'Thriller, Horror',
    Mood.romantic: 'Romance, Drama',
    Mood.adventurous: 'Adventure, Fantasy',
    Mood.curious: 'Mystery, History',
  };

  /// Legacy ENERGY_OPTIONS, unchanged values.
  static const List<(String, int)> energyOptions = [
    ('Low Key', 3),
    ('Balanced', 6),
    ('High Energy', 9),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // A plain two-column layout, not GridView: a nested Scrollable (even
    // non-scrolling) swallows Scrollable.ensureVisible, and shrinkWrap
    // grids lay out eagerly anyway.
    final cards =
        [
              for (final mood in Mood.values)
                _MoodCard(
                  mood: mood,
                  selected: mood == selectedMood,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onMoodChanged(mood);
                  },
                ),
            ]
            .animate(interval: 40.ms)
            .fadeIn(duration: StitchMotion.base)
            .scaleXY(begin: 0.97, end: 1, duration: StitchMotion.base);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < cards.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: StitchSpacing.sm),
            child: Row(
              children: [
                Expanded(child: cards[i]),
                const SizedBox(width: StitchSpacing.sm),
                Expanded(
                  child: i + 1 < cards.length
                      ? cards[i + 1]
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        const SizedBox(height: StitchSpacing.xl),
        Text('ENERGY', style: textTheme.labelSmall),
        const SizedBox(height: StitchSpacing.sm),
        _EnergyRow(intensity: intensity, onChanged: onIntensityChanged),
        const SizedBox(height: StitchSpacing.xl),
        Text('TONE', style: textTheme.labelSmall),
        _ToneSlider(seriousness: seriousness, onChanged: onSeriousnessChanged),
      ],
    );
  }
}

class _MoodCard extends StatelessWidget {
  const _MoodCard({
    required this.mood,
    required this.selected,
    required this.onTap,
  });

  final Mood mood;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = StitchColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final neon = StitchMoodTheme.neonOf(stitchMoodFor(mood));

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: StitchMotion.base,
        curve: StitchMotion.easeOut,
        padding: const EdgeInsets.all(StitchSpacing.md),
        decoration: BoxDecoration(
          color: selected
              ? Color.alphaBlend(neon.withValues(alpha: 0.14), colors.charcoal)
              : colors.charcoal,
          borderRadius: BorderRadius.circular(StitchRadius.lg),
          border: Border.all(
            color: selected ? neon : colors.hairline,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [BoxShadow(color: neon.withValues(alpha: 0.3), blurRadius: 18)]
              : const [],
        ),
        child: Row(
          children: [
            StitchMoodBadge(mood: mood, neon: neon, active: selected),
            const SizedBox(width: StitchSpacing.md),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mood.label,
                    style: textTheme.titleMedium?.copyWith(
                      color: selected ? neon : colors.parchment,
                    ),
                  ),
                  Text(
                    StitchMoodSelector.genreHints[mood]!,
                    style: textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // The rest-state whisper of this card's own hue.
            if (!selected)
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: neon.withValues(alpha: 0.6),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EnergyRow extends StatelessWidget {
  const _EnergyRow({required this.intensity, required this.onChanged});

  final int intensity;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = StitchColors.of(context);
    final moodTheme = StitchMoodTheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        for (final (label, value) in StitchMoodSelector.energyOptions) ...[
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onChanged(value);
              },
              child: AnimatedContainer(
                duration: StitchMotion.base,
                curve: StitchMotion.easeOut,
                padding: const EdgeInsets.symmetric(vertical: StitchSpacing.md),
                decoration: BoxDecoration(
                  color: intensity == value ? moodTheme.halo : colors.charcoal,
                  borderRadius: BorderRadius.circular(StitchRadius.md),
                  border: Border.all(
                    color: intensity == value
                        ? moodTheme.accent
                        : colors.hairline,
                  ),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: textTheme.labelLarge?.copyWith(
                    color: intensity == value ? moodTheme.accent : colors.smoke,
                  ),
                ),
              ),
            ),
          ),
          if (value != StitchMoodSelector.energyOptions.last.$2)
            const SizedBox(width: StitchSpacing.sm),
        ],
      ],
    );
  }
}

class _ToneSlider extends StatelessWidget {
  const _ToneSlider({required this.seriousness, required this.onChanged});

  final int seriousness;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = StitchColors.of(context);
    final moodTheme = StitchMoodTheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Slider(
          value: seriousness.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          activeColor: moodTheme.accent,
          inactiveColor: colors.graphite,
          onChanged: (value) => onChanged(value.round()),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('FUN', style: textTheme.labelSmall),
            Text(
              '$seriousness / 10',
              style: StitchTypography.data(
                color: moodTheme.accent,
                fontSize: 12,
              ),
            ),
            Text('SERIOUS', style: textTheme.labelSmall),
          ],
        ),
      ],
    );
  }
}
