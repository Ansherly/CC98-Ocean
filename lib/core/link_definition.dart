import 'package:cc98_ocean/controls/image_viewer.dart';
import 'package:cc98_ocean/controls/info_flower.dart';
import 'package:cc98_ocean/core/models/user.dart';
import 'package:cc98_ocean/core/network/api_client.dart';
import 'package:cc98_ocean/core/network/api_endpoints.dart';
import 'package:cc98_ocean/core/services/user_service.dart';
import 'package:cc98_ocean/pages/board.dart';
import 'package:cc98_ocean/pages/profile.dart';
import 'package:cc98_ocean/pages/user_space.dart';
import 'package:cc98_ocean/pages/topic.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 链接解析结果类型。
enum LinkTargetType { topic, board, userId, userName, image, unknown }

/// 链接解析结果（移植自 C# UrlEx 的正则约定）。
class LinkTarget {
  final LinkTargetType type;
  final String url;

  // topic
  final int topicId;
  final int? page; // 1-based 页码
  final int? anchor; // 页内楼层序号（0-based），对应 URL 的 #N

  final int boardId;
  final int userId;
  final String userName;

  const LinkTarget._({
    required this.type,
    required this.url,
    this.topicId = 0,
    this.page,
    this.anchor,
    this.boardId = 0,
    this.userId = 0,
    this.userName = '',
  });

  /// 主题链接的全局回复索引（0-based），无定位目标时为 null。
  ///
  /// 锚点 `#n` 是**页内** 1-based 楼层号，页码缺省视为第一页：
  /// 全局楼层（1-based）= (page - 1) * 10 + n，回复索引 = 全局楼层 - 1。
  /// 例：/topic/{id}#5 → 第一页 5 楼 → 索引 4；/topic/{id}/2#3 → 13 楼 → 索引 12。
  int? get globalFloor {
    if (page == null && anchor == null) return null;
    final page1 = page ?? 1;
    final globalFloor1 = (page1 - 1) * 10 + (anchor ?? 1);
    return globalFloor1 > 0 ? globalFloor1 - 1 : 0;
  }
}

/// UBB / Markdown 链接的统一路由器：
/// - 站内链接（cc98.org）跳转对应页面（帖子/版面/用户/图片预览）；
/// - 其余链接（外链）复制到剪贴板并提示。
class LinkNavigator {
  LinkNavigator._();

  // ── URL 识别（与 C# UrlEx 正则一致，并支持真实锚点格式） ──

  /// /topic/{id}、/topic/{id}/{page}、/topic/{id}#{floor}、/topic/{id}/{page}#{n}
  /// 注意：站内引用块生成的是 /topic/{id}#{楼层}（无页码段），楼层为 1-based。
  static final RegExp _topicRegex = RegExp(
      r'^(?:https?://(?:www\.)?cc98\.org)?/topic/(\d+)(?:/(\d+))?(?:#(\d+))?$');

  /// /board/{id}
  static final RegExp _boardRegex =
      RegExp(r'^https?://(?:www\.)?cc98\.org/board/(\d+)$');

  /// /user/id/{id} 与 /user/{id} 两种形式
  static final RegExp _userIdRegex =
      RegExp(r'^https?://(?:www\.)?cc98\.org/user/(?:id/)?(\d+)$');

  /// /user/name/{name}
  static final RegExp _userNameRegex = RegExp(
      r'^https?://(?:api\.cc98\.org|www\.cc98\.org)/user/name/(.+)$');

  /// file.cc98.org 上的图片
  static final RegExp _cc98ImageRegex = RegExp(
      r'^https?://file\.cc98\.org/.*\.(png|jpe?g|gif|bmp|webp)$',
      caseSensitive: false);

  static LinkTarget analyze(String url) {
    final topic = _topicRegex.firstMatch(url);
    if (topic != null) {
      return LinkTarget._(
        type: LinkTargetType.topic,
        url: url,
        topicId: int.parse(topic.group(1)!),
        page: topic.group(2) != null ? int.parse(topic.group(2)!) : null,
        anchor: topic.group(3) != null ? int.parse(topic.group(3)!) : null,
      );
    }

    final board = _boardRegex.firstMatch(url);
    if (board != null) {
      return LinkTarget._(
          type: LinkTargetType.board,
          url: url,
          boardId: int.parse(board.group(1)!));
    }

    final userId = _userIdRegex.firstMatch(url);
    if (userId != null) {
      return LinkTarget._(
          type: LinkTargetType.userId,
          url: url,
          userId: int.parse(userId.group(1)!));
    }

    final userName = _userNameRegex.firstMatch(url);
    if (userName != null) {
      return LinkTarget._(
          type: LinkTargetType.userName,
          url: url,
          userName: Uri.decodeComponent(userName.group(1)!));
    }

    if (_cc98ImageRegex.hasMatch(url)) {
      return LinkTarget._(type: LinkTargetType.image, url: url);
    }

    return LinkTarget._(type: LinkTargetType.unknown, url: url);
  }

  // ── 路由 ────────────────────────────────────────────

  /// 当前话题页的就地跳转处理器（由 Topic 注册）。
  /// 话题内点击主题链接时优先走它：跨话题就地切换内容，不 push 新路由。
  static void Function(int topicId, int? floor)? inPlaceTopicJump;

  /// 链接点击入口：站内跳转，其余复制。
  static Future<void> handle(BuildContext context, String url) async {
    if (url.trim().isEmpty) return;

    final target = analyze(url);
    switch (target.type) {
      case LinkTargetType.topic:
        final inPlace = inPlaceTopicJump;
        if (inPlace != null) {
          // 话题页内：就地跳转（跨话题切换 / 同话题切页滚动）
          inPlace(target.topicId, target.globalFloor);
          return;
        }
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => Topic(
                      topicId: target.topicId,
                      initialFloor: target.globalFloor,
                    )));
        return;
      case LinkTargetType.board:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => Board(boardId: target.boardId)));
        return;
      case LinkTargetType.userId:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => UserSpacePage(
                    userId: target.userId)));
        return;
      case LinkTargetType.userName:
        await _navigateToUserByName(context, target.userName);
        return;
      case LinkTargetType.image:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => ImagePreview(imageUrl: url)));
        return;
      case LinkTargetType.unknown:
        await copyToClipboard(context, url);
        return;
    }
  }

  /// @用户名 点击：按名字搜索用户并跳转空间（对应 C# HandleAtUserAsync）。
  static Future<void> handleUserName(BuildContext context, String name) async {
    await _navigateToUserByName(context, name);
  }

  static Future<void> _navigateToUserByName(
      BuildContext context, String name) async {
    final result = await UserService().searchUserByName(name);
    if (!context.mounted) return;
    final user = result.data;
    if (result.isError || user == null || user.userId == 0) {
      InfoFlower.show(context,
          icon: FluentIcons.person_question_mark_16_regular, text: '未找到用户');
      return;
    }
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => UserSpacePage(userId: user.userId)));
  }

  /// 外链处理：复制到剪贴板并提示。
  static Future<void> copyToClipboard(BuildContext context, String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (!context.mounted) return;
    InfoFlower.show(context,
        icon: FluentIcons.clipboard_paste_16_regular, text: '链接已复制到剪贴板');
  }

  /// 批量取用户信息（供其他模块复用）。
  static Future<List<SimpleUserInfo>> fetchBasicUsers(List<int> userIds) async {
    if (userIds.isEmpty) return [];
    final result = await ApiClient.instance.getTyped<List<dynamic>>(
      ApiEndpoints.basicUserInfoList(
          userIds.map((id) => 'id=$id').join('&')),
      fromJson: (json) => json as List<dynamic>,
    );
    if (result.isError) return [];
    return result.data!
        .map((e) => SimpleUserInfo.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
