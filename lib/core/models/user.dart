import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

int _toInt(dynamic v) => (v as num?)?.toInt() ?? 0;
String _toStr(dynamic v) => v as String? ?? '';
bool _toBool(dynamic v) => v as bool? ?? false;

/// 用户完整资料。
@freezed
class User with _$User {
  const factory User({
    @JsonKey(fromJson: _toInt) required int id,
    @JsonKey(fromJson: _toStr) required String name,
    @JsonKey(name: 'portraitUrl', fromJson: _toStr)
    required String portraitUrl,
    @JsonKey(name: 'postCount', fromJson: _toInt) required int postCount,
    @JsonKey(name: 'fanCount', fromJson: _toInt) required int fanCount,
    @JsonKey(name: 'followCount', fromJson: _toInt) required int followCount,
    @JsonKey(fromJson: _toInt) required int gender,
    @JsonKey(fromJson: _toInt) required int popularity,
    @JsonKey(fromJson: _toInt) required int wealth,
    @JsonKey(fromJson: _toStr) required String introduction,
    @JsonKey(name: 'signatureCode', fromJson: _toStr)
    required String signatureCode,
    @JsonKey(name: 'levelTitle', fromJson: _toStr)
    required String levelTitle,
    @JsonKey(name: 'isFollowing', fromJson: _toBool)
    required bool isFollowing,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

/// 用户简略信息。
@freezed
class SimpleUserInfo with _$SimpleUserInfo {
  const factory SimpleUserInfo({
    @JsonKey(name: 'id', fromJson: _toInt) required int userId,
    @JsonKey(name: 'name', fromJson: _toStr) required String userName,
    @JsonKey(name: 'portraitUrl', fromJson: _toStr)
    required String portraitUrl,
    @JsonKey(name: 'postCount') int? postCount,
    @JsonKey(name: 'fanCount') int? fanCount,
    String? introduction,
  }) = _SimpleUserInfo;

  factory SimpleUserInfo.fromJson(Map<String, dynamic> json) =>
      _$SimpleUserInfoFromJson(json);
}
