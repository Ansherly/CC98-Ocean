import 'package:flutter/material.dart';

import 'strategy.dart';
import 'ubb_text_style.dart';

/// UBB 文本渲染组件。在 [Column] 中渲染 BBCode 文本，支持块级和内联布局。
///
/// 匹配 C# UbbTextBlock 的渲染行为：
/// - 块级元素（引用、表格、代码等）独占一行
/// - 内联元素（加粗、颜色等）在同一行内累积
/// - 块级元素出现时自动刷出当前行内内容
class UbbText extends StatelessWidget {
  final String data;
  final UbbTextStyle style;
  final void Function(String url)? onLinkTap;

  const UbbText({
    super.key,
    required this.data,
    this.style = const UbbTextStyle(),
    this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();
    final renderer = UbbRenderer(style: style, onLinkTap: onLinkTap);
    final widgets = renderer.render(data);
    if (widgets.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widgets,
    );
  }
}
