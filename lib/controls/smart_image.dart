import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:cc98_ocean/core/network/api_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 智能网络图片源，通过 [ApiClient] 加载远程图片。
class SmartNetworkImage extends ImageProvider<SmartNetworkImage> {
  final String url;
  final int? memCacheWidth;
  final int? memCacheHeight;

  const SmartNetworkImage(this.url, {this.memCacheWidth, this.memCacheHeight});

  Future<Uint8List> _loadBytes() async {
    final result = await ApiClient.instance.getTyped<Uint8List>(
      url,
      fromJson: (json) => json as Uint8List,
      options: Options(responseType: ResponseType.bytes),
    );
    if (result.isError) {
      throw Exception('${result.error!.statusCode}: ${result.error!.message}');
    }
    return result.data!;
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
