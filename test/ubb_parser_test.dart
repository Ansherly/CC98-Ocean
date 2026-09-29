import 'package:cc98_ocean/ubb_text_block/parser.dart';
import 'package:cc98_ocean/ubb_text_block/tokenizer.dart';
import 'package:cc98_ocean/ubb_text_block/autolink.dart';
import 'package:cc98_ocean/ubb_text_block/emoticon_rules.dart';
import 'package:flutter_test/flutter_test.dart';

UbbNode parseOne(String input) {
  final doc = UbbParser.parse(input);
  return doc.root;
}

void main() {
  group('Tokenizer', () {
    test('splits tag headers and attributes', () {
      final tokens = UbbTokenizer('[url=https://a.com,x]text[/url]')
          .scanTokens()
          .toList();
      expect(tokens.map((t) => t.type).toList(), [
        TokenType.leftBracket,
        TokenType.tagName,
        TokenType.equal,
        TokenType.attrValue,
        TokenType.comma,
        TokenType.attrValue,
        TokenType.rightBracket,
        TokenType.text,
        TokenType.leftBracket,
        TokenType.slash,
        TokenType.tagName,
        TokenType.rightBracket,
        TokenType.eof,
      ]);
    });

    test('= inside url attr is part of the value', () {
      final tokens = UbbTokenizer('[url=https://a.com/?a=b]t[/url]')
          .scanTokens()
          .toList();
      final attr = tokens.firstWhere((t) => t.type == TokenType.attrValue);
      expect(attr.value, 'https://a.com/?a=b');
    });

    test('@mention requires trailing space and CJK width limit', () {
      final tokens = UbbTokenizer('@某人 hello').scanTokens().toList();
      expect(tokens.first.type, TokenType.at);
      expect(tokens.first.value, '某人');

      // 无空格跟随 → 回退为普通文本
      final invalid = UbbTokenizer('@某人hello').scanTokens().toList();
      expect(invalid.first.type, TokenType.text);
      expect(invalid.first.value, '@');
    });

    test('math delimiters', () {
      final tokens = UbbTokenizer(r'$x$$y$').scanTokens().toList();
      expect(tokens[0].type, TokenType.dollar);
      expect(tokens[1].type, TokenType.text);
      expect(tokens[2].type, TokenType.doubleDollar);
    });
  });

  group('Parser', () {
    test('simple tag nesting', () {
      final root = parseOne('[b]bold[i]both[/i][/b]');
      expect(root.children, hasLength(1));
      final bold = root.children[0] as TagNode;
      expect(bold.type, UbbNodeType.bold);
      expect(bold.children, hasLength(2));
      expect((bold.children[1] as TagNode).type, UbbNodeType.italic);
    });

    test('unknown tag falls back to text', () {
      final root = parseOne('a[unknown]b[/unknown]c');
      // 未知标签的开头与结尾都按原文输出（与 C# 一致）
      final texts = root.children.cast<TextNode>().map((n) => n.content);
      expect(texts.join(''), 'a[unknown]b[/unknown]c');
    });

    test('malformed attribute falls back to raw text', () {
      final root = parseOne('[size=[b]]x[/size]');
      // 非法属性使标签头回退为文本；已消费的 Token 拼回原文（与 C# 一致）
      expect((root.children[0] as TextNode).content, '[size=[b');
    });

    test('verbatim content keeps raw inner tags', () {
      final root = parseOne('[code]a [b]c[/b] d[/code]');
      final code = root.children[0] as TagNode;
      expect(code.type, UbbNodeType.code);
      expect((code.children[0] as TextNode).content, 'a [b]c[/b] d');
    });

    test('noubb verbatim until EOF without closing tag', () {
      final root = parseOne('[noubb]x [b] y');
      final noubb = root.children[0] as TagNode;
      expect(noubb.type, UbbNodeType.noUbb);
      expect((noubb.children[0] as TextNode).content, 'x [b] y');
    });

    test('unclosed tag still renders with content at EOF', () {
      final root = parseOne('hello [b]world');
      expect(root.children[0], isA<TextNode>());
      final bold = root.children[1] as TagNode;
      expect(bold.type, UbbNodeType.bold);
      expect((bold.children[0] as TextNode).content, 'world');
    });

    test('emoji prefixes map to emoji nodes', () {
      for (final name in ['ac01', 'em00', 'tb02', 'ms01', 'cc9801']) {
        final root = parseOne('[$name]');
        final node = root.children[0] as TagNode;
        expect(node.type, UbbNodeType.emoji, reason: name);
        expect(node.getAttribute('code'), name);
      }
    });

    test('quote nesting produces nested tree', () {
      final root = parseOne('[quote]outer[quote]inner[/quote][/quote]');
      final quote = root.children[0] as TagNode;
      expect(quote.type, UbbNodeType.quote);
      final inner = quote.children.whereType<TagNode>().toList();
      expect(inner, hasLength(1));
      expect(inner[0].type, UbbNodeType.quote);
    });

    test('inline latex via dollar and block via double dollar', () {
      final root = parseOne(r'$a+b$ and $$c$$');
      final inline = root.children[0] as LatexNode;
      expect(inline.latex, 'a+b');
      expect(inline.isBlock, isFalse);
      // 中间的 " and " 文本
      expect((root.children[1] as TextNode).content, ' and ');
      final block = root.children[2] as LatexNode;
      expect(block.latex, 'c');
      expect(block.isBlock, isTrue);
    });

    test('at mention node', () {
      final root = parseOne('@admin hi');
      final at = root.children[0] as AtNode;
      expect(at.username, 'admin');
    });

    test('attribute mapping for known tags', () {
      final root = parseOne('[url=https://a.com]x[/url][color=red]y[/color]');
      final url = root.children[0] as TagNode;
      expect(url.getAttribute('href'), 'https://a.com');
      final color = root.children[1] as TagNode;
      expect(color.getAttribute('color'), 'red');
    });
  });

  group('AutoLinkDetector', () {
    test('detects http and www links', () {
      final spans = AutoLinkDetector.detect('看 https://a.com/x 和 www.cc98.org/topic/1');
      expect(spans, hasLength(2));
      expect(spans[0].url, 'https://a.com/x');
      expect(spans[1].url, 'https://www.cc98.org/topic/1');
    });

    test('trims trailing punctuation and unbalanced parens', () {
      expect(AutoLinkDetector.detect('(https://a.com/x)')[0].url,
          'https://a.com/x');
      expect(AutoLinkDetector.detect('https://a.com/Page_(film)')[0].url,
          'https://a.com/Page_(film)');
      expect(AutoLinkDetector.detect('去 https://a.com。')[0].url,
          'https://a.com');
    });

    test('rejects www without dot in host', () {
      expect(AutoLinkDetector.detect('www.foo 后续'), isEmpty);
    });
  });

  group('EmoticonRules', () {
    test('maps codes to asset paths', () {
      expect(EmoticonRules.getEmoticonUrl('ac01'),
          'assets/images/emoji/ac-white/ac01.png');
      expect(EmoticonRules.getEmoticonUrl('em00'),
          'assets/images/emoji/em/em00.gif');
      expect(EmoticonRules.getEmoticonUrl('tb02'),
          'assets/images/emoji/tb/tb02.png');
      expect(EmoticonRules.getEmoticonUrl('cc9801'),
          'assets/images/emoji/CC98/CC9801.gif');
      // 通用规则(2字母+2数字)对任意前缀生效，与 C# 一致；
      // 但解析器的 emoji 前缀白名单不会把 zz99 当作表情节点
      expect(EmoticonRules.getEmoticonUrl('zz99'),
          'assets/images/emoji/zz/zz99.png');
    });
  });
}
