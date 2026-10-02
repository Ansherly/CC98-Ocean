import 'dart:io';

import 'package:cc98_ocean/controls/fluent_iconbutton.dart';
import 'package:cc98_ocean/controls/info_flower.dart';
import 'package:cc98_ocean/controls/smart_image.dart';
import 'package:cc98_ocean/controls/status_title.dart';
import 'package:cc98_ocean/core/services/download_service.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';

/// 全屏图片预览：支持保存到本机（移动端存相册 / 桌面端存下载目录），
/// 安卓端可拉起系统分享面板。
class ImagePreview extends StatefulWidget {
  final String imageUrl;

  const ImagePreview({super.key, required this.imageUrl});

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  bool _isDownloading = false;

  bool get _isAndroid => !kIsWeb && Platform.isAndroid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: buildAppBar(context),
      body: buildLayout(),
    );
  }

  PreferredSizeWidget buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      toolbarHeight: 48,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      actionsPadding: const EdgeInsets.only(right: 13),
      titleSpacing: 8,
      leading: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: FluentIconbutton(
          icon: FluentIcons.chevron_left_16_regular,
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      actions: [
        // 下载并保存：移动端存相册，桌面端存"下载"目录
        FluentIconbutton(
          icon: _isDownloading
              ? FluentIcons.arrow_clockwise_16_regular
              : FluentIcons.arrow_download_16_regular,
          tooltip: _isDownloading ? '正在保存…' : '保存图片',
          onPressed: _isDownloading ? null : _downloadImage,
        ),
        // 系统分享：仅安卓（按需求）
        if (_isAndroid)
          FluentIconbutton(
            icon: FluentIcons.share_16_regular,
            tooltip: '分享',
            onPressed: _shareImage,
          ),
      ],
      title: const StatusTitle(title: '图片预览'),
    );
  }

  Widget buildLayout() {
    return Center(
      child: PhotoView(
        imageProvider: SmartNetworkImage(widget.imageUrl),
        minScale: PhotoViewComputedScale.contained * 0.2,
        maxScale: PhotoViewComputedScale.covered * 4,
        backgroundDecoration: const BoxDecoration(color: Colors.black),
        loadingBuilder: (context, event) => const Center(
          child: CircularProgressIndicator(),
        ),
        errorBuilder: (context, error, stackTrace) => Center(
          child: Text('图片已被小猫吃掉···'),
        ),
      ),
    );
  }

  Future<void> _downloadImage() async {
    setState(() => _isDownloading = true);
    final result = await DownloadService.instance
        .download(widget.imageUrl, fileName: 'cc98_image');
    if (!mounted) return;
    setState(() => _isDownloading = false);
    InfoFlower.show(
      context,
      icon: result.success
          ? FluentIcons.checkmark_circle_16_regular
          : FluentIcons.error_circle_16_regular,
      text: result.message,
    );
  }

  Future<void> _shareImage() async {
    await SharePlus.instance.share(
      ShareParams(text: widget.imageUrl, title: 'CC98 图片'),
    );
  }
}
