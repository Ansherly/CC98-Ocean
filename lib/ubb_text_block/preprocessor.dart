/// BBCode 预处理。在 bbob_dart 解析前对文本进行标准化转换。
///
/// 处理范围：
/// - Emoji 短码 ([tb02], [ac01] 等 → [img] 标签)
/// - 命名颜色 ([color=red] → [color=#ff0000])
/// - 对齐标签规范化 ([align=center] → [center])
/// - LaTeX 行内公式 ($...$ → [math]...[/math])
/// - @用户名 (@username → [at]username[/at])
class UbbPreprocessor {
  static final RegExp _emojiRegex = RegExp(r'\[([a-zA-Z]+)(\d+)\]');
  static final RegExp _latexInlineRegex = RegExp(r'\$(.+?)\$');
  static final RegExp _latexBlockRegex = RegExp(r'\$\$(.+?)\$\$', dotAll: true);
  static final RegExp _atRegex = RegExp(r'@([一-鿿\w]{1,10})\s');

  static const String _baseImagePath = 'assets/images/emoji/';

  static const Map<String, String> _colorMap = {
    'red': 'ff0000',
    'green': '008000',
    'blue': '0000ff',
    'yellow': 'ffff00',
    'purple': '800080',
    'orange': 'ffa500',
    'pink': 'ffc0cb',
    'brown': 'a52a2a',
    'black': '000000',
    'white': 'ffffff',
    'gray': '808080',
    'grey': '808080',
    'cyan': '00ffff',
    'magenta': 'ff00ff',
    'lime': '00ff00',
    'maroon': '800000',
    'olive': '808000',
    'teal': '008080',
    'navy': '000080',
    'silver': 'c0c0c0',
    'gold': 'ffd700',
    'violet': 'ee82ee',
    'indigo': '4b0082',
    'coral': 'ff7f50',
    'turquoise': '40e0d0',
    'salmon': 'fa8072',
    'aqua': '00ffff',
    'azure': 'f0ffff',
    'beige': 'f5f5dc',
    'crimson': 'dc143c',
    'darkblue': '00008b',
    'darkred': '8b0000',
    'khaki': 'f0e68c',
    'lavender': 'e6e6fa',
    'plum': 'dda0dd',
  };

  /// 对 BBCode 字符串进行全量预处理。
  static String preprocess(String input) {
    var result = input;
    result = _convertLatex(result);
    result = _convertAtMentions(result);
    result = _convertEmoji(result);
    result = _convertColorNames(result);
    result = _convertAlign(result);
    return result;
  }

  /// 转换 LaTeX 公式：`$...$` → `[math]...[/math]`，`$$...$$` → `[math]...[/math]`
  static String _convertLatex(String input) {
    // 先处理块级公式
    var result = input.replaceAllMapped(_latexBlockRegex, (m) => '[math]${m[1]}[/math]');
    // 再处理行内公式
    result = result.replaceAllMapped(_latexInlineRegex, (m) => '[math]${m[1]}[/math]');
    return result;
  }

  /// 转换 @提及：`@username ` → `[at]username[/at]`
  static String _convertAtMentions(String input) {
    return input.replaceAllMapped(_atRegex, (m) => '[at]${m[1]}[/at]');
  }

  /// 转换 Emoji 短码。
  static String _convertEmoji(String input) {
    return input.replaceAllMapped(_emojiRegex, (match) {
      final prefix = match.group(1)!;
      final number = match.group(2)!;
      String url;
      if (prefix == 'ac') {
        url = '$_baseImagePath$prefix-white/$prefix$number.png';
      } else if (prefix == 'tb' || prefix == 'em' || prefix == 'ms') {
        url = '$_baseImagePath$prefix/$prefix$number.png';
      } else if (prefix == 'cc') {
        url = '$_baseImagePath/CC$number.png';
      } else {
        return match.group(0)!;
      }
      return '[img]assets/$url[/img]';
    });
  }

  /// 转换命名颜色为十六进制。
  static String _convertColorNames(String input) {
    final colorRegex = RegExp(r'\[color=([a-zA-Z]+)\]');
    return input.replaceAllMapped(colorRegex, (match) {
      final name = match.group(1)!.toLowerCase();
      final hex = _colorMap[name];
      if (hex != null) return '[color=#$hex]';
      // 未知颜色名 → 用 ASCII 编码做 fallback
      final fallback = name.codeUnits
          .take(6)
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join('');
      return '[color=#$fallback]';
    });
  }

  /// 规范化对齐标签 [align=center] → [center]。
  static String _convertAlign(String input) {
    final regex = RegExp(r'\[align=([a-zA-Z]+)\](.*?)\[/align\]', dotAll: true);
    return input.replaceAllMapped(regex, (match) {
      final align = match.group(1)!.toLowerCase();
      final content = match.group(2)!;
      if (align == 'left' || align == 'center' || align == 'right') {
        return '[$align]$content[/$align]';
      }
      return match.group(0)!;
    });
  }
}
