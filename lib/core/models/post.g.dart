// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HotPost _$HotPostFromJson(Map<String, dynamic> json) => HotPost(
      id: _toInt(json['id']),
      authorUserId: _toInt(json['authorUserId']),
      hitCount: _toInt(json['hitCount']),
      replyCount: _toInt(json['replyCount']),
      title: _toStr(json['title']),
      authorName: _toStr(json['authorName']),
      boardName: _toStr(json['boardName']),
      portraitUrl:
          json['portraitUrl'] == null ? '' : _toStr(json['portraitUrl']),
    );

Map<String, dynamic> _$HotPostToJson(HotPost instance) => <String, dynamic>{
      'id': instance.id,
      'authorUserId': instance.authorUserId,
      'replyCount': instance.replyCount,
      'hitCount': instance.hitCount,
      'authorName': instance.authorName,
      'title': instance.title,
      'boardName': instance.boardName,
      'portraitUrl': instance.portraitUrl,
    };

FeedPost _$FeedPostFromJson(Map<String, dynamic> json) => FeedPost(
      id: _toInt(json['id']),
      isMe: _toBool(json['isMe']),
      userId: _toInt(json['userId']),
      dislikeCount: _toInt(json['dislikeCount']),
      hitCount: _toInt(json['hitCount']),
      likeCount: _toInt(json['likeCount']),
      replyCount: _toInt(json['replyCount']),
      time: _toStr(json['time']),
      title: _toStr(json['title']),
      userName: _toStr(json['userName']),
      mediaContent: _toMap(json['mediaContent']),
      portraitUrl:
          json['portraitUrl'] == null ? '' : _toStr(json['portraitUrl']),
    );

Map<String, dynamic> _$FeedPostToJson(FeedPost instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'likeCount': instance.likeCount,
      'dislikeCount': instance.dislikeCount,
      'replyCount': instance.replyCount,
      'hitCount': instance.hitCount,
      'userName': instance.userName,
      'title': instance.title,
      'time': instance.time,
      'isMe': instance.isMe,
      'portraitUrl': instance.portraitUrl,
      'mediaContent': instance.mediaContent,
    };
