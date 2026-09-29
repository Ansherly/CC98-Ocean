import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:cc98_ocean/core/link_definition.dart';
import 'package:cc98_ocean/ubb_text_block/ubb_text_style.dart';

/// Markdown 内容视图：与 UBB 渲染共用同一套正文排版
/// （Hm Sans、[kPostContentFontSize] 号、主题前景色），避免"MD 字大 UBB 字小"。
class MarkdownView extends StatelessWidget {
  final String data;

  /// 是否可长按选择文本。
  final bool selectable;

  const MarkdownView(this.data, {super.key, this.selectable = true});

  /// 基础正文样式：环境样式（主题字体/颜色）+ 帖子正文基准字号。
  static TextStyle baseStyle(BuildContext context) =>
      DefaultTextStyle.of(context)
          .style
          .merge(const TextStyle(fontSize: kPostContentFontSize));

  @override
  Widget build(BuildContext context) {
    final base = baseStyle(context);
    final config = MarkdownConfig(configs: [
      PConfig(textStyle: base),
      // 链接点击：站内跳转 / 外链复制（与 UBB 渲染一致）
      LinkConfig(
        style: base.copyWith(
          color: const Color(0xFF20B2AA), // LightSeaGreen，与 UBB 链接色一致
          decoration: TextDecoration.underline,
        ),
        onTap: (url) => LinkNavigator.handle(context, url),
      ),
      H1Config(
          style: base.copyWith(
              fontSize: 22, fontWeight: FontWeight.bold)),
      H2Config(
          style: base.copyWith(
              fontSize: 19, fontWeight: FontWeight.bold)),
      H3Config(
          style: base.copyWith(
              fontSize: 17, fontWeight: FontWeight.bold)),
      H4Config(
          style: base.copyWith(
              fontSize: base.fontSize ?? 15, fontWeight: FontWeight.bold)),
    ]);
    return MarkdownBlock(data: data, selectable: selectable, config: config);
  }
}
