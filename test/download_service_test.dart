import 'package:cc98_ocean/core/services/download_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// DownloadService.buildFileName 纯逻辑验收。
void main() {
  test('从 URL 末段取文件名并保留扩展名', () {
    final name = DownloadService.buildFileName(
      'https://file.cc98.org/v4-upload/d/2026/0928/ttpwjmgx.webp',
      null,
    );
    expect(name.endsWith('ttpwjmgx.webp'), isTrue, reason: name);
  });

  test('无扩展名的 URL 回落 .jpg', () {
    final name = DownloadService.buildFileName(
      'https://file.cc98.org/v4-upload/d/2026/0928/image',
      null,
    );
    expect(name.endsWith('.jpg'), isTrue, reason: name);
  });

  test('URL 带查询参数时忽略参数部分', () {
    final name = DownloadService.buildFileName(
      'https://file.cc98.org/a/b/photo.png?token=abc&x=1',
      null,
    );
    expect(name.contains('?'), isFalse, reason: name);
    expect(name.endsWith('.png'), isTrue, reason: name);
  });

  test('提供文件名时自动补扩展名并清理非法字符', () {
    final name = DownloadService.buildFileName(
      'https://file.cc98.org/a/b/x.png',
      '我的 图片:1?',
    );
    expect(name.contains(':'), isFalse);
    expect(name.contains('?'), isFalse);
    expect(name.endsWith('.png'), isTrue, reason: name);
  });

  test('每次下载附时间戳避免重名', () {
    final a = DownloadService.buildFileName(
        'https://file.cc98.org/a.png', null);
    final b = DownloadService.buildFileName(
        'https://file.cc98.org/a.png', null);
    // 同一毫秒内可能相同，但两文件名均应含时间戳前缀格式
    expect(a.startsWith(RegExp(r'\d{13}_')), isTrue, reason: a);
    expect(b.startsWith(RegExp(r'\d{13}_')), isTrue, reason: b);
  });
}
