// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'board.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BoardInfo _$BoardInfoFromJson(Map<String, dynamic> json) {
  return _BoardInfo.fromJson(json);
}

/// @nodoc
mixin _$BoardInfo {
  @JsonKey(fromJson: _toInt)
  int get id => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _toStr)
  String get name => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _toStr)
  String get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'bigPaper', fromJson: _toStr)
  String get bigPaper => throw _privateConstructorUsedError;
  @JsonKey(name: 'boardMasters')
  List<String> get boardMasters => throw _privateConstructorUsedError;
  @JsonKey(name: 'topicCount', fromJson: _toInt)
  int get topicCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'todayCount', fromJson: _toInt)
  int get todayCount => throw _privateConstructorUsedError;

  /// Serializes this BoardInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BoardInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BoardInfoCopyWith<BoardInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BoardInfoCopyWith<$Res> {
  factory $BoardInfoCopyWith(BoardInfo value, $Res Function(BoardInfo) then) =
      _$BoardInfoCopyWithImpl<$Res, BoardInfo>;
  @useResult
  $Res call(
      {@JsonKey(fromJson: _toInt) int id,
      @JsonKey(fromJson: _toStr) String name,
      @JsonKey(fromJson: _toStr) String description,
      @JsonKey(name: 'bigPaper', fromJson: _toStr) String bigPaper,
      @JsonKey(name: 'boardMasters') List<String> boardMasters,
      @JsonKey(name: 'topicCount', fromJson: _toInt) int topicCount,
      @JsonKey(name: 'todayCount', fromJson: _toInt) int todayCount});
}

/// @nodoc
class _$BoardInfoCopyWithImpl<$Res, $Val extends BoardInfo>
    implements $BoardInfoCopyWith<$Res> {
  _$BoardInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BoardInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? bigPaper = null,
    Object? boardMasters = null,
    Object? topicCount = null,
    Object? todayCount = null,
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
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      bigPaper: null == bigPaper
          ? _value.bigPaper
          : bigPaper // ignore: cast_nullable_to_non_nullable
              as String,
      boardMasters: null == boardMasters
          ? _value.boardMasters
          : boardMasters // ignore: cast_nullable_to_non_nullable
              as List<String>,
      topicCount: null == topicCount
          ? _value.topicCount
          : topicCount // ignore: cast_nullable_to_non_nullable
              as int,
      todayCount: null == todayCount
          ? _value.todayCount
          : todayCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BoardInfoImplCopyWith<$Res>
    implements $BoardInfoCopyWith<$Res> {
  factory _$$BoardInfoImplCopyWith(
          _$BoardInfoImpl value, $Res Function(_$BoardInfoImpl) then) =
      __$$BoardInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(fromJson: _toInt) int id,
      @JsonKey(fromJson: _toStr) String name,
      @JsonKey(fromJson: _toStr) String description,
      @JsonKey(name: 'bigPaper', fromJson: _toStr) String bigPaper,
      @JsonKey(name: 'boardMasters') List<String> boardMasters,
      @JsonKey(name: 'topicCount', fromJson: _toInt) int topicCount,
      @JsonKey(name: 'todayCount', fromJson: _toInt) int todayCount});
}

/// @nodoc
class __$$BoardInfoImplCopyWithImpl<$Res>
    extends _$BoardInfoCopyWithImpl<$Res, _$BoardInfoImpl>
    implements _$$BoardInfoImplCopyWith<$Res> {
  __$$BoardInfoImplCopyWithImpl(
      _$BoardInfoImpl _value, $Res Function(_$BoardInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of BoardInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? bigPaper = null,
    Object? boardMasters = null,
    Object? topicCount = null,
    Object? todayCount = null,
  }) {
    return _then(_$BoardInfoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      bigPaper: null == bigPaper
          ? _value.bigPaper
          : bigPaper // ignore: cast_nullable_to_non_nullable
              as String,
      boardMasters: null == boardMasters
          ? _value._boardMasters
          : boardMasters // ignore: cast_nullable_to_non_nullable
              as List<String>,
      topicCount: null == topicCount
          ? _value.topicCount
          : topicCount // ignore: cast_nullable_to_non_nullable
              as int,
      todayCount: null == todayCount
          ? _value.todayCount
          : todayCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BoardInfoImpl implements _BoardInfo {
  const _$BoardInfoImpl(
      {@JsonKey(fromJson: _toInt) required this.id,
      @JsonKey(fromJson: _toStr) required this.name,
      @JsonKey(fromJson: _toStr) required this.description,
      @JsonKey(name: 'bigPaper', fromJson: _toStr) this.bigPaper = '',
      @JsonKey(name: 'boardMasters') final List<String> boardMasters = const [],
      @JsonKey(name: 'topicCount', fromJson: _toInt) required this.topicCount,
      @JsonKey(name: 'todayCount', fromJson: _toInt) required this.todayCount})
      : _boardMasters = boardMasters;

  factory _$BoardInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$BoardInfoImplFromJson(json);

  @override
  @JsonKey(fromJson: _toInt)
  final int id;
  @override
  @JsonKey(fromJson: _toStr)
  final String name;
  @override
  @JsonKey(fromJson: _toStr)
  final String description;
  @override
  @JsonKey(name: 'bigPaper', fromJson: _toStr)
  final String bigPaper;
  final List<String> _boardMasters;
  @override
  @JsonKey(name: 'boardMasters')
  List<String> get boardMasters {
    if (_boardMasters is EqualUnmodifiableListView) return _boardMasters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_boardMasters);
  }

  @override
  @JsonKey(name: 'topicCount', fromJson: _toInt)
  final int topicCount;
  @override
  @JsonKey(name: 'todayCount', fromJson: _toInt)
  final int todayCount;

  @override
  String toString() {
    return 'BoardInfo(id: $id, name: $name, description: $description, bigPaper: $bigPaper, boardMasters: $boardMasters, topicCount: $topicCount, todayCount: $todayCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BoardInfoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.bigPaper, bigPaper) ||
                other.bigPaper == bigPaper) &&
            const DeepCollectionEquality()
                .equals(other._boardMasters, _boardMasters) &&
            (identical(other.topicCount, topicCount) ||
                other.topicCount == topicCount) &&
            (identical(other.todayCount, todayCount) ||
                other.todayCount == todayCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      description,
      bigPaper,
      const DeepCollectionEquality().hash(_boardMasters),
      topicCount,
      todayCount);

  /// Create a copy of BoardInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BoardInfoImplCopyWith<_$BoardInfoImpl> get copyWith =>
      __$$BoardInfoImplCopyWithImpl<_$BoardInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BoardInfoImplToJson(
      this,
    );
  }
}

abstract class _BoardInfo implements BoardInfo {
  const factory _BoardInfo(
      {@JsonKey(fromJson: _toInt) required final int id,
      @JsonKey(fromJson: _toStr) required final String name,
      @JsonKey(fromJson: _toStr) required final String description,
      @JsonKey(name: 'bigPaper', fromJson: _toStr) final String bigPaper,
      @JsonKey(name: 'boardMasters') final List<String> boardMasters,
      @JsonKey(name: 'topicCount', fromJson: _toInt)
      required final int topicCount,
      @JsonKey(name: 'todayCount', fromJson: _toInt)
      required final int todayCount}) = _$BoardInfoImpl;

  factory _BoardInfo.fromJson(Map<String, dynamic> json) =
      _$BoardInfoImpl.fromJson;

  @override
  @JsonKey(fromJson: _toInt)
  int get id;
  @override
  @JsonKey(fromJson: _toStr)
  String get name;
  @override
  @JsonKey(fromJson: _toStr)
  String get description;
  @override
  @JsonKey(name: 'bigPaper', fromJson: _toStr)
  String get bigPaper;
  @override
  @JsonKey(name: 'boardMasters')
  List<String> get boardMasters;
  @override
  @JsonKey(name: 'topicCount', fromJson: _toInt)
  int get topicCount;
  @override
  @JsonKey(name: 'todayCount', fromJson: _toInt)
  int get todayCount;

  /// Create a copy of BoardInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BoardInfoImplCopyWith<_$BoardInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BoardSection _$BoardSectionFromJson(Map<String, dynamic> json) {
  return _BoardSection.fromJson(json);
}

/// @nodoc
mixin _$BoardSection {
  @JsonKey(fromJson: _toStr)
  String get name => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _toInt)
  int get id => throw _privateConstructorUsedError;
  List<BoardInfo> get boards => throw _privateConstructorUsedError;

  /// Serializes this BoardSection to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BoardSection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BoardSectionCopyWith<BoardSection> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BoardSectionCopyWith<$Res> {
  factory $BoardSectionCopyWith(
          BoardSection value, $Res Function(BoardSection) then) =
      _$BoardSectionCopyWithImpl<$Res, BoardSection>;
  @useResult
  $Res call(
      {@JsonKey(fromJson: _toStr) String name,
      @JsonKey(fromJson: _toInt) int id,
      List<BoardInfo> boards});
}

/// @nodoc
class _$BoardSectionCopyWithImpl<$Res, $Val extends BoardSection>
    implements $BoardSectionCopyWith<$Res> {
  _$BoardSectionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BoardSection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? id = null,
    Object? boards = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      boards: null == boards
          ? _value.boards
          : boards // ignore: cast_nullable_to_non_nullable
              as List<BoardInfo>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BoardSectionImplCopyWith<$Res>
    implements $BoardSectionCopyWith<$Res> {
  factory _$$BoardSectionImplCopyWith(
          _$BoardSectionImpl value, $Res Function(_$BoardSectionImpl) then) =
      __$$BoardSectionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(fromJson: _toStr) String name,
      @JsonKey(fromJson: _toInt) int id,
      List<BoardInfo> boards});
}

/// @nodoc
class __$$BoardSectionImplCopyWithImpl<$Res>
    extends _$BoardSectionCopyWithImpl<$Res, _$BoardSectionImpl>
    implements _$$BoardSectionImplCopyWith<$Res> {
  __$$BoardSectionImplCopyWithImpl(
      _$BoardSectionImpl _value, $Res Function(_$BoardSectionImpl) _then)
      : super(_value, _then);

  /// Create a copy of BoardSection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? id = null,
    Object? boards = null,
  }) {
    return _then(_$BoardSectionImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      boards: null == boards
          ? _value._boards
          : boards // ignore: cast_nullable_to_non_nullable
              as List<BoardInfo>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BoardSectionImpl implements _BoardSection {
  const _$BoardSectionImpl(
      {@JsonKey(fromJson: _toStr) required this.name,
      @JsonKey(fromJson: _toInt) required this.id,
      required final List<BoardInfo> boards})
      : _boards = boards;

  factory _$BoardSectionImpl.fromJson(Map<String, dynamic> json) =>
      _$$BoardSectionImplFromJson(json);

  @override
  @JsonKey(fromJson: _toStr)
  final String name;
  @override
  @JsonKey(fromJson: _toInt)
  final int id;
  final List<BoardInfo> _boards;
  @override
  List<BoardInfo> get boards {
    if (_boards is EqualUnmodifiableListView) return _boards;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_boards);
  }

  @override
  String toString() {
    return 'BoardSection(name: $name, id: $id, boards: $boards)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BoardSectionImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality().equals(other._boards, _boards));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, name, id, const DeepCollectionEquality().hash(_boards));

  /// Create a copy of BoardSection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BoardSectionImplCopyWith<_$BoardSectionImpl> get copyWith =>
      __$$BoardSectionImplCopyWithImpl<_$BoardSectionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BoardSectionImplToJson(
      this,
    );
  }
}

abstract class _BoardSection implements BoardSection {
  const factory _BoardSection(
      {@JsonKey(fromJson: _toStr) required final String name,
      @JsonKey(fromJson: _toInt) required final int id,
      required final List<BoardInfo> boards}) = _$BoardSectionImpl;

  factory _BoardSection.fromJson(Map<String, dynamic> json) =
      _$BoardSectionImpl.fromJson;

  @override
  @JsonKey(fromJson: _toStr)
  String get name;
  @override
  @JsonKey(fromJson: _toInt)
  int get id;
  @override
  List<BoardInfo> get boards;

  /// Create a copy of BoardSection
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BoardSectionImplCopyWith<_$BoardSectionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StandardPost _$StandardPostFromJson(Map<String, dynamic> json) {
  return _StandardPost.fromJson(json);
}

/// @nodoc
mixin _$StandardPost {
  @JsonKey(fromJson: _toInt)
  int get id => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _toStr)
  String get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'userName', fromJson: _toStr)
  String get userName => throw _privateConstructorUsedError;
  @JsonKey(name: 'replyCount', fromJson: _toInt)
  int get replyCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'hitCount', fromJson: _toInt)
  int get hitCount => throw _privateConstructorUsedError;

  /// Serializes this StandardPost to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StandardPost
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StandardPostCopyWith<StandardPost> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StandardPostCopyWith<$Res> {
  factory $StandardPostCopyWith(
          StandardPost value, $Res Function(StandardPost) then) =
      _$StandardPostCopyWithImpl<$Res, StandardPost>;
  @useResult
  $Res call(
      {@JsonKey(fromJson: _toInt) int id,
      @JsonKey(fromJson: _toStr) String title,
      @JsonKey(name: 'userName', fromJson: _toStr) String userName,
      @JsonKey(name: 'replyCount', fromJson: _toInt) int replyCount,
      @JsonKey(name: 'hitCount', fromJson: _toInt) int hitCount});
}

/// @nodoc
class _$StandardPostCopyWithImpl<$Res, $Val extends StandardPost>
    implements $StandardPostCopyWith<$Res> {
  _$StandardPostCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StandardPost
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? userName = null,
    Object? replyCount = null,
    Object? hitCount = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      replyCount: null == replyCount
          ? _value.replyCount
          : replyCount // ignore: cast_nullable_to_non_nullable
              as int,
      hitCount: null == hitCount
          ? _value.hitCount
          : hitCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StandardPostImplCopyWith<$Res>
    implements $StandardPostCopyWith<$Res> {
  factory _$$StandardPostImplCopyWith(
          _$StandardPostImpl value, $Res Function(_$StandardPostImpl) then) =
      __$$StandardPostImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(fromJson: _toInt) int id,
      @JsonKey(fromJson: _toStr) String title,
      @JsonKey(name: 'userName', fromJson: _toStr) String userName,
      @JsonKey(name: 'replyCount', fromJson: _toInt) int replyCount,
      @JsonKey(name: 'hitCount', fromJson: _toInt) int hitCount});
}

/// @nodoc
class __$$StandardPostImplCopyWithImpl<$Res>
    extends _$StandardPostCopyWithImpl<$Res, _$StandardPostImpl>
    implements _$$StandardPostImplCopyWith<$Res> {
  __$$StandardPostImplCopyWithImpl(
      _$StandardPostImpl _value, $Res Function(_$StandardPostImpl) _then)
      : super(_value, _then);

  /// Create a copy of StandardPost
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? userName = null,
    Object? replyCount = null,
    Object? hitCount = null,
  }) {
    return _then(_$StandardPostImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      replyCount: null == replyCount
          ? _value.replyCount
          : replyCount // ignore: cast_nullable_to_non_nullable
              as int,
      hitCount: null == hitCount
          ? _value.hitCount
          : hitCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StandardPostImpl implements _StandardPost {
  const _$StandardPostImpl(
      {@JsonKey(fromJson: _toInt) required this.id,
      @JsonKey(fromJson: _toStr) required this.title,
      @JsonKey(name: 'userName', fromJson: _toStr) this.userName = '匿名',
      @JsonKey(name: 'replyCount', fromJson: _toInt) required this.replyCount,
      @JsonKey(name: 'hitCount', fromJson: _toInt) required this.hitCount});

  factory _$StandardPostImpl.fromJson(Map<String, dynamic> json) =>
      _$$StandardPostImplFromJson(json);

  @override
  @JsonKey(fromJson: _toInt)
  final int id;
  @override
  @JsonKey(fromJson: _toStr)
  final String title;
  @override
  @JsonKey(name: 'userName', fromJson: _toStr)
  final String userName;
  @override
  @JsonKey(name: 'replyCount', fromJson: _toInt)
  final int replyCount;
  @override
  @JsonKey(name: 'hitCount', fromJson: _toInt)
  final int hitCount;

  @override
  String toString() {
    return 'StandardPost(id: $id, title: $title, userName: $userName, replyCount: $replyCount, hitCount: $hitCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StandardPostImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.replyCount, replyCount) ||
                other.replyCount == replyCount) &&
            (identical(other.hitCount, hitCount) ||
                other.hitCount == hitCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, title, userName, replyCount, hitCount);

  /// Create a copy of StandardPost
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StandardPostImplCopyWith<_$StandardPostImpl> get copyWith =>
      __$$StandardPostImplCopyWithImpl<_$StandardPostImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StandardPostImplToJson(
      this,
    );
  }
}

abstract class _StandardPost implements StandardPost {
  const factory _StandardPost(
      {@JsonKey(fromJson: _toInt) required final int id,
      @JsonKey(fromJson: _toStr) required final String title,
      @JsonKey(name: 'userName', fromJson: _toStr) final String userName,
      @JsonKey(name: 'replyCount', fromJson: _toInt)
      required final int replyCount,
      @JsonKey(name: 'hitCount', fromJson: _toInt)
      required final int hitCount}) = _$StandardPostImpl;

  factory _StandardPost.fromJson(Map<String, dynamic> json) =
      _$StandardPostImpl.fromJson;

  @override
  @JsonKey(fromJson: _toInt)
  int get id;
  @override
  @JsonKey(fromJson: _toStr)
  String get title;
  @override
  @JsonKey(name: 'userName', fromJson: _toStr)
  String get userName;
  @override
  @JsonKey(name: 'replyCount', fromJson: _toInt)
  int get replyCount;
  @override
  @JsonKey(name: 'hitCount', fromJson: _toInt)
  int get hitCount;

  /// Create a copy of StandardPost
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StandardPostImplCopyWith<_$StandardPostImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
