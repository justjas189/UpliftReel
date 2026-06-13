import 'package:flutter/material.dart';

/// Static Stitch 2.0 palette. Warm-violet blacks keep poster art vivid;
/// ember amber is the projector-lamp primary. Mood neons live in
/// [StitchMoodTheme], never here.
class StitchColors extends ThemeExtension<StitchColors> {
  const StitchColors({
    required this.voidBlack,
    required this.charcoal,
    required this.graphite,
    required this.ember,
    required this.burntAmber,
    required this.parchment,
    required this.smoke,
    required this.hairline,
    required this.success,
    required this.danger,
  });

  /// App background.
  final Color voidBlack;

  /// Surface elevation 1: headers, sheets.
  final Color charcoal;

  /// Surface elevation 2: cards, tiles.
  final Color graphite;

  /// Primary action color.
  final Color ember;

  /// Pressed / deep variant of ember.
  final Color burntAmber;

  /// Primary text.
  final Color parchment;

  /// Secondary text.
  final Color smoke;

  /// Borders and dividers.
  final Color hairline;

  final Color success;
  final Color danger;

  static const StitchColors dark = StitchColors(
    voidBlack: Color(0xFF0E0D11),
    charcoal: Color(0xFF1A181F),
    graphite: Color(0xFF272330),
    ember: Color(0xFFE89B3C),
    burntAmber: Color(0xFFB4621B),
    parchment: Color(0xFFF2EDE4),
    smoke: Color(0xFF9B95A6),
    hairline: Color(0xFF36323F),
    success: Color(0xFF5DD39E),
    danger: Color(0xFFE85C5C),
  );

  static StitchColors of(BuildContext context) =>
      Theme.of(context).extension<StitchColors>()!;

  @override
  StitchColors copyWith({
    Color? voidBlack,
    Color? charcoal,
    Color? graphite,
    Color? ember,
    Color? burntAmber,
    Color? parchment,
    Color? smoke,
    Color? hairline,
    Color? success,
    Color? danger,
  }) {
    return StitchColors(
      voidBlack: voidBlack ?? this.voidBlack,
      charcoal: charcoal ?? this.charcoal,
      graphite: graphite ?? this.graphite,
      ember: ember ?? this.ember,
      burntAmber: burntAmber ?? this.burntAmber,
      parchment: parchment ?? this.parchment,
      smoke: smoke ?? this.smoke,
      hairline: hairline ?? this.hairline,
      success: success ?? this.success,
      danger: danger ?? this.danger,
    );
  }

  @override
  StitchColors lerp(ThemeExtension<StitchColors>? other, double t) {
    if (other is! StitchColors) return this;
    return StitchColors(
      voidBlack: Color.lerp(voidBlack, other.voidBlack, t)!,
      charcoal: Color.lerp(charcoal, other.charcoal, t)!,
      graphite: Color.lerp(graphite, other.graphite, t)!,
      ember: Color.lerp(ember, other.ember, t)!,
      burntAmber: Color.lerp(burntAmber, other.burntAmber, t)!,
      parchment: Color.lerp(parchment, other.parchment, t)!,
      smoke: Color.lerp(smoke, other.smoke, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      success: Color.lerp(success, other.success, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}
