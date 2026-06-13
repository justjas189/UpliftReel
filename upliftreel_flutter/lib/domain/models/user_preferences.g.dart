// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReleaseYearRange _$ReleaseYearRangeFromJson(Map<String, dynamic> json) =>
    _ReleaseYearRange(
      min: (json['min'] as num).toInt(),
      max: (json['max'] as num).toInt(),
    );

Map<String, dynamic> _$ReleaseYearRangeToJson(_ReleaseYearRange instance) =>
    <String, dynamic>{'min': instance.min, 'max': instance.max};

_UserPreferences _$UserPreferencesFromJson(Map<String, dynamic> json) =>
    _UserPreferences(
      selectedGenres: (json['selectedGenres'] as List<dynamic>)
          .map((e) => $enumDecode(_$GenreEnumMap, e))
          .toList(),
      minRating: (json['minRating'] as num).toDouble(),
      maxRating: (json['maxRating'] as num).toDouble(),
      preferredActors:
          (json['preferredActors'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      preferredDirectors:
          (json['preferredDirectors'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      releaseYearRange: json['releaseYearRange'] == null
          ? null
          : ReleaseYearRange.fromJson(
              json['releaseYearRange'] as Map<String, dynamic>,
            ),
      maxRuntime: (json['maxRuntime'] as num?)?.toInt(),
      excludedGenres:
          (json['excludedGenres'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$GenreEnumMap, e))
              .toList() ??
          const [],
      excludedMovieIds:
          (json['excludedMovieIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      notificationTime: json['notificationTime'] as String? ?? '19:00',
      preferredLanguage: json['preferredLanguage'] as String? ?? 'en',
    );

Map<String, dynamic> _$UserPreferencesToJson(_UserPreferences instance) =>
    <String, dynamic>{
      'selectedGenres': instance.selectedGenres
          .map((e) => _$GenreEnumMap[e]!)
          .toList(),
      'minRating': instance.minRating,
      'maxRating': instance.maxRating,
      'preferredActors': instance.preferredActors,
      'preferredDirectors': instance.preferredDirectors,
      'releaseYearRange': instance.releaseYearRange?.toJson(),
      'maxRuntime': instance.maxRuntime,
      'excludedGenres': instance.excludedGenres
          .map((e) => _$GenreEnumMap[e]!)
          .toList(),
      'excludedMovieIds': instance.excludedMovieIds,
      'notificationTime': instance.notificationTime,
      'preferredLanguage': instance.preferredLanguage,
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
