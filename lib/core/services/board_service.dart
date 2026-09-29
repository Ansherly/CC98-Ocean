import 'package:cc98_ocean/core/models/board.dart';
import 'package:cc98_ocean/core/network/api_client.dart';
import 'package:cc98_ocean/core/network/api_endpoints.dart';
import 'package:cc98_ocean/core/network/result.dart';
import 'package:dio/dio.dart';

/// 版面相关的数据访问层。
class BoardService {
  final _api = ApiClient.instance;

  Future<ApiResponse<List<BoardSection>>> getAllBoards() =>
      _api.getTyped(ApiEndpoints.allBoards, fromJson: (json) =>
          (json as List).map((e) => BoardSection.fromJson(e as Map<String, dynamic>)).toList());

  Future<ApiResponse<BoardInfo>> getBoardInfo(int boardId) =>
      _api.getTyped(ApiEndpoints.boardInfo(boardId),
          fromJson: (json) => BoardInfo.fromJson(json as Map<String, dynamic>));

  Future<ApiResponse<List<StandardPost>>> getBoardTopics(
    int boardId,
    int start,
  ) =>
      _api.getTyped(ApiEndpoints.topicList(boardId, start), fromJson: (json) =>
          (json as List).map((e) => StandardPost.fromJson(e as Map<String, dynamic>)).toList());

  /// 关注（follow=true 时 PUT）/ 取消关注（DELETE）版面。
  Future<ApiOutcome> editFocusBoards(int boardId, {required bool follow}) async {
    try {
      final response = follow
          ? await _api.put(ApiEndpoints.editFocusBoards(boardId),
              data: '',
              options: Options(headers: {'Content-Type': 'application/json'}))
          : await _api.delete(ApiEndpoints.editFocusBoards(boardId));
      return ApiOutcome(success: response.statusCode == 200);
    } catch (e) {
      return ApiOutcome(success: false, message: e.toString());
    }
  }
}
