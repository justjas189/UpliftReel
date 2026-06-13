import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/models/movie.dart';

/// Launches a movie trailer with graceful degradation so the button is
/// never a dead end:
///
/// 1. No [Movie.trailerUrl] → a YouTube search for the title instead.
/// 2. External app intent (YouTube app) — preferred.
/// 3. In-app browser view (Android Custom Tab / SFSafariViewController)
///    when package-visibility rules or device policy block the external
///    intent.
/// 4. Platform default as the last launcher attempt.
/// 5. All launchers failed → snackbar, never a silent no-op.
Future<void> launchTrailer(BuildContext context, Movie movie) async {
  final uri = Uri.parse(
    movie.trailerUrl ??
        'https://www.youtube.com/results?search_query='
            '${Uri.encodeQueryComponent('${movie.title} '
            '${movie.releaseYear > 0 ? movie.releaseYear : ''} trailer')}',
  );

  const modes = [
    LaunchMode.externalApplication,
    LaunchMode.inAppBrowserView,
    LaunchMode.platformDefault,
  ];

  for (final mode in modes) {
    try {
      if (await launchUrl(uri, mode: mode)) return;
    } on Exception {
      // Try the next mode.
    }
  }

  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Could not open the trailer on this device.')),
  );
}
