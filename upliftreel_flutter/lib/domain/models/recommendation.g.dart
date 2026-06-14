// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RecommendationResult _$RecommendationResultFromJson(
  Map<String, dynamic> json,
) => _RecommendationResult(
  movie: Movie.fromJson(json['movie'] as Map<String, dynamic>),
  matchScore: (json['matchScore'] as num).toDouble(),
  explanation: json['explanation'] as String,
  isAlternative: json['isAlternative'] as bool,
  alternativeReason: json['alternativeReason'] as String?,
  compatibility: (json['compatibility'] as num?)?.toDouble() ?? 0.0,
  isBelowThreshold: json['isBelowThreshold'] as bool? ?? false,
);

Map<String, dynamic> _$RecommendationResultToJson(
  _RecommendationResult instance,
) => <String, dynamic>{
  'movie': instance.movie.toJson(),
  'matchScore': instance.matchScore,
  'explanation': instance.explanation,
  'isAlternative': instance.isAlternative,
  'alternativeReason': instance.alternativeReason,
  'compatibility': instance.compatibility,
  'isBelowThreshold': instance.isBelowThreshold,
};
