import 'package:freezed_annotation/freezed_annotation.dart';

import 'mood.dart';
import 'movie.dart';
import 'user_preferences.dart';

part 'recommendation.freezed.dart';
part 'recommendation.g.dart';

/// Engine input. Not persisted, so no JSON.
@freezed
abstract class RecommendationContext with _$RecommendationContext {
  const factory RecommendationContext({
    required UserPreferences userPreferences,
    MoodInput? currentMood,
    @Default([]) List<String> previousRecommendationIds,
    @Default([]) List<String> watchedMovieIds,
  }) = _RecommendationContext;
}

/// Engine output. Persisted as the daily pick, so JSON round-trips.
@freezed
abstract class RecommendationResult with _$RecommendationResult {
  const factory RecommendationResult({
    required Movie movie,

    /// 0–100.
    required double matchScore,
    required String explanation,
    required bool isAlternative,
    String? alternativeReason,
  }) = _RecommendationResult;

  factory RecommendationResult.fromJson(Map<String, dynamic> json) =>
      _$RecommendationResultFromJson(json);
}
