// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'movie.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Movie {

 String get id; String get title; List<Genre> get genres; double get imdbRating; int get releaseYear;/// Minutes.
 int get runtime; String get synopsis; String get director; List<String> get actors; List<MoodTag> get moodTags; String? get trailerUrl; String? get posterUrl; String? get backdropUrl;
/// Create a copy of Movie
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MovieCopyWith<Movie> get copyWith => _$MovieCopyWithImpl<Movie>(this as Movie, _$identity);

  /// Serializes this Movie to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Movie&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.genres, genres)&&(identical(other.imdbRating, imdbRating) || other.imdbRating == imdbRating)&&(identical(other.releaseYear, releaseYear) || other.releaseYear == releaseYear)&&(identical(other.runtime, runtime) || other.runtime == runtime)&&(identical(other.synopsis, synopsis) || other.synopsis == synopsis)&&(identical(other.director, director) || other.director == director)&&const DeepCollectionEquality().equals(other.actors, actors)&&const DeepCollectionEquality().equals(other.moodTags, moodTags)&&(identical(other.trailerUrl, trailerUrl) || other.trailerUrl == trailerUrl)&&(identical(other.posterUrl, posterUrl) || other.posterUrl == posterUrl)&&(identical(other.backdropUrl, backdropUrl) || other.backdropUrl == backdropUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,const DeepCollectionEquality().hash(genres),imdbRating,releaseYear,runtime,synopsis,director,const DeepCollectionEquality().hash(actors),const DeepCollectionEquality().hash(moodTags),trailerUrl,posterUrl,backdropUrl);

@override
String toString() {
  return 'Movie(id: $id, title: $title, genres: $genres, imdbRating: $imdbRating, releaseYear: $releaseYear, runtime: $runtime, synopsis: $synopsis, director: $director, actors: $actors, moodTags: $moodTags, trailerUrl: $trailerUrl, posterUrl: $posterUrl, backdropUrl: $backdropUrl)';
}


}

/// @nodoc
abstract mixin class $MovieCopyWith<$Res>  {
  factory $MovieCopyWith(Movie value, $Res Function(Movie) _then) = _$MovieCopyWithImpl;
@useResult
$Res call({
 String id, String title, List<Genre> genres, double imdbRating, int releaseYear, int runtime, String synopsis, String director, List<String> actors, List<MoodTag> moodTags, String? trailerUrl, String? posterUrl, String? backdropUrl
});




}
/// @nodoc
class _$MovieCopyWithImpl<$Res>
    implements $MovieCopyWith<$Res> {
  _$MovieCopyWithImpl(this._self, this._then);

  final Movie _self;
  final $Res Function(Movie) _then;

/// Create a copy of Movie
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? genres = null,Object? imdbRating = null,Object? releaseYear = null,Object? runtime = null,Object? synopsis = null,Object? director = null,Object? actors = null,Object? moodTags = null,Object? trailerUrl = freezed,Object? posterUrl = freezed,Object? backdropUrl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,genres: null == genres ? _self.genres : genres // ignore: cast_nullable_to_non_nullable
as List<Genre>,imdbRating: null == imdbRating ? _self.imdbRating : imdbRating // ignore: cast_nullable_to_non_nullable
as double,releaseYear: null == releaseYear ? _self.releaseYear : releaseYear // ignore: cast_nullable_to_non_nullable
as int,runtime: null == runtime ? _self.runtime : runtime // ignore: cast_nullable_to_non_nullable
as int,synopsis: null == synopsis ? _self.synopsis : synopsis // ignore: cast_nullable_to_non_nullable
as String,director: null == director ? _self.director : director // ignore: cast_nullable_to_non_nullable
as String,actors: null == actors ? _self.actors : actors // ignore: cast_nullable_to_non_nullable
as List<String>,moodTags: null == moodTags ? _self.moodTags : moodTags // ignore: cast_nullable_to_non_nullable
as List<MoodTag>,trailerUrl: freezed == trailerUrl ? _self.trailerUrl : trailerUrl // ignore: cast_nullable_to_non_nullable
as String?,posterUrl: freezed == posterUrl ? _self.posterUrl : posterUrl // ignore: cast_nullable_to_non_nullable
as String?,backdropUrl: freezed == backdropUrl ? _self.backdropUrl : backdropUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Movie].
extension MoviePatterns on Movie {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Movie value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Movie() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Movie value)  $default,){
final _that = this;
switch (_that) {
case _Movie():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Movie value)?  $default,){
final _that = this;
switch (_that) {
case _Movie() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  List<Genre> genres,  double imdbRating,  int releaseYear,  int runtime,  String synopsis,  String director,  List<String> actors,  List<MoodTag> moodTags,  String? trailerUrl,  String? posterUrl,  String? backdropUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Movie() when $default != null:
return $default(_that.id,_that.title,_that.genres,_that.imdbRating,_that.releaseYear,_that.runtime,_that.synopsis,_that.director,_that.actors,_that.moodTags,_that.trailerUrl,_that.posterUrl,_that.backdropUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  List<Genre> genres,  double imdbRating,  int releaseYear,  int runtime,  String synopsis,  String director,  List<String> actors,  List<MoodTag> moodTags,  String? trailerUrl,  String? posterUrl,  String? backdropUrl)  $default,) {final _that = this;
switch (_that) {
case _Movie():
return $default(_that.id,_that.title,_that.genres,_that.imdbRating,_that.releaseYear,_that.runtime,_that.synopsis,_that.director,_that.actors,_that.moodTags,_that.trailerUrl,_that.posterUrl,_that.backdropUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  List<Genre> genres,  double imdbRating,  int releaseYear,  int runtime,  String synopsis,  String director,  List<String> actors,  List<MoodTag> moodTags,  String? trailerUrl,  String? posterUrl,  String? backdropUrl)?  $default,) {final _that = this;
switch (_that) {
case _Movie() when $default != null:
return $default(_that.id,_that.title,_that.genres,_that.imdbRating,_that.releaseYear,_that.runtime,_that.synopsis,_that.director,_that.actors,_that.moodTags,_that.trailerUrl,_that.posterUrl,_that.backdropUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Movie implements Movie {
  const _Movie({required this.id, required this.title, required final  List<Genre> genres, required this.imdbRating, required this.releaseYear, required this.runtime, required this.synopsis, required this.director, required final  List<String> actors, required final  List<MoodTag> moodTags, this.trailerUrl, this.posterUrl, this.backdropUrl}): _genres = genres,_actors = actors,_moodTags = moodTags;
  factory _Movie.fromJson(Map<String, dynamic> json) => _$MovieFromJson(json);

@override final  String id;
@override final  String title;
 final  List<Genre> _genres;
@override List<Genre> get genres {
  if (_genres is EqualUnmodifiableListView) return _genres;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_genres);
}

@override final  double imdbRating;
@override final  int releaseYear;
/// Minutes.
@override final  int runtime;
@override final  String synopsis;
@override final  String director;
 final  List<String> _actors;
@override List<String> get actors {
  if (_actors is EqualUnmodifiableListView) return _actors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_actors);
}

 final  List<MoodTag> _moodTags;
@override List<MoodTag> get moodTags {
  if (_moodTags is EqualUnmodifiableListView) return _moodTags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_moodTags);
}

@override final  String? trailerUrl;
@override final  String? posterUrl;
@override final  String? backdropUrl;

/// Create a copy of Movie
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MovieCopyWith<_Movie> get copyWith => __$MovieCopyWithImpl<_Movie>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MovieToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Movie&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other._genres, _genres)&&(identical(other.imdbRating, imdbRating) || other.imdbRating == imdbRating)&&(identical(other.releaseYear, releaseYear) || other.releaseYear == releaseYear)&&(identical(other.runtime, runtime) || other.runtime == runtime)&&(identical(other.synopsis, synopsis) || other.synopsis == synopsis)&&(identical(other.director, director) || other.director == director)&&const DeepCollectionEquality().equals(other._actors, _actors)&&const DeepCollectionEquality().equals(other._moodTags, _moodTags)&&(identical(other.trailerUrl, trailerUrl) || other.trailerUrl == trailerUrl)&&(identical(other.posterUrl, posterUrl) || other.posterUrl == posterUrl)&&(identical(other.backdropUrl, backdropUrl) || other.backdropUrl == backdropUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,const DeepCollectionEquality().hash(_genres),imdbRating,releaseYear,runtime,synopsis,director,const DeepCollectionEquality().hash(_actors),const DeepCollectionEquality().hash(_moodTags),trailerUrl,posterUrl,backdropUrl);

@override
String toString() {
  return 'Movie(id: $id, title: $title, genres: $genres, imdbRating: $imdbRating, releaseYear: $releaseYear, runtime: $runtime, synopsis: $synopsis, director: $director, actors: $actors, moodTags: $moodTags, trailerUrl: $trailerUrl, posterUrl: $posterUrl, backdropUrl: $backdropUrl)';
}


}

/// @nodoc
abstract mixin class _$MovieCopyWith<$Res> implements $MovieCopyWith<$Res> {
  factory _$MovieCopyWith(_Movie value, $Res Function(_Movie) _then) = __$MovieCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, List<Genre> genres, double imdbRating, int releaseYear, int runtime, String synopsis, String director, List<String> actors, List<MoodTag> moodTags, String? trailerUrl, String? posterUrl, String? backdropUrl
});




}
/// @nodoc
class __$MovieCopyWithImpl<$Res>
    implements _$MovieCopyWith<$Res> {
  __$MovieCopyWithImpl(this._self, this._then);

  final _Movie _self;
  final $Res Function(_Movie) _then;

/// Create a copy of Movie
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? genres = null,Object? imdbRating = null,Object? releaseYear = null,Object? runtime = null,Object? synopsis = null,Object? director = null,Object? actors = null,Object? moodTags = null,Object? trailerUrl = freezed,Object? posterUrl = freezed,Object? backdropUrl = freezed,}) {
  return _then(_Movie(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,genres: null == genres ? _self._genres : genres // ignore: cast_nullable_to_non_nullable
as List<Genre>,imdbRating: null == imdbRating ? _self.imdbRating : imdbRating // ignore: cast_nullable_to_non_nullable
as double,releaseYear: null == releaseYear ? _self.releaseYear : releaseYear // ignore: cast_nullable_to_non_nullable
as int,runtime: null == runtime ? _self.runtime : runtime // ignore: cast_nullable_to_non_nullable
as int,synopsis: null == synopsis ? _self.synopsis : synopsis // ignore: cast_nullable_to_non_nullable
as String,director: null == director ? _self.director : director // ignore: cast_nullable_to_non_nullable
as String,actors: null == actors ? _self._actors : actors // ignore: cast_nullable_to_non_nullable
as List<String>,moodTags: null == moodTags ? _self._moodTags : moodTags // ignore: cast_nullable_to_non_nullable
as List<MoodTag>,trailerUrl: freezed == trailerUrl ? _self.trailerUrl : trailerUrl // ignore: cast_nullable_to_non_nullable
as String?,posterUrl: freezed == posterUrl ? _self.posterUrl : posterUrl // ignore: cast_nullable_to_non_nullable
as String?,backdropUrl: freezed == backdropUrl ? _self.backdropUrl : backdropUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
