// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mood.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MoodInput {

 Mood get mood;/// 1–10.
 int get intensity;/// 1 = fun … 10 = serious. Was `moodSlider` in legacy.
 int get seriousness;
/// Create a copy of MoodInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MoodInputCopyWith<MoodInput> get copyWith => _$MoodInputCopyWithImpl<MoodInput>(this as MoodInput, _$identity);

  /// Serializes this MoodInput to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MoodInput&&(identical(other.mood, mood) || other.mood == mood)&&(identical(other.intensity, intensity) || other.intensity == intensity)&&(identical(other.seriousness, seriousness) || other.seriousness == seriousness));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mood,intensity,seriousness);

@override
String toString() {
  return 'MoodInput(mood: $mood, intensity: $intensity, seriousness: $seriousness)';
}


}

/// @nodoc
abstract mixin class $MoodInputCopyWith<$Res>  {
  factory $MoodInputCopyWith(MoodInput value, $Res Function(MoodInput) _then) = _$MoodInputCopyWithImpl;
@useResult
$Res call({
 Mood mood, int intensity, int seriousness
});




}
/// @nodoc
class _$MoodInputCopyWithImpl<$Res>
    implements $MoodInputCopyWith<$Res> {
  _$MoodInputCopyWithImpl(this._self, this._then);

  final MoodInput _self;
  final $Res Function(MoodInput) _then;

/// Create a copy of MoodInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mood = null,Object? intensity = null,Object? seriousness = null,}) {
  return _then(_self.copyWith(
mood: null == mood ? _self.mood : mood // ignore: cast_nullable_to_non_nullable
as Mood,intensity: null == intensity ? _self.intensity : intensity // ignore: cast_nullable_to_non_nullable
as int,seriousness: null == seriousness ? _self.seriousness : seriousness // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MoodInput].
extension MoodInputPatterns on MoodInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MoodInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MoodInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MoodInput value)  $default,){
final _that = this;
switch (_that) {
case _MoodInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MoodInput value)?  $default,){
final _that = this;
switch (_that) {
case _MoodInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Mood mood,  int intensity,  int seriousness)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MoodInput() when $default != null:
return $default(_that.mood,_that.intensity,_that.seriousness);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Mood mood,  int intensity,  int seriousness)  $default,) {final _that = this;
switch (_that) {
case _MoodInput():
return $default(_that.mood,_that.intensity,_that.seriousness);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Mood mood,  int intensity,  int seriousness)?  $default,) {final _that = this;
switch (_that) {
case _MoodInput() when $default != null:
return $default(_that.mood,_that.intensity,_that.seriousness);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MoodInput implements MoodInput {
  const _MoodInput({required this.mood, required this.intensity, required this.seriousness});
  factory _MoodInput.fromJson(Map<String, dynamic> json) => _$MoodInputFromJson(json);

@override final  Mood mood;
/// 1–10.
@override final  int intensity;
/// 1 = fun … 10 = serious. Was `moodSlider` in legacy.
@override final  int seriousness;

/// Create a copy of MoodInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MoodInputCopyWith<_MoodInput> get copyWith => __$MoodInputCopyWithImpl<_MoodInput>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MoodInputToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MoodInput&&(identical(other.mood, mood) || other.mood == mood)&&(identical(other.intensity, intensity) || other.intensity == intensity)&&(identical(other.seriousness, seriousness) || other.seriousness == seriousness));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mood,intensity,seriousness);

@override
String toString() {
  return 'MoodInput(mood: $mood, intensity: $intensity, seriousness: $seriousness)';
}


}

/// @nodoc
abstract mixin class _$MoodInputCopyWith<$Res> implements $MoodInputCopyWith<$Res> {
  factory _$MoodInputCopyWith(_MoodInput value, $Res Function(_MoodInput) _then) = __$MoodInputCopyWithImpl;
@override @useResult
$Res call({
 Mood mood, int intensity, int seriousness
});




}
/// @nodoc
class __$MoodInputCopyWithImpl<$Res>
    implements _$MoodInputCopyWith<$Res> {
  __$MoodInputCopyWithImpl(this._self, this._then);

  final _MoodInput _self;
  final $Res Function(_MoodInput) _then;

/// Create a copy of MoodInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mood = null,Object? intensity = null,Object? seriousness = null,}) {
  return _then(_MoodInput(
mood: null == mood ? _self.mood : mood // ignore: cast_nullable_to_non_nullable
as Mood,intensity: null == intensity ? _self.intensity : intensity // ignore: cast_nullable_to_non_nullable
as int,seriousness: null == seriousness ? _self.seriousness : seriousness // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
