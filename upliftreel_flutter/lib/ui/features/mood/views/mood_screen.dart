import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../domain/models/mood.dart';
import '../../../../domain/mood_suggestions.dart';
import '../../../../state/mood_controller.dart';
import '../../../../state/recommendation_controller.dart';
import '../../../core/theme/stitch_mood_icons.dart';
import '../../../core/theme/stitch_theme.dart';
import '../../../core/widgets/stitch_button.dart';
import '../../../core/widgets/stitch_mood_selector.dart';

class MoodScreen extends ConsumerWidget {
  const MoodScreen({super.key});

  static const int _defaultIntensity = 6; // Legacy 'Balanced'.
  static const int _defaultSeriousness = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = StitchColors.of(context);
    final moodTheme = StitchMoodTheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    final moodInput = ref.watch(moodControllerProvider);
    final generating = ref.watch(recommendationControllerProvider).isLoading;
    final controller = ref.read(moodControllerProvider.notifier);

    void selectMood(Mood mood) {
      controller.select(
        MoodInput(
          mood: mood,
          intensity: moodInput?.intensity ?? _defaultIntensity,
          seriousness: moodInput?.seriousness ?? _defaultSeriousness,
        ),
      );
    }

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
              Text('MOOD', style: textTheme.labelSmall),
              const SizedBox(height: StitchSpacing.sm),
              Text('How do you feel tonight?', style: textTheme.displayMedium),
              const SizedBox(height: StitchSpacing.lg),
              Text("TONIGHT'S SUGGESTIONS", style: textTheme.labelSmall),
              const SizedBox(height: StitchSpacing.sm),
              Wrap(
                spacing: StitchSpacing.sm,
                runSpacing: StitchSpacing.sm,
                children: [
                  for (final suggestion in moodSuggestionsFor(DateTime.now()))
                    _SuggestionPill(
                      suggestion: suggestion,
                      onTap: () => selectMood(suggestion.mood),
                    ),
                ],
              ),
              const SizedBox(height: StitchSpacing.xl),
              StitchMoodSelector(
                selectedMood: moodInput?.mood,
                intensity: moodInput?.intensity ?? _defaultIntensity,
                seriousness: moodInput?.seriousness ?? _defaultSeriousness,
                onMoodChanged: selectMood,
                onIntensityChanged: (value) {
                  if (moodInput != null) {
                    controller.select(moodInput.copyWith(intensity: value));
                  }
                },
                onSeriousnessChanged: (value) {
                  if (moodInput != null) {
                    controller.select(moodInput.copyWith(seriousness: value));
                  }
                },
              ),
              const SizedBox(height: StitchSpacing.xl),
              StitchButton(
                label: 'Find my movie',
                variant: StitchButtonVariant.mood,
                expand: true,
                loading: generating,
                onPressed: moodInput == null
                    ? null
                    : () async {
                        await controller.commit();
                        await ref
                            .read(recommendationControllerProvider.notifier)
                            .generate();
                        if (context.mounted) context.go('/home');
                      },
              ),
              if (moodInput != null)
                StitchButton(
                  label: 'Clear mood',
                  variant: StitchButtonVariant.ghost,
                  expand: true,
                  onPressed: controller.clear,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuggestionPill extends StatelessWidget {
  const _SuggestionPill({required this.suggestion, required this.onTap});

  final MoodSuggestion suggestion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = StitchColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final neon = StitchMoodTheme.neonOf(stitchMoodFor(suggestion.mood));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: StitchSpacing.md,
          vertical: StitchSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: colors.charcoal,
          borderRadius: BorderRadius.circular(StitchRadius.full),
          border: Border.all(color: neon.withValues(alpha: 0.45)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(stitchMoodIcon(suggestion.mood), size: 16, color: neon),
                const SizedBox(width: StitchSpacing.xs),
                Text(suggestion.label, style: textTheme.labelLarge),
              ],
            ),
            Text(suggestion.description, style: textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
