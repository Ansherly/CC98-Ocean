import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:cc98_ocean/core/network/api_client.dart';
import 'package:cc98_ocean/core/network/api_endpoints.dart';
import 'package:cc98_ocean/core/network/result.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as dev;

/// 认证服务。
///
/// 管理登录状态、OAuth2 令牌和 SharedPreferences。
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  static SharedPreferences? _prefs;

  AuthService._internal();

  /// 初始化 SharedPreferences。应在 [main] 中调用一次。
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// 判断用户是否已登录。
  Future<bool> getLoginStatus() async {
    final accessToken = await ApiClient.instance.getAccessToken();
    final refreshToken = await ApiClient.instance.getRefreshToken();
    if (accessToken == null || refreshToken == null) return false;
    return _prefs?.getBool('isActive') ?? false;
  }

  /// 获取应用初始路由状态。
  Future<bool> isLoggedIn() async {
    final loggedIn = await getLoginStatus();
    dev.log(loggedIn ? '已登录' : '未登录', name: '登录检查');
    return loggedIn;
  }

  /// 设置登录状态标记。
  Future<bool> setLoginStatus(bool newValue) async {
    return await _prefs?.setBool('isActive', newValue) ?? false;
  }

  /// 使用用户名和密码登录。
  ///
  /// 返回 [ApiResponse]：成功时 [data] 为 true，失败时 [error] 不为 null。
  Future<ApiResponse<bool>> loginAsync(String id, String password) async {
    final result = await ApiClient.instance.postTyped<Map<String, dynamic>>(
      ApiEndpoints.tokenEndpoint,
      fromJson: (json) => json as Map<String, dynamic>,
      data: {
        'grant_type': 'password',
        'username': id,
        'password': password,
        'client_id': ApiClient.clientId,
        'client_secret': ApiClient.clientSecret,
        'scope': 'cc98-api openid offline_access',
      },
      options: Options(
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      ),
    );

    if (result.isError) {
      // 尝试解析 OAuth 错误描述
      final error = result.error!;
      if (error.statusCode == 400 && error.rawError is DioException) {
        try {
          final dioError = error.rawError as DioException;
          final errData = dioError.response?.data as Map<String, dynamic>?;
          if (errData != null) {
            final desc = errData['error_description'] as String?;
            if (desc != null) {
              return ApiResponse(
                  error: ApiError(statusCode: 400, message: desc));
            }
          }
        } catch (_) {}
      }
      return ApiResponse(error: error);
    }

    final data = result.data!;
    final accessToken = data['access_token'] as String?;
    final refreshToken = data['refresh_token'] as String?;
    if (accessToken != null && refreshToken != null) {
      await ApiClient.instance.saveAccessToken(accessToken);
      await ApiClient.instance.saveRefreshToken(refreshToken);
      dev.log('成功登录并保存凭据', name: '登录');
      return ApiResponse(data: true);
    }
    return ApiResponse(
      error: ApiError(
        statusCode: null,
        message: '登录失败: 响应中缺少令牌',
      ),
    );
  }
}
