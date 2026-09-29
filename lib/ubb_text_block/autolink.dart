/// 裸 URL 识别（移植自 C# UbbTextBlock/Common/AutoLinkDetector.cs）。
///
/// 只认 http:// 、https:// 与 www. 开头的链接；不做裸域名识别。
/// 把一段纯文本切成"普通文本 + 链接"若干段，供文本渲染策略输出可点击链接。
class AutoLinkSpan {
  final int start;
  final int length;
  final String url;

  const AutoLinkSpan(this.start, this.length, this.url);
}

class AutoLinkDetector {
  /// www. 链接点击时补全的协议。
  static const _defaultScheme = 'https://';

  /// 候选 URL：以 http(s):// 或 www. 开头，后接一串"URL 可能出现的字符"。
  /// 字符集刻意排除空白、引号、尖括号、方括号/花括号(UBB 标签语法)、反引号、
  /// 星号与中日韩标点；括号先纳入匹配，再由 [_trimTail] 按配对情况裁掉多余的右括号。
  static final RegExp _urlCandidateRegex = RegExp(
    r'''(?:(?:https?://)|(?:www\.))[^\s<>"'`\[\]{}*\u3000-\u303F\u4E00-\u9FFF\u3400-\u4DBF\uF900-\uFAFF\uFF00-\uFFEF\u2018\u2019\u201C\u201D\u2026\u2014\uFF5E]+''',
    caseSensitive: false,
  );

  /// 识别文本里的裸链接；没有命中时返回空列表。
  static List<AutoLinkSpan> detect(String text) {
    final spans = <AutoLinkSpan>[];
    if (text.isEmpty) return spans;

    for (final match in _urlCandidateRegex.allMatches(text)) {
      final candidate = match.group(0)!;
      final length = _trimTail(candidate);
      if (length <= 0) continue;

      var url = candidate.substring(0, length);
      // www. 开头的补上默认协议；http(s) 原样使用
      if (url.length >= 4 &&
          url.substring(0, 4).toLowerCase() == 'www.') {
        // 要求主机名里至少再有一个点(www.a.b)，挡掉 "www.foo" 这类误报
        var hostEnd = -1;
        for (var i = 4; i < url.length; i++) {
          final c = url[i];
          if (c == '/' || c == '?' || c == '#' || c == ':') {
            hostEnd = i;
            break;
          }
        }
        final host = hostEnd < 0 ? url.substring(4) : url.substring(4, hostEnd);
        if (!host.contains('.')) continue;
        url = _defaultScheme + url;
      }

      spans.add(AutoLinkSpan(match.start, length, url));
    }

    return spans;
  }

  /// 裁掉 URL 尾部的标点：先按配对裁掉多余的右括号，再反复裁掉中英文句读与引号。
  static int _trimTail(String candidate) {
    var length = candidate.length;

    // 1) 括号配对：只在"右括号多于左括号"时裁掉末尾的 ')'
    //    例：(https://a.com/x) → 裁掉收尾 ')'；https://a.com/Page_(film) → 保留成对括号
    while (length > 0 && candidate[length - 1] == ')') {
      var open = 0;
      var close = 0;
      for (var i = 0; i < length; i++) {
        if (candidate[i] == '(') {
          open++;
        } else if (candidate[i] == ')') {
          close++;
        }
      }

      if (close <= open) break;
      length--;
    }

    // 2) 尾部标点：句号、逗号、分号、冒号、感叹号、问号、引号等
    //    注意：右括号只归上面的配对规则管
    while (length > 0 && _isTrailingPunctuation(candidate[length - 1])) {
      length--;
    }

    return length;
  }

  static bool _isTrailingPunctuation(String c) {
    const punctuation = {
      '.', ',', ';', ':', '!', '?', '\'', '"', '>',
      '。', '，', '、', '；', '：', '！', '？', '…',
      '“', '”', '‘', '’',
      '（', '）', '【', '】', '「', '」', '『', '』',
      '《', '》', '〈', '〉',
    };
    return punctuation.contains(c);
  }
}
