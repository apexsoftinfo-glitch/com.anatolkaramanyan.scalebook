// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'model_project.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ModelProject {

 String get id; String get title; String get scale; double get progress; String get status; String? get mainImageUrl; List<BuildStep> get steps; List<String> get galleryUrls; DateTime get createdAt;
/// Create a copy of ModelProject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ModelProjectCopyWith<ModelProject> get copyWith => _$ModelProjectCopyWithImpl<ModelProject>(this as ModelProject, _$identity);

  /// Serializes this ModelProject to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ModelProject&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.scale, scale) || other.scale == scale)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.status, status) || other.status == status)&&(identical(other.mainImageUrl, mainImageUrl) || other.mainImageUrl == mainImageUrl)&&const DeepCollectionEquality().equals(other.steps, steps)&&const DeepCollectionEquality().equals(other.galleryUrls, galleryUrls)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,scale,progress,status,mainImageUrl,const DeepCollectionEquality().hash(steps),const DeepCollectionEquality().hash(galleryUrls),createdAt);

@override
String toString() {
  return 'ModelProject(id: $id, title: $title, scale: $scale, progress: $progress, status: $status, mainImageUrl: $mainImageUrl, steps: $steps, galleryUrls: $galleryUrls, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ModelProjectCopyWith<$Res>  {
  factory $ModelProjectCopyWith(ModelProject value, $Res Function(ModelProject) _then) = _$ModelProjectCopyWithImpl;
@useResult
$Res call({
 String id, String title, String scale, double progress, String status, String? mainImageUrl, List<BuildStep> steps, List<String> galleryUrls, DateTime createdAt
});




}
/// @nodoc
class _$ModelProjectCopyWithImpl<$Res>
    implements $ModelProjectCopyWith<$Res> {
  _$ModelProjectCopyWithImpl(this._self, this._then);

  final ModelProject _self;
  final $Res Function(ModelProject) _then;

/// Create a copy of ModelProject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? scale = null,Object? progress = null,Object? status = null,Object? mainImageUrl = freezed,Object? steps = null,Object? galleryUrls = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,scale: null == scale ? _self.scale : scale // ignore: cast_nullable_to_non_nullable
as String,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,mainImageUrl: freezed == mainImageUrl ? _self.mainImageUrl : mainImageUrl // ignore: cast_nullable_to_non_nullable
as String?,steps: null == steps ? _self.steps : steps // ignore: cast_nullable_to_non_nullable
as List<BuildStep>,galleryUrls: null == galleryUrls ? _self.galleryUrls : galleryUrls // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ModelProject].
extension ModelProjectPatterns on ModelProject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ModelProject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ModelProject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ModelProject value)  $default,){
final _that = this;
switch (_that) {
case _ModelProject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ModelProject value)?  $default,){
final _that = this;
switch (_that) {
case _ModelProject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String scale,  double progress,  String status,  String? mainImageUrl,  List<BuildStep> steps,  List<String> galleryUrls,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ModelProject() when $default != null:
return $default(_that.id,_that.title,_that.scale,_that.progress,_that.status,_that.mainImageUrl,_that.steps,_that.galleryUrls,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String scale,  double progress,  String status,  String? mainImageUrl,  List<BuildStep> steps,  List<String> galleryUrls,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _ModelProject():
return $default(_that.id,_that.title,_that.scale,_that.progress,_that.status,_that.mainImageUrl,_that.steps,_that.galleryUrls,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String scale,  double progress,  String status,  String? mainImageUrl,  List<BuildStep> steps,  List<String> galleryUrls,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ModelProject() when $default != null:
return $default(_that.id,_that.title,_that.scale,_that.progress,_that.status,_that.mainImageUrl,_that.steps,_that.galleryUrls,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ModelProject extends ModelProject {
  const _ModelProject({required this.id, required this.title, required this.scale, this.progress = 0.0, required this.status, this.mainImageUrl, final  List<BuildStep> steps = const [], final  List<String> galleryUrls = const [], required this.createdAt}): _steps = steps,_galleryUrls = galleryUrls,super._();
  factory _ModelProject.fromJson(Map<String, dynamic> json) => _$ModelProjectFromJson(json);

@override final  String id;
@override final  String title;
@override final  String scale;
@override@JsonKey() final  double progress;
@override final  String status;
@override final  String? mainImageUrl;
 final  List<BuildStep> _steps;
@override@JsonKey() List<BuildStep> get steps {
  if (_steps is EqualUnmodifiableListView) return _steps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_steps);
}

 final  List<String> _galleryUrls;
@override@JsonKey() List<String> get galleryUrls {
  if (_galleryUrls is EqualUnmodifiableListView) return _galleryUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_galleryUrls);
}

@override final  DateTime createdAt;

/// Create a copy of ModelProject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ModelProjectCopyWith<_ModelProject> get copyWith => __$ModelProjectCopyWithImpl<_ModelProject>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ModelProjectToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ModelProject&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.scale, scale) || other.scale == scale)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.status, status) || other.status == status)&&(identical(other.mainImageUrl, mainImageUrl) || other.mainImageUrl == mainImageUrl)&&const DeepCollectionEquality().equals(other._steps, _steps)&&const DeepCollectionEquality().equals(other._galleryUrls, _galleryUrls)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,scale,progress,status,mainImageUrl,const DeepCollectionEquality().hash(_steps),const DeepCollectionEquality().hash(_galleryUrls),createdAt);

@override
String toString() {
  return 'ModelProject(id: $id, title: $title, scale: $scale, progress: $progress, status: $status, mainImageUrl: $mainImageUrl, steps: $steps, galleryUrls: $galleryUrls, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ModelProjectCopyWith<$Res> implements $ModelProjectCopyWith<$Res> {
  factory _$ModelProjectCopyWith(_ModelProject value, $Res Function(_ModelProject) _then) = __$ModelProjectCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String scale, double progress, String status, String? mainImageUrl, List<BuildStep> steps, List<String> galleryUrls, DateTime createdAt
});




}
/// @nodoc
class __$ModelProjectCopyWithImpl<$Res>
    implements _$ModelProjectCopyWith<$Res> {
  __$ModelProjectCopyWithImpl(this._self, this._then);

  final _ModelProject _self;
  final $Res Function(_ModelProject) _then;

/// Create a copy of ModelProject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? scale = null,Object? progress = null,Object? status = null,Object? mainImageUrl = freezed,Object? steps = null,Object? galleryUrls = null,Object? createdAt = null,}) {
  return _then(_ModelProject(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,scale: null == scale ? _self.scale : scale // ignore: cast_nullable_to_non_nullable
as String,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,mainImageUrl: freezed == mainImageUrl ? _self.mainImageUrl : mainImageUrl // ignore: cast_nullable_to_non_nullable
as String?,steps: null == steps ? _self._steps : steps // ignore: cast_nullable_to_non_nullable
as List<BuildStep>,galleryUrls: null == galleryUrls ? _self._galleryUrls : galleryUrls // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
