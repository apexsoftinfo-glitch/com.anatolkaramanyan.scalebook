// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UserSession {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserSession);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'UserSession()';
}


}

/// @nodoc
class $UserSessionCopyWith<$Res>  {
$UserSessionCopyWith(UserSession _, $Res Function(UserSession) __);
}


/// Adds pattern-matching-related methods to [UserSession].
extension UserSessionPatterns on UserSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserSession value)?  $default,{TResult Function( _Unauthenticated value)?  unauthenticated,TResult Function( _Initializing value)?  initializing,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserSession() when $default != null:
return $default(_that);case _Unauthenticated() when unauthenticated != null:
return unauthenticated(_that);case _Initializing() when initializing != null:
return initializing(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserSession value)  $default,{required TResult Function( _Unauthenticated value)  unauthenticated,required TResult Function( _Initializing value)  initializing,}){
final _that = this;
switch (_that) {
case _UserSession():
return $default(_that);case _Unauthenticated():
return unauthenticated(_that);case _Initializing():
return initializing(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserSession value)?  $default,{TResult? Function( _Unauthenticated value)?  unauthenticated,TResult? Function( _Initializing value)?  initializing,}){
final _that = this;
switch (_that) {
case _UserSession() when $default != null:
return $default(_that);case _Unauthenticated() when unauthenticated != null:
return unauthenticated(_that);case _Initializing() when initializing != null:
return initializing(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? userId,  bool isAnonymous,  bool isOffline,  ProfileModel? profile,  bool isPro)?  $default,{TResult Function()?  unauthenticated,TResult Function()?  initializing,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserSession() when $default != null:
return $default(_that.userId,_that.isAnonymous,_that.isOffline,_that.profile,_that.isPro);case _Unauthenticated() when unauthenticated != null:
return unauthenticated();case _Initializing() when initializing != null:
return initializing();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? userId,  bool isAnonymous,  bool isOffline,  ProfileModel? profile,  bool isPro)  $default,{required TResult Function()  unauthenticated,required TResult Function()  initializing,}) {final _that = this;
switch (_that) {
case _UserSession():
return $default(_that.userId,_that.isAnonymous,_that.isOffline,_that.profile,_that.isPro);case _Unauthenticated():
return unauthenticated();case _Initializing():
return initializing();case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? userId,  bool isAnonymous,  bool isOffline,  ProfileModel? profile,  bool isPro)?  $default,{TResult? Function()?  unauthenticated,TResult? Function()?  initializing,}) {final _that = this;
switch (_that) {
case _UserSession() when $default != null:
return $default(_that.userId,_that.isAnonymous,_that.isOffline,_that.profile,_that.isPro);case _Unauthenticated() when unauthenticated != null:
return unauthenticated();case _Initializing() when initializing != null:
return initializing();case _:
  return null;

}
}

}

/// @nodoc


class _UserSession extends UserSession {
  const _UserSession({required this.userId, required this.isAnonymous, required this.isOffline, required this.profile, this.isPro = false}): super._();
  

 final  String? userId;
 final  bool isAnonymous;
 final  bool isOffline;
 final  ProfileModel? profile;
/// Whether user has active "pro" entitlement.
/// Always false until /subscription step adds RevenueCat.
@JsonKey() final  bool isPro;

/// Create a copy of UserSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserSessionCopyWith<_UserSession> get copyWith => __$UserSessionCopyWithImpl<_UserSession>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserSession&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.isAnonymous, isAnonymous) || other.isAnonymous == isAnonymous)&&(identical(other.isOffline, isOffline) || other.isOffline == isOffline)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.isPro, isPro) || other.isPro == isPro));
}


@override
int get hashCode => Object.hash(runtimeType,userId,isAnonymous,isOffline,profile,isPro);

@override
String toString() {
  return 'UserSession(userId: $userId, isAnonymous: $isAnonymous, isOffline: $isOffline, profile: $profile, isPro: $isPro)';
}


}

/// @nodoc
abstract mixin class _$UserSessionCopyWith<$Res> implements $UserSessionCopyWith<$Res> {
  factory _$UserSessionCopyWith(_UserSession value, $Res Function(_UserSession) _then) = __$UserSessionCopyWithImpl;
@useResult
$Res call({
 String? userId, bool isAnonymous, bool isOffline, ProfileModel? profile, bool isPro
});


$ProfileModelCopyWith<$Res>? get profile;

}
/// @nodoc
class __$UserSessionCopyWithImpl<$Res>
    implements _$UserSessionCopyWith<$Res> {
  __$UserSessionCopyWithImpl(this._self, this._then);

  final _UserSession _self;
  final $Res Function(_UserSession) _then;

/// Create a copy of UserSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? userId = freezed,Object? isAnonymous = null,Object? isOffline = null,Object? profile = freezed,Object? isPro = null,}) {
  return _then(_UserSession(
userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,isAnonymous: null == isAnonymous ? _self.isAnonymous : isAnonymous // ignore: cast_nullable_to_non_nullable
as bool,isOffline: null == isOffline ? _self.isOffline : isOffline // ignore: cast_nullable_to_non_nullable
as bool,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as ProfileModel?,isPro: null == isPro ? _self.isPro : isPro // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of UserSession
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileModelCopyWith<$Res>? get profile {
    if (_self.profile == null) {
    return null;
  }

  return $ProfileModelCopyWith<$Res>(_self.profile!, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}

/// @nodoc


class _Unauthenticated extends UserSession {
  const _Unauthenticated(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Unauthenticated);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'UserSession.unauthenticated()';
}


}




/// @nodoc


class _Initializing extends UserSession {
  const _Initializing(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initializing);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'UserSession.initializing()';
}


}




// dart format on
