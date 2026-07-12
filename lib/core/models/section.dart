import 'package:freezed_annotation/freezed_annotation.dart';

import 'post.dart';

part 'section.freezed.dart';
part 'section.g.dart';

/// 首页分区元数据。
@freezed
class SectionInfo with _$SectionInfo {
  const factory SectionInfo({
    @JsonKey(name: 'jsonPropertyName') required String jsonPropertyName,
    required String description,
  }) = _SectionInfo;

  factory SectionInfo.fromJson(Map<String, dynamic> json) =>
      _$SectionInfoFromJson(json);
}

/// 首页分区，含帖子列表。
class IndexSection {
  final String name;
  final String description;
  List<HotPost> posts;
  bool portraitLoaded;

  IndexSection({
    required this.name,
    required this.description,
    required this.posts,
    this.portraitLoaded = false,
  });

  factory IndexSection.fromJson(String key, List<HotPost> posts) {
    const nameToDescription = {
      'hotTopic': '十大话题',
      'schoolEvent': '校园活动',
      'academics': '学术通知',
      'emotion': '感性·情感',
      'partTimeJob': '实习兼职',
      'fullTimeJob': '求职广场',
      'fleaMarket': '跳蚤市场',
      'study': '学习天地',
    };
    return IndexSection(
      name: key,
      description: nameToDescription[key] ?? '未知版块',
      posts: posts,
    );
  }
}
