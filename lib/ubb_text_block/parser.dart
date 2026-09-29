/// UBB 节点模型与解析器（移植自 C# UbbTextBlock/Parser）。

import 'tokenizer.dart';

/// UBB 节点类型。
enum UbbNodeType {
  document, // 文档根节点
  text, // 纯文本
  bold, // [b]
  italic, // [i]
  underline, // [u]
  strikethrough, // [del]
  size, // [size]
  font, // [font]
  color, // [color]
  url, // [url]
  topic, // [topic]
  image, // [img]
  audio, // [audio]
  video, // [video]
  code, // [code]
  quote, // [quote]
  align, // [align]
  left, // [left]
  center, // [center]
  right, // [right]
  table, // [table]
  tableRow, // [tr]
  tableCell, // [td]
  paragraph, // 段落（自动生成）
  divider, // [line] / [hr]
  emoji, // 表情 [em00] [ac01] 等
  latex, // 公式
  upload, // [upload]
  bilibili, // [bili]
  noUbb, // [noubb]
  markdown, // [md]
  needReply, // [needreply]
  replyView, // [replyview]
  posterOnly, // 仅楼主可见
  at, // @提及
}

/// 块级类型：出现在文本流两侧时会裁剪多余的换行。
extension UbbNodeTypeX on UbbNodeType {
  bool get isBlock {
    const blockTypes = {
      UbbNodeType.code,
      UbbNodeType.quote,
      UbbNodeType.table,
      UbbNodeType.tableRow,
      UbbNodeType.tableCell,
      UbbNodeType.image,
      UbbNodeType.audio,
      UbbNodeType.video,
      UbbNodeType.bilibili,
      UbbNodeType.paragraph,
      UbbNodeType.divider,
      UbbNodeType.align,
      UbbNodeType.left,
      UbbNodeType.center,
      UbbNodeType.right,
      UbbNodeType.noUbb,
      UbbNodeType.markdown,
      UbbNodeType.replyView,
    };
    return blockTypes.contains(this);
  }
}

abstract class UbbNode {
  UbbNodeType get type;
  final List<UbbNode> _children = [];
  List<UbbNode> get children => _children;

  UbbNode? parent;
  UbbNode? get previousSibling {
    if (parent == null) return null;
    final siblings = parent!._children;
    final index = siblings.indexOf(this);
    return index > 0 ? siblings[index - 1] : null;
  }

  UbbNode? get nextSibling {
    if (parent == null) return null;
    final siblings = parent!._children;
    final index = siblings.indexOf(this);
    return index >= 0 && index < siblings.length - 1
        ? siblings[index + 1]
        : null;
  }

  UbbNode? get firstChild => _children.isNotEmpty ? _children.first : null;

  void addChild(UbbNode child) {
    child.parent = this;
    _children.add(child);
  }
}

/// 纯文本节点。
class TextNode extends UbbNode {
  final String content;
  @override
  final UbbNodeType type = UbbNodeType.text;
  TextNode(this.content);
}

/// 标签节点。
class TagNode extends UbbNode {
  @override
  final UbbNodeType type;
  final Map<String, String> attributes;

  TagNode(this.type, this.attributes);

  String getAttribute(String key, [String defaultValue = '']) =>
      attributes[key] ?? defaultValue;
}

/// @提及节点（无子节点）。
class AtNode extends UbbNode {
  final String username;
  @override
  final UbbNodeType type = UbbNodeType.at;
  AtNode(this.username);
}

/// `$...$` / `$$...$$` 形式的 LaTeX 节点。
/// `[math]` 标签是 TagNode 而非 LatexNode（尽管 type 相同）。
class LatexNode extends UbbNode {
  final String latex;
  final bool isBlock;
  @override
  final UbbNodeType type = UbbNodeType.latex;
  LatexNode(this.latex, this.isBlock);
}

/// 文档根。
class UbbDocument {
  final UbbNode root = _DocumentNode();
}

class _DocumentNode extends UbbNode {
  @override
  final UbbNodeType type = UbbNodeType.document;
}

/// 将词元序列转换为 UBB 文档树的解析器。
class UbbParser {
  final List<Token> _tokens;
  int _index = 0;

  UbbParser(Iterable<Token> tokens) : _tokens = tokens.toList();

  Token get _peek =>
      _index < _tokens.length ? _tokens[_index] : const Token(TokenType.eof, '', -1);

  Token _consume() => _tokens[_index++];

  Token? _peekOffset(int offset) =>
      (_index + offset < _tokens.length) ? _tokens[_index + offset] : null;

  Token? get _peekNext => _peekOffset(1);

  static UbbDocument parse(String ubbText) {
    final parser = UbbParser(UbbTokenizer(ubbText).scanTokens());
    return parser._parseDocument();
  }

  UbbDocument _parseDocument() {
    final doc = UbbDocument();
    // 递归解析根节点，直到 EOF
    _parseContent(doc.root, null);
    return doc;
  }

  /// [closingTag] 为期望遇到的闭合标签类型，null 则解析到 EOF。
  void _parseContent(UbbNode parent, UbbNodeType? closingTag) {
    while (_index < _tokens.length) {
      final token = _peek;

      // 闭合标签检测
      if (token.type == TokenType.leftBracket &&
          _peekNext?.type == TokenType.slash) {
        final nextTagNameToken = _peekOffset(2);
        if (nextTagNameToken?.type == TokenType.tagName) {
          final foundType = _mapToNodeType(nextTagNameToken!.value);
          if (closingTag != null && closingTag == foundType) {
            // 消费 [/tag] 并返回
            _consume();
            _consume();
            _consume();
            if (_peek.type == TokenType.rightBracket) _consume();
            return;
          }

          if (closingTag != null && _isKnownType(foundType)) return;
        }
      }

      final node = _parseElement();
      if (node != null) {
        parent.addChild(node);

        if (node is TagNode && !_isSelfClosing(node.type)) {
          if (node.type == UbbNodeType.code ||
              node.type == UbbNodeType.noUbb ||
              node.type == UbbNodeType.markdown) {
            // 进入“逐字模式”，直接寻找闭合标签
            _parseVerbatimContent(node);
          } else {
            _parseContent(node, node.type);
          }
        }
      } else {
        _index++;
      }
    }
  }

  UbbNode? _parseElement() {
    final token = _peek;
    switch (token.type) {
      case TokenType.text:
        _consume();
        return TextNode(token.value);
      case TokenType.dollar:
      case TokenType.doubleDollar:
        return _parseLatex();
      case TokenType.at:
        _consume();
        return AtNode(token.value);
      case TokenType.leftBracket:
        _consume(); // 消耗 '['
        return _parseTagHeaderOrFallback();
      case TokenType.eof:
        return null;
      default:
        // 遇到未知的 Token 类型（如孤立的等号、逗号），当作文本处理
        _consume();
        return TextNode(token.value);
    }
  }

  // 处理标签头，失败则回退为文本
  UbbNode _parseTagHeaderOrFallback() {
    // 进入此方法前 '[' 已消费，记录起始索引以便回退
    final startIndex = _index - 1;

    // 1. 检查 TagName
    if (_peek.type != TokenType.tagName) return TextNode('[');

    final name = _consume().value;
    final type = _mapToNodeType(name);

    // 2. 如果是未知标签，直接回退
    if (type == UbbNodeType.text) return TextNode('[$name');

    final attributes = <String, String>{};
    var attrCount = 0;

    // 3. 解析属性循环
    while (_peek.type != TokenType.rightBracket &&
        _peek.type != TokenType.eof) {
      final t = _consume();

      if (t.type == TokenType.equal || t.type == TokenType.comma) {
        // 如果在等号/逗号后紧跟的是另一个 '['，说明格式非法
        if (_peek.type == TokenType.leftBracket) return _fallbackToText(startIndex);

        if (_peek.type == TokenType.attrValue) {
          final valToken = _consume();

          // 如果 Scanner 错误地将 '[' 包含在属性值中，这里进行二次检查
          if (valToken.value.contains('[')) return _fallbackToText(startIndex);

          final key = attrCount == 0 ? getAttributeName(type) : 'value$attrCount';
          attributes[key] = valToken.value;
          attrCount++;
        } else {
          // 有 = / , 但后面不是合法的属性值（也不是闭合括号），回退
          if (_peek.type != TokenType.rightBracket &&
              _peek.type != TokenType.comma) {
            return _fallbackToText(startIndex);
          }
        }
      } else {
        // 标签内部出现了意料之外的 Token 类型
        return _fallbackToText(startIndex);
      }
    }

    if (type == UbbNodeType.emoji) attributes['code'] = name;
    // 4. 检查是否以 ']' 正常结尾
    if (_peek.type == TokenType.rightBracket) {
      _consume();
      return TagNode(type, attributes);
    }

    // 到达 EOF 仍未闭合，回退
    return _fallbackToText(startIndex);
  }

  String getAttributeName(UbbNodeType type) {
    switch (type) {
      case UbbNodeType.size:
        return 'size';
      case UbbNodeType.font:
        return 'font';
      case UbbNodeType.color:
        return 'color';
      case UbbNodeType.url:
        return 'href';
      case UbbNodeType.code:
        return 'language';
      case UbbNodeType.quote:
        return 'author';
      case UbbNodeType.emoji:
        return 'code';
      default:
        return 'value';
    }
  }

  void _parseVerbatimContent(TagNode parent) {
    final sb = StringBuffer();
    // 确定要找的闭合标签类型
    final targetType = _getVerbatimTagType(parent.type);

    while (_index < _tokens.length) {
      // 探测：当前位置是否是闭合标签 [/targetName]
      if (_isClosingTag(targetType)) {
        // 将之前积累的所有文本存入 TextNode
        if (sb.isNotEmpty) parent.addChild(TextNode(sb.toString()));

        // 消费掉整个闭合标签 [/xxx]
        _consume(); // [
        _consume(); // /
        _consume(); // TagName
        if (_peek.type == TokenType.rightBracket) _consume(); // ]

        return;
      }

      // 没遇到闭合标签，则消费当前 Token 并记录其原始值
      sb.write(_consume().value);
    }

    // 容错：如果直到 EOF 都没找到闭合标签
    if (sb.isNotEmpty) parent.addChild(TextNode(sb.toString()));
  }

  // 精准探测闭合标签
  bool _isClosingTag(UbbNodeType tagType) {
    return _peek.type == TokenType.leftBracket &&
        _peekNext?.type == TokenType.slash &&
        _peekOffset(2)?.type == TokenType.tagName &&
        _mapToNodeType(_peekOffset(2)!.value) == tagType &&
        _peekOffset(3)?.type == TokenType.rightBracket;
  }

  LatexNode _parseLatex() {
    // 只有 $ 形式的 Latex 会调用到这里
    final token = _consume();
    final isBlock = token.type == TokenType.doubleDollar;
    var latex = '';
    if (_peek.type == TokenType.text) latex = _consume().value;
    if (_peek.type == token.type) _consume();
    return LatexNode(latex, isBlock);
  }

  bool _isKnownType(UbbNodeType type) =>
      type != UbbNodeType.text && type != UbbNodeType.document;

  bool _isSelfClosing(UbbNodeType type) {
    switch (type) {
      case UbbNodeType.divider: // [line]
      case UbbNodeType.emoji: // [ac01]
        return true;
      default:
        return false;
    }
  }

  UbbNodeType _getVerbatimTagType(UbbNodeType src) {
    switch (src) {
      case UbbNodeType.code:
      case UbbNodeType.noUbb:
      case UbbNodeType.markdown:
        return src;
      default:
        throw StateError('Not a verbatim tag: $src');
    }
  }

  // 注册新标签节点必要的映射
  UbbNodeType _mapToNodeType(String tagNameRaw) {
    final tagName = tagNameRaw.toLowerCase();
    // 处理 CC98 特有的表情前缀
    const emojiPrefixes = ['cc98', 'a:', 'c:', 'f:', 'tb', 'ms', 'em', 'ac'];
    for (final prefix in emojiPrefixes) {
      if (tagName.startsWith(prefix)) return UbbNodeType.emoji;
    }

    switch (tagName) {
      case 'b':
        return UbbNodeType.bold;
      case 'i':
        return UbbNodeType.italic;
      case 'u':
        return UbbNodeType.underline;
      case 'del':
        return UbbNodeType.strikethrough;
      case 'size':
        return UbbNodeType.size;
      case 'font':
        return UbbNodeType.font;
      case 'color':
        return UbbNodeType.color;
      case 'url':
        return UbbNodeType.url;
      case 'topic':
        return UbbNodeType.topic;
      case 'img':
        return UbbNodeType.image;
      case 'audio':
        return UbbNodeType.audio;
      case 'video':
        return UbbNodeType.video;
      case 'code':
        return UbbNodeType.code;
      case 'quote':
      case 'quotex':
        return UbbNodeType.quote;
      case 'align':
        return UbbNodeType.align;
      case 'left':
        return UbbNodeType.left;
      case 'center':
        return UbbNodeType.center;
      case 'right':
        return UbbNodeType.right;
      case 'table':
        return UbbNodeType.table;
      case 'tr':
        return UbbNodeType.tableRow;
      case 'td':
        return UbbNodeType.tableCell;
      case 'hr':
      case 'line':
        return UbbNodeType.divider;
      case 'math':
        return UbbNodeType.latex;
      case 'bili':
        return UbbNodeType.bilibili;
      case 'upload':
        return UbbNodeType.upload;
      case 'noubb':
        return UbbNodeType.noUbb;
      case 'md':
        return UbbNodeType.markdown;
      case 'replyview':
        return UbbNodeType.replyView;
      case 'needreply':
        return UbbNodeType.needReply;
      default:
        return UbbNodeType.text;
    }
  }

  // 将当前解析进度涉及的所有 Token 还原为原始文本
  TextNode _fallbackToText(int startIndex) {
    final sb = StringBuffer();
    for (var i = startIndex; i < _index; i++) {
      sb.write(_tokens[i].value);
    }
    return TextNode(sb.toString());
  }
}
