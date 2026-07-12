import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api_endpoints.dart';
import 'result.dart';

/// Dio 封装的 HTTP 客户端。
///
/// - 单例模式，全局共享一个 [Dio] 实例。
/// - 通过拦截器自动在请求头注入 `Authorization: Bearer <access_token>`。
/// - 收到 401 时自动用 refresh_token 刷新，成功后重试原始请求。
class ApiClient {
  static ApiClient? _instance;

  late final Dio _dio;
  static const FlutterSecureStorage _vault = FlutterSecureStorage();

  /// OAuth2 客户端凭证（与 openid.cc98.org 注册的公共客户端一致）
  static const String clientId = '9a1fd200-8687-44b1-4c20-08d50a96e5cd';
  static const String clientSecret =
      '8b53f727-08e2-4509-8857-e34bf92b27f2';

  bool _isRefreshing = false;

  ApiClient._() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json'},
    ));
    _dio.interceptors.add(_authInterceptor());
  }

  /// 全局单例。
  static ApiClient get instance {
    _instance ??= ApiClient._();
    return _instance!;
  }

  /// 公开 Dio 实例，方便需要直接设置 responseType 等特殊场景。
  Dio get dio => _dio;


  // ── 底层 HTTP 方法（返回原始 Response） ───────────

  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) =>
      _dio.get(url,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken);

  Future<Response> post(
    String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) =>
      _dio.post(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

  Future<Response> put(
    String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) =>
      _dio.put(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

  Future<Response> delete(
    String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) =>
      _dio.delete(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

  // ── 泛型 JSON 请求（返回 Result<T, ApiError>） ──────

  /// 获取强类型对象。需要提供 [fromJson] 将 JSON 转换为 [T]。
  Future<ApiResponse<T>> getTyped<T>(
    String url, {
    required T Function(dynamic json) fromJson,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response =
          await _dio.get(url, options: options, cancelToken: cancelToken);
      if (response.statusCode == 200) {
        return ApiResponse(data: fromJson(response.data));
      }
      return ApiResponse(error: ApiError.http(response.statusCode!));
    } on DioException catch (e) {
      return ApiResponse(error: ApiError.fromDioException(e));
    } catch (e) {
      return ApiResponse(error: ApiError(
          statusCode: null, message: '数据解析失败: ${e.runtimeType}', rawError: e));
    }
  }

  /// POST 请求，返回强类型对象。
  Future<ApiResponse<T>> postTyped<T>(
    String url, {
    required T Function(dynamic json) fromJson,
    Object? data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post(
        url,
        data: data,
        options: options,
        cancelToken: cancelToken,
      );
      if (response.statusCode == 200) {
        return ApiResponse(data: fromJson(response.data));
      }
      return ApiResponse(error: ApiError.http(response.statusCode!));
    } on DioException catch (e) {
      return ApiResponse(error: ApiError.fromDioException(e));
    } catch (e) {
      return ApiResponse(error: ApiError(
          statusCode: null, message: '数据解析失败: ${e.runtimeType}', rawError: e));
    }
  }

  /// PUT 请求，返回强类型对象。
  Future<ApiResponse<T>> putTyped<T>(
    String url, {
    required T Function(dynamic json) fromJson,
    Object? data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.put(
        url,
        data: data,
        options: options,
        cancelToken: cancelToken,
      );
      if (response.statusCode == 200) {
        return ApiResponse(data: fromJson(response.data));
      }
      return ApiResponse(error: ApiError.http(response.statusCode!));
    } on DioException catch (e) {
      return ApiResponse(error: ApiError.fromDioException(e));
    } catch (e) {
      return ApiResponse(error: ApiError(
          statusCode: null, message: '数据解析失败: ${e.runtimeType}', rawError: e));
    }
  }

  // ── Token 管理 ──────────────────────────────────────

  /// 从安全存储读取 access token。
  Future<String?> getAccessToken() async => _vault.read(key: 'access');

  /// 从安全存储读取 refresh token。
  Future<String?> getRefreshToken() async => _vault.read(key: 'refresh');

  /// 保存 access token。
  Future<void> saveAccessToken(String token) async =>
      _vault.write(key: 'access', value: token);

  /// 保存 refresh token。
  Future<void> saveRefreshToken(String token) async =>
      _vault.write(key: 'refresh', value: token);

  /// 清除所有 token（退出登录时调用）。
  Future<void> clearTokens() async {
    await _vault.delete(key: 'access');
    await _vault.delete(key: 'refresh');
  }

  /// 使用 refresh token 换新的 access token。
  ///
  /// 返回新的 access token；失败时返回 null。
  Future<String?> refreshAccessToken() async {
    final refreshToken = await _vault.read(key: 'refresh');
    if (refreshToken == null) return null;

    try {
      final response = await Dio().post(
        ApiEndpoints.tokenEndpoint,
        data: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
          'client_id': clientId,
          'client_secret': clientSecret,
        },
      );

      if (response.statusCode == 200) {
        final json = response.data as Map<String, dynamic>;
        final newAccessToken = json['access_token'] as String?;
        if (newAccessToken != null) {
          await saveAccessToken(newAccessToken);
          // 如果服务器返回新的 refresh token，也保存
          final newRefreshToken = json['refresh_token'] as String?;
          if (newRefreshToken != null) {
            await saveRefreshToken(newRefreshToken);
          }
          return newAccessToken;
        }
      }
    } catch (_) {
      // 刷新失败，清除 token
      await clearTokens();
    }
    return null;
  }

  // ── 拦截器 ──────────────────────────────────────────

  Interceptor _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _vault.read(key: 'access');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401 && !_isRefreshing) {
          _isRefreshing = true;
          try {
            final newToken = await refreshAccessToken();
            if (newToken != null) {
              // 用新 token 重试原始请求
              error.requestOptions.headers['Authorization'] =
                  'Bearer $newToken';
              final response = await _dio.fetch(error.requestOptions);
              _isRefreshing = false;
              return handler.resolve(response);
            }
          } catch (_) {}
          _isRefreshing = false;
        }
        handler.next(error);
      },
    );
  }
}
