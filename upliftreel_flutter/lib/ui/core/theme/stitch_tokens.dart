import 'package:flutter/animation.dart';

/// Spacing scale ported unchanged from legacy StitchDesignSystem (4pt base).
abstract final class StitchSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
}

/// Corner radii ported unchanged from legacy StitchDesignSystem.
abstract final class StitchRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 22;
  static const double full = 999;
}

/// One shared physics language for every micro-interaction.
abstract final class StitchMotion {
  /// Tactile press feedback (button scale, chip select).
  static const Duration tap = Duration(milliseconds: 120);

  /// Standard state transitions.
  static const Duration base = Duration(milliseconds: 240);

  /// Content reveals: cards, staggered lists.
  static const Duration reveal = Duration(milliseconds: 400);

  /// Mood ambience shift — slow enough to read as atmosphere, not a glitch.
  static const Duration ambient = Duration(milliseconds: 900);

  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeInOutCubicEmphasized;
}
