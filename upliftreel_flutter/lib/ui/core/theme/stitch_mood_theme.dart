import 'package:flutter/material.dart';

import '../../../domain/models/mood.dart';
import 'stitch_colors.dart';

/// The nine ambience states. Eight map 1:1 to the legacy MoodEmoji set
/// (MoodDetectionService.getMoodColor); neutral is the resting ember state.
enum StitchMood {
  neutral,
  happy,
  excited,
  relaxed,
  romantic,
  suspense,
  introspective,
  adventurous,
  curious,
}

/// Domain mood → ambience state. The single mapping point between the
/// engine's Mood and the theme's StitchMood.
StitchMood stitchMoodFor(Mood mood) {
  return switch (mood) {
    Mood.happy => StitchMood.happy,
    Mood.suspense => StitchMood.suspense,
    Mood.introspective => StitchMood.introspective,
    Mood.excited => StitchMood.excited,
    Mood.romantic => StitchMood.romantic,
    Mood.adventurous => StitchMood.adventurous,
    Mood.relaxed => StitchMood.relaxed,
    Mood.curious => StitchMood.curious,
  };
}

/// Mood-reactive ambience — the Stitch 2.0 signature element.
///
/// Carries the only neon in the app. Because [lerp] is real, MaterialApp's
/// built-in AnimatedTheme makes every consumer breathe to a new mood color
/// with zero per-widget animation code.
class StitchMoodTheme extends ThemeExtension<StitchMoodTheme> {
  const StitchMoodTheme({
    required this.accent,
    required this.glow,
    required this.halo,
  });

  /// Full-strength neon: selection states, highlights, progress.
  final Color accent;

  /// Accent at shadow strength: BoxShadow color for glows.
  final Color glow;

  /// Accent pre-blended into the background: ambient washes, gradients.
  final Color halo;

  /// Legacy hues saturation-tuned for the dark charcoal base.
  static const Map<StitchMood, Color> _neon = {
    StitchMood.neutral: Color(0xFFE89B3C), // ember — rest state
    StitchMood.happy: Color(0xFFFFD24A), // was #FFD700
    StitchMood.excited: Color(0xFFFF7847), // was #FF6B35
    StitchMood.relaxed: Color(0xFF3DE8DC), // was #4ECDC4
    StitchMood.romantic: Color(0xFFFF6FC0), // was #FF69B4
    StitchMood.suspense: Color(0xFF9D4DFF), // was #8A2BE2
    StitchMood.introspective: Color(0xFF8E9BB3), // was #708090
    StitchMood.adventurous: Color(0xFF4DE84D), // was #32CD32
    StitchMood.curious: Color(0xFFFFB52E), // was #FFA500
  };

  /// The raw neon for a mood — for UI that previews a mood other than the
  /// currently applied one (e.g. each mood card tinted with its own hue).
  static Color neonOf(StitchMood mood) => _neon[mood]!;

  factory StitchMoodTheme.fromMood(StitchMood mood) {
    final neon = _neon[mood]!;
    return StitchMoodTheme(
      accent: neon,
      glow: neon.withValues(alpha: 0.35),
      halo: Color.alphaBlend(
        neon.withValues(alpha: 0.08),
        StitchColors.dark.voidBlack,
      ),
    );
  }

  static StitchMoodTheme of(BuildContext context) =>
      Theme.of(context).extension<StitchMoodTheme>()!;

  @override
  StitchMoodTheme copyWith({Color? accent, Color? glow, Color? halo}) {
    return StitchMoodTheme(
      accent: accent ?? this.accent,
      glow: glow ?? this.glow,
      halo: halo ?? this.halo,
    );
  }

  @override
  StitchMoodTheme lerp(ThemeExtension<StitchMoodTheme>? other, double t) {
    if (other is! StitchMoodTheme) return this;
    return StitchMoodTheme(
      accent: Color.lerp(accent, other.accent, t)!,
      glow: Color.lerp(glow, other.glow, t)!,
      halo: Color.lerp(halo, other.halo, t)!,
    );
  }
}
