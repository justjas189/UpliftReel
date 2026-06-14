import 'package:flutter/material.dart';

import '../../../domain/models/movie.dart';
import '../share_movie.dart';
import 'stitch_button.dart';

/// Share action that opens the platform share sheet for [movie].
///
/// Text-only share: the embedded TMDB URL drives the rich link preview via
/// Open Graph, so there's no poster download and no loading state — the sheet
/// opens immediately.
class ShareMovieButton extends StatelessWidget {
  const ShareMovieButton({
    super.key,
    required this.movie,
    this.variant = StitchButtonVariant.outline,
    this.icon = Icons.ios_share,
    this.expand = false,
  });

  final Movie movie;
  final StitchButtonVariant variant;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return StitchButton(
      label: 'Share',
      icon: icon,
      variant: variant,
      expand: expand,
      onPressed: () => shareMovie(movie),
    );
  }
}
