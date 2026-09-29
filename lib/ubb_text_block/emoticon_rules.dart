/// 表情规则（移植自 C# EmoticonRules，URL 模板改为 Flutter 资源路径）。
///
/// URL 模板中的 `\$1`、`\$2` 会被替换为正则捕获组。
class EmoticonRule {
  final RegExp pattern;
  final String urlTemplate;

  const EmoticonRule(this.pattern, this.urlTemplate);

  bool isMatch(String tagName) => pattern.hasMatch(tagName);

  String getUrl(String tagName) {
    return tagName.replaceAllMapped(pattern, (m) {
      return urlTemplate.replaceAllMapped(RegExp(r'\$(\d+)'), (g) {
        return m.group(int.parse(g.group(1)!)) ?? '';
      });
    });
  }
}

class EmoticonRules {
  static const String _basePath = 'assets/images/emoji';

  static final List<EmoticonRule> rules = [
    // ac娘：ac + 2~4位数字
    EmoticonRule(
        RegExp(r'^ac(\d{2,4})$', caseSensitive: false),
        '$_basePath/ac-white/ac\$1.png'),
    // 经典表情：em + 2位数字
    EmoticonRule(
        RegExp(r'^em(\d{2})$', caseSensitive: false),
        '$_basePath/em/em\$1.gif'),
    // 贴吧/雀魂等：任意2字母 + 2位数字
    EmoticonRule(
        RegExp(r'^([a-zA-Z]{2})(\d{2})$'), '$_basePath/\$1/\$1\$2.png'),
    // CC98：cc98 + 2位数字
    EmoticonRule(
        RegExp(r'^cc98(\d{2})$', caseSensitive: false),
        '$_basePath/CC98/CC98\$1.gif'),
  ];

  static bool isEmoticonTag(String tagName) {
    if (tagName.isEmpty) return false;
    return rules.any((rule) => rule.isMatch(tagName));
  }

  /// 按规则顺序匹配，返回第一个命中的资源路径。
  static String? getEmoticonUrl(String tagName) {
    if (tagName.isEmpty) return null;
    for (final rule in rules) {
      if (rule.isMatch(tagName)) return rule.getUrl(tagName);
    }
    return null;
  }
}
