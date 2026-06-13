// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tmdb_movie_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TmdbMovieDto _$TmdbMovieDtoFromJson(Map<String, dynamic> json) =>
    _TmdbMovieDto(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      overview: json['overview'] as String? ?? '',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      releaseDate: json['release_date'] as String? ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
      genreIds:
          (json['genre_ids'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
    );

Map<String, dynamic> _$TmdbMovieDtoToJson(_TmdbMovieDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'overview': instance.overview,
      'poster_path': instance.posterPath,
      'backdrop_path': instance.backdropPath,
      'release_date': instance.releaseDate,
      'vote_average': instance.voteAverage,
      'genre_ids': instance.genreIds,
    };
