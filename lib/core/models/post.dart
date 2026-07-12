import 'package:json_annotation/json_annotation.dart';

part 'post.g.dart';

int _toInt(dynamic v) => (v as num?)?.toInt() ?? 0;
String _toStr(dynamic v) => v as String? ?? '';
bool _toBool(dynamic v) => v as bool? ?? false;
Map<String, dynamic> _toMap(dynamic v) =>
    v as Map<String, dynamic>? ?? {};

/// 首页十大话题帖子。
@JsonSerializable()
class HotPost {
  @JsonKey(name: 'id', fromJson: _toInt)
  final int id;
  @JsonKey(name: 'authorUserId', fromJson: _toInt)
  final int authorUserId;
  @JsonKey(name: 'replyCount', fromJson: _toInt)
  int replyCount;
  @JsonKey(name: 'hitCount', fromJson: _toInt)
  int hitCount;
  @JsonKey(name: 'authorName', fromJson: _toStr)
  final String authorName;
  @JsonKey(fromJson: _toStr)
  final String title;
  @JsonKey(name: 'boardName', fromJson: _toStr)
  final String boardName;
  @JsonKey(fromJson: _toStr)
  String portraitUrl;

  HotPost({
    required this.id,
    required this.authorUserId,
    required this.hitCount,
    required this.replyCount,
    required this.title,
    required this.authorName,
    required this.boardName,
    this.portraitUrl = '',
  });

  factory HotPost.fromJson(Map<String, dynamic> json) =>
      _$HotPostFromJson(json);
  Map<String, dynamic> toJson() => _$HotPostToJson(this);
}

/// 发现页/动态页帖子。
@JsonSerializable()
class FeedPost {
  @JsonKey(name: 'id', fromJson: _toInt)
  final int id;
  @JsonKey(name: 'userId', fromJson: _toInt)
  final int userId;
  @JsonKey(name: 'likeCount', fromJson: _toInt)
  int likeCount;
  @JsonKey(name: 'dislikeCount', fromJson: _toInt)
  int dislikeCount;
  @JsonKey(name: 'replyCount', fromJson: _toInt)
  int replyCount;
  @JsonKey(name: 'hitCount', fromJson: _toInt)
  int hitCount;
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
  @JsonKey(name: 'mediaContent', fromJson: _toMap)
  final Map<String, dynamic> mediaContent;

  FeedPost({
    required this.id,
    required this.isMe,
    required this.userId,
    required this.dislikeCount,
    required this.hitCount,
    required this.likeCount,
    required this.replyCount,
    required this.time,
    required this.title,
    required this.userName,
    required this.mediaContent,
    this.portraitUrl = '',
  });

  factory FeedPost.fromJson(Map<String, dynamic> json) =>
      _$FeedPostFromJson(json);
  Map<String, dynamic> toJson() => _$FeedPostToJson(this);
}
