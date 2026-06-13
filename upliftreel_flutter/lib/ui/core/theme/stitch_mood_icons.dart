import 'package:flutter/material.dart';

import '../../../domain/models/mood.dart';

/// Stitch 2.0 mood glyphs: replaces the legacy raw emoji with material
/// icons rendered inside neon-tinted badges. Domain [Mood.emoji] survives
/// as legacy parity data; the UI renders these instead.
IconData stitchMoodIcon(Mood mood) {
  return switch (mood) {
    Mood.happy => Icons.wb_sunny_outlined,
    Mood.suspense => Icons.bolt_outlined,
    Mood.introspective => Icons.nightlight_outlined,
    Mood.excited => Icons.local_fire_department_outlined,
    Mood.romantic => Icons.favorite_outline,
    Mood.adventurous => Icons.explore_outlined,
    Mood.relaxed => Icons.spa_outlined,
    Mood.curious => Icons.psychology_outlined,
  };
}

/// Rounded gradient badge carrying a mood glyph — the standard emoji
/// replacement across mood cards, suggestion pills, and status chips.
class StitchMoodBadge extends StatelessWidget {
  const StitchMoodBadge({
    super.key,
    required this.mood,
    required this.neon,
    this.size = 40,
    this.active = false,
  });

  final Mood mood;

  /// The mood's own neon hue (callers resolve via StitchMoodTheme.neonOf).
  final Color neon;

  final double size;

  /// Active floods the badge with the neon; rest keeps a faint wash.
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: active
              ? [neon.withValues(alpha: 0.32), neon.withValues(alpha: 0.12)]
              : [neon.withValues(alpha: 0.16), neon.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(size * 0.32),
        border: Border.all(color: neon.withValues(alpha: active ? 0.9 : 0.35)),
      ),
      child: Icon(
        stitchMoodIcon(mood),
        size: size * 0.55,
        color: active ? neon : neon.withValues(alpha: 0.85),
      ),
    );
  }
}
