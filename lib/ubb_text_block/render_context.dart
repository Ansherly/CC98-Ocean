import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// 媒体点击类型（对应 C# MediaType）。
enum UbbMediaType { link, image, audio, file, atUser }

/// 渲染配置：由 [UbbText] 的属性填充（对应 C# RenderPropertyKeys 属性袋）。
class UbbRenderConfig {
  /// 段落基础样式（字号 / 前景色 / 字体）。
  final TextStyle baseStyle;

  /// 粗体字体（为空时仅加粗，继承基础字体）。
  final String? boldFontFamily;

  /// 代码块背景色（为空时由前景色推导半透明色）。
  final Color? codeBackground;

  /// 引用背景色（为空时由前景色推导半透明色）。
  final Color? quoteBackground;

  /// 链接颜色，默认 CC98 传统色 LightSeaGreen。
  final Color linkColor;

  /// 当前主题明暗（代码高亮配色需要区分）。
  final Brightness brightness;

  final double imageMaxWidth;
  final double imageMaxHeight;

  /// 是否隐藏图片（UBB 隐藏图片语法）。
  final bool hideImage;

  /// 是否把正文里的裸 URL 自动渲染成可点击链接。
  final bool autoLink;

  /// 媒体点击回调（链接 / 图片 / 音频 / 文件 / @用户）。
  final void Function(String src, UbbMediaType type)? onMediaTap;

  const UbbRenderConfig({
    this.baseStyle = const TextStyle(fontSize: 14),
    this.boldFontFamily,
    this.codeBackground,
    this.quoteBackground,
    this.linkColor = const Color(0xFF20B2AA), // LightSeaGreen
    this.brightness = Brightness.light,
    this.imageMaxWidth = double.infinity,
    this.imageMaxHeight = double.infinity,
    this.hideImage = false,
    this.autoLink = true,
    this.onMediaTap,
  });

  /// 由前景色推导主题自适应的半透明色（对应 UbbBrushHelper）。
  static Color resolveColor(Color? color,
      [Color fallback = const Color(0xFF888888)]) {
    return color ?? fallback;
  }

  static int _channel(double component) => (component * 255.0).round() & 0xff;

  static Color subtle(Color? foreground, [int alpha = 0x33]) {
    final c = resolveColor(foreground);
    return Color.fromARGB(alpha, _channel(c.r), _channel(c.g), _channel(c.b));
  }

  static Color fill(Color? foreground, [int alpha = 0x14]) {
    final c = resolveColor(foreground);
    return Color.fromARGB(alpha, _channel(c.r), _channel(c.g), _channel(c.b));
  }
}

/// 内联渲染上下文（对应 C# RenderContext）。
///
/// 管理当前正在构建的文本段落与内联容器栈：
/// - 内联内容累积为 [TextSpan] 树，块级元素出现时刷出为 [RichText]；
/// - 嵌套块级容器（引用 / 对齐 / 表格单元格）通过 [pushContainer] /
///   [createChildContext] 获得独立的块级 / 段落状态。
class UbbRenderContext {
  final UbbRenderConfig config;

  /// 当前块级容器的子 Widget 列表。
  List<Widget> container;

  /// 本上下文中创建的手势识别器，由宿主 Widget 负责释放。
  final List<TapGestureRecognizer> recognizers;

  /// 当前段落累积的内联元素。
  List<InlineSpan> _paragraphSpans = [];

  /// 正在构建的内联容器（如 Bold / Hyperlink 对应的 TextSpan）。
  TextSpan? _currentInline;

  /// 未完成的内联容器栈。
  final List<TextSpan> _inlineStack = [];

  /// 当前生效的手势识别器栈（链接容器内创建的叶子 span 需要携带识别器，
  /// 因为 Flutter 的命中测试只解析到叶子 TextSpan）。
  final List<GestureRecognizer?> _recognizerStack = [];

  /// 嵌套块级容器时暂存的父容器。
  final List<List<Widget>> _containerStack = [];

  UbbRenderContext({
    required this.config,
    required this.container,
    List<TapGestureRecognizer>? recognizers,
  }) : recognizers = recognizers ?? [];

  /// 为"独立渲染"的块创建子上下文（表格单元格、单条引用等）：
  /// 共享配置与手势识别器列表，但拥有独立的容器 / 段落 / 内联状态。
  UbbRenderContext createChildContext(List<Widget> container) {
    return UbbRenderContext(
      config: config,
      container: container,
      recognizers: recognizers,
    );
  }

  // ── 内联操作 ──────────────────────────────────────

  /// 当前生效的手势识别器（链接容器内部最深的非空识别器）。
  GestureRecognizer? get _currentRecognizer {
    for (var i = _recognizerStack.length - 1; i >= 0; i--) {
      final r = _recognizerStack[i];
      if (r != null) return r;
    }
    return null;
  }

  /// 向当前文本段落或内联容器添加内联元素。
  void addInline(InlineSpan inline) {
    // 链接容器内新建的叶子文本 span 需要携带识别器
    if (inline is TextSpan && inline.recognizer == null) {
      final recognizer = _currentRecognizer;
      if (recognizer != null) {
        inline = TextSpan(
          text: inline.text,
          style: inline.style,
          recognizer: recognizer,
          children: inline.children,
        );
      }
    }
    if (_currentInline != null) {
      _currentInline!.children!.add(inline);
    } else {
      _paragraphSpans.add(inline);
    }
  }

  void addText(String text) {
    if (text.isEmpty) return;
    addInline(TextSpan(text: text));
  }

  /// 开始构建新的内联容器（如 Bold、Italic、超链接等对应的 TextSpan）。
  /// [recognizer] 用于链接类容器，会附加到容器内的叶子文本 span 上。
  void beginInlineContainer(TextStyle style, [GestureRecognizer? recognizer]) {
    _recognizerStack.add(recognizer);
    final span = TextSpan(style: style, children: []);
    if (_currentInline != null) _inlineStack.add(_currentInline!);
    _currentInline = span;
  }

  /// 结束当前内联容器的构建。
  void endInlineContainer() {
    if (_recognizerStack.isNotEmpty) _recognizerStack.removeLast();
    final completed = _currentInline;
    if (completed == null) return;

    if (_inlineStack.isNotEmpty) {
      // 从栈中取出父容器，把刚完成的容器挂进去
      final parent = _inlineStack.removeLast();
      parent.children!.add(completed);
      _currentInline = parent;
      return;
    }

    // 没有父容器，落到当前段落
    _paragraphSpans.add(completed);
    _currentInline = null;
  }

  /// 创建可点击链接用的手势识别器（自动登记以便释放）。
  TapGestureRecognizer createRecognizer(VoidCallback onTap) {
    final recognizer = TapGestureRecognizer();
    recognizer.onTap = onTap;
    recognizers.add(recognizer);
    return recognizer;
  }

  // ── 块级操作 ──────────────────────────────────────

  /// 添加块级元素：先结束所有内联容器与当前文本块。
  void addToContainer(Widget element) {
    while (_currentInline != null) {
      endInlineContainer();
    }
    finalizeCurrentTextBlock();
    container.add(element);
  }

  /// 切入一个嵌套块级容器（引用 / 对齐等），与 [popContainer] 成对使用。
  void pushContainer(List<Widget> newContainer) {
    _containerStack.add(container);
    container = newContainer;
  }

  /// 恢复到 [pushContainer] 之前的容器。
  void popContainer() {
    if (_containerStack.isEmpty) return;
    container = _containerStack.removeLast();
  }

  /// 结束当前文本块的构建：内联内容刷出为一个 [RichText]。
  void finalizeCurrentTextBlock() {
    while (_currentInline != null) {
      endInlineContainer();
    }
    if (_paragraphSpans.isNotEmpty) {
      container.add(RichText(
        softWrap: true,
        text: TextSpan(
          style: config.baseStyle,
          children: List.of(_paragraphSpans),
        ),
      ));
      _paragraphSpans = [];
    }

    _inlineStack.clear();
    _recognizerStack.clear();
    _currentInline = null;
  }
}
