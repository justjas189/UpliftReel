import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/stitch_theme.dart';

/// Shimmer placeholder block. Compose these into layout-shaped skeletons
/// instead of legacy's centered ActivityIndicator.
class StitchSkeleton extends StatelessWidget {
  const StitchSkeleton({
    super.key,
    required this.height,
    this.width = double.infinity,
    this.radius = StitchRadius.md,
  });

  final double height;
  final double width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colors = StitchColors.of(context);

    return Shimmer.fromColors(
      baseColor: colors.graphite,
      highlightColor: Color.alphaBlend(
        colors.parchment.withValues(alpha: 0.08),
        colors.graphite,
      ),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: colors.graphite,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
