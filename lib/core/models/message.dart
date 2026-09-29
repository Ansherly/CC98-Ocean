import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';
part 'message.g.dart';

int _toInt(dynamic v) => (v as num?)?.toInt() ?? 0;
String _toStr(dynamic v) => v as String? ?? '';
bool _toBool(dynamic v) => v as bool? ?? false;

/// 聊天消息。
@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    @JsonKey(fromJson: _toStr) required String content,
    @JsonKey(fromJson: _toInt) required int id,
    @JsonKey(name: 'senderId', fromJson: _toInt) required int senderId,
    @JsonKey(fromJson: _toStr) required String time,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}

/// 私信联系人。
@JsonSerializable()
class Contact {
  @JsonKey(name: 'lastContent', fromJson: _toStr)
  final String lastContent;
  @JsonKey(name: 'userId', fromJson: _toInt)
  final int id;
  @JsonKey(fromJson: _toStr)
  final String time;
  String name;
  String portraitUrl;

  Contact({
    required this.lastContent,
    required this.id,
    required this.time,
    this.name = '未知用户',
    this.portraitUrl = '',
  });

  factory Contact.fromJson(Map<String, dynamic> json) =>
      _$ContactFromJson(json);
  Map<String, dynamic> toJson() => _$ContactToJson(this);
}

/// 通知项。
@freezed
class NotificationItem with _$NotificationItem {
  const factory NotificationItem({
    @JsonKey(fromJson: _toInt) required int id,
    @JsonKey(fromJson: _toInt) required int type,
    @JsonKey(name: 'topicId', fromJson: _toInt) required int topicId,
    @JsonKey(name: 'postId', fromJson: _toInt) required int postId,
    @JsonKey(name: 'boardId', fromJson: _toInt) required int boardId,
    @JsonKey(fromJson: _toStr) required String time,
    @JsonKey(name: 'isRead', fromJson: _toBool) required bool isRead,
    @JsonKey(name: 'postBasicInfo')
    required PostBasicInfo postBasicInfo,
  }) = _NotificationItem;

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      _$NotificationItemFromJson(json);
}

/// 通知中的帖子基本信息。
@freezed
class PostBasicInfo with _$PostBasicInfo {
  const factory PostBasicInfo({
    @JsonKey(fromJson: _toInt) required int id,
    @JsonKey(fromJson: _toInt) required int floor,
    @JsonKey(name: 'userId', fromJson: _toInt) required int userId,
    @JsonKey(name: 'userName', fromJson: _toStr) required String userName,
    @JsonKey(name: 'isDeleted', fromJson: _toBool) required bool isDeleted,
    @JsonKey(name: 'boardId', fromJson: _toInt) required int boardId,
  }) = _PostBasicInfo;

  factory PostBasicInfo.fromJson(Map<String, dynamic> json) =>
      _$PostBasicInfoFromJson(json);
}
