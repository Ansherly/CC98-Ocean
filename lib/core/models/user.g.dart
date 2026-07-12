// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      id: _toInt(json['id']),
      name: _toStr(json['name']),
      portraitUrl: _toStr(json['portraitUrl']),
      postCount: _toInt(json['postCount']),
      fanCount: _toInt(json['fanCount']),
      followCount: _toInt(json['followCount']),
      gender: _toInt(json['gender']),
      popularity: _toInt(json['popularity']),
      wealth: _toInt(json['wealth']),
      introduction: _toStr(json['introduction']),
      signatureCode: _toStr(json['signatureCode']),
      levelTitle: _toStr(json['levelTitle']),
      isFollowing: _toBool(json['isFollowing']),
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'portraitUrl': instance.portraitUrl,
      'postCount': instance.postCount,
      'fanCount': instance.fanCount,
      'followCount': instance.followCount,
      'gender': instance.gender,
      'popularity': instance.popularity,
      'wealth': instance.wealth,
      'introduction': instance.introduction,
      'signatureCode': instance.signatureCode,
      'levelTitle': instance.levelTitle,
      'isFollowing': instance.isFollowing,
    };

_$SimpleUserInfoImpl _$$SimpleUserInfoImplFromJson(Map<String, dynamic> json) =>
    _$SimpleUserInfoImpl(
      userId: _toInt(json['id']),
      userName: _toStr(json['name']),
      portraitUrl: _toStr(json['portraitUrl']),
      postCount: (json['postCount'] as num?)?.toInt(),
      fanCount: (json['fanCount'] as num?)?.toInt(),
      introduction: json['introduction'] as String?,
    );

Map<String, dynamic> _$$SimpleUserInfoImplToJson(
        _$SimpleUserInfoImpl instance) =>
    <String, dynamic>{
      'id': instance.userId,
      'name': instance.userName,
      'portraitUrl': instance.portraitUrl,
      'postCount': instance.postCount,
      'fanCount': instance.fanCount,
      'introduction': instance.introduction,
    };
