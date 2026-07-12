// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reply.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Reply _$ReplyFromJson(Map<String, dynamic> json) => Reply(
      id: _toInt(json['id']),
      isMe: _toBool(json['isMe']),
      userId: _toInt(json['userId']),
      dislikeCount: _toInt(json['dislikeCount']),
      contentType: _toInt(json['contentType']),
      likeCount: _toInt(json['likeCount']),
      floor: _toInt(json['floor']),
      time: _toStr(json['time']),
      title: _toStr(json['title']),
      userName: _toStr(json['userName']),
      content: _toStr(json['content']),
      likeState: _toInt(json['likeState']),
      portraitUrl:
          json['portraitUrl'] == null ? '' : _toStr(json['portraitUrl']),
    );

Map<String, dynamic> _$ReplyToJson(Reply instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'likeCount': instance.likeCount,
      'dislikeCount': instance.dislikeCount,
      'likeState': instance.likeState,
      'floor': instance.floor,
      'contentType': instance.contentType,
      'userName': instance.userName,
      'title': instance.title,
      'time': instance.time,
      'isMe': instance.isMe,
      'portraitUrl': instance.portraitUrl,
      'content': instance.content,
    };
