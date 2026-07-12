// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) {
  return _ChatMessage.fromJson(json);
}

/// @nodoc
mixin _$ChatMessage {
  @JsonKey(fromJson: _toStr)
  String get content => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _toInt)
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'senderId', fromJson: _toInt)
  int get senderId => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _toStr)
  String get time => throw _privateConstructorUsedError;

  /// Serializes this ChatMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatMessageCopyWith<ChatMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatMessageCopyWith<$Res> {
  factory $ChatMessageCopyWith(
          ChatMessage value, $Res Function(ChatMessage) then) =
      _$ChatMessageCopyWithImpl<$Res, ChatMessage>;
  @useResult
  $Res call(
      {@JsonKey(fromJson: _toStr) String content,
      @JsonKey(fromJson: _toInt) int id,
      @JsonKey(name: 'senderId', fromJson: _toInt) int senderId,
      @JsonKey(fromJson: _toStr) String time});
}

/// @nodoc
class _$ChatMessageCopyWithImpl<$Res, $Val extends ChatMessage>
    implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = null,
    Object? id = null,
    Object? senderId = null,
    Object? time = null,
  }) {
    return _then(_value.copyWith(
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as int,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChatMessageImplCopyWith<$Res>
    implements $ChatMessageCopyWith<$Res> {
  factory _$$ChatMessageImplCopyWith(
          _$ChatMessageImpl value, $Res Function(_$ChatMessageImpl) then) =
      __$$ChatMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(fromJson: _toStr) String content,
      @JsonKey(fromJson: _toInt) int id,
      @JsonKey(name: 'senderId', fromJson: _toInt) int senderId,
      @JsonKey(fromJson: _toStr) String time});
}

/// @nodoc
class __$$ChatMessageImplCopyWithImpl<$Res>
    extends _$ChatMessageCopyWithImpl<$Res, _$ChatMessageImpl>
    implements _$$ChatMessageImplCopyWith<$Res> {
  __$$ChatMessageImplCopyWithImpl(
      _$ChatMessageImpl _value, $Res Function(_$ChatMessageImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = null,
    Object? id = null,
    Object? senderId = null,
    Object? time = null,
  }) {
    return _then(_$ChatMessageImpl(
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as int,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatMessageImpl implements _ChatMessage {
  const _$ChatMessageImpl(
      {@JsonKey(fromJson: _toStr) required this.content,
      @JsonKey(fromJson: _toInt) required this.id,
      @JsonKey(name: 'senderId', fromJson: _toInt) required this.senderId,
      @JsonKey(fromJson: _toStr) required this.time});

  factory _$ChatMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatMessageImplFromJson(json);

  @override
  @JsonKey(fromJson: _toStr)
  final String content;
  @override
  @JsonKey(fromJson: _toInt)
  final int id;
  @override
  @JsonKey(name: 'senderId', fromJson: _toInt)
  final int senderId;
  @override
  @JsonKey(fromJson: _toStr)
  final String time;

  @override
  String toString() {
    return 'ChatMessage(content: $content, id: $id, senderId: $senderId, time: $time)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatMessageImpl &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.time, time) || other.time == time));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, content, id, senderId, time);

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      __$$ChatMessageImplCopyWithImpl<_$ChatMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatMessageImplToJson(
      this,
    );
  }
}

abstract class _ChatMessage implements ChatMessage {
  const factory _ChatMessage(
      {@JsonKey(fromJson: _toStr) required final String content,
      @JsonKey(fromJson: _toInt) required final int id,
      @JsonKey(name: 'senderId', fromJson: _toInt) required final int senderId,
      @JsonKey(fromJson: _toStr)
      required final String time}) = _$ChatMessageImpl;

  factory _ChatMessage.fromJson(Map<String, dynamic> json) =
      _$ChatMessageImpl.fromJson;

  @override
  @JsonKey(fromJson: _toStr)
  String get content;
  @override
  @JsonKey(fromJson: _toInt)
  int get id;
  @override
  @JsonKey(name: 'senderId', fromJson: _toInt)
  int get senderId;
  @override
  @JsonKey(fromJson: _toStr)
  String get time;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

NotificationItem _$NotificationItemFromJson(Map<String, dynamic> json) {
  return _NotificationItem.fromJson(json);
}

/// @nodoc
mixin _$NotificationItem {
  @JsonKey(fromJson: _toInt)
  int get id => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _toInt)
  int get type => throw _privateConstructorUsedError;
  @JsonKey(name: 'topicId', fromJson: _toInt)
  int get topicId => throw _privateConstructorUsedError;
  @JsonKey(name: 'postId', fromJson: _toInt)
  int get postId => throw _privateConstructorUsedError;
  @JsonKey(name: 'boardId', fromJson: _toInt)
  int get boardId => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _toStr)
  String get time => throw _privateConstructorUsedError;
  @JsonKey(name: 'isRead', fromJson: _toBool)
  bool get isRead => throw _privateConstructorUsedError;
  @JsonKey(name: 'postBasicInfo')
  PostBasicInfo get postBasicInfo => throw _privateConstructorUsedError;

  /// Serializes this NotificationItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationItemCopyWith<NotificationItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationItemCopyWith<$Res> {
  factory $NotificationItemCopyWith(
          NotificationItem value, $Res Function(NotificationItem) then) =
      _$NotificationItemCopyWithImpl<$Res, NotificationItem>;
  @useResult
  $Res call(
      {@JsonKey(fromJson: _toInt) int id,
      @JsonKey(fromJson: _toInt) int type,
      @JsonKey(name: 'topicId', fromJson: _toInt) int topicId,
      @JsonKey(name: 'postId', fromJson: _toInt) int postId,
      @JsonKey(name: 'boardId', fromJson: _toInt) int boardId,
      @JsonKey(fromJson: _toStr) String time,
      @JsonKey(name: 'isRead', fromJson: _toBool) bool isRead,
      @JsonKey(name: 'postBasicInfo') PostBasicInfo postBasicInfo});

  $PostBasicInfoCopyWith<$Res> get postBasicInfo;
}

/// @nodoc
class _$NotificationItemCopyWithImpl<$Res, $Val extends NotificationItem>
    implements $NotificationItemCopyWith<$Res> {
  _$NotificationItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? topicId = null,
    Object? postId = null,
    Object? boardId = null,
    Object? time = null,
    Object? isRead = null,
    Object? postBasicInfo = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as int,
      topicId: null == topicId
          ? _value.topicId
          : topicId // ignore: cast_nullable_to_non_nullable
              as int,
      postId: null == postId
          ? _value.postId
          : postId // ignore: cast_nullable_to_non_nullable
              as int,
      boardId: null == boardId
          ? _value.boardId
          : boardId // ignore: cast_nullable_to_non_nullable
              as int,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as String,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      postBasicInfo: null == postBasicInfo
          ? _value.postBasicInfo
          : postBasicInfo // ignore: cast_nullable_to_non_nullable
              as PostBasicInfo,
    ) as $Val);
  }

  /// Create a copy of NotificationItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PostBasicInfoCopyWith<$Res> get postBasicInfo {
    return $PostBasicInfoCopyWith<$Res>(_value.postBasicInfo, (value) {
      return _then(_value.copyWith(postBasicInfo: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$NotificationItemImplCopyWith<$Res>
    implements $NotificationItemCopyWith<$Res> {
  factory _$$NotificationItemImplCopyWith(_$NotificationItemImpl value,
          $Res Function(_$NotificationItemImpl) then) =
      __$$NotificationItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(fromJson: _toInt) int id,
      @JsonKey(fromJson: _toInt) int type,
      @JsonKey(name: 'topicId', fromJson: _toInt) int topicId,
      @JsonKey(name: 'postId', fromJson: _toInt) int postId,
      @JsonKey(name: 'boardId', fromJson: _toInt) int boardId,
      @JsonKey(fromJson: _toStr) String time,
      @JsonKey(name: 'isRead', fromJson: _toBool) bool isRead,
      @JsonKey(name: 'postBasicInfo') PostBasicInfo postBasicInfo});

  @override
  $PostBasicInfoCopyWith<$Res> get postBasicInfo;
}

/// @nodoc
class __$$NotificationItemImplCopyWithImpl<$Res>
    extends _$NotificationItemCopyWithImpl<$Res, _$NotificationItemImpl>
    implements _$$NotificationItemImplCopyWith<$Res> {
  __$$NotificationItemImplCopyWithImpl(_$NotificationItemImpl _value,
      $Res Function(_$NotificationItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of NotificationItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? topicId = null,
    Object? postId = null,
    Object? boardId = null,
    Object? time = null,
    Object? isRead = null,
    Object? postBasicInfo = null,
  }) {
    return _then(_$NotificationItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as int,
      topicId: null == topicId
          ? _value.topicId
          : topicId // ignore: cast_nullable_to_non_nullable
              as int,
      postId: null == postId
          ? _value.postId
          : postId // ignore: cast_nullable_to_non_nullable
              as int,
      boardId: null == boardId
          ? _value.boardId
          : boardId // ignore: cast_nullable_to_non_nullable
              as int,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as String,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      postBasicInfo: null == postBasicInfo
          ? _value.postBasicInfo
          : postBasicInfo // ignore: cast_nullable_to_non_nullable
              as PostBasicInfo,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationItemImpl implements _NotificationItem {
  const _$NotificationItemImpl(
      {@JsonKey(fromJson: _toInt) required this.id,
      @JsonKey(fromJson: _toInt) required this.type,
      @JsonKey(name: 'topicId', fromJson: _toInt) required this.topicId,
      @JsonKey(name: 'postId', fromJson: _toInt) required this.postId,
      @JsonKey(name: 'boardId', fromJson: _toInt) required this.boardId,
      @JsonKey(fromJson: _toStr) required this.time,
      @JsonKey(name: 'isRead', fromJson: _toBool) required this.isRead,
      @JsonKey(name: 'postBasicInfo') required this.postBasicInfo});

  factory _$NotificationItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationItemImplFromJson(json);

  @override
  @JsonKey(fromJson: _toInt)
  final int id;
  @override
  @JsonKey(fromJson: _toInt)
  final int type;
  @override
  @JsonKey(name: 'topicId', fromJson: _toInt)
  final int topicId;
  @override
  @JsonKey(name: 'postId', fromJson: _toInt)
  final int postId;
  @override
  @JsonKey(name: 'boardId', fromJson: _toInt)
  final int boardId;
  @override
  @JsonKey(fromJson: _toStr)
  final String time;
  @override
  @JsonKey(name: 'isRead', fromJson: _toBool)
  final bool isRead;
  @override
  @JsonKey(name: 'postBasicInfo')
  final PostBasicInfo postBasicInfo;

  @override
  String toString() {
    return 'NotificationItem(id: $id, type: $type, topicId: $topicId, postId: $postId, boardId: $boardId, time: $time, isRead: $isRead, postBasicInfo: $postBasicInfo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.topicId, topicId) || other.topicId == topicId) &&
            (identical(other.postId, postId) || other.postId == postId) &&
            (identical(other.boardId, boardId) || other.boardId == boardId) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            (identical(other.postBasicInfo, postBasicInfo) ||
                other.postBasicInfo == postBasicInfo));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, type, topicId, postId,
      boardId, time, isRead, postBasicInfo);

  /// Create a copy of NotificationItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationItemImplCopyWith<_$NotificationItemImpl> get copyWith =>
      __$$NotificationItemImplCopyWithImpl<_$NotificationItemImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationItemImplToJson(
      this,
    );
  }
}

abstract class _NotificationItem implements NotificationItem {
  const factory _NotificationItem(
      {@JsonKey(fromJson: _toInt) required final int id,
      @JsonKey(fromJson: _toInt) required final int type,
      @JsonKey(name: 'topicId', fromJson: _toInt) required final int topicId,
      @JsonKey(name: 'postId', fromJson: _toInt) required final int postId,
      @JsonKey(name: 'boardId', fromJson: _toInt) required final int boardId,
      @JsonKey(fromJson: _toStr) required final String time,
      @JsonKey(name: 'isRead', fromJson: _toBool) required final bool isRead,
      @JsonKey(name: 'postBasicInfo')
      required final PostBasicInfo postBasicInfo}) = _$NotificationItemImpl;

  factory _NotificationItem.fromJson(Map<String, dynamic> json) =
      _$NotificationItemImpl.fromJson;

  @override
  @JsonKey(fromJson: _toInt)
  int get id;
  @override
  @JsonKey(fromJson: _toInt)
  int get type;
  @override
  @JsonKey(name: 'topicId', fromJson: _toInt)
  int get topicId;
  @override
  @JsonKey(name: 'postId', fromJson: _toInt)
  int get postId;
  @override
  @JsonKey(name: 'boardId', fromJson: _toInt)
  int get boardId;
  @override
  @JsonKey(fromJson: _toStr)
  String get time;
  @override
  @JsonKey(name: 'isRead', fromJson: _toBool)
  bool get isRead;
  @override
  @JsonKey(name: 'postBasicInfo')
  PostBasicInfo get postBasicInfo;

  /// Create a copy of NotificationItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationItemImplCopyWith<_$NotificationItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PostBasicInfo _$PostBasicInfoFromJson(Map<String, dynamic> json) {
  return _PostBasicInfo.fromJson(json);
}

/// @nodoc
mixin _$PostBasicInfo {
  @JsonKey(fromJson: _toInt)
  int get id => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _toInt)
  int get floor => throw _privateConstructorUsedError;
  @JsonKey(name: 'userId', fromJson: _toInt)
  int get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'userName', fromJson: _toStr)
  String get userName => throw _privateConstructorUsedError;
  @JsonKey(name: 'isDeleted', fromJson: _toBool)
  bool get isDeleted => throw _privateConstructorUsedError;
  @JsonKey(name: 'boardId', fromJson: _toInt)
  int get boardId => throw _privateConstructorUsedError;

  /// Serializes this PostBasicInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PostBasicInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PostBasicInfoCopyWith<PostBasicInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PostBasicInfoCopyWith<$Res> {
  factory $PostBasicInfoCopyWith(
          PostBasicInfo value, $Res Function(PostBasicInfo) then) =
      _$PostBasicInfoCopyWithImpl<$Res, PostBasicInfo>;
  @useResult
  $Res call(
      {@JsonKey(fromJson: _toInt) int id,
      @JsonKey(fromJson: _toInt) int floor,
      @JsonKey(name: 'userId', fromJson: _toInt) int userId,
      @JsonKey(name: 'userName', fromJson: _toStr) String userName,
      @JsonKey(name: 'isDeleted', fromJson: _toBool) bool isDeleted,
      @JsonKey(name: 'boardId', fromJson: _toInt) int boardId});
}

/// @nodoc
class _$PostBasicInfoCopyWithImpl<$Res, $Val extends PostBasicInfo>
    implements $PostBasicInfoCopyWith<$Res> {
  _$PostBasicInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PostBasicInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? floor = null,
    Object? userId = null,
    Object? userName = null,
    Object? isDeleted = null,
    Object? boardId = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      floor: null == floor
          ? _value.floor
          : floor // ignore: cast_nullable_to_non_nullable
              as int,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      isDeleted: null == isDeleted
          ? _value.isDeleted
          : isDeleted // ignore: cast_nullable_to_non_nullable
              as bool,
      boardId: null == boardId
          ? _value.boardId
          : boardId // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PostBasicInfoImplCopyWith<$Res>
    implements $PostBasicInfoCopyWith<$Res> {
  factory _$$PostBasicInfoImplCopyWith(
          _$PostBasicInfoImpl value, $Res Function(_$PostBasicInfoImpl) then) =
      __$$PostBasicInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(fromJson: _toInt) int id,
      @JsonKey(fromJson: _toInt) int floor,
      @JsonKey(name: 'userId', fromJson: _toInt) int userId,
      @JsonKey(name: 'userName', fromJson: _toStr) String userName,
      @JsonKey(name: 'isDeleted', fromJson: _toBool) bool isDeleted,
      @JsonKey(name: 'boardId', fromJson: _toInt) int boardId});
}

/// @nodoc
class __$$PostBasicInfoImplCopyWithImpl<$Res>
    extends _$PostBasicInfoCopyWithImpl<$Res, _$PostBasicInfoImpl>
    implements _$$PostBasicInfoImplCopyWith<$Res> {
  __$$PostBasicInfoImplCopyWithImpl(
      _$PostBasicInfoImpl _value, $Res Function(_$PostBasicInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of PostBasicInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? floor = null,
    Object? userId = null,
    Object? userName = null,
    Object? isDeleted = null,
    Object? boardId = null,
  }) {
    return _then(_$PostBasicInfoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      floor: null == floor
          ? _value.floor
          : floor // ignore: cast_nullable_to_non_nullable
              as int,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      isDeleted: null == isDeleted
          ? _value.isDeleted
          : isDeleted // ignore: cast_nullable_to_non_nullable
              as bool,
      boardId: null == boardId
          ? _value.boardId
          : boardId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PostBasicInfoImpl implements _PostBasicInfo {
  const _$PostBasicInfoImpl(
      {@JsonKey(fromJson: _toInt) required this.id,
      @JsonKey(fromJson: _toInt) required this.floor,
      @JsonKey(name: 'userId', fromJson: _toInt) required this.userId,
      @JsonKey(name: 'userName', fromJson: _toStr) required this.userName,
      @JsonKey(name: 'isDeleted', fromJson: _toBool) required this.isDeleted,
      @JsonKey(name: 'boardId', fromJson: _toInt) required this.boardId});

  factory _$PostBasicInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PostBasicInfoImplFromJson(json);

  @override
  @JsonKey(fromJson: _toInt)
  final int id;
  @override
  @JsonKey(fromJson: _toInt)
  final int floor;
  @override
  @JsonKey(name: 'userId', fromJson: _toInt)
  final int userId;
  @override
  @JsonKey(name: 'userName', fromJson: _toStr)
  final String userName;
  @override
  @JsonKey(name: 'isDeleted', fromJson: _toBool)
  final bool isDeleted;
  @override
  @JsonKey(name: 'boardId', fromJson: _toInt)
  final int boardId;

  @override
  String toString() {
    return 'PostBasicInfo(id: $id, floor: $floor, userId: $userId, userName: $userName, isDeleted: $isDeleted, boardId: $boardId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PostBasicInfoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.floor, floor) || other.floor == floor) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted) &&
            (identical(other.boardId, boardId) || other.boardId == boardId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, floor, userId, userName, isDeleted, boardId);

  /// Create a copy of PostBasicInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PostBasicInfoImplCopyWith<_$PostBasicInfoImpl> get copyWith =>
      __$$PostBasicInfoImplCopyWithImpl<_$PostBasicInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PostBasicInfoImplToJson(
      this,
    );
  }
}

abstract class _PostBasicInfo implements PostBasicInfo {
  const factory _PostBasicInfo(
      {@JsonKey(fromJson: _toInt) required final int id,
      @JsonKey(fromJson: _toInt) required final int floor,
      @JsonKey(name: 'userId', fromJson: _toInt) required final int userId,
      @JsonKey(name: 'userName', fromJson: _toStr)
      required final String userName,
      @JsonKey(name: 'isDeleted', fromJson: _toBool)
      required final bool isDeleted,
      @JsonKey(name: 'boardId', fromJson: _toInt)
      required final int boardId}) = _$PostBasicInfoImpl;

  factory _PostBasicInfo.fromJson(Map<String, dynamic> json) =
      _$PostBasicInfoImpl.fromJson;

  @override
  @JsonKey(fromJson: _toInt)
  int get id;
  @override
  @JsonKey(fromJson: _toInt)
  int get floor;
  @override
  @JsonKey(name: 'userId', fromJson: _toInt)
  int get userId;
  @override
  @JsonKey(name: 'userName', fromJson: _toStr)
  String get userName;
  @override
  @JsonKey(name: 'isDeleted', fromJson: _toBool)
  bool get isDeleted;
  @override
  @JsonKey(name: 'boardId', fromJson: _toInt)
  int get boardId;

  /// Create a copy of PostBasicInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PostBasicInfoImplCopyWith<_$PostBasicInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
