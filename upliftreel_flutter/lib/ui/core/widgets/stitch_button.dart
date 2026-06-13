import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/stitch_theme.dart';

enum StitchButtonVariant {
  /// Ember — the default call to action.
  primary,

  /// Mood accent with glow — the one button allowed to carry the neon.
  mood,

  /// Hairline border, parchment text.
  outline,

  /// Bare text in smoke.
  ghost,
}

/// Stitch 2.0 button: 120ms scale-press, light haptic on tap, loading state.
/// Replaces the legacy StitchButton (TouchableOpacity, no feedback).
class StitchButton extends StatefulWidget {
  const StitchButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = StitchButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final StitchButtonVariant variant;
  final IconData? icon;
  final bool loading;
  final bool expand;

  @override
  State<StitchButton> createState() => _StitchButtonState();
}

class _StitchButtonState extends State<StitchButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.loading;

  void _setPressed(bool value) {
    if (_enabled && _pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = StitchColors.of(context);
    final moodTheme = StitchMoodTheme.of(context);

    final (Color? background, Color foreground, BoxBorder? border,
        List<BoxShadow> shadow) = switch (widget.variant) {
      StitchButtonVariant.primary => (
          colors.ember,
          colors.voidBlack,
          null,
          const <BoxShadow>[],
        ),
      StitchButtonVariant.mood => (
          moodTheme.accent,
          colors.voidBlack,
          null,
          [BoxShadow(color: moodTheme.glow, blurRadius: 18)],
        ),
      StitchButtonVariant.outline => (
          null,
          colors.parchment,
          Border.all(color: colors.hairline),
          const <BoxShadow>[],
        ),
      StitchButtonVariant.ghost => (
          null,
          colors.smoke,
          null,
          const <BoxShadow>[],
        ),
    };

    final label = Text(
      widget.label,
      style: Theme.of(context)
          .textTheme
          .labelLarge
          ?.copyWith(color: foreground),
    );

    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: _enabled
            ? () {
                HapticFeedback.lightImpact();
                widget.onPressed!();
              }
            : null,
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1,
          duration: StitchMotion.tap,
          curve: StitchMotion.easeOut,
          child: AnimatedOpacity(
            opacity: _enabled || widget.loading ? 1 : 0.55,
            duration: StitchMotion.base,
            child: Container(
              height: 52,
              width: widget.expand ? double.infinity : null,
              padding:
                  const EdgeInsets.symmetric(horizontal: StitchSpacing.xl),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(StitchRadius.md),
                border: border,
                boxShadow: shadow,
              ),
              child: Row(
                mainAxisSize:
                    widget.expand ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.loading)
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: foreground,
                      ),
                    )
                  else ...[
                    if (widget.icon != null) ...[
                      Icon(widget.icon, size: 18, color: foreground),
                      const SizedBox(width: StitchSpacing.sm),
                    ],
                    label,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
