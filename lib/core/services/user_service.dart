import 'package:cc98_ocean/core/models/board.dart';
import 'package:cc98_ocean/core/models/user.dart';
import 'package:cc98_ocean/core/network/api_client.dart';
import 'package:cc98_ocean/core/network/api_endpoints.dart';
import 'package:cc98_ocean/core/network/result.dart';

/// 用户与消息相关的数据访问层。
class UserService {
  final _api = ApiClient.instance;

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
}
