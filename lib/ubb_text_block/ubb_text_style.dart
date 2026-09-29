import 'package:flutter/material.dart';

/// 帖子正文的基准字号。UBB 与 Markdown 渲染共用，保证两者视觉一致。
const double kPostContentFontSize = 15.0;

/// UBB 文本渲染的样式配置（对应 C# UbbTextBlock 的依赖属性）。
class UbbTextStyle {
  /// 段落基础样式（字号 / 前景色 / 字体）。
  ///
  /// 注意：[UbbText] 会把该样式与环境的 [DefaultTextStyle] 合并，
  /// 因此字体家族与颜色默认继承应用主题（Hm Sans），此处只需给出字号。
  final TextStyle baseStyle;

  /// 粗体字体（为空时仅加粗，继承基础字体）。
  final String? boldFontFamily;

  /// 代码块背景色（为空时由前景色推导半透明色）。
  final Color? codeBackground;

  /// 引用背景色（为空时由前景色推导半透明色）。
  final Color? quoteBackground;

  /// 链接颜色，默认 CC98 传统色 LightSeaGreen。
  final Color linkColor;

  final double imageMaxWidth;
  final double imageMaxHeight;

  /// 是否隐藏图片（含 UBB 隐藏图片语法 [img=1]）。
  final bool hideImage;

  /// 是否把正文里的裸 URL 自动渲染成可点击链接。
  final bool autoLink;

  const UbbTextStyle({
    this.baseStyle = const TextStyle(fontSize: kPostContentFontSize),
    this.boldFontFamily,
    this.codeBackground,
    this.quoteBackground,
    this.linkColor = const Color(0xFF20B2AA), // LightSeaGreen
    this.imageMaxWidth = 400.0,
    this.imageMaxHeight = double.infinity,
    this.hideImage = false,
    this.autoLink = true,
  });

  UbbTextStyle copyWith({
    TextStyle? baseStyle,
    String? boldFontFamily,
    Color? codeBackground,
    Color? quoteBackground,
    Color? linkColor,
    double? imageMaxWidth,
    double? imageMaxHeight,
    bool? hideImage,
    bool? autoLink,
  }) =>
      UbbTextStyle(
        baseStyle: baseStyle ?? this.baseStyle,
        boldFontFamily: boldFontFamily ?? this.boldFontFamily,
        codeBackground: codeBackground ?? this.codeBackground,
        quoteBackground: quoteBackground ?? this.quoteBackground,
        linkColor: linkColor ?? this.linkColor,
        imageMaxWidth: imageMaxWidth ?? this.imageMaxWidth,
        imageMaxHeight: imageMaxHeight ?? this.imageMaxHeight,
        hideImage: hideImage ?? this.hideImage,
        autoLink: autoLink ?? this.autoLink,
      );

  static double convertUbbSize(int ubbSize) {
    if (ubbSize <= 1) return 8.0;
    if (ubbSize == 2) return 10.0;
    if (ubbSize == 3) return 13.0;
    if (ubbSize == 4) return 17.0;
    if (ubbSize == 5) return 22.0;
    if (ubbSize == 6) return 26.0;
    if (ubbSize == 7) return 30.0;
    if (ubbSize == 8) return 32.0;
    if (ubbSize == 9) return 34.0;
    if (ubbSize == 10) return 35.0;
    if (ubbSize == 11) return 35.5;
    if (ubbSize == 12) return 35.8;
    if (ubbSize == 13) return 36.0;
    if (ubbSize > 13) return 36.0 + (ubbSize - 13) * 0.5;
    return 14.0;
  }
}
