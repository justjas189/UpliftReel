// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_preferences.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReleaseYearRange {

 int get min; int get max;
/// Create a copy of ReleaseYearRange
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReleaseYearRangeCopyWith<ReleaseYearRange> get copyWith => _$ReleaseYearRangeCopyWithImpl<ReleaseYearRange>(this as ReleaseYearRange, _$identity);

  /// Serializes this ReleaseYearRange to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReleaseYearRange&&(identical(other.min, min) || other.min == min)&&(identical(other.max, max) || other.max == max));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,min,max);

@override
String toString() {
  return 'ReleaseYearRange(min: $min, max: $max)';
}


}

/// @nodoc
abstract mixin class $ReleaseYearRangeCopyWith<$Res>  {
  factory $ReleaseYearRangeCopyWith(ReleaseYearRange value, $Res Function(ReleaseYearRange) _then) = _$ReleaseYearRangeCopyWithImpl;
@useResult
$Res call({
 int min, int max
});




}
/// @nodoc
class _$ReleaseYearRangeCopyWithImpl<$Res>
    implements $ReleaseYearRangeCopyWith<$Res> {
  _$ReleaseYearRangeCopyWithImpl(this._self, this._then);

  final ReleaseYearRange _self;
  final $Res Function(ReleaseYearRange) _then;

/// Create a copy of ReleaseYearRange
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? min = null,Object? max = null,}) {
  return _then(_self.copyWith(
min: null == min ? _self.min : min // ignore: cast_nullable_to_non_nullable
as int,max: null == max ? _self.max : max // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ReleaseYearRange].
extension ReleaseYearRangePatterns on ReleaseYearRange {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReleaseYearRange value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReleaseYearRange() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReleaseYearRange value)  $default,){
final _that = this;
switch (_that) {
case _ReleaseYearRange():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReleaseYearRange value)?  $default,){
final _that = this;
switch (_that) {
case _ReleaseYearRange() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int min,  int max)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReleaseYearRange() when $default != null:
return $default(_that.min,_that.max);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int min,  int max)  $default,) {final _that = this;
switch (_that) {
case _ReleaseYearRange():
return $default(_that.min,_that.max);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int min,  int max)?  $default,) {final _that = this;
switch (_that) {
case _ReleaseYearRange() when $default != null:
return $default(_that.min,_that.max);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReleaseYearRange implements ReleaseYearRange {
  const _ReleaseYearRange({required this.min, required this.max});
  factory _ReleaseYearRange.fromJson(Map<String, dynamic> json) => _$ReleaseYearRangeFromJson(json);

@override final  int min;
@override final  int max;

/// Create a copy of ReleaseYearRange
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReleaseYearRangeCopyWith<_ReleaseYearRange> get copyWith => __$ReleaseYearRangeCopyWithImpl<_ReleaseYearRange>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReleaseYearRangeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReleaseYearRange&&(identical(other.min, min) || other.min == min)&&(identical(other.max, max) || other.max == max));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,min,max);

@override
String toString() {
  return 'ReleaseYearRange(min: $min, max: $max)';
}


}

/// @nodoc
abstract mixin class _$ReleaseYearRangeCopyWith<$Res> implements $ReleaseYearRangeCopyWith<$Res> {
  factory _$ReleaseYearRangeCopyWith(_ReleaseYearRange value, $Res Function(_ReleaseYearRange) _then) = __$ReleaseYearRangeCopyWithImpl;
@override @useResult
$Res call({
 int min, int max
});




}
/// @nodoc
class __$ReleaseYearRangeCopyWithImpl<$Res>
    implements _$ReleaseYearRangeCopyWith<$Res> {
  __$ReleaseYearRangeCopyWithImpl(this._self, this._then);

  final _ReleaseYearRange _self;
  final $Res Function(_ReleaseYearRange) _then;

/// Create a copy of ReleaseYearRange
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? min = null,Object? max = null,}) {
  return _then(_ReleaseYearRange(
min: null == min ? _self.min : min // ignore: cast_nullable_to_non_nullable
as int,max: null == max ? _self.max : max // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$UserPreferences {

 List<Genre> get selectedGenres; double get minRating; double get maxRating; List<String> get preferredActors; List<String> get preferredDirectors; ReleaseYearRange? get releaseYearRange;/// Minutes.
 int? get maxRuntime; List<Genre> get excludedGenres; List<String> get excludedMovieIds;/// 24h "HH:MM".
 String get notificationTime;/// ISO-639-1 original-language filter for TMDB discovery.
/// Must be a key of [kPreferredLanguages].
 String get preferredLanguage;
/// Create a copy of UserPreferences
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserPreferencesCopyWith<UserPreferences> get copyWith => _$UserPreferencesCopyWithImpl<UserPreferences>(this as UserPreferences, _$identity);

  /// Serializes this UserPreferences to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserPreferences&&const DeepCollectionEquality().equals(other.selectedGenres, selectedGenres)&&(identical(other.minRating, minRating) || other.minRating == minRating)&&(identical(other.maxRating, maxRating) || other.maxRating == maxRating)&&const DeepCollectionEquality().equals(other.preferredActors, preferredActors)&&const DeepCollectionEquality().equals(other.preferredDirectors, preferredDirectors)&&(identical(other.releaseYearRange, releaseYearRange) || other.releaseYearRange == releaseYearRange)&&(identical(other.maxRuntime, maxRuntime) || other.maxRuntime == maxRuntime)&&const DeepCollectionEquality().equals(other.excludedGenres, excludedGenres)&&const DeepCollectionEquality().equals(other.excludedMovieIds, excludedMovieIds)&&(identical(other.notificationTime, notificationTime) || other.notificationTime == notificationTime)&&(identical(other.preferredLanguage, preferredLanguage) || other.preferredLanguage == preferredLanguage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(selectedGenres),minRating,maxRating,const DeepCollectionEquality().hash(preferredActors),const DeepCollectionEquality().hash(preferredDirectors),releaseYearRange,maxRuntime,const DeepCollectionEquality().hash(excludedGenres),const DeepCollectionEquality().hash(excludedMovieIds),notificationTime,preferredLanguage);

@override
String toString() {
  return 'UserPreferences(selectedGenres: $selectedGenres, minRating: $minRating, maxRating: $maxRating, preferredActors: $preferredActors, preferredDirectors: $preferredDirectors, releaseYearRange: $releaseYearRange, maxRuntime: $maxRuntime, excludedGenres: $excludedGenres, excludedMovieIds: $excludedMovieIds, notificationTime: $notificationTime, preferredLanguage: $preferredLanguage)';
}


}

/// @nodoc
abstract mixin class $UserPreferencesCopyWith<$Res>  {
  factory $UserPreferencesCopyWith(UserPreferences value, $Res Function(UserPreferences) _then) = _$UserPreferencesCopyWithImpl;
@useResult
$Res call({
 List<Genre> selectedGenres, double minRating, double maxRating, List<String> preferredActors, List<String> preferredDirectors, ReleaseYearRange? releaseYearRange, int? maxRuntime, List<Genre> excludedGenres, List<String> excludedMovieIds, String notificationTime, String preferredLanguage
});


$ReleaseYearRangeCopyWith<$Res>? get releaseYearRange;

}
/// @nodoc
class _$UserPreferencesCopyWithImpl<$Res>
    implements $UserPreferencesCopyWith<$Res> {
  _$UserPreferencesCopyWithImpl(this._self, this._then);

  final UserPreferences _self;
  final $Res Function(UserPreferences) _then;

/// Create a copy of UserPreferences
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectedGenres = null,Object? minRating = null,Object? maxRating = null,Object? preferredActors = null,Object? preferredDirectors = null,Object? releaseYearRange = freezed,Object? maxRuntime = freezed,Object? excludedGenres = null,Object? excludedMovieIds = null,Object? notificationTime = null,Object? preferredLanguage = null,}) {
  return _then(_self.copyWith(
selectedGenres: null == selectedGenres ? _self.selectedGenres : selectedGenres // ignore: cast_nullable_to_non_nullable
as List<Genre>,minRating: null == minRating ? _self.minRating : minRating // ignore: cast_nullable_to_non_nullable
as double,maxRating: null == maxRating ? _self.maxRating : maxRating // ignore: cast_nullable_to_non_nullable
as double,preferredActors: null == preferredActors ? _self.preferredActors : preferredActors // ignore: cast_nullable_to_non_nullable
as List<String>,preferredDirectors: null == preferredDirectors ? _self.preferredDirectors : preferredDirectors // ignore: cast_nullable_to_non_nullable
as List<String>,releaseYearRange: freezed == releaseYearRange ? _self.releaseYearRange : releaseYearRange // ignore: cast_nullable_to_non_nullable
as ReleaseYearRange?,maxRuntime: freezed == maxRuntime ? _self.maxRuntime : maxRuntime // ignore: cast_nullable_to_non_nullable
as int?,excludedGenres: null == excludedGenres ? _self.excludedGenres : excludedGenres // ignore: cast_nullable_to_non_nullable
as List<Genre>,excludedMovieIds: null == excludedMovieIds ? _self.excludedMovieIds : excludedMovieIds // ignore: cast_nullable_to_non_nullable
as List<String>,notificationTime: null == notificationTime ? _self.notificationTime : notificationTime // ignore: cast_nullable_to_non_nullable
as String,preferredLanguage: null == preferredLanguage ? _self.preferredLanguage : preferredLanguage // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of UserPreferences
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReleaseYearRangeCopyWith<$Res>? get releaseYearRange {
    if (_self.releaseYearRange == null) {
    return null;
  }

  return $ReleaseYearRangeCopyWith<$Res>(_self.releaseYearRange!, (value) {
    return _then(_self.copyWith(releaseYearRange: value));
  });
}
}


/// Adds pattern-matching-related methods to [UserPreferences].
extension UserPreferencesPatterns on UserPreferences {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserPreferences value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserPreferences() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserPreferences value)  $default,){
final _that = this;
switch (_that) {
case _UserPreferences():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserPreferences value)?  $default,){
final _that = this;
switch (_that) {
case _UserPreferences() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Genre> selectedGenres,  double minRating,  double maxRating,  List<String> preferredActors,  List<String> preferredDirectors,  ReleaseYearRange? releaseYearRange,  int? maxRuntime,  List<Genre> excludedGenres,  List<String> excludedMovieIds,  String notificationTime,  String preferredLanguage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserPreferences() when $default != null:
return $default(_that.selectedGenres,_that.minRating,_that.maxRating,_that.preferredActors,_that.preferredDirectors,_that.releaseYearRange,_that.maxRuntime,_that.excludedGenres,_that.excludedMovieIds,_that.notificationTime,_that.preferredLanguage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Genre> selectedGenres,  double minRating,  double maxRating,  List<String> preferredActors,  List<String> preferredDirectors,  ReleaseYearRange? releaseYearRange,  int? maxRuntime,  List<Genre> excludedGenres,  List<String> excludedMovieIds,  String notificationTime,  String preferredLanguage)  $default,) {final _that = this;
switch (_that) {
case _UserPreferences():
return $default(_that.selectedGenres,_that.minRating,_that.maxRating,_that.preferredActors,_that.preferredDirectors,_that.releaseYearRange,_that.maxRuntime,_that.excludedGenres,_that.excludedMovieIds,_that.notificationTime,_that.preferredLanguage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Genre> selectedGenres,  double minRating,  double maxRating,  List<String> preferredActors,  List<String> preferredDirectors,  ReleaseYearRange? releaseYearRange,  int? maxRuntime,  List<Genre> excludedGenres,  List<String> excludedMovieIds,  String notificationTime,  String preferredLanguage)?  $default,) {final _that = this;
switch (_that) {
case _UserPreferences() when $default != null:
return $default(_that.selectedGenres,_that.minRating,_that.maxRating,_that.preferredActors,_that.preferredDirectors,_that.releaseYearRange,_that.maxRuntime,_that.excludedGenres,_that.excludedMovieIds,_that.notificationTime,_that.preferredLanguage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserPreferences implements UserPreferences {
  const _UserPreferences({required final  List<Genre> selectedGenres, required this.minRating, required this.maxRating, final  List<String> preferredActors = const [], final  List<String> preferredDirectors = const [], this.releaseYearRange, this.maxRuntime, final  List<Genre> excludedGenres = const [], final  List<String> excludedMovieIds = const [], this.notificationTime = '19:00', this.preferredLanguage = 'en'}): _selectedGenres = selectedGenres,_preferredActors = preferredActors,_preferredDirectors = preferredDirectors,_excludedGenres = excludedGenres,_excludedMovieIds = excludedMovieIds;
  factory _UserPreferences.fromJson(Map<String, dynamic> json) => _$UserPreferencesFromJson(json);

 final  List<Genre> _selectedGenres;
@override List<Genre> get selectedGenres {
  if (_selectedGenres is EqualUnmodifiableListView) return _selectedGenres;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedGenres);
}

@override final  double minRating;
@override final  double maxRating;
 final  List<String> _preferredActors;
@override@JsonKey() List<String> get preferredActors {
  if (_preferredActors is EqualUnmodifiableListView) return _preferredActors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_preferredActors);
}

 final  List<String> _preferredDirectors;
@override@JsonKey() List<String> get preferredDirectors {
  if (_preferredDirectors is EqualUnmodifiableListView) return _preferredDirectors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_preferredDirectors);
}

@override final  ReleaseYearRange? releaseYearRange;
/// Minutes.
@override final  int? maxRuntime;
 final  List<Genre> _excludedGenres;
@override@JsonKey() List<Genre> get excludedGenres {
  if (_excludedGenres is EqualUnmodifiableListView) return _excludedGenres;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_excludedGenres);
}

 final  List<String> _excludedMovieIds;
@override@JsonKey() List<String> get excludedMovieIds {
  if (_excludedMovieIds is EqualUnmodifiableListView) return _excludedMovieIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_excludedMovieIds);
}

/// 24h "HH:MM".
@override@JsonKey() final  String notificationTime;
/// ISO-639-1 original-language filter for TMDB discovery.
/// Must be a key of [kPreferredLanguages].
@override@JsonKey() final  String preferredLanguage;

/// Create a copy of UserPreferences
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserPreferencesCopyWith<_UserPreferences> get copyWith => __$UserPreferencesCopyWithImpl<_UserPreferences>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserPreferencesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserPreferences&&const DeepCollectionEquality().equals(other._selectedGenres, _selectedGenres)&&(identical(other.minRating, minRating) || other.minRating == minRating)&&(identical(other.maxRating, maxRating) || other.maxRating == maxRating)&&const DeepCollectionEquality().equals(other._preferredActors, _preferredActors)&&const DeepCollectionEquality().equals(other._preferredDirectors, _preferredDirectors)&&(identical(other.releaseYearRange, releaseYearRange) || other.releaseYearRange == releaseYearRange)&&(identical(other.maxRuntime, maxRuntime) || other.maxRuntime == maxRuntime)&&const DeepCollectionEquality().equals(other._excludedGenres, _excludedGenres)&&const DeepCollectionEquality().equals(other._excludedMovieIds, _excludedMovieIds)&&(identical(other.notificationTime, notificationTime) || other.notificationTime == notificationTime)&&(identical(other.preferredLanguage, preferredLanguage) || other.preferredLanguage == preferredLanguage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_selectedGenres),minRating,maxRating,const DeepCollectionEquality().hash(_preferredActors),const DeepCollectionEquality().hash(_preferredDirectors),releaseYearRange,maxRuntime,const DeepCollectionEquality().hash(_excludedGenres),const DeepCollectionEquality().hash(_excludedMovieIds),notificationTime,preferredLanguage);

@override
String toString() {
  return 'UserPreferences(selectedGenres: $selectedGenres, minRating: $minRating, maxRating: $maxRating, preferredActors: $preferredActors, preferredDirectors: $preferredDirectors, releaseYearRange: $releaseYearRange, maxRuntime: $maxRuntime, excludedGenres: $excludedGenres, excludedMovieIds: $excludedMovieIds, notificationTime: $notificationTime, preferredLanguage: $preferredLanguage)';
}


}

/// @nodoc
abstract mixin class _$UserPreferencesCopyWith<$Res> implements $UserPreferencesCopyWith<$Res> {
  factory _$UserPreferencesCopyWith(_UserPreferences value, $Res Function(_UserPreferences) _then) = __$UserPreferencesCopyWithImpl;
@override @useResult
$Res call({
 List<Genre> selectedGenres, double minRating, double maxRating, List<String> preferredActors, List<String> preferredDirectors, ReleaseYearRange? releaseYearRange, int? maxRuntime, List<Genre> excludedGenres, List<String> excludedMovieIds, String notificationTime, String preferredLanguage
});


@override $ReleaseYearRangeCopyWith<$Res>? get releaseYearRange;

}
/// @nodoc
class __$UserPreferencesCopyWithImpl<$Res>
    implements _$UserPreferencesCopyWith<$Res> {
  __$UserPreferencesCopyWithImpl(this._self, this._then);

  final _UserPreferences _self;
  final $Res Function(_UserPreferences) _then;

/// Create a copy of UserPreferences
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectedGenres = null,Object? minRating = null,Object? maxRating = null,Object? preferredActors = null,Object? preferredDirectors = null,Object? releaseYearRange = freezed,Object? maxRuntime = freezed,Object? excludedGenres = null,Object? excludedMovieIds = null,Object? notificationTime = null,Object? preferredLanguage = null,}) {
  return _then(_UserPreferences(
selectedGenres: null == selectedGenres ? _self._selectedGenres : selectedGenres // ignore: cast_nullable_to_non_nullable
as List<Genre>,minRating: null == minRating ? _self.minRating : minRating // ignore: cast_nullable_to_non_nullable
as double,maxRating: null == maxRating ? _self.maxRating : maxRating // ignore: cast_nullable_to_non_nullable
as double,preferredActors: null == preferredActors ? _self._preferredActors : preferredActors // ignore: cast_nullable_to_non_nullable
as List<String>,preferredDirectors: null == preferredDirectors ? _self._preferredDirectors : preferredDirectors // ignore: cast_nullable_to_non_nullable
as List<String>,releaseYearRange: freezed == releaseYearRange ? _self.releaseYearRange : releaseYearRange // ignore: cast_nullable_to_non_nullable
as ReleaseYearRange?,maxRuntime: freezed == maxRuntime ? _self.maxRuntime : maxRuntime // ignore: cast_nullable_to_non_nullable
as int?,excludedGenres: null == excludedGenres ? _self._excludedGenres : excludedGenres // ignore: cast_nullable_to_non_nullable
as List<Genre>,excludedMovieIds: null == excludedMovieIds ? _self._excludedMovieIds : excludedMovieIds // ignore: cast_nullable_to_non_nullable
as List<String>,notificationTime: null == notificationTime ? _self.notificationTime : notificationTime // ignore: cast_nullable_to_non_nullable
as String,preferredLanguage: null == preferredLanguage ? _self.preferredLanguage : preferredLanguage // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of UserPreferences
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReleaseYearRangeCopyWith<$Res>? get releaseYearRange {
    if (_self.releaseYearRange == null) {
    return null;
  }

  return $ReleaseYearRangeCopyWith<$Res>(_self.releaseYearRange!, (value) {
    return _then(_self.copyWith(releaseYearRange: value));
  });
}
}

// dart format on
