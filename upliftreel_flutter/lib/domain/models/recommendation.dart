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

    /// Transient Era Selector overlay. Intersected with
    /// [UserPreferences.releaseYearRange] by the engine's hard filter; null
    /// means no era constraint (see [EraFilter.all]).
    ReleaseYearRange? eraRange,
  }) = _RecommendationContext;
}

/// Engine output. Persisted as the daily pick, so JSON round-trips.
@freezed
abstract class RecommendationResult with _$RecommendationResult {
  const factory RecommendationResult({
    required Movie movie,

    /// Legacy weighted score, 0–100. Parity-locked; used for ranking and the
    /// explanation tier prefix.
    required double matchScore,
    required String explanation,
    required bool isAlternative,
    String? alternativeReason,

    /// Normalized compatibility 0–100: [matchScore] expressed as a percentage
    /// of the weight actually applicable to this user's mood + preferences.
    /// This is the number the 75% gate tests against.
    @Default(0.0) double compatibility,

    /// True when [compatibility] fell under the 75% threshold and this pick is
    /// the best available rather than a qualifying match — the UI surfaces a
    /// "below your bar" badge.
    @Default(false) bool isBelowThreshold,
  }) = _RecommendationResult;

  factory RecommendationResult.fromJson(Map<String, dynamic> json) =>
      _$RecommendationResultFromJson(json);
}
