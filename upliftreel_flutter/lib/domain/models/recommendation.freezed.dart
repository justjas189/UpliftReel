// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recommendation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RecommendationContext {

 UserPreferences get userPreferences; MoodInput? get currentMood; List<String> get previousRecommendationIds; List<String> get watchedMovieIds;/// Transient Era Selector overlay. Intersected with
/// [UserPreferences.releaseYearRange] by the engine's hard filter; null
/// means no era constraint (see [EraFilter.all]).
 ReleaseYearRange? get eraRange;
/// Create a copy of RecommendationContext
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecommendationContextCopyWith<RecommendationContext> get copyWith => _$RecommendationContextCopyWithImpl<RecommendationContext>(this as RecommendationContext, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecommendationContext&&(identical(other.userPreferences, userPreferences) || other.userPreferences == userPreferences)&&(identical(other.currentMood, currentMood) || other.currentMood == currentMood)&&const DeepCollectionEquality().equals(other.previousRecommendationIds, previousRecommendationIds)&&const DeepCollectionEquality().equals(other.watchedMovieIds, watchedMovieIds)&&(identical(other.eraRange, eraRange) || other.eraRange == eraRange));
}


@override
int get hashCode => Object.hash(runtimeType,userPreferences,currentMood,const DeepCollectionEquality().hash(previousRecommendationIds),const DeepCollectionEquality().hash(watchedMovieIds),eraRange);

@override
String toString() {
  return 'RecommendationContext(userPreferences: $userPreferences, currentMood: $currentMood, previousRecommendationIds: $previousRecommendationIds, watchedMovieIds: $watchedMovieIds, eraRange: $eraRange)';
}


}

/// @nodoc
abstract mixin class $RecommendationContextCopyWith<$Res>  {
  factory $RecommendationContextCopyWith(RecommendationContext value, $Res Function(RecommendationContext) _then) = _$RecommendationContextCopyWithImpl;
@useResult
$Res call({
 UserPreferences userPreferences, MoodInput? currentMood, List<String> previousRecommendationIds, List<String> watchedMovieIds, ReleaseYearRange? eraRange
});


$UserPreferencesCopyWith<$Res> get userPreferences;$MoodInputCopyWith<$Res>? get currentMood;$ReleaseYearRangeCopyWith<$Res>? get eraRange;

}
/// @nodoc
class _$RecommendationContextCopyWithImpl<$Res>
    implements $RecommendationContextCopyWith<$Res> {
  _$RecommendationContextCopyWithImpl(this._self, this._then);

  final RecommendationContext _self;
  final $Res Function(RecommendationContext) _then;

/// Create a copy of RecommendationContext
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userPreferences = null,Object? currentMood = freezed,Object? previousRecommendationIds = null,Object? watchedMovieIds = null,Object? eraRange = freezed,}) {
  return _then(_self.copyWith(
userPreferences: null == userPreferences ? _self.userPreferences : userPreferences // ignore: cast_nullable_to_non_nullable
as UserPreferences,currentMood: freezed == currentMood ? _self.currentMood : currentMood // ignore: cast_nullable_to_non_nullable
as MoodInput?,previousRecommendationIds: null == previousRecommendationIds ? _self.previousRecommendationIds : previousRecommendationIds // ignore: cast_nullable_to_non_nullable
as List<String>,watchedMovieIds: null == watchedMovieIds ? _self.watchedMovieIds : watchedMovieIds // ignore: cast_nullable_to_non_nullable
as List<String>,eraRange: freezed == eraRange ? _self.eraRange : eraRange // ignore: cast_nullable_to_non_nullable
as ReleaseYearRange?,
  ));
}
/// Create a copy of RecommendationContext
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserPreferencesCopyWith<$Res> get userPreferences {
  
  return $UserPreferencesCopyWith<$Res>(_self.userPreferences, (value) {
    return _then(_self.copyWith(userPreferences: value));
  });
}/// Create a copy of RecommendationContext
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MoodInputCopyWith<$Res>? get currentMood {
    if (_self.currentMood == null) {
    return null;
  }

  return $MoodInputCopyWith<$Res>(_self.currentMood!, (value) {
    return _then(_self.copyWith(currentMood: value));
  });
}/// Create a copy of RecommendationContext
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReleaseYearRangeCopyWith<$Res>? get eraRange {
    if (_self.eraRange == null) {
    return null;
  }

  return $ReleaseYearRangeCopyWith<$Res>(_self.eraRange!, (value) {
    return _then(_self.copyWith(eraRange: value));
  });
}
}


/// Adds pattern-matching-related methods to [RecommendationContext].
extension RecommendationContextPatterns on RecommendationContext {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecommendationContext value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecommendationContext() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecommendationContext value)  $default,){
final _that = this;
switch (_that) {
case _RecommendationContext():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecommendationContext value)?  $default,){
final _that = this;
switch (_that) {
case _RecommendationContext() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( UserPreferences userPreferences,  MoodInput? currentMood,  List<String> previousRecommendationIds,  List<String> watchedMovieIds,  ReleaseYearRange? eraRange)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecommendationContext() when $default != null:
return $default(_that.userPreferences,_that.currentMood,_that.previousRecommendationIds,_that.watchedMovieIds,_that.eraRange);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( UserPreferences userPreferences,  MoodInput? currentMood,  List<String> previousRecommendationIds,  List<String> watchedMovieIds,  ReleaseYearRange? eraRange)  $default,) {final _that = this;
switch (_that) {
case _RecommendationContext():
return $default(_that.userPreferences,_that.currentMood,_that.previousRecommendationIds,_that.watchedMovieIds,_that.eraRange);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( UserPreferences userPreferences,  MoodInput? currentMood,  List<String> previousRecommendationIds,  List<String> watchedMovieIds,  ReleaseYearRange? eraRange)?  $default,) {final _that = this;
switch (_that) {
case _RecommendationContext() when $default != null:
return $default(_that.userPreferences,_that.currentMood,_that.previousRecommendationIds,_that.watchedMovieIds,_that.eraRange);case _:
  return null;

}
}

}

/// @nodoc


class _RecommendationContext implements RecommendationContext {
  const _RecommendationContext({required this.userPreferences, this.currentMood, final  List<String> previousRecommendationIds = const [], final  List<String> watchedMovieIds = const [], this.eraRange}): _previousRecommendationIds = previousRecommendationIds,_watchedMovieIds = watchedMovieIds;
  

@override final  UserPreferences userPreferences;
@override final  MoodInput? currentMood;
 final  List<String> _previousRecommendationIds;
@override@JsonKey() List<String> get previousRecommendationIds {
  if (_previousRecommendationIds is EqualUnmodifiableListView) return _previousRecommendationIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_previousRecommendationIds);
}

 final  List<String> _watchedMovieIds;
@override@JsonKey() List<String> get watchedMovieIds {
  if (_watchedMovieIds is EqualUnmodifiableListView) return _watchedMovieIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_watchedMovieIds);
}

/// Transient Era Selector overlay. Intersected with
/// [UserPreferences.releaseYearRange] by the engine's hard filter; null
/// means no era constraint (see [EraFilter.all]).
@override final  ReleaseYearRange? eraRange;

/// Create a copy of RecommendationContext
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecommendationContextCopyWith<_RecommendationContext> get copyWith => __$RecommendationContextCopyWithImpl<_RecommendationContext>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecommendationContext&&(identical(other.userPreferences, userPreferences) || other.userPreferences == userPreferences)&&(identical(other.currentMood, currentMood) || other.currentMood == currentMood)&&const DeepCollectionEquality().equals(other._previousRecommendationIds, _previousRecommendationIds)&&const DeepCollectionEquality().equals(other._watchedMovieIds, _watchedMovieIds)&&(identical(other.eraRange, eraRange) || other.eraRange == eraRange));
}


@override
int get hashCode => Object.hash(runtimeType,userPreferences,currentMood,const DeepCollectionEquality().hash(_previousRecommendationIds),const DeepCollectionEquality().hash(_watchedMovieIds),eraRange);

@override
String toString() {
  return 'RecommendationContext(userPreferences: $userPreferences, currentMood: $currentMood, previousRecommendationIds: $previousRecommendationIds, watchedMovieIds: $watchedMovieIds, eraRange: $eraRange)';
}


}

/// @nodoc
abstract mixin class _$RecommendationContextCopyWith<$Res> implements $RecommendationContextCopyWith<$Res> {
  factory _$RecommendationContextCopyWith(_RecommendationContext value, $Res Function(_RecommendationContext) _then) = __$RecommendationContextCopyWithImpl;
@override @useResult
$Res call({
 UserPreferences userPreferences, MoodInput? currentMood, List<String> previousRecommendationIds, List<String> watchedMovieIds, ReleaseYearRange? eraRange
});


@override $UserPreferencesCopyWith<$Res> get userPreferences;@override $MoodInputCopyWith<$Res>? get currentMood;@override $ReleaseYearRangeCopyWith<$Res>? get eraRange;

}
/// @nodoc
class __$RecommendationContextCopyWithImpl<$Res>
    implements _$RecommendationContextCopyWith<$Res> {
  __$RecommendationContextCopyWithImpl(this._self, this._then);

  final _RecommendationContext _self;
  final $Res Function(_RecommendationContext) _then;

/// Create a copy of RecommendationContext
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userPreferences = null,Object? currentMood = freezed,Object? previousRecommendationIds = null,Object? watchedMovieIds = null,Object? eraRange = freezed,}) {
  return _then(_RecommendationContext(
userPreferences: null == userPreferences ? _self.userPreferences : userPreferences // ignore: cast_nullable_to_non_nullable
as UserPreferences,currentMood: freezed == currentMood ? _self.currentMood : currentMood // ignore: cast_nullable_to_non_nullable
as MoodInput?,previousRecommendationIds: null == previousRecommendationIds ? _self._previousRecommendationIds : previousRecommendationIds // ignore: cast_nullable_to_non_nullable
as List<String>,watchedMovieIds: null == watchedMovieIds ? _self._watchedMovieIds : watchedMovieIds // ignore: cast_nullable_to_non_nullable
as List<String>,eraRange: freezed == eraRange ? _self.eraRange : eraRange // ignore: cast_nullable_to_non_nullable
as ReleaseYearRange?,
  ));
}

/// Create a copy of RecommendationContext
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserPreferencesCopyWith<$Res> get userPreferences {
  
  return $UserPreferencesCopyWith<$Res>(_self.userPreferences, (value) {
    return _then(_self.copyWith(userPreferences: value));
  });
}/// Create a copy of RecommendationContext
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MoodInputCopyWith<$Res>? get currentMood {
    if (_self.currentMood == null) {
    return null;
  }

  return $MoodInputCopyWith<$Res>(_self.currentMood!, (value) {
    return _then(_self.copyWith(currentMood: value));
  });
}/// Create a copy of RecommendationContext
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReleaseYearRangeCopyWith<$Res>? get eraRange {
    if (_self.eraRange == null) {
    return null;
  }

  return $ReleaseYearRangeCopyWith<$Res>(_self.eraRange!, (value) {
    return _then(_self.copyWith(eraRange: value));
  });
}
}


/// @nodoc
mixin _$RecommendationResult {

 Movie get movie;/// Legacy weighted score, 0–100. Parity-locked; used for ranking and the
/// explanation tier prefix.
 double get matchScore; String get explanation; bool get isAlternative; String? get alternativeReason;/// Normalized compatibility 0–100: [matchScore] expressed as a percentage
/// of the weight actually applicable to this user's mood + preferences.
/// This is the number the 75% gate tests against.
 double get compatibility;/// True when [compatibility] fell under the 75% threshold and this pick is
/// the best available rather than a qualifying match — the UI surfaces a
/// "below your bar" badge.
 bool get isBelowThreshold;
/// Create a copy of RecommendationResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecommendationResultCopyWith<RecommendationResult> get copyWith => _$RecommendationResultCopyWithImpl<RecommendationResult>(this as RecommendationResult, _$identity);

  /// Serializes this RecommendationResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecommendationResult&&(identical(other.movie, movie) || other.movie == movie)&&(identical(other.matchScore, matchScore) || other.matchScore == matchScore)&&(identical(other.explanation, explanation) || other.explanation == explanation)&&(identical(other.isAlternative, isAlternative) || other.isAlternative == isAlternative)&&(identical(other.alternativeReason, alternativeReason) || other.alternativeReason == alternativeReason)&&(identical(other.compatibility, compatibility) || other.compatibility == compatibility)&&(identical(other.isBelowThreshold, isBelowThreshold) || other.isBelowThreshold == isBelowThreshold));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,movie,matchScore,explanation,isAlternative,alternativeReason,compatibility,isBelowThreshold);

@override
String toString() {
  return 'RecommendationResult(movie: $movie, matchScore: $matchScore, explanation: $explanation, isAlternative: $isAlternative, alternativeReason: $alternativeReason, compatibility: $compatibility, isBelowThreshold: $isBelowThreshold)';
}


}

/// @nodoc
abstract mixin class $RecommendationResultCopyWith<$Res>  {
  factory $RecommendationResultCopyWith(RecommendationResult value, $Res Function(RecommendationResult) _then) = _$RecommendationResultCopyWithImpl;
@useResult
$Res call({
 Movie movie, double matchScore, String explanation, bool isAlternative, String? alternativeReason, double compatibility, bool isBelowThreshold
});


$MovieCopyWith<$Res> get movie;

}
/// @nodoc
class _$RecommendationResultCopyWithImpl<$Res>
    implements $RecommendationResultCopyWith<$Res> {
  _$RecommendationResultCopyWithImpl(this._self, this._then);

  final RecommendationResult _self;
  final $Res Function(RecommendationResult) _then;

/// Create a copy of RecommendationResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? movie = null,Object? matchScore = null,Object? explanation = null,Object? isAlternative = null,Object? alternativeReason = freezed,Object? compatibility = null,Object? isBelowThreshold = null,}) {
  return _then(_self.copyWith(
movie: null == movie ? _self.movie : movie // ignore: cast_nullable_to_non_nullable
as Movie,matchScore: null == matchScore ? _self.matchScore : matchScore // ignore: cast_nullable_to_non_nullable
as double,explanation: null == explanation ? _self.explanation : explanation // ignore: cast_nullable_to_non_nullable
as String,isAlternative: null == isAlternative ? _self.isAlternative : isAlternative // ignore: cast_nullable_to_non_nullable
as bool,alternativeReason: freezed == alternativeReason ? _self.alternativeReason : alternativeReason // ignore: cast_nullable_to_non_nullable
as String?,compatibility: null == compatibility ? _self.compatibility : compatibility // ignore: cast_nullable_to_non_nullable
as double,isBelowThreshold: null == isBelowThreshold ? _self.isBelowThreshold : isBelowThreshold // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of RecommendationResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MovieCopyWith<$Res> get movie {
  
  return $MovieCopyWith<$Res>(_self.movie, (value) {
    return _then(_self.copyWith(movie: value));
  });
}
}


/// Adds pattern-matching-related methods to [RecommendationResult].
extension RecommendationResultPatterns on RecommendationResult {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecommendationResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecommendationResult() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecommendationResult value)  $default,){
final _that = this;
switch (_that) {
case _RecommendationResult():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecommendationResult value)?  $default,){
final _that = this;
switch (_that) {
case _RecommendationResult() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Movie movie,  double matchScore,  String explanation,  bool isAlternative,  String? alternativeReason,  double compatibility,  bool isBelowThreshold)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecommendationResult() when $default != null:
return $default(_that.movie,_that.matchScore,_that.explanation,_that.isAlternative,_that.alternativeReason,_that.compatibility,_that.isBelowThreshold);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Movie movie,  double matchScore,  String explanation,  bool isAlternative,  String? alternativeReason,  double compatibility,  bool isBelowThreshold)  $default,) {final _that = this;
switch (_that) {
case _RecommendationResult():
return $default(_that.movie,_that.matchScore,_that.explanation,_that.isAlternative,_that.alternativeReason,_that.compatibility,_that.isBelowThreshold);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Movie movie,  double matchScore,  String explanation,  bool isAlternative,  String? alternativeReason,  double compatibility,  bool isBelowThreshold)?  $default,) {final _that = this;
switch (_that) {
case _RecommendationResult() when $default != null:
return $default(_that.movie,_that.matchScore,_that.explanation,_that.isAlternative,_that.alternativeReason,_that.compatibility,_that.isBelowThreshold);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecommendationResult implements RecommendationResult {
  const _RecommendationResult({required this.movie, required this.matchScore, required this.explanation, required this.isAlternative, this.alternativeReason, this.compatibility = 0.0, this.isBelowThreshold = false});
  factory _RecommendationResult.fromJson(Map<String, dynamic> json) => _$RecommendationResultFromJson(json);

@override final  Movie movie;
/// Legacy weighted score, 0–100. Parity-locked; used for ranking and the
/// explanation tier prefix.
@override final  double matchScore;
@override final  String explanation;
@override final  bool isAlternative;
@override final  String? alternativeReason;
/// Normalized compatibility 0–100: [matchScore] expressed as a percentage
/// of the weight actually applicable to this user's mood + preferences.
/// This is the number the 75% gate tests against.
@override@JsonKey() final  double compatibility;
/// True when [compatibility] fell under the 75% threshold and this pick is
/// the best available rather than a qualifying match — the UI surfaces a
/// "below your bar" badge.
@override@JsonKey() final  bool isBelowThreshold;

/// Create a copy of RecommendationResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecommendationResultCopyWith<_RecommendationResult> get copyWith => __$RecommendationResultCopyWithImpl<_RecommendationResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecommendationResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecommendationResult&&(identical(other.movie, movie) || other.movie == movie)&&(identical(other.matchScore, matchScore) || other.matchScore == matchScore)&&(identical(other.explanation, explanation) || other.explanation == explanation)&&(identical(other.isAlternative, isAlternative) || other.isAlternative == isAlternative)&&(identical(other.alternativeReason, alternativeReason) || other.alternativeReason == alternativeReason)&&(identical(other.compatibility, compatibility) || other.compatibility == compatibility)&&(identical(other.isBelowThreshold, isBelowThreshold) || other.isBelowThreshold == isBelowThreshold));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,movie,matchScore,explanation,isAlternative,alternativeReason,compatibility,isBelowThreshold);

@override
String toString() {
  return 'RecommendationResult(movie: $movie, matchScore: $matchScore, explanation: $explanation, isAlternative: $isAlternative, alternativeReason: $alternativeReason, compatibility: $compatibility, isBelowThreshold: $isBelowThreshold)';
}


}

/// @nodoc
abstract mixin class _$RecommendationResultCopyWith<$Res> implements $RecommendationResultCopyWith<$Res> {
  factory _$RecommendationResultCopyWith(_RecommendationResult value, $Res Function(_RecommendationResult) _then) = __$RecommendationResultCopyWithImpl;
@override @useResult
$Res call({
 Movie movie, double matchScore, String explanation, bool isAlternative, String? alternativeReason, double compatibility, bool isBelowThreshold
});


@override $MovieCopyWith<$Res> get movie;

}
/// @nodoc
class __$RecommendationResultCopyWithImpl<$Res>
    implements _$RecommendationResultCopyWith<$Res> {
  __$RecommendationResultCopyWithImpl(this._self, this._then);

  final _RecommendationResult _self;
  final $Res Function(_RecommendationResult) _then;

/// Create a copy of RecommendationResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? movie = null,Object? matchScore = null,Object? explanation = null,Object? isAlternative = null,Object? alternativeReason = freezed,Object? compatibility = null,Object? isBelowThreshold = null,}) {
  return _then(_RecommendationResult(
movie: null == movie ? _self.movie : movie // ignore: cast_nullable_to_non_nullable
as Movie,matchScore: null == matchScore ? _self.matchScore : matchScore // ignore: cast_nullable_to_non_nullable
as double,explanation: null == explanation ? _self.explanation : explanation // ignore: cast_nullable_to_non_nullable
as String,isAlternative: null == isAlternative ? _self.isAlternative : isAlternative // ignore: cast_nullable_to_non_nullable
as bool,alternativeReason: freezed == alternativeReason ? _self.alternativeReason : alternativeReason // ignore: cast_nullable_to_non_nullable
as String?,compatibility: null == compatibility ? _self.compatibility : compatibility // ignore: cast_nullable_to_non_nullable
as double,isBelowThreshold: null == isBelowThreshold ? _self.isBelowThreshold : isBelowThreshold // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of RecommendationResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MovieCopyWith<$Res> get movie {
  
  return $MovieCopyWith<$Res>(_self.movie, (value) {
    return _then(_self.copyWith(movie: value));
  });
}
}

// dart format on
