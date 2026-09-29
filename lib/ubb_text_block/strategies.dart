import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:cc98_ocean/controls/markdown_view.dart';

import 'package:cc98_ocean/controls/audio_player.dart';
import 'package:cc98_ocean/controls/video_player.dart';

import 'autolink.dart';
import 'emoticon_rules.dart';
import 'parser.dart';
import 'render_context.dart';

// ── 节点分发 ─────────────────────────────────────────

/// 渲染策略注册表（对应 C# UbbTextBlock.RenderStrategies）。
final Map<UbbNodeType, void Function(UbbNode node, UbbRenderContext ctx)> ubbRenderStrategies = {
  UbbNodeType.text: _renderText,
  UbbNodeType.bold: _renderBold,
  UbbNodeType.italic: _renderItalic,
  UbbNodeType.underline: _renderUnderline,
  UbbNodeType.strikethrough: _renderStrikethrough,
  UbbNodeType.size: _renderSize,
  UbbNodeType.font: _renderFont,
  UbbNodeType.color: _renderColor,
  UbbNodeType.url: _renderUrl,
  UbbNodeType.topic: _renderTopic,
  UbbNodeType.image: _renderImage,
  UbbNodeType.audio: _renderAudio,
  UbbNodeType.video: _renderVideo,
  UbbNodeType.bilibili: _renderBilibili,
  UbbNodeType.upload: _renderFile,
  UbbNodeType.code: _renderCode,
  UbbNodeType.quote: _renderFlatQuote,
  UbbNodeType.align: _renderAlign,
  UbbNodeType.left: _renderLeft,
  UbbNodeType.center: _renderCenter,
  UbbNodeType.right: _renderRight,
  UbbNodeType.table: _renderTable,
  UbbNodeType.tableRow: _renderTableRow,
  UbbNodeType.tableCell: _renderTableCell,
  UbbNodeType.paragraph: _renderParagraph,
  UbbNodeType.emoji: _renderEmoji,
  UbbNodeType.latex: _renderLatex,
  UbbNodeType.divider: _renderDivider,
  UbbNodeType.markdown: _renderMarkdown,
  UbbNodeType.at: _renderAt,
  UbbNodeType.replyView: _renderReplyView,
  UbbNodeType.needReply: _renderReplyView,
  UbbNodeType.posterOnly: _renderPosterOnly,
};

extension UbbNodeRender on UbbRenderContext {
  void renderNode(UbbNode node) {
    final strategy = ubbRenderStrategies[node.type];
    if (strategy != null) {
      strategy(node, this);
    } else {
      // 未匹配到渲染策略时，忽略此层级并渲染子节点
      for (final child in node.children) {
        renderNode(child);
      }
    }
  }
}

// ── 共用函数 ─────────────────────────────────────────

/// 递归收集节点内的所有文本（对应 RenderHelper.CollectText）。
String collectText(UbbNode node) {
  final sb = StringBuffer();
  void collect(UbbNode n) {
    for (final child in n.children) {
      if (child is TextNode) {
        sb.write(child.content);
      } else {
        collect(child);
      }
    }
  }

  collect(node);
  return sb.toString().trim();
}

/// 链接统一样式（颜色 + 可选下划线），所有链接类策略共用。
TextStyle linkStyle(UbbRenderContext ctx, {bool underline = true}) {
  return TextStyle(
    color: ctx.config.linkColor,
    decoration: underline ? TextDecoration.underline : TextDecoration.none,
  );
}

/// 由当前基础样式取前景色（用于推导半透明色）。
Color? _foreground(UbbRenderContext ctx) => ctx.config.baseStyle.color;

/// URL 合法性检查。[requireScheme] 为 false 时不强制 http/https 前缀。
bool isValidUrl(String s, {bool requireScheme = true}) {
  if (s.isEmpty) return false;
  final uri = Uri.tryParse(s);
  if (uri == null || uri.host.isEmpty) return false;
  if (requireScheme && uri.scheme != 'http' && uri.scheme != 'https') {
    return false;
  }
  return true;
}

void _onMedia(UbbRenderContext ctx, String src, UbbMediaType type) {
  ctx.config.onMediaTap?.call(src, type);
}

// ── 文本渲染策略（含裸 URL 自动链接） ─────────────────

void _renderText(UbbNode node, UbbRenderContext ctx) {
  final textNode = node as TextNode;
  if (textNode.content.trim().isEmpty) return;

  var content = textNode.content;
  if (node.parent?.type == UbbNodeType.document) {
    final prevIsBlock = node.previousSibling?.type.isBlock ?? false;
    final nextIsBlock = node.nextSibling?.type.isBlock ?? false;

    if (prevIsBlock) content = content.replaceFirst(RegExp(r'^[\r\n]+'), '');
    if (nextIsBlock) content = content.replaceFirst(RegExp(r'[\r\n]+$'), '');
  }

  if (content.isEmpty) return;

  // 裸 URL 自动链接：开关关闭、或文本处于 [url] 内部时，一律按原文输出
  final enableAutoLink = ctx.config.autoLink && _isAutoLinkAllowed(node);
  final spans = enableAutoLink ? AutoLinkDetector.detect(content) : <AutoLinkSpan>[];

  if (spans.isEmpty) {
    ctx.addText(content);
    return;
  }

  // 按识别结果分段输出：普通文本 → TextSpan，链接 → 带识别器的 TextSpan
  var cursor = 0;
  for (final span in spans) {
    if (span.start > cursor) {
      ctx.addText(content.substring(cursor, span.start));
    }

    final url = span.url;
    final recognizer = ctx.createRecognizer(() => _onMedia(ctx, url, UbbMediaType.link));
    ctx.addInline(TextSpan(
      text: content.substring(span.start, span.start + span.length),
      style: linkStyle(ctx),
      recognizer: recognizer,
    ));

    cursor = span.start + span.length;
  }

  if (cursor < content.length) ctx.addText(content.substring(cursor));
}

/// 该文本节点是否允许自动链接：位于 [url] 内部时不参与。
/// 沿父链向上查，走到块级边界（或文档根）为止。
bool _isAutoLinkAllowed(UbbNode node) {
  for (var parent = node.parent; parent != null; parent = parent.parent) {
    if (parent.type == UbbNodeType.url) return false;
    if (parent.type == UbbNodeType.document || parent.type.isBlock) return true;
  }
  return true;
}

// ── 行内样式策略 ─────────────────────────────────────

void _renderBold(UbbNode node, UbbRenderContext ctx) {
  // 字体为空时不能赋值，应以宿主设置为准
  final boldFontFamily = ctx.config.boldFontFamily;
  ctx.beginInlineContainer(TextStyle(
    fontWeight: FontWeight.bold,
    fontFamily: boldFontFamily,
  ));
  for (final child in node.children) {
    ctx.renderNode(child);
  }
  ctx.endInlineContainer();
}

void _renderItalic(UbbNode node, UbbRenderContext ctx) {
  ctx.beginInlineContainer(const TextStyle(fontStyle: FontStyle.italic));
  for (final child in node.children) {
    ctx.renderNode(child);
  }
  ctx.endInlineContainer();
}

void _renderUnderline(UbbNode node, UbbRenderContext ctx) {
  ctx.beginInlineContainer(const TextStyle(decoration: TextDecoration.underline));
  for (final child in node.children) {
    ctx.renderNode(child);
  }
  ctx.endInlineContainer();
}

void _renderStrikethrough(UbbNode node, UbbRenderContext ctx) {
  ctx.beginInlineContainer(const TextStyle(decoration: TextDecoration.lineThrough));
  for (final child in node.children) {
    ctx.renderNode(child);
  }
  ctx.endInlineContainer();
}

// ── 字号 / 字体 / 颜色 ───────────────────────────────

void _renderSize(UbbNode node, UbbRenderContext ctx) {
  final tagNode = node as TagNode;
  final sizeStr = tagNode.getAttribute('size');
  final sizeInt = int.tryParse(sizeStr);
  if (sizeInt == null) {
    // 解析失败，默认渲染子节点
    for (final child in node.children) {
      ctx.renderNode(child);
    }
    return;
  }

  final pixels =
      sizeStr.contains('px') ? sizeInt.toDouble() : _convertUbbSizeToPixels(sizeInt);
  ctx.beginInlineContainer(TextStyle(fontSize: pixels));
  for (final child in node.children) {
    ctx.renderNode(child);
  }
  ctx.endInlineContainer();
}

double _convertUbbSizeToPixels(int ubbSize) {
  // 简单的分段线性插值
  if (ubbSize <= 1) return 8;
  if (ubbSize == 2) return 10;
  if (ubbSize == 3) return 13;
  if (ubbSize == 4) return 17;
  if (ubbSize == 5) return 22;
  if (ubbSize == 6) return 26;
  if (ubbSize == 7) return 30;
  if (ubbSize == 8) return 32;
  if (ubbSize == 9) return 34;
  if (ubbSize == 10) return 35;
  if (ubbSize == 11) return 35.5;
  if (ubbSize == 12) return 35.8;
  if (ubbSize == 13) return 36;

  // 超过13后缓慢增长
  return 36 + (ubbSize - 13) * 0.5;
}

void _renderFont(UbbNode node, UbbRenderContext ctx) {
  final tagNode = node as TagNode;
  final fontName = tagNode.getAttribute('font');
  if (fontName.isEmpty) {
    for (final child in node.children) {
      ctx.renderNode(child);
    }
    return;
  }

  ctx.beginInlineContainer(TextStyle(fontFamily: fontName));
  for (final child in node.children) {
    ctx.renderNode(child);
  }
  ctx.endInlineContainer();
}

void _renderColor(UbbNode node, UbbRenderContext ctx) {
  final tagNode = node as TagNode;
  final colorStr = tagNode.getAttribute('color');
  if (colorStr.isEmpty) {
    for (final child in node.children) {
      ctx.renderNode(child);
    }
    return;
  }

  Color? color;
  try {
    color = _parseColor(colorStr);
  } catch (_) {
    // 解析失败，使用默认颜色
  }

  ctx.beginInlineContainer(color != null ? TextStyle(color: color) : const TextStyle());
  for (final child in node.children) {
    ctx.renderNode(child);
  }
  ctx.endInlineContainer();
}

Color _parseColor(String colorStrRaw) {
  // 移除可能的 #
  final colorStr = colorStrRaw.trim().replaceFirst(RegExp(r'^#+'), '');
  switch (colorStr.toLowerCase()) {
    case 'black':
      return Colors.black;
    case 'white':
      return Colors.white;
    case 'red':
      return Colors.red;
    case 'green':
      return Colors.green;
    case 'blue':
      return const Color.fromARGB(255, 142, 130, 254); // CC98 主题蓝
    case 'gray':
    case 'grey':
      return Colors.grey;
    case 'yellow':
      return Colors.yellow;
    case 'purple':
      return Colors.purple;
    case 'orange':
      return Colors.orange;
    case 'transparent':
      return Colors.transparent;
    case 'pink':
      return Colors.pink;
    case 'gold':
      return const Color(0xFFFFD700);
    default:
      return _colorFromRgb(colorStr);
  }
}

Color _colorFromRgb(String colorStr) {
  if (colorStr.length == 6) {
    final r = int.tryParse(colorStr.substring(0, 2), radix: 16);
    final g = int.tryParse(colorStr.substring(2, 4), radix: 16);
    final b = int.tryParse(colorStr.substring(4, 6), radix: 16);
    if (r != null && g != null && b != null) {
      return Color.fromARGB(255, r, g, b);
    }
  }
  return Colors.black;
}

// ── 链接类 ───────────────────────────────────────────

void _renderUrl(UbbNode node, UbbRenderContext ctx) {
  final tagNode = node as TagNode;
  var url = tagNode.getAttribute('href');
  if (url.isEmpty) {
    // [url]链接文本[/url] 形式：链接在子文本中。
    // href 非空时原样使用（相对路径如 /topic/1#5 由 LinkNavigator 处理）
    final first = node.firstChild;
    if (first is TextNode) url = first.content;
  }

  final recognizer = ctx.createRecognizer(() => _onMedia(ctx, url, UbbMediaType.link));
  ctx.beginInlineContainer(linkStyle(ctx), recognizer);
  for (final child in node.children) {
    ctx.renderNode(child);
  }
  ctx.endInlineContainer();
}

void _renderTopic(UbbNode node, UbbRenderContext ctx) {
  final tagNode = node as TagNode;
  final topicId = tagNode.getAttribute('value');
  // 必须是纯数字，否则不渲染
  if (topicId.isEmpty || !RegExp(r'^\d+$').hasMatch(topicId)) return;

  final url = 'https://www.cc98.org/topic/$topicId';
  final recognizer = ctx.createRecognizer(() => _onMedia(ctx, url, UbbMediaType.link));
  ctx.beginInlineContainer(linkStyle(ctx), recognizer);
  for (final child in node.children) {
    ctx.renderNode(child);
  }
  ctx.endInlineContainer();
}

void _renderAt(UbbNode node, UbbRenderContext ctx) {
  final atNode = node as AtNode;
  // @ 提及沿用链接色，但保持无下划线
  final recognizer =
      ctx.createRecognizer(() => _onMedia(ctx, atNode.username, UbbMediaType.atUser));
  ctx.beginInlineContainer(linkStyle(ctx, underline: false), recognizer);
  ctx.addText('@${atNode.username}');
  ctx.endInlineContainer();
}

void _renderBilibili(UbbNode node, UbbRenderContext ctx) {
  // BV 号补全用的视频页前缀
  const videoUrlPrefix = 'https://www.bilibili.com/video/';

  // 取值顺序：属性 [bili=BVxxx] → 子文本 [bili]BVxxx[/bili]
  var raw = node is TagNode ? node.getAttribute('value') : '';
  if (raw.trim().isEmpty) raw = collectText(node);
  raw = raw.trim();

  if (raw.isEmpty) return;

  // 已是完整地址则原样使用，否则按 BV/av 号补全为视频页地址
  final url = raw.toLowerCase().startsWith('http') ? raw : videoUrlPrefix + raw.replaceFirst(RegExp(r'^/+'), '');

  final recognizer = ctx.createRecognizer(() => _onMedia(ctx, url, UbbMediaType.link));
  ctx.addInline(TextSpan(
    text: raw,
    style: linkStyle(ctx),
    recognizer: recognizer,
  ));
}

// ── 图片 ─────────────────────────────────────────────

void _renderImage(UbbNode node, UbbRenderContext ctx) {
  final tagNode = node as TagNode;
  final value = tagNode.getAttribute('value');
  var src = '';
  if (!isValidUrl(value, requireScheme: false)) {
    // 尝试从子节点获取URL（对于 [img]url[/img] 格式）
    final first = node.firstChild;
    if (first is TextNode) src = first.content;
  } else {
    src = value;
  }

  if (!isValidUrl(src, requireScheme: false)) return;

  ctx.addToContainer(_HideableImage(
    url: src,
    maxWidth: ctx.config.imageMaxWidth,
    maxHeight: ctx.config.imageMaxHeight,
    // UBB 隐藏图片语法
    hidden: ctx.config.hideImage || value == '1',
    onTap: () => _onMedia(ctx, src, UbbMediaType.image),
  ));
}

class _HideableImage extends StatefulWidget {
  final String url;
  final double maxWidth;
  final double maxHeight;
  final bool hidden;
  final VoidCallback onTap;

  const _HideableImage({
    required this.url,
    required this.maxWidth,
    required this.maxHeight,
    required this.hidden,
    required this.onTap,
  });

  @override
  State<_HideableImage> createState() => _HideableImageState();
}

class _HideableImageState extends State<_HideableImage> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (widget.hidden && !_revealed) {
      content = InkWell(
        onTap: () => setState(() => _revealed = true),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.withAlpha(0x1F),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.visibility, size: 16),
              SizedBox(width: 4),
              Text('点击显示图片', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      );
    } else {
      content = Image.network(
        widget.url,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Text(
          '[图片加载失败]',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: GestureDetector(
        onTap: widget.onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: widget.maxWidth,
            maxHeight: widget.maxHeight,
          ),
          child: content,
        ),
      ),
    );
  }
}

// ── 代码块 ───────────────────────────────────────────

void _renderCode(UbbNode node, UbbRenderContext ctx) {
  final languageName = node is TagNode ? node.getAttribute('language') : '';
  final foreground = _foreground(ctx);
  final background =
      ctx.config.codeBackground ?? UbbRenderConfig.fill(foreground, 0x1F);
  final code = collectText(node);

  ctx.addToContainer(Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    margin: const EdgeInsets.fromLTRB(4, 2, 4, 2),
    decoration: BoxDecoration(
      color: background,
      border: Border.all(color: UbbRenderConfig.subtle(foreground)),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (languageName.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              languageName,
              style: TextStyle(
                fontSize: 11,
                color: UbbRenderConfig.subtle(foreground, 0x88),
              ),
            ),
          ),
        SelectableText(
          code,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: ctx.config.baseStyle.fontSize,
            color: ctx.config.baseStyle.color,
          ),
        ),
      ],
    ),
  ));
}

// ── 段落 / 对齐 ──────────────────────────────────────

void _renderParagraph(UbbNode node, UbbRenderContext ctx) {
  ctx.finalizeCurrentTextBlock();
}

void _renderAlignValue(UbbNode node, UbbRenderContext ctx, String align) {
  ctx.finalizeCurrentTextBlock();

  // 使用 Column 进行对齐控制
  final panel = <Widget>[];

  // 切入面板渲染子节点（容器状态的保存 / 恢复由上下文统一负责）
  ctx.pushContainer(panel);
  for (final child in node.children) {
    ctx.renderNode(child);
  }
  ctx.finalizeCurrentTextBlock();
  ctx.popContainer();

  // 将面板添加回之前的容器
  ctx.addToContainer(Column(
    crossAxisAlignment: align == 'center'
        ? CrossAxisAlignment.center
        : align == 'right'
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
    children: panel,
  ));
}

void _renderAlign(UbbNode node, UbbRenderContext ctx) {
  ctx.finalizeCurrentTextBlock();
  final align = (node as TagNode).getAttribute('value', 'left').toLowerCase();
  _renderAlignValue(node, ctx, align);
}

void _renderLeft(UbbNode node, UbbRenderContext ctx) =>
    _renderAlignValue(node, ctx, 'left');

void _renderCenter(UbbNode node, UbbRenderContext ctx) =>
    _renderAlignValue(node, ctx, 'center');

void _renderRight(UbbNode node, UbbRenderContext ctx) =>
    _renderAlignValue(node, ctx, 'right');

// ── 引用（扁平化 + 折叠） ─────────────────────────────

const int _maxVisibleDepth = 2;

void _renderFlatQuote(UbbNode node, UbbRenderContext ctx) {
  ctx.finalizeCurrentTextBlock();

  // 提取引用链（所有层级）
  final quoteChain = <UbbNode>[];
  _extractAllQuotes(node, quoteChain);

  if (quoteChain.isEmpty) return;

  ctx.addToContainer(_QuoteContainer(
    quoteChain: quoteChain,
    config: ctx.config,
    renderQuote: (quoteNode, panel) {
      final childCtx = ctx.createChildContext(panel);
      // 渲染引用内容（跳过嵌套的引用，它们已经被提取出来了）
      for (final child in quoteNode.children) {
        if (child.type != UbbNodeType.quote) childCtx.renderNode(child);
      }
      childCtx.finalizeCurrentTextBlock();
    },
  ));
}

void _extractAllQuotes(UbbNode node, List<UbbNode> chain) {
  if (node.type == UbbNodeType.quote) {
    chain.add(node);

    // 查找所有直接子引用
    for (final child in node.children) {
      if (child.type == UbbNodeType.quote) {
        _extractAllQuotes(child, chain);
      }
    }
  }
}

class _QuoteContainer extends StatefulWidget {
  final List<UbbNode> quoteChain;
  final UbbRenderConfig config;
  final void Function(UbbNode quoteNode, List<Widget> panel) renderQuote;

  const _QuoteContainer({
    required this.quoteChain,
    required this.config,
    required this.renderQuote,
  });

  @override
  State<_QuoteContainer> createState() => _QuoteContainerState();
}

class _QuoteContainerState extends State<_QuoteContainer> {
  bool _expanded = false;

  Widget _separator() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 5),
      color: UbbRenderConfig.subtle(widget.config.baseStyle.color),
    );
  }

  Widget _renderSingleQuote(UbbNode quoteNode) {
    final contentPanel = <Widget>[];
    widget.renderQuote(quoteNode, contentPanel);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: contentPanel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chain = widget.quoteChain;
    final needCollapse = chain.length > _maxVisibleDepth;
    final visibleCount = chain.length < _maxVisibleDepth ? chain.length : _maxVisibleDepth;

    final children = <Widget>[];

    // 折叠部分（第3层及以后）
    if (needCollapse) {
      final collapsedQuotes = chain.sublist(_maxVisibleDepth);
      children.add(InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: UbbRenderConfig.subtle(widget.config.baseStyle.color, 0x14),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            _expanded ? '收起引用' : '展开${collapsedQuotes.length}条引用',
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ));
      children.add(const SizedBox(height: 4));

      if (_expanded) {
        // 折叠的引用按从深到浅的顺序展示
        children.add(const SizedBox(height: 8));
        for (var i = collapsedQuotes.length - 1; i >= 0; i--) {
          children.add(_renderSingleQuote(collapsedQuotes[i]));
          if (i > 0) children.add(_separator());
        }
        children.add(_separator());
      }
    }

    // 可见部分（前两层）
    for (var i = visibleCount - 1; i >= 0; i--) {
      children.add(_renderSingleQuote(chain[i]));
      // 在引用之间添加分割线（除了最后一个）
      if (i > 0) children.add(_separator());
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: widget.config.quoteBackground ??
            UbbRenderConfig.fill(widget.config.baseStyle.color, 0x14),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

// ── 表格 ─────────────────────────────────────────────

void _renderTable(UbbNode node, UbbRenderContext ctx) {
  ctx.finalizeCurrentTextBlock();

  // 解析表格结构
  final rows = <List<UbbNode>>[];
  for (final child in node.children) {
    if (child.type == UbbNodeType.tableRow) {
      final cells = child.children
          .where((cell) => cell.type == UbbNodeType.tableCell)
          .toList();
      rows.add(cells.cast<UbbNode>());
    }
  }

  var columns = 0;
  for (final row in rows) {
    if (row.length > columns) columns = row.length;
  }

  if (rows.isEmpty || columns == 0) return;

  final foreground = _foreground(ctx);
  final border = BorderSide(color: UbbRenderConfig.subtle(foreground));

  ctx.addToContainer(Table(
    border: TableBorder.all(color: border.color, width: border.width),
    defaultVerticalAlignment: TableCellVerticalAlignment.top,
    columnWidths: {
      for (var i = 0; i < columns; i++) i: const FlexColumnWidth(1),
    },
    children: [
      for (final row in rows)
        TableRow(
          children: [
            for (var j = 0; j < columns; j++)
              TableCell(
                child: j < row.length
                    ? _buildCell(row[j], ctx)
                    : const SizedBox.shrink(),
              ),
          ],
        ),
    ],
  ));
}

Widget _buildCell(UbbNode cellNode, UbbRenderContext ctx) {
  final contentPanel = <Widget>[];
  final childCtx = ctx.createChildContext(contentPanel);
  for (final child in cellNode.children) {
    childCtx.renderNode(child);
  }
  childCtx.finalizeCurrentTextBlock();

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: contentPanel,
    ),
  );
}

void _renderTableRow(UbbNode node, UbbRenderContext ctx) {
  // 表格行由表格策略统一处理；独立出现时渲染子节点
  for (final child in node.children) {
    ctx.renderNode(child);
  }
}

void _renderTableCell(UbbNode node, UbbRenderContext ctx) {
  for (final child in node.children) {
    ctx.renderNode(child);
  }
}

// ── 分隔线 ───────────────────────────────────────────

void _renderDivider(UbbNode node, UbbRenderContext ctx) {
  ctx.addToContainer(Padding(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
    child: CustomPaint(
      size: const Size(double.infinity, 2),
      painter: _DashedLinePainter(
        color: UbbRenderConfig.subtle(_foreground(ctx)),
      ),
    ),
  ));
}

class _DashedLinePainter extends CustomPainter {
  final Color color;

  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashWidth = 4.0;
    const dashGap = 4.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, size.height / 2),
          Offset(x + dashWidth, size.height / 2), paint);
      x += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}

// ── 表情 ─────────────────────────────────────────────

void _renderEmoji(UbbNode node, UbbRenderContext ctx) {
  // 不 finalize，保持在当前文本流
  final tagNode = node as TagNode;
  final emoticonCode = tagNode.getAttribute('code');
  if (emoticonCode.isEmpty) return;

  final assetPath = EmoticonRules.getEmoticonUrl(emoticonCode);
  if (assetPath == null) {
    ctx.addText('[$emoticonCode]');
    return;
  }

  ctx.addInline(WidgetSpan(
    alignment: PlaceholderAlignment.middle,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Image.asset(
        assetPath,
        width: 32,
        height: 32,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Text('[$emoticonCode]'),
      ),
    ),
  ));
}

// ── LaTeX ────────────────────────────────────────────

void _renderLatex(UbbNode node, UbbRenderContext ctx) {
  if (node is LatexNode) {
    // $...$ / $$...$$ 形式：行内公式
    ctx.addInline(WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Math.tex(
        node.latex,
        mathStyle: MathStyle.text,
        textStyle: const TextStyle(fontSize: 14),
        onErrorFallback: (error) => Text(error.message,
            style: const TextStyle(color: Colors.red, fontSize: 12)),
      ),
    ));
  } else {
    // [math]...[/math] 标签形式：块级公式
    ctx.finalizeCurrentTextBlock();
    final codeText = collectText(node);
    ctx.addToContainer(Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Math.tex(
        codeText,
        mathStyle: MathStyle.display,
        textStyle: const TextStyle(fontSize: 14),
        onErrorFallback: (error) => Text(error.message,
            style: const TextStyle(color: Colors.red, fontSize: 12)),
      ),
    ));
  }
}

// ── Markdown ─────────────────────────────────────────

void _renderMarkdown(UbbNode node, UbbRenderContext ctx) {
  ctx.finalizeCurrentTextBlock();

  final codeText = collectText(node);
  ctx.addToContainer(MarkdownView(codeText, selectable: false));
}

// ── 音频 / 视频 / 文件 ───────────────────────────────

void _renderAudio(UbbNode node, UbbRenderContext ctx) {
  final first = node.firstChild;
  if (first is! TextNode) return;

  final src = first.content;
  if (!isValidUrl(src, requireScheme: false)) {
    ctx.addInline(TextSpan(text: '[无效音频链接: $src]'));
    return;
  }

  ctx.addToContainer(Padding(
    padding: const EdgeInsets.all(10),
    child: AudioPlayerWidget(audioUrl: src),
  ));
}

void _renderVideo(UbbNode node, UbbRenderContext ctx) {
  final tagNode = node as TagNode;
  var src = tagNode.getAttribute('value');
  if (src.isEmpty) {
    // 尝试从子节点获取URL
    final first = node.firstChild;
    if (first is TextNode) src = first.content;
  }

  if (src.isEmpty) return;

  ctx.addToContainer(Padding(
    padding: const EdgeInsets.all(10),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 400),
      child: VideoFrame(videoUrl: src),
    ),
  ));
}

void _renderFile(UbbNode node, UbbRenderContext ctx) {
  final tagNode = node as TagNode;
  var src = tagNode.getAttribute('value');
  if (!isValidUrl(src, requireScheme: false)) {
    // 尝试从子节点获取URL
    final first = node.firstChild;
    if (first is TextNode) src = first.content;
  }

  if (!isValidUrl(src, requireScheme: false)) return;

  final fileName = Uri.tryParse(src)?.pathSegments.isNotEmpty == true
      ? Uri.parse(src).pathSegments.last
      : src;

  ctx.addToContainer(Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: InkWell(
      onTap: () => _onMedia(ctx, src, UbbMediaType.file),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: UbbRenderConfig.subtle(_foreground(ctx))),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.description_outlined, size: 20),
            const SizedBox(width: 8),
            Flexible(child: Text(fileName, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    ),
  ));
}

// ── 可见性提示 ───────────────────────────────────────

void _renderReplyView(UbbNode node, UbbRenderContext ctx) {
  ctx.addInline(TextSpan(
    text: '此消息回复可见',
    style: TextStyle(color: ctx.config.linkColor),
  ));
}

void _renderPosterOnly(UbbNode node, UbbRenderContext ctx) {
  ctx.addInline(const TextSpan(
    text: '本楼开启了仅楼主可见',
    style: TextStyle(color: Colors.red),
  ));
}
