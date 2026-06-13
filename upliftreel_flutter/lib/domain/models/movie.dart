import 'package:freezed_annotation/freezed_annotation.dart';

part 'movie.freezed.dart';
part 'movie.g.dart';

/// Ported 1:1 from legacy `Genre` (src/types/index.ts). [label] preserves the
/// legacy wire strings used in explanations and TMDB mapping.
enum Genre {
  @JsonValue('comedy')
  comedy('comedy'),
  @JsonValue('drama')
  drama('drama'),
  @JsonValue('thriller')
  thriller('thriller'),
  @JsonValue('horror')
  horror('horror'),
  @JsonValue('sci-fi')
  scifi('sci-fi'),
  @JsonValue('romance')
  romance('romance'),
  @JsonValue('action')
  action('action'),
  @JsonValue('documentary')
  documentary('documentary'),
  @JsonValue('adventure')
  adventure('adventure'),
  @JsonValue('fantasy')
  fantasy('fantasy'),
  @JsonValue('mystery')
  mystery('mystery'),
  @JsonValue('animation')
  animation('animation');

  const Genre(this.label);
  final String label;
}

/// Ported 1:1 from legacy `MoodTag`.
enum MoodTag {
  @JsonValue('exciting')
  exciting('exciting'),
  @JsonValue('thought-provoking')
  thoughtProvoking('thought-provoking'),
  @JsonValue('scary')
  scary('scary'),
  @JsonValue('romantic')
  romantic('romantic'),
  @JsonValue('funny')
  funny('funny'),
  @JsonValue('uplifting')
  uplifting('uplifting'),
  @JsonValue('intense')
  intense('intense'),
  @JsonValue('relaxing')
  relaxing('relaxing'),
  @JsonValue('nostalgic')
  nostalgic('nostalgic'),
  @JsonValue('inspiring')
  inspiring('inspiring');

  const MoodTag(this.label);
  final String label;
}

@freezed
abstract class Movie with _$Movie {
  const factory Movie({
    required String id,
    required String title,
    required List<Genre> genres,
    required double imdbRating,
    required int releaseYear,

    /// Minutes.
    required int runtime,
    required String synopsis,
    required String director,
    required List<String> actors,
    required List<MoodTag> moodTags,
    String? trailerUrl,
    String? posterUrl,
    String? backdropUrl,
  }) = _Movie;

  factory Movie.fromJson(Map<String, dynamic> json) => _$MovieFromJson(json);
}
