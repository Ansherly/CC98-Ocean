import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:bbob_dart/bbob_dart.dart' as bbob;

import 'package:cc98_ocean/controls/audio_player.dart';
import 'package:cc98_ocean/controls/video_player.dart';

import 'ubb_text_style.dart';
import 'preprocessor.dart';

// ── 内联渲染上下文 ─────────────────────────────────

/// 内联渲染上下文。管理当前正在累积的 [InlineSpan] 列表和样式栈。
class InlineContext {
  final List<InlineSpan> spans = [];
  final List<TextStyle> _styleStack = [];
  void Function(String url)? onLinkTap;

  InlineContext(TextStyle baseStyle, {this.onLinkTap}) {
    _styleStack.add(baseStyle);
  }

  TextStyle get currentStyle => _styleStack.last;

  void pushStyle(TextStyle style) {
    _styleStack.add(_mergeStyle(currentStyle, style));
  }

  void popStyle() {
    if (_styleStack.length > 1) _styleStack.removeLast();
  }

  void addSpan(InlineSpan span) {
    spans.add(span);
  }

  void addText(String text) {
    if (text.isNotEmpty) {
      spans.add(TextSpan(text: text, style: currentStyle));
    }
  }

  static TextStyle _mergeStyle(TextStyle base, TextStyle override) {
    return base.merge(override);
  }
}

// ── 节点类型 ───────────────────────────────────────

/// 渲染用节点类型（从 bbob_dart AST 转换而来）。
class UbbNode {
  final String tag;
  final Map<String, String> attributes;
  final List<UbbNode> children;
  final bool isText;
  final String text;

  UbbNode({
    required this.tag,
    this.attributes = const {},
    this.children = const [],
    this.isText = false,
    this.text = '',
  });

  UbbNode.text(this.text)
      : tag = '',
        attributes = const {},
        children = const [],
        isText = true;

  String getAttribute(String key, [String fallback = '']) =>
      attributes[key] ?? fallback;
}

// ── 策略基类 ───────────────────────────────────────

/// BBCode 标签的渲染策略。
abstract class UbbStrategy {
  /// 是否为块级元素（需要独占一行的元素）。
  bool get isBlock => false;

  /// 以内联方式渲染。
  void buildInline(UbbNode node, InlineContext ctx, UbbTextStyle style) {}

  /// 以块级方式渲染，返回 Widget。
  Widget? buildWidget(UbbNode node, UbbTextStyle style,
      {void Function(String url)? onLinkTap}) =>
      null;
}

// ── 策略注册表 ─────────────────────────────────────

/// 全局策略注册表，标签名不区分大小写。
class UbbStrategyRegistry {
  static final UbbStrategyRegistry _instance = UbbStrategyRegistry._();
  factory UbbStrategyRegistry() => _instance;
  static UbbStrategyRegistry get instance => _instance;

  final Map<String, UbbStrategy> _strategies = {};

  UbbStrategyRegistry._() {
    _registerAll();
  }

  void register(String tag, UbbStrategy strategy) {
    _strategies[tag.toLowerCase()] = strategy;
  }

  UbbStrategy? get(String tag) => _strategies[tag.toLowerCase()];

  Set<String> get tagNames => _strategies.keys.toSet();

  void _registerAll() {
    // 内联策略
    register('b', _InlineStrategy(TextStyle(fontWeight: FontWeight.bold)));
    register('i', _InlineStrategy(TextStyle(fontStyle: FontStyle.italic)));
    register('u', _InlineStrategy(TextStyle(decoration: TextDecoration.underline)));
    register('del', _InlineStrategy(TextStyle(decoration: TextDecoration.lineThrough)));
    register('s', _InlineStrategy(TextStyle(decoration: TextDecoration.lineThrough)));
    register('color', _ColorStrategy());
    register('size', _SizeStrategy());
    register('font', _FontStrategy());
    register('url', _UrlStrategy());
    register('topic', _TopicStrategy());
    register('left', _AlignStrategy(TextAlign.left));
    register('center', _AlignStrategy(TextAlign.center));
    register('right', _AlignStrategy(TextAlign.right));

    // 块级策略
    register('img', _ImgStrategy());
    register('audio', _AudioStrategy());
    register('video', _VideoStrategy());
    register('code', _CodeStrategy());
    register('quote', _QuoteStrategy());
    register('quotex', _QuoteStrategy());
    register('align', _AlignBlockStrategy());
    register('hr', _HrStrategy());
    register('line', _HrStrategy());
    register('table', _TableStrategy());
    register('tr', _TableRowStrategy());
    register('td', _TableCellStrategy());
    register('list', _ListStrategy());
    register('ol', _ListStrategy());
    register('ul', _UnorderedListStrategy());
    register('*', _ListItemStrategy());
    register('spoiler', _SpoilerStrategy());
    register('replyview', _ReplyViewStrategy());
    register('needreply', _ReplyViewStrategy());
    register('posteronly', _PosterOnlyStrategy());
    register('at', _AtStrategy());
    register('math', _LatexStrategy());
    register('upload', _FileStrategy());
    register('bili', _BilibiliStrategy());
    register('noubb', _NoUbbStrategy());
    register('md', _MarkdownStrategy());
    register('h1', _HeaderStrategy(1));
    register('h2', _HeaderStrategy(2));
    register('h3', _HeaderStrategy(3));
    register('h4', _HeaderStrategy(4));
  }
}

// ── 内联策略实现 ───────────────────────────────────

class _InlineStrategy extends UbbStrategy {
  final TextStyle _style;
  _InlineStrategy(this._style);

  @override
  void buildInline(UbbNode node, InlineContext ctx, UbbTextStyle style) {
    ctx.pushStyle(_style);
    for (final child in node.children) {
      _renderChild(child, ctx, style);
    }
    ctx.popStyle();
  }

  static void _renderChild(UbbNode node, InlineContext ctx, UbbTextStyle style) {
    if (node.isText) {
      ctx.addText(node.text);
      return;
    }
    final strategy = UbbStrategyRegistry.instance.get(node.tag);
    if (strategy != null && !strategy.isBlock) {
      strategy.buildInline(node, ctx, style);
    } else if (strategy != null) {
      // block inside inline — skip
    } else {
      for (final child in node.children) _renderChild(child, ctx, style);
    }
  }
}

class _ColorStrategy extends UbbStrategy {
  @override
  void buildInline(UbbNode node, InlineContext ctx, UbbTextStyle style) {
    final colorStr = node.getAttribute('color', '').replaceFirst('#', '');
    if (colorStr.length == 6) {
      final r = int.tryParse(colorStr.substring(0, 2), radix: 16) ?? 0;
      final g = int.tryParse(colorStr.substring(2, 4), radix: 16) ?? 0;
      final b = int.tryParse(colorStr.substring(4, 6), radix: 16) ?? 0;
      ctx.pushStyle(TextStyle(color: Color.fromARGB(255, r, g, b)));
    }
    for (final child in node.children) {
      _renderChild(child, ctx, style);
    }
    if (colorStr.length == 6) ctx.popStyle();
  }

  static void _renderChild(UbbNode node, InlineContext ctx, UbbTextStyle style) {
    if (node.isText) { ctx.addText(node.text); return; }
    final s = UbbStrategyRegistry.instance.get(node.tag);
    if (s != null && !s.isBlock) s.buildInline(node, ctx, style);
    else for (final c in node.children) _renderChild(c, ctx, style);
  }
}

class _SizeStrategy extends UbbStrategy {
  @override
  void buildInline(UbbNode node, InlineContext ctx, UbbTextStyle style) {
    final sizeStr = node.getAttribute('size');
    final size = int.tryParse(sizeStr);
    if (size != null) {
      ctx.pushStyle(TextStyle(fontSize: UbbTextStyle.convertUbbSize(size)));
    }
    for (final child in node.children) {
      _inlineChild(child, ctx, style);
    }
    if (size != null) ctx.popStyle();
  }
}

class _FontStrategy extends UbbStrategy {
  @override
  void buildInline(UbbNode node, InlineContext ctx, UbbTextStyle style) {
    final fontName = node.getAttribute('font');
    if (fontName.isNotEmpty) {
      ctx.pushStyle(TextStyle(fontFamily: fontName));
    }
    for (final child in node.children) {
      _inlineChild(child, ctx, style);
    }
    if (fontName.isNotEmpty) ctx.popStyle();
  }
}

class _UrlStrategy extends UbbStrategy {
  @override
  void buildInline(UbbNode node, InlineContext ctx, UbbTextStyle style) {
    final url = node.getAttribute('href');
    final text = _collectText(node);
    final displayText = url.isNotEmpty ? url : text;
    final recognizer = TapGestureRecognizer();
    if (ctx.onLinkTap != null) {
      recognizer.onTap = () => ctx.onLinkTap!(displayText);
    }
    ctx.addSpan(TextSpan(
      text: displayText,
      style: ctx.currentStyle.copyWith(
        color: const Color(0xFF00CED1),
        decoration: TextDecoration.underline,
      ),
      recognizer: recognizer,
    ));
  }
}

class _TopicStrategy extends UbbStrategy {
  @override
  void buildInline(UbbNode node, InlineContext ctx, UbbTextStyle style) {
    final topicId = node.getAttribute('value', '');
    if (topicId.isEmpty || !RegExp(r'^\d+$').hasMatch(topicId)) return;
    final url = 'https://www.cc98.org/topic/$topicId';
    final text = _collectText(node);
    final recognizer = TapGestureRecognizer();
    if (ctx.onLinkTap != null) {
      recognizer.onTap = () => ctx.onLinkTap!(url);
    }
    ctx.addSpan(TextSpan(
      text: text.isNotEmpty ? text : url,
      style: ctx.currentStyle.copyWith(
        color: const Color(0xFF00CED1),
        decoration: TextDecoration.underline,
      ),
      recognizer: recognizer,
    ));
  }
}

class _HeaderStrategy extends UbbStrategy {
  final int level;
  static const _sizes = {1: 28.0, 2: 26.0, 3: 24.0, 4: 22.0, 5: 20.0, 6: 18.0};

  _HeaderStrategy(this.level);

  @override
  bool get isBlock => true;

  @override
  Widget? buildWidget(UbbNode node, UbbTextStyle style,
      {void Function(String url)? onLinkTap}) {
    final fontSize = _sizes[level] ?? 16.0;
    final ctx = InlineContext(style.baseStyle.copyWith(
      fontSize: fontSize, fontWeight: FontWeight.bold,
    ));
    for (final child in node.children) {
      if (child.isText) ctx.addText(child.text);
      else {
        final s = UbbStrategyRegistry.instance.get(child.tag);
        if (s != null && !s.isBlock) s.buildInline(child, ctx, style);
      }
    }
    return Padding(
      padding: EdgeInsets.only(top: level == 1 ? 16 : 8, bottom: 4),
      child: RichText(text: TextSpan(children: ctx.spans)),
    );
  }
}

class _AlignStrategy extends UbbStrategy {
  final TextAlign _align;
  _AlignStrategy(this._align);

  @override
  void buildInline(UbbNode node, InlineContext ctx, UbbTextStyle style) {
    ctx.pushStyle(TextStyle(height: 1.5));
    for (final child in node.children) {
      if (child.isText) ctx.addText(child.text);
      else _inlineChild(child, ctx, style);
    }
    ctx.popStyle();
  }
}

// ── 块级策略实现 ───────────────────────────────────

class _ImgStrategy extends UbbStrategy {
  @override
  bool get isBlock => true;

  @override
  Widget? buildWidget(UbbNode node, UbbTextStyle style,
      {void Function(String url)? onLinkTap}) {
    final src = node.getAttribute('value');
    final url = src.isNotEmpty ? src : _collectText(node);
    if (url.isEmpty) return null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: GestureDetector(
        onTap: onLinkTap != null ? () => onLinkTap(url) : null,
        child: Image.network(url,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Text('[图片加载失败]', style: TextStyle(color: Colors.grey)),
        ),
      ),
    );
  }
}

class _AudioStrategy extends UbbStrategy {
  @override
  bool get isBlock => true;
  @override
  Widget? buildWidget(UbbNode node, UbbTextStyle style,
      {void Function(String url)? onLinkTap}) {
    final src = _collectText(node);
    if (src.isEmpty) return null;
    return AudioPlayerWidget(audioUrl: src);
  }
}

class _VideoStrategy extends UbbStrategy {
  @override
  bool get isBlock => true;
  @override
  Widget? buildWidget(UbbNode node, UbbTextStyle style,
      {void Function(String url)? onLinkTap}) {
    final src = node.getAttribute('value');
    final url = src.isNotEmpty ? src : _collectText(node);
    if (url.isEmpty) return null;
    return VideoFrame(videoUrl: url);
  }
}

class _CodeStrategy extends UbbStrategy {
  @override
  bool get isBlock => true;

  @override
  Widget? buildWidget(UbbNode node, UbbTextStyle style,
      {void Function(String url)? onLinkTap}) {
    final code = _collectText(node);
    final lang = node.getAttribute('language', '');
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: style.codeBackground ?? const Color(0xFFE8F4F9),
        borderRadius: BorderRadius.circular(4),
      ),
      child: SelectableText(
        code,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: style.baseStyle.fontSize,
        ),
      ),
    );
  }
}

class _QuoteStrategy extends UbbStrategy {
  static const int _maxVisibleDepth = 2;

  @override
  bool get isBlock => true;

  @override
  Widget? buildWidget(UbbNode node, UbbTextStyle style,
      {void Function(String url)? onLinkTap}) {
    final chain = _extractQuoteChain(node);
    if (chain.isEmpty) return null;
    return _buildQuoteContainer(chain, style, onLinkTap);
  }

  /// 提取所有嵌套引用层级（从浅到深）。
  List<UbbNode> _extractQuoteChain(UbbNode node) {
    final chain = <UbbNode>[];
    _collectQuotes(node, chain);
    return chain;
  }

  void _collectQuotes(UbbNode node, List<UbbNode> chain) {
    if (node.tag == 'quote' || node.tag == 'quotex') {
      chain.add(node);
      for (final child in node.children) {
        _collectQuotes(child, chain);
      }
    }
  }

  Widget _buildQuoteContainer(List<UbbNode> chain, UbbTextStyle style,
      void Function(String url)? onLinkTap) {
    final needCollapse = chain.length > _maxVisibleDepth;
    final visibleCount = _maxVisibleDepth.clamp(0, chain.length);

    final allChildren = <Widget>[];

    // 折叠部分（第3层及以后）
    if (needCollapse) {
      final collapsedQuotes = chain.sublist(_maxVisibleDepth);
      allChildren.add(_buildCollapsedSection(collapsedQuotes, style, onLinkTap));
      allChildren.add(_buildSeparator());
    }

    // 可见部分（前两层，从深到浅）
    for (int i = visibleCount - 1; i >= 0; i--) {
      allChildren.add(_renderSingleQuote(chain[i], style, onLinkTap));
      if (i > 0) allChildren.add(_buildSeparator());
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: style.quoteBackground ?? const Color(0x140078D7),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: allChildren,
      ),
    );
  }

  Widget _buildCollapsedSection(List<UbbNode> collapsedQuotes, UbbTextStyle style,
      void Function(String url)? onLinkTap) {
    return StatefulBuilder(
      builder: (context, setInnerState) {
        var isExpanded = false;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => setInnerState(() => isExpanded = !isExpanded),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isExpanded ? '收起引用' : '展开${collapsedQuotes.length}条引用',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
            if (isExpanded)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: collapsedQuotes.reversed.map((q) =>
                    _renderSingleQuote(q, style, onLinkTap)
                  ).toList(),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _renderSingleQuote(UbbNode node, UbbTextStyle style,
      void Function(String url)? onLinkTap) {
    final renderer = UbbRenderer(style: style, onLinkTap: onLinkTap);
    final content = <Widget>[];

    for (final child in node.children) {
      if (child.tag == 'quote' || child.tag == 'quotex') continue;
      final bbcode = _serializeNode(child);
      if (bbcode.isNotEmpty) {
        content.addAll(renderer.render(bbcode));
      }
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: const Color(0xFFFFC4AE),
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: content,
      ),
    );
  }

  Widget _buildSeparator() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: Colors.black.withAlpha(20),
    );
  }

  /// 将节点序列化为 BBCode 字符串，用于渲染器重新解析。
  String _serializeNode(UbbNode node) {
    if (node.isText) return node.text;
    final buf = StringBuffer();
    _writeNode(buf, node);
    return buf.toString();
  }

  void _writeNode(StringBuffer buf, UbbNode node) {
    if (node.isText) {
      buf.write(node.text);
      return;
    }
    buf.write('[');
    buf.write(node.tag);
    for (final entry in node.attributes.entries) {
      if (entry.value.isNotEmpty) {
        buf.write('=${entry.value}');
      }
    }
    buf.write(']');
    for (final child in node.children) {
      _writeNode(buf, child);
    }
    buf.write('[/${node.tag}]');
  }
}

class _HrStrategy extends UbbStrategy {
  @override
  bool get isBlock => true;

  @override
  Widget? buildWidget(UbbNode node, UbbTextStyle style,
      {void Function(String url)? onLinkTap}) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey.withAlpha(128),
            width: 1,
          ),
        ),
      ),
    );
  }
}

class _AlignBlockStrategy extends UbbStrategy {
  @override
  bool get isBlock => true;

  @override
  Widget? buildWidget(UbbNode node, UbbTextStyle style,
      {void Function(String url)? onLinkTap}) {
    final align = node.getAttribute('value', 'left');
    final renderer = UbbRenderer(style: style, onLinkTap: onLinkTap);
    final children = renderer.render(_collectText(node));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: align == 'center'
            ? CrossAxisAlignment.center
            : align == 'right'
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _TableStrategy extends UbbStrategy {
  @override
  bool get isBlock => true;

  @override
  Widget? buildWidget(UbbNode node, UbbTextStyle style,
      {void Function(String url)? onLinkTap}) {
    final renderer = UbbRenderer(style: style, onLinkTap: onLinkTap);
    return Table(
      border: TableBorder.all(color: Colors.grey.shade300),
      columnWidths: const {},
      defaultVerticalAlignment: TableCellVerticalAlignment.top,
      children: _buildRows(node, renderer),
    );
  }

  List<TableRow> _buildRows(UbbNode tableNode, UbbRenderer renderer) {
    final rows = <TableRow>[];
    for (final child in tableNode.children) {
      if (child.tag == 'tr') {
        final cells = child.children.where((c) => c.tag == 'td').toList();
        rows.add(TableRow(
          children: cells.map((cell) {
            final content = renderer.render(_collectText(cell));
            return Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: content,
              ),
            );
          }).toList(),
        ));
      }
    }
    return rows;
  }
}

class _TableRowStrategy extends UbbStrategy {
  @override
  bool get isBlock => true;
  @override
  Widget? buildWidget(UbbNode node, UbbTextStyle style,
      {void Function(String url)? onLinkTap}) =>
      const SizedBox.shrink();
}

class _TableCellStrategy extends UbbStrategy {
  @override
  bool get isBlock => true;
  @override
  Widget? buildWidget(UbbNode node, UbbTextStyle style,
      {void Function(String url)? onLinkTap}) =>
      const SizedBox.shrink();
}

class _ListStrategy extends UbbStrategy {
  @override
  bool get isBlock => true;

  @override
  Widget? buildWidget(UbbNode node, UbbTextStyle style,
      {void Function(String url)? onLinkTap}) {
    final renderer = UbbRenderer(style: style, onLinkTap: onLinkTap);
    final items = <Widget>[];
    for (final child in node.children) {
      if (child.tag == '*') {
        final content = renderer.render(_collectText(child));
        items.add(Padding(
          padding: const EdgeInsets.only(left: 20, top: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(fontSize: 14)),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: content,
              )),
            ],
          ),
        ));
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items,
    );
  }
}

class _UnorderedListStrategy extends _ListStrategy {}

class _ListItemStrategy extends UbbStrategy {
  @override
  bool get isBlock => true;
  @override
  Widget? buildWidget(UbbNode node, UbbTextStyle style,
      {void Function(String url)? onLinkTap}) =>
      const SizedBox.shrink();
}

class _SpoilerStrategy extends UbbStrategy {
  @override
  bool get isBlock => true;
  @override
  Widget? buildWidget(UbbNode node, UbbTextStyle style,
      {void Function(String url)? onLinkTap}) {
    final text = _collectText(node);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('⚠️ 以下内容可能剧透', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(text),
        ],
      ),
    );
  }
}

class _ReplyViewStrategy extends UbbStrategy {
  @override
  void buildInline(UbbNode node, InlineContext ctx, UbbTextStyle style) {
    ctx.addSpan(TextSpan(
      text: '此消息回复可见',
      style: ctx.currentStyle.copyWith(
        color: const Color(0xFF00CED1),
        fontStyle: FontStyle.italic,
      ),
    ));
  }
}

class _PosterOnlyStrategy extends UbbStrategy {
  @override
  void buildInline(UbbNode node, InlineContext ctx, UbbTextStyle style) {
    ctx.addSpan(TextSpan(
      text: '本楼开启了仅楼主可见',
      style: ctx.currentStyle.copyWith(color: Colors.red),
    ));
  }
}

class _AtStrategy extends UbbStrategy {
  @override
  void buildInline(UbbNode node, InlineContext ctx, UbbTextStyle style) {
    final username = _collectText(node);
    ctx.addSpan(TextSpan(
      text: '@$username',
      style: ctx.currentStyle.copyWith(
        color: const Color(0xFF00CED1),
      ),
    ));
  }
}

class _LatexStrategy extends UbbStrategy {
  @override
  bool get isBlock => true;
  @override
  Widget? buildWidget(UbbNode node, UbbTextStyle style,
      {void Function(String url)? onLinkTap}) =>
      const SizedBox.shrink();
}

class _FileStrategy extends UbbStrategy {
  @override
  bool get isBlock => true;
  @override
  Widget? buildWidget(UbbNode node, UbbTextStyle style,
      {void Function(String url)? onLinkTap}) =>
      const SizedBox.shrink();
}

class _BilibiliStrategy extends UbbStrategy {
  @override
  bool get isBlock => true;
  @override
  Widget? buildWidget(UbbNode node, UbbTextStyle style,
      {void Function(String url)? onLinkTap}) =>
      const SizedBox.shrink();
}

class _NoUbbStrategy extends UbbStrategy {
  @override
  void buildInline(UbbNode node, InlineContext ctx, UbbTextStyle style) {
    final text = _collectText(node);
    if (text.isNotEmpty) ctx.addText(text);
  }
}

class _MarkdownStrategy extends UbbStrategy {
  @override
  bool get isBlock => true;
  @override
  Widget? buildWidget(UbbNode node, UbbTextStyle style,
      {void Function(String url)? onLinkTap}) =>
      const SizedBox.shrink();
}

// ── 共用函数 ───────────────────────────────────────

String _collectText(UbbNode node) {
  final buf = StringBuffer();
  _collectTextRecursive(node, buf);
  return buf.toString().trim();
}

void _collectTextRecursive(UbbNode node, StringBuffer buf) {
  for (final child in node.children) {
    if (child.isText) {
      buf.write(child.text);
    } else {
      for (final c in child.children) _collectTextRecursive(c, buf);
    }
  }
}

void _inlineChild(UbbNode node, InlineContext ctx, UbbTextStyle style) {
  if (node.isText) { ctx.addText(node.text); return; }
  final s = UbbStrategyRegistry.instance.get(node.tag);
  if (s != null && !s.isBlock) s.buildInline(node, ctx, style);
  else for (final c in node.children) _inlineChild(c, ctx, style);
}

// ── 核心渲染器 ─────────────────────────────────────

/// 将 BBCode 字符串渲染为 Flutter Widget 列表。
class UbbRenderer {
  final UbbTextStyle style;
  final void Function(String url)? onLinkTap;

  UbbRenderer({this.style = const UbbTextStyle(), this.onLinkTap});

  List<Widget> render(String data) {
    final processed = UbbPreprocessor.preprocess(data);
    final nodes = bbob.parse(processed,
        validTags: UbbStrategyRegistry.instance.tagNames);
    final children = <Widget>[];
    _renderTo(nodes, InlineContext(style.baseStyle, onLinkTap: onLinkTap), children);
    return children;
  }

  void _renderTo(List<bbob.Node> nodeList, InlineContext ctx, List<Widget> out) {
    for (final node in nodeList) {
      if (node is bbob.Text) {
        if (node.text.isNotEmpty) ctx.addText(node.text);
        continue;
      }
      if (node is bbob.Element) {
        final tag = node.tag.toLowerCase();
        final strategy = UbbStrategyRegistry.instance.get(tag);
        if (strategy != null) {
          if (strategy.isBlock) {
            _flushInline(ctx, out);
            final widget = strategy.buildWidget(
                _convertElement(node), style,
                onLinkTap: onLinkTap);
            if (widget != null) out.add(widget);
          } else {
            strategy.buildInline(_convertElement(node), ctx, style);
          }
        } else {
          _renderTo(node.children, ctx, out);
        }
      }
    }
    _flushInline(ctx, out);
  }

  void _flushInline(InlineContext ctx, List<Widget> out) {
    if (ctx.spans.isNotEmpty) {
      out.add(RichText(
        softWrap: true,
        text: TextSpan(children: List.from(ctx.spans), style: style.baseStyle),
      ));
      ctx.spans.clear();
    }
  }

  UbbNode _convertElement(bbob.Element elem) {
    final tag = elem.tag.toLowerCase();
    // bbob_dart 将 [tag=val] 解析为 attributes: {val: val}。
    // 这里按 C# 惯例规范化属性键名。
    final rawAttrs = Map<String, String>.from(elem.attributes);
    final attrs = <String, String>{};
    if (rawAttrs.isNotEmpty) {
      final firstVal = rawAttrs.keys.first;
      switch (tag) {
        case 'color':
          attrs['color'] = firstVal;
        case 'size':
          attrs['size'] = firstVal;
        case 'font':
          attrs['font'] = firstVal;
        case 'url':
          attrs['href'] = firstVal;
        case 'code':
          attrs['language'] = firstVal;
        case 'quote':
        case 'quotex':
          attrs['author'] = firstVal;
        case 'topic':
          attrs['value'] = firstVal;
        case 'img':
        case 'audio':
        case 'video':
        case 'upload':
          attrs['value'] = firstVal;
        default:
          attrs.addAll(rawAttrs);
      }
    }
    return UbbNode(
      tag: tag,
      attributes: attrs,
      children: elem.children.map((c) {
        if (c is bbob.Text) return UbbNode.text(c.text);
        return _convertElement(c as bbob.Element);
      }).toList(),
    );
  }
}
