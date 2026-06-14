import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/era_filter.dart';
import '../../../state/era_filter_controller.dart';
import '../theme/stitch_theme.dart';

/// Horizontal Era Selector chip rail. Reads/sets the transient
/// [eraFilterControllerProvider] and calls [onChanged] so the host can
/// regenerate the pick for the new release window.
class EraSelector extends ConsumerWidget {
  const EraSelector({super.key, this.onChanged});

  /// Fired after the era changes (host triggers a regenerate).
  final ValueChanged<EraFilter>? onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final selected = ref.watch(eraFilterControllerProvider);

    void select(EraFilter era) {
      if (era == selected) return;
      HapticFeedback.selectionClick();
      ref.read(eraFilterControllerProvider.notifier).select(era);
      onChanged?.call(era);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ERA', style: textTheme.labelSmall),
        const SizedBox(height: StitchSpacing.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final era in EraFilter.presets) ...[
                _EraChip(
                  label: era.label,
                  selected: era == selected,
                  onTap: () => select(era),
                ),
                const SizedBox(width: StitchSpacing.sm),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _EraChip extends StatelessWidget {
  const _EraChip({
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
        padding: const EdgeInsets.symmetric(
          horizontal: StitchSpacing.md,
          vertical: StitchSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected
              ? Color.alphaBlend(
                  moodTheme.accent.withValues(alpha: 0.16),
                  colors.charcoal,
                )
              : colors.charcoal,
          borderRadius: BorderRadius.circular(StitchRadius.full),
          border: Border.all(
            color: selected ? moodTheme.accent : colors.hairline,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: selected ? moodTheme.accent : colors.smoke,
          ),
        ),
      ),
    );
  }
}
