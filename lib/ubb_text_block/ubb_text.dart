import 'package:cc98_ocean/core/link_definition.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'parser.dart';
import 'render_context.dart';
import 'strategies.dart';
import 'ubb_text_style.dart';

/// UBB 文本渲染组件（对应 C# UbbTextBlock 控件）。
///
/// 渲染流程与 C# 参考实现一致：Tokenizer → Parser（AST + 非法标签回退）→
/// 按节点类型分发渲染策略。块级元素（引用、表格、代码等）独占一行，
/// 内联元素（加粗、颜色、链接等）在同一行内累积。
class UbbText extends StatefulWidget {
  final String data;
  final UbbTextStyle style;

  /// 链接 / 图片 / 音频等媒体点击回调（对应 C# MediaClicked 事件）。
  final void Function(String src, UbbMediaType mediaType)? onMediaTap;

  /// 兼容旧 API 的纯链接点击回调。
  final void Function(String url)? onLinkTap;

  const UbbText({
    super.key,
    required this.data,
    this.style = const UbbTextStyle(),
    this.onMediaTap,
    this.onLinkTap,
  });

  @override
  State<UbbText> createState() => _UbbTextState();
}

class _UbbTextState extends State<UbbText> {
  // 本帧渲染创建的手势识别器
  List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers = [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    if (data.isEmpty) return const SizedBox.shrink();

    // 上一帧的识别器等本帧渲染完成后再释放，避免命中仍在飞行中的手势事件
    final staleRecognizers = _recognizers;
    _recognizers = [];
    if (staleRecognizers.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        for (final recognizer in staleRecognizers) {
          recognizer.dispose();
        }
      });
    }

    final style = widget.style;
    // 与环境 DefaultTextStyle 合并：继承主题的字体家族（Hm Sans）与前景色，
    // 显式配置的字号等属性优先
    final baseStyle =
        DefaultTextStyle.of(context).style.merge(style.baseStyle);
    final config = UbbRenderConfig(
      baseStyle: baseStyle,
      boldFontFamily: style.boldFontFamily,
      codeBackground: style.codeBackground,
      quoteBackground: style.quoteBackground,
      linkColor: style.linkColor,
      imageMaxWidth: style.imageMaxWidth,
      imageMaxHeight: style.imageMaxHeight,
      hideImage: style.hideImage,
      autoLink: style.autoLink,
      brightness: Theme.of(context).brightness,
      onMediaTap: _handleMedia,
    );

    final children = <Widget>[];
    final ctx = UbbRenderContext(
      config: config,
      container: children,
      recognizers: _recognizers,
    );

    try {
      final document = UbbParser.parse(data);

      // 逐个顶层节点渲染，单个节点出错不影响其余内容
      for (final node in document.root.children) {
        try {
          ctx.renderNode(node);
        } catch (nodeException) {
          ctx.finalizeCurrentTextBlock();
          children.add(_buildErrorText('${node.type} 渲染失败:$nodeException'));
        }
      }

      // 结束最后一个文本块
      ctx.finalizeCurrentTextBlock();
    } catch (ex) {
      // 解析级错误：整篇无法渲染
      children.clear();
      children.add(_buildErrorText('渲染错误: $ex'));
    }

    if (children.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  /// 媒体点击分发：外部回调优先；未提供时走默认链接路由
  /// （站内链接跳转、@用户跳空间、图片预览、外链复制）。
  void _handleMedia(String src, UbbMediaType type) {
    if (!mounted) return;
    if (type == UbbMediaType.link && widget.onLinkTap != null) {
      widget.onLinkTap!(src);
      return;
    }
    if (widget.onMediaTap != null) {
      widget.onMediaTap!(src, type);
      return;
    }
    switch (type) {
      case UbbMediaType.link:
      case UbbMediaType.image:
        LinkNavigator.handle(context, src);
      case UbbMediaType.atUser:
        LinkNavigator.handleUserName(context, src);
      default:
        break;
    }
  }

  Widget _buildErrorText(String message) {
    return Text(
      message,
      style: const TextStyle(color: Colors.red),
    );
  }
}
