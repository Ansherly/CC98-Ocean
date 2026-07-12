// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Contact _$ContactFromJson(Map<String, dynamic> json) => Contact(
      lastContent: _toStr(json['lastContent']),
      id: _toInt(json['userId']),
      time: _toStr(json['time']),
      name: json['name'] as String? ?? '未知用户',
      portraitUrl: json['portraitUrl'] as String? ?? '',
    );

Map<String, dynamic> _$ContactToJson(Contact instance) => <String, dynamic>{
      'lastContent': instance.lastContent,
      'userId': instance.id,
      'time': instance.time,
      'name': instance.name,
      'portraitUrl': instance.portraitUrl,
    };

_$ChatMessageImpl _$$ChatMessageImplFromJson(Map<String, dynamic> json) =>
    _$ChatMessageImpl(
      content: _toStr(json['content']),
      id: _toInt(json['id']),
      senderId: _toInt(json['senderId']),
      time: _toStr(json['time']),
    );

Map<String, dynamic> _$$ChatMessageImplToJson(_$ChatMessageImpl instance) =>
    <String, dynamic>{
      'content': instance.content,
      'id': instance.id,
      'senderId': instance.senderId,
      'time': instance.time,
    };

_$NotificationItemImpl _$$NotificationItemImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationItemImpl(
      id: _toInt(json['id']),
      type: _toInt(json['type']),
      topicId: _toInt(json['topicId']),
      postId: _toInt(json['postId']),
      boardId: _toInt(json['boardId']),
      time: _toStr(json['time']),
      isRead: _toBool(json['isRead']),
      postBasicInfo:
          PostBasicInfo.fromJson(json['postBasicInfo'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$NotificationItemImplToJson(
        _$NotificationItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'topicId': instance.topicId,
      'postId': instance.postId,
      'boardId': instance.boardId,
      'time': instance.time,
      'isRead': instance.isRead,
      'postBasicInfo': instance.postBasicInfo,
    };

_$PostBasicInfoImpl _$$PostBasicInfoImplFromJson(Map<String, dynamic> json) =>
    _$PostBasicInfoImpl(
      id: _toInt(json['id']),
      floor: _toInt(json['floor']),
      userId: _toInt(json['userId']),
      userName: _toStr(json['userName']),
      isDeleted: _toBool(json['isDeleted']),
      boardId: _toInt(json['boardId']),
    );

Map<String, dynamic> _$$PostBasicInfoImplToJson(_$PostBasicInfoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'floor': instance.floor,
      'userId': instance.userId,
      'userName': instance.userName,
      'isDeleted': instance.isDeleted,
      'boardId': instance.boardId,
    };
