import 'dart:convert';

import 'package:cc98_ocean/core/models/board.dart';
import 'package:cc98_ocean/core/models/extras.dart';
import 'package:cc98_ocean/core/models/user.dart';
import 'package:cc98_ocean/core/network/api_client.dart';
import 'package:cc98_ocean/core/network/api_endpoints.dart';
import 'package:cc98_ocean/core/network/result.dart';
import 'package:dio/dio.dart';

/// 用户与消息相关的数据访问层。
class UserService {
  final _api = ApiClient.instance;

  // ── 通用辅助 ────────────────────────────────────────

  /// 无数据返回的写操作封装：成功返回 [ApiOutcome.success]。
  Future<ApiOutcome> _write(Future<dynamic> Function() request,
      {bool Function(dynamic)? validate}) async {
    try {
      final response = await request();
      final ok = response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300 &&
          (validate == null || validate(response.data));
      return ApiOutcome(
        success: ok,
        message: ok ? null : (response.data?.toString() ?? '请求失败'),
      );
    } catch (e) {
      return ApiOutcome(success: false, message: e.toString());
    }
  }

  Options get _jsonEmpty => Options(headers: {'Content-Type': 'application/json'});

  // ── 查询 ────────────────────────────────────────────

  /// 批量获取用户头像 URL 并写入模型。
  Future<void> enrichPortraits<T>(
    List<T> items,
    int Function(T) getUserId,
    void Function(T, String) setPortraitUrl,
  ) async {
    if (items.isEmpty) return;
    final userIds = items.map(getUserId).toSet().toList();
    final result = await _api.getTyped<List<dynamic>>(
      ApiEndpoints.basicUserInfoList(
          userIds.map((id) => 'id=$id').join('&')),
      fromJson: (json) => json as List<dynamic>,
    );
    if (result.isError) return;

    final portraitMap = result.data!
        .map((e) => SimpleUserInfo.fromJson(e as Map<String, dynamic>))
        .toList();
    for (final item in items) {
      final uid = getUserId(item);
      SimpleUserInfo? match;
      try {
        match = portraitMap.firstWhere((u) => u.userId == uid);
      } catch (_) {
        match = null;
      }
      if (match != null) {
        setPortraitUrl(item, match.portraitUrl);
      }
    }
  }

  Future<ApiResponse<User>> getUserProfile({
    required bool isMe,
    int userId = 0,
  }) =>
      _api.getTyped(ApiEndpoints.userProfile(isMe: isMe, userId: userId),
          fromJson: (json) => User.fromJson(json as Map<String, dynamic>));

  Future<ApiResponse<List<StandardPost>>> getRecentTopics({
    required bool isMe,
    required int userId,
    required int start,
  }) =>
      _api.getTyped(
          ApiEndpoints.recentTopic(isMe: isMe, userId: userId, start: start),
          fromJson: (json) => (json as List)
              .map((e) =>
                  StandardPost.fromJson(e as Map<String, dynamic>))
              .toList());

  Future<ApiResponse<List<SimpleUserInfo>>> getFriends(
    String type,
    int start,
  ) async {
    final idResult = await _api.getTyped<List<int>>(
      ApiEndpoints.friendList(type, start),
      fromJson: (json) => (json as List).cast<int>(),
    );
    if (idResult.isError) return ApiResponse(error: idResult.error);
    return _api.getTyped(
      ApiEndpoints.userInfoList(
          idResult.data!.map((id) => 'id=$id').join('&')),
      fromJson: (json) => (json as List)
          .map((e) =>
              SimpleUserInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<ApiResponse<List<dynamic>>> getContacts() =>
      _api.getTyped(ApiEndpoints.recentChatUserList(0),
          fromJson: (json) => json as List);

  Future<ApiResponse<List<dynamic>>> getChatHistory(
    int userId,
    int start,
  ) =>
      _api.getTyped(ApiEndpoints.chatHistory(userId, start),
          fromJson: (json) => json as List);

  Future<ApiResponse<List<dynamic>>> getNotifications(
    String typeName,
    int start,
  ) =>
      _api.getTyped(ApiEndpoints.systemNotice(typeName, start),
          fromJson: (json) => json as List);

  /// 按用户名精确查找用户（未找到时 id 为 0）。
  Future<ApiResponse<SimpleUserInfo?>> searchUserByName(String name) async {
    final result = await _api.getTyped<dynamic>(
      ApiEndpoints.searchUserByName(Uri.encodeComponent(name)),
      fromJson: (json) => json,
    );
    if (result.isError) return ApiResponse(error: result.error);
    final json = result.data;
    if (json == null || json is! Map<String, dynamic>) {
      return ApiResponse<SimpleUserInfo?>(data: null);
    }
    return ApiResponse(data: SimpleUserInfo.fromJson(json));
  }

  /// 未读消息计数。
  Future<ApiResponse<UnreadMessageInfo>> getUnreadCount() => _api.getTyped(
      ApiEndpoints.unreadMessage,
      fromJson: (json) =>
          UnreadMessageInfo.fromJson(json as Map<String, dynamic>));

  /// 浏览历史记录（响应为 {data: [...]}，接口限速）。
  Future<ApiResponse<List<SimpleTopicInfo>>> getBrowseHistory(int start) =>
      _api.getTyped(ApiEndpoints.browseHistory(start),
          fromJson: SimpleTopicInfo.listFromJson);

  /// 收藏夹列表。
  Future<ApiResponse<List<FavoriteGroup>>> getFavoriteGroups() =>
      _api.getTyped(ApiEndpoints.favoritesList,
          fromJson: FavoriteGroup.listFromJson);

  /// 收藏帖子列表（约定多取 1 条用于判断 hasMore，由调用方截断）。
  Future<ApiResponse<List<SimpleTopicInfo>>> getFavoriteTopics(
          int start, int order, int groupId) =>
      _api.getTyped(ApiEndpoints.favoriteTopicList(start, order, groupId),
          fromJson: SimpleTopicInfo.listFromJson);

  // ── 写操作 ──────────────────────────────────────────

  /// 每日签到。成功时响应为获得的财富值数字；
  /// 重复签到返回 400 "has_signed_in_today"。
  Future<SignInResult> signIn() async {
    try {
      final response = await _api.post(ApiEndpoints.signIn,
          data: '', options: _jsonEmpty);
      final wealth =
          response.data is num ? (response.data as num).toInt() : null;
      return SignInResult(
        status: SignInStatus.success,
        wealth: wealth,
        message: wealth != null ? '签到成功，获得财富值：$wealth' : '签到成功',
      );
    } on DioException catch (e) {
      final body = e.response?.data?.toString() ?? '';
      if (e.response?.statusCode == 400 &&
          body.contains('has_signed_in_today')) {
        // 今日已签到：视为已签到状态，但不提示
        return const SignInResult(
            status: SignInStatus.alreadySigned, message: '今日已签到');
      }
      return SignInResult(
          status: SignInStatus.failed,
          message: body.isNotEmpty ? '签到失败：$body' : '签到失败');
    } catch (_) {
      return const SignInResult(status: SignInStatus.failed, message: '签到失败');
    }
  }

  /// 发送私信。
  Future<ApiOutcome> sendPrivateMessage(int receiverId, String content) =>
      _write(() => _api.post(ApiEndpoints.sendPrivateMessage,
          data: jsonEncode({'receiverId': receiverId, 'content': content}),
          options: Options(headers: {'Content-Type': 'application/json'})));

  /// 关注（follow=true 时 PUT）或取关（DELETE）用户。
  Future<ApiOutcome> editFollowee(int userId, {required bool follow}) =>
      _write(() => follow
          ? _api.put(ApiEndpoints.editFriends(userId), data: '', options: _jsonEmpty)
          : _api.delete(ApiEndpoints.editFriends(userId)));

  /// 财富转账（赠米）。
  Future<ApiOutcome> transferWealth({
    required int wealth,
    required List<String> userNames,
    required String reason,
  }) =>
      _write(() => _api.put(ApiEndpoints.transferWealth,
          data: jsonEncode({
            'wealth': wealth,
            'userNames': userNames,
            'reason': reason,
          }),
          options: Options(headers: {'Content-Type': 'application/json'})));

  /// 开关浏览历史记录。
  Future<ApiOutcome> enableBrowseHistory(bool enabled) =>
      _write(() => _api.put(ApiEndpoints.enableBrowseHistory(enabled),
          data: '', options: _jsonEmpty));
}

/// 签到结果状态。
enum SignInStatus { success, alreadySigned, failed }

/// 签到结果：区分"本次签到成功""今日已签到""失败"。
class SignInResult {
  final SignInStatus status;

  /// 本次签到获得的财富值（alreadySigned / failed 时为 null）。
  final int? wealth;
  final String message;

  const SignInResult({
    required this.status,
    this.wealth,
    required this.message,
  });

  bool get isSuccess => status == SignInStatus.success;
  bool get isAlreadySigned => status == SignInStatus.alreadySigned;
}
