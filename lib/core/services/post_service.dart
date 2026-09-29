import 'dart:convert';

import 'package:cc98_ocean/core/models/extras.dart';
import 'package:cc98_ocean/core/network/result.dart';
import 'package:dio/dio.dart';
import 'package:cc98_ocean/core/models/post.dart';
import 'package:cc98_ocean/core/models/reply.dart';
import 'package:cc98_ocean/core/network/api_client.dart';
import 'package:cc98_ocean/core/network/api_endpoints.dart';
import 'package:cc98_ocean/core/services/user_service.dart';

/// 帖子相关的数据访问层。
class PostService {
  final _api = ApiClient.instance;
  final _users = UserService();

  Future<ApiResponse<Map<String, dynamic>>> getHotIndex() =>
      _api.getTyped(ApiEndpoints.index,
          fromJson: (json) => json as Map<String, dynamic>);

  Future<ApiResponse<List<FeedPost>>> getNewTopics(int start) async {
    final raw = await _api.getTyped<List<FeedPost>>(
      ApiEndpoints.newTopicList(start),
      fromJson: (json) => (json as List)
          .map((e) => FeedPost.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    if (!raw.isError && raw.data!.isNotEmpty) {
      await _users.enrichPortraits(
          raw.data!, (p) => p.userId, (p, url) => p.portraitUrl = url);
    }
    return raw;
  }

  Future<ApiResponse<List<FeedPost>>> getMoments(int start) async {
    final raw = await _api.getTyped<List<FeedPost>>(
      ApiEndpoints.moment(start),
      fromJson: (json) => (json as List)
          .map((e) => FeedPost.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    if (!raw.isError && raw.data!.isNotEmpty) {
      await _users.enrichPortraits(
          raw.data!, (p) => p.userId, (p, url) => p.portraitUrl = url);
    }
    return raw;
  }

  Future<ApiResponse<List<FeedPost>>> getFavoriteUpdates(int start) async {
    final raw = await _api.getTyped<List<FeedPost>>(
      ApiEndpoints.favoriteTopicUpdate(start),
      fromJson: (json) => (json as List)
          .map((e) => FeedPost.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    if (!raw.isError && raw.data!.isNotEmpty) {
      await _users.enrichPortraits(
          raw.data!, (p) => p.userId, (p, url) => p.portraitUrl = url);
    }
    return raw;
  }

  Future<ApiResponse<Map<String, dynamic>>> getTopicInfo(int topicId) =>
      _api.getTyped(ApiEndpoints.topicInfo(topicId),
          fromJson: (json) => json as Map<String, dynamic>);

  Future<ApiResponse<List<Reply>>> getReplyList(
    int topicId,
    int start,
  ) async {
    final raw = await _api.getTyped<List<Reply>>(
      ApiEndpoints.replyList(topicId, start),
      fromJson: (json) => (json as List)
          .map((e) => Reply.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    if (!raw.isError && raw.data!.isNotEmpty) {
      await _users.enrichPortraits(
          raw.data!, (r) => r.userId, (r, url) => r.portraitUrl = url);
    }
    return raw;
  }

  Future<ApiResponse<Map<String, dynamic>>> react(
    int postId,
    bool like, {
    required String Function(bool like) bodyBuilder,
  }) async {
    await _api.put(
      ApiEndpoints.react(postId),
      data: utf8.encode(bodyBuilder(like)),
      options:
          Options(headers: {'Content-Type': 'application/json;charset=utf-8'}),
    );
    return _api.getTyped(ApiEndpoints.react(postId),
        fromJson: (json) => json as Map<String, dynamic>);
  }

  Future<ApiResponse<Map<String, dynamic>>> sendReply(
    int topicId,
    Map<String, dynamic> body,
  ) =>
      _api.postTyped(
        ApiEndpoints.sendReply(topicId),
        fromJson: (json) => json as Map<String, dynamic>,
        data: jsonEncode(body),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

  // ── 收藏 ────────────────────────────────────────────

  /// 主题是否已收藏（响应为裸 bool）。
  Future<bool> isFavorite(int topicId) async {
    try {
      final response = await _api.get(ApiEndpoints.isFavorite(topicId));
      return response.data == true;
    } catch (_) {
      return false;
    }
  }

  /// 收藏主题到指定收藏夹。
  Future<ApiOutcome> addIntoFavorites(int topicId, int groupId) async {
    try {
      final response = await _api.put(
        ApiEndpoints.addIntoFavorites(topicId, groupId),
        data: '',
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      return ApiOutcome(success: response.statusCode == 200);
    } catch (e) {
      return ApiOutcome(success: false, message: e.toString());
    }
  }

  /// 取消收藏。
  Future<ApiOutcome> deleteFavorite(int topicId) async {
    try {
      final response = await _api.delete(ApiEndpoints.deleteFavoriteTopic(topicId));
      return ApiOutcome(success: response.statusCode == 200);
    } catch (e) {
      return ApiOutcome(success: false, message: e.toString());
    }
  }

  // ── 投票 ────────────────────────────────────────────

  Future<ApiResponse<VoteInfo>> getVoteInfo(int topicId) => _api.getTyped(
      ApiEndpoints.vote(topicId),
      fromJson: (json) => VoteInfo.fromJson(json as Map<String, dynamic>));

  /// 投票。响应为字符串，"1" 视为成功。
  Future<ApiOutcome> sendVote(int topicId, List<int> items) async {
    try {
      final response = await _api.post(
        ApiEndpoints.vote(topicId),
        data: jsonEncode({'items': items}),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      final ok = response.statusCode == 200 &&
          response.data.toString().trim() == '1';
      return ApiOutcome(success: ok);
    } catch (e) {
      return ApiOutcome(success: false, message: e.toString());
    }
  }

  // ── 风评（评分） ────────────────────────────────────

  /// 风评理由列表。type: 1=加风评，2=扣风评。
  Future<ApiResponse<List<RatingReason>>> getRatingReasons(int type) =>
      _api.getTyped(ApiEndpoints.rateReason(type),
          fromJson: RatingReason.listFromJson);

  /// 给帖子评分（风评）。
  Future<ApiOutcome> rate(int postId,
      {required int reasonId, required int type}) async {
    try {
      final response = await _api.put(
        ApiEndpoints.rate(postId),
        data: jsonEncode({'reasonId': reasonId, 'type': type}),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      return ApiOutcome(success: response.statusCode == 200);
    } catch (e) {
      return ApiOutcome(success: false, message: e.toString());
    }
  }

  // ── 搜索 ────────────────────────────────────────────

  /// 全站搜索主题。
  Future<ApiResponse<List<Map<String, dynamic>>>> searchTopics(
          String keyword, int start) =>
      _api.getTyped(
          ApiEndpoints.searchTopic(Uri.encodeComponent(keyword), start),
          fromJson: (json) => (json as List)
              .map((e) => (e as Map<String, dynamic>)
                  .cast<String, dynamic>())
              .toList());

  /// 版面内搜索主题。
  Future<ApiResponse<List<Map<String, dynamic>>>> searchTopicsInBoard(
          int boardId, String keyword, int start) =>
      _api.getTyped(
          ApiEndpoints.searchTopicInBoard(
              boardId, Uri.encodeComponent(keyword), start),
          fromJson: (json) => (json as List)
              .map((e) => (e as Map<String, dynamic>)
                  .cast<String, dynamic>())
              .toList());

  /// 批量获取主题标题。
  Future<ApiResponse<List<BasicTopicInfo>>> getBasicTopicInfos(
          List<int> topicIds) =>
      _api.getTyped(
          ApiEndpoints.basicTopicInfoList(
              topicIds.map((id) => 'id=$id').join('&')),
          fromJson: (json) => (json as List)
              .whereType<Map<String, dynamic>>()
              .map(BasicTopicInfo.fromJson)
              .toList());

  // ── 发帖 ────────────────────────────────────────────

  /// 发布新主题。成功时响应为新建主题的 TopicId。
  Future<ApiOutcome> sendNewTopic(int boardId, Map<String, dynamic> body,
      {int? Function()? onTopicId}) async {
    try {
      final response = await _api.post(
        ApiEndpoints.sendNewTopic(boardId),
        data: jsonEncode(body),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      return ApiOutcome(success: response.statusCode == 200);
    } catch (e) {
      return ApiOutcome(success: false, message: e.toString());
    }
  }
}
