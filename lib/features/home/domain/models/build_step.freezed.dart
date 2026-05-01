// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'build_step.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BuildStep {

 String get id; String get projectId; DateTime get date; String get note; String? get imageUrl;
/// Create a copy of BuildStep
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BuildStepCopyWith<BuildStep> get copyWith => _$BuildStepCopyWithImpl<BuildStep>(this as BuildStep, _$identity);

  /// Serializes this BuildStep to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BuildStep&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.date, date) || other.date == date)&&(identical(other.note, note) || other.note == note)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,projectId,date,note,imageUrl);

@override
String toString() {
  return 'BuildStep(id: $id, projectId: $projectId, date: $date, note: $note, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class $BuildStepCopyWith<$Res>  {
  factory $BuildStepCopyWith(BuildStep value, $Res Function(BuildStep) _then) = _$BuildStepCopyWithImpl;
@useResult
$Res call({
 String id, String projectId, DateTime date, String note, String? imageUrl
});




}
/// @nodoc
class _$BuildStepCopyWithImpl<$Res>
    implements $BuildStepCopyWith<$Res> {
  _$BuildStepCopyWithImpl(this._self, this._then);

  final BuildStep _self;
  final $Res Function(BuildStep) _then;

/// Create a copy of BuildStep
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? projectId = null,Object? date = null,Object? note = null,Object? imageUrl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BuildStep].
extension BuildStepPatterns on BuildStep {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BuildStep value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BuildStep() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BuildStep value)  $default,){
final _that = this;
switch (_that) {
case _BuildStep():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BuildStep value)?  $default,){
final _that = this;
switch (_that) {
case _BuildStep() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String projectId,  DateTime date,  String note,  String? imageUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BuildStep() when $default != null:
return $default(_that.id,_that.projectId,_that.date,_that.note,_that.imageUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String projectId,  DateTime date,  String note,  String? imageUrl)  $default,) {final _that = this;
switch (_that) {
case _BuildStep():
return $default(_that.id,_that.projectId,_that.date,_that.note,_that.imageUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String projectId,  DateTime date,  String note,  String? imageUrl)?  $default,) {final _that = this;
switch (_that) {
case _BuildStep() when $default != null:
return $default(_that.id,_that.projectId,_that.date,_that.note,_that.imageUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BuildStep extends BuildStep {
  const _BuildStep({required this.id, required this.projectId, required this.date, required this.note, this.imageUrl}): super._();
  factory _BuildStep.fromJson(Map<String, dynamic> json) => _$BuildStepFromJson(json);

@override final  String id;
@override final  String projectId;
@override final  DateTime date;
@override final  String note;
@override final  String? imageUrl;

/// Create a copy of BuildStep
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BuildStepCopyWith<_BuildStep> get copyWith => __$BuildStepCopyWithImpl<_BuildStep>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BuildStepToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BuildStep&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.date, date) || other.date == date)&&(identical(other.note, note) || other.note == note)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,projectId,date,note,imageUrl);

@override
String toString() {
  return 'BuildStep(id: $id, projectId: $projectId, date: $date, note: $note, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class _$BuildStepCopyWith<$Res> implements $BuildStepCopyWith<$Res> {
  factory _$BuildStepCopyWith(_BuildStep value, $Res Function(_BuildStep) _then) = __$BuildStepCopyWithImpl;
@override @useResult
$Res call({
 String id, String projectId, DateTime date, String note, String? imageUrl
});




}
/// @nodoc
class __$BuildStepCopyWithImpl<$Res>
    implements _$BuildStepCopyWith<$Res> {
  __$BuildStepCopyWithImpl(this._self, this._then);

  final _BuildStep _self;
  final $Res Function(_BuildStep) _then;

/// Create a copy of BuildStep
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? projectId = null,Object? date = null,Object? note = null,Object? imageUrl = freezed,}) {
  return _then(_BuildStep(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
