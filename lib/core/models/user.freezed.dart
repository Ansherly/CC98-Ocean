// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

User _$UserFromJson(Map<String, dynamic> json) {
  return _User.fromJson(json);
}

/// @nodoc
mixin _$User {
  @JsonKey(fromJson: _toInt)
  int get id => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _toStr)
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'portraitUrl', fromJson: _toStr)
  String get portraitUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'postCount', fromJson: _toInt)
  int get postCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'fanCount', fromJson: _toInt)
  int get fanCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'followCount', fromJson: _toInt)
  int get followCount => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _toInt)
  int get gender => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _toInt)
  int get popularity => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _toInt)
  int get wealth => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _toStr)
  String get introduction => throw _privateConstructorUsedError;
  @JsonKey(name: 'signatureCode', fromJson: _toStr)
  String get signatureCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'levelTitle', fromJson: _toStr)
  String get levelTitle => throw _privateConstructorUsedError;
  @JsonKey(name: 'isFollowing', fromJson: _toBool)
  bool get isFollowing => throw _privateConstructorUsedError;

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserCopyWith<User> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserCopyWith<$Res> {
  factory $UserCopyWith(User value, $Res Function(User) then) =
      _$UserCopyWithImpl<$Res, User>;
  @useResult
  $Res call(
      {@JsonKey(fromJson: _toInt) int id,
      @JsonKey(fromJson: _toStr) String name,
      @JsonKey(name: 'portraitUrl', fromJson: _toStr) String portraitUrl,
      @JsonKey(name: 'postCount', fromJson: _toInt) int postCount,
      @JsonKey(name: 'fanCount', fromJson: _toInt) int fanCount,
      @JsonKey(name: 'followCount', fromJson: _toInt) int followCount,
      @JsonKey(fromJson: _toInt) int gender,
      @JsonKey(fromJson: _toInt) int popularity,
      @JsonKey(fromJson: _toInt) int wealth,
      @JsonKey(fromJson: _toStr) String introduction,
      @JsonKey(name: 'signatureCode', fromJson: _toStr) String signatureCode,
      @JsonKey(name: 'levelTitle', fromJson: _toStr) String levelTitle,
      @JsonKey(name: 'isFollowing', fromJson: _toBool) bool isFollowing});
}

/// @nodoc
class _$UserCopyWithImpl<$Res, $Val extends User>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? portraitUrl = null,
    Object? postCount = null,
    Object? fanCount = null,
    Object? followCount = null,
    Object? gender = null,
    Object? popularity = null,
    Object? wealth = null,
    Object? introduction = null,
    Object? signatureCode = null,
    Object? levelTitle = null,
    Object? isFollowing = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      portraitUrl: null == portraitUrl
          ? _value.portraitUrl
          : portraitUrl // ignore: cast_nullable_to_non_nullable
              as String,
      postCount: null == postCount
          ? _value.postCount
          : postCount // ignore: cast_nullable_to_non_nullable
              as int,
      fanCount: null == fanCount
          ? _value.fanCount
          : fanCount // ignore: cast_nullable_to_non_nullable
              as int,
      followCount: null == followCount
          ? _value.followCount
          : followCount // ignore: cast_nullable_to_non_nullable
              as int,
      gender: null == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as int,
      popularity: null == popularity
          ? _value.popularity
          : popularity // ignore: cast_nullable_to_non_nullable
              as int,
      wealth: null == wealth
          ? _value.wealth
          : wealth // ignore: cast_nullable_to_non_nullable
              as int,
      introduction: null == introduction
          ? _value.introduction
          : introduction // ignore: cast_nullable_to_non_nullable
              as String,
      signatureCode: null == signatureCode
          ? _value.signatureCode
          : signatureCode // ignore: cast_nullable_to_non_nullable
              as String,
      levelTitle: null == levelTitle
          ? _value.levelTitle
          : levelTitle // ignore: cast_nullable_to_non_nullable
              as String,
      isFollowing: null == isFollowing
          ? _value.isFollowing
          : isFollowing // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserImplCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$$UserImplCopyWith(
          _$UserImpl value, $Res Function(_$UserImpl) then) =
      __$$UserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(fromJson: _toInt) int id,
      @JsonKey(fromJson: _toStr) String name,
      @JsonKey(name: 'portraitUrl', fromJson: _toStr) String portraitUrl,
      @JsonKey(name: 'postCount', fromJson: _toInt) int postCount,
      @JsonKey(name: 'fanCount', fromJson: _toInt) int fanCount,
      @JsonKey(name: 'followCount', fromJson: _toInt) int followCount,
      @JsonKey(fromJson: _toInt) int gender,
      @JsonKey(fromJson: _toInt) int popularity,
      @JsonKey(fromJson: _toInt) int wealth,
      @JsonKey(fromJson: _toStr) String introduction,
      @JsonKey(name: 'signatureCode', fromJson: _toStr) String signatureCode,
      @JsonKey(name: 'levelTitle', fromJson: _toStr) String levelTitle,
      @JsonKey(name: 'isFollowing', fromJson: _toBool) bool isFollowing});
}

/// @nodoc
class __$$UserImplCopyWithImpl<$Res>
    extends _$UserCopyWithImpl<$Res, _$UserImpl>
    implements _$$UserImplCopyWith<$Res> {
  __$$UserImplCopyWithImpl(_$UserImpl _value, $Res Function(_$UserImpl) _then)
      : super(_value, _then);

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? portraitUrl = null,
    Object? postCount = null,
    Object? fanCount = null,
    Object? followCount = null,
    Object? gender = null,
    Object? popularity = null,
    Object? wealth = null,
    Object? introduction = null,
    Object? signatureCode = null,
    Object? levelTitle = null,
    Object? isFollowing = null,
  }) {
    return _then(_$UserImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      portraitUrl: null == portraitUrl
          ? _value.portraitUrl
          : portraitUrl // ignore: cast_nullable_to_non_nullable
              as String,
      postCount: null == postCount
          ? _value.postCount
          : postCount // ignore: cast_nullable_to_non_nullable
              as int,
      fanCount: null == fanCount
          ? _value.fanCount
          : fanCount // ignore: cast_nullable_to_non_nullable
              as int,
      followCount: null == followCount
          ? _value.followCount
          : followCount // ignore: cast_nullable_to_non_nullable
              as int,
      gender: null == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as int,
      popularity: null == popularity
          ? _value.popularity
          : popularity // ignore: cast_nullable_to_non_nullable
              as int,
      wealth: null == wealth
          ? _value.wealth
          : wealth // ignore: cast_nullable_to_non_nullable
              as int,
      introduction: null == introduction
          ? _value.introduction
          : introduction // ignore: cast_nullable_to_non_nullable
              as String,
      signatureCode: null == signatureCode
          ? _value.signatureCode
          : signatureCode // ignore: cast_nullable_to_non_nullable
              as String,
      levelTitle: null == levelTitle
          ? _value.levelTitle
          : levelTitle // ignore: cast_nullable_to_non_nullable
              as String,
      isFollowing: null == isFollowing
          ? _value.isFollowing
          : isFollowing // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserImpl implements _User {
  const _$UserImpl(
      {@JsonKey(fromJson: _toInt) required this.id,
      @JsonKey(fromJson: _toStr) required this.name,
      @JsonKey(name: 'portraitUrl', fromJson: _toStr) required this.portraitUrl,
      @JsonKey(name: 'postCount', fromJson: _toInt) required this.postCount,
      @JsonKey(name: 'fanCount', fromJson: _toInt) required this.fanCount,
      @JsonKey(name: 'followCount', fromJson: _toInt) required this.followCount,
      @JsonKey(fromJson: _toInt) required this.gender,
      @JsonKey(fromJson: _toInt) required this.popularity,
      @JsonKey(fromJson: _toInt) required this.wealth,
      @JsonKey(fromJson: _toStr) required this.introduction,
      @JsonKey(name: 'signatureCode', fromJson: _toStr)
      required this.signatureCode,
      @JsonKey(name: 'levelTitle', fromJson: _toStr) required this.levelTitle,
      @JsonKey(name: 'isFollowing', fromJson: _toBool)
      required this.isFollowing});

  factory _$UserImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserImplFromJson(json);

  @override
  @JsonKey(fromJson: _toInt)
  final int id;
  @override
  @JsonKey(fromJson: _toStr)
  final String name;
  @override
  @JsonKey(name: 'portraitUrl', fromJson: _toStr)
  final String portraitUrl;
  @override
  @JsonKey(name: 'postCount', fromJson: _toInt)
  final int postCount;
  @override
  @JsonKey(name: 'fanCount', fromJson: _toInt)
  final int fanCount;
  @override
  @JsonKey(name: 'followCount', fromJson: _toInt)
  final int followCount;
  @override
  @JsonKey(fromJson: _toInt)
  final int gender;
  @override
  @JsonKey(fromJson: _toInt)
  final int popularity;
  @override
  @JsonKey(fromJson: _toInt)
  final int wealth;
  @override
  @JsonKey(fromJson: _toStr)
  final String introduction;
  @override
  @JsonKey(name: 'signatureCode', fromJson: _toStr)
  final String signatureCode;
  @override
  @JsonKey(name: 'levelTitle', fromJson: _toStr)
  final String levelTitle;
  @override
  @JsonKey(name: 'isFollowing', fromJson: _toBool)
  final bool isFollowing;

  @override
  String toString() {
    return 'User(id: $id, name: $name, portraitUrl: $portraitUrl, postCount: $postCount, fanCount: $fanCount, followCount: $followCount, gender: $gender, popularity: $popularity, wealth: $wealth, introduction: $introduction, signatureCode: $signatureCode, levelTitle: $levelTitle, isFollowing: $isFollowing)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.portraitUrl, portraitUrl) ||
                other.portraitUrl == portraitUrl) &&
            (identical(other.postCount, postCount) ||
                other.postCount == postCount) &&
            (identical(other.fanCount, fanCount) ||
                other.fanCount == fanCount) &&
            (identical(other.followCount, followCount) ||
                other.followCount == followCount) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.popularity, popularity) ||
                other.popularity == popularity) &&
            (identical(other.wealth, wealth) || other.wealth == wealth) &&
            (identical(other.introduction, introduction) ||
                other.introduction == introduction) &&
            (identical(other.signatureCode, signatureCode) ||
                other.signatureCode == signatureCode) &&
            (identical(other.levelTitle, levelTitle) ||
                other.levelTitle == levelTitle) &&
            (identical(other.isFollowing, isFollowing) ||
                other.isFollowing == isFollowing));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      portraitUrl,
      postCount,
      fanCount,
      followCount,
      gender,
      popularity,
      wealth,
      introduction,
      signatureCode,
      levelTitle,
      isFollowing);

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      __$$UserImplCopyWithImpl<_$UserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserImplToJson(
      this,
    );
  }
}

abstract class _User implements User {
  const factory _User(
      {@JsonKey(fromJson: _toInt) required final int id,
      @JsonKey(fromJson: _toStr) required final String name,
      @JsonKey(name: 'portraitUrl', fromJson: _toStr)
      required final String portraitUrl,
      @JsonKey(name: 'postCount', fromJson: _toInt)
      required final int postCount,
      @JsonKey(name: 'fanCount', fromJson: _toInt) required final int fanCount,
      @JsonKey(name: 'followCount', fromJson: _toInt)
      required final int followCount,
      @JsonKey(fromJson: _toInt) required final int gender,
      @JsonKey(fromJson: _toInt) required final int popularity,
      @JsonKey(fromJson: _toInt) required final int wealth,
      @JsonKey(fromJson: _toStr) required final String introduction,
      @JsonKey(name: 'signatureCode', fromJson: _toStr)
      required final String signatureCode,
      @JsonKey(name: 'levelTitle', fromJson: _toStr)
      required final String levelTitle,
      @JsonKey(name: 'isFollowing', fromJson: _toBool)
      required final bool isFollowing}) = _$UserImpl;

  factory _User.fromJson(Map<String, dynamic> json) = _$UserImpl.fromJson;

  @override
  @JsonKey(fromJson: _toInt)
  int get id;
  @override
  @JsonKey(fromJson: _toStr)
  String get name;
  @override
  @JsonKey(name: 'portraitUrl', fromJson: _toStr)
  String get portraitUrl;
  @override
  @JsonKey(name: 'postCount', fromJson: _toInt)
  int get postCount;
  @override
  @JsonKey(name: 'fanCount', fromJson: _toInt)
  int get fanCount;
  @override
  @JsonKey(name: 'followCount', fromJson: _toInt)
  int get followCount;
  @override
  @JsonKey(fromJson: _toInt)
  int get gender;
  @override
  @JsonKey(fromJson: _toInt)
  int get popularity;
  @override
  @JsonKey(fromJson: _toInt)
  int get wealth;
  @override
  @JsonKey(fromJson: _toStr)
  String get introduction;
  @override
  @JsonKey(name: 'signatureCode', fromJson: _toStr)
  String get signatureCode;
  @override
  @JsonKey(name: 'levelTitle', fromJson: _toStr)
  String get levelTitle;
  @override
  @JsonKey(name: 'isFollowing', fromJson: _toBool)
  bool get isFollowing;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SimpleUserInfo _$SimpleUserInfoFromJson(Map<String, dynamic> json) {
  return _SimpleUserInfo.fromJson(json);
}

/// @nodoc
mixin _$SimpleUserInfo {
  @JsonKey(name: 'id', fromJson: _toInt)
  int get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'name', fromJson: _toStr)
  String get userName => throw _privateConstructorUsedError;
  @JsonKey(name: 'portraitUrl', fromJson: _toStr)
  String get portraitUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'postCount')
  int? get postCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'fanCount')
  int? get fanCount => throw _privateConstructorUsedError;
  String? get introduction => throw _privateConstructorUsedError;

  /// Serializes this SimpleUserInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SimpleUserInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SimpleUserInfoCopyWith<SimpleUserInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SimpleUserInfoCopyWith<$Res> {
  factory $SimpleUserInfoCopyWith(
          SimpleUserInfo value, $Res Function(SimpleUserInfo) then) =
      _$SimpleUserInfoCopyWithImpl<$Res, SimpleUserInfo>;
  @useResult
  $Res call(
      {@JsonKey(name: 'id', fromJson: _toInt) int userId,
      @JsonKey(name: 'name', fromJson: _toStr) String userName,
      @JsonKey(name: 'portraitUrl', fromJson: _toStr) String portraitUrl,
      @JsonKey(name: 'postCount') int? postCount,
      @JsonKey(name: 'fanCount') int? fanCount,
      String? introduction});
}

/// @nodoc
class _$SimpleUserInfoCopyWithImpl<$Res, $Val extends SimpleUserInfo>
    implements $SimpleUserInfoCopyWith<$Res> {
  _$SimpleUserInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SimpleUserInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? userName = null,
    Object? portraitUrl = null,
    Object? postCount = freezed,
    Object? fanCount = freezed,
    Object? introduction = freezed,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      portraitUrl: null == portraitUrl
          ? _value.portraitUrl
          : portraitUrl // ignore: cast_nullable_to_non_nullable
              as String,
      postCount: freezed == postCount
          ? _value.postCount
          : postCount // ignore: cast_nullable_to_non_nullable
              as int?,
      fanCount: freezed == fanCount
          ? _value.fanCount
          : fanCount // ignore: cast_nullable_to_non_nullable
              as int?,
      introduction: freezed == introduction
          ? _value.introduction
          : introduction // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SimpleUserInfoImplCopyWith<$Res>
    implements $SimpleUserInfoCopyWith<$Res> {
  factory _$$SimpleUserInfoImplCopyWith(_$SimpleUserInfoImpl value,
          $Res Function(_$SimpleUserInfoImpl) then) =
      __$$SimpleUserInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'id', fromJson: _toInt) int userId,
      @JsonKey(name: 'name', fromJson: _toStr) String userName,
      @JsonKey(name: 'portraitUrl', fromJson: _toStr) String portraitUrl,
      @JsonKey(name: 'postCount') int? postCount,
      @JsonKey(name: 'fanCount') int? fanCount,
      String? introduction});
}

/// @nodoc
class __$$SimpleUserInfoImplCopyWithImpl<$Res>
    extends _$SimpleUserInfoCopyWithImpl<$Res, _$SimpleUserInfoImpl>
    implements _$$SimpleUserInfoImplCopyWith<$Res> {
  __$$SimpleUserInfoImplCopyWithImpl(
      _$SimpleUserInfoImpl _value, $Res Function(_$SimpleUserInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of SimpleUserInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? userName = null,
    Object? portraitUrl = null,
    Object? postCount = freezed,
    Object? fanCount = freezed,
    Object? introduction = freezed,
  }) {
    return _then(_$SimpleUserInfoImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      portraitUrl: null == portraitUrl
          ? _value.portraitUrl
          : portraitUrl // ignore: cast_nullable_to_non_nullable
              as String,
      postCount: freezed == postCount
          ? _value.postCount
          : postCount // ignore: cast_nullable_to_non_nullable
              as int?,
      fanCount: freezed == fanCount
          ? _value.fanCount
          : fanCount // ignore: cast_nullable_to_non_nullable
              as int?,
      introduction: freezed == introduction
          ? _value.introduction
          : introduction // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SimpleUserInfoImpl implements _SimpleUserInfo {
  const _$SimpleUserInfoImpl(
      {@JsonKey(name: 'id', fromJson: _toInt) required this.userId,
      @JsonKey(name: 'name', fromJson: _toStr) required this.userName,
      @JsonKey(name: 'portraitUrl', fromJson: _toStr) required this.portraitUrl,
      @JsonKey(name: 'postCount') this.postCount,
      @JsonKey(name: 'fanCount') this.fanCount,
      this.introduction});

  factory _$SimpleUserInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$SimpleUserInfoImplFromJson(json);

  @override
  @JsonKey(name: 'id', fromJson: _toInt)
  final int userId;
  @override
  @JsonKey(name: 'name', fromJson: _toStr)
  final String userName;
  @override
  @JsonKey(name: 'portraitUrl', fromJson: _toStr)
  final String portraitUrl;
  @override
  @JsonKey(name: 'postCount')
  final int? postCount;
  @override
  @JsonKey(name: 'fanCount')
  final int? fanCount;
  @override
  final String? introduction;

  @override
  String toString() {
    return 'SimpleUserInfo(userId: $userId, userName: $userName, portraitUrl: $portraitUrl, postCount: $postCount, fanCount: $fanCount, introduction: $introduction)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SimpleUserInfoImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.portraitUrl, portraitUrl) ||
                other.portraitUrl == portraitUrl) &&
            (identical(other.postCount, postCount) ||
                other.postCount == postCount) &&
            (identical(other.fanCount, fanCount) ||
                other.fanCount == fanCount) &&
            (identical(other.introduction, introduction) ||
                other.introduction == introduction));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, userId, userName, portraitUrl,
      postCount, fanCount, introduction);

  /// Create a copy of SimpleUserInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SimpleUserInfoImplCopyWith<_$SimpleUserInfoImpl> get copyWith =>
      __$$SimpleUserInfoImplCopyWithImpl<_$SimpleUserInfoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SimpleUserInfoImplToJson(
      this,
    );
  }
}

abstract class _SimpleUserInfo implements SimpleUserInfo {
  const factory _SimpleUserInfo(
      {@JsonKey(name: 'id', fromJson: _toInt) required final int userId,
      @JsonKey(name: 'name', fromJson: _toStr) required final String userName,
      @JsonKey(name: 'portraitUrl', fromJson: _toStr)
      required final String portraitUrl,
      @JsonKey(name: 'postCount') final int? postCount,
      @JsonKey(name: 'fanCount') final int? fanCount,
      final String? introduction}) = _$SimpleUserInfoImpl;

  factory _SimpleUserInfo.fromJson(Map<String, dynamic> json) =
      _$SimpleUserInfoImpl.fromJson;

  @override
  @JsonKey(name: 'id', fromJson: _toInt)
  int get userId;
  @override
  @JsonKey(name: 'name', fromJson: _toStr)
  String get userName;
  @override
  @JsonKey(name: 'portraitUrl', fromJson: _toStr)
  String get portraitUrl;
  @override
  @JsonKey(name: 'postCount')
  int? get postCount;
  @override
  @JsonKey(name: 'fanCount')
  int? get fanCount;
  @override
  String? get introduction;

  /// Create a copy of SimpleUserInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SimpleUserInfoImplCopyWith<_$SimpleUserInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
