import 'package:json_annotation/json_annotation.dart';

part 'reply.g.dart';

int _toInt(dynamic v) => (v as num?)?.toInt() ?? 0;
String _toStr(dynamic v) => v as String? ?? '';
bool _toBool(dynamic v) => v as bool? ?? false;

/// 帖子回复。
@JsonSerializable()
class Reply {
  @JsonKey(fromJson: _toInt)
  final int id;
  @JsonKey(name: 'userId', fromJson: _toInt)
  final int userId;
  @JsonKey(name: 'likeCount', fromJson: _toInt)
  int likeCount;
  @JsonKey(name: 'dislikeCount', fromJson: _toInt)
  int dislikeCount;
  @JsonKey(name: 'likeState', fromJson: _toInt)
  int likeState;
  @JsonKey(fromJson: _toInt)
  final int floor;
  @JsonKey(name: 'contentType', fromJson: _toInt)
  final int contentType;
  @JsonKey(name: 'userName', fromJson: _toStr)
  final String userName;
  @JsonKey(fromJson: _toStr)
  final String title;
  @JsonKey(fromJson: _toStr)
  final String time;
  @JsonKey(name: 'isMe', fromJson: _toBool)
  final bool isMe;
  @JsonKey(fromJson: _toStr)
  String portraitUrl;
  @JsonKey(fromJson: _toStr)
  final String content;

  Reply({
    required this.id,
    required this.isMe,
    required this.userId,
    required this.dislikeCount,
    required this.contentType,
    required this.likeCount,
    required this.floor,
    required this.time,
    required this.title,
    required this.userName,
    required this.content,
    required this.likeState,
    this.portraitUrl = '',
  });

  factory Reply.fromJson(Map<String, dynamic> json) =>
      _$ReplyFromJson(json);
  Map<String, dynamic> toJson() => _$ReplyToJson(this);
}
