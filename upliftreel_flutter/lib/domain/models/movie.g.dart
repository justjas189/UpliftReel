// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Movie _$MovieFromJson(Map<String, dynamic> json) => _Movie(
  id: json['id'] as String,
  title: json['title'] as String,
  genres: (json['genres'] as List<dynamic>)
      .map((e) => $enumDecode(_$GenreEnumMap, e))
      .toList(),
  imdbRating: (json['imdbRating'] as num).toDouble(),
  releaseYear: (json['releaseYear'] as num).toInt(),
  runtime: (json['runtime'] as num).toInt(),
  synopsis: json['synopsis'] as String,
  director: json['director'] as String,
  actors: (json['actors'] as List<dynamic>).map((e) => e as String).toList(),
  moodTags: (json['moodTags'] as List<dynamic>)
      .map((e) => $enumDecode(_$MoodTagEnumMap, e))
      .toList(),
  writers:
      (json['writers'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  producers:
      (json['producers'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  tagline: json['tagline'] as String?,
  awards: json['awards'] as String?,
  trailerUrl: json['trailerUrl'] as String?,
  posterUrl: json['posterUrl'] as String?,
  backdropUrl: json['backdropUrl'] as String?,
);

Map<String, dynamic> _$MovieToJson(_Movie instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'genres': instance.genres.map((e) => _$GenreEnumMap[e]!).toList(),
  'imdbRating': instance.imdbRating,
  'releaseYear': instance.releaseYear,
  'runtime': instance.runtime,
  'synopsis': instance.synopsis,
  'director': instance.director,
  'actors': instance.actors,
  'moodTags': instance.moodTags.map((e) => _$MoodTagEnumMap[e]!).toList(),
  'writers': instance.writers,
  'producers': instance.producers,
  'tagline': instance.tagline,
  'awards': instance.awards,
  'trailerUrl': instance.trailerUrl,
  'posterUrl': instance.posterUrl,
  'backdropUrl': instance.backdropUrl,
};

const _$GenreEnumMap = {
  Genre.comedy: 'comedy',
  Genre.drama: 'drama',
  Genre.thriller: 'thriller',
  Genre.horror: 'horror',
  Genre.scifi: 'sci-fi',
  Genre.romance: 'romance',
  Genre.action: 'action',
  Genre.documentary: 'documentary',
  Genre.adventure: 'adventure',
  Genre.fantasy: 'fantasy',
  Genre.mystery: 'mystery',
  Genre.animation: 'animation',
};

const _$MoodTagEnumMap = {
  MoodTag.exciting: 'exciting',
  MoodTag.thoughtProvoking: 'thought-provoking',
  MoodTag.scary: 'scary',
  MoodTag.romantic: 'romantic',
  MoodTag.funny: 'funny',
  MoodTag.uplifting: 'uplifting',
  MoodTag.intense: 'intense',
  MoodTag.relaxing: 'relaxing',
  MoodTag.nostalgic: 'nostalgic',
  MoodTag.inspiring: 'inspiring',
};
