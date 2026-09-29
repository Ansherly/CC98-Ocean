import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api_endpoints.dart';
import 'result.dart';

/// Dio 封装的 HTTP 客户端。
///
/// Token 生命周期对齐 C# TokenHandler/TokenService 模式：
/// - 内存缓存 + 安全存储持久化，过期时间取 `expires_in - 60s` 提前量；
/// - 拦截器直接注入内存 token，不再每次读存储；
/// - 401 时互斥刷新（并发请求共享同一个 in-flight Future，双检避免重复刷新）
///   并重试一次；
/// - 仅 refresh_token 真正失效才清除会话，网络错误保留 token 下次重试；
/// - 请求前发现 token 已过期则后台预热刷新。
class ApiClient {
  static ApiClient? _instance;

  late final Dio _dio;
  static const FlutterSecureStorage _vault = FlutterSecureStorage();

  /// OAuth2 客户端凭证（与 openid.cc98.org 注册的公共客户端一致）
  static const String clientId = '9a1fd200-8687-44b1-4c20-08d50a96e5cd';
  static const String clientSecret =
      '8b53f727-08e2-4509-8857-e34bf92b27f2';

  /// 令牌端点路径片段：登录/刷新请求自身不附加 Authorization，
  /// 也不触发 401 刷新重试。
  static const String _tokenPathFragment = '/connect/token';

  // ── Token 内存状态 ──────────────────────────────────

  String? _accessToken;
  String? _refreshToken;

  /// access token 过期时刻（UTC，已含 60s 提前量）。
  DateTime? _expiresAt;

  /// 进行中的刷新任务：并发 401 共享同一个 Future。
  Future<String?>? _refreshing;

  bool get hasSession => _accessToken != null && _refreshToken != null;

  bool get _isExpired {
    final access = _accessToken;
    if (access == null) return true;
    final expiresAt = _expiresAt;
    return expiresAt == null || DateTime.now().toUtc().isAfter(expiresAt);
  }

  /// 启动时从安全存储恢复内存缓存（在 AuthService.init 中调用）。
  Future<void> restoreSession() async {
    _accessToken = await _vault.read(key: 'access');
    _refreshToken = await _vault.read(key: 'refresh');
    final expiresAt = await _vault.read(key: 'expiresAt');
    _expiresAt =
        expiresAt == null ? null : DateTime.tryParse(expiresAt)?.toUtc();
  }

  /// 写入会话（登录成功或刷新成功）。过期时间提前 60 秒。
  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    int? expiresIn,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    final lifetime = (expiresIn ?? 3600) - 60;
    _expiresAt = DateTime.now().toUtc()
        .add(Duration(seconds: lifetime > 0 ? lifetime : 0));
    await _vault.write(key: 'access', value: accessToken);
    await _vault.write(key: 'refresh', value: refreshToken);
    await _vault.write(key: 'expiresAt', value: _expiresAt!.toIso8601String());
  }

  /// 清除会话（登出或 refresh_token 失效）。
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    _expiresAt = null;
    _refreshing = null;
    await _vault.delete(key: 'access');
    await _vault.delete(key: 'refresh');
    await _vault.delete(key: 'expiresAt');
  }

  // 兼容旧接口：登录状态检查用（内存优先，回落存储）。
  Future<String?> getAccessToken() async =>
      _accessToken ??= await _vault.read(key: 'access');

  Future<String?> getRefreshToken() async =>
      _refreshToken ??= await _vault.read(key: 'refresh');

  // ── 刷新（互斥 + 双检 + 失败分类） ───────────────────

  /// 确保返回未过期的 access token；必要时刷新。
  ///
  /// 并发 401 共享同一个刷新 Future：后来者直接等待既有任务，
  /// 避免 refresh_token 轮换竞态下的重复刷新；刷新完成后
  /// [_refreshing] 复位，后续调用经 [_isExpired] 双检即得新 token。
  Future<String?> ensureFreshToken() {
    if (!_isExpired) return Future<String?>.value(_accessToken);
    if (!hasSession) return Future<String?>.value(null);
    final inFlight = _refreshing;
    if (inFlight != null) return inFlight;
    final task = _refreshNow();
    _refreshing = task;
    return task.whenComplete(() => _refreshing = null);
  }

  Future<String?> _refreshNow() async {
    final refreshToken = _refreshToken;
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
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );
      final data = response.data;
      final access =
          data is Map<String, dynamic> ? data['access_token'] as String? : null;
      if (access == null) return null;
      await saveSession(
        accessToken: access,
        refreshToken: data['refresh_token'] as String? ?? refreshToken,
        expiresIn: (data['expires_in'] as num?)?.toInt(),
      );
      return access;
    } on DioException catch (e) {
      // 仅 refresh_token 真正失效才清除会话；网络错误保留，下次请求重试
      final status = e.response?.statusCode;
      if (status == 400 || status == 401) {
        await clearTokens();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ── 拦截器（对齐 C# TokenHandler） ──────────────────

  bool _isTokenRequest(RequestOptions options) =>
      options.uri.path.contains(_tokenPathFragment);

  Interceptor _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        if (!_isTokenRequest(options)) {
          // 主动预热：token 已过期则后台刷新；当前请求仍按旧 token 发出，
          // 若 401 将在 onError 中刷新并重试
          if (hasSession && _isExpired && _refreshing == null) {
            ensureFreshToken();
          }
          final token = _accessToken;
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final request = error.requestOptions;
        final alreadyRetried = request.extra['__tokenRetried'] == true;
        if (error.response?.statusCode == 401 &&
            !_isTokenRequest(request) &&
            !alreadyRetried) {
          final token = await ensureFreshToken();
          if (token != null) {
            try {
              request.headers['Authorization'] = 'Bearer $token';
              request.extra['__tokenRetried'] = true;
              final response = await _dio.fetch(request);
              return handler.resolve(response);
            } on DioException catch (retryError) {
              return handler.next(retryError);
            }
          }
        }
        handler.next(error);
      },
    );
  }

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
}
