/// UBB 语法的最小单元（移植自 C# UbbTextBlock/Tokenizer）。
enum TokenType {
  leftBracket, // [
  rightBracket, // ]
  slash, // /
  equal, // =
  comma, // ,

  // 公式符号
  dollar, // $
  doubleDollar, // $$

  // 内容类
  at, // @用户名（含尾部空格）
  tagName, // b, url, img, ac01 等
  attrValue, // 属性值
  text, // 普通文本
  eof, // 结束符
}

class Token {
  final TokenType type;
  final String value;
  final int position;

  const Token(this.type, this.value, this.position);

  @override
  String toString() => 'Token($type, "$value")';
}

/// 将原始文本分解为一系列 Token 的词法分析器。
class UbbTokenizer {
  final String _input;
  bool _inTag = false;
  // 记录上一个 Token 类型以判断上下文
  TokenType _lastType = TokenType.eof;
  int _pos = 0;

  UbbTokenizer(this._input);

  String get _peek => _pos < _input.length ? _input[_pos] : '\x00';

  String _advance() => _input[_pos++];

  Iterable<Token> scanTokens() sync* {
    while (_pos < _input.length) {
      late Token token;
      if (_inTag) {
        token = _scanInTag();
      } else {
        final c = _peek;
        if (c == '[') {
          _inTag = true;
          final start = _pos;
          _advance();
          token = Token(TokenType.leftBracket, '[', start);
        } else if (c == r'$') {
          token = _scanMathDelimiter();
        } else if (c == '@') {
          token = _scanAtMention();
        } else {
          token = _scanText();
        }
      }

      _lastType = token.type;
      yield token;
    }

    yield Token(TokenType.eof, '', _pos);
  }

  Token _scanInTag() {
    final c = _peek;

    switch (c) {
      case ']':
        _inTag = false;
        final start = _pos;
        _advance();
        return Token(TokenType.rightBracket, ']', start);
      case ',':
        final start = _pos;
        _advance();
        return Token(TokenType.comma, ',', start);
      case '=':
        // 只有在 TagName 之后，等号才是属性开始的分隔符；
        // 否则（例如在 URL 内部），它是属性内容的一部分
        if (_lastType == TokenType.tagName) {
          final start = _pos;
          _advance();
          return Token(TokenType.equal, '=', start);
        }
        return _scanTagContent();
      case '/':
        if (_lastType == TokenType.leftBracket) {
          final start = _pos;
          _advance();
          return Token(TokenType.slash, '/', start);
        }
        return _scanTagContent();
      default:
        return _scanTagContent();
    }
  }

  Token _scanTagContent() {
    final start = _pos;
    while (_pos < _input.length && !_isTagDelimiter(_peek)) {
      _advance();
    }

    final value = _input.substring(start, _pos);

    // 根据上一个 Token 判断当前内容的性质：
    // 前面是 '[' 或 '[/'，则当前是标签名；否则（前面是 '=' 或 ','）视为属性值
    if (_lastType == TokenType.leftBracket || _lastType == TokenType.slash) {
      return Token(TokenType.tagName, value, start);
    }
    return Token(TokenType.attrValue, value, start);
  }

  Token _scanText() {
    final start = _pos;
    while (_pos < _input.length &&
        _peek != '[' &&
        _peek != r'$' &&
        _peek != '@') {
      _advance();
    }
    return Token(TokenType.text, _input.substring(start, _pos), start);
  }

  Token _scanMathDelimiter() {
    final start = _pos;
    _advance();
    if (_peek == r'$') {
      _advance();
      return Token(TokenType.doubleDollar, r'$$', start);
    }

    return Token(TokenType.dollar, r'$', start);
  }

  /// 扫描@提及，格式：@用户名（后跟空格）。
  /// 用户名限制：5个以内汉字或10个以内英文/数字，只能是汉字（包括日韩）、数字、外文字母。
  Token _scanAtMention() {
    final start = _pos;
    _advance(); // 消费 '@'

    final nameStart = _pos;
    var nameLength = 0;
    // 等效长度：字母数字算 1、汉字等东亚文字算 2，边扫描边累加
    var nameWidth = 0;
    var isValid = true;

    // 解析用户名
    while (_pos < _input.length) {
      final c = _peek;

      // 用户名后必须紧跟空格才结束
      if (c == ' ') break;

      // 检查字符是否合法
      if (!_isValidUsernameChar(c)) {
        isValid = false;
        break;
      }

      nameLength++;
      nameWidth += _isLetterOrDigit(c) ? 1 : 2;

      if (nameWidth > 10) {
        // 总等效长度限制为 10
        isValid = false;
        break;
      }

      _advance();
    }

    // 验证有效性：必须有用户名，且后跟空格
    if (isValid && nameLength > 0 && _pos < _input.length && _peek == ' ') {
      final username = _input.substring(nameStart, _pos);
      _advance(); // 消费空格
      return Token(TokenType.at, username, start);
    }

    // 无效情况：回退，将@作为普通文本处理
    _pos = start + 1;
    return Token(TokenType.text, '@', start);
  }

  // = 是否作为分隔符取决于当前上下文：] , 和 结束符永远是分隔符；
  // 只有在寻找 TagName 的阶段，= 才是分隔符
  bool _isTagDelimiter(String c) {
    if (c == ']' || c == ',' || c == '\x00') return true;

    if (c == '=' &&
        (_lastType == TokenType.leftBracket ||
            _lastType == TokenType.slash)) {
      return true;
    }

    return false;
  }

  static final RegExp _letterOrDigit = RegExp(r'[\p{L}\p{Nd}]', unicode: true);

  /// 判断单个 UTF-16 码元是否为字母或数字（对应 char.IsLetterOrDigit；
  /// 代理项对无法整体判断，按 C# 的行为视为不匹配）。
  static bool _isLetterOrDigit(String c) => _letterOrDigit.hasMatch(c);

  /// 判断字符是否为合法的用户名组成字符：
  /// 字母、数字、CJK 统一表意文字（基本区 + 扩展A/B，包括日文、韩文等东亚文字）。
  static bool _isValidUsernameChar(String c) {
    if (_isLetterOrDigit(c)) return true;

    final code = c.codeUnitAt(0);
    return (code >= 0x4E00 && code <= 0x9FFF) || // CJK统一表意文字
        (code >= 0x3400 && code <= 0x4DBF); // CJK扩展A
  }
}
