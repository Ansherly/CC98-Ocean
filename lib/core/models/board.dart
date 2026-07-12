import 'package:freezed_annotation/freezed_annotation.dart';

part 'board.freezed.dart';
part 'board.g.dart';

int _toInt(dynamic v) => (v as num?)?.toInt() ?? 0;
String _toStr(dynamic v) => v as String? ?? '';

/// 版面基本信息。
@freezed
class BoardInfo with _$BoardInfo {
  const factory BoardInfo({
    @JsonKey(fromJson: _toInt) required int id,
    @JsonKey(fromJson: _toStr) required String name,
    @JsonKey(fromJson: _toStr) required String description,
    @JsonKey(name: 'bigPaper', fromJson: _toStr) @Default('') String bigPaper,
    @JsonKey(name: 'boardMasters')
    @Default([])
    List<String> boardMasters,
    @JsonKey(name: 'topicCount', fromJson: _toInt) required int topicCount,
    @JsonKey(name: 'todayCount', fromJson: _toInt) required int todayCount,
  }) = _BoardInfo;

  factory BoardInfo.fromJson(Map<String, dynamic> json) =>
      _$BoardInfoFromJson(json);
}

/// 版面分区。
@freezed
class BoardSection with _$BoardSection {
  const factory BoardSection({
    @JsonKey(fromJson: _toStr) required String name,
    @JsonKey(fromJson: _toInt) required int id,
    required List<BoardInfo> boards,
  }) = _BoardSection;

  factory BoardSection.fromJson(Map<String, dynamic> json) =>
      _$BoardSectionFromJson(json);
}

/// 版面帖子条目。
@freezed
class StandardPost with _$StandardPost {
  const factory StandardPost({
    @JsonKey(fromJson: _toInt) required int id,
    @JsonKey(fromJson: _toStr) required String title,
    @JsonKey(name: 'userName', fromJson: _toStr)
    @Default('匿名')
    String userName,
    @JsonKey(name: 'replyCount', fromJson: _toInt) required int replyCount,
    @JsonKey(name: 'hitCount', fromJson: _toInt) required int hitCount,
  }) = _StandardPost;

  factory StandardPost.fromJson(Map<String, dynamic> json) =>
      _$StandardPostFromJson(json);
}
