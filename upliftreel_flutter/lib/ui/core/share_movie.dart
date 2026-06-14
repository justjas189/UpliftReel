import 'package:share_plus/share_plus.dart';

import '../../domain/models/movie.dart';

/// Public TMDB page for [movie]. [Movie.id] is stored as `tmdb-<numericId>`
/// (see `MovieRepository`), so we strip the prefix to land on the canonical
/// URL. Messaging apps scrape this page's Open Graph tags to render a rich
/// preview card (poster + title), which is why we share a URL rather than an
/// attached image file — image attachments make some apps (e.g. Messenger)
/// drop our text.
String _tmdbUrl(Movie movie) {
  const prefix = 'tmdb-';
  final id = movie.id.startsWith(prefix)
      ? movie.id.substring(prefix.length)
      : movie.id;
  return 'https://www.themoviedb.org/movie/$id';
}

/// Clean, readable share body: title, year, IMDb rating, tagline, our sign-off,
/// then the TMDB URL on its own final line so the platform/messaging app
/// generates the link preview from TMDB's OG tags.
String _shareText(Movie movie) {
  final buffer = StringBuffer()
    ..writeln('🎬 ${movie.title} (${movie.releaseYear})')
    ..writeln('★ IMDb ${movie.imdbRating.toStringAsFixed(1)}');

  final tagline = movie.tagline;
  if (tagline != null && tagline.isNotEmpty) {
    buffer
      ..writeln()
      ..writeln('“$tagline”');
  }

  buffer
    ..writeln()
    ..writeln('— Shared from Uplift Reel')
    ..write(_tmdbUrl(movie));

  return buffer.toString();
}

/// Email-style subject line: `Title (Year) - Uplift Reel Pick`. Surfaced by
/// apps that read the subject (email, some messengers) alongside [text].
String _shareSubject(Movie movie) =>
    '${movie.title} (${movie.releaseYear}) - Uplift Reel Pick';

/// Opens the platform share sheet for [movie] as a text-only share.
///
/// The v13 equivalent of `Share.share(text, subject:)`. The TMDB URL embedded
/// in [text] drives the rich link preview (poster + title) via Open Graph —
/// no local image download/attachment, so multipart-hostile apps keep our copy.
Future<void> shareMovie(Movie movie) {
  return SharePlus.instance.share(
    ShareParams(text: _shareText(movie), subject: _shareSubject(movie)),
  );
}
