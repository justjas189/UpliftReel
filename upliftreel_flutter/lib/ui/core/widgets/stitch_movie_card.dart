import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/stitch_theme.dart';

/// Glassmorphic surface: blur over the mood halo, hairline edge, faint
/// parchment sheen. Quiet by design — content carries the color.
class StitchMovieCard extends StatelessWidget {
  const StitchMovieCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(StitchSpacing.base),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = StitchColors.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(StitchRadius.lg),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(StitchRadius.lg),
            border: Border.all(
              color: colors.hairline.withValues(alpha: 0.7),
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.alphaBlend(
                  colors.parchment.withValues(alpha: 0.05),
                  colors.charcoal.withValues(alpha: 0.6),
                ),
                colors.charcoal.withValues(alpha: 0.4),
              ],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
