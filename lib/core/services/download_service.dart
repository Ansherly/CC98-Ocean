import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';

/// 下载结果。
class DownloadResult {
  final bool success;
  final String message;

  /// 桌面端保存的文件完整路径（移动端存相册时为 null）。
  final String? path;

  const DownloadResult({required this.success, required this.message, this.path});
}

/// 可复用的文件下载服务。
///
/// - **移动端（Android / iOS）**:下载后经 [Gal] 存入系统相册；
/// - **桌面端（Windows / Linux / macOS）**:写入系统"下载"目录
///   （不可用时回落到应用文档目录）；
/// - 图片字节走独立 Dio（无鉴权头，Accept 任意，120s 超时），
///   与业务 [ApiClient] 隔离——理由见 SmartNetworkImage 的注释。
class DownloadService {
  DownloadService._();

  static final DownloadService instance = DownloadService._();

  late final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 120),
    responseType: ResponseType.bytes,
    headers: {'Accept': '*/*'},
  ));

  /// 下载 [url] 并保存。
  ///
  /// [fileName] 提供期望的文件名（自动清理非法字符、补扩展名）；
  /// [onProgress] 回调 (已接收字节, 总字节)，总长未知时 total 为 -1。
  Future<DownloadResult> download(
    String url, {
    String? fileName,
    void Function(int received, int? total)? onProgress,
  }) async {
    try {
      final response = await _dio.get<List<int>>(
        url,
        onReceiveProgress: onProgress != null
            ? (received, total) => onProgress(received, total > 0 ? total : null)
            : null,
      );
      final data = response.data;
      if (response.statusCode != 200 || data == null || data.isEmpty) {
        return DownloadResult(
            success: false, message: '下载失败：HTTP ${response.statusCode}');
      }

      final name = buildFileName(url, fileName);
      final bytes = Uint8List.fromList(data);

      // 移动端存入系统相册
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        await Gal.putImageBytes(bytes, name: name);
        return const DownloadResult(success: true, message: '已保存到相册');
      }

      // 桌面端写入"下载"目录（不可用时回落到应用文档目录）
      final dir = await getDownloadDirectory();
      final file = File('${dir.path}${Platform.pathSeparator}$name');
      await file.writeAsBytes(bytes);
      return DownloadResult(
          success: true, message: '已保存：${file.path}', path: file.path);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      return DownloadResult(
          success: false, message: '下载失败：HTTP ${status ?? "网络错误"}');
    } catch (e) {
      return DownloadResult(success: false, message: '下载失败：${e.toString()}');
    }
  }

  /// 目标目录：桌面端优先系统"下载"目录，不可用时回落到应用文档目录。
  Future<Directory> getDownloadDirectory() async {
    final downloads = await getDownloadsDirectory();
    if (downloads != null) return downloads;
    final docs = await getApplicationDocumentsDirectory();
    // 确保目录存在（部分平台首次访问可能不存在）
    if (!docs.existsSync()) await docs.create(recursive: true);
    return docs;
  }

  /// 从 URL 与期望名构造安全文件名。
  ///
  /// - 优先使用 [provided]（自动补扩展名）；
  /// - 否则取 URL 路径的末段；无扩展名时回落 `.jpg`；
  /// - 清理各平台非法字符，时间戳防重名。
  static String buildFileName(String url, String? provided) {
    final ext = _extensionOf(url);
    if (provided != null && provided.trim().isNotEmpty) {
      final base = provided.trim().replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      return base.contains('.') ? base : '$base$ext';
    }
    var segment = Uri.tryParse(url)?.pathSegments.isNotEmpty == true
        ? Uri.parse(url).pathSegments.last
        : '';
    segment = segment.isEmpty ? 'cc98_download' : segment;
    final cleaned =
        segment.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    final hasExt = cleaned.contains('.');
    final stamp = DateTime.now().millisecondsSinceEpoch;
    return hasExt
        ? '${stamp}_$cleaned'
        : '${stamp}_$cleaned$ext';
  }

  static String _extensionOf(String url) {
    final path = Uri.tryParse(url)?.path ?? '';
    final dot = path.lastIndexOf('.');
    if (dot == -1 || dot == path.length - 1) return '.jpg';
    final ext = path.substring(dot).toLowerCase();
    return RegExp(r'^\.[a-z0-9]{2,5}$').hasMatch(ext) ? ext : '.jpg';
  }
}
