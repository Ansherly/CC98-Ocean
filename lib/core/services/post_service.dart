import 'dart:convert';

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
}
