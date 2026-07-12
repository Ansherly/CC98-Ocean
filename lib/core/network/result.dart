import 'package:dio/dio.dart';


class ApiResponse<T>{
  final T? data;
  final ApiError? error;

  ApiResponse({this.data, this.error})
      : assert(data != null || error != null,
            'ApiResponse must have either data or error');

  bool get isError => error != null || data == null;

}


/// 统一的 API 错误信息。
class ApiError {
  /// HTTP 状态码（网络错误时为 null）。
  final int? statusCode;

  /// 用户可读的错误消息。
  final String message;

  /// 原始异常对象（用于调试）。
  final Object? rawError;

  const ApiError({this.statusCode, required this.message, this.rawError});

  /// 从 [DioException] 创建友好的错误信息。
  factory ApiError.fromDioException(DioException e) => ApiError(
        statusCode: e.response?.statusCode,
        message: _friendlyMessage(e),
        rawError: e,
      );

  /// 从 HTTP 状态码创建错误。
  factory ApiError.http(int statusCode, [String? body]) => ApiError(
        statusCode: statusCode,
        message: _httpStatusMessage(statusCode, body),
      );

  static String _friendlyMessage(DioException e) => switch (e.type) {
        DioExceptionType.connectionTimeout => '连接超时，请检查网络',
        DioExceptionType.receiveTimeout => '服务器响应超时',
        DioExceptionType.sendTimeout => '发送请求超时',
        DioExceptionType.connectionError => '无法连接到服务器',
        DioExceptionType.cancel => '请求已取消',
        DioExceptionType.badResponse => _httpStatusMessage(
            e.response?.statusCode ?? 0, null),
        _ => e.message ?? '网络请求失败',
      };

  static String _httpStatusMessage(int code, [String? _]) => switch (code) {
        400 => '请求参数错误',
        401 => '登录已过期，请重新登录',
        403 => '访问被拒绝',
        404 => '资源未找到',
        500 => '服务器内部错误',
        502 || 503 || 504 => '服务器暂时不可用',
        _ => '请求失败 (HTTP $code)',
      };

  @override
  String toString() => message;
}
