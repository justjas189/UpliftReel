import 'package:freezed_annotation/freezed_annotation.dart';

part 'tmdb_movie_dto.freezed.dart';
part 'tmdb_movie_dto.g.dart';

/// Wire format of one entry in TMDB /movie/popular results.
/// Ported from legacy TMDBMovie (src/services/tmdb.ts).
@freezed
abstract class TmdbMovieDto with _$TmdbMovieDto {
  const factory TmdbMovieDto({
    required int id,
    required String title,
    @Default('') String overview,
    @JsonKey(name: 'poster_path') String? posterPath,
    @JsonKey(name: 'backdrop_path') String? backdropPath,
    @JsonKey(name: 'release_date') @Default('') String releaseDate,
    @JsonKey(name: 'vote_average') @Default(0) double voteAverage,
    @JsonKey(name: 'genre_ids') @Default([]) List<int> genreIds,
  }) = _TmdbMovieDto;

  factory TmdbMovieDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbMovieDtoFromJson(json);
}
