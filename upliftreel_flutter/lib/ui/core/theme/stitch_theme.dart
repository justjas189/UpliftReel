import 'package:flutter/material.dart';

import 'stitch_colors.dart';
import 'stitch_mood_theme.dart';
import 'stitch_tokens.dart';
import 'stitch_typography.dart';

export 'stitch_colors.dart';
export 'stitch_mood_theme.dart';
export 'stitch_tokens.dart';
export 'stitch_typography.dart';

/// Assembles the dark-first Stitch 2.0 ThemeData. Rebuild with a new [mood]
/// and MaterialApp's AnimatedTheme handles the ambience crossfade.
abstract final class StitchTheme {
  static ThemeData dark({StitchMood mood = StitchMood.neutral}) {
    const colors = StitchColors.dark;
    final moodTheme = StitchMoodTheme.fromMood(mood);
    final textTheme = StitchTypography.textTheme(
      primary: colors.parchment,
      secondary: colors.smoke,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: colors.voidBlack,
      splashFactory: InkSparkle.splashFactory,
      colorScheme: ColorScheme.dark(
        primary: colors.ember,
        onPrimary: colors.voidBlack,
        secondary: moodTheme.accent,
        onSecondary: colors.voidBlack,
        surface: colors.charcoal,
        onSurface: colors.parchment,
        surfaceContainerHighest: colors.graphite,
        error: colors.danger,
        outline: colors.hairline,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: colors.graphite,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(StitchRadius.lg),
          side: const BorderSide(color: Color(0xFF36323F)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF36323F),
        thickness: 1,
        space: 1,
      ),
      extensions: [colors, moodTheme],
    );
  }
}
