import 'package:flutter/material.dart';

/// 匹配 C# UbbTextBlock 的属性配置。
class UbbTextStyle {
  final TextStyle baseStyle;
  final TextStyle? boldStyle;
  final Color? codeBackground;
  final Color? quoteBackground;
  final double imageMaxWidth;
  final bool hideImage;

  const UbbTextStyle({
    this.baseStyle = const TextStyle(fontSize: 14, color: Colors.black87),
    this.boldStyle,
    this.codeBackground = const Color(0xFFE8F4F9),
    this.quoteBackground = const Color(0x140078D7),
    this.imageMaxWidth = 400.0,
    this.hideImage = false,
  });

  TextStyle get effectiveBoldStyle =>
      boldStyle ?? baseStyle.copyWith(fontWeight: FontWeight.bold);

  static const Map<int, double> ubbSizeToPixels = {
    1: 8.0,
    2: 10.0,
    3: 13.0,
    4: 17.0,
    5: 22.0,
    6: 26.0,
    7: 30.0,
    8: 32.0,
    9: 34.0,
    10: 35.0,
    11: 35.5,
    12: 35.8,
    13: 36.0,
  };

  static double convertUbbSize(int ubbSize) {
    if (ubbSize <= 1) return 8.0;
    if (ubbSize > 13) return 36.0 + (ubbSize - 13) * 0.5;
    return ubbSizeToPixels[ubbSize] ?? 14.0;
  }

  UbbTextStyle copyWith({
    TextStyle? baseStyle,
    TextStyle? boldStyle,
    Color? codeBackground,
    Color? quoteBackground,
    double? imageMaxWidth,
    bool? hideImage,
  }) =>
      UbbTextStyle(
        baseStyle: baseStyle ?? this.baseStyle,
        boldStyle: boldStyle ?? this.boldStyle,
        codeBackground: codeBackground ?? this.codeBackground,
        quoteBackground: quoteBackground ?? this.quoteBackground,
        imageMaxWidth: imageMaxWidth ?? this.imageMaxWidth,
        hideImage: hideImage ?? this.hideImage,
      );
}
