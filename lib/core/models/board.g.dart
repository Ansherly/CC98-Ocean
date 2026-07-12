// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'board.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BoardInfoImpl _$$BoardInfoImplFromJson(Map<String, dynamic> json) =>
    _$BoardInfoImpl(
      id: _toInt(json['id']),
      name: _toStr(json['name']),
      description: _toStr(json['description']),
      bigPaper: json['bigPaper'] == null ? '' : _toStr(json['bigPaper']),
      boardMasters: (json['boardMasters'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      topicCount: _toInt(json['topicCount']),
      todayCount: _toInt(json['todayCount']),
    );

Map<String, dynamic> _$$BoardInfoImplToJson(_$BoardInfoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'bigPaper': instance.bigPaper,
      'boardMasters': instance.boardMasters,
      'topicCount': instance.topicCount,
      'todayCount': instance.todayCount,
    };

_$BoardSectionImpl _$$BoardSectionImplFromJson(Map<String, dynamic> json) =>
    _$BoardSectionImpl(
      name: _toStr(json['name']),
      id: _toInt(json['id']),
      boards: (json['boards'] as List<dynamic>)
          .map((e) => BoardInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$BoardSectionImplToJson(_$BoardSectionImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'id': instance.id,
      'boards': instance.boards,
    };

_$StandardPostImpl _$$StandardPostImplFromJson(Map<String, dynamic> json) =>
    _$StandardPostImpl(
      id: _toInt(json['id']),
      title: _toStr(json['title']),
      userName: json['userName'] == null ? '匿名' : _toStr(json['userName']),
      replyCount: _toInt(json['replyCount']),
      hitCount: _toInt(json['hitCount']),
    );

Map<String, dynamic> _$$StandardPostImplToJson(_$StandardPostImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'userName': instance.userName,
      'replyCount': instance.replyCount,
      'hitCount': instance.hitCount,
    };
