import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 智能网络图片源：独立的图片加载通道。
///
/// 刻意**不复用** [ApiClient]：业务 Dio 带 Authorization 头、
/// Accept: application/json 与 15s 超时，且 401 会触发 Token 刷新
/// （失败还会清会话）——这些对图床的纯图片请求都是错误语义。
/// 图片加载用专用 Dio：无鉴权头、Accept 任意、60s 超时。
class SmartNetworkImage extends ImageProvider<SmartNetworkImage> {
  final String url;
  final int? memCacheWidth;
  final int? memCacheHeight;

  const SmartNetworkImage(this.url, {this.memCacheWidth, this.memCacheHeight});

  /// 图片专用加载器（懒创建，与业务 ApiClient 完全隔离）。
  static Dio? _imageDio;

  static Dio get _dio {
    _imageDio ??= Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 60), // 大图需要更长接收时间
      responseType: ResponseType.bytes,
      headers: {'Accept': '*/*'},
    ));
    return _imageDio!;
  }

  Future<Uint8List> _loadBytes() async {
    final response = await _dio.get<List<int>>(url);
    final data = response.data;
    if (data == null || response.statusCode != 200) {
      throw Exception('图片加载失败: HTTP ${response.statusCode}');
    }
    return Uint8List.fromList(data);
  }

  @override
  ImageStreamCompleter loadImage(
      SmartNetworkImage key, ImageDecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadBytes()
          .then((bytes) async => decode(await ImmutableBuffer.fromUint8List(bytes))),
      scale: 1.0,
      informationCollector: () => [
        DiagnosticsProperty('SmartNetworkImage', url),
      ],
    );
  }

  @override
  Future<SmartNetworkImage> obtainKey(ImageConfiguration cfg) => SynchronousFuture(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SmartNetworkImage && url == other.url;

  @override
  int get hashCode => url.hashCode;
}
